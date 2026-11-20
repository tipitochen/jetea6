"""Vistas de la rotacion del ARSENAL tomadas EXACTAMENTE de la hoja de referencia del usuario (ref/rot.png):
fila 0 = Jose, fila 1 = Luciana, 6 vistas cada uno. Se recorta cada figura, se clasifican los colores,
se quita la pistola dibujada (el arma elegida se dibuja con sprites en ese lugar) y se reduce a la
resolucion de la pantalla (cabe en 96x120)."""
import numpy as np
from PIL import Image
from scipy import ndimage

SRC = 'ref/rot.png'
FIG_X = [[(8, 207), (207, 361), (367, 520), (515, 700), (704, 850), (851, 1021)],
         [(2, 182), (175, 358), (366, 529), (526, 682), (687, 845), (852, 1022)]]
FIG_Y = [(20, 275), (296, 564)]
SCALE = 0.45
GUNMIN = 250

REFC = {   # colores representativos de la referencia -> simbolo
    'k': [(0, 0, 0), (30, 10, 5), (45, 25, 20)],
    'w': [(242, 242, 242), (215, 215, 215), (180, 180, 180)],
    's': [(245, 150, 75), (220, 145, 85), (240, 145, 50)],
    'h': [(100, 30, 5), (75, 30, 15), (130, 60, 25), (100, 50, 20)],
    'g': [(100, 100, 100), (130, 130, 130), (60, 60, 60)],
}
SHIRT = [[(0, 165, 220), (0, 140, 210), (30, 120, 190)], [(240, 55, 125), (215, 50, 120), (190, 40, 100)]]


def classify(rgb, ci):
    cols = []; syms = []
    for k, L in REFC.items():
        for c in L: cols.append(c); syms.append(k)
    for c in SHIRT[ci]: cols.append(c); syms.append('c')
    cols = np.array(cols, float)
    d = ((rgb[:, :, None, :] - cols[None, None, :, :]) ** 2).sum(-1)
    idx = d.argmin(-1)
    return np.array(syms)[idx]


def figure(ci, vi):
    im = np.array(Image.open(SRC).convert('RGB')).astype(float)
    x0, x1 = FIG_X[ci][vi]; y0, y1 = FIG_Y[ci]
    sub = im[y0:y1, x0:x1]
    sym = classify(sub, ci)
    nonblack = sub.sum(2) > 60
    lab, n = ndimage.label(ndimage.binary_dilation(nonblack, iterations=2))
    sizes = ndimage.sum(np.ones_like(lab), lab, range(1, n + 1))
    mask = ndimage.binary_fill_holes(lab == (1 + int(np.argmax(sizes))))
    mask = ndimage.binary_erosion(mask, iterations=2)
    # quitar el anillo blanco exterior (se vuelve a generar despues): blanco conectado al exterior
    near_out = ndimage.binary_dilation(~mask, iterations=6)
    wl, wn = ndimage.label(sym == 'w')
    keep_ring = np.zeros_like(mask)
    for i in range(1, wn + 1):
        comp = wl == i
        if (comp & near_out).sum() > 0.6 * comp.sum(): keep_ring |= comp
    body = mask & ~keep_ring
    # el negro de afuera del contorno (entre el anillo y el fondo) tampoco es figura
    bl, bn = ndimage.label(body & (sym != 'k'))
    # pistola: gris -> se borra junto con su contorno negro
    gun = (sym == 'g') & body
    gl, gn = ndimage.label(gun)
    gun_big = np.zeros_like(gun)
    for i in range(1, gn + 1):
        if (gl == i).sum() > GUNMIN: gun_big |= gl == i
    anchor = None
    if gun_big.sum() > 0:
        colored = body & np.isin(sym, ['s', 'c', 'h']) & ~gun_big
        zone = ndimage.binary_dilation(gun_big, iterations=12) & ~ndimage.binary_dilation(colored, iterations=3)
        ys, xs = np.nonzero(gun_big)
        # el agarre: el punto del arma mas cercano a la piel (la mano)
        skin = body & (sym == 's')
        sy, sx = np.nonzero(skin)
        best = None
        for y, x in zip(ys[::3], xs[::3]):
            d = ((sy - y) ** 2 + (sx - x) ** 2).min()
            if best is None or d < best[0]: best = (d, x, y)
        gx = xs.mean(); gy = ys.mean()
        anchor = (best[1], best[2], gx < best[1])     # (x, y, el cano apunta a la izquierda)
        body = body & ~(zone | gun_big)
        # el negro que quedo suelto del contorno del arma
        bl, bn = ndimage.label(body)
        if bn > 1:
            sz = ndimage.sum(np.ones_like(bl), bl, range(1, bn + 1))
            body = bl == (1 + int(np.argmax(sz)))
    # contornos negros sueltos (del arma borrada): el negro solo queda si hay color cerca
    if anchor:
        content = body & np.isin(sym, ['s', 'c', 'h', 'w'])
        near_gun = ndimage.binary_dilation(gun_big, iterations=22)
        body = body & (content | ndimage.binary_dilation(content, iterations=4) | ~near_gun)
    sym = np.where(body, sym, '.')
    sym = np.where((sym == 'g'), 'k', sym)
    # recortar
    ys, xs = np.nonzero(body)
    ty0, ty1, tx0, tx1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    sym = sym[ty0:ty1, tx0:tx1]
    if anchor: anchor = (anchor[0] - tx0, anchor[1] - ty0, anchor[2])
    return sym, anchor


def downscale(sym, f):
    H, W = sym.shape
    h, w = int(round(H * f)), int(round(W * f))
    out = [['.'] * w for _ in range(h)]
    for y in range(h):
        for x in range(w):
            a0, a1 = int(y / f), max(int(y / f) + 1, int((y + 1) / f))
            b0, b1 = int(x / f), max(int(x / f) + 1, int((x + 1) / f))
            blk = sym[a0:a1, b0:b1].ravel()
            vals, cnt = np.unique(blk, return_counts=True)
            # el fondo solo gana si es mayoria clara; el negro (contorno) tiene prioridad sobre empates
            order = sorted(zip(cnt, vals), key=lambda t: (t[0] + (0.6 if t[1] == 'k' else 0) - (0.4 if t[1] == '.' else 0)), reverse=True)
            out[y][x] = order[0][1]
    return out


def add_ring(g):
    """contorno negro (el fondo) + borde blanco exterior, como en la referencia"""
    H, W = len(g), len(g[0])
    core = np.array([[v != '.' for v in r] for r in g])
    d1 = ndimage.binary_dilation(core)
    d2 = ndimage.binary_dilation(d1)
    ring = d2 & ~d1
    pad = [['.'] * (W + 4) for _ in range(H + 4)]
    core2 = np.zeros((H + 4, W + 4), bool); core2[2:H + 2, 2:W + 2] = core
    r1 = ndimage.binary_dilation(core2); r2 = ndimage.binary_dilation(r1, structure=np.ones((3, 3)))
    for y in range(H):
        for x in range(W): pad[y + 2][x + 2] = g[y][x]
    for y in range(H + 4):
        for x in range(W + 4):
            if r2[y, x] and not r1[y, x]: pad[y][x] = 'w'
    return pad


def views(ci):
    out = []
    for vi in range(6):
        sym, anc = figure(ci, vi)
        g = downscale(sym, SCALE)
        g = add_ring(g)
        if anc: anc = (anc[0] * SCALE + 2, anc[1] * SCALE + 2, anc[2])
        out.append((g, anc))
    return out


if __name__ == '__main__':
    C = {'k': (0, 0, 0), 's': (252, 152, 56), 'h': (124, 8, 0), 'w': (252, 252, 252), 'c': (60, 188, 252), 'g': (120, 120, 120)}
    im = Image.new('RGB', (6 * 110, 2 * 130), (0, 0, 0))
    for ci in range(2):
        C['c'] = (60, 188, 252) if ci == 0 else (248, 56, 152)
        for vi, (g, anc) in enumerate(views(ci)):
            print(ci, vi, len(g[0]), len(g), anc)
            for y, r in enumerate(g):
                for x, v in enumerate(r):
                    if v != '.': im.putpixel((vi * 110 + x, ci * 130 + y), C[v])
            if anc: im.putpixel((vi * 110 + int(anc[0]), ci * 130 + int(anc[1])), (255, 0, 0))
    im.resize((im.width * 3, im.height * 3), Image.NEAREST).save('refrot.png')
