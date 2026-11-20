"""Muneco 3D (figura de accion) de Jose y Luciana segun la hoja de referencia del usuario:
chibi, pelo grande en puntas, ojos enojados, camisa hawaiana abierta con flores, short blanco,
zapatillas grandes, guardia de pelea (un puno adelante, el otro levantado con el arma).
Se renderiza en proyeccion ortografica a N angulos -> giro real de bandeja (la pose no cambia).
Contorno negro grueso en todos los bordes (estilo de la referencia) + borde blanco exterior."""
import numpy as np, math

W, H = 32, 60          # resolucion del modelo (en pantalla se dibuja a 2x)
ZN = 112               # muestras de profundidad
SCL = 0.9              # escala del modelo
CX = W / 2


# ---------------------------------------------------------------- SDFs
def sd_ell(p, c, r):
    q = [(p[i] - c[i]) / r[i] for i in range(3)]
    k = np.sqrt(q[0] ** 2 + q[1] ** 2 + q[2] ** 2)
    return (k - 1.0) * min(r)

def sd_cap(p, a, b, r, rb=None):
    if rb is None: rb = r
    pa = [p[i] - a[i] for i in range(3)]; ba = [b[i] - a[i] for i in range(3)]
    h = (pa[0] * ba[0] + pa[1] * ba[1] + pa[2] * ba[2]) / (ba[0] ** 2 + ba[1] ** 2 + ba[2] ** 2)
    h = np.clip(h, 0, 1)
    d = [pa[i] - ba[i] * h for i in range(3)]
    return np.sqrt(d[0] ** 2 + d[1] ** 2 + d[2] ** 2) - (r + (rb - r) * h)

def sd_rbox(p, c, b, r):
    q = [np.abs(p[i] - c[i]) - b[i] for i in range(3)]
    o = np.sqrt(sum(np.maximum(qi, 0) ** 2 for qi in q))
    return o + np.minimum(np.maximum(q[0], np.maximum(q[1], q[2])), 0) - r


HEAD = (0, 39.0, 0.6)
HAND = {0: (-11.4, 31.8, 4.4), 1: (-11.0, 31.4, 4.4)}


def model(ci):
    """lista de (grupo, sdf) ; ci 0 = Jose, 1 = Luciana"""
    L = []
    fem = ci == 1
    A = L.append
    # zapatillas grandes y piernas abiertas (guardia)
    for sx in (-1, 1):
        A(('shoe', lambda p, sx=sx: sd_ell(p, (sx * 7.6, 2.6, 1.4), (3.9, 2.8, 5.6))))
        A(('leg', lambda p, sx=sx: sd_cap(p, (sx * 7.0, 4.6, 0.2), (sx * 5.2, 12.0, 0.2), 2.9 if not fem else 2.6)))
        A(('shorts', lambda p, sx=sx: sd_cap(p, (sx * 3.4, 15.6, 0), (sx * 4.8, 13.4, 0.3), 3.5 if not fem else 3.3)))
    A(('shorts', lambda p: sd_rbox(p, (0, 16.4, 0), (4.2, 1.2, 2.8), 2.2)))
    # torso
    A(('torso', lambda p: sd_ell(p, (0, 23.6, 0), (9.2 if not fem else 8.4, 7.0, 6.2))))
    # cabeza + orejas
    A(('head', lambda p: sd_ell(p, HEAD, (10.6, 10.0, 9.6))))
    for sx in (-1, 1):
        A(('ear', lambda p, sx=sx: sd_ell(p, (sx * 10.0, 38.0, 1.4), (1.5, 2.1, 1.5))))
        if fem:
            A(('earring', lambda p, sx=sx: sd_ell(p, (sx * 10.3, 35.4, 1.6), (1.1, 1.1, 1.1))))
    # pelo
    if not fem:
        A(('hair', lambda p: sd_ell(p, (0, 42.6, -1.6), (11.6, 9.4, 11.2))))
        spikes = [((0, 48, -1), (1, 57.5, -3), 4.6, 0.8), ((-5, 47, 0), (-8.5, 55.5, -1), 4.0, 0.8),
                  ((5, 47, 0), (8.8, 55, -1.5), 4.0, 0.8), ((-3, 47, -5), (-5.5, 54, -11.5), 4.2, 0.8),
                  ((3, 47, -5), (5.5, 53.5, -12), 4.2, 0.8), ((0, 43, -8), (0, 45.5, -15.5), 4.6, 1.0),
                  ((-6, 42, -7), (-10.5, 43.5, -13), 3.8, 0.8), ((6, 42, -7), (10.5, 43.5, -13), 3.8, 0.8),
                  ((-9, 44, -1), (-14, 47.5, -3.5), 3.4, 0.8), ((9, 44, -1), (14, 47.5, -3.5), 3.4, 0.8),
                  ((-2, 47, 5), (-1.5, 52, 10.5), 3.4, 0.8), ((3, 47, 5), (5.5, 51, 10), 3.4, 0.8),
                  ((-3.5, 45.5, 7), (-2.6, 41.5, 10.0), 2.5, 0.6), ((2.6, 45.5, 7), (3.6, 41.8, 9.8), 2.4, 0.6)]
    else:
        A(('hair', lambda p: sd_ell(p, (0, 42.8, -1.4), (11.8, 9.6, 11.2))))
        spikes = [((-3, 47, 4), (-6.5, 50.5, 9.5), 3.6, 0.9), ((2, 47.5, 4), (6, 50, 9.8), 3.6, 0.9),
                  ((-4, 45, 7.5), (-3.2, 41.6, 10.0), 2.6, 0.7), ((3, 45, 7.5), (2.2, 41.8, 10.0), 2.4, 0.7),
                  ((-9, 42, 3), (-9.8, 32.5, 4.6), 2.6, 1.4), ((9, 42, 3), (9.8, 32.5, 4.6), 2.6, 1.4),
                  ((0, 50, -6), (0, 53, -13), 3.6, 3.2), ((0, 53, -13), (0, 47, -19), 3.4, 2.8),
                  ((0, 47, -19), (0, 38, -19.5), 2.8, 1.6), ((0, 38, -19.5), (2, 33, -17), 1.6, 0.6)]
        A(('scrunch', lambda p: sd_ell(p, (0, 51.0, -9.0), (3.2, 3.2, 2.4))))
    for a, b, ra, rb in spikes:
        A(('hair', lambda p, a=a, b=b, ra=ra, rb=rb: sd_cap(p, a, b, ra, rb)))
    # brazos: izquierdo (+x) puno adelante a la altura del pecho, derecho (-x) levantado con el arma
    sh = 8.9 if not fem else 8.2
    ar = 2.7 if not fem else 2.4
    A(('sleeve', lambda p: sd_cap(p, (sh, 28.4, 0), (sh + 2.4, 25.6, 0.4), 3.4)))
    A(('arm', lambda p: sd_cap(p, (sh + 2.4, 25.6, 0.4), (sh + 3.6, 21.2, 3.0), ar)))
    A(('arm', lambda p: sd_cap(p, (sh + 3.6, 21.2, 3.0), (7.4, 23.6, 7.6), ar - 0.1)))
    A(('fist', lambda p: sd_ell(p, (6.9, 24.0, 8.4), (3.4, 3.2, 3.2))))
    A(('sleeve', lambda p: sd_cap(p, (-sh, 28.4, 0), (-sh - 2.4, 25.6, 0.4), 3.4)))
    A(('arm', lambda p: sd_cap(p, (-sh - 2.4, 25.6, 0.4), (-sh - 4.0, 22.4, 2.0), ar)))
    A(('arm', lambda p: sd_cap(p, (-sh - 4.0, 22.4, 2.0), (-11.6, 29.6, 4.0), ar - 0.1)))
    A(('fist', lambda p: sd_ell(p, HAND[ci], (3.3, 3.4, 3.2))))
    return L


def body_model(ci):
    """cuerpo en la pose de la referencia del usuario (guardia), sin cabeza:
    piernas bien abiertas con rodillas flexionadas y pies hacia afuera, short ancho,
    puno izquierdo (de la pantalla) levantado al costado de la cara, el otro adelante a la altura del pecho"""
    L = []
    fem = ci == 1
    A = L.append
    lr = 2.9 if not fem else 2.6
    for sx in (-1, 1):
        A(('shoe', lambda p, sx=sx: sd_ell(p, (sx * 11.0, 2.5, 1.6), (4.6, 2.8, 5.0))))
        A(('leg', lambda p, sx=sx: sd_cap(p, (sx * 10.6, 4.4, 0.6), (sx * 9.8, 8.6, 1.8), lr)))
        A(('leg', lambda p, sx=sx: sd_cap(p, (sx * 9.8, 8.6, 1.8), (sx * 6.8, 12.2, 0.6), lr + 0.3)))
        A(('shorts', lambda p, sx=sx: sd_cap(p, (sx * 3.4, 16.0, 0), (sx * 6.8, 12.4, 0.6), 4.1 if not fem else 3.8)))
    A(('shorts', lambda p: sd_rbox(p, (0, 16.6, 0), (4.6, 1.4, 3.0), 2.4)))
    A(('torso', lambda p: sd_ell(p, (0, 23.6, 0), (9.4 if not fem else 8.6, 6.8, 6.2))))
    A(('neck', lambda p: sd_cap(p, (0, 28, 0.3), (0, 37, -0.5), 3.0)))
    sh = 8.9 if not fem else 8.2
    ar = 2.8 if not fem else 2.5
    # brazo de adelante (+x): codo abajo, puno adelante del pecho del lado derecho de la pantalla
    A(('sleeve', lambda p: sd_cap(p, (sh, 28.2, 0), (sh + 2.2, 25.2, 0.6), 3.4)))
    A(('arm', lambda p: sd_cap(p, (sh + 2.2, 25.2, 0.6), (sh + 4.6, 20.0, 2.0), ar)))
    A(('arm', lambda p: sd_cap(p, (sh + 4.6, 20.0, 2.0), (sh + 3.6, 19.0, 6.4), ar - 0.1)))
    A(('fist', lambda p: sd_ell(p, (sh + 3.4, 19.2, 7.2), (3.8, 3.6, 3.6))))
    # brazo levantado (-x): puno al costado de la cara
    A(('sleeve', lambda p: sd_cap(p, (-sh, 28.2, 0), (-sh - 2.4, 25.4, 0.6), 3.4)))
    A(('arm', lambda p: sd_cap(p, (-sh - 2.4, 25.4, 0.6), (-sh - 6.0, 21.6, 1.6), ar)))
    A(('arm', lambda p: sd_cap(p, (-sh - 6.0, 21.6, 1.6), (-sh - 6.4, 28.6, 2.6), ar - 0.1)))
    A(('fist', lambda p: sd_ell(p, (-sh - 6.4, 30.4, 2.8), (3.8, 3.8, 3.6))))
    return L


def body_model_relajado(ci):
    """solo el cuerpo (sin cabeza), parado normal: brazos abajo con los punos al costado de la cadera,
    piernas un poco abiertas. La cabeza se pone despues (dibujo de la referencia)."""
    L = []
    fem = ci == 1
    A = L.append
    for sx in (-1, 1):
        A(('shoe', lambda p, sx=sx: sd_ell(p, (sx * 5.4, 2.6, 1.4), (3.6, 2.7, 5.4))))
        A(('leg', lambda p, sx=sx: sd_cap(p, (sx * 5.0, 4.6, 0.2), (sx * 4.4, 12.0, 0.2), 2.8 if not fem else 2.5)))
        A(('shorts', lambda p, sx=sx: sd_cap(p, (sx * 3.2, 15.8, 0), (sx * 4.4, 12.6, 0.3), 3.6 if not fem else 3.4)))
    A(('shorts', lambda p: sd_rbox(p, (0, 16.6, 0), (4.0, 1.4, 2.8), 2.2)))
    A(('torso', lambda p: sd_ell(p, (0, 23.8, 0), (8.6 if not fem else 8.0, 7.0, 5.8))))
    A(('neck', lambda p: sd_cap(p, (0, 28, 0.3), (0, 32, 0.3), 2.6)))
    sh = 8.4 if not fem else 7.8
    ar = 2.6 if not fem else 2.3
    for sx in (-1, 1):
        A(('sleeve', lambda p, sx=sx: sd_cap(p, (sx * sh, 28.0, 0), (sx * (sh + 1.8), 24.6, 0.2), 3.3)))
        A(('arm', lambda p, sx=sx: sd_cap(p, (sx * (sh + 1.8), 24.6, 0.2), (sx * (sh + 2.6), 19.6, 0.6), ar)))
        A(('arm', lambda p, sx=sx: sd_cap(p, (sx * (sh + 2.6), 19.6, 0.6), (sx * (sh + 1.8), 16.4, 1.4), ar - 0.1)))
        A(('fist', lambda p, sx=sx: sd_ell(p, (sx * (sh + 1.6), 15.2, 1.6), (3.1, 3.1, 3.0))))
    return L


# rango de clases para decidir de que lado va la linea negra cuando estan a la misma profundidad
RANK = {'skin': 0, 'shirt': 1, 'under': 2, 'white': 3, 'shoe': 3, 'hair': 4, 'eye': 5, 'pink': 5}


def flowers(x, y, z, base):
    """flores blancas (rombos con centro) de la camisa hawaiana"""
    for fx, fy, fz in ((-6.0, 25.5, 4.6), (5.6, 21.0, 4.4), (-4.5, 20.0, -5.0), (5.0, 26.6, -4.2), (-9.0, 23.0, -0.5),
                       (9.0, 23.5, 0.5), (0, 23.0, -6.2), (-11.5, 26.5, 0.6), (11.5, 26.5, 0.6), (-2.5, 28.0, -5.5)):
        d = abs(x - fx) + abs(y - fy) + abs(z - fz) * 0.5
        if d < 1.6: return 'w' if d > 0.5 else base
    return base


def surface(ci, g, P):
    """(simbolo de color, clase de contorno) para un punto de superficie del grupo g"""
    fem = ci == 1
    x, y, z = P
    if g == 'shoe':
        if y < 1.1: return 'k', 'shoe'
        if z > 3.5 and 2.6 < y < 3.4: return 'k', 'shoe'           # linea de la puntera
        return 'w', 'shoe'
    if g in ('leg', 'arm', 'ear', 'fist', 'neck'):
        return 's', 'skin'
    if g in ('earring', 'scrunch'):
        return 'c', 'pink'
    if g == 'shorts':
        if abs(x) < 0.5 and y < 15.0 and z > 0: return 'k', 'white'
        return 'w', 'white'
    if g == 'sleeve':
        return flowers(x, y, z, 'c'), 'shirt'
    if g == 'torso':
        if z > 1.0 and abs(x) < (2.4 if not fem else 2.0) + (28 - y) * 0.06: return 'w', 'under'   # remera
        if y > 29.0 and z > -1 and abs(x) < 5: return 's', 'skin'                                  # cuello
        return flowers(x, y, z, 'c'), 'shirt'
    if g == 'hair':
        return 'H', 'hair'
    if g == 'head':
        hx, hy, hz = x - HEAD[0], y - HEAD[1], z - HEAD[2]
        phi = math.atan2(hx, hz)                 # 0 = de frente
        side = 1.12 if fem else 1.28
        bang = 3.4 + 1.6 * abs(math.sin(phi * 5.0 + 0.4))
        if abs(phi) > side or hy > bang: return 'H', 'hair'
        if hz > 3.0:
            for s in (-1, 1):
                ex = s * 4.0
                t = (hx - ex) * s                # + hacia afuera
                if -1.7 <= t <= 1.8 and -2.2 <= hy <= 0.4:
                    if t <= -0.2 and hy <= 0.0: return 'k', 'eye'      # pupila del lado de adentro
                    return 'w', 'eye'
                if -2.0 <= t <= 2.3 and 0.4 < hy <= 1.0 + 0.3 * (t + 2.0):
                    return 'k', 'eye'                                 # ceja/parpado enojado
                if fem and 2.3 < t <= 3.3 and -0.6 <= hy <= 1.4:
                    return 'k', 'eye'                                 # pestana
            if abs(hx) < (1.6 if not fem else 1.1) and -6.2 < hy < -5.5: return 'k', 'eye'   # boca
        return 's', 'skin'
    return 's', 'skin'


def render(ci, theta, body=False, Wd=None, Hd=None, scl=None):
    """theta en radianes: 0 = de frente. Grilla HxW de simbolos (k s h w c o .) y la mano (x, y, visible, z)"""
    global W, H, CX, SCL
    sv = (W, H, CX, SCL)
    if Wd: W, H, CX, SCL = Wd, Hd, Wd / 2, scl
    try:
        return _render(ci, theta, body_model(ci) if body else model(ci), not body)
    finally:
        W, H, CX, SCL = sv


def _render(ci, theta, L, ring):
    us = (np.arange(W) + 0.5 - CX) / SCL
    vs = (H - (np.arange(H) + 0.5)) / SCL
    zs = np.linspace(26, -26, ZN)
    U, V, Z = np.meshgrid(us, vs, zs, indexing='xy')   # (H, W, ZN)
    c, s = math.cos(theta), math.sin(theta)
    X = U * c - Z * s
    Zm = U * s + Z * c
    P = (X, V, Zm)
    best = np.full(U.shape, 1e9); gid = np.full(U.shape, -1)
    names = []
    for i, (g, f) in enumerate(L):
        d = f(P)
        m = d < best
        best = np.where(m, d, best); gid = np.where(m, i, gid)
        names.append(g)
    inside = best < 0
    hit = inside.any(axis=2)
    zi = np.argmax(inside, axis=2)
    out = [['.'] * W for _ in range(H)]
    cls = [[None] * W for _ in range(H)]
    dep = np.full((H, W), -99.0)
    for yy in range(H):
        for xx in range(W):
            if not hit[yy, xx]: continue
            k = zi[yy, xx]
            g = names[gid[yy, xx, k]]
            Pm = (X[yy, xx, k], V[yy, xx, k], Zm[yy, xx, k])
            col, cl = surface(ci, g, Pm)
            if col == 'H':
                ph = math.atan2(Pm[0], Pm[2] + 1)
                col = 'k' if math.sin(ph * 6 + Pm[1] * 0.55) > 0.955 else 'h'
                cl = 'hair'
            out[yy][xx] = col
            cls[yy][xx] = cl
            dep[yy, xx] = zs[k]
    # contornos negros en cada borde entre clases (del lado de atras, o del de menor rango)
    edge = set()
    for yy in range(H):
        for xx in range(W):
            a = cls[yy][xx]
            if a is None: continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                X2, Y2 = xx + dx, yy + dy
                if not (0 <= X2 < W and 0 <= Y2 < H): continue
                b = cls[Y2][X2]
                if b is None: continue
                dd = dep[Y2, X2] - dep[yy, xx]
                if a != b:
                    if dd > 1.2 or (abs(dd) <= 1.2 and RANK[a] < RANK[b]): edge.add((xx, yy))
                elif dd > 3.0:
                    edge.add((xx, yy))
    for xx, yy in edge: out[yy][xx] = 'k'
    # borde blanco exterior separado por el contorno negro
    fig = [[out[y][x] != '.' for x in range(W)] for y in range(H)]
    def near(x, y, r):
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                if abs(dx) + abs(dy) <= r and 0 <= x + dx < W and 0 <= y + dy < H and fig[y + dy][x + dx]: return True
        return False
    if ring:
        for y in range(H):
            for x in range(W):
                if not fig[y][x] and not near(x, y, 1) and near(x, y, 2): out[y][x] = 'o'
    # mano (arma)
    hx, hy, hz = HAND[ci]
    sx = hx * c + hz * s
    sz = -hx * s + hz * c
    vis_px = int(math.floor(sx * SCL + CX)); vis_py = int(math.floor(H - hy * SCL))
    vis = 0 <= vis_py < H and 0 <= vis_px < W and dep[vis_py, vis_px] <= sz + 2.0
    return out, (sx * SCL + CX, H - hy * SCL, bool(vis), sz)


if __name__ == '__main__':
    from PIL import Image
    C = {'k': (0, 0, 0), 's': (252, 160, 68), 'h': (136, 72, 0), 'w': (250, 250, 250), 'o': (250, 250, 250), 'c': (60, 190, 250)}
    N = 8
    im = Image.new('RGB', (N * W, 2 * H), (0, 0, 0))
    for ci in range(2):
        C['c'] = (60, 190, 250) if ci == 0 else (248, 120, 200)
        for a in range(N):
            g, hand = render(ci, 2 * math.pi * a / N)
            for y in range(H):
                for x in range(W):
                    if g[y][x] != '.': im.putpixel((a * W + x, ci * H + y), C[g[y][x]])
    im.resize((im.width * 5, im.height * 5), Image.NEAREST).save('doll.png')
