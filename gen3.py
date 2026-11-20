#!/usr/bin/env python3
"""Generador v3 (beat 'em up): CHR 64KB + tablas de metasprites + niveles/oleadas."""
import io, contextlib, random, math
with contextlib.redirect_stdout(io.StringIO()):
    import gen2
from gen import FONT, tile_bytes
from sprite3 import frame, make_enemy, quantize, CLS_RGB
from art4 import car, moto, BOSSES, BOSS_COL, BOSS_NAMES, to_grid, blank, paste
from art import Canvas
from bg4 import THEMES, street, farband
from emu import PAL as NP

CHR = bytearray(64 * 1024)
def put(unit, idx, rows):
    off = unit * 1024 + idx * 16
    CHR[off:off + 16] = tile_bytes(rows)
def pix_rows(pix):            # matriz 8x8 de indices -> filas string
    return [''.join(str(v) if v else '.' for v in r) for r in pix]

# ------------------------------------------------------------------ paginas de fuente
CHR[0:2048] = gen2.CHR[0:2048]                       # menus (unidades 0-1)
FONT2 = gen2.FONT2
def game_font_page(unit):
    for ch, g in FONT2.items():
        rows = ['1' + ''.join('2' if p == '#' else '1' for p in r) + '11' for r in g] + ['11111111']
        put(unit, ord(ch) - 32, rows)
    put(unit, 0, ['11111111'] * 8)                   # espacio = negro solido
    put(unit, 63, ['11111111'] * 8)                  # '_' = negro solido
    sp = {
     0x40: ["11111111", "13333331", "13232331", "13333331", "13333331", "13333331", "11111111", "11111111"],  # vida llena
     0x41: ["11111111", "13331221", "13231111", "13331111", "13331111", "13331221", "11111111", "11111111"],  # media
     0x42: ["11111111", "12111121", "11111111", "11111111", "11111111", "12111121", "11111111", "11111111"],  # vacia
     0x43: ["11121111", "11121111", "11222111", "22222221", "12222211", "12211221", "22111221", "11111111"],  # estrella
     0x44: ["11111111"] * 8,
     0x45: ["11111111", "13333311", "13232311", "13333311", "13232311", "13333311", "11111111", "11111111"],  # ficha vehiculo
    }
    for k, v in sp.items(): put(unit, k - 0, v) if k < 64 else put(unit + 1, k - 64, v)

# ------------------------------------------------------------------ temas de fondo
THEME_ORDER = 'ABCD'
FAR_BASE = 0x48
theme_data = {}
for ti, th in enumerate(THEME_ORDER):
    fpage = 2 + ti * 2
    game_font_page(fpage)
    # banda lejana 16x4 tiles
    img = farband(th, 7 + ti)
    ftiles = []; fmap = []
    for ty in range(4):
        row = []
        for tx in range(16):
            t = tuple(''.join('.' if img[ty * 8 + y][tx * 8 + x] == 0 else str(img[ty * 8 + y][tx * 8 + x]) for x in range(8)) for y in range(8))
            if t not in ftiles: ftiles.append(t)
            row.append(FAR_BASE + ftiles.index(t))
        fmap.append(row)
    assert FAR_BASE + len(ftiles) <= 128, (th, len(ftiles))
    for i, t in enumerate(ftiles):
        n = FAR_BASE + i
        put(fpage + n // 64, n % 64, list(t))
    # fachadas + calle (R1, $80+)
    tunit = 10 + ti * 2
    tl = [tuple(['........'] * 8)]                  # $80 = vacio
    def tid(t):
        if t not in tl: tl.append(t)
        return 0x80 + tl.index(t)
    blocks = []
    for c, pals in THEMES[th]():
        cols = []
        for half in range(2):
            col = []
            for r in range(10):
                t = tuple(''.join('.' if c.p[r * 8 + y][half * 8 + x] == 0 else str(c.p[r * 8 + y][half * 8 + x]) for x in range(8)) for y in range(8))
                col.append(tid(t))
            cols.append(col)
        blocks.append((cols, pals))
    st = street(th)
    smap = []
    for r in range(12):
        row = []
        for cx in range(4):
            t = tuple(''.join('.' if st.p[r * 8 + y][cx * 8 + x] == 0 else str(st.p[r * 8 + y][cx * 8 + x]) for x in range(8)) for y in range(8))
            row.append(tid(t))
        smap.append(row)
    assert len(tl) <= 128, (th, len(tl))
    for i, t in enumerate(tl):
        put(tunit + i // 64, i % 64, list(t))
    theme_data[th] = dict(fmap=fmap, blocks=blocks, smap=smap, fpage=fpage, tunit=tunit)

# escena del banco (unidades 18-19) desde v2
for i in range(128):
    off = 6 * 1024 + i * 16
    CHR[18 * 1024 + i * 16: 18 * 1024 + i * 16 + 16] = gen2.CHR[off:off + 16]

# ------------------------------------------------------------------ sprites
CHARS = [dict(name='jose', row=0, shirt=0x2C, crgb=(20, 180, 225)),
         dict(name='luci', row=1, shirt=0x25, crgb=(235, 55, 125))]
P3 = [0x0F, 0x27, 0x30]
unit = 20
FRAMES = {}          # nombre -> lista de (bank_unit, entries[(dy,dx,tile,attr)])
UNITS = {}

def pack(name, framelists, bank_tiles, tile_base, first_unit, fixed_units=None):
    """framelists: lista de entradas (dx,dy,pix,attr). Empaqueta en bancos de bank_tiles."""
    banks = []           # cada banco: lista de tiles (filas)
    out = []
    cur = None
    for ents in framelists:
        needed = []
        for dx, dy, pix, ap in ents:
            t = tuple(pix_rows(pix))
            if t not in needed: needed.append(t)
        if cur is None or len(set(banks[cur]) | set(needed)) > bank_tiles:
            banks.append([]); cur = len(banks) - 1
        b = banks[cur]
        res = []
        for dx, dy, pix, ap in ents:
            t = tuple(pix_rows(pix))
            if t not in b: b.append(t)
            res.append((dy, dx, tile_base + b.index(t), ap))
        out.append((cur, res))
    per = bank_tiles // 64
    for bi, b in enumerate(banks):
        for i, t in enumerate(b):
            put(first_unit + bi * per + i // 64, i % 64, list(t))
    FRAMES[name] = [(first_unit + bi * per, r) for bi, r in out]
    return first_unit + len(banks) * per

for ch in CHARS:
    cls = dict(CLS_RGB); cls['c'] = ch['crgb']
    pals = [(0, [0x0F, 0x27, 0x17]), (1, [0x0F, 0x30, ch['shirt']]), (3, P3)]
    fl = [quantize(frame(ch['row'], c), pals, cls) for c in range(16)]
    unit = pack(ch['name'], fl, 64, 0x00, unit)
    drv = frame(ch['row'], 0); rid = frame(ch['row'], 7)
    vl = [quantize(moto(rid, 0), pals, cls), quantize(moto(rid, 1.2), pals, cls)]
    unit = pack(ch['name'] + '_moto', vl, 64, 0x00, unit)
    vl = [quantize(car(drv, 0), pals, cls), quantize(car(drv, 1.2), pals, cls)]
    unit = pack(ch['name'] + '_car', vl, 64, 0x00, unit)
EFR = [0, 2, 3, 7, 9, 14, 15]          # quieto, caminar1, caminar2, golpe, apuntar, herido, caido
for kind, ucol in (('cop', 0x12), ('soldier', 0x1A)):
    cls = dict(CLS_RGB); cls['u'] = NP[ucol]
    fl = [quantize(make_enemy(frame(0, c), kind), [(2, [0x0F, 0x27, ucol])], cls) for c in EFR]
    unit = pack(kind, fl, 128, 0x80, unit)
    assert len(set(b for b, _ in FRAMES[kind])) == 1, kind
# varios (R3, $40)
misc = []
cls = dict(CLS_RGB); cls['c'] = (20, 180, 225)
def mq(g, pals): return quantize(g, pals, cls)
misc_frames = {}
misc_frames['car'] = mq(car(None, 0), [(1, [0x0F, 0x30, 0x2C]), (3, P3)])
misc_frames['moto'] = mq(moto(None, 0), [(1, [0x0F, 0x30, 0x2C]), (3, P3)])
def expl16(k):
    R = random.Random(30 + k); c = Canvas(16, 16); rad = [4, 7, 7.5][k]
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5) + R.uniform(-1.4, 1.4)
            v = (3 if d < rad * .45 else 2 if d < rad * .8 else 1 if d < rad else 0) if k < 2 else (1 if d < rad and R.random() < .5 else 0)
            if v: c.set(x, y, v)
    return to_grid(c, {1: 'k', 2: 's', 3: 'w'})
for k in range(3): misc_frames['ex%d' % k] = mq(expl16(k), [(3, P3)])
def small(rows): return [list(r) for r in rows]
misc_frames['pb'] = mq(small(["..www.", ".wwsww", "..www."]), [(3, P3)])
misc_frames['eb'] = mq(small([".sss.", "sswss", ".sss."]), [(3, P3)])
misc_frames['flash'] = mq(small(["..w....", "...w.w.", "wwwwssw", "...w.w.", "..w...."]), [(3, P3)])
misc_frames['shadow'] = mq(small([".kkkkkkkkkk.", "kkkkkkkkkkkk", ".kkkkkkkkkk."]), [(3, P3)])
misc_frames['shell'] = mq(small([".kkk.", "kwwsk", "kwssk", ".kkk."]), [(3, P3)])
misc_frames['bomb'] = mq(small(["..k..", ".kkk.", "kkwkk", "kkkkk", ".kkk."]), [(3, P3)])
gg = [list(r) for r in ["kkkkkk.kkkkkk..kk...", "kwwwwk.kwwwwk..kwk..", "kwkkkk.kwkkwk..kwwk.", "kwkwwk.kwkkwk..kwwwk",
                        "kwkkwk.kwkkwk..kwwk.", "kwwwwk.kwwwwk..kwk..", "kkkkkk.kkkkkk..kk..."]]
misc_frames['go'] = mq(gg, [(3, P3)])
misc_frames['ab'] = mq([list(r) for r in ["kkkkk.kkkkk", "kwwwk.kwwkk", "kwkwk.kwkwk", "kwwwk.kwwkk", "kwkwk.kwkwk", "kwkwk.kwwkk", "kkkkk.kkkkk"]], [(3, P3)])
bag = Canvas(12, 12); bag.ellipse(6, 7, 5, 4.3, 2); bag.rect(4, 1, 8, 3, 2); bag.line(3, 3, 9, 3, 1)
for (x, y) in ((6, 5), (5, 6), (6, 7), (7, 8), (6, 9), (5, 10), (6, 4), (6, 11)): bag.set(x, y, 1)
bag.outline(1)
misc_frames['bag'] = mq(to_grid(bag, {1: 'k', 2: 'w'}), [(3, P3)])
names = list(misc_frames.keys())
unit = pack('misc', [misc_frames[n] for n in names], 64, 0x40, unit)
assert len(set(b for b, _ in FRAMES['misc'])) == 1
MISC_IDX = {n: i for i, n in enumerate(names)}
# jefes
for i, f in enumerate(BOSSES):
    u, v = BOSS_COL[i]
    cls = dict(CLS_RGB); cls['u'] = NP[u]; cls['v'] = NP[v]; cls['o'] = NP[0x27]
    pals = [(2, [0x0F, u, v]), (3, P3)]
    fl = [quantize(f(0), pals, cls), quantize(f(1), pals, cls)]
    unit = pack('boss%d' % i, fl, 128, 0x80, unit)
print('unidades CHR usadas:', unit)
assert unit <= 64
open('chr3.bin', 'wb').write(CHR)

# ------------------------------------------------------------------ tablas de metasprites (banco 0)
A = ['; ---- banco 0: metasprites y niveles ----']
def emit_set(name):
    fr = FRAMES[name]
    A.append('%s_lo: .byte %s' % (name, ','.join('<%s_f%d' % (name, i) for i in range(len(fr)))))
    A.append('%s_hi: .byte %s' % (name, ','.join('>%s_f%d' % (name, i) for i in range(len(fr)))))
    A.append('%s_bk: .byte %s' % (name, ','.join(str(b) for b, _ in fr)))
    for i, (b, ents) in enumerate(fr):
        flat = [len(ents)]
        for dy, dx, t, ap in ents: flat += [dy & 255, dx & 255, t, ap]
        A.append('%s_f%d: .byte %s' % (name, i, ','.join('$%02X' % v for v in flat)))
for n in FRAMES: emit_set(n)
# ------------------------------------------------------------------ niveles
NAMES = ["PLAYA VICE", "CALLE OCHO", "PUERTO DEL SOL", "LOS CAYOS", "AUTOPISTA 95",
         "LOS PANTANOS", "DISTRITO ART DECO", "AEROPUERTO", "CENTRO NOCTURNO", "LA MANSION"]
#        tema, bg,   P1 (lejano/acentos)   P2 (fachada)          P3 (calle)
LV = [('A', 0x21, (0x07, 0x2A, 0x30), (0x0F, 0x35, 0x30), (0x0F, 0x37, 0x27)),
      ('B', 0x22, (0x0F, 0x24, 0x2C), (0x0F, 0x17, 0x27), (0x0F, 0x00, 0x10)),
      ('C', 0x26, (0x0F, 0x28, 0x30), (0x0F, 0x16, 0x21), (0x0F, 0x00, 0x10)),
      ('A', 0x31, (0x07, 0x2A, 0x30), (0x0F, 0x3A, 0x30), (0x0F, 0x37, 0x27)),
      ('B', 0x14, (0x0F, 0x28, 0x24), (0x0F, 0x04, 0x13), (0x0F, 0x00, 0x2D)),
      ('C', 0x1B, (0x0F, 0x2A, 0x3A), (0x0F, 0x19, 0x29), (0x0F, 0x09, 0x19)),
      ('A', 0x34, (0x04, 0x2A, 0x30), (0x0F, 0x2C, 0x30), (0x0F, 0x37, 0x27)),
      ('D', 0x11, (0x0F, 0x16, 0x30), (0x0F, 0x18, 0x28), (0x0F, 0x00, 0x2D)),
      ('B', 0x0F, (0x01, 0x24, 0x2C), (0x0F, 0x02, 0x12), (0x0F, 0x00, 0x10)),
      ('D', 0x01, (0x0F, 0x16, 0x28), (0x0F, 0x0A, 0x1A), (0x0F, 0x00, 0x2D))]
LEVEL_MC = 112
for i in range(10):
    th, bg, p1, p2, p3 = LV[i]
    td = theme_data[th]
    R = random.Random(500 + i)
    nb = len(td['blocks'])
    seq = []
    while len(seq) < LEVEL_MC:
        b = R.randrange(nb)
        run = R.choice([1, 2, 2, 3])
        seq += [b] * run
    seq = seq[:LEVEL_MC]
    faction = 1 if i >= 5 else 0
    ucol = 0x1A if faction else 0x12
    bu, bv = BOSS_COL[i]
    pal = [bg, 0x0F, 0x30, 0x16, bg, *p1, bg, *p2, bg, *p3,
           bg, 0x0F, 0x27, 0x17, bg, 0x0F, 0x30, 0x2C, bg, 0x0F, 0x27, ucol, bg, 0x0F, 0x27, 0x30]
    bpal = [bg, 0x0F, bu, bv]
    waves = []
    for k, mc in enumerate((10, 26, 42, 58, 74)):
        waves += [mc, 3 + (i + k) // 3]
    vehs = []
    for k, mc in enumerate((18, 50, 82)):
        vehs += [mc, 1 + (k + i) % 2, R.choice([176, 196, 216])]
    A.append('lvl%d_seq:\n' % i + '\n'.join('    .byte ' + ','.join(str(v) for v in seq[j:j + 16]) for j in range(0, LEVEL_MC, 16)))
    A.append('lvl%d_pal: .byte %s' % (i, ','.join('$%02X' % v for v in pal)))
    A.append('lvl%d_bpal: .byte %s' % (i, ','.join('$%02X' % v for v in bpal)))
    A.append('lvl%d_waves: .byte %s, $FF' % (i, ','.join(str(v) for v in waves)))
    A.append('lvl%d_veh: .byte %s, $FF' % (i, ','.join(str(v) for v in vehs)))
for th in THEME_ORDER:
    td = theme_data[th]
    # bloques: por bloque 20 bytes tiles (col0 r0..9, col1 r0..9) + 5 paletas
    A.append('blk_%s:' % th)
    for cols, pals in td['blocks']:
        A.append('    .byte ' + ','.join('$%02X' % v for v in cols[0] + cols[1]) + ',' + ','.join(str(p) for p in pals) + ',0,0,0')
    A.append('street_%s:' % th)
    for row in td['smap']: A.append('    .byte ' + ','.join('$%02X' % v for v in row))
    A.append('far_%s:' % th)
    for row in td['fmap']: A.append('    .byte ' + ','.join('$%02X' % v for v in row))
A.append('bank_nt:'); A.append('\n'.join('    .byte ' + ','.join('$%02X' % v for v in sum(gen2.bank_nt, [])[j:j + 16]) for j in range(0, 960, 16)))
A.append('bank_at:'); A.append('    .byte ' + ','.join('$%02X' % v for v in gen2.bank_attr))
k = [i for i, l in enumerate(A) if l.startswith('lvl0_seq')][0]
open('bank0.asm', 'w').write('\n'.join(A[:k]) + '\n')
open('bank1.asm', 'w').write('\n'.join(A[k:]) + '\n')

# ------------------------------------------------------------------ tabla fija
D = []
for n in names: D.append('MF_%s = %d' % (n.upper(), MISC_IDX[n]))
D.append('LEVEL_MC = %d' % LEVEL_MC)
D.append('level_tbl:')
for i in range(10):
    th = LV[i][0]; td = theme_data[th]
    D.append('    .word lvl%d_seq, lvl%d_pal, lvl%d_waves, lvl%d_veh, blk_%s, street_%s, far_%s, lvl%d_bpal' % (i, i, i, i, th, th, th, i))
    D.append('    .byte %d, %d, %d, %d, %d, %d, 0, 0' % (td['fpage'], td['tunit'], 1 if i >= 5 else 0, min(5, 1 + i // 2), i, 0))
# unidades de sprites
D.append('chr_sets:')
for n in ('cop', 'soldier', 'misc'): D.append('UNIT_%s = %d' % (n.upper(), FRAMES[n][0][0]))
D.append('boss_units: .byte ' + ','.join(str(FRAMES['boss%d' % i][0][0]) for i in range(10)))
D.append('name_tbl:'); D.append('    .word ' + ','.join('name%d' % i for i in range(10)))
for i, nm in enumerate(NAMES):
    D.append('name%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 14 * 32 + (32 - len(nm)) // 2, nm))
D.append('bname_tbl:'); D.append('    .word ' + ','.join('bname%d' % i for i in range(10)))
for i, nm in enumerate(BOSS_NAMES):
    D.append('bname%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 18 * 32 + (32 - len(nm)) // 2, nm))
# logo/sol/notas desde gen2 (data2.asm)
src = open('data2.asm').read()
keep = src[src.index('logo_strs:'):]
D.append(keep)
open('data3.asm', 'w').write('\n'.join(D) + '\n')
print('bank0 bytes aprox', sum(len(l) for l in A) // 4)
