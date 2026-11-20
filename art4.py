"""Arte v3: vehiculos con conductor, jefes estilo Metal Slug (caricatura), efectos."""
import math, random
from art import Canvas
from sprite3 import frame, make_enemy

# clases: k negro, s piel, h pelo, c color personaje, w blanco, u color enemigo/jefe 1, v color jefe 2, o naranja(P3 piel)
def to_grid(cv, cmap):
    return [[cmap.get(v, '.') if v else '.' for v in r] for r in cv.p]

def paste(dst, src, ox, oy, solid_only=True):
    for y, r in enumerate(src):
        for x, c in enumerate(r):
            if c != '.' and 0 <= oy + y < len(dst) and 0 <= ox + x < len(dst[0]):
                dst[oy + y][ox + x] = c

def blank(w, h): return [['.'] * w for _ in range(h)]

def wheel(cv, cx, cy, r, ph):
    cv.ellipse(cx, cy, r, r, 1)
    cv.ellipse(cx, cy, r - 2.0, r - 2.0, 3)
    for k in range(4):
        a = ph + k * math.pi / 2
        cv.line(cx, cy, cx + (r - 2.2) * math.cos(a), cy + (r - 2.2) * math.sin(a), 1)
    cv.set(cx, cy, 3)

# ------------------------------------------------------------ auto convertible (48x32)
def car_body(ph):
    cv = Canvas(48, 32)
    # 1 negro, 2 color, 3 blanco
    cv.poly([(1, 17), (8, 14), (28, 13), (33, 13), (46, 16), (47, 23), (44, 26), (3, 26), (1, 23)], 2)
    cv.line(2, 20, 46, 20, 3)                 # franja cromada
    cv.rect(45, 17, 46, 18, 3)                # faro
    cv.rect(1, 17, 2, 18, 1)
    cv.line(12, 16, 12, 24, 1)                # puerta
    wheel(cv, 10, 25, 6, ph)
    wheel(cv, 38, 25, 6, ph + .4)
    cv.outline(1)
    return cv

def gun_out(f):
    """copia del cuadro con el cañon de la pistola un poco mas largo (mas visible)"""
    d = [r[:] + ['.'] * 4 for r in f]
    gs = [(x, y) for y in range(len(d)) for x in range(len(d[0])) if d[y][x] == 'g']
    if not gs: return d
    mx = max(x for x, y in gs)
    rows = sorted(set(y for x, y in gs if x >= mx - 1))
    for y in rows:
        for x in (mx + 1, mx + 2, mx + 3):
            d[y][x] = 'g'
        d[y][mx + 4] = 'k'
    for x in range(mx + 1, mx + 5):
        if d[rows[0] - 1][x] == '.': d[rows[0] - 1][x] = 'k'
        if d[rows[-1] + 1][x] == '.': d[rows[-1] + 1][x] = 'k'
    return d

def car(driver_frame, ph):
    g = to_grid(car_body(ph), {1: 'k', 2: 'c', 3: 'w'})
    canvas = blank(48, 38)
    if driver_frame is not None:
        d = gun_out(driver_frame)[:20]
        paste(canvas, d, 8, 0)
    paste(canvas, g, 0, 6)
    if driver_frame is not None:
        # brazo con la pistola por delante de la carroceria (ventana abierta)
        gs = [(x, y) for y in range(len(d)) for x in range(len(d[0])) if d[y][x] == 'g']
        if gs:
            gx0 = min(x for x, y in gs) - 4
            ys = [y for x, y in gs]
            for y in range(min(ys) - 2, max(ys) + 3):
                for x in range(gx0, len(d[0])):
                    if 0 <= y < len(d) and d[y][x] != '.' and 0 <= y < len(canvas): canvas[y][x + 8] = d[y][x]
    return canvas

# ------------------------------------------------------------ moto deportiva (40x32)
def moto_body(ph):
    cv = Canvas(40, 32)
    cv.line(17, 28, 4, 25, 3, 2)               # escape
    cv.line(9, 25, 18, 24, 1, 2)               # basculante
    wheel(cv, 9, 25, 6, ph)
    wheel(cv, 31, 25, 6, ph + .3)
    cv.line(31, 25, 28, 13, 3, 2)              # horquilla
    cv.poly([(3, 17), (10, 18), (14, 15), (24, 14), (28, 12), (33, 15), (37, 19), (35, 22), (27, 23),
             (18, 23), (13, 21), (7, 20), (3, 19)], 2)
    cv.poly([(5, 16), (13, 16.5), (13, 18), (6, 18)], 1)
    cv.rect(15, 21, 22, 26, 1); cv.line(16, 22, 21, 22, 3); cv.line(16, 24, 21, 24, 3)
    cv.line(29, 10, 32, 13, 3)
    cv.rect(35, 18, 36, 18, 3)
    cv.outline(1)
    return cv

def moto(rider_frame, ph):
    g = to_grid(moto_body(ph), {1: 'k', 2: 'c', 3: 'w'})
    canvas = blank(40, 42)
    if rider_frame is not None:
        r = gun_out(rider_frame)
        paste(canvas, r[:26], 9, 0)
    paste(canvas, g, 0, 10)
    return canvas

# ------------------------------------------------------------ jefes
def outline_grid(g):
    H, W = len(g), len(g[0])
    old = [r[:] for r in g]
    for y in range(H):
        for x in range(W):
            if old[y][x] == '.':
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < W and 0 <= yy < H and old[yy][xx] not in ('.', 'k'):
                        g[y][x] = 'k'; break
    return g

def cop_head(kind='cop'):
    f = make_enemy(frame(0, 0), kind)
    return [r[:] for r in f[:16]]

CM = {1: 'k', 2: 'u', 3: 'v', 4: 'w', 5: 'o'}

def boss_armored(ph):            # 1 patrullero blindado 48x36
    cv = Canvas(48, 36)
    cv.poly([(2, 18), (8, 12), (38, 12), (46, 18), (47, 29), (1, 29)], 2)
    cv.poly([(42, 16), (47, 18), (47, 28), (44, 28)], 4)          # pala
    cv.rect(10, 14, 36, 16, 3); cv.line(4, 22, 44, 22, 4)
    cv.rect(18, 6, 30, 12, 2); cv.rect(30, 8, 40, 10, 1)            # torreta + cañon
    cv.rect(14, 9, 17, 12, 4); cv.rect(31, 9, 34, 12, 5)            # sirenas
    for x in range(6, 42, 6): cv.set(x, 25, 1)
    wheel(cv, 11, 29, 6, ph); wheel(cv, 36, 29, 6, ph + .5)
    cv.outline(1)
    g = to_grid(cv, CM)
    paste(g, cop_head()[:10], 18, -3) if False else None
    return g

def boss_motocop(ph):            # 2 moto policial 40x34 con policia
    b = moto_body(ph)
    g = to_grid(b, {1: 'k', 2: 'u', 3: 'w'})
    c = blank(40, 44)
    rider = make_enemy(frame(0, 7), 'cop')
    paste(c, [r[:] for r in rider[:26]], 9, 0)
    paste(c, g, 0, 12)
    return c

def boss_swat(ph):               # 3 camion SWAT 48x40
    cv = Canvas(48, 40)
    cv.rect(2, 6, 32, 32, 2)                                        # caja
    cv.poly([(32, 14), (40, 14), (46, 22), (46, 32), (32, 32)], 3)  # cabina
    cv.poly([(34, 16), (39, 16), (43, 22), (34, 22)], 4)            # vidrio
    cv.rect(4, 10, 30, 12, 3); cv.line(2, 20, 32, 20, 1)
    for x in range(6, 30, 5): cv.rect(x, 24, x + 2, 28, 1)          # rejillas
    cv.rect(10, 2, 24, 6, 1); cv.rect(24, 3, 34, 4, 1)              # cañon de agua
    wheel(cv, 10, 33, 6, ph); wheel(cv, 38, 33, 6, ph + .5)
    cv.outline(1)
    return to_grid(cv, CM)

def boss_heli(ph):               # 4 helicoptero 48x28
    cv = Canvas(48, 28)
    cv.ellipse(14, 15, 11, 7, 2)
    cv.rect(22, 11, 44, 14, 2); cv.rect(40, 7, 45, 14, 3)
    cv.ellipse(10, 14, 6, 4.5, 4)
    cv.line(4, 19, 24, 19, 3)
    cv.rect(13, 6, 16, 8, 1)
    cv.line(6, 25, 24, 25, 1); cv.line(9, 21, 8, 25, 1); cv.line(20, 21, 21, 25, 1)
    cv.rect(2, 20, 6, 22, 1)
    if ph == 0: cv.line(0, 5, 30, 4, 1, 2)
    else: cv.line(4, 4, 34, 5, 1, 2)
    if ph == 0: cv.line(44, 3, 44, 12, 1)
    else: cv.line(40, 8, 47, 8, 1)
    cv.outline(1)
    return to_grid(cv, CM)

def boss_robot(ph):              # 5 robot antidisturbios 40x48
    cv = Canvas(40, 48)
    lg = 2 if ph else -2
    cv.rect(10, 30, 16, 44 + (lg > 0), 3); cv.rect(23, 30, 29, 44 - (lg > 0), 3)   # piernas
    cv.rect(7, 43, 18, 47, 1); cv.rect(21, 43, 32, 47, 1)
    cv.poly([(6, 12), (33, 12), (35, 30), (4, 30)], 2)              # torso
    cv.rect(13, 3, 26, 12, 3); cv.rect(15, 6, 24, 8, 5)              # cabeza/visor
    cv.rect(0, 14, 6, 28, 3); cv.rect(33, 14, 39, 22, 3)             # brazos
    cv.rect(30, 22, 39, 36, 4)                                       # escudo
    cv.line(31, 28, 38, 28, 1); cv.rect(10, 16, 28, 18, 4)
    cv.rect(16, 20, 22, 24, 5)
    cv.outline(1)
    return to_grid(cv, CM)

def boss_jeep(ph):               # 6 jeep militar 48x36 con artillero
    cv = Canvas(48, 36)
    cv.poly([(1, 18), (12, 16), (30, 16), (34, 12), (40, 12), (47, 19), (47, 28), (1, 28)], 2)
    cv.line(34, 12, 31, 4, 3, 2)
    cv.rect(4, 19, 44, 21, 3)
    cv.rect(16, 8, 20, 16, 1); cv.rect(10, 7, 24, 9, 1)              # ametralladora
    wheel(cv, 10, 29, 6, ph); wheel(cv, 37, 29, 6, ph + .5)
    cv.rect(44, 20, 46, 22, 4)
    cv.outline(1)
    g = to_grid(cv, CM)
    head = make_enemy(frame(0, 0), 'soldier')[:14]
    c = blank(48, 40)
    paste(c, [r[:] for r in head], 4, 0)
    paste(c, g, 0, 4)
    return c

def boss_tank(ph):               # 7 tanque 48x40
    cv = Canvas(48, 40)
    cv.poly([(2, 26), (6, 22), (42, 22), (46, 26), (46, 34), (42, 38), (6, 38), (2, 34)], 1)   # orugas
    for i in range(6): wheel(cv, 8 + i * 6.4, 31, 3.2, ph + i)
    cv.poly([(4, 16), (44, 16), (46, 22), (2, 22)], 2)                # casco
    cv.poly([(12, 6), (30, 6), (34, 16), (8, 16)], 3)                 # torreta
    cv.rect(0, 9, 12, 12, 1)                                          # cañon (hacia la izquierda)
    cv.rect(18, 2, 24, 6, 2)
    cv.line(6, 19, 42, 19, 3)
    cv.rect(26, 9, 30, 12, 5)
    cv.outline(1)
    return to_grid(cv, CM)

def boss_jet(ph):                # 8 avion de ataque 48x24
    cv = Canvas(48, 24)
    cv.poly([(0, 12), (10, 8), (40, 8), (47, 4), (47, 14), (40, 16), (10, 16)], 2)
    cv.poly([(16, 12), (30, 12), (36, 22), (24, 22)], 3)              # ala
    cv.poly([(6, 9), (14, 6), (20, 8)], 4)                            # cabina
    cv.rect(18, 15, 30, 17, 1)                                        # bombas
    cv.line(40, 12, 46, 12, 3)
    if ph: cv.rect(44, 9, 47, 13, 5)
    cv.outline(1)
    return to_grid(cv, CM)

def boss_mecha(ph):              # 9 mecha 40x48
    cv = Canvas(40, 48)
    k = 3 if ph else 0
    cv.poly([(8, 30), (14, 30), (12 - k, 40), (16 - k, 46), (4 - k, 46)], 3)
    cv.poly([(26, 30), (32, 30), (36 + k, 46), (24 + k, 46), (28 + k, 40)], 3)
    cv.ellipse(20, 22, 16, 11, 2)                                     # cuerpo
    cv.ellipse(14, 20, 6, 4, 4)                                       # cabina
    cv.rect(26, 8, 36, 16, 3)                                         # lanzamisiles
    for x in (28, 31, 34): cv.set(x, 10, 1); cv.set(x, 13, 1)
    cv.rect(0, 22, 8, 25, 1)                                          # cañon
    cv.line(4, 31, 36, 31, 3)
    cv.outline(1)
    g = to_grid(cv, CM)
    head = make_enemy(frame(0, 0), 'soldier')[:12]
    paste(g, [[c if c != '.' else '.' for c in r[4:14]] for r in head[2:10]], 9, 15)
    return g

def boss_supertank(ph):          # 10 super tanque del general 48x48
    g = boss_tank(ph)
    c = blank(48, 52)
    head = make_enemy(frame(0, 13), 'soldier')
    paste(c, [r[:] for r in head[:20]], 12, 0)
    paste(c, g, 0, 12)
    for x in range(4, 44, 8): c[46][x] = 'v'
    return c

BOSSES = [boss_armored, boss_motocop, boss_swat, boss_heli, boss_robot,
          boss_jeep, boss_tank, boss_jet, boss_mecha, boss_supertank]
BOSS_NAMES = ["PATRULLERO BLINDADO", "HELICOPTERO MILITAR", "CAMION SWAT", "HELICOPTERO", "ROBOT ANTIMOTINES",
              "YATE DEL CAPO", "TANQUE", "AVION DE ATAQUE", "MECHA MILITAR", "SUPER TANQUE"]
# colores u, v por jefe (NES)
BOSS_COL = [(0x12, 0x21), (0x12, 0x31), (0x00, 0x10), (0x12, 0x30), (0x02, 0x12),
            (0x1A, 0x29), (0x0A, 0x1A), (0x10, 0x00), (0x18, 0x28), (0x0A, 0x1A)]

# ------------------------------------------------------------ efectos
def explosion(k):
    R = random.Random(20 + k)
    cv = Canvas(24, 24)
    rad = [5, 9, 11, 10][k]
    for y in range(24):
        for x in range(24):
            d = math.hypot(x - 11.5, y - 11.5) + R.uniform(-1.8, 1.8)
            if k < 3:
                c = 3 if d < rad * .45 else 2 if d < rad * .8 else 1 if d < rad else 0
            else:
                c = 1 if (d < rad and R.random() < .5) else 0
            if c: cv.set(x, y, c)
    return to_grid(cv, {1: 'k', 2: 's', 3: 'w'})
