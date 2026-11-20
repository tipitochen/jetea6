#!/usr/bin/env python3
"""Emulador NES minimo (CPU 6502 + PPU aproximada + MMC3) solo para probar GTA6.nes."""
from PIL import Image

PAL = [(84,84,84),(0,30,116),(8,16,144),(48,0,136),(68,0,100),(92,0,48),(84,4,0),(60,24,0),(32,42,0),(8,58,0),(0,64,0),(0,60,0),(0,50,60),(0,0,0),(0,0,0),(0,0,0),
(152,150,152),(8,76,196),(48,50,236),(92,30,228),(136,20,176),(160,20,100),(152,34,32),(120,60,0),(84,90,0),(40,114,0),(8,124,0),(0,118,40),(0,102,120),(0,0,0),(0,0,0),(0,0,0),
(236,238,236),(76,154,236),(120,124,236),(176,98,236),(228,84,236),(236,88,180),(236,106,100),(212,136,32),(160,170,0),(116,196,0),(76,208,32),(56,204,108),(56,180,204),(60,60,60),(0,0,0),(0,0,0),
(236,238,236),(168,204,236),(188,188,236),(212,178,236),(236,174,236),(236,174,212),(236,180,176),(228,196,144),(204,210,120),(180,222,120),(168,226,144),(152,226,180),(160,214,228),(160,162,160),(0,0,0),(0,0,0)]

C, Z, I, D, B, U, V, N = 1, 2, 4, 8, 16, 32, 64, 128

class NES:
    def __init__(self, path, idle_addr=None):
        d = open(path, 'rb').read()
        np, nc = d[4], d[5]
        self.prg = d[16:16 + np * 16384]
        self.chr = d[16 + np * 16384:16 + np * 16384 + nc * 8192]
        self.nprg8 = len(self.prg) // 8192
        self.ram = bytearray(0x800)
        self.vram = bytearray(0x800)
        self.palram = bytearray(32)
        self.oam = bytearray(256)
        self.bank_sel = 0; self.regs = [0, 2, 4, 5, 6, 7, 0, 1]
        self.irq_latch = 0; self.irq_counter = 0; self.irq_reload = False
        self.irq_en = False; self.irq_line = False
        self.ctrl = 0; self.mask = 0; self.status = 0
        self.v = 0; self.t = 0; self.fx = 0; self.w = 0; self.buf = 0; self.oamaddr = 0
        self.pad = 0; self.pad_shift = 0; self.pad2 = 0; self.pad2_shift = 0; self.strobe = 0
        self.a = self.x = self.y = 0; self.sp = 0xFD; self.p = I | U
        self.cyc = 0
        self.pc = self.rd16(0xFFFC)
        self.nmi_pending = False
        self.idle = idle_addr
        self.frame = 0
        self.line_h = [0] * 240
        self.irq_count = 0
        self.late_w = 0; self.late_max = -999; self.last_w = 0
        self.sprite_limit = True
        self.line_chr = [(0, 0)] * 240
        self.apu_writes = 0
        self.base = 0
        self.idle_cyc = 0
        self.target = 0

    # ---------------- mapeo
    def prg_off(self, addr):
        slot = (addr - 0x8000) >> 13
        mode = (self.bank_sel >> 6) & 1
        last = self.nprg8 - 1
        if slot == 0: b = self.regs[6] if mode == 0 else last - 1
        elif slot == 1: b = self.regs[7]
        elif slot == 2: b = last - 1 if mode == 0 else self.regs[6]
        else: b = last
        return (b % self.nprg8) * 8192 + (addr & 0x1FFF)

    def chr_addr(self, a):
        # modo A12 sin invertir
        if (self.bank_sel & 0x80) == 0:
            if a < 0x800: base = (self.regs[0] & 0xFE) * 1024 + a
            elif a < 0x1000: base = (self.regs[1] & 0xFE) * 1024 + (a - 0x800)
            else:
                k = (a - 0x1000) >> 10
                base = self.regs[2 + k] * 1024 + (a & 0x3FF)
        else:
            raise Exception("modo CHR invertido no soportado")
        return base % len(self.chr)

    def nt_index(self, a):
        a &= 0xFFF
        # mirroring vertical (A000=0)
        return a & 0x7FF

    # ---------------- bus
    def rd(self, a):
        if a < 0x2000: return self.ram[a & 0x7FF]
        if a < 0x4000:
            r = a & 7
            if r == 2:
                v = self.status; self.status &= 0x7F; self.w = 0; return v
            if r == 7:
                va = self.v & 0x3FFF
                if va >= 0x3F00:
                    v = self.palram[va & 0x1F]
                else:
                    v = self.buf; self.buf = self.ppu_read(va)
                self.v = (self.v + (32 if self.ctrl & 4 else 1)) & 0x7FFF
                return v
            return 0
        if a == 0x4016:
            v = self.pad_shift & 1
            self.pad_shift = (self.pad_shift >> 1) | 0x80
            return v | 0x40
        if a == 0x4017:
            v = self.pad2_shift & 1
            self.pad2_shift = (self.pad2_shift >> 1) | 0x80
            return v | 0x40
        if a >= 0x8000: return self.prg[self.prg_off(a)]
        return 0

    def ppu_read(self, va):
        if va < 0x2000: return self.chr[self.chr_addr(va)]
        return self.vram[self.nt_index(va)]

    def wr(self, a, val):
        if a < 0x2000: self.ram[a & 0x7FF] = val; return
        if a < 0x4000:
            r = a & 7
            if r == 7 and (self.mask & 0x18):
                ln = (self.cyc - self.base) * 3 // 341
                self.last_w = ln
                if ln < 241 or ln >= 261:
                    self.late_w += 1; self.late_max = max(self.late_max, ln if ln < 241 else ln - 262)
            if r == 0:
                self.ctrl = val; self.t = (self.t & 0xF3FF) | ((val & 3) << 10)
            elif r == 1: self.mask = val
            elif r == 3: self.oamaddr = val
            elif r == 4: self.oam[self.oamaddr] = val; self.oamaddr = (self.oamaddr + 1) & 255
            elif r == 5:
                if self.w == 0:
                    self.t = (self.t & 0xFFE0) | (val >> 3); self.fx = val & 7; self.w = 1
                else:
                    self.t = (self.t & 0x8C1F) | ((val & 7) << 12) | ((val >> 3) << 5); self.w = 0
            elif r == 6:
                if self.w == 0:
                    self.t = (self.t & 0x00FF) | ((val & 0x3F) << 8); self.w = 1
                else:
                    self.t = (self.t & 0xFF00) | val; self.v = self.t; self.w = 0
            elif r == 7:
                va = self.v & 0x3FFF
                if va >= 0x3F00:
                    i = va & 0x1F
                    if i in (0x10, 0x14, 0x18, 0x1C): i -= 0x10
                    self.palram[i] = val
                elif va >= 0x2000:
                    self.vram[self.nt_index(va)] = val
                self.v = (self.v + (32 if self.ctrl & 4 else 1)) & 0x7FFF
            return
        if a == 0x4014:
            base = val << 8
            for i in range(256):
                self.oam[(self.oamaddr + i) & 255] = self.rd(base + i)
            self.cyc += 513; return
        if a == 0x4016:
            if val & 1:
                self.pad_shift = int('{:08b}'.format(self.pad)[::-1], 2)
                self.pad2_shift = int('{:08b}'.format(self.pad2)[::-1], 2)
            return
        if a < 0x4020: self.apu_writes += 1; return
        if a >= 0x8000:
            reg = a & 0xE001
            if reg == 0x8000: self.bank_sel = val
            elif reg == 0x8001: self.regs[self.bank_sel & 7] = val
            elif reg == 0xC000: self.irq_latch = val
            elif reg == 0xC001: self.irq_counter = 0; self.irq_reload = True
            elif reg == 0xE000: self.irq_en = False; self.irq_line = False
            elif reg == 0xE001: self.irq_en = True

    def rd16(self, a): return self.rd(a) | (self.rd(a + 1) << 8)

    def clock_mmc3(self):
        if self.irq_counter == 0 or self.irq_reload:
            self.irq_counter = self.irq_latch; self.irq_reload = False
        else:
            self.irq_counter -= 1
        if self.irq_counter == 0 and self.irq_en:
            self.irq_line = True

    # ---------------- CPU
    def push(self, v): self.ram[0x100 + self.sp] = v; self.sp = (self.sp - 1) & 255
    def pop(self): self.sp = (self.sp + 1) & 255; return self.ram[0x100 + self.sp]
    def setzn(self, v):
        self.p = (self.p & ~(Z | N)) | (Z if v == 0 else 0) | (v & 0x80)
    def interrupt(self, vec):
        self.push(self.pc >> 8); self.push(self.pc & 255); self.push((self.p | U) & ~B)
        self.p |= I; self.pc = self.rd16(vec); self.cyc += 7

    def step(self):
        if self.nmi_pending:
            self.nmi_pending = False; self.interrupt(0xFFFA); return
        if self.irq_line and not (self.p & I):
            self.irq_count += 1
            self.interrupt(0xFFFE); return
        if self.idle is not None and self.pc == self.idle and self.ram[0x11] == 0:
            self.idle_cyc += self.target - self.cyc; self.cyc = self.target; return
        pc = self.pc
        op = self.rd(pc)
        self.pc = (pc + 1) & 0xFFFF
        f = OPT[op]
        if f is None:
            raise Exception("opcode ilegal %02X en %04X" % (op, pc))
        f[0](self, f[1])
        self.cyc += f[2]

    def addr(self, mode):
        pc = self.pc
        if mode == 'imm': self.pc = pc + 1; return pc
        if mode == 'zp': self.pc = pc + 1; return self.rd(pc)
        if mode == 'zpx': self.pc = pc + 1; return (self.rd(pc) + self.x) & 255
        if mode == 'zpy': self.pc = pc + 1; return (self.rd(pc) + self.y) & 255
        if mode == 'abs': self.pc = pc + 2; return self.rd16(pc)
        if mode == 'abx': self.pc = pc + 2; return (self.rd16(pc) + self.x) & 0xFFFF
        if mode == 'aby': self.pc = pc + 2; return (self.rd16(pc) + self.y) & 0xFFFF
        if mode == 'izx':
            self.pc = pc + 1; z = (self.rd(pc) + self.x) & 255
            return self.ram[z] | (self.ram[(z + 1) & 255] << 8)
        if mode == 'izy':
            self.pc = pc + 1; z = self.rd(pc)
            return ((self.ram[z] | (self.ram[(z + 1) & 255] << 8)) + self.y) & 0xFFFF
        if mode == 'ind':
            self.pc = pc + 2; a = self.rd16(pc)
            return self.rd(a) | (self.rd((a & 0xFF00) | ((a + 1) & 0xFF)) << 8)
        raise Exception(mode)

    # ---------------- frame
    def run_frame(self, buttons=0, buttons2=0):
        self.pad = buttons; self.pad2 = buttons2
        for line in range(262):
            dots_end = (line + 1) * 341
            # copia horizontal (dot 257) ~ 3/4 de la linea
            self.target = (line * 341 + 257) // 3 + self.base
            while self.cyc < self.target: self.step()
            rendering = (self.mask & 0x18) != 0
            if line < 239 and rendering:
                self.line_h[line + 1] = ((self.t & 31) * 8 + self.fx) | (((self.t >> 10) & 1) << 8)
                self.line_chr[line + 1] = (self.regs[0], self.regs[1])
            if line == 261 and rendering:
                self.v = self.t
                self.line_h[0] = ((self.t & 31) * 8 + self.fx) | (((self.t >> 10) & 1) << 8)
                self.line_chr[0] = (self.regs[0], self.regs[1])
            if rendering and (line < 240 or line == 261):
                self.clock_mmc3()
            self.target = dots_end // 3 + self.base
            while self.cyc < self.target: self.step()
            if line == 240:
                self.status |= 0x80
                if self.ctrl & 0x80: self.nmi_pending = True
            if line == 260:
                self.status &= 0x7F
        self.base += 262 * 341 // 3
        self.frame += 1

    def render(self):
        img = Image.new('RGB', (256, 240))
        px = img.load()
        bgpt = 0x1000 if self.ctrl & 0x10 else 0
        sppt = 0x1000 if self.ctrl & 0x08 else 0
        bgidx = [[0] * 256 for _ in range(240)]
        for y in range(240):
            hs = self.line_h[y]
            ty = y >> 3; fy = y & 7
            for x in range(256):
                wx = (hs + x) & 511
                nt = (wx >> 8) * 0x400
                tx = (wx & 255) >> 3
                tile = self.vram[nt + ty * 32 + tx]
                at = self.vram[nt + 0x3C0 + (ty >> 2) * 8 + (tx >> 2)]
                sh = ((ty & 2) << 1) | (tx & 2)
                pal = (at >> sh) & 3
                pa = bgpt + tile * 16 + fy
                if bgpt:
                    bb = self.chr_addr(pa)
                else:
                    r0, r1 = self.line_chr[y]
                    bb = ((r0 & 0xFE) * 1024 + pa) if pa < 0x800 else ((r1 & 0xFE) * 1024 + pa - 0x800)
                    bb %= len(self.chr)
                lo = self.chr[bb]; hi = self.chr[bb + 8]
                b = 7 - (wx & 7)
                c = ((lo >> b) & 1) | (((hi >> b) & 1) << 1)
                bgidx[y][x] = c
                col = self.palram[pal * 4 + c] if c else self.palram[0]
                px[x, y] = PAL[col & 63]
        allow = [set() for _ in range(240)]
        for i in range(64):
            sy0 = self.oam[i * 4] + 1
            for r in range(8):
                yy = sy0 + r
                if yy < 240 and len(allow[yy]) < 8: allow[yy].add(i)
        for i in range(63, -1, -1):
            sy = self.oam[i * 4] + 1; tile = self.oam[i * 4 + 1]; at = self.oam[i * 4 + 2]; sx = self.oam[i * 4 + 3]
            if sy >= 240: continue
            for r in range(8):
                yy = sy + r
                if yy >= 240: break
                if self.sprite_limit and i not in allow[yy]: continue
                rr = 7 - r if at & 0x80 else r
                pa = sppt + tile * 16 + rr
                lo = self.chr[self.chr_addr(pa)]; hi = self.chr[self.chr_addr(pa + 8)]
                for cc in range(8):
                    xx = sx + cc
                    if xx >= 256: break
                    b = cc if at & 0x40 else 7 - cc
                    c = ((lo >> b) & 1) | (((hi >> b) & 1) << 1)
                    if c:
                        col = self.palram[0x10 + (at & 3) * 4 + c]
                        px[xx, yy] = PAL[col & 63]
        return img

# ------------------------------------------------------------------ opcodes
def _ld(reg):
    def f(s, m):
        v = s.rd(s.addr(m)); setattr(s, reg, v); s.setzn(v)
    return f
def _st(reg):
    def f(s, m): s.wr(s.addr(m), getattr(s, reg))
    return f
def _adc_v(s, v):
    r = s.a + v + (s.p & C)
    s.p = (s.p & ~(C | V)) | (C if r > 255 else 0) | (V if (~(s.a ^ v) & (s.a ^ r) & 0x80) else 0)
    s.a = r & 255; s.setzn(s.a)
def ADC(s, m): _adc_v(s, s.rd(s.addr(m)))
def SBC(s, m): _adc_v(s, s.rd(s.addr(m)) ^ 255)
def AND(s, m): s.a &= s.rd(s.addr(m)); s.setzn(s.a)
def ORA(s, m): s.a |= s.rd(s.addr(m)); s.setzn(s.a)
def EOR(s, m): s.a ^= s.rd(s.addr(m)); s.setzn(s.a)
def _cmp(reg):
    def f(s, m):
        v = s.rd(s.addr(m)); r = getattr(s, reg) - v
        s.p = (s.p & ~C) | (C if r >= 0 else 0); s.setzn(r & 255)
    return f
def BIT(s, m):
    v = s.rd(s.addr(m))
    s.p = (s.p & ~(Z | V | N)) | (Z if (v & s.a) == 0 else 0) | (v & 0xC0)
def _rmw(fn):
    def f(s, m):
        if m == 'acc':
            s.a = fn(s, s.a); s.setzn(s.a)
        else:
            a = s.addr(m); v = fn(s, s.rd(a)); s.wr(a, v); s.setzn(v)
    return f
def _asl(s, v): s.p = (s.p & ~C) | (v >> 7); return (v << 1) & 255
def _lsr(s, v): s.p = (s.p & ~C) | (v & 1); return v >> 1
def _rol(s, v):
    c = s.p & C; s.p = (s.p & ~C) | (v >> 7); return ((v << 1) | c) & 255
def _ror(s, v):
    c = s.p & C; s.p = (s.p & ~C) | (v & 1); return (v >> 1) | (c << 7)
def _inc(s, v): return (v + 1) & 255
def _dec(s, v): return (v - 1) & 255
def _br(flag, val):
    def f(s, m):
        off = s.rd(s.pc); s.pc += 1
        if ((s.p & flag) != 0) == val:
            if off > 127: off -= 256
            s.pc = (s.pc + off) & 0xFFFF; s.cyc += 1
    return f
def JMP(s, m): s.pc = s.addr(m)
def JSR(s, m):
    t = s.rd16(s.pc); r = s.pc + 1
    s.push(r >> 8); s.push(r & 255); s.pc = t
def RTS(s, m): lo = s.pop(); hi = s.pop(); s.pc = ((hi << 8) | lo) + 1
def RTI(s, m):
    s.p = (s.pop() | U) & ~B; lo = s.pop(); hi = s.pop(); s.pc = (hi << 8) | lo
def BRK(s, m): s.pc += 1; s.push(s.pc >> 8); s.push(s.pc & 255); s.push(s.p | B | U); s.p |= I; s.pc = s.rd16(0xFFFE)
def _flag(fl, val):
    def f(s, m): s.p = (s.p | fl) if val else (s.p & ~fl)
    return f
def _tr(src, dst, z=True):
    def f(s, m):
        v = getattr(s, src); setattr(s, dst, v)
        if z: s.setzn(v)
    return f
def INX(s, m): s.x = (s.x + 1) & 255; s.setzn(s.x)
def INY(s, m): s.y = (s.y + 1) & 255; s.setzn(s.y)
def DEX(s, m): s.x = (s.x - 1) & 255; s.setzn(s.x)
def DEY(s, m): s.y = (s.y - 1) & 255; s.setzn(s.y)
def PHA(s, m): s.push(s.a)
def PHP(s, m): s.push(s.p | B | U)
def PLA(s, m): s.a = s.pop(); s.setzn(s.a)
def PLP(s, m): s.p = (s.pop() | U) & ~B
def NOP(s, m): pass

from asm import OPS
FN = {'LDA': _ld('a'), 'LDX': _ld('x'), 'LDY': _ld('y'), 'STA': _st('a'), 'STX': _st('x'), 'STY': _st('y'),
      'ADC': ADC, 'SBC': SBC, 'AND': AND, 'ORA': ORA, 'EOR': EOR, 'CMP': _cmp('a'), 'CPX': _cmp('x'), 'CPY': _cmp('y'),
      'BIT': BIT, 'ASL': _rmw(_asl), 'LSR': _rmw(_lsr), 'ROL': _rmw(_rol), 'ROR': _rmw(_ror),
      'INC': _rmw(_inc), 'DEC': _rmw(_dec),
      'BCC': _br(C, False), 'BCS': _br(C, True), 'BEQ': _br(Z, True), 'BNE': _br(Z, False),
      'BMI': _br(N, True), 'BPL': _br(N, False), 'BVC': _br(V, False), 'BVS': _br(V, True),
      'JMP': JMP, 'JSR': JSR, 'RTS': RTS, 'RTI': RTI, 'BRK': BRK,
      'CLC': _flag(C, 0), 'SEC': _flag(C, 1), 'CLI': _flag(I, 0), 'SEI': _flag(I, 1), 'CLD': _flag(D, 0),
      'SED': _flag(D, 1), 'CLV': _flag(V, 0),
      'TAX': _tr('a', 'x'), 'TAY': _tr('a', 'y'), 'TXA': _tr('x', 'a'), 'TYA': _tr('y', 'a'),
      'TSX': _tr('sp', 'x'), 'TXS': _tr('x', 'sp', False),
      'INX': INX, 'INY': INY, 'DEX': DEX, 'DEY': DEY, 'PHA': PHA, 'PHP': PHP, 'PLA': PLA, 'PLP': PLP, 'NOP': NOP}
CYC = dict(imp=2, acc=2, imm=2, zp=3, zpx=4, zpy=4, abs=4, abx=4, aby=4, ind=5, izx=6, izy=5, rel=2)
OPT = [None] * 256
for mn, modes in OPS.items():
    for m, op in modes.items():
        c = CYC[m]
        if mn in ('JSR', 'RTS', 'RTI'): c = 6
        if mn in ('PHA', 'PHP'): c = 3
        if mn in ('PLA', 'PLP'): c = 4
        if mn == 'JMP' and m == 'abs': c = 3
        if mn in ('ASL', 'LSR', 'ROL', 'ROR', 'INC', 'DEC') and m not in ('acc',): c += 2
        if mn in ('STA',) and m in ('abx', 'aby', 'izy'): c += 1
        OPT[op] = (FN[mn], m, c)
