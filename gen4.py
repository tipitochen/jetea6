from PIL import Image
import numpy as np
#!/usr/bin/env python3
"""Generador v4 (JETEA 6): CHR 128KB, 2 jugadores, armas en el fondo, patrulleros, barra de jefe, musica GTA."""
import io, contextlib, random, math
with contextlib.redirect_stdout(io.StringIO()):
    import gen2
from gen import FONT, tile_bytes
from sprite3 import frame, quantize, CLS_RGB, nes
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

NUNITS = 256
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
WEAP = {   # paleta 0 de fondo: 1 negro, 2 blanco, 3 rojo
 'PIST': ["1111111111111111", "1122222222222111", "1122222222222211", "1111222111111111", "1111223111111111", "1111222111111111", "1111111111111111", "1111111111111111"],
 'ESCO': ["1111111111111111", "1111111111111111", "3333322222222221", "3333322222222221", "3311111222111111", "3111111111111111", "1111111111111111", "1111111111111111"],
 'METR': ["1111111111111111", "1111111111211111", "1112222222222221", "1122222222222221", "1111222112111111", "1111222112111111", "1111111112111111", "1111111111111111"],
 'BAZU': ["1111111111111111", "1112222222222111", "1322323222322231", "1322323222322231", "1112222222222111", "1111112211111111", "1111111111111111", "1111111111111111"],
 'CORA': ["1111111111111111", "1111331111331111", "1113233113333111", "1113333333333111", "1111333333331111", "1111133333311111", "1111111331111111", "1111111111111111"],
 'LANZ': ["1111111111111111", "1222222222222331", "1222222222223333", "1222222222222331", "1111223111111111", "1111222111111111", "1111111111111111", "1111111111111111"],
 'PUNO': ["1111111111111111", "1111122222211111", "1111222222221111", "1111222222222111", "1111322222222111", "1111332222221111", "1111133333311111", "1111111111111111"],
 'BARR': ["2222222233333333", "3333333333333333", "3333333333333333", "3333333333333333", "3333333333333333", "3333333333333333", "3333333333333333", "3333333333333333"],
}
WEAP_ORDER = ['PIST', 'ESCO', 'METR', 'BAZU', 'CORA', 'LANZ', 'PUNO', 'BARR']

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
    cls = dict(CLS_RGB); cls['c'] = tuple(nes(ch['shirt']))
    # clases = colores NES exactos de la paleta del jugador (asi no hay pixeles "malos" falsos)
    cls.update(k=tuple(nes(0x0F)), s=tuple(nes(0x27)), h=tuple(nes(0x17)), w=tuple(nes(0x30)), g=tuple(nes(0x30)))
    pals = [(0, [0x0F, 0x27, 0x17]), (1, [0x0F, 0x30, ch['shirt']]), (3, P3)]
    import ref_veh
    park = [quantize(ref_veh.parked('auto'), [(1, [0x0F, 0x30, ch['shirt']]), (3, P3)], cls),
            quantize(ref_veh.parked('moto'), [(1, [0x0F, 0x30, ch['shirt']]), (3, P3)], cls)]
    from arsenal_gen import clean_face
    G = [clean_face(frame(ch['row'], c)) for c in range(16)]
    G += stomp_poses(ch['row'])     # 16..19: caminata de pisotones
    fl = [quantize_layered(x, pals, cls, ax=int(round(head_anchor(x))), max_split=6) for x in G]
    for c in (2, 3, 4, 11, 12): fl[c] = []      # cuadros que ya no se usan
    nb_frames = []
    unit, pf = pack_with_prefix(ch['name'], park, fl, 64, 0x00, unit)
    if PARKED is None: PARKED = pf
    drv = clean_face(frame(ch['row'], 9)); rid = clean_face(frame(ch['row'], 9))
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
        return quantize_layered(rid_l, pals, cls, ax=ax, max_split=6) + quantize(veh_l, pals, cls, ax=ax)
    # moto y auto de la referencia del usuario (conductor + vehiculo en capas)
    VM, MZM = ref_veh.vehicle('moto', ch['row']); VA, MZA = ref_veh.vehicle('auto', ch['row'])
    from sprite3 import anchor as _a2
    rl = [quantize_layered(f, pals, cls, ax=_a2(f), max_split=8) for f in (VM[0][0], VM[1][0], VA[0][0], VA[1][0])]
    from sprite3 import anchor as _anc
    VEH_MUZ = [(MZM[0] - _anc(VM[0][0]), len(VM[0][0]) - MZM[1]), (MZA[0] - _anc(VA[0][0]), len(VA[0][0]) - MZA[1])]
    nb_frames = []
    unit, _ = pack_with_prefix(ch['name'] + '_ride', park[:1], rl, 64, 0x00, unit, per_bank_max=1)   # solo el auto (patrulleros)
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
 'arrow': mq(small(["...ww...", "...www..", "wwwwwww.", "wwwwwwww", "wwwwwwww", "wwwwwww.", "...www..", "...ww..."])),
 'plane': mq(small(["..........w.....", ".........ww.....", "ww....wwwwwwwww.", "wwwwwwwwwwwwwwww", ".wwwwwwwwwwwwww.", ".......ww.......", "......ww........"])),
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
    split = prefix in ('jose', 'luci', 'jose_ride', 'luci_ride')
    for i, ents in enumerate(frames):
        seen = set(); base = []; over = []
        for e in ents:
            dy, dx, t, ap = e
            (over if (dy, dx) in seen and split else base).append(e)
            seen.add((dy, dx))
        # jugadores: [n base, ...] seguido de [n superpuestos, ...] (se dibujan al final de todo:
        # con mas de 8 sprites por linea se pierde un detalle de color, no un pedazo del cuerpo)
        flat = [len(base)]
        for dy, dx, t, ap in base: flat += [dy & 255, dx & 255, t, ap]
        if split:
            flat.append(len(over))
            for dy, dx, t, ap in over: flat += [dy & 255, dx & 255, t, ap]
        A.append('%s_f%d: .byte %s' % (prefix, i, ','.join('$%02X' % v for v in flat)))
for n, fr in FRAMES.items():
    emit_frames(n, [r for _, r in fr])
    A.append('%s_bk: .byte %s' % (n, ','.join(str(b) for b, _ in fr)))
emit_frames('park', PARKED)
emit_frames('misc', MISC_FRAMES)
emit_frames('bossx', BOSSX_FRAMES)
open('bank0.asm', 'w').write('\n'.join(A) + '\n')

# ------------------------------------------------------------------ niveles (banco 1)
NAMES = ["PLAYA NICE", "CIELOS DE NICE", "PUERTO DEL SOL", "LOS CAYOS", "AUTOPISTA 95",
         "BAHIA DE NICE", "DISTRITO ART DECO", "AEROPUERTO", "CENTRO NOCTURNO", "LA MANSION"]
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
    for k, mc in enumerate((86, 89, 92)):
        t = 1 + R.randrange(4) if i > 0 else 1 + k % 3
        if i >= 4 and k == 2: t = 6          # lanzacohetes en los niveles altos
        weap += [mc, t, R.choice([208, 216, 224])]
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
NM = ['; nombres de niveles y jefes (banco 2)']
NM.append('name_tbl:'); NM.append('    .word ' + ','.join('name%d' % i for i in range(10)))
for i, nm in enumerate(NAMES):
    NM.append('name%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 14 * 32 + (32 - len(nm)) // 2, nm))
NM.append('bname_tbl:'); NM.append('    .word ' + ','.join('bname%d' % i for i in range(10)))
for i, nm in enumerate(BOSS_NAMES):
    NM.append('bname%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 18 * 32 + (32 - len(nm)) // 2, nm))
open('names4.asm', 'w').write('\n'.join(NM) + '\n')
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
blank_t = tuple(['........'] * 8)
u_next = SUNIT
for si, (TSs, BSs, nts, spal, flash, R, nt_, nb_) in enumerate(SCN):
    def need(T):
        hi = max([i for i, t in enumerate(T) if t != blank_t] + [0])
        return 2 if hi < 128 else 4
    nt_u, nb_u = need(TSs), need(BSs)
    ut = u_next; ub = ut + nt_u; u_next = ub + nb_u
    for i, t in enumerate(TSs[:nt_u * 64]): put(ut, i, list(t))
    for i, t in enumerate(BSs[:nb_u * 64]): put(ub, i, list(t))
    hdr = (ut, ut + 2 if nt_u == 4 else ut, ub, ub + 2 if nb_u == 4 else ub)
    L = ['; ---- banco %d: escena %d de la historia ----' % (3 + si, si)]
    L.append('    .byte ' + ','.join('$%02X' % v for v in spal) + ',$0F,$0F,$27,$17,$0F,$0F,$30,$2C,$0F,$0F,$27,$12,$0F,$0F,$27,$30')
    for nt in nts:
        for j in range(0, 1024, 16): L.append('    .byte ' + ','.join('$%02X' % v for v in nt[j:j + 16]))
    fi = flash[0]
    L.append('    .byte %d, %d, %d, %d, %d, %d, $%02X, $%02X' % (hdr + ((R - 1) * 8 + 2, fi, flash[1], flash[2])))
    for sp, t in STORY_LINES[si]:
        L.append('    .byte %d' % sp)
        L.append('    .ltext "%s"' % t)
    L.append('    .byte $FF')
    assert u_next <= 118, ('historia sin lugar', u_next)
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

# ------------------------------------------------------------------ ARSENAL (personaje girando + armas)
import arsenal_gen as AG
ARS_U = 128
ars_units = []; ars_sunit = []; ars_attr = []; ars_ov = []; ars_hand = []; ars_pals = []
GRIP = {1: (5, 4), 2: (7, 3), 3: (5, 4), 4: (6, 4), 6: (5, 4)}
WSLOT = [0, 1, 2, 3, 4, 6]
WNAME = {1: 'PIST', 2: 'ESCO', 3: 'METR', 4: 'BAZU', 6: 'LANZ'}
def wsprite(t):
    """arma a 2x como sprites (placa negra transparente): lista de (dy, tile_rows, dx) respecto del agarre"""
    ic = WEAP[WNAME[t]]
    big = [[ic[y // 2][x // 2] for x in range(32)] for y in range(16)]
    gx, gy = GRIP[t]
    out = []
    for ty in range(2):
        for tx in range(4):
            rows = tuple(''.join('.' if big[ty * 8 + y][tx * 8 + x] == '1' else big[ty * 8 + y][tx * 8 + x] for x in range(8)) for y in range(8))
            if all(c == '.' for r in rows for c in r): continue
            out.append((ty * 8 - gy * 2, rows, tx * 8 - gx * 2))
    return out
WSP = {t: wsprite(t) for t in WNAME}
for ci, (row, shirt) in enumerate(((0, 0x2C), (1, 0x25))):
    A, pals = AG.build(row, shirt)
    spr_tiles = [tuple(['........'] * 8)]
    def stile(rows):
        if rows not in spr_tiles: spr_tiles.append(rows)
        return spr_tiles.index(rows)
    wt = {t: [(dy, stile(rows), dx) for dy, rows, dx in WSP[t]] for t in WSP}
    # iconos del menu (a 2x, sin letras): punos + armas, posicion desde la esquina
    def icon2x(name):
        ic = WEAP[name]
        big = [[ic[y // 2][x // 2] for x in range(32)] for y in range(16)]
        L_ = []
        for ty in range(2):
            for tx in range(4):
                rows = tuple(''.join('.' if big[ty * 8 + y][tx * 8 + x] == '1' else big[ty * 8 + y][tx * 8 + x] for x in range(8)) for y in range(8))
                if all(c == '.' for r in rows for c in r): continue
                L_.append((ty * 8, stile(rows), tx * 8))
        return L_
    icons = [icon2x(n) for n in ('PUNO', 'PIST', 'ESCO', 'METR', 'BAZU', 'LANZ')]
    arrow = stile(tuple(r.replace('#', '2') for r in ["........", "..#.....", "..##....", "..###...", "..####..", "..###...", "..##....", "..#....."]))
    for ai, a in enumerate(A):
        u = ARS_U + (ci * AG.NV + ai) * 3
        ars_units.append(u)
        for i, t in enumerate(a['cells']): put(u, i, list(t))
        # atributos filas 1..4 (32 bytes): izquierda la figura, derecha el menu (paleta 3)
        at = []
        for ay in range(1, 5):
            for axb in range(8):
                v = 0
                for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                    by = ay * 2 + dy - 2; bx = axb * 2 + dx
                    p = a['attr'][by][bx] if (0 <= by < len(a['attr']) and bx < AG.CW // 2) else 3
                    v |= p << (q * 2)
                at.append(v)
        ars_attr.append(at)
        ov = []
        for x0, y0, t, pi in a['over']:
            rows = tuple(''.join(str(v) if v else '.' for v in r) for r in t)
            ov.append((y0 - 1, stile(rows), pi, x0))
        ars_ov.append(ov)
        ars_hand.append(a['hand'])
    su = ARS_U + 2 * AG.NV * 3 + ci * 4
    ars_sunit.append(su)
    assert len(spr_tiles) <= 256
    for i, t in enumerate(spr_tiles): put(su, i, list(t))
    pal = []
    for P in pals: pal += [0x0F] + P          # fondo negro (como la referencia); 4a paleta = figura + menu
    for P in pals[:3]: pal += [0x0F] + P
    pal += [0x0F, 0x0F, 0x30, 0x16]
    ars_pals.append(pal)
    if ci == 0: WT0 = wt; ARROW0 = arrow; IC0 = icons
    else: assert wt == WT0 and arrow == ARROW0 and icons == IC0
    ars_pals_w = wt
A7 = ['; ---- datos del ARSENAL ----', 'ARS_ARROW = %d' % ARROW0]
A7.append('ars_units: .byte ' + ','.join(str(v) for v in ars_units))
A7.append('ars_sunit: .byte ' + ','.join(str(v) for v in ars_sunit))
A7.append('ars_seq: .byte ' + ','.join(str(v) for v in AG.SEQ))
for ci in range(2): A7.append('ars_pal%d: .byte %s' % (ci, ','.join('$%02X' % v for v in ars_pals[ci])))
A7.append('ars_attr:')
for at in ars_attr: A7.append('    .byte ' + ','.join('$%02X' % v for v in at))
A7.append('ARS_NV = %d' % AG.NV)
A7.append('ARS_NSEQ = %d' % len(AG.SEQ))
A7.append('ars_base: .byte 0, %d' % AG.NV)
A7.append('ars_ov_lo: .byte ' + ','.join('<ars_ov%d' % i for i in range(2 * AG.NV)))
A7.append('ars_ov_hi: .byte ' + ','.join('>ars_ov%d' % i for i in range(2 * AG.NV)))
for i, ov in enumerate(ars_ov):
    A7.append('ars_ov%d: .byte %d%s' % (i, len(ov), ''.join(', %d,%d,%d,%d' % (y, t, p, x) for y, t, p, x in ov)))
A7.append('ars_hand: .byte ' + ','.join('%d,%d,%d,%d' % (x & 255, y, 1 if v else 0, 1 if f else 0) for x, y, v, f in ars_hand))
# armas: listas por tipo (con los tiles de cada personaje: se generan iguales porque se agregan en el mismo orden)
A7.append('ars_w_lo: .byte ' + ','.join(('<ars_w%d' % t) if t else '<ars_w0' for t in WSLOT))
A7.append('ars_w_hi: .byte ' + ','.join(('>ars_w%d' % t) if t else '>ars_w0' for t in WSLOT))
A7.append('ars_w0: .byte 0')
A7.append('ars_ic_lo: .byte ' + ','.join('<ars_ic%d' % i for i in range(6)))
A7.append('ars_ic_hi: .byte ' + ','.join('>ars_ic%d' % i for i in range(6)))
for i, L_ in enumerate(IC0):
    A7.append('ars_ic%d: .byte %d%s' % (i, len(L_), ''.join(', %d,%d,%d' % (dy, tt, dx) for dy, tt, dx in L_)))
for t in WNAME:
    L_ = WT0[t]
    A7.append('ars_w%d: .byte %d%s' % (t, len(L_), ''.join(', %d,%d,%d' % (dy & 255, tt, dx & 255) for dy, tt, dx in L_)))
open('ars_data.asm', 'w').write('\n'.join(A7) + '\n')
# ------------------------------------------------------------------ NIVEL 2: EN LOS CIELOS (banco 8)
import heli_gen as HG
ht2, ht3, A8 = HG.build()
for i, t in enumerate(ht2): put(HG.HELI_SPR_UNIT, i, list(t))
for i, t in enumerate(ht3): put(HG.HELI_BOSS_UNIT, i, list(t))
htl, AB = HG.bg_asm()
for i, t in enumerate(htl): put(HG.HELI_BG_UNIT + i // 64, i % 64, list(t))
def emit_to(L, prefix, frames):
    L.append('%s_lo: .byte %s' % (prefix, ','.join('<%s_f%d' % (prefix, i) for i in range(len(frames)))))
    L.append('%s_hi: .byte %s' % (prefix, ','.join('>%s_f%d' % (prefix, i) for i in range(len(frames)))))
    for i, ents in enumerate(frames):
        flat = [len(ents)]
        for dy, dx, t, ap in ents: flat += [dy & 255, dx & 255, t, ap]
        L.append('%s_f%d: .byte %s' % (prefix, i, ','.join('$%02X' % v for v in flat)))
emit_to(A8, 'hm', MISC_FRAMES)
emit_to(A8, 'hbx', BOSSX_FRAMES)
# personajes caminando para la animacion de subir al helicoptero (cuadro + su banco de CHR)
# policias de la calle para la escena de los drones (banco de policias en R4/R5)
emit_to(A8, 'hc', [FRAMES['cop'][k][1] for k in (0, 4)])
A8.append('hc_unit = %d' % FRAMES['cop'][0][0])
for nm, pre in (('jose', 'hj'), ('luci', 'hl')):
    sel = [0, 16, 17, 18, 19]
    emit_to(A8, pre, [FRAMES[nm][k][1] for k in sel])
    A8.append('%s_unit: .byte %s' % (pre, ','.join(str(FRAMES[nm][k][0]) for k in sel)))
# escena de la azotea con el helicoptero grande
sr0, sr1, AS = HG.scene_build()
for i, t in enumerate(sr1): put(HG.SCENE_R1 + i // 64, i % 64, list(t))
FP = 2                                   # pagina de fuente del tema A (R0 del nivel 1)
for U, k in ((HG.SCENE_A, 0), (HG.SCENE_B, 1)):
    for t in range(0x48):
        CHR[U * 1024 + t * 16:U * 1024 + t * 16 + 16] = CHR[FP * 1024 + t * 16:FP * 1024 + t * 16 + 16]
    for i, pair in enumerate(sr0):
        tt = 0x48 + i
        put(U + tt // 64, tt % 64, list(pair[k]))
open('heli_data.asm', 'w').write('\n'.join(A8 + AB + AS) + '\n')
# ------------------------------------------------------------------ NIVEL 6: BAHIA DE NICE (motos de agua, banco 9)
import agua_gen as WG
wpl, wen, wya, wsc, A9 = WG.build()
for v, tl_ in enumerate(wpl):
    for i, t in enumerate(tl_): put(WG.AGUA_PL_UNIT + v, i, list(t))
for i, t in enumerate(wen): put(WG.AGUA_EN_UNIT, i, list(t))
for i, t in enumerate(wya): put(WG.AGUA_BOSS_UNIT, i, list(t))
for i, t in enumerate(wsc): put(WG.ASC_SPR + i // 64, i % 64, list(t))
wtl, WB = WG.bg_asm()
for i, t in enumerate(wtl): put(WG.AGUA_BG_UNIT + i // 64, i % 64, list(t))
emit_to(A9, 'whm', MISC_FRAMES)
emit_to(A9, 'whbx', BOSSX_FRAMES)
for nm, pre in (('jose', 'whj'), ('luci', 'whl')):
    sel = [0, 16, 17, 18, 19]
    emit_to(A9, pre, [FRAMES[nm][k][1] for k in sel])
    A9.append('%s_unit: .byte %s' % (pre, ','.join(str(FRAMES[nm][k][0]) for k in sel)))
# fuente del nivel con los tiles del yate en $48..
for t in range(0x48):
    CHR[WG.AGUA_FONT * 1024 + t * 16:WG.AGUA_FONT * 1024 + t * 16 + 16] = CHR[FP * 1024 + t * 16:FP * 1024 + t * 16 + 16]
for i, t in enumerate(WG.YACHT_TILES):
    tt = 0x48 + i
    put(WG.AGUA_FONT + tt // 64, tt % 64, list(t))
wr0, wr1, WS = WG.dock_build()
for i, t in enumerate(wr1): put(WG.ASC_R1 + i // 64, i % 64, list(t))
for t in range(0x48):
    CHR[WG.ASC_A * 1024 + t * 16:WG.ASC_A * 1024 + t * 16 + 16] = CHR[FP * 1024 + t * 16:FP * 1024 + t * 16 + 16]
for i, t in enumerate(wr0):
    tt = 0x48 + i
    put(WG.ASC_A + tt // 64, tt % 64, list(t))
ki = WB.index('agua_map:')
BIG = [l for l in WB[ki:] + WS if not (l.startswith('agua_bgpal') or l.startswith('dock_pal'))]
PALS = WB[:ki] + [l for l in WB[ki:] + WS if l.startswith('agua_bgpal') or l.startswith('dock_pal')]
open('agua_data.asm', 'w').write('\n'.join(A9 + PALS) + '\n')
open('agua_bgdata.asm', 'w').write('; banco 10 (se mapea en $A000 solo con la PPU apagada)\n' + '\n'.join(BIG) + '\n')
open('chr4.bin', 'wb').write(CHR)
print('arsenal: unidades hasta', ARS_U + 2 * AG.NV * 3 + 8)
print('titulo: tiles arriba %d abajo %d' % (ntop, nbot))
print('ok')
