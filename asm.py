#!/usr/bin/env python3
"""Mini ensamblador 6502 (sintaxis estilo ca65 simplificada) para el proyecto GTA6 NES."""
import re, sys, os

OPS = {
'ADC': dict(imm=0x69,zp=0x65,zpx=0x75,abs=0x6D,abx=0x7D,aby=0x79,izx=0x61,izy=0x71),
'AND': dict(imm=0x29,zp=0x25,zpx=0x35,abs=0x2D,abx=0x3D,aby=0x39,izx=0x21,izy=0x31),
'ASL': dict(acc=0x0A,zp=0x06,zpx=0x16,abs=0x0E,abx=0x1E),
'BCC': dict(rel=0x90),'BCS':dict(rel=0xB0),'BEQ':dict(rel=0xF0),'BMI':dict(rel=0x30),
'BNE': dict(rel=0xD0),'BPL':dict(rel=0x10),'BVC':dict(rel=0x50),'BVS':dict(rel=0x70),
'BIT': dict(zp=0x24,abs=0x2C),
'BRK': dict(imp=0x00),
'CLC':dict(imp=0x18),'CLD':dict(imp=0xD8),'CLI':dict(imp=0x58),'CLV':dict(imp=0xB8),
'CMP': dict(imm=0xC9,zp=0xC5,zpx=0xD5,abs=0xCD,abx=0xDD,aby=0xD9,izx=0xC1,izy=0xD1),
'CPX': dict(imm=0xE0,zp=0xE4,abs=0xEC),
'CPY': dict(imm=0xC0,zp=0xC4,abs=0xCC),
'DEC': dict(zp=0xC6,zpx=0xD6,abs=0xCE,abx=0xDE),
'DEX':dict(imp=0xCA),'DEY':dict(imp=0x88),
'EOR': dict(imm=0x49,zp=0x45,zpx=0x55,abs=0x4D,abx=0x5D,aby=0x59,izx=0x41,izy=0x51),
'INC': dict(zp=0xE6,zpx=0xF6,abs=0xEE,abx=0xFE),
'INX':dict(imp=0xE8),'INY':dict(imp=0xC8),
'JMP': dict(abs=0x4C,ind=0x6C),
'JSR': dict(abs=0x20),
'LDA': dict(imm=0xA9,zp=0xA5,zpx=0xB5,abs=0xAD,abx=0xBD,aby=0xB9,izx=0xA1,izy=0xB1),
'LDX': dict(imm=0xA2,zp=0xA6,zpy=0xB6,abs=0xAE,aby=0xBE),
'LDY': dict(imm=0xA0,zp=0xA4,zpx=0xB4,abs=0xAC,abx=0xBC),
'LSR': dict(acc=0x4A,zp=0x46,zpx=0x56,abs=0x4E,abx=0x5E),
'NOP':dict(imp=0xEA),
'ORA': dict(imm=0x09,zp=0x05,zpx=0x15,abs=0x0D,abx=0x1D,aby=0x19,izx=0x01,izy=0x11),
'PHA':dict(imp=0x48),'PHP':dict(imp=0x08),'PLA':dict(imp=0x68),'PLP':dict(imp=0x28),
'ROL': dict(acc=0x2A,zp=0x26,zpx=0x36,abs=0x2E,abx=0x3E),
'ROR': dict(acc=0x6A,zp=0x66,zpx=0x76,abs=0x6E,abx=0x7E),
'RTI':dict(imp=0x40),'RTS':dict(imp=0x60),
'SBC': dict(imm=0xE9,zp=0xE5,zpx=0xF5,abs=0xED,abx=0xFD,aby=0xF9,izx=0xE1,izy=0xF1),
'SEC':dict(imp=0x38),'SED':dict(imp=0xF8),'SEI':dict(imp=0x78),
'STA': dict(zp=0x85,zpx=0x95,abs=0x8D,abx=0x9D,aby=0x99,izx=0x81,izy=0x91),
'STX': dict(zp=0x86,zpy=0x96,abs=0x8E),
'STY': dict(zp=0x84,zpx=0x94,abs=0x8C),
'TAX':dict(imp=0xAA),'TAY':dict(imp=0xA8),'TSX':dict(imp=0xBA),'TXA':dict(imp=0x8A),
'TXS':dict(imp=0x9A),'TYA':dict(imp=0x98),
}
SIZE = dict(imp=1,acc=1,imm=2,zp=2,zpx=2,zpy=2,abs=3,abx=3,aby=3,ind=3,izx=2,izy=2,rel=2)

class Undef(Exception): pass
class AsmError(Exception): pass

def text_bytes(s):
    out = []
    for ch in s:
        c = ord(ch)
        if c < 32 or c > 95:
            raise AsmError("caracter no soportado en texto: %r" % ch)
        out.append(c - 32)
    return out

def split_args(s):
    # separa por comas respetando comillas
    parts, cur, q = [], '', False
    for ch in s:
        if ch == '"':
            q = not q; cur += ch
        elif ch == ',' and not q:
            parts.append(cur.strip()); cur = ''
        else:
            cur += ch
    if cur.strip():
        parts.append(cur.strip())
    return parts

class Assembler:
    def __init__(self, size=0x8000):
        self.syms = {}
        self.out = bytearray([0xFF] * size)
        self.used = bytearray(size)

    def load(self, path):
        lines = []
        base = os.path.dirname(path)
        for i, raw in enumerate(open(path, encoding='utf-8')):
            line = raw
            # quitar comentario (no dentro de comillas)
            q = False; cut = None
            for j, ch in enumerate(line):
                if ch == '"': q = not q
                if ch == ';' and not q:
                    cut = j; break
            if cut is not None: line = line[:cut]
            line = line.rstrip()
            m = re.match(r'\s*\.include\s+"([^"]+)"', line)
            if m:
                lines += self.load(os.path.join(base, m.group(1)))
                continue
            lines.append((path, i + 1, line))
        return lines

    def ev(self, expr, scope, strict):
        e = expr.strip()
        if e.startswith('<'):
            return self.ev(e[1:], scope, strict) & 0xFF
        if e.startswith('>'):
            return (self.ev(e[1:], scope, strict) >> 8) & 0xFF
        def rep(m):
            t = m.group(0)
            if t.startswith('$'): return str(int(t[1:], 16))
            if t.startswith('%'): return str(int(t[1:], 2))
            if t[0].isdigit(): return t
            name = scope + t if t.startswith('@') else t
            if name in self.syms: return str(self.syms[name])
            if strict: raise AsmError("simbolo indefinido: " + name)
            raise Undef(name)
        e2 = re.sub(r'\$[0-9A-Fa-f]+|%[01]+|@?[A-Za-z_][A-Za-z0-9_]*|\d+', rep, e)
        e2 = e2.replace('/', '//')
        return int(eval(e2, {"__builtins__": {}}))

    def parse_operand(self, op):
        op = op.strip()
        if op == '': return 'imp', None
        if op.upper() == 'A': return 'acc', None
        if op.startswith('#'): return 'imm', op[1:]
        m = re.match(r'^\((.*),\s*[xX]\s*\)$', op)
        if m: return 'izx', m.group(1)
        m = re.match(r'^\((.*)\)\s*,\s*[yY]$', op)
        if m: return 'izy', m.group(1)
        m = re.match(r'^\((.*)\)$', op)
        if m: return 'ind', m.group(1)
        m = re.match(r'^(.*),\s*[xX]$', op)
        if m: return 'x', m.group(1)
        m = re.match(r'^(.*),\s*[yY]$', op)
        if m: return 'y', m.group(1)
        return 'a', op

    def assemble(self, path):
        lines = self.load(path)
        self.decisions = {}
        for pas in (1, 2):
            self.run(lines, pas)
        return self.out

    def emit(self, b):
        if self.pas == 2:
            if self.fo < 0 or self.fo >= len(self.out):
                raise AsmError("fuera del archivo: %x" % self.fo)
            if self.used[self.fo]:
                raise AsmError("solapamiento en offset %x" % self.fo)
            self.out[self.fo] = b & 0xFF
            self.used[self.fo] = 1
        self.fo += 1
        self.pc += 1

    def run(self, lines, pas):
        self.pas = pas
        self.pc = 0; self.fo = 0
        scope = ''
        strict = (pas == 2)
        for idx, (fn, ln, line) in enumerate(lines):
            try:
                s = line.strip()
                if not s: continue
                # constante
                m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$', s)
                if m:
                    try:
                        self.syms[m.group(1)] = self.ev(m.group(2), scope, strict)
                    except Undef:
                        pass
                    continue
                # etiqueta
                m = re.match(r'^(@?[A-Za-z_][A-Za-z0-9_]*):\s*(.*)$', s)
                if m:
                    name = m.group(1)
                    if name.startswith('@'):
                        full = scope + name
                    else:
                        scope = name; full = name
                    if pas == 1 and full in self.syms and self.syms[full] != self.pc:
                        raise AsmError("etiqueta duplicada: " + full)
                    if pas == 2 and self.syms.get(full) != self.pc:
                        raise AsmError("etiqueta cambio de valor: " + full)
                    self.syms[full] = self.pc
                    s = m.group(2).strip()
                    if not s: continue
                if s.startswith('.'):
                    self.directive(s, scope, strict)
                    continue
                parts = s.split(None, 1)
                mn = parts[0].upper()
                operand = parts[1] if len(parts) > 1 else ''
                if mn not in OPS: raise AsmError("instruccion desconocida: " + mn)
                modes = OPS[mn]
                kind, ex = self.parse_operand(operand)
                if kind == 'imp' and 'imp' not in modes and 'acc' in modes:
                    kind = 'acc'
                if kind in ('imp', 'acc'):
                    if kind not in modes: raise AsmError("modo invalido")
                    self.emit(modes[kind]); continue
                if 'rel' in modes:
                    try:
                        tgt = self.ev(ex, scope, strict)
                    except Undef:
                        tgt = self.pc
                    off = tgt - (self.pc + 2)
                    if pas == 2 and not (-128 <= off <= 127):
                        raise AsmError("salto fuera de rango (%d)" % off)
                    self.emit(modes['rel']); self.emit(off & 0xFF); continue
                if kind in ('imm', 'izx', 'izy', 'ind'):
                    if kind not in modes: raise AsmError("modo %s invalido para %s" % (kind, mn))
                    try: v = self.ev(ex, scope, strict)
                    except Undef: v = 0
                    self.emit(modes[kind])
                    if kind == 'ind':
                        self.emit(v & 0xFF); self.emit(v >> 8)
                    else:
                        if pas == 2 and not (0 <= v <= 255): raise AsmError("valor fuera de byte: %d" % v)
                        self.emit(v)
                    continue
                # a / x / y
                zpm = {'a': 'zp', 'x': 'zpx', 'y': 'zpy'}[kind]
                abm = {'a': 'abs', 'x': 'abx', 'y': 'aby'}[kind]
                key = idx
                if pas == 1:
                    try:
                        v = self.ev(ex, scope, False); known = True
                    except Undef:
                        v = 0x1234; known = False
                    use_zp = known and 0 <= v < 256 and zpm in modes
                    if not use_zp and abm not in modes:
                        if zpm in modes: use_zp = True
                        else: raise AsmError("modo invalido para " + mn)
                    self.decisions[key] = use_zp
                use_zp = self.decisions[key]
                try: v = self.ev(ex, scope, strict)
                except Undef: v = 0
                if use_zp:
                    if pas == 2 and not (0 <= v < 256): raise AsmError("zp fuera de rango")
                    self.emit(modes[zpm]); self.emit(v)
                else:
                    self.emit(modes[abm]); self.emit(v & 0xFF); self.emit((v >> 8) & 0xFF)
            except (AsmError, SyntaxError, ValueError) as e:
                raise AsmError("%s:%d: %s\n  %s" % (fn, ln, e, line))

    def directive(self, s, scope, strict):
        parts = s.split(None, 1)
        d = parts[0].lower()
        arg = parts[1] if len(parts) > 1 else ''
        def val(x):
            try: return self.ev(x, scope, strict)
            except Undef: return 0
        if d == '.base':
            a = split_args(arg)
            self.fo = val(a[0]); self.pc = val(a[1])
        elif d == '.pad':
            tgt = val(arg)
            while self.pc < tgt: self.emit(0xFF)
        elif d == '.byte':
            for a in split_args(arg):
                if a.startswith('"'):
                    for b in text_bytes(a[1:-1]): self.emit(b)
                else:
                    v = val(a)
                    if strict and not (-128 <= v <= 255): raise AsmError("byte fuera de rango %d" % v)
                    self.emit(v)
        elif d == '.word':
            for a in split_args(arg):
                v = val(a); self.emit(v & 0xFF); self.emit((v >> 8) & 0xFF)
        elif d == '.res':
            a = split_args(arg)
            n = val(a[0]); f = val(a[1]) if len(a) > 1 else 0
            for _ in range(n): self.emit(f)
        elif d == '.text':
            a = split_args(arg)
            for b in text_bytes(a[0][1:-1]): self.emit(b)
        elif d == '.ltext':  # .ltext "TEXTO" -> len, bytes
            a = split_args(arg)
            bs = text_bytes(a[0][1:-1])
            self.emit(len(bs))
            for b in bs: self.emit(b)
        elif d == '.str':   # .str ppuaddr, "TEXTO"  ->  hi, lo, len, bytes
            a = split_args(arg)
            addr = val(a[0]); bs = text_bytes(a[1][1:-1])
            self.emit(addr >> 8); self.emit(addr & 0xFF); self.emit(len(bs))
            for b in bs: self.emit(b)
        elif d == '.strb':  # .strb ppuaddr, b1, b2...
            a = split_args(arg)
            addr = val(a[0]); bs = [val(x) for x in a[1:]]
            self.emit(addr >> 8); self.emit(addr & 0xFF); self.emit(len(bs))
            for b in bs: self.emit(b)
        else:
            raise AsmError("directiva desconocida " + d)

if __name__ == '__main__':
    a = Assembler()
    prg = a.assemble(sys.argv[1])
    open(sys.argv[2], 'wb').write(prg)
