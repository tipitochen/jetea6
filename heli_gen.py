"""Nivel 2: EN LOS CIELOS (helicoptero). Arte (sprites + fondo de cielo) y datos para el banco 8."""
import math, random
from art import Canvas
from art4 import to_grid
from sprite3 import quantize, quantize_layered, nes, CLS_RGB

HELI_BG_UNIT = 192        # 2 KB (R1): cielo, nubes, ciudad
HELI_SPR_UNIT = 194       # R2: helicoptero del jugador, policias con propulsor, helicoptero policial
HELI_BOSS_UNIT = 195      # R3: helicoptero militar (jefe)

K, W, C, S, H, U, V, G = 1, 2, 3, 4, 5, 6, 7, 8
SYM = {K: 'k', W: 'w', C: 'c', S: 's', H: 'h', U: 'u', V: 'v', G: 'w'}


def rotor(cv, cx, y, ph, half):
    """aspa principal: larga / corta segun la fase (da sensacion de giro)"""
    L = half if ph == 0 else half * 0.45
    cv.line(cx - L, y, cx + L, y, W)
    cv.rect(cx - 1, y, cx + 1, y + 2, K)


def player_heli(ph):
    cv = Canvas(44, 26)
    # cola
    cv.poly([(2, 11), (18, 12), (18, 16), (3, 14)], C)
    cv.rect(0, 7, 3, 15, C)                       # aleta
    # rotor de cola
    if ph == 0: cv.line(1, 6, 1, 16, W)
    else: cv.line(-2, 11, 5, 11, W)
    # cuerpo
    cv.ellipse(28, 14, 12, 7, C)
    cv.poly([(34, 8), (41, 13), (40, 16), (33, 16)], W)     # cabina (vidrio)
    # pilotos (cabezas) dentro de la cabina
    cv.ellipse(34, 12, 2.2, 2.2, S); cv.rect(32, 9, 36, 10, H)
    cv.ellipse(27, 12, 2.2, 2.2, S); cv.rect(25, 9, 29, 10, H)
    cv.line(17, 15, 40, 15, W)                    # franja
    # patines
    cv.line(20, 22, 38, 22, K); cv.line(18, 21, 20, 22, K); cv.line(38, 22, 41, 20, K)
    cv.line(24, 20, 24, 22, K); cv.line(34, 20, 34, 22, K)
    cv.outline(K)
    rotor(cv, 28, 5, ph, 18)
    cv.rect(27, 5, 29, 7, K)
    return to_grid(cv, SYM)


def jet_cop(ph):
    """policia con mochila propulsora, mirando a la izquierda (vuela hacia el jugador)"""
    cv = Canvas(20, 28)
    # mochila
    cv.rect(11, 9, 15, 18, W); cv.rect(12, 10, 14, 17, U)
    # llamas
    fl = 5 if ph == 0 else 8
    for i in range(fl):
        hw = 2.4 * (1 - i / (fl + 1))
        cv.line(13 - hw, 19 + i, 13 + hw, 19 + i, S)
        if i < fl - 2: cv.line(13 - hw * 0.4, 19 + i, 13 + hw * 0.4, 19 + i, W)
    # cuerpo
    cv.rect(5, 9, 11, 18, U)
    cv.line(5, 13, 11, 13, K)                     # cinturon
    # piernas colgando
    cv.rect(4, 19, 6, 24, U); cv.rect(8, 19, 10, 23, U)
    cv.rect(3, 24, 6, 25, K); cv.rect(7, 23, 10, 24, K)
    # cabeza + gorra
    cv.ellipse(8, 5, 3.4, 3.4, S)
    cv.rect(4, 0, 11, 2, U); cv.rect(2, 2, 11, 3, U)
    cv.set(6, 5, K)
    # brazo con pistola hacia adelante (izquierda)
    cv.rect(1, 11, 6, 12, U); cv.rect(0, 10, 1, 12, S)
    cv.rect(-1, 9, 1, 10, W)
    cv.outline(K)
    return to_grid(cv, SYM)


def jet_cop_street(ph):
    """el mismo policia de la calle (pose apuntando), mirando a la izquierda, con mochila propulsora"""
    from enemy4 import make_enemy2
    from sprite3 import frame
    g = [list(reversed(r)) for r in make_enemy2(frame(0, 9), 'cop')]
    while all(v == '.' for v in g[0]): g.pop(0)
    H = len(g); W = len(g[0])
    g = [r + ['.', '.'] for r in g] + [['.'] * (W + 2) for _ in range(6)]
    W += 2
    # mochila en la espalda (lado derecho)
    for y in range(11, 22):
        for x in range(17, 23):
            edge = y in (11, 21) or x in (17, 22)
            g[y][x] = 'k' if edge else ('w' if (y - 11) % 4 else 'u')
    # llama
    fl = 6 if ph == 0 else 9
    for i in range(fl):
        hw = 2.2 * (1 - i / (fl + 1))
        for x in range(int(round(19.5 - hw)), int(round(19.5 + hw)) + 1):
            y = 22 + i
            if 0 <= y < len(g):
                g[y][x] = 'w' if (abs(x - 19.5) < hw * 0.45 and i < fl - 2) else 's'
    while all(v == '.' for v in g[-1]): g.pop()
    return g


def drone(ph):
    """dron policial (cuadricoptero) con luz y canon abajo"""
    cv = Canvas(28, 16)
    # brazos
    cv.line(4, 6, 23, 6, U); cv.line(4, 7, 23, 7, U)
    # helices (borrosas, dos fases)
    for cx in (4, 23):
        cv.rect(cx - 1, 3, cx + 1, 6, K)
        if ph == 0:
            cv.line(cx - 4, 2, cx + 4, 2, W)
        else:
            cv.line(cx - 2, 2, cx + 2, 2, W); cv.set(cx - 4, 3, W); cv.set(cx + 4, 1, W)
    # cuerpo
    cv.ellipse(13.5, 8.5, 6, 3.6, U)
    cv.rect(10, 6, 17, 7, W)                      # franja blanca
    cv.rect(12, 4, 15, 5, S if ph == 0 else W)    # luz de patrullero
    cv.ellipse(13.5, 9.5, 2, 1.6, K); cv.set(13, 9, W)   # camara
    # canon
    cv.rect(11, 12, 16, 13, K); cv.rect(9, 12, 10, 13, W)
    # patitas
    cv.line(8, 11, 7, 14, K); cv.line(19, 11, 20, 14, K)
    cv.outline(K)
    return to_grid(cv, SYM)


def police_heli(ph):
    """helicoptero policial mirando a la izquierda"""
    cv = Canvas(44, 26)
    cv.poly([(42, 11), (26, 12), (26, 16), (41, 14)], U)
    cv.rect(41, 7, 44, 15, U)
    if ph == 0: cv.line(42, 6, 42, 16, W)
    else: cv.line(39, 11, 46, 11, W)
    cv.ellipse(16, 14, 12, 7, U)
    cv.poly([(10, 8), (3, 13), (4, 16), (11, 16)], W)
    cv.line(4, 15, 27, 15, W)
    cv.rect(14, 10, 18, 12, W)                    # ventana
    # sirena
    cv.rect(17, 6, 20, 7, S if ph == 0 else W)
    cv.line(6, 22, 24, 22, K); cv.line(3, 20, 6, 22, K); cv.line(24, 22, 26, 21, K)
    cv.line(10, 20, 10, 22, K); cv.line(20, 20, 20, 22, K)
    cv.outline(K)
    rotor(cv, 16, 4, ph, 17)
    cv.rect(15, 4, 17, 6, K)
    return to_grid(cv, SYM)


def boss_heli(ph):
    """helicoptero militar de ataque (jefe), mirando a la izquierda"""
    cv = Canvas(56, 34)
    # cola larga
    cv.poly([(55, 12), (30, 14), (30, 19), (54, 16)], U)
    cv.rect(51, 6, 55, 17, U); cv.rect(52, 7, 54, 15, V)
    if ph == 0: cv.line(53, 4, 53, 19, W)
    else: cv.line(49, 12, 58, 12, W)
    # cuerpo blindado
    cv.poly([(4, 18), (12, 10), (34, 9), (40, 13), (40, 22), (10, 24)], U)
    cv.poly([(8, 18), (14, 12), (33, 11), (37, 14), (37, 19), (12, 21)], V)
    cv.poly([(5, 17), (12, 11), (17, 11), (14, 18)], W)       # cabina
    cv.line(13, 12, 11, 17, K)
    # alas con lanzacohetes
    cv.rect(18, 22, 34, 23, K)
    cv.rect(16, 24, 26, 27, U); cv.rect(28, 24, 36, 27, U)
    cv.rect(15, 25, 16, 26, S); cv.rect(27, 25, 28, 26, S)
    # cañon bajo la nariz
    cv.rect(2, 22, 10, 23, K); cv.rect(0, 22, 2, 23, W)
    # patines
    cv.line(10, 31, 36, 31, K); cv.line(14, 28, 14, 31, K); cv.line(32, 28, 32, 31, K)
    cv.outline(K)
    rotor(cv, 22, 4, ph, 24)
    cv.rect(21, 4, 23, 8, K)
    return to_grid(cv, SYM)


def cls_for(u, v):
    c = dict(CLS_RGB)
    c.update(k=tuple(nes(0x0F)), w=tuple(nes(0x30)), s=tuple(nes(0x27)), h=tuple(nes(0x17)),
             c=tuple(nes(0x2C)), u=tuple(nes(u)), v=tuple(nes(v)))
    return c


def pix_rows(p): return tuple(''.join(str(v) if v else '.' for v in r) for r in p)


class Bank:
    def __init__(s, base, cap): s.base, s.cap, s.t = base, cap, [tuple(['........'] * 8)]
    def tid(s, rows):
        if rows not in s.t: s.t.append(rows)
        assert len(s.t) <= s.cap, ('banco lleno', s.base)
        return s.base + s.t.index(rows)


def build():
    """-> (tiles R2, tiles R3, tiles BG, asm)"""
    A = ['; ---- datos del nivel helicoptero (generado por heli_gen.py) ----']
    A.append('HELI_BG_UNIT = %d' % HELI_BG_UNIT)
    A.append('HELI_SPR_UNIT = %d' % HELI_SPR_UNIT)
    A.append('HELI_BOSS_UNIT = %d' % HELI_BOSS_UNIT)
    b2 = Bank(0x00, 64); b3 = Bank(0x40, 64)
    frames = []
    # jugador: P0 cabezas (piel/pelo), P1 cuerpo (blanco/camisa), P3 (piel/blanco)
    cp = cls_for(0x12, 0x21)
    pal_p = [(1, [0x0F, 0x30, 0x2C]), (0, [0x0F, 0x27, 0x17]), (3, [0x0F, 0x27, 0x30])]
    pal_e = [(2, [0x0F, 0x27, 0x12]), (3, [0x0F, 0x27, 0x30])]
    pal_b = [(2, [0x0F, 0x0A, 0x1A]), (3, [0x0F, 0x27, 0x30])]
    def add(name, ents, bank):
        L = []
        for dx, dy, p, ap in ents:
            L.append((dy, dx, bank.tid(pix_rows(p)), ap))
        frames.append((name, L))
    for ph in range(2):
        add('pl%d' % ph, quantize(player_heli(ph), pal_p, cp), b2)
    ce = cls_for(0x12, 0x30)
    for ph in range(2):
        add('jc%d' % ph, quantize(drone(ph), pal_e, ce), b2)
    for ph in range(2):
        add('ph%d' % ph, quantize(police_heli(ph), pal_e, ce), b3)
    cb = cls_for(0x0A, 0x1A)
    for ph in range(2):
        add('bs%d' % ph, quantize(boss_heli(ph), pal_b, cb), b3)
    for name, L in frames:
        flat = [len(L)]
        for dy, dx, t, ap in L: flat += [dy & 255, dx & 255, t, ap]
        A.append('hf_%s: .byte %s' % (name, ','.join('$%02X' % v for v in flat)))
    A.append('hf_lo: .byte ' + ','.join('<hf_%s' % n for n, _ in frames))
    A.append('hf_hi: .byte ' + ','.join('>hf_%s' % n for n, _ in frames))
    for i, (n, L) in enumerate(frames):
        A.append('HF_%s = %d' % (n.upper(), i))
    print('heli sprites: R2 %d tiles, R3 %d tiles; sprites por cuadro %s' % (len(b2.t), len(b3.t), [(n, len(L)) for n, L in frames]))
    return b2.t, b3.t, A


# ------------------------------------------------------------ fondo: cielo con nubes + techos de la ciudad abajo
def sky_bg():
    """mapa de 32x22 (filas 8..29) + tiles. Indices 0x80+; color 1 = cielo, 2 = blanco, 3 = celeste (nubes) /
    en la ciudad: 1 cielo, 2 edificio oscuro, 3 ventanas"""
    Wd, Hd = 256, 26 * 8
    img = [[1] * Wd for _ in range(Hd)]
    R = random.Random(7)
    def cloud(cx, cy, w, h):
        for y in range(Hd):
            for x in range(Wd):
                for k in range(5):
                    bx = cx + (k - 2) * w * 0.22
                    by = cy + (abs(k - 2) * h * 0.18)
                    rx = w * (0.30 if k != 2 else 0.36); ry = h * (0.55 if k != 2 else 0.75)
                    dx = min(abs(x - bx), Wd - abs(x - bx))
                    d = (dx / rx) ** 2 + ((y - by) / ry) ** 2
                    if d <= 1:
                        img[y][x] = 3 if (y - by) > ry * 0.35 else 2
    cloud(90, 12, 48, 12); cloud(210, 20, 36, 10)                 # banda de arriba (parallax lento)
    cloud(40, 28 + 32, 56, 20); cloud(160, 64 + 32, 72, 24); cloud(236, 14 + 32, 40, 14)
    # ciudad (abajo): edificios alineados a la grilla de tiles, ventanas con el mismo patron
    x = 0
    while x < Wd:
        w = R.choice([2, 3, 3, 4]) * 8; h = R.choice([2, 3, 4, 5]) * 8
        for yy in range(Hd - h, Hd):
            for xx in range(x, min(Wd, x + w)):
                img[yy][xx] = 6
                if (yy - (Hd - h)) % 8 in (3, 4) and (xx - x) % 8 in (2, 3, 5, 6) and yy < Hd - 2: img[yy][xx] = 7
        x += w
    # tiles
    tl = []; mp = []
    for ty in range(26):
        row = []
        for tx in range(32):
            blk = [img[ty * 8 + y][tx * 8:tx * 8 + 8] for y in range(8)]
            city = any(v >= 6 for r in blk for v in r)
            t = tuple(''.join({1: '1', 2: '2', 3: '3', 6: '2', 7: '3'}[v] for v in r) for r in blk)
            key = (t, city)
            if key not in tl: tl.append(key)
            row.append(0x80 + tl.index(key))
        mp.append(row)
    assert len(tl) <= 128, len(tl)
    # atributos: cielo paleta 2, filas con ciudad paleta 3 (bloques de 16x16: si hay ciudad en el bloque -> 3)
    attr = []
    for ay in range(8):
        for ax in range(8):
            v = 0
            for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                ty = ay * 4 + dy * 2; tx = ax * 4 + dx * 2
                if ty < 4: p = 0
                else:
                    city = any(tl[mp[yy - 4][xx] - 0x80][1] for yy in (ty, ty + 1) if 4 <= yy < 30 for xx in (tx, tx + 1))
                    p = 3 if city else 2
                v |= p << (q * 2)
            attr.append(v)
    return [t for t, _ in tl], mp, attr


def bg_asm():
    tl, mp, attr = sky_bg()
    A = ['heli_map:']
    for r in mp: A.append('    .byte ' + ','.join('$%02X' % v for v in r))
    A.append('heli_attr: .byte ' + ','.join('$%02X' % v for v in attr))
    print('heli fondo: %d tiles' % len(tl))
    return tl, A


if __name__ == '__main__':
    from PIL import Image
    CC = {'k': (0, 0, 0), 'w': (250, 250, 250), 'c': (0, 220, 210), 's': (250, 160, 70), 'h': (200, 80, 10), 'u': (30, 60, 200), 'v': (80, 160, 40), '.': (60, 140, 250)}
    gs = [player_heli(0), player_heli(1), drone(0), drone(1), police_heli(0), boss_heli(0), boss_heli(1)]
    im = Image.new('RGB', (sum(len(g[0]) + 6 for g in gs), 36), (60, 140, 250))
    x0 = 0
    for g in gs:
        for y, r in enumerate(g):
            for x, v in enumerate(r):
                if v != '.': im.putpixel((x0 + x, y), CC[v])
        x0 += len(g[0]) + 6
    im.resize((im.width * 4, im.height * 4), Image.NEAREST).save('heli_art.png')
    tl, mp, attr = sky_bg()
    bg = Image.new('RGB', (256, 176))
    P = {'1': (100, 176, 255), '2': (250, 250, 250), '3': (180, 220, 250)}
    for ty, r in enumerate(mp):
        for tx, t in enumerate(r):
            for y, row in enumerate(tl[t - 0x80]):
                for x, ch in enumerate(row): bg.putpixel((tx * 8 + x, ty * 8 + y), P[ch])
    bg.resize((512, 352)).save('heli_bg.png')
    print(len(tl))


# ------------------------------------------------------------ escena: azotea con el helicoptero grande
SCENE_R1 = 196          # 2 KB: tiles $80-$FF de la escena
SCENE_A = 198           # 2 KB: fuente + tiles $48-$7F (rotor posicion A)
SCENE_B = 200           # 2 KB: fuente + tiles $48-$7F (rotor posicion B)
# colores (indices de paleta logicos)
SKY, WH, LT, BODY, GLS, DK, FL, FL2, YL = 'S', 'W', 'L', 'C', 'G', 'K', 'F', 'f', 'Y'


def scene_img(rot):
    """256x176 (filas de pantalla 8..29). rot = 0/1 posicion del rotor"""
    from art import Canvas
    cv = Canvas(256, 176)
    # nubes
    import random
    R = random.Random(5)
    for cx, cy, w in ((40, 14, 50), (210, 30, 60), (120, 6, 34)):
        cv.ellipse(cx, cy, w * 0.5, 7, 2); cv.ellipse(cx - w * 0.22, cy - 4, w * 0.25, 6, 2); cv.ellipse(cx + w * 0.18, cy - 3, w * 0.22, 5, 2)
        cv.line(cx - w * 0.45, cy + 4, cx + w * 0.45, cy + 4, 3)
    # azotea
    cv.rect(0, 136, 255, 175, 7)
    cv.rect(0, 136, 255, 138, 8)              # borde claro
    for x in range(0, 256, 32): cv.rect(x, 157, x, 175, 1)     # juntas
    cv.line(0, 156, 255, 156, 1)
    # marca del helipuerto (circulo amarillo y la H)
    cv.rect(96, 168, 208, 169, 9)             # linea amarilla
    cv.rect(140, 150, 143, 166, 9); cv.rect(157, 150, 160, 166, 9); cv.rect(140, 157, 160, 159, 9)
    # ---- helicoptero grande (mirando a la izquierda)
    # cola
    cv.poly([(196, 96), (246, 100), (246, 108), (196, 114)], 4)
    cv.line(196, 108, 246, 105, 2)
    cv.poly([(236, 74), (248, 74), (250, 108), (240, 108)], 4)      # aleta
    cv.ellipse(244, 92, 2, 9 if rot == 0 else 3, 2)                  # rotor de cola
    # fuselaje
    cv.poly([(70, 112), (78, 92), (96, 80), (176, 78), (200, 90), (204, 112), (196, 126), (84, 126)], 4)
    cv.rect(84, 112, 198, 115, 2)                                      # franja blanca
    # parabrisas grande
    cv.poly([(74, 108), (82, 92), (98, 82), (112, 82), (112, 106)], 5)
    cv.line(84, 92, 100, 84, 2); cv.line(80, 100, 90, 92, 2)          # brillo
    cv.line(112, 82, 112, 108, 1)
    # puerta abierta (por donde suben)
    cv.rect(132, 86, 160, 124, 1)
    cv.rect(134, 88, 158, 122, 1)
    cv.line(131, 86, 131, 124, 2); cv.line(161, 86, 161, 124, 2)
    # ventana de atras
    cv.rect(170, 88, 186, 100, 5); cv.line(172, 90, 178, 90, 2)
    # motor arriba
    cv.poly([(118, 78), (124, 70), (170, 70), (178, 78)], 4)
    cv.rect(126, 72, 168, 74, 2)
    # patines
    cv.line(86, 134, 196, 134, 1); cv.line(86, 133, 196, 133, 1)
    cv.line(80, 131, 86, 133, 1)
    for x in (104, 176): cv.line(x, 126, x - 4, 133, 1); cv.line(x + 1, 126, x - 3, 133, 1)
    # mastil y rotor principal
    cv.rect(145, 62, 149, 70, 1)
    if rot == 0:
        cv.rect(30, 60, 264, 61, 1); cv.rect(40, 59, 254, 59, 2)
    else:
        cv.rect(110, 60, 184, 61, 1); cv.rect(118, 59, 176, 59, 2)
        cv.line(80, 58, 110, 60, 3); cv.line(184, 60, 214, 62, 3)
    cv.rect(142, 58, 152, 62, 1)
    cv.outline(1)
    g = to_grid(cv, {1: 'K', 2: 'W', 3: 'L', 4: 'C', 5: 'G', 7: 'F', 8: 'f', 9: 'Y'})
    return [[(SKY if v == '.' else v) for v in r] for r in g]


# paletas de la escena: 1 cielo/nubes, 2 helicoptero, 3 azotea  (el negro es el fondo universal)
SC_PALS = {1: ['S', 'W', 'L'], 2: ['S', 'W', 'C'], 3: ['F', 'f', 'Y']}
SC_RGB = {'S': (100, 176, 255), 'W': (252, 252, 252), 'L': (184, 220, 255), 'C': (0, 232, 216), 'G': (100, 176, 255),
          'K': (0, 0, 0), 'F': (120, 120, 120), 'f': (188, 188, 188), 'Y': (248, 216, 32)}


def scene_build():
    A_ = scene_img(0); B_ = scene_img(1)
    A_ = [[('S' if v == 'G' else v) for v in r] for r in A_]      # vidrio = color del cielo
    B_ = [[('S' if v == 'G' else v) for v in r] for r in B_]
    Hh = len(A_)
    # paleta por bloque de 16x16
    attr_blk = {}
    for by in range(Hh // 16 + 1):
        for bx in range(16):
            best = None
            for pi, P in SC_PALS.items():
                err = 0
                for img in (A_, B_):
                    for y in range(by * 16, min(Hh, by * 16 + 16)):
                        for x in range(bx * 16, bx * 16 + 16):
                            v = img[y][x]
                            if v != 'K' and v not in P: err += 1
                if best is None or err < best[0]: best = (err, pi)
            attr_blk[(bx, by)] = best[1]
    def tile(img, tx, ty):
        P = SC_PALS[attr_blk[(tx // 2, ty // 2)]]
        rows = []
        for y in range(8):
            r = ''
            for x in range(8):
                v = img[ty * 8 + y][tx * 8 + x]
                if v == 'K': r += '0'
                elif v in P: r += str(P.index(v) + 1)
                else:
                    # el mas parecido de la paleta
                    c = SC_RGB[v]
                    d = [sum((a - b) ** 2 for a, b in zip(c, SC_RGB[p])) for p in P] + [sum(a * a for a in c)]
                    k = d.index(min(d)); r += str(k + 1) if k < 3 else '0'
            rows.append(r.replace('0', '.'))
        return tuple(rows)
    r0 = []; r1 = []; mp = []
    for ty in range(22):
        row = []
        for tx in range(32):
            ta = tile(A_, tx, ty); tb = tile(B_, tx, ty)
            if ta != tb:
                if (ta, tb) not in r0: r0.append((ta, tb))
                row.append(0x48 + r0.index((ta, tb)))
            else:
                if ta not in r1: r1.append(ta)
                row.append(0x80 + r1.index(ta))
        mp.append(row)
    # lo que no entra en R1 va a los huecos libres de R0 (igual en las dos versiones)
    while len(r1) > 128 and len(r0) < 56:
        t = r1.pop()
        r0.append((t, t))
        idx = 0x80 + len(r1)
        for row in mp:
            for i, v in enumerate(row):
                if v == idx: row[i] = 0x48 + len(r0) - 1
    print('escena helipuerto: rotor+extra %d tiles (max 56), resto %d tiles (max 128)' % (len(r0), len(r1)))
    assert len(r0) <= 56, ('rotor', len(r0))
    assert len(r1) <= 128, ('escena', len(r1))
    # atributos (filas 0-3 HUD paleta 0, 4-7 cielo paleta 1)
    attr = []
    for ay in range(8):
        for ax in range(8):
            v = 0
            for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                ty = ay * 4 + dy * 2; tx = ax * 4 + dx * 2
                if ty < 4: p = 0
                elif ty < 8: p = 1
                else: p = attr_blk[(tx // 2, (ty - 8) // 2)]
                v |= p << (q * 2)
            attr.append(v)
    A = ['scene_map:']
    for r in mp: A.append('    .byte ' + ','.join('$%02X' % v for v in r))
    A.append('scene_attr: .byte ' + ','.join('$%02X' % v for v in attr))
    A.append('SCENE_R1 = %d' % SCENE_R1)
    A.append('SCENE_A = %d' % SCENE_A)
    A.append('SCENE_B = %d' % SCENE_B)
    return r0, r1, A
