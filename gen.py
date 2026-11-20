#!/usr/bin/env python3
"""Genera CHR (graficos), datos de niveles, paletas, textos y musica para GTA6 NES."""
import random

# ------------------------------------------------------------------ CHR helpers
CHR = bytearray(16 * 1024)

def tile_bytes(rows):
    rows = [(r + '........')[:8] for r in rows] + ['........'] * (8 - len(rows))
    p0, p1 = [], []
    for r in rows:
        b0 = b1 = 0
        for i, ch in enumerate(r):
            v = 0 if ch in '. ' else int(ch)
            b0 |= (v & 1) << (7 - i)
            b1 |= ((v >> 1) & 1) << (7 - i)
        p0.append(b0); p1.append(b1)
    return bytes(p0 + p1)

def put_tile(unit, idx, rows):
    off = unit * 1024 + idx * 16
    CHR[off:off + 16] = tile_bytes(rows)

def put_sprite_grid(unit_base, first, rows, w, h):
    """rows: lista de strings (w*8 de ancho, h*8 de alto). Tiles en orden fila-mayor."""
    rows = [(r + '.' * 64)[:w * 8] for r in rows] + ['.' * (w * 8)] * (h * 8 - len(rows))
    n = first
    for ty in range(h):
        for tx in range(w):
            t = [rows[ty * 8 + y][tx * 8:tx * 8 + 8] for y in range(8)]
            u = unit_base + n // 64
            put_tile(u, n % 64, t)
            n += 1
    return n

# ------------------------------------------------------------------ fuente 5x7
FONT = {
'0': [" ### ","#   #","#  ##","# # #","##  #","#   #"," ### "],
'1': ["  #  "," ##  ","  #  ","  #  ","  #  ","  #  "," ### "],
'2': [" ### ","#   #","    #","   # ","  #  "," #   ","#####"],
'3': ["#####","   # ","  #  ","   # ","    #","#   #"," ### "],
'4': ["   # ","  ## "," # # ","#  # ","#####","   # ","   # "],
'5': ["#####","#    ","#### ","    #","    #","#   #"," ### "],
'6': ["  ## "," #   ","#    ","#### ","#   #","#   #"," ### "],
'7': ["#####","    #","   # ","  #  "," #   "," #   "," #   "],
'8': [" ### ","#   #","#   #"," ### ","#   #","#   #"," ### "],
'9': [" ### ","#   #","#   #"," ####","    #","   # "," ##  "],
'A': [" ### ","#   #","#   #","#####","#   #","#   #","#   #"],
'B': ["#### ","#   #","#   #","#### ","#   #","#   #","#### "],
'C': [" ### ","#   #","#    ","#    ","#    ","#   #"," ### "],
'D': ["#### ","#   #","#   #","#   #","#   #","#   #","#### "],
'E': ["#####","#    ","#    ","#### ","#    ","#    ","#####"],
'F': ["#####","#    ","#    ","#### ","#    ","#    ","#    "],
'G': [" ### ","#   #","#    ","# ###","#   #","#   #"," ####"],
'H': ["#   #","#   #","#   #","#####","#   #","#   #","#   #"],
'I': [" ### ","  #  ","  #  ","  #  ","  #  ","  #  "," ### "],
'J': ["  ###","   # ","   # ","   # ","   # ","#  # "," ##  "],
'K': ["#   #","#  # ","# #  ","##   ","# #  ","#  # ","#   #"],
'L': ["#    ","#    ","#    ","#    ","#    ","#    ","#####"],
'M': ["#   #","## ##","# # #","# # #","#   #","#   #","#   #"],
'N': ["#   #","#   #","##  #","# # #","#  ##","#   #","#   #"],
'O': [" ### ","#   #","#   #","#   #","#   #","#   #"," ### "],
'P': ["#### ","#   #","#   #","#### ","#    ","#    ","#    "],
'Q': [" ### ","#   #","#   #","#   #","# # #","#  # "," ## #"],
'R': ["#### ","#   #","#   #","#### ","# #  ","#  # ","#   #"],
'S': [" ####","#    ","#    "," ### ","    #","    #","#### "],
'T': ["#####","  #  ","  #  ","  #  ","  #  ","  #  ","  #  "],
'U': ["#   #","#   #","#   #","#   #","#   #","#   #"," ### "],
'V': ["#   #","#   #","#   #","#   #","#   #"," # # ","  #  "],
'W': ["#   #","#   #","#   #","# # #","# # #","# # #"," # # "],
'X': ["#   #","#   #"," # # ","  #  "," # # ","#   #","#   #"],
'Y': ["#   #","#   #"," # # ","  #  ","  #  ","  #  ","  #  "],
'Z': ["#####","    #","   # ","  #  "," #   ","#    ","#####"],
'!': ["  #  ","  #  ","  #  ","  #  ","  #  ","     ","  #  "],
'.': ["     ","     ","     ","     ","     "," ##  "," ##  "],
',': ["     ","     ","     ","     "," ##  ","  #  "," #   "],
'-': ["     ","     ","     ","#####","     ","     ","     "],
':': ["     "," ##  "," ##  ","     "," ##  "," ##  ","     "],
'?': [" ### ","#   #","    #","   # ","  #  ","     ","  #  "],
"'": ["  #  ","  #  "," #   ","     ","     ","     ","     "],
'/': ["    #","    #","   # ","  #  "," #   ","#    ","#    "],
}

for ch, g in FONT.items():
    rows = ['.' + r.replace('#', '1').replace(' ', '.') + '..' for r in g] + ['........']
    put_tile(0, ord(ch) - 32, rows)

# tiles especiales en pagina de fuente ($40+)
put_tile(1, 0, [".11.11..", "1111111.", "1222221.", "1222221.", ".12221..", "..121...", "...1....", "........"])  # $40 corazon (borde 1, relleno 2)
# correccion: corazon en colores 2 (rojo) con brillo 1
put_tile(1, 0, ["........", ".22.22..", "2212222.", "2222222.", ".22222..", "..222...", "...2....", "........"])
put_tile(1, 1, ["11111111"] * 8)                                   # $41 solido c1
put_tile(1, 2, ["22222222"] * 8)                                   # $42 solido c2
put_tile(1, 3, ["33333333"] * 8)                                   # $43 solido c3
put_tile(1, 4, ["33333333", "32323232", "33333333", "23232323", "22222222", "32323232", "22222222", "22222222"])  # $44 3->2
put_tile(1, 5, ["22222222", "21212121", "22222222", "12121212", "11111111", "21212121", "11111111", "11111111"])  # $45 2->1
put_tile(1, 6, ["........", "33333333", "33333333", "33333333", "33333333", "33333333", "33333333", "........"])  # $46 barra moto

# ------------------------------------------------------------------ tilesets de nivel (R1, tiles $80+)
T = dict(GTOP=0, GFILL=1, PLAT=2, WIN=3, WALL=4, ROOF=5, WATER=6)

TS_A = {  # Playa / art deco (pastel)
 'GTOP':  ["33333333", "33333333", "11111111", "22222222", "22122222", "22222212", "22222222", "21222222"],
 'GFILL': ["22222222", "22212222", "22222222", "12222222", "22222122", "22222222", "22122222", "22222222"],
 'PLAT':  ["11111111", "33223322", "33223322", "33223322", "32332332", "11111111", ".1....1.", ".1....1."],
 'WIN':   ["11111111", "12222211", "12232211", "12222211", "12222211", "13333311", "11111111", "11111111"],
 'WALL':  ["11111111", "11111111", "11111111", "33333333", "11111111", "11111111", "11111111", "11111111"],
 'ROOF':  ["33333333", "33333333", "11111111", "13131311", "11111111", "11111111", "11111111", "11111111"],
 'WATER': ["33333333", "33113333", "31331133", "33333311", "33333333", "33311333", "31133113", "33333333"],
}
TS_B = {  # Ciudad / industrial (noche)
 'GTOP':  ["33333333", "11111111", "22222222", "22222222", "33332222", "22222222", "22222222", "22222222"],
 'GFILL': ["22212221", "22212221", "11111111", "21222122", "21222122", "11111111", "22212221", "22212221"],
 'PLAT':  ["33333333", "31.3.3.3", "3.3.3.31", "33333333", "1......1", "........", "........", "........"],
 'WIN':   ["11111111", "12211221", "12211221", "12211221", "11111111", "11111111", "13311331", "11111111"],
 'WALL':  ["31111111", "31111111", "31111111", "31111111", "31111111", "31111111", "31111111", "31111111"],
 'ROOF':  ["...33...", "...33...", "33333333", "31111113", "11111111", "11111111", "11111111", "11111111"],
 'WATER': ["33333333", "33113333", "31331133", "33333311", "33333333", "33311333", "31133113", "33333333"],
}
for unit, ts in ((2, TS_A), (4, TS_B)):
    for k, i in T.items():
        put_tile(unit, i, ts[k])

# ------------------------------------------------------------------ sprites (unidades 8-11 => $1000)
SPR = 8
HEAD_MAN = [
 "................",
 ".....11111......",
 "....1111111.....",
 "....1122222.....",
 "....2111111.....",
 "....2222222.....",
 ".....22222......",
 "......222.......",
]
TORSO_MAN = [
 "....33333333....",
 "...333133313....",
 "...3133333222111",
 "...3331313...1..",
 "...33333333.....",
 "....3313333.....",
 "....11111111....",
 "....11111111....",
]
HEAD_WOMAN = [
 "................",
 ".....11111......",
 "....1111111.....",
 "...11122222.....",
 "...1121111......",
 "...11222222.....",
 "...111222.......",
 "...111.22.......",
]
TORSO_WOMAN = [
 "...11333333.....",
 "...113333333....",
 "....333333222111",
 "....333333...1..",
 ".....222222.....",
 ".....222222.....",
 "....11111111....",
 "....11111111....",
]
LEGS = {
 'stand': ["....1111.1111...", "....222...222...", "....222...222...", "....222...222...",
           "....222...222...", "....222...222...", "...1111..1111...", "................"],
 'walk1': ["...1111..1111...", "...222....222...", "..222......222..", "..222......222..",
           ".222........222.", ".222........222.", "1111........1111", "................"],
 'walk2': [".....111111.....", "......2222......", "......2222......", ".....222.22.....",
           ".....22..222....", "....222...22....", "....111...111...", "................"],
 'jump':  ["...111111111....", "...222...222....", "..222....222....", "..1111...1111...",
           "................", "................", "................", "................"],
}
def person(head, torso):
    frames = []
    for k in ('stand', 'walk1', 'walk2', 'jump'):
        tor = list(torso)
        if k == 'jump':
            tor = tor[:6] + ["....11111111....", "...111111111...."]
        frames.append(head + tor + LEGS[k])
    return frames

n = 0
for f in person(HEAD_MAN, TORSO_MAN):          # tiles 0-23
    n = put_sprite_grid(SPR, n, f, 2, 3)
for f in person(HEAD_WOMAN, TORSO_WOMAN):      # tiles 24-47
    n = put_sprite_grid(SPR, n, f, 2, 3)
HEAD_THUG = [
 "................",
 ".....33333......",
 "....3333333.....",
 "....3322222.....",
 "....2221221.....",
 "....2222222.....",
 ".....21112......",
 "......222.......",
]
TORSO_THUG = [r.replace('1', '3') for r in TORSO_MAN[:6]] + TORSO_MAN[6:]
TORSO_THUG[2] = "...3233333222111"
th = person(HEAD_THUG, TORSO_THUG)
THUG_TILE = n
for f in (th[1], th[2]):                       # tiles 48-59
    n = put_sprite_grid(SPR, n, f, 2, 3)
MOTO_TILE = n
MOTO = [
 "................................",
 "..........................22....",
 ".........................2.2....",
 "........33333333333.....2.......",
 "......3333333333333333.2........",
 ".....33333333333333333332.......",
 "....222222333333333332222222....",
 "...11111.2222222222222.11111....",
 "..1111111..2222222....1111111...",
 ".111.2.111..1111111..111.2.111..",
 ".11.222.11...........11.222.11..",
 ".111.2.111...........111.2.111..",
 "..1111111.............1111111...",
 "...11111...............11111....",
 "................................",
 "................................",
]
n = put_sprite_grid(SPR, n, MOTO, 4, 2)        # 60-67
BOSS_TILE = n
BOSS = [
 "..11111111111111111111111111....",
 "...............11...............",
 "...............11...............",
 "..........222222222222..........",
 "........2222222222222222........",
 "......22233332222222222222......",
 ".....2223333332222222222222222..",
 "....222333333322222222222222222.",
 "....22222222222222222222222..111",
 "....2222222222222222222222...111",
 ".....222222222222222222.........",
 "......22222222222222222.........",
 ".......222222222222222..........",
 ".11111..1........1..............",
 "11..3....1........1.............",
 ".11111..1111111111111111........",
 "................................",
 "................................",
 "................................",
 "................................",
 "................................",
 "................................",
 "................................",
 "................................",
]
n = put_sprite_grid(SPR, n, BOSS, 4, 3)        # 68-79
EXPL_TILE = n
R = random.Random(3)
ex = []
for y in range(16):
    row = ''
    for x in range(16):
        d = ((x - 7.5) ** 2 + (y - 7.5) ** 2) ** 0.5 + R.uniform(-1.5, 1.5)
        row += '3' if d < 3.5 else '2' if d < 5.5 else '1' if d < 7.2 else '.'
    ex.append(row)
n = put_sprite_grid(SPR, n, ex, 2, 2)          # 80-83
PB_TILE = n
put_tile(SPR + n // 64, n % 64, ["........", "........", "...22...", "..2332..", "..2332..", "...22...", "........", "........"]); n += 1
EB_TILE = n
put_tile(SPR + n // 64, n % 64, ["........", "........", "..333...", ".33333..", ".33333..", "..333...", "........", "........"]); n += 1
ARROW_TILE = n
put_tile(SPR + n // 64, n % 64, ["..2222..", "..2222..", "..2222..", "22222222", ".222222.", "..2222..", "...22...", "........"]); n += 1
assert n < 256

open('chr.bin', 'wb').write(CHR)

# ------------------------------------------------------------------ niveles
NAMES = ["PLAYA VICE", "CALLE OCHO", "PUERTO DEL SOL", "LOS CAYOS", "AUTOPISTA 95",
         "LOS PANTANOS", "DISTRITO ART DECO", "AEROPUERTO", "CENTRO NOCTURNO", "LA MANSION"]
# (bg, edif c1 c2 c3, suelo c1 c2 c3, tileset unit)
LPAL = [
 (0x21, 0x35, 0x1C, 0x30, 0x07, 0x37, 0x2C, 2),
 (0x22, 0x27, 0x17, 0x38, 0x00, 0x10, 0x2A, 2),
 (0x26, 0x13, 0x0F, 0x25, 0x0F, 0x00, 0x2C, 4),
 (0x31, 0x3A, 0x1A, 0x30, 0x07, 0x37, 0x2C, 2),
 (0x14, 0x04, 0x28, 0x13, 0x0F, 0x00, 0x28, 4),
 (0x3B, 0x1A, 0x0A, 0x29, 0x0A, 0x19, 0x2C, 2),
 (0x34, 0x2C, 0x1C, 0x30, 0x07, 0x37, 0x2C, 2),
 (0x11, 0x10, 0x00, 0x30, 0x0F, 0x00, 0x30, 4),
 (0x0F, 0x02, 0x28, 0x12, 0x0F, 0x00, 0x24, 4),
 (0x01, 0x13, 0x0F, 0x25, 0x0F, 0x03, 0x24, 2),
]
def level_palette(i):
    bg, b1, b2, b3, g1, g2, g3, _ = LPAL[i]
    return [bg, b1, b2, b3, bg, g1, g2, g3, bg, 0x30, 0x10, 0x00, bg, 0x30, 0x16, 0x28,
            bg, 0x0F, 0x37, 0x2A, bg, 0x0F, 0x37, 0x16, bg, 0x0F, 0x30, 0x16, bg, 0x0F, 0x10, 0x27]

L = 160
def gy(h): return 224 - 16 * h
def gen_level(n):
    R = random.Random(777 + n * 131)
    h = [2] * L; p = [0] * L
    i = 16; cur = 2; end = L - 22
    pit_prob = 0.16 + 0.015 * n
    while i < end:
        r = R.random()
        if r < pit_prob and i + 8 < end:
            w = 2 if R.random() < 0.35 + 0.05 * n else 1
            for k in range(w): h[i + k] = 0
            if w == 2 and R.random() < 0.3:
                for k in range(-1, 3): p[i + k] = cur + 2
            i += w
            if cur > 1 and R.random() < 0.3: cur -= 1
            for k in range(R.randint(4, 7)):
                if i < end: h[i] = cur; i += 1
        elif r < pit_prob + 0.30:
            cur = max(1, min(4, cur + R.choice([-1, 1])))
            for k in range(R.randint(5, 10)):
                if i < end: h[i] = cur; i += 1
        else:
            st = i; seg = R.randint(7, 12)
            for k in range(seg):
                if i < end: h[i] = cur; i += 1
            if R.random() < 0.6 and i - st > 6:
                pl = R.randint(3, 5); off = R.randint(1, max(1, (i - st) - pl - 1))
                ph = cur + R.choice([2, 3])
                for k in range(pl):
                    c = st + off + k
                    if c < i: p[c] = ph
    while i < L:
        if cur > 2: cur -= 1
        elif cur < 2: cur += 1
        for k in range(2):
            if i < L: h[i] = cur; i += 1
    for c in range(L - 18, L): h[c] = 2; p[c] = 0
    # spawns
    sp = []
    def flat(c, w):
        return all(0 <= c + k < L and h[c + k] == h[c] and h[c] > 0 for k in range(w))
    used = set()
    for tgt in (22, 58, 94, 126):          # motos cada cierto tiempo
        c = tgt
        while not (flat(c, 3) and p[c] == 0 and p[c + 1] == 0):
            c += 1
        sp.append((c, 3, gy(h[c]) - 16)); used.update(range(c - 1, c + 3))
    c = 20
    step_lo = max(3, 7 - n // 2); step_hi = max(6, 12 - n // 2)
    while c < L - 22:
        if h[c] > 0 and c not in used and flat(c, 1):
            sp.append((c, 1, gy(h[c]) - 24))
        c += R.randint(step_lo, step_hi)
    # tiradores en plataformas
    c = 18
    while c < L - 22:
        if p[c] and p[c - 1] == 0:
            run = 0
            while p[c + run]: run += 1
            if R.random() < 0.55 + 0.04 * n:
                sp.append((c + run // 2, 2, gy(p[c]) - 24))
            c += run
        c += 1
    # tiradores en el suelo
    c = 30
    while c < L - 24:
        if h[c] > 0 and c not in used and R.random() < 0.25 + 0.03 * n:
            sp.append((c, 2, gy(h[c]) - 24))
            c += 12
        c += 3
    sp.sort()
    cols = [(h[c] & 15) | ((p[c] & 15) << 4) for c in range(L)]
    return cols, sp

def byterows(data, per=16):
    out = []
    for i in range(0, len(data), per):
        out.append('    .byte ' + ','.join('$%02X' % b for b in data[i:i + per]))
    return '\n'.join(out)

lv = []
lv.append('; ---- datos de niveles (banco 0, $8000) ----')
for i in range(10):
    cols, sp = gen_level(i)
    lv.append('lvl%d_cols:' % i)
    lv.append(byterows(cols))
    lv.append('lvl%d_spawn:' % i)
    flat_sp = []
    for c, t, y in sp: flat_sp += [c, t, y]
    flat_sp.append(0xFF)
    lv.append(byterows(flat_sp, 15))
open('levels.asm', 'w').write('\n'.join(lv) + '\n')

# ------------------------------------------------------------------ datos en banco fijo
d = []
d.append('THUG_TILE = %d\nMOTO_TILE = %d\nBOSS_TILE = %d\nEXPL_TILE = %d\nPB_TILE = %d\nEB_TILE = %d\nARROW_TILE = %d'
         % (THUG_TILE, MOTO_TILE, BOSS_TILE, EXPL_TILE, PB_TILE, EB_TILE, ARROW_TILE))
d.append('T_GTOP = $80\nT_GFILL = $81\nT_PLAT = $82\nT_WIN = $83\nT_WALL = $84\nT_ROOF = $85\nT_WATER = $86')
d.append('LEVEL_LEN = %d' % L)
d.append('level_tbl:')
for i in range(10):
    d.append('    .word lvl%d_cols\n    .byte LEVEL_LEN\n    .word lvl%d_spawn\n    .byte %d\n    .word pal_lvl%d' % (i, i, LPAL[i][7], i))
for i in range(10):
    d.append('pal_lvl%d:' % i)
    d.append(byterows(level_palette(i)))
R = random.Random(5)
sk = []
while len(sk) < 32:
    w = R.randint(3, 6); top = R.randint(9, 19)
    sk += [top] * w + [30] * R.randint(1, 2)
d.append('skyline:')
d.append(byterows(sk[:32]))
# nombres de nivel centrados en fila 15
d.append('name_tbl:')
d.append('    .word ' + ','.join('name%d' % i for i in range(10)))
for i, nm in enumerate(NAMES):
    col = (32 - len(nm)) // 2
    d.append('name%d:\n    .str $%04X, "%s"\n    .byte 0' % (i, 0x2000 + 15 * 32 + col, nm))

# logo GTA6 (escala: cada pixel = un tile)
ROWTILE = [0x43, 0x43, 0x44, 0x42, 0x45, 0x41, 0x41]
logo = []
for ry in range(7):
    row = []
    for li, ch in enumerate("GTA6"):
        g = FONT[ch][ry]
        row += [ROWTILE[ry] if c == '#' else 0 for c in g]
        if li < 3: row.append(0)
    addr = 0x2000 + (5 + ry) * 32 + 4
    logo.append('    .strb $%04X, %s' % (addr, ','.join('$%02X' % b for b in row)))
sun = []
for i, (w, t) in enumerate([(6, 0x43), (10, 0x43), (12, 0x44), (14, 0x42), (14, 0x45), (16, 0x41)]):
    c0 = 16 - w // 2
    sun.append('    .strb $%04X, %s' % (0x2000 + (14 + i) * 32 + c0, ','.join(['$%02X' % t] * w)))
d.append('sun_strs:')
d += sun
d.append('    .byte 0')
d.append('logo_strs:')
d += logo
d.append('    .byte 0')

# notas: tabla de periodos (pulso). indice 1 = MIDI 36
d.append('note_lo:\n    .byte 0')
lo, hi = [], []
for m in range(36, 96):
    f = 440.0 * 2 ** ((m - 69) / 12)
    per = max(8, min(0x7FF, round(1789773 / (16 * f)) - 1))
    lo.append(per & 0xFF); hi.append(per >> 8)
d.append(byterows(lo))
d.append('note_hi:\n    .byte 0')
d.append(byterows(hi))
open('data.asm', 'w').write('\n'.join(d) + '\n')

# ------------------------------------------------------------------ musica (banco 1, $A000)
NOTE = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
def midi(s):
    return 12 * (int(s[-1]) + 1) + NOTE[s[0]] + (1 if '#' in s else 0)
def idx(m): return m - 35
melody = """A4 . C5 E5 D5 C5 B4 C5  A4 . C5 F5 E5 C5 A4 C5  G4 . C5 E5 D5 C5 G4 E4  B4 . D5 G5 F5 D5 B4 D5
E5 E5 D5 C5 E5 . A5 .  F5 E5 C5 A4 C5 . F5 .  E5 D5 C5 G4 C5 . E5 G5  D5 . B4 G4 B4 D5 G5 .""".split()
bass_roots = ['A2', 'F2', 'C3', 'G2'] * 2
STEP = 12
def stream(notes, tri=False):
    out = []
    for nt in notes:
        if nt == '.':
            if out and out[-2] == 0 and out[-1] + STEP < 250:
                out[-1] += STEP
            else:
                out += [0, STEP]
        else:
            m = midi(nt) + (12 if tri else 0)
            out += [idx(m), STEP]
    return out + [0xFF]
bass = []
for r in bass_roots:
    lo_ = r; hi_ = r[0] + str(int(r[-1]) + 1)
    bass += [lo_, hi_] * 4
mu = ['; ---- musica (banco 1, $A000) ----', 'mus_pulse:', byterows(stream(melody)),
      'mus_tri:', byterows(stream(bass, tri=True))]
open('music.asm', 'w').write('\n'.join(mu) + '\n')
print("ok: tiles sprite usados", n)
