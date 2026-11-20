"""Moto y auto tomados de las referencias del usuario (ref/moto.png, ref/auto.png): se lee la grilla de
pixeles del dibujo y se clasifican los colores en las clases del juego."""
import numpy as np
from PIL import Image

def grid(path, p):
    im = np.array(Image.open(path).convert('RGB')).astype(float)
    H, W, _ = im.shape
    best = None
    for oy in np.arange(0, p, 1.0):
        for ox in np.arange(0, p, 1.0):
            ys = (np.arange(oy + p / 2, H, p)).astype(int); xs = (np.arange(ox + p / 2, W, p)).astype(int)
            # varianza dentro de cada celda (muestras alrededor del centro)
            tot = 0
            for d in (-p * .3, p * .3):
                a = im[np.clip(ys + int(d), 0, H - 1)][:, xs]; b = im[ys][:, xs]
                tot += np.abs(a - b).sum()
            if best is None or tot < best[0]: best = (tot, ox, oy)
    _, ox, oy = best
    ys = (np.arange(oy + p / 2, H - p / 4, p)).astype(int); xs = (np.arange(ox + p / 2, W - p / 4, p)).astype(int)
    # color de cada celda: mediana de una ventana central
    r = max(1, int(p * .2))
    out = np.zeros((len(ys), len(xs), 3))
    for i, y in enumerate(ys):
        for j, x in enumerate(xs):
            out[i, j] = np.median(im[max(0, y - r):y + r + 1, max(0, x - r):x + r + 1].reshape(-1, 3), axis=0)
    return out

REF = {'k': [(0, 0, 0), (25, 25, 30)], 'w': [(250, 250, 250), (240, 240, 240)], 'g': [(185, 190, 195), (150, 155, 160)],
       's': [(235, 155, 45), (215, 135, 40)], 'h': [(140, 75, 20), (110, 55, 15), (165, 85, 15)],
       'c': [(80, 200, 220), (60, 180, 205), (140, 225, 240)], '.': []}

def classify(g, bg):
    cols = []; syms = []
    for k, L in REF.items():
        for c in L: cols.append(c); syms.append(k)
    for c in bg: cols.append(c); syms.append('.')
    cols = np.array(cols, float)
    d = ((g[:, :, None, :] - cols[None, None]) ** 2).sum(-1)
    return [list(r) for r in np.array(syms)[d.argmin(-1)]]

def crop(g):
    ys = [y for y, r in enumerate(g) if any(v != '.' for v in r)]
    xs = [x for r in g for x, v in enumerate(r) if v != '.']
    return [r[min(xs):max(xs) + 1] for r in g[min(ys):max(ys) + 1]]

def exterior(g, bgsyms):
    """el fondo (y el negro conectado al borde) pasa a '.', despues se vuelve a poner el contorno negro"""
    H, W = len(g), len(g[0])
    from collections import deque
    seen = [[False] * W for _ in range(H)]
    q = deque((y, x) for y in range(H) for x in (0, W - 1)); q.extend((y, x) for x in range(W) for y in (0, H - 1))
    while q:
        y, x = q.popleft()
        if not (0 <= y < H and 0 <= x < W) or seen[y][x] or g[y][x] not in bgsyms: continue
        seen[y][x] = True
        q.extend(((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)))
    out = [[('.' if seen[y][x] else g[y][x]) for x in range(W)] for y in range(H)]
    out = [[('.' if v == '.' else v) for v in r] for r in out]
    for y in range(H):
        for x in range(W):
            if out[y][x] == '.' and any(0 <= y + dy < H and 0 <= x + dx < W and out[y + dy][x + dx] not in '.k' and not seen[y + dy][x + dx]
                                        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                out[y][x] = 'K'
    out = [[('k' if v == 'K' else v) for v in r] for r in out]
    # negro suelto (lineas de velocidad del piso, etc.): componentes solo de negro sin color al lado
    from scipy import ndimage
    blk = np.array([[v == 'k' for v in r] for r in out])
    lab, n = ndimage.label(blk)
    col = np.array([[v not in '.k' for v in r] for r in out])
    near = ndimage.binary_dilation(col)
    for i in range(1, n + 1):
        m = lab == i
        if not (m & near).any():
            for y, x in zip(*np.nonzero(m)): out[y][x] = '.'
    # colores sueltos fuera del dibujo principal
    fig = np.array([[v != '.' for v in r] for r in out])
    lab, n = ndimage.label(fig)
    if n > 1:
        sz = ndimage.sum(np.ones_like(lab), lab, range(1, n + 1)); keep = 1 + int(np.argmax(sz))
        for y, x in zip(*np.nonzero((lab != keep) & fig)): out[y][x] = '.'
    return out

def moto_ref():
    g = grid('ref/moto.png', 16.5)
    return crop(exterior(classify(g, [(0, 0, 0)]), 'k.'))

def auto_ref():
    g = grid('ref/auto.png', 21.0)
    c = classify(g, [(53, 71, 86), (60, 75, 90), (214, 222, 228), (205, 212, 218)])
    return crop(exterior(c, '.'))

if __name__ == '__main__':
    for name, g in (('moto', moto_ref()), ('auto', auto_ref())):
        print(name, len(g[0]), len(g))
        for r in g: print(''.join(r))


# ------------------------------------------------------------ armado para el juego
def pad(g, n=1):
    W = len(g[0])
    return [['.'] * (W + 2 * n) for _ in range(n)] + [['.'] * n + r + ['.'] * n for r in g] + [['.'] * (W + 2 * n) for _ in range(n)]

def rider_mask(g, top_rows):
    """pixeles del conductor: piel/pelo de las filas de arriba + su contorno"""
    H, W = len(g), len(g[0])
    m = [[False] * W for _ in range(H)]
    for y in range(min(H, top_rows)):
        for x in range(W):
            if g[y][x] in 'sh': m[y][x] = True
    for y in range(min(H, top_rows)):
        for x in range(W):
            if g[y][x] == 'k' and any(0 <= y + dy < H and 0 <= x + dx < W and m[y + dy][x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1))):
                m[y][x] = True
    return m

def add_gun(g, rows):
    """pistola en la mano de adelante (la piel mas a la derecha en esas filas) apuntando hacia adelante"""
    best = None
    for y in rows:
        for x in range(len(g[0])):
            if g[y][x] == 's' and (best is None or x > best[0]): best = (x, y)
    hx, hy = best
    gy = hy - 1
    W = len(g[0])
    need = hx + 8 - W
    if need > 0: g = [r + ['.'] * need for r in g]
    for x in range(hx + 1, hx + 6):
        g[gy][x] = 'g'; g[gy - 1][x] = 'k' if g[gy - 1][x] in '.' else g[gy - 1][x]
        g[gy + 1][x] = 'k' if x > hx + 2 else g[gy + 1][x]
    g[gy + 1][hx + 1] = 'g'; g[gy + 1][hx + 2] = 'g'; g[gy + 2][hx + 1] = 'k'; g[gy + 2][hx + 2] = 'k'
    g[gy][hx + 6] = 'k'
    return g, (hx + 6, gy)

def luci_hair(g):
    """cola de caballo hacia atras (izquierda) con gomita rosa (color de su ropa)"""
    H, W = len(g), len(g[0])
    hs = [(x, y) for y in range(H) for x in range(W) if g[y][x] == 'h']
    y0 = min(y for x, y in hs)
    xl = min(x for x, y in hs if y <= y0 + 5)
    tail = ["..kkk..", ".khhhk.", "khhhhk.", "khhhk..", "khhk...", ".khk...", "..k...."]
    for dy, row in enumerate(tail):
        for dx, v in enumerate(row):
            X, Y = xl - 6 + dx, y0 + 2 + dy
            if v != '.' and 0 <= Y < H and 0 <= X < W and g[Y][X] in '.k': g[Y][X] = v
    for Y, X in ((y0 + 2, xl), (y0 + 3, xl), (y0 + 2, xl + 1), (y0 + 3, xl + 1)):
        g[Y][X] = 'C'
    return g

def spin(g, rows_from):
    """segundo cuadro: rayos de las ruedas girados (blanco <-> gris)"""
    out = [r[:] for r in g]
    for y in range(rows_from, len(g)):
        for x in range(len(g[0])):
            v = g[y][x]
            if v == 'w': out[y][x] = 'g'
            elif v == 'g': out[y][x] = 'w'
    return out

def wheels_dark(g, rows_from):
    """el gris de las llantas no existe en la paleta del jugador: va negro (goma)"""
    return [[('k' if (y >= rows_from and v == 'g') else ('c' if v == 'C' else v)) for v in r] for y, r in enumerate(g)]

def vehicle(kind, ci):
    """-> [(full, body)] x2 cuadros, punto de la boca del arma (x, y) en la grilla"""
    if kind == 'moto':
        g = pad(moto_ref()); top = 24; wheel_from = 31; gun_rows = range(19, 22)
    else:
        g = pad(auto_ref()); top = 19; wheel_from = 29; gun_rows = range(16, 19)
    g, muzzle = add_gun(g, gun_rows)
    if ci == 1:
        g = luci_hair(g)
    m = rider_mask(g, top + 2)
    for y in range(len(g)):
        for x in range(len(g[0])):
            if g[y][x] in 'gC' and y < top: m[y][x] = True
    body = [[('.' if m[y][x] else g[y][x]) for x in range(len(g[0]))] for y in range(len(g))]
    # el hueco que deja el conductor dentro del vehiculo se rellena con carroceria (asi el vehiculo
    # estacionado es exactamente la capa del vehiculo y comparten tiles)
    fill_from = 21 if kind == 'moto' else 99
    H, W = len(body), len(body[0])
    for y in range(fill_from, H):
        xs = [x for x in range(W) if body[y][x] != '.']
        if not xs: continue
        for x in range(min(xs), max(xs) + 1):
            if body[y][x] == '.' and (m[y][x] or (kind == 'moto' and y < 31)): body[y][x] = 'c'
    if kind == 'moto':                         # la punta suelta del escape (ahorra tiles)
        for y in range(H - 5, H):
            for x in range(0, 8):
                g_ = body[y][x]
                body[y][x] = '.'
    if kind == 'moto':                         # el parabrisas suelto va con el conductor
        for y in range(fill_from - 1):
            body[y] = ['.'] * W
    else:                                      # auto: el parabrisas va con el conductor (patrullero sin parabrisas)
        for y in range(top - 1):
            body[y] = ['.'] * W
    for y in range(0, H):
        for x in range(W):
            if body[y][x] == '.' and any(0 <= y + dy < H and 0 <= x + dx < W and body[y + dy][x + dx] not in '.k' for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                body[y][x] = 'k'
    frames = []
    for ph in range(2):
        f = g if ph == 0 else spin(g, wheel_from)
        b = body if ph == 0 else spin(body, wheel_from)
        frames.append((wheels_dark(f, wheel_from), wheels_dark(b, wheel_from)))
    return frames, muzzle

def parked(kind):
    """vehiculo sin conductor = exactamente la capa del vehiculo del cuadro 0 (comparte tiles)"""
    fr, _ = vehicle(kind, 0)
    return [r[:] for r in fr[0][1]]
