#!/usr/bin/env python3
"""Generador v2: CHR 64KB, niveles con vehiculos/patrulleros, banco, banda lejana, musica 3 pistas."""
import random, math
from art import *
from gen import FONT, tile_bytes

CHR = bytearray(64 * 1024)
def put(unit, idx, rows):
    off = unit * 1024 + idx * 16
    CHR[off:off + 16] = tile_bytes(rows)
def put_tiles(unit, first, tiles):
    for i, t in enumerate(tiles):
        n = first + i
        put(unit + n // 64, n % 64, t)
    return first + len(tiles)

# ---------------------------------------------------------------- fuente (unidades 0-1)
FONT2 = dict(FONT)
FONT2['+'] = ["     ", "  #  ", "  #  ", "#####", "  #  ", "  #  ", "     "]
FONT2['$'] = ["  #  ", " ####", "# #  ", " ### ", "  # #", "#### ", "  #  "]
for ch, g in FONT2.items():
    put(0, ord(ch) - 32, ['.' + r.replace('#', '1').replace(' ', '.') + '..' for r in g] + ['........'])
SPECIAL = {
 0x40: ["........", ".22.22..", "2212222.", "2222222.", ".22222..", "..222...", "...2....", "........"],  # corazon
 0x41: ["11111111"] * 8, 0x42: ["22222222"] * 8, 0x43: ["33333333"] * 8,
 0x44: ["33333333", "32323232", "33333333", "23232323", "22222222", "32323232", "22222222", "22222222"],
 0x45: ["22222222", "21212121", "22222222", "12121212", "11111111", "21212121", "11111111", "11111111"],
 0x46: ["........", "33333333", "33333333", "33333333", "33333333", "33333333", "33333333", "........"],  # barra
 0x47: ["...3....", "...3....", "..333...", "3333333.", ".33333..", ".33.33..", "33...33.", "........"],  # estrella
 0x48: ["...1....", "...1....", "..1.1...", "111.111.", ".1...1..", ".1.1.1..", "11...11.", "........"],  # estrella vacia
 0x49: ["33333333", "33333333", "........", "........", "33333333", "33333333", "........", "........"],  # rayas sol
 0x4A: ["22222222", "22222222", "........", "........", "22222222", "22222222", "........", "........"],
 0x4B: ["11111111", "11111111", "........", "........", "11111111", "11111111", "........", "........"],
}
for k, v in SPECIAL.items(): put(k // 64, k % 64, v)

# ---------------------------------------------------------------- tilesets de nivel
def tset(style):
    t = {}
    if style == 'A':
        t['GTOP'] = ["33333333", "33333333", "11111111", "22122212", "22222222", "21222122", "22222222", "22212222"]
        t['GSUB'] = ["22222222", "22212222", "12222221", "22222222", "22222122", "22122222", "22222222", "21222212"]
        t['G1'] = ["22222222", "22212222", "22222222", "12222222", "22222122", "22222222", "22122222", "22222222"]
        t['G2'] = ["22222122", "22222222", "21222222", "22222222", "22212222", "22222221", "22222222", "12222222"]
        t['PLAT'] = ["11111111", "33223322", "33223322", "33223322", "32332332", "11111111", ".1....1.", ".1....1."]
        t['ROOF1'] = ["...33...", "..3113..", "33333333", "31111113", "11111111", "13131311", "11111111", "11111111"]
        t['WALL1'] = ["11111111", "11111111", "11111111", "33333333", "11111111", "11111111", "11111111", "11111111"]
        t['WIN1A'] = ["11111111", "11222111", "12222211", "12322211", "12222211", "13333311", "11111111", "11111111"]
        t['WIN1B'] = ["11111111", "11333111", "13333311", "13333311", "13333311", "13333311", "11111111", "11111111"]
        t['ROOF2'] = ["33333333", "31313131", "33333333", "11111111", "11111111", "11111111", "11111111", "11111111"]
        t['WALL2'] = ["11111111", "11111111", "11111111", "11111111", "11111111", "11111111", "33333333", "33333333"]
        t['WIN2A'] = ["11111111", "12222221", "12222221", "12222221", "33333333", "13131313", "11111111", "11111111"]
        t['WIN2B'] = ["11111111", "13333331", "13222231", "13222231", "33333333", "13131313", "11111111", "11111111"]
    else:
        t['GTOP'] = ["33333333", "11111111", "22222222", "22222222", "33332222", "22222222", "22222222", "22222222"]
        t['GSUB'] = ["22222222", "22222222", "22222222", "22222222", "22222222", "22222222", "11111111", "22222222"]
        t['G1'] = ["22212221", "22212221", "11111111", "21222122", "21222122", "11111111", "22212221", "22212221"]
        t['G2'] = ["22212221", "22212221", "11111111", "21222122", "21212122", "11111111", "22212221", "22212221"]
        t['PLAT'] = ["33333333", "31.3.3.3", "3.3.3.31", "33333333", "1......1", "........", "........", "........"]
        t['ROOF1'] = ["...33...", "...11...", "33333333", "31111113", "11111111", "11111111", "11111111", "11111111"]
        t['WALL1'] = ["31111111", "31111111", "31111111", "31111111", "31111111", "31111111", "31111111", "31111111"]
        t['WIN1A'] = ["11111111", "12211221", "12211221", "12211221", "11111111", "11111111", "13311331", "11111111"]
        t['WIN1B'] = ["11111111", "11111221", "11111221", "11111221", "11111111", "11111111", "13311331", "11111111"]
        t['ROOF2'] = ["33333333", "33333333", "11111111", "13131313", "11111111", "11111111", "11111111", "11111111"]
        t['WALL2'] = ["11131113", "11131113", "33333333", "13111311", "13111311", "33333333", "11131113", "11131113"]
        t['WIN2A'] = ["11111111", "12222221", "12121221", "12222221", "12121221", "12222221", "11111111", "11111111"]
        t['WIN2B'] = ["11111111", "11111111", "11111111", "11111111", "11111111", "11111111", "11111111", "11111111"]
    if style == 'A':  # palmera
        t['P_TL'] = ["........", "...22...", ".222222.", "2222222.", "22...222", "2.....22", "......22", "......1."]
        t['P_TR'] = ["........", "...22...", ".222222.", ".2222222", "222...22", "22.....2", "22......", ".1......"]
        t['P_BL'] = [".....22.", "....2.11", "...2..11", "......11", "......11", ".......1", ".......1", ".......1"]
        t['P_BR'] = [".22.....", "11.2....", "11..2...", "1.......", "1.......", "1.......", "1.......", "1......."]
        t['TR_L'] = [".......1", ".......1", ".......1", "......11", "......11", "......11", "......11", "......11"]
        t['TR_R'] = ["1.......", "1.......", "1.......", "1.......", "1.......", "1.......", "11......", "11......"]
    else:              # farol
        t['P_TL'] = ["........", "........", ".....111", "....1222", "....1222", ".....111", "......1.", "......1."]
        t['P_TR'] = ["........", "........", "111.....", "2221....", "2221....", "111.....", ".1......", "1......."]
        t['P_BL'] = [".......1", ".......1", ".......1", ".......1", ".......1", ".......1", ".......1", ".......1"]
        t['P_BR'] = ["........"] * 8
        t['TR_L'] = [".......1", ".......1", ".......1", ".......1", ".......1", ".......1", "......11", ".....111"]
        t['TR_R'] = ["........"] * 6 + ["........", "1......."]
    return t

ORDER = ['GTOP', 'GSUB', 'G1', 'G2', 'PLAT', 'WTOP', 'WATER', 'ROOF1', 'WALL1', 'WIN1A', 'WIN1B',
         'ROOF2', 'WALL2', 'WIN2A', 'WIN2B', 'P_TL', 'P_TR', 'P_BL', 'P_BR', 'TR_L', 'TR_R']
def water_frames(k):
    top = []; body = []
    for y in range(8):
        r1 = ''; r2 = ''
        for x in range(8):
            w = math.sin((x + k * 2) * math.pi / 4 + y * 0.9)
            r1 += ('.' if y < 2 and w < 0.2 else '3') if y < 3 else ('1' if w > 0.75 else '3')
            r2 += '1' if (math.sin((x + k * 2) * math.pi / 4 + y * 1.3) > 0.8) else '3'
        top.append(r1); body.append(r2)
    return top, body

# banda lejana (6 filas x 16 tiles, se repite)
def farband(style, seed):
    R = random.Random(seed)
    W, H = 128, 48
    img = [[0] * W for _ in range(H)]
    # nubes (c3)
    for _ in range(5):
        cx, cy = R.randint(0, W), R.randint(4, 18)
        for k in range(5):
            ex, ey = cx + R.randint(-10, 10), cy + R.randint(-2, 3)
            rx, ry = R.randint(5, 9), R.randint(2, 4)
            for y in range(ey - ry, ey + ry + 1):
                for x in range(ex - rx, ex + rx + 1):
                    if ((x - ex) / rx) ** 2 + ((y - ey) / ry) ** 2 <= 1 and 0 <= y < H:
                        img[y][x % W] = 3
    # silueta lejana (c1) con luces (c2)
    x = 0
    while x < W:
        w = R.randint(5, 12); h = R.randint(8, 22) if style == 'B' else R.randint(5, 16)
        for xx in range(x, min(W, x + w)):
            for y in range(H - h, H):
                img[y][xx] = 1
        if style == 'A' and R.random() < 0.5:   # palmera lejana
            px = x + w // 2
            for y in range(H - h - 8, H - h): img[y][px % W] = 1
            for d in range(-3, 4): img[H - h - 8 + abs(d) // 2][(px + d) % W] = 2
        for k in range(R.randint(1, 4)):
            lx, ly = x + R.randint(1, max(1, w - 2)), H - R.randint(2, max(3, h - 2))
            if 0 <= ly < H: img[ly][lx % W] = 2
        x += w + R.randint(0, 3)
    if style == 'B':  # gruas
        for gx in (30, 95):
            for y in range(10, H): img[y][gx] = 1
            for xx in range(gx - 12, gx + 8): img[10][xx % W] = 1
    tiles = []; tmap = []
    for ty in range(6):
        row = []
        for tx in range(16):
            t = tuple(''.join('.' if img[ty * 8 + y][tx * 8 + x] == 0 else str(img[ty * 8 + y][tx * 8 + x])
                              for x in range(8)) for y in range(8))
            if t not in tiles: tiles.append(t)
            row.append(tiles.index(t))
        tmap.append(row)
    return tiles, tmap

FAR_BASE = 32   # tiles $A0+
farmaps = {}
for style, base in (('A', 16), ('B', 24)):
    t = tset(style)
    ftiles, fmap = farband(style, 11 if style == 'A' else 12)
    assert len(ftiles) <= 96, len(ftiles)
    farmaps[style] = fmap
    for k in range(4):
        wt, wb = water_frames(k)
        t['WTOP'] = wt; t['WATER'] = wb
        unit = base + 2 * k
        for i, name in enumerate(ORDER):
            put(unit + i // 64, i % 64, t[name])
        for i, ft in enumerate(ftiles):
            n = FAR_BASE + i
            put(unit + n // 64, n % 64, list(ft))
TI = {name: 0x80 + i for i, name in enumerate(ORDER)}

# ---------------------------------------------------------------- tileset del banco (unidades 6-7)
BANKT = {
 'SKY':   ["........"] * 8,
 'STAR':  ["........", "........", "....3...", "........", "........", "........", "........", "........"],
 'CORN':  ["33333333", "22222222", "11111111", "31313131", "33333333", "22222222", "22222222", "11111111"],
 'PED':   ["33333333", "32222223", "32222223", "33333333", "22222222", "22222222", "22222222", "22222222"],
 'COLT':  ["33333333", ".322223.", "..3223..", "..3223..", "..3223..", "..3223..", "..3223..", "..3223.."],
 'COL':   ["..3223..", "..3223..", "..3213..", "..3223..", "..3223..", "..3213..", "..3223..", "..3223.."],
 'WALL':  ["22222222", "22212222", "22212222", "11111111", "22222221", "22222221", "22222221", "11111111"],
 'WINT':  ["22222222", "21111112", "21222212", "21212212", "21222212", "21212212", "21222212", "21212212"],
 'WINB':  ["21222212", "21212212", "21222212", "21111112", "33333333", "22222222", "22222222", "22222222"],
 'DOORL': ["11111111", "13333333", "13222222", "13222222", "13222222", "13222222", "13222222", "13222222"],
 'DOORR': ["11111111", "33333331", "22222231", "22222231", "22222231", "22222231", "22222231", "22222231"],
 'STEP':  ["33333333", "22222222", "22222222", "11111111", "33333333", "22222222", "22222222", "11111111"],
 'WALK':  ["33333333", "22222222", "22212222", "22222222", "22222222", "22222212", "22222222", "11111111"],
 'ROAD':  ["11111111", "11111111", "11111111", "11111111", "11111111", "11111111", "11111111", "11111111"],
 'LINE':  ["11111111", "11111111", "11111111", "33333311", "33333311", "11111111", "11111111", "11111111"],
 'SIGN':  ["33333333", "3......3", "3......3", "3......3", "3......3", "3......3", "3......3", "33333333"],
 'SIGNL': ["33333333", "3.......", "3.......", "3.......", "3.......", "3.......", "3.......", "33333333"],
 'SIGNR': ["33333333", ".......3", ".......3", ".......3", ".......3", ".......3", ".......3", "33333333"],
 'SIGNM': ["33333333", "........", "........", "........", "........", "........", "........", "33333333"],
}
BKORDER = list(BANKT.keys())
for i, k in enumerate(BKORDER): put(6, i, BANKT[k])
BK = {k: 0x80 + i for i, k in enumerate(BKORDER)}
# mapa del banco 32x30
R = random.Random(4)
bank_nt = [[0] * 32 for _ in range(30)]
for y in range(0, 6):
    for x in range(32):
        bank_nt[y][x] = BK['STAR'] if R.random() < 0.12 else BK['SKY']
for x in range(3, 29):
    bank_nt[6][x] = BK['PED']; bank_nt[7][x] = BK['CORN']
for x in range(5, 27): bank_nt[5][x] = BK['PED']
# letrero BANCO DE NICE CITY en fila 9 (fuente)
sign = "BANCO DE NICE CITY"
sx = 16 - len(sign) // 2
for x in range(3, 29):
    bank_nt[8][x] = BK['SIGNM']; bank_nt[10][x] = BK['SIGNM']
    bank_nt[9][x] = BK['WALL']
bank_nt[8][3] = BK['SIGNL']; bank_nt[8][28] = BK['SIGNR']; bank_nt[10][3] = BK['SIGNL']; bank_nt[10][28] = BK['SIGNR']
for i, ch in enumerate(sign): bank_nt[9][sx + i] = ord(ch) - 32
for y in range(9, 10):
    for x in range(3, 29):
        if bank_nt[y][x] == BK['WALL']: bank_nt[y][x] = 0
for y in range(11, 22):
    for x in range(3, 29):
        bank_nt[y][x] = BK['WALL']
for cx in (5, 9, 22, 26):
    bank_nt[11][cx] = BK['COLT']
    for y in range(12, 22): bank_nt[y][cx] = BK['COL']
for wx in (7, 24):
    for y in (13, 17):
        bank_nt[y][wx] = BK['WINT']; bank_nt[y + 1][wx] = BK['WINB']
for y in range(15, 22):
    for x in range(13, 19):
        bank_nt[y][x] = BK['DOORL'] if x < 16 else BK['DOORR']
        if y > 15: bank_nt[y][x] = BK['DOORL'] if x == 13 else BK['DOORR'] if x == 18 else BK['ROAD']
for x in range(1, 31): bank_nt[22][x] = BK['STEP']; bank_nt[23][x] = BK['STEP']
for x in range(32): bank_nt[24][x] = BK['WALK']; bank_nt[25][x] = BK['WALK']
for y in range(26, 30):
    for x in range(32):
        bank_nt[y][x] = BK['LINE'] if (y == 27 and x % 4 < 2) else BK['ROAD']
bank_attr = [0] * 64
for ay in range(8):
    for ax in range(8):
        v = 0
        for q, (dx, dy) in enumerate(((0, 0), (1, 0), (0, 1), (1, 1))):
            ty = ay * 4 + dy * 2; tx = ax * 4 + dx * 2
            pal = 0
            if ty < 4: pal = 3
            if ty >= 24: pal = 1
            if ty in (8, 10) and 3 <= tx < 29: pal = 3
            v |= pal << (q * 2)
        bank_attr[ay * 8 + ax] = v

# ---------------------------------------------------------------- sprites
def frames_tiles(frames, w, h):
    out = []
    for cv in frames: out += to_tiles(cv, w, h)
    return out
put_tiles(32, 0, frames_tiles(char_frames('jose'), 2, 4))       # 32-33
put_tiles(34, 0, frames_tiles(char_frames('luciana'), 2, 4))    # 34-35
put_tiles(37, 0, frames_tiles(enemy_frames('cop'), 2, 4))       # 37
put_tiles(38, 0, frames_tiles(enemy_frames('soldier'), 2, 4))   # 38
# vehiculos (36) -> sprite tiles $40+
vt = to_tiles(moto(0), 4, 2) + to_tiles(moto(1.2), 4, 2) + to_tiles(luxury_car(0), 6, 2) + to_tiles(luxury_car(1.2), 6, 2) + to_tiles(police_car(), 6, 2)
assert len(vt) <= 64
put_tiles(36, 0, vt)
V_MOTO, V_CAR, V_POL = 0x40, 0x40 + 16, 0x40 + 40
# misc (39) -> $C0+
misc = to_tiles(heli_body(), 6, 2) + to_tiles(heli_rotor(0), 6, 1) + to_tiles(heli_rotor(1), 6, 1)
M_HELI = 0xC0; M_ROTOR = 0xC0 + 12
for k in range(3): misc += to_tiles(explosion(k), 2, 2)
M_EXPL = 0xC0 + 24
M_PB = 0xC0 + len(misc); misc.append(["........", "........", "..2222..", ".233332.", ".233332.", "..2222..", "........", "........"])
M_EB = 0xC0 + len(misc); misc.append(["........", "...33...", "..3223..", ".322223.", ".322223.", "..3223..", "...33...", "........"])
M_FLASH = 0xC0 + len(misc); misc.append(["........", "..2.....", "...2.2..", "22223333", "..2.2...", "...2....", "........", "........"])
M_SIREN = 0xC0 + len(misc); misc.append(["........", "........", "..1111..", ".133331.", ".133331.", "11111111", "........", "........"])
M_ARROW = 0xC0 + len(misc); misc.append(["..2222..", "..2222..", "..2222..", "22222222", ".222222.", "..2222..", "...22...", "........"])
bag = Canvas(16, 16)
bag.ellipse(8, 10, 6, 5, 2); bag.rect(6, 2, 10, 5, 2); bag.line(5, 5, 11, 5, 1)
bag.line(6, 1, 10, 1, 2)
for (x, y) in ((8, 7), (7, 8), (8, 9), (9, 10), (8, 11), (7, 12), (8, 13), (8, 6), (8, 14)): bag.set(x, y, 1)
bag.outline(1)
M_BAG = 0xC0 + len(misc); misc += to_tiles(bag, 2, 2)
dust = Canvas(16, 8)
for x, y, r in ((4, 5, 2.5), (9, 4, 3), (13, 6, 2)): dust.ellipse(x, y, r, r * .8, 2)
M_DUST = 0xC0 + len(misc); misc += to_tiles(dust, 2, 1)
AB = Canvas(16, 8)
M_AB = 0xC0 + len(misc)
misc.append(["22222222", "21122222", "12212222", "11112222", "12212222", "12212222", "22222222", "........"])  # A
misc.append(["22222222", "11122222", "12212222", "11122222", "12212222", "11122222", "22222222", "........"])  # B
assert len(misc) <= 64, len(misc)
put_tiles(39, 0, misc)
open('chr2.bin', 'wb').write(CHR)

# ---------------------------------------------------------------- niveles
NAMES = ["PLAYA VICE", "CALLE OCHO", "PUERTO DEL SOL", "LOS CAYOS", "AUTOPISTA 95",
         "LOS PANTANOS", "DISTRITO ART DECO", "AEROPUERTO", "CENTRO NOCTURNO", "LA MANSION"]
# bg, edif(3), suelo(3), lejano(3), tileset
LP = [
 (0x21, 0x35, 0x1C, 0x30, 0x07, 0x37, 0x2C, 0x13, 0x2A, 0x30, 'A'),
 (0x22, 0x27, 0x17, 0x38, 0x00, 0x10, 0x2A, 0x02, 0x29, 0x30, 'A'),
 (0x26, 0x13, 0x0F, 0x25, 0x0F, 0x00, 0x2C, 0x04, 0x28, 0x36, 'B'),
 (0x31, 0x3A, 0x1A, 0x30, 0x07, 0x37, 0x2C, 0x1B, 0x2A, 0x30, 'A'),
 (0x14, 0x04, 0x28, 0x13, 0x0F, 0x00, 0x28, 0x03, 0x28, 0x24, 'B'),
 (0x3B, 0x1A, 0x0A, 0x29, 0x0A, 0x19, 0x2C, 0x09, 0x2A, 0x30, 'A'),
 (0x34, 0x2C, 0x1C, 0x30, 0x07, 0x37, 0x2C, 0x14, 0x2A, 0x30, 'A'),
 (0x11, 0x10, 0x00, 0x30, 0x0F, 0x00, 0x30, 0x01, 0x28, 0x31, 'B'),
 (0x0F, 0x02, 0x28, 0x12, 0x0F, 0x00, 0x24, 0x01, 0x28, 0x13, 'B'),
 (0x01, 0x13, 0x0F, 0x25, 0x0F, 0x03, 0x24, 0x0F, 0x2A, 0x12, 'A'),
]
FACTION_PAL = [[0x0F, 0x27, 0x12], [0x0F, 0x27, 0x1A]]
def level_palette(i):
    bg, b1, b2, b3, g1, g2, g3, f1, f2, f3, _ = LP[i]
    fp = FACTION_PAL[1 if i >= 5 else 0]
    return [bg, b1, b2, b3, bg, g1, g2, g3, bg, f1, f2, f3, bg, 0x30, 0x16, 0x28,
            bg, 0x0F, 0x27, 0x2A, bg, 0x0F, 0x27, 0x18, bg] + fp + [bg, 0x0F, 0x30, 0x16]

L = 160
def gy(h): return 224 - 16 * h
def gen_level(n):
    R = random.Random(919 + n * 71)
    h = [2] * L; p = [0] * L
    i = 18; cur = 2; end = L - 22
    pit_prob = 0.14 + 0.015 * n
    while i < end:
        r = R.random()
        if r < pit_prob and i + 8 < end:
            w = 2 if R.random() < 0.35 + 0.05 * n else 1
            for k in range(w): h[i + k] = 0
            if w == 2 and R.random() < 0.3:
                for k in range(-1, 3): p[i + k] = min(6, cur + 2)
            i += w
            if cur > 1 and R.random() < 0.3: cur -= 1
            for k in range(R.randint(5, 8)):
                if i < end: h[i] = cur; i += 1
        elif r < pit_prob + 0.28:
            cur = max(1, min(4, cur + R.choice([-1, 1])))
            for k in range(R.randint(6, 11)):
                if i < end: h[i] = cur; i += 1
        else:
            st = i; seg = R.randint(8, 14)
            for k in range(seg):
                if i < end: h[i] = cur; i += 1
            if R.random() < 0.55 and i - st > 7:
                pl = R.randint(3, 5); off = R.randint(1, max(1, (i - st) - pl - 1))
                ph = min(6, cur + R.choice([2, 3]))
                for k in range(pl):
                    c = st + off + k
                    if c < i: p[c] = ph
    while i < L:
        if cur > 2: cur -= 1
        elif cur < 2: cur += 1
        for k in range(2):
            if i < L: h[i] = cur; i += 1
    for c in range(L - 18, L): h[c] = 2; p[c] = 0
    sp = []
    def flat(c, w):
        return all(0 <= c + k < L and h[c + k] == h[c] and h[c] > 0 and p[c + k] == 0 for k in range(w))
    used = set()
    # vehiculos estacionados: moto / auto de lujo alternados
    c = 8; kind = 3
    while c < L - 24:
        cc = c
        w = 2 if kind == 3 else 3
        while cc < L - 22 and not flat(cc - 1, w + 2): cc += 1
        if cc >= L - 22: break
        sp.append((cc, kind, gy(h[cc]) - 16)); used.update(range(cc - 2, cc + w + 2))
        kind = 6 if kind == 3 else 3
        c = cc + R.randint(20, 28)
    # patrulleros
    npol = 1 + n // 2
    cands = [c for c in range(30, L - 30) if flat(c, 4) and c not in used]
    R.shuffle(cands)
    pc = sorted(cands[:npol + 1])
    last = -99
    for c in pc:
        if c - last > 14:
            sp.append((c, 7, gy(h[c]) - 16)); last = c
    # policias que corren
    c = 22
    lo_, hi_ = max(3, 7 - n // 2), max(6, 11 - n // 2)
    while c < L - 22:
        if h[c] > 0 and c not in used and p[c] == 0:
            sp.append((c, 1, gy(h[c]) - 32))
        c += R.randint(lo_, hi_)
    # tiradores agachados en plataformas y suelo
    c = 18
    while c < L - 22:
        if p[c] and p[c - 1] == 0:
            run = 0
            while p[c + run]: run += 1
            if R.random() < 0.6 + 0.03 * n:
                sp.append((c + run // 2, 2, gy(p[c]) - 32))
            c += run
        c += 1
    c = 34
    while c < L - 24:
        if h[c] > 0 and c not in used and R.random() < 0.18 + 0.03 * n:
            sp.append((c, 2, gy(h[c]) - 32)); c += 12
        c += 3
    # bolsas de dinero
    for c in range(25, L - 25, 31):
        cc = c
        while h[cc] == 0: cc += 1
        y = gy(p[cc]) - 40 if p[cc] else gy(h[cc]) - 40
        sp.append((cc, 9, y))
    sp.sort()
    cols = [(h[c] & 15) | ((p[c] & 15) << 4) for c in range(L)]
    return cols, sp

def byterows(data, per=16):
    return '\n'.join('    .byte ' + ','.join('$%02X' % (b & 0xFF) for b in data[i:i + per]) for i in range(0, len(data), per))

lv = ['; ---- banco 0: niveles ----']
for i in range(10):
    cols, sp = gen_level(i)
    lv.append('lvl%d_cols:' % i); lv.append(byterows(cols))
    lv.append('lvl%d_spawn:' % i)
    fl = []
    for c, t, y in sp: fl += [c, t, y]
    lv.append(byterows(fl + [0xFF], 15))
for st in ('A', 'B'):
    lv.append('far_%s:' % st)
    flat_ = []
    for row in farmaps[st]: flat_ += [FAR_BASE + 0x80 + v for v in row]
    lv.append(byterows(flat_))
lv.append('bank_nt:'); lv.append(byterows(sum(bank_nt, [])))
lv.append('bank_at:'); lv.append(byterows(bank_attr))
open('levels2.asm', 'w').write('\n'.join(lv) + '\n')

# ---------------------------------------------------------------- tablas para el banco fijo
d = []
consts = dict(V_MOTO=V_MOTO, V_CAR=V_CAR, V_POL=V_POL, M_HELI=M_HELI, M_ROTOR=M_ROTOR, M_EXPL=M_EXPL, M_PB=M_PB,
              M_EB=M_EB, M_FLASH=M_FLASH, M_SIREN=M_SIREN, M_ARROW=M_ARROW, M_BAG=M_BAG, M_DUST=M_DUST, M_AB=M_AB,
              LEVEL_LEN=L, FAR_TILE=FAR_BASE + 0x80)
for k, v in consts.items(): d.append('%s = %d' % (k, v))
for k, v in TI.items(): d.append('T_%s = $%02X' % (k, v))
d.append('level_tbl:')
for i in range(10):
    st = LP[i][10]
    d.append('    .word lvl%d_cols\n    .byte LEVEL_LEN\n    .word lvl%d_spawn\n    .byte %d\n    .word pal_lvl%d\n    .byte %d\n    .word far_%s\n    .byte %d, 0, 0, 0, 0'
             % (i, i, 16 if st == 'A' else 24, i, 1 if i >= 5 else 0, st, min(5, 1 + i // 2)))
for i in range(10):
    d.append('pal_lvl%d:' % i); d.append(byterows(level_palette(i)))
# skyline: valores de fila del techo; huecos de 2-4 alineados a columnas pares
R = random.Random(8)
sk = []
while len(sk) < 32:
    w = R.choice([4, 6, 6, 8]); top = R.randint(10, 19)
    sty = R.randint(0, 1)
    sk += [top | (sty << 7)] * w
    sk += [30] * R.choice([2, 2, 4])
sk = sk[:32]
if sk[31] != 30: sk[30] = sk[31] = 30
d.append('skyline:'); d.append(byterows(sk))
d.append('name_tbl:'); d.append('    .word ' + ','.join('name%d' % i for i in range(10)))
for i, nm in enumerate(NAMES):
    d.append('name%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 14 * 32 + (32 - len(nm)) // 2, nm))
ROWTILE = [0x43, 0x43, 0x44, 0x42, 0x45, 0x41, 0x41]
d.append('logo_strs:')
for ry in range(7):
    row = []
    for li, ch in enumerate("GTA6"):
        row += [ROWTILE[ry] if c == '#' else 0 for c in FONT[ch][ry]]
        if li < 3: row.append(0)
    d.append('    .strb $%04X, %s' % (0x2000 + (4 + ry) * 32 + 4, ','.join('$%02X' % b for b in row)))
d.append('    .byte 0')
d.append('sun_strs:')
for i, (w, t) in enumerate([(6, 0x43), (10, 0x49), (12, 0x44), (14, 0x4A), (14, 0x45), (16, 0x4B)]):
    d.append('    .strb $%04X, %s' % (0x2000 + (14 + i) * 32 + 16 - w // 2, ','.join(['$%02X' % t] * w)))
d.append('    .byte 0')
lo, hi = [], []
for m in range(36, 96):
    f = 440.0 * 2 ** ((m - 69) / 12)
    per = max(8, min(0x7FF, round(1789773 / (16 * f)) - 1))
    lo.append(per & 0xFF); hi.append(per >> 8)
d.append('note_lo:\n    .byte 0'); d.append(byterows(lo))
d.append('note_hi:\n    .byte 0'); d.append(byterows(hi))
open('data2.asm', 'w').write('\n'.join(d) + '\n')

# ---------------------------------------------------------------- musica
NOTE = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
def midi(s): return 12 * (int(s[-1]) + 1) + NOTE[s[0]] + (1 if '#' in s else 0)
def stream(notes, step, tri=False):
    out = []
    for nt in notes:
        if nt == '.':
            if len(out) >= 2 and out[-2] == 0 and out[-1] + step < 250: out[-1] += step
            else: out += [0, step]
        elif nt == '-':
            if out[-1] + step < 250: out[-1] += step
            else: out += [out[-2], step]
        else:
            out += [midi(nt) + (12 if tri else 0) - 35, step]
    return out + [0xFF]
def drums(pat, bars, step):
    out = []
    m = {'K': 1, 'S': 2, 'H': 3, '.': 0}
    for _ in range(bars):
        for ch in pat: out += [m[ch], step]
    return out + [0xFF]
def octbass(roots, per_root=8):
    out = []
    for r in roots:
        hi_ = r[:-1] + str(int(r[-1]) + 1)
        out += [r, hi_] * (per_root // 2)
    return out
tracks = {}
# 0: titulo / escena (lento, misterioso)
mel0 = """D5 - A4 - F4 . A4 D5  C5 - A4 - F4 . E4 F4  D5 - A#4 - F4 . A#4 D5  C5 - . E5 D5 C5 A4 .
F5 - E5 - D5 . C5 A4  C5 - A#4 - A4 . G4 A4  F4 - . A4 C5 - D5 .  E5 - . D5 C#5 - . .""".split()
tracks[0] = (stream(mel0, 14), stream(octbass(['D2', 'F2', 'A#1', 'C2', 'D2', 'F2', 'A#1', 'A1']), 14, True),
             drums('K.H.S.H.', 8, 14))
# 1: juego (persecucion synthwave)
mel1 = """A4 . C5 E5 D5 C5 B4 C5  A4 . C5 F5 E5 C5 A4 C5  G4 . C5 E5 D5 C5 G4 E4  B4 . D5 G5 F5 D5 B4 D5
E5 E5 D5 C5 E5 . A5 .  F5 E5 C5 A4 C5 . F5 .  E5 D5 C5 G4 C5 . E5 G5  D5 . B4 G4 B4 D5 G5 .
A5 - G5 E5 - D5 E5 .  F5 - E5 C5 - A4 C5 .  G5 - E5 C5 - G4 C5 E5  D5 - B4 G4 - D5 G5 B5""".split()
tracks[1] = (stream(mel1, 10), stream(octbass(['A2', 'F2', 'C3', 'G2'] * 3), 10, True),
             drums('K.HSKKSH', 12, 10))
# 2: jefe
mel2 = """E5 E5 G5 E5 A5 E5 B5 A5  G5 E5 D5 E5 G5 . F#5 .  E5 E5 G5 E5 A5 E5 B5 A5  C6 B5 A5 G5 F#5 . D#5 .""".split()
tracks[2] = (stream(mel2, 8), stream(['E2', 'E3'] * 12 + ['C2', 'C3', 'C2', 'C3', 'B1', 'B2', 'B1', 'B2'], 8, True),
             drums('KHSHKKSH', 4, 8))
mu = ['; ---- musica ----']
for k, (a, b, c) in tracks.items():
    mu += ['trk%d_p:' % k, byterows(a), 'trk%d_t:' % k, byterows(b), 'trk%d_n:' % k, byterows(c)]
mu.append('track_tbl:')
mu.append('    .word ' + ','.join('trk%d_p,trk%d_t,trk%d_n' % (k, k, k) for k in range(3)))
open('music2.asm', 'w').write('\n'.join(mu) + '\n')
print('ok', len(misc), 'misc tiles; far tiles', [len(farband(s, 11 if s == 'A' else 12)[0]) for s in 'AB'])
