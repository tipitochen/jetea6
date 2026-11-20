from PIL import Image
import numpy as np
#!/usr/bin/env python3
"""Generador v4 (JETEA 6): CHR 128KB, 2 jugadores, armas en el fondo, patrulleros, barra de jefe, musica GTA."""
import io, contextlib, random, math
with contextlib.redirect_stdout(io.StringIO()):
    import gen2
from gen import FONT, tile_bytes
from sprite3 import frame, quantize, CLS_RGB
from enemy4 import make_enemy2, EFR4
from walk5 import head_anchor, mirror_legs
from walk6 import walk_poses
from walk7 import stomp_poses
from deshine import deshine
from sprite3 import quantize_layered
from art4 import car, moto, BOSSES, BOSS_COL, BOSS_NAMES, to_grid, blank, paste
from art import Canvas
from bg4 import THEMES, street, farband
from emu import PAL as NP

NUNITS = 128
CHR = bytearray(NUNITS * 1024)
def put(unit, idx, rows):
    off = unit * 1024 + idx * 16
    CHR[off:off + 16] = tile_bytes(rows)
def pix_rows(pix): return tuple(''.join(str(v) if v else '.' for v in r) for r in pix)

# ------------------------------------------------------------------ fuentes
FONT2 = dict(gen2.FONT2)
FONT2['>'] = ["#    ", "##   ", "###  ", "#### ", "###  ", "##   ", "#    "]
CHR[0:2048] = gen2.CHR[0:2048]
def game_font_page(unit):
    for ch, g in FONT2.items():
        put(unit, ord(ch) - 32, ['1' + ''.join('2' if p == '#' else '1' for p in r) + '11' for r in g] + ['11111111'])
    put(unit, 0, ['11111111'] * 8)
    put(unit, 63, ['11111111'] * 8)
    sp = {
     0x40: ["11111111", "13333331", "13232331", "13333331", "13333331", "13333331", "11111111", "11111111"],
     0x41: ["11111111", "13331221", "13231111", "13331111", "13331111", "13331221", "11111111", "11111111"],
     0x42: ["11111111", "12111121", "11111111", "11111111", "11111111", "12111121", "11111111", "11111111"],
     0x43: ["11121111", "11121111", "11222111", "22222221", "12222211", "12211221", "22111221", "11111111"],
     0x44: ["11111111"] * 8,
     0x45: ["11111111", "13333311", "13232311", "13333311", "13232311", "13333311", "11111111", "11111111"],
    }
    for k, v in sp.items(): put(unit + 1, k - 64, v)

# ------------------------------------------------------------------ armas (tiles de fondo, 16x8 sobre placa negra)
WEAP = {
 'PIST': ["1111111111111111", "1111111111111111", "1133333333311111", "1133333333311111", "1111131111111111", "1111133111111111", "1111111111111111", "1111111111111111"],
 'ESCO': ["1111111111111111", "1111111111111111", "1222222333333331", "1222222333333331", "1221111111111111", "1111111111111111", "1111111111111111", "1111111111111111"],
 'METR': ["1111111111111111", "1111111111111111", "1112233333333311", "1112233333333311", "1111131113111111", "1111131113111111", "1111111113111111", "1111111111111111"],
 'CORA': ["1111111111111111", "1111331111331111", "1113233113333111", "1113333333333111", "1111333333331111", "1111133333311111", "1111111331111111", "1111111111111111"],
 'LANZ': ["1111111111111111", "1333333333332311", "1322222222223331", "1333333333332311", "1111133111111111", "1111131111111111", "1111111111111111", "1111111111111111"],
 'BAZU': ["1111111111111111", "1112222222222111", "1322333333332231", "1322333333332231", "1112222222222111", "1111113111111111", "1111111111111111", "1111111111111111"],
}
WEAP_ORDER = ['PIST', 'ESCO', 'METR', 'BAZU', 'CORA', 'LANZ']

# ------------------------------------------------------------------ temas
THEME_ORDER = 'ABCD'
FAR_BASE = 0x48
theme_data = {}
for ti, th in enumerate(THEME_ORDER):
    fpage = 2 + ti * 2
    game_font_page(fpage)
    img = farband(th, 7 + ti)
    ftiles = []; fmap = []
    for ty in range(4):
        row = []
        for tx in range(16):
            t = tuple(''.join('.' if img[ty * 8 + y][tx * 8 + x] == 0 else str(img[ty * 8 + y][tx * 8 + x]) for x in range(8)) for y in range(8))
            if t not in ftiles: ftiles.append(t)
            row.append(FAR_BASE + ftiles.index(t))
        fmap.append(row)
    assert FAR_BASE + len(ftiles) <= 128
    for i, t in enumerate(ftiles):
        n = FAR_BASE + i
        put(fpage + n // 64, n % 64, list(t))
    tunit = 10 + ti * 2
    tl = [tuple(['........'] * 8)]
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
    wt = []
    for w in WEAP_ORDER:
        rows = WEAP[w]
        for h in range(2):
            t = tuple(r[h * 8:h * 8 + 8] for r in rows)
            wt.append(tid(t))
    assert len(tl) <= 128, (th, len(tl))
    for i, t in enumerate(tl): put(tunit + i // 64, i % 64, list(t))
    theme_data[th] = dict(fmap=fmap, blocks=blocks, smap=smap, fpage=fpage, tunit=tunit, wt=wt)
for i in range(128):
    CHR[18 * 1024 + i * 16: 18 * 1024 + i * 16 + 16] = gen2.CHR[6 * 1024 + i * 16: 6 * 1024 + i * 16 + 16]

# ------------------------------------------------------------------ sprites
P3 = [0x0F, 0x27, 0x30]
FRAMES = {}
unit = 20

def ents_tiles(ents): return [pix_rows(p) for _, _, p, _ in ents]

def pack_with_prefix(name, prefix_ents_list, framelists, bank_tiles, tile_base, first_unit, per_bank_max=99):
    """prefix: lista de cuadros cuyos tiles van primero (mismos indices en todos los bancos)."""
    prefix = []
    for ents in prefix_ents_list:
        for t in ents_tiles(ents):
            if t not in prefix: prefix.append(t)
    banks = []; out = []; cur = None
    for ents in framelists:
        need = [t for t in ents_tiles(ents) if t not in prefix]
        if cur is None or len(set(banks[cur]) | set(need)) > bank_tiles or nb_frames[cur] >= per_bank_max:
            banks.append(list(prefix)); cur = len(banks) - 1
            nb_frames.append(0)
        b = banks[cur]
        for t in need:
            if t not in b: b.append(t)
        assert len(b) <= bank_tiles, (name, len(b))
        nb_frames[cur] += 1
        out.append((cur, [(dy, dx, tile_base + b.index(pix_rows(p)), ap) for dx, dy, p, ap in ents]))
    per = bank_tiles // 64
    for bi, b in enumerate(banks):
        for i, t in enumerate(b): put(first_unit + bi * per + i // 64, i % 64, list(t))
    FRAMES[name] = [(first_unit + bi * per, r) for bi, r in out]
    pref_frames = []
    for ents in prefix_ents_list:
        pref_frames.append([(dy, dx, tile_base + prefix.index(pix_rows(p)), ap) for dx, dy, p, ap in ents])
    return first_unit + len(banks) * per, pref_frames


from sprite3 import quantize_off
def quant_pair(src, mir, pals, cls):
    """cuantiza src y su version con piernas espejadas usando la misma grilla (comparten tiles de arriba)."""
    a1 = int(round(head_anchor(src))); a2 = int(round(head_anchor(mir)))
    best = None
    for oy in range(8):
        for ox in range(8):
            r = quantize_off(src, pals, cls, a1, ox, oy)
            sc = r[1] + len(r[0]) * 20000
            if best is None or sc < best[0]: best = (sc, r[0], ox, oy)
    _, e1, ox, oy = best
    ox2 = (a1 + ox - a2) % 8
    e2 = quantize_off(mir, pals, cls, a2, ox2, oy)[0]
    return e1, e2

nb_frames = []
CHARS = [dict(name='jose', row=0, shirt=0x2C, crgb=(20, 180, 225)),
         dict(name='luci', row=1, shirt=0x25, crgb=(235, 55, 125))]
PARKED = None
for ch in CHARS:
    cls = dict(CLS_RGB); cls['c'] = ch['crgb']
    pals = [(0, [0x0F, 0x27, 0x17]), (1, [0x0F, 0x30, ch['shirt']]), (3, P3)]
    park = [quantize(car(None, 0), [(1, [0x0F, 0x30, ch['shirt']]), (3, P3)], cls),
            quantize(moto(None, 0), [(1, [0x0F, 0x30, ch['shirt']]), (3, P3)], cls)]
    G = [deshine(frame(ch['row'], c)) for c in range(16)]
    G += stomp_poses(ch['row'])     # 16..19: caminata de pisotones
    fl = [quantize_layered(x, pals, cls, ax=int(round(head_anchor(x))), max_split=3) for x in G]
    nb_frames = []
    unit, pf = pack_with_prefix(ch['name'], park, fl, 64, 0x00, unit)
    if PARKED is None: PARKED = pf
    drv = deshine(frame(ch['row'], 9)); rid = deshine(frame(ch['row'], 9))
    def layered(full, body):
        """conductor y vehiculo como capas separadas (la cara no comparte tiles con la carroceria)"""
        from sprite3 import anchor as _anc
        ax = _anc(full)
        H = len(full); W = len(full[0])
        rid_l = [['.'] * W for _ in range(H)]; veh_l = [['.'] * W for _ in range(H)]
        for y in range(H):
            for x in range(W):
                c = full[y][x]
                if c == '.': continue
                if body[y][x] != '.' and body[y][x] == c: veh_l[y][x] = c
                else: rid_l[y][x] = c
        return quantize_layered(rid_l, pals, cls, ax=ax, max_split=3) + quantize(veh_l, pals, cls, ax=ax)
    rl = [layered(moto(rid, 0), moto(None, 0)), layered(moto(rid, 1.2), moto(None, 1.2)),
          layered(car(drv, 0), car(None, 0)), layered(car(drv, 1.2), car(None, 1.2))]
    nb_frames = []
    unit, _ = pack_with_prefix(ch['name'] + '_ride', park, rl, 64, 0x00, unit, per_bank_max=1)
print('unidades tras jugadores', unit)

# misc compartido (enemigos + jefes), al inicio de R4
cls = dict(CLS_RGB)
def mq(g, pals=None): return quantize(g, pals or [(3, P3)], cls)
def small(rows): return [list(r) for r in rows]
def expl16(k):
    R = random.Random(30 + k); c = Canvas(16, 16); rad = [6, 7.5][k]
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5) + R.uniform(-1.4, 1.4)
            v = (3 if d < rad * .45 else 2 if d < rad * .8 else 1 if d < rad else 0) if k == 0 else (1 if d < rad and R.random() < .5 else 2 if d < rad * .5 and R.random() < .3 else 0)
            if v: c.set(x, y, v)
    return to_grid(c, {1: 'k', 2: 's', 3: 'w'})
bag = Canvas(12, 12); bag.ellipse(6, 7, 5, 4.3, 2); bag.rect(4, 1, 8, 3, 2); bag.line(3, 3, 9, 3, 1)
for (x, y) in ((6, 5), (5, 6), (6, 7), (7, 8), (6, 9), (5, 10), (6, 4), (6, 11)): bag.set(x, y, 1)
bag.outline(1)
MISC = {
 'pb': mq(small(["..www.", ".wwsww", "..www."])),
 'eb': mq(small(["..kkk..", ".kswsk.", "kswwwsk", "kwwwwwk", "kswwwsk", ".kswsk.", "..kkk.."])),
 'flash': mq(small(["..w....", "...w.w.", "wwwwssw", "...w.w.", "..w...."])),
 'shadow': mq(small([".kkkkkkkkkk.", "kkkkkkkkkkkk", ".kkkkkkkkkk."])),
 'ex0': mq(expl16(0)), 'ex1': mq(expl16(1)),
 'ab': mq(small(["kkkkk.kkkkk", "kwwwk.kwwkk", "kwkwk.kwkwk", "kwwwk.kwwkk", "kwkwk.kwkwk", "kwkwk.kwwkk", "kkkkk.kkkkk"])),
 'rocket': mq(small(["..kkkkk..", "skwwwwwk.", "sskwwwwwk", "skwwwwwk.", "..kkkkk.."])),
 'siren': mq(small([".kkkkkk.", "kswwwssk", "kswwwssk", "kkkkkkkk"])),
}
MISC_ORDER = list(MISC.keys())
E = 'kkkkkkkk'; F = 'kswwwwsk'
BOSSX = {
 'bar0': mq(small([E] * 8)), 'bar1': mq(small([E] * 6 + [F, E])),
 'bar2': mq(small([E] * 4 + [F, E] * 2)),
 'bar3': mq(small([E] * 2 + [F, E] * 3)),
 'bar4': mq(small([F, E] * 4)),
 'shell': mq(small(["..ssss..", ".swwwws.", "swwwwwws", "swwwwwws", "swwwwwws", "swwwwwws", ".swwwws.", "..ssss.."])),
 'bomb': mq(small(["....s.s.", ".....s..", "..wwwww.", ".wkkkkkw", "wkskkkkkw"[:8], "wkkkkkkw", ".wkkkkw.", "..wwww.."])),
}
BOSSX_ORDER = list(BOSSX.keys())

def enemy_set(kind, ucol):
    c2 = dict(CLS_RGB); c2['u'] = NP[ucol]
    P = [(2, [0x0F, 0x27, ucol])]
    G = [make_enemy2(frame(0, c), kind) for c in (0, 2, 3, 7, 9, 14, 15)]
    fl = [quantize(x, P, c2, ax=int(round(head_anchor(x)))) for x in G]
    for i, c in ((1, 2), (2, 3)):
        e1, e2 = quant_pair(G[i], make_enemy2(mirror_legs(frame(0, c), 0)[0], kind), P, c2)
        fl[i] = e1; fl.append(e2)
    return fl
for kind, ucol in (('cop', 0x12), ('soldier', 0x1A)):
    nb_frames = []
    pre = [MISC[n] for n in MISC_ORDER]
    unit, mpf = pack_with_prefix(kind, pre, enemy_set(kind, ucol), 128, 0x80, unit)
    print(kind, 'bancos', len(set(b for b, _ in FRAMES[kind])))
    assert len(set(b for b, _ in FRAMES[kind])) == 1, kind
    MISC_FRAMES = mpf
for i, f in enumerate(BOSSES):
    u, v = BOSS_COL[i]
    c2 = dict(CLS_RGB); c2['u'] = NP[u]; c2['v'] = NP[v]; c2['o'] = NP[0x27]
    pals = [(2, [0x0F, u, v]), (3, P3)]
    nb_frames = []
    pre = [MISC[n] for n in MISC_ORDER] + [BOSSX[n] for n in BOSSX_ORDER]
    unit, bpf = pack_with_prefix('boss%d' % i, pre, [quantize(f(0), pals, c2), quantize(f(1), pals, c2)], 128, 0x80, unit)
    assert len(set(b for b, _ in FRAMES['boss%d' % i])) == 1
    BOSSX_FRAMES = bpf[len(MISC_ORDER):]
print('unidades CHR usadas:', unit)
assert unit <= NUNITS
open('chr4.bin', 'wb').write(CHR)

# ------------------------------------------------------------------ tablas de metasprites (banco 0)
A = ['; ---- banco 0: metasprites ----']
def emit_frames(prefix, frames):
    A.append('%s_lo: .byte %s' % (prefix, ','.join('<%s_f%d' % (prefix, i) for i in range(len(frames)))))
    A.append('%s_hi: .byte %s' % (prefix, ','.join('>%s_f%d' % (prefix, i) for i in range(len(frames)))))
    for i, ents in enumerate(frames):
        flat = [len(ents)]
        for dy, dx, t, ap in ents: flat += [dy & 255, dx & 255, t, ap]
        A.append('%s_f%d: .byte %s' % (prefix, i, ','.join('$%02X' % v for v in flat)))
for n, fr in FRAMES.items():
    emit_frames(n, [r for _, r in fr])
    A.append('%s_bk: .byte %s' % (n, ','.join(str(b) for b, _ in fr)))
emit_frames('park', PARKED)
emit_frames('misc', MISC_FRAMES)
emit_frames('bossx', BOSSX_FRAMES)
open('bank0.asm', 'w').write('\n'.join(A) + '\n')

# ------------------------------------------------------------------ niveles (banco 1)
NAMES = ["PLAYA NICE", "CALLE OCHO", "PUERTO DEL SOL", "LOS CAYOS", "AUTOPISTA 95",
         "LOS PANTANOS", "DISTRITO ART DECO", "AEROPUERTO", "CENTRO NOCTURNO", "LA MANSION"]
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
B = ['; ---- banco 1: niveles ----']
for i in range(10):
    th, bg, p1, p2, p3 = LV[i]
    td = theme_data[th]
    R = random.Random(500 + i)
    seq = []
    while len(seq) < LEVEL_MC:
        seq += [R.randrange(len(td['blocks']))] * R.choice([1, 2, 2, 3])
    seq = seq[:LEVEL_MC]
    faction = 1 if i >= 5 else 0
    ucol = 0x1A if faction else 0x12
    bu, bv = BOSS_COL[i]
    pal = [bg, 0x0F, 0x30, 0x16, bg, *p1, bg, *p2, bg, *p3,
           bg, 0x0F, 0x27, 0x17, bg, 0x0F, 0x30, 0x2C, bg, 0x0F, 0x27, ucol, bg, 0x0F, 0x27, 0x30]
    waves = []
    for k, mc in enumerate((10, 26, 42, 58, 74)):
        cnt = 3 + (i + k) // 3
        cars = 1 if (i >= 1 and k % 2 == 1) or (i >= 4 and k >= 2) else 0
        waves += [mc, cnt, cars]
    vehs = []
    for k, mc in enumerate((18, 50, 82)):
        vehs += [mc, 1 + (k + i) % 2, R.choice([180, 200, 220])]
    weap = []
    for k, mc in enumerate((6, 36, 66)):
        t = 1 + R.randrange(4) if i > 0 else 1 + k % 3
        if i >= 4 and k == 2: t = 6          # lanzacohetes en los niveles altos
        weap += [mc, t, R.choice([176, 196, 216])]
    B.append('lvl%d_seq:\n' % i + '\n'.join('    .byte ' + ','.join(str(v) for v in seq[j:j + 16]) for j in range(0, LEVEL_MC, 16)))
    B.append('lvl%d_pal: .byte %s' % (i, ','.join('$%02X' % v for v in pal)))
    B.append('lvl%d_bpal: .byte $%02X,$0F,$%02X,$%02X' % (i, bg, bu, bv))
    B.append('lvl%d_waves: .byte %s, $FF' % (i, ','.join(str(v) for v in waves)))
    B.append('lvl%d_veh: .byte %s, $FF' % (i, ','.join(str(v) for v in vehs)))
    B.append('lvl%d_weap: .byte %s, $FF' % (i, ','.join(str(v) for v in weap)))
for th in THEME_ORDER:
    td = theme_data[th]
    B.append('blk_%s:' % th)
    for cols, pals in td['blocks']:
        B.append('    .byte ' + ','.join('$%02X' % v for v in cols[0] + cols[1]) + ',' + ','.join(str(p) for p in pals) + ',0,0,0')
    B.append('street_%s:' % th)
    for row in td['smap']: B.append('    .byte ' + ','.join('$%02X' % v for v in row))
    B.append('far_%s:' % th)
    for row in td['fmap']: B.append('    .byte ' + ','.join('$%02X' % v for v in row))
    B.append('wtile_%s: .byte %s' % (th, ','.join('$%02X' % v for v in td['wt'])))
B.append('bank_nt:'); B.append('\n'.join('    .byte ' + ','.join('$%02X' % v for v in sum(gen2.bank_nt, [])[j:j + 16]) for j in range(0, 960, 16)))
B.append('bank_at:'); B.append('    .byte ' + ','.join('$%02X' % v for v in gen2.bank_attr))
open('bank1.asm', 'w').write('\n'.join(B) + '\n')

# ------------------------------------------------------------------ tabla fija
D = []
for i, n in enumerate(MISC_ORDER): D.append('MF_%s = %d' % (n.upper(), i))
for i, n in enumerate(BOSSX_ORDER): D.append('BX_%s = %d' % (n.upper(), i))
D.append('LEVEL_MC = %d' % LEVEL_MC)
D.append('level_tbl:')
for i in range(10):
    th = LV[i][0]; td = theme_data[th]
    D.append('    .word lvl%d_seq, lvl%d_pal, lvl%d_waves, lvl%d_veh, blk_%s, street_%s, far_%s, lvl%d_bpal, lvl%d_weap, wtile_%s' % (i, i, i, i, th, th, th, i, i, th))
    D.append('    .byte %d, %d, %d, %d, %d' % (td['fpage'], td['tunit'], 1 if i >= 5 else 0, min(5, 1 + i // 2), i))
for n in ('cop', 'soldier'): D.append('UNIT_%s = %d' % (n.upper(), FRAMES[n][0][0]))
D.append('boss_units: .byte ' + ','.join(str(FRAMES['boss%d' % i][0][0]) for i in range(10)))
D.append('name_tbl:'); D.append('    .word ' + ','.join('name%d' % i for i in range(10)))
for i, nm in enumerate(NAMES):
    D.append('name%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 14 * 32 + (32 - len(nm)) // 2, nm))
D.append('bname_tbl:'); D.append('    .word ' + ','.join('bname%d' % i for i in range(10)))
for i, nm in enumerate(BOSS_NAMES):
    D.append('bname%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 18 * 32 + (32 - len(nm)) // 2, nm))
# logo JETEA 6
GL = {'J': ["..##", "...#", "...#", "...#", "#..#", "#..#", ".##."],
      'E': ["####", "#...", "#...", "###.", "#...", "#...", "####"],
      'T': ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
      'A': [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
      '6': [".##.", "#...", "#...", "###.", "#..#", "#..#", ".##."],
      ' ': [".."] * 7}
ROWTILE = [0x43, 0x43, 0x44, 0x42, 0x45, 0x41, 0x41]
src = open('data2.asm').read()
D.append(src[src.index('note_lo:'):])
open('data4.asm', 'w').write('\n'.join(D) + '\n')

# ------------------------------------------------------------------ pantalla de titulo (imagen de referencia)
import title_gen
TF = dict(gen2.FONT2); TF['>'] = ["#    ", "##   ", "###  ", "#### ", "###  ", "##   ", "#    "]
TS, BS, tnt, tat, tpal, ntop, nbot = title_gen.make_title(TF)
TUNIT = 120
for i, t in enumerate(TS): put(TUNIT, i, list(t))
for i, t in enumerate(BS): put(TUNIT + 4, i, list(t))
T = ['; ---- banco 2: titulo ----', 'title_nt:']
allb = tnt + tat
for j in range(0, 1024, 16): T.append('    .byte ' + ','.join('$%02X' % v for v in allb[j:j + 16]))
T.append('title_pal: .byte ' + ','.join('$%02X' % v for v in tpal) + ',$0F,$0F,$27,$17,$0F,$0F,$30,$2C,$0F,$0F,$27,$12,$0F,$0F,$27,$30')
open('bank2.asm', 'w').write('\n'.join(T) + '\n')
D2 = open('data4.asm').read() + 'TITLE_UNIT = %d\nTITLE_SPLIT = %d\n' % (TUNIT, title_gen.SPLIT_ROW)
open('data4.asm', 'w').write(D2)
open('chr4.bin', 'wb').write(CHR)

# ------------------------------------------------------------------ mini historia (3 escenas grandes)
import story_gen
STORY_LINES = [
    [(0, "ARRIBA LAS MANOS!"), (1, "ESTO ES UN ASALTO!"), (2, "NO DISPAREN! TOMEN TODO!"), (0, "LA PLATA A LA BOLSA, RAPIDO!")],
    [(1, "ESCUCHAN ESO? SIRENAS..."), (0, "VAMONOS! LLEGO LA POLICIA!"), (1, "SALGAMOS YA, POR LA PUERTA!")],
    [(0, "TENEMOS EL BOTIN!"), (1, "A LA MOTO! A NICE CITY!")],
    [(4, "NICE CITY YA NO ES LUGAR..."), (3, "...PARA NOSOTROS. VAMONOS."), (4, "A DONDE VAMOS, JOSE?"),
     (3, "A OTRA CIUDAD. JUNTOS."), (5, "Y ASI SIGUIO LA AVENTURA"), (5, "CONTINUARA...")],
]
NAMES_ST = ["JOSE:", "LUCIANA:", "CAJERO:", "FIN"]
alltext = [t for sc in STORY_LINES for _, t in sc] + NAMES_ST
for sc in STORY_LINES:
    for _, t in sc: assert len(t) <= 28, t
SCN = story_gen.make_story(TF, alltext)
SUNIT = (unit + 1) & ~1
assert SUNIT + 32 <= 118, ('sin lugar para la historia', SUNIT)
for si, (TSs, BSs, nts, spal, flash, R, nt_, nb_) in enumerate(SCN):
    u = SUNIT + si * 8
    for i, t in enumerate(TSs): put(u, i, list(t))
    for i, t in enumerate(BSs): put(u + 4, i, list(t))
    L = ['; ---- banco %d: escena %d de la historia ----' % (3 + si, si)]
    L.append('    .byte ' + ','.join('$%02X' % v for v in spal) + ',$0F,$0F,$27,$17,$0F,$0F,$30,$2C,$0F,$0F,$27,$12,$0F,$0F,$27,$30')
    for nt in nts:
        for j in range(0, 1024, 16): L.append('    .byte ' + ','.join('$%02X' % v for v in nt[j:j + 16]))
    fi = flash[0]
    L.append('    .byte %d, %d, %d, %d, %d, %d, $%02X, $%02X' % (u, u + 2, u + 4, u + 6, (R - 1) * 8 + 2, fi, flash[1], flash[2]))
    for sp, t in STORY_LINES[si]:
        L.append('    .byte %d' % sp)
        L.append('    .ltext "%s"' % t)
    L.append('    .byte $FF')
    open('bank%d.asm' % (3 + si), 'w').write('\n'.join(L) + '\n')
open('chr4.bin', 'wb').write(CHR)

# ------------------------------------------------------------------ logo NIKITA (intro)
def make_nikita():
    from scipy import ndimage
    im = np.array(Image.open('story/nikita.jpg').convert('L'))
    B = im < 128
    lab, n = ndimage.label(B)
    objs = ndimage.find_objects(lab)
    comps = sorted(range(1, n + 1), key=lambda i: objs[i - 1][1].start)
    bolts = [comps[0], comps[-1]]
    letters = comps[1:-1]
    Wt = 240; f = B.shape[1] / Wt; Ht = int(B.shape[0] / f)
    def render(ids, val):
        m = np.isin(lab, ids)
        out = np.zeros((Ht, Wt), int)
        for y in range(Ht):
            for x in range(Wt):
                blk = m[int(y * f):int((y + 1) * f), int(x * f):int((x + 1) * f)]
                if blk.mean() > .45: out[y, x] = val
        return out
    L = [render([c], 1) for c in letters]
    BO = render(bolts, 2)
    steps = []
    acc = np.zeros((Ht, Wt), int)
    for k in range(len(L)):
        acc = np.maximum(acc, L[k]); steps.append(acc.copy())
    steps.append(np.maximum(acc, BO))
    ox, oy = 8, 3
    tiles = [tuple(['........'] * 8)]
    nts = []
    for st in steps:
        canvas = np.zeros((48, 256), int)
        canvas[oy:oy + Ht, ox:ox + Wt] = st
        nt = []
        for ty in range(6):
            for tx in range(32):
                t = tuple(''.join(str(canvas[ty * 8 + y, tx * 8 + x]) if canvas[ty * 8 + y, tx * 8 + x] else '.' for x in range(8)) for y in range(8))
                if t not in tiles: tiles.append(t)
                nt.append(tiles.index(t))
        nts.append(nt)
    assert len(tiles) <= 256, len(tiles)
    return tiles, nts
NK_T, NK_NT = make_nikita()
NKUNIT = 118
for i, t in enumerate(NK_T): put(NKUNIT, i, list(t))
L7 = ['; ---- banco 7: logo NIKITA ----', 'NK_UNIT = %d' % NKUNIT, 'NK_STEPS = %d' % len(NK_NT), 'nk_nt:']
for nt in NK_NT:
    for j in range(0, 192, 16): L7.append('    .byte ' + ','.join('$%02X' % v for v in nt[j:j + 16]))
open('bank7data.asm', 'w').write('\n'.join(L7) + '\n')
print('logo nikita tiles', len(NK_T))
open('chr4.bin', 'wb').write(CHR)
print('titulo: tiles arriba %d abajo %d' % (ntop, nbot))
print('ok')
