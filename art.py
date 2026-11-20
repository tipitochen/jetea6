"""Arte procedural para GTA6 NES: personajes 16x32, policias, soldados, vehiculos, explosiones."""
import math, random

class Canvas:
    def __init__(s, w, h):
        s.w, s.h = w, h
        s.p = [[0] * w for _ in range(h)]
    def set(s, x, y, c):
        x = int(math.floor(x + 0.5)); y = int(math.floor(y + 0.5))
        if 0 <= x < s.w and 0 <= y < s.h:
            s.p[y][x] = c
    def get(s, x, y):
        if 0 <= x < s.w and 0 <= y < s.h: return s.p[y][x]
        return 0
    def brush(s, x, y, c, w):
        if w == 1: s.set(x, y, c)
        elif w == 2:
            for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)): s.set(x + dx - .5, y + dy - .5, c)
        else:
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    if abs(dx) + abs(dy) < 2: s.set(x + dx, y + dy, c)
    def line(s, x0, y0, x1, y1, c, w=1):
        n = int(max(abs(x1 - x0), abs(y1 - y0)) * 2) + 1
        for i in range(n + 1):
            t = i / n
            s.brush(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, c, w)
    def rect(s, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1):
                s.set(x, y, c)
    def ellipse(s, cx, cy, rx, ry, c):
        for y in range(int(cy - ry - 1), int(cy + ry + 2)):
            for x in range(int(cx - rx - 1), int(cx + rx + 2)):
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                    s.set(x, y, c)
    def ring(s, cx, cy, r0, r1, c):
        for y in range(int(cy - r1 - 1), int(cy + r1 + 2)):
            for x in range(int(cx - r1 - 1), int(cx + r1 + 2)):
                d = math.hypot(x - cx, y - cy)
                if r0 <= d <= r1: s.set(x, y, c)
    def outline(s, c=1, only_bg=True):
        old = [r[:] for r in s.p]
        for y in range(s.h):
            for x in range(s.w):
                if old[y][x] == 0:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        xx, yy = x + dx, y + dy
                        if 0 <= xx < s.w and 0 <= yy < s.h and old[yy][xx] not in (0, c):
                            s.p[y][x] = c; break
    def poly(s, pts, c):
        ys = [p[1] for p in pts]
        for y in range(int(min(ys)), int(max(ys)) + 1):
            xs = []
            yc = y + 0.5
            for i in range(len(pts)):
                (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % len(pts)]
                if (y0 <= yc < y1) or (y1 <= yc < y0):
                    xs.append(x0 + (yc - y0) * (x1 - x0) / (y1 - y0))
            xs.sort()
            for i in range(0, len(xs) - 1, 2):
                for x in range(int(math.ceil(xs[i] - 0.5)), int(math.floor(xs[i + 1] - 0.5)) + 1):
                    s.set(x, y, c)
    def flip(s):
        for r in s.p: r.reverse()
    def rows(s):
        return [''.join('.' if v == 0 else str(v) for v in r) for r in s.p]

# ---------------------------------------------------------------- personajes
def leg(cv, hx, hy, th, kb, kind, front):
    """th = angulo muslo (grados, + adelante), kb = flexion rodilla."""
    a = math.radians(th); b = math.radians(th - kb)
    L1, L2 = 6, 6
    kx, ky = hx + L1 * math.sin(a), hy + L1 * math.cos(a)
    ax, ay = kx + L2 * math.sin(b), ky + L2 * math.cos(b)
    if kind in ('cop', 'soldier'):
        cv.line(hx, hy, kx, ky, 3, 2); cv.line(kx, ky, ax, ay, 3, 2)
        cv.line(ax - .5, ay, ax + 2.5, ay, 1, 2)          # bota
    else:
        sh = 3 if kind == 'jose' else 1.8                 # largo del short
        mx, my = hx + sh * math.sin(a), hy + sh * math.cos(a)
        cv.line(hx, hy, kx, ky, 2, 2)
        cv.line(hx, hy, mx, my, 3, 2)
        cv.line(kx, ky, ax, ay, 2, 2)
        cv.line(ax - .5, ay + .3, ax + 2.2, ay + .3, 1, 2)  # zapatilla
    return ax, ay

def head(cv, kind, x, y, sway=0):
    # x,y = esquina sup izq de la cabeza (6x9)
    if kind == 'luciana':
        # pelo largo detras
        for i in range(10):
            cv.line(x - 1 + sway * (i / 9), y + 2 + i, x + 2, y + 2 + i, 1)
    cv.ellipse(x + 3, y + 4.5, 3.0, 4.0, 2)               # cara
    if kind == 'jose':
        cv.rect(x, y, x + 5, y + 1, 1); cv.rect(x - 1, y + 1, x + 1, y + 5, 1)
        cv.set(x + 5, y - 1 + 1, 1); cv.set(x + 3, y - 1 + 1, 1)
        cv.rect(x + 3, y + 3, x + 6, y + 3, 1)              # lentes
        cv.set(x + 6, y + 4, 1)
        cv.set(x + 6, y + 5, 2)                           # nariz
        cv.set(x + 5, y + 7, 1)                           # barba
        cv.set(x + 4, y + 7, 1)
    elif kind == 'luciana':
        cv.rect(x, y, x + 5, y + 1, 1); cv.rect(x - 1, y + 1, x + 1, y + 4, 1)
        cv.set(x + 5, y + 2, 1)                           # flequillo
        cv.rect(x + 3, y + 3, x + 5, y + 3, 1)              # lentes
        cv.set(x + 6, y + 5, 2)
        cv.set(x + 5, y + 7, 3)                           # labios
        cv.set(x + 1, y + 6, 3)                           # arete
    elif kind == 'cop':
        cv.rect(x - 1, y - 1, x + 5, y + 1, 1)              # gorra
        cv.rect(x + 3, y + 1, x + 7, y + 1, 1)              # visera
        cv.set(x + 2, y, 2)                               # placa
        cv.rect(x - 1, y + 2, x, y + 4, 1)
        cv.set(x + 5, y + 3, 1)                           # ojo
        cv.rect(x + 4, y + 6, x + 6, y + 6, 1)              # bigote
        cv.set(x + 6, y + 5, 2)
    elif kind == 'soldier':
        cv.ellipse(x + 2.5, y + 1.5, 4, 2.6, 3)           # casco
        cv.rect(x - 1, y + 2, x + 6, y + 2, 1)
        cv.rect(x + 3, y + 4, x + 5, y + 4, 1)              # gafas
        cv.set(x + 6, y + 5, 2)
        cv.rect(x + 1, y + 6, x + 1, y + 8, 1)              # correa

def torso(cv, kind, x, y, h=6, lean=0):
    # x = borde izq, y = hombros
    for i in range(h):
        sx = x + lean * (1 - i / max(1, h - 1))
        cv.rect(sx, y + i, sx + 5, y + i, 3)
    if kind == 'jose':                                    # camisa hawaiana
        for (dx, dy) in ((1, 1), (4, 2), (2, 4), (5, 4), (0, 3)):
            if dy < h: cv.set(x + dx + lean * (1 - dy / max(1, h - 1)), y + dy, 2 if (dx + dy) % 2 else 1)
        cv.set(x + 4 + lean, y, 2)                        # cuello abierto
    elif kind == 'luciana':
        for i in range(3, h):
            sx = x + lean * (1 - i / max(1, h - 1))
            cv.rect(sx + 1, y + i, sx + 4, y + i, 2)      # ombligo al aire
    elif kind == 'cop':
        cv.set(x + 2 + lean, y + 1, 2)                    # placa
        cv.rect(x, y + h - 1, x + 5, y + h - 1, 1)          # cinturon
    elif kind == 'soldier':
        cv.set(x + 1 + lean, y + 2, 1); cv.set(x + 4 + lean, y + 4, 1)
        cv.rect(x, y + h - 1, x + 5, y + h - 1, 1)

def arm_gun(cv, kind, sx, sy, hx, hy, gdx, gdy):
    cv.line(sx, sy, hx, hy, 2, 2)
    if kind in ('cop', 'soldier'):
        cv.line(sx, sy, (sx + hx) / 2, (sy + hy) / 2, 3, 2)
    else:
        cv.set(sx, sy, 3); cv.set(sx + 1, sy, 3)
    ln = 7 if kind == 'soldier' else 3.5
    cv.line(hx, hy, hx + gdx * ln, hy + gdy * ln, 1, 2)
    cv.set(hx - gdy, hy + abs(gdx) + 1, 1)
    if kind == 'soldier':
        cv.line(hx - gdx * 2, hy - gdy * 2, hx, hy, 1, 2)

def arm_back(cv, kind, sx, sy, ang):
    a = math.radians(ang)
    ex, ey = sx + 3 * math.sin(a), sy + 3 * math.cos(a)
    hx, hy = ex + 3 * math.sin(a + .5), ey + 3 * math.cos(a + .5)
    col = 3 if kind in ('cop', 'soldier') else 2
    cv.line(sx, sy, ex, ey, col, 2); cv.line(ex, ey, hx, hy, 2, 2)

def person(kind, pose):
    cv = Canvas(16, 32)
    by = pose.get('by', 0)
    lean = pose.get('lean', 0)
    hx, hy = 7.5, 19 + by
    # brazo trasero
    if pose.get('back', None) is not None:
        arm_back(cv, kind, 6 + lean, 12 + by, pose['back'])
    # pierna trasera
    th, kb = pose['legs'][0]
    leg(cv, hx - .5, hy, th, kb, kind, False)
    # torso + cadera
    torso(cv, kind, 5, 10 + by, 6, lean)
    if kind in ('jose', 'luciana'):
        cv.rect(5, 16 + by, 10, 18 + by, 3)              # short
        cv.rect(5, 16 + by, 10, 16 + by, 1 if kind == 'jose' else 3)  # cinturon
    else:
        cv.rect(5, 16 + by, 10, 18 + by, 3)
    th, kb = pose['legs'][1]
    leg(cv, hx + .5, hy, th, kb, kind, True)
    head(cv, kind, 6 + lean, 1 + by, pose.get('sway', 0))
    g = pose.get('gun')
    if g:
        arm_gun(cv, kind, *g)
    cv.outline(1)
    return cv

RUN = []
for i in range(6):
    ph = 2 * math.pi * i / 6
    fl = (32 * math.sin(ph), 18 + 40 * (1 + math.cos(ph + .9)) / 2)
    bl = (32 * math.sin(ph + math.pi), 18 + 40 * (1 + math.cos(ph + math.pi + .9)) / 2)
    bob = -1 if i in (1, 4) else 0
    RUN.append(dict(by=bob, legs=[bl, fl], back=-30 * math.sin(ph), lean=1, sway=-2 + (i % 2),
                    gun=(10, 12 + bob, 12.5, 13.5 + bob, 1, 0)))
GUNF = (10, 12, 12.5, 13.5, 1, 0)
POSES = [
    dict(legs=[(-8, 4), (8, 4)], back=5, gun=GUNF, sway=-1),                                    # 0 quieto 1
    dict(by=1, legs=[(-8, 8), (8, 8)], back=8, gun=(10, 13, 12.5, 14.5, 1, 0), sway=-1),         # 1 quieto 2
] + RUN + [                                                                                     # 2-7 correr
    dict(by=-1, legs=[(-20, 70), (40, 80)], back=-60, gun=(10, 11, 12.5, 12.5, 1, 0), lean=1),   # 8 salto
    dict(legs=[(-15, 20), (25, 35)], back=-120, gun=(10, 12, 12.5, 13.5, 1, 0), sway=-2),       # 9 caida
    dict(by=7, legs=[(75, 150), (95, 160)], back=10, gun=(10, 19, 12.5, 20.5, 1, 0), lean=1),   # 10 agachado
    dict(legs=[(-8, 4), (8, 4)], back=5, gun=(10, 11, 12, 5, 0, -1)),                           # 11 apunta arriba
    dict(legs=[(-8, 4), (10, 6)], back=5, gun=(10, 11, 12.5, 8, .7, -.7)),                      # 12 diagonal
    dict(legs=[(-25, 10), (15, 30)], back=-150, lean=-1, sway=2),                                # 13 herido
    dict(by=1, legs=[(80, 85), (85, 90)], back=None, gun=(10, 13, 13, 13, 1, 0), lean=2),       # 14 en moto
    dict(by=10, legs=[(90, 175), (100, 178)], back=60, lean=3),                                  # 15 caido
]
PALSPLIT = [2] * 16
PALSPLIT[10] = 3   # agachado: paleta inferior solo en la ultima fila de tiles
PALSPLIT[15] = 3

def char_frames(kind):
    return [person(kind, p) for p in POSES]

ENEMY_POSES = RUN[0:6:2] + [RUN[3]]          # 4 frames de carrera
def enemy_frames(kind):
    fr = []
    for p in (RUN[0], RUN[1], RUN[3], RUN[4]):
        fr.append(person(kind, p))
    fr.append(person(kind, dict(legs=[(-10, 4), (12, 6)], back=10, gun=(10, 12, 12.5, 13, 1, 0))))   # disparo
    fr.append(person(kind, dict(by=7, legs=[(75, 150), (95, 160)], back=10, gun=(10, 19, 12.5, 20, 1, 0), lean=1)))  # agachado
    fr.append(person(kind, dict(legs=[(-30, 20), (10, 40)], back=-150, lean=-2)))   # golpeado
    fr.append(person(kind, dict(by=10, legs=[(90, 175), (100, 178)], back=60, lean=3)))  # caido
    return fr

# ---------------------------------------------------------------- vehiculos
def wheel(cv, cx, cy, r, phase):
    cv.ellipse(cx, cy, r, r, 1)
    cv.ellipse(cx, cy, r - 1.8, r - 1.8, 2)
    for k in range(5):
        a = phase + k * math.pi * 2 / 5
        cv.line(cx, cy, cx + (r - 1.9) * math.cos(a), cy + (r - 1.9) * math.sin(a), 1)
    cv.set(cx, cy, 2)

def moto(phase):
    cv = Canvas(32, 16)
    cv.line(13, 12.5, 3, 10.5, 2, 2)                          # escape
    cv.line(7, 11, 14, 10, 1, 2)                              # basculante
    wheel(cv, 7, 11, 4.9, phase)
    wheel(cv, 25, 11, 4.9, phase + .3)
    cv.line(25, 11, 22.5, 3, 2, 2)                            # horquilla
    cv.poly([(2, 4), (8, 5), (12, 3), (20, 2.5), (23, 2), (26.5, 4), (29.5, 6.5), (28, 8.5), (22, 9.5),
             (15, 9.5), (11, 8), (6, 7), (2, 6)], 3)          # carenado
    cv.poly([(4, 3), (11.5, 3.6), (11.5, 5), (5, 4.8)], 1)    # asiento
    cv.line(13.5, 3.4, 19, 3, 2)                              # brillo tanque
    cv.rect(12, 8, 18, 12, 1); cv.line(13, 9, 17, 9, 2); cv.line(13, 11, 17, 11, 2)  # motor
    cv.line(20, 1, 22.5, 1, 1)                                # manubrio
    cv.line(23.5, 0, 25.5, 2.5, 2)                            # parabrisas
    cv.rect(28, 6, 29, 6, 2)                                  # faro
    cv.line(17, 7, 26, 6, 1)                                  # linea carenado
    cv.set(2, 5, 1)                                           # luz trasera
    return cv

def luxury_car(phase):
    cv = Canvas(48, 16)
    # carroceria baja deportiva
    for x in range(1, 47):
        top = 7
        if 13 <= x <= 31: top = 2 if 17 <= x <= 27 else 2 + (17 - x if x < 17 else x - 27) * 0.9
        if x > 31: top = 6 + (x - 31) * 0.12
        for y in range(int(top), 13): cv.set(x, y, 3)
    # ventanas
    for x in range(15, 31):
        for y in range(3, 7):
            if (x >= 18 or y >= 3 + (18 - x) * 0.9) and (x <= 27 or y >= 3 + (x - 27) * 1.1):
                cv.set(x, y, 2)
    cv.line(22, 3, 22, 6, 3)                                # pilar
    cv.ellipse(25, 4.2, 1.3, 1.3, 1)                         # conductor
    cv.line(2, 9, 45, 9, 2)                                 # franja
    cv.line(23, 7, 23, 11, 1)                                # puerta
    cv.rect(45, 7, 46, 8, 2)                                 # faro
    cv.rect(1, 7, 2, 8, 1)
    cv.line(1, 12, 46, 12, 1)                                # paragolpes
    wheel(cv, 10, 11.5, 4.5, phase)
    wheel(cv, 38, 11.5, 4.5, phase + .5)
    cv.line(33, 6, 44, 7, 2)                                 # brillo capot
    return cv

def police_car():
    cv = Canvas(48, 16)
    for x in range(1, 47):
        top = 7
        if 12 <= x <= 33: top = 2 if 16 <= x <= 29 else 2 + (16 - x if x < 16 else x - 29) * 1.1
        for y in range(int(top), 13): cv.set(x, y, 3)
    for x in range(14, 32):
        for y in range(3, 7):
            if (x >= 16 or y >= 3 + (16 - x)) and (x <= 29 or y >= 3 + (x - 29)):
                cv.set(x, y, 1)
    cv.line(22, 3, 22, 6, 3)
    cv.rect(14, 8, 33, 10, 2)                                # franja puertas
    cv.line(23, 8, 23, 11, 1)
    cv.rect(45, 7, 46, 8, 2)
    cv.line(1, 12, 46, 12, 1)
    cv.rect(0, 9, 1, 11, 1); cv.rect(46, 9, 47, 11, 1)
    wheel(cv, 10, 11.5, 4.5, 0)
    wheel(cv, 38, 11.5, 4.5, .5)
    return cv

def heli_body():
    cv = Canvas(48, 16)
    cv.ellipse(12, 7, 10, 5.5, 3)                            # cabina
    cv.rect(18, 4, 44, 6, 3)                                 # cola
    cv.rect(40, 1, 44, 6, 3)                                 # aleta
    cv.ellipse(9, 6, 5, 3.5, 2)                              # vidrio
    cv.line(4, 9, 20, 9, 2)                                  # franja
    cv.rect(11, 0, 15, 1, 1)                                 # eje
    cv.line(5, 14, 22, 14, 1); cv.line(9, 11, 8, 14, 1); cv.line(18, 11, 19, 14, 1)  # patines
    cv.rect(2, 10, 5, 11, 1)                                 # ametralladora
    cv.line(0, 11, 2, 11, 1)
    cv.outline(1)
    return cv

def heli_rotor(k):
    cv = Canvas(48, 8)
    if k == 0:
        cv.line(0, 6, 26, 7, 1, 1); cv.line(1, 7, 25, 7, 1)
    else:
        cv.line(4, 7, 30, 6, 1, 1); cv.line(5, 7, 28, 7, 1)
    cv.rect(12, 7, 14, 7, 1)
    # rotor de cola
    if k == 0: cv.line(42, 0, 42, 7, 1)
    else: cv.line(39, 4, 46, 4, 1)
    return cv

def explosion(k):
    R = random.Random(10 + k)
    cv = Canvas(16, 16)
    rad = [4.5, 7, 7.8][k]
    for y in range(16):
        for x in range(16):
            d = math.hypot(x - 7.5, y - 7.5) + R.uniform(-1.4, 1.4)
            if k < 2:
                c = 2 if d < rad * 0.45 else 3 if d < rad * 0.8 else 1 if d < rad else 0
            else:
                c = 1 if d < rad and R.random() < .55 else 3 if d < rad * 0.5 and R.random() < .4 else 0
            if c: cv.set(x, y, c)
    return cv

def to_tiles(cv, w, h):
    rows = cv.rows()
    tiles = []
    for ty in range(h):
        for tx in range(w):
            tiles.append([rows[ty * 8 + y][tx * 8:tx * 8 + 8] for y in range(8)])
    return tiles
