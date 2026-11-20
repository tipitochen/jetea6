"""Giro del ARSENAL con pose fija: la cabeza de cada vista sale EXACTA de la hoja de referencia del
usuario (y su espejo para el otro lado), el cuerpo es siempre el mismo muneco "parado normal"
(brazos abajo, piernas un poco abiertas) dibujado al mismo angulo que la cabeza -> solo gira."""
import math
import numpy as np
from scipy import ndimage
import ref_rot, doll3d

# (vista de la referencia, espejar, angulo del cuerpo en grados; 0 = de frente, + = gira a la derecha)
VIEWS = [(0, False, 20), (1, False, 55), (2, False, 90), (3, False, 135), (4, False, 180),
         (3, True, 225), (2, True, 270), (1, True, 315)]
BODY_W, BODY_H, BODY_S = 60, 36, 0.9    # cuerpo a media resolucion (despues 2x)


def head(ci, vi):
    """cabeza (pelo + cara + orejas) de la vista vi de la referencia, a la escala de pantalla.
    Si la vista tenia el puno levantado (la pistola), ese puno se saca."""
    sym, anc = ref_rot.figure(ci, vi)
    g = np.array(ref_rot.downscale(sym, ref_rot.SCALE))
    H, W = g.shape
    y0 = next(y for y in range(H) if (g[y] != '.').any())
    neck = next(y for y in range(y0 + int((H - y0) * 0.35), H) if (g[y] == 'c').sum() >= 6)
    out = g.copy()
    out[neck:] = '.'
    if vi in (3, 4):
        # de espaldas: la cabeza termina donde termina el pelo (el cuello lo pone el cuerpo)
        hr = [y for y in range(H) if (out[y] == 'h').sum() >= 3]
        out[hr[-1] + 2:] = '.'
        out[out == 's'] = '.'                     # de espaldas no se ve cara: la piel es del brazo levantado
        hx_ = [x for y in range(hr[0], hr[0] + 20) for x in range(W) if out[y, x] == 'h']
        neck_x = (min(hx_) + max(hx_)) / 2
    else:
        # de frente / de costado: el eje pasa por el menton (piel de las ultimas filas)
        sx_ = [x for y in range(neck - 6, neck) for x in range(W) if out[y, x] == 's']
        neck_x = sum(sx_) / len(sx_)
    if anc: ax, ay = anc[0] * ref_rot.SCALE, anc[1] * ref_rot.SCALE
    if anc and vi == 3:
        sk = out == 's'
        lab, n = ndimage.label(sk, structure=np.ones((3, 3)))
        yy, xx = np.mgrid[0:H, 0:W]
        gone = np.zeros_like(sk)
        sizes = [(lab == i).sum() for i in range(1, n + 1)]
        face = 1 + int(np.argmax(sizes))
        for i in range(1, n + 1):
            m = lab == i
            if i != face and (np.hypot(xx[m] - ax, yy[m] - ay).min() < 7): gone |= m
        out[gone] = '.'
        near = ndimage.binary_dilation(gone, iterations=3)
        out[near & (out == 'k')] = '.'
    # punos/brazos a la altura de los hombros (no son parte de la cabeza): piel que no es la cara,
    # pegada al cuello y fuera del ancho de la cara
    sk = out == 's'
    lab, n = ndimage.label(sk, structure=np.ones((3, 3)))
    if n and vi == 3:
        sizes = [(lab == i).sum() for i in range(1, n + 1)]
        face = 1 + int(np.argmax(sizes))
        fx = np.nonzero(lab == face)[1]
        gone = np.zeros_like(sk)
        for i in range(1, n + 1):
            if i == face: continue
            ys_, xs_ = np.nonzero(lab == i)
            if ys_.max() >= neck - 9 and (xs_.max() < fx.min() + 1 or xs_.min() > fx.max() - 1): gone |= lab == i
        if anc:
            wl, wn = ndimage.label(out == 'w')
            for i in range(1, wn + 1):
                ys_, xs_ = np.nonzero(wl == i)
                if len(ys_) < 25 and np.hypot(xs_ - ax, ys_ - ay).min() < 12: gone |= wl == i
        out[gone] = '.'
        out[ndimage.binary_dilation(gone, iterations=3) & (out == 'k')] = '.'
    # rosa dentro de la cara (sombras de mejillas/boca que caen en el color de la camisa) -> piel
    cl, cn = ndimage.label(out == 'c')
    for i in range(1, cn + 1):
        m = cl == i
        ys_, xs_ = np.nonzero(m)
        if len(ys_) > 6 and ys_.mean() > y0 + (neck - y0) * 0.45:
            ring_ = ndimage.binary_dilation(m) & ~m
            if (out[ring_] == 's').sum() >= 3: out[m] = 's'
    # negro suelto (sin color cerca) fuera
    col = np.isin(out, ['h', 's', 'w', 'c'])
    keep = ndimage.binary_dilation(col, iterations=2)
    out[(out == 'k') & ~keep] = '.'
    # restos chicos sueltos
    lab, n = ndimage.label(out != '.', structure=np.ones((3, 3)))
    for i in range(1, n + 1):
        if (lab == i).sum() < 20: out[lab == i] = '.'
    ys, xs = np.nonzero(out != '.')
    out = out[ys.min():neck, xs.min():xs.max() + 1]      # hasta la linea del cuello
    return [list(r) for r in out], neck_x - xs.min()


def body(ci, deg):
    g, _ = doll3d.render(ci, math.radians(deg), body=True, Wd=BODY_W, Hd=BODY_H, scl=BODY_S)
    big = [[g[y // 2][x // 2] for x in range(2 * BODY_W)] for y in range(2 * BODY_H)]
    return big


HEAD_ROWS = 56          # la linea del cuello queda siempre en la misma fila
CANVAS_W = 100


def compose(ci, k):
    """figura de accion: el cuerpo NUNCA se mueve; la cabeza se apoya siempre con el cuello en el
    mismo punto (fila fija, centro del lienzo). Solo cambia el angulo."""
    vi, mir, deg = VIEWS[k]
    hd, nx = head(ci, vi)
    if mir:
        hd = [r[::-1] for r in hd]; nx = len(hd[0]) - 1 - nx
    bd = body(ci, deg)
    hh, hw = len(hd), len(hd[0])
    bh, bw = len(bd), len(bd[0])
    top_b = next(y for y in range(bh) if any(v != '.' for v in bd[y]))
    overlap = 12
    W = CANVAS_W
    H = HEAD_ROWS + (bh - top_b) - overlap
    out = [['.'] * W for _ in range(H)]
    ox_b = (W - bw) // 2
    for y in range(top_b, bh):
        for x in range(bw):
            v = bd[y][x]
            if v != '.' and 0 <= ox_b + x < W: out[HEAD_ROWS - overlap + y - top_b][ox_b + x] = v
    ox_h = int(round(W / 2 - 0.5 - nx))
    oy_h = HEAD_ROWS - hh
    if vi in (3, 4):
        # de espaldas: el pelo baja hasta la nuca (sino queda un cuello larguisimo)
        hd = [r[:] for r in hd]
        # fila mas ancha del pelo de abajo; desde ahi el pelo baja hasta la nuca angostandose
        wid = [(sum(1 for v in hd[y] if v != '.'), y) for y in range(hh)]
        yb = max(y for w_, y in wid if w_ >= 0.6 * max(w_ for w_, _ in wid))
        xs = [x for x in range(hw) if hd[yb][x] != '.']
        cx = (min(xs) + max(xs)) / 2
        half = (max(xs) - min(xs)) / 2 - 2
        for y in range(yb + 1, hh - 1):
            half = max(7, half - 0.8)
            x0, x1 = int(round(cx - half)), int(round(cx + half))
            for x in range(max(0, x0), min(hw, x1 + 1)):
                if hd[y][x] in '.k':
                    hd[y][x] = 'k' if x in (x0, x1) or (x - x0) % 6 == 3 else 'h'
        for x in range(hw):
            if hd[hh - 1][x] == '.' and hd[hh - 2][x] not in '.': hd[hh - 1][x] = 'k'
    hm = [[False] * W for _ in range(H)]
    for y in range(hh):
        for x in range(hw):
            v = hd[y][x]
            if v != '.' and 0 <= ox_h + x < W and 0 <= oy_h + y: out[oy_h + y][ox_h + x] = v; hm[oy_h + y][ox_h + x] = True
    # contorno negro entre la cabeza y lo que tiene alrededor (punos, hombros): no se mezclan
    for y in range(H):
        for x in range(W):
            if hm[y][x] or out[y][x] in '.k': continue
            if any(0 <= y + dy < H and 0 <= x + dx < W and hm[y + dy][x + dx] and out[y + dy][x + dx] != 'k'
                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                out[y][x] = 'k'
    # union cabeza-cuerpo: se cierran los huecos chicos alrededor del cuello
    a = np.array(out)
    fig = a != '.'
    band = np.zeros_like(fig); band[max(0, HEAD_ROWS - 14):HEAD_ROWS + 4] = True
    cl = ndimage.binary_closing(fig, structure=np.ones((3, 3)), iterations=3) & band & ~fig
    for y, x in zip(*np.nonzero(cl)): a[y, x] = 'k'
    return [list(r) for r in a]


def fill_holes(g):
    """tapa los huecos: todo lo encerrado por la figura (y las grietas de 1-2 pixeles) se pinta
    con el color vecino mas comun (el negro solo si no hay otro)"""
    a = np.array(g)
    fig = a != '.'
    closed = ndimage.binary_closing(fig, structure=np.ones((3, 3)), iterations=2) | fig
    full = ndimage.binary_fill_holes(closed)
    todo = full & ~fig
    for _ in range(8):
        if not todo.any(): break
        nxt = todo.copy()
        for y, x in zip(*np.nonzero(todo)):
            nb = [a[y + dy, x + dx] for dy in (-1, 0, 1) for dx in (-1, 0, 1)
                  if (dy or dx) and 0 <= y + dy < a.shape[0] and 0 <= x + dx < a.shape[1] and a[y + dy, x + dx] != '.' and not todo[y + dy, x + dx]]
            if not nb: continue
            col = [v for v in nb if v != 'k'] or nb
            a[y, x] = max(set(col), key=col.count)
            nxt[y, x] = False
        todo = nxt
    return [list(r) for r in a]


def views(ci):
    out = []
    for k in range(len(VIEWS)):
        g = fill_holes(compose(ci, k))
        g = ref_rot.add_ring(g)
        out.append((g, None))
    return out


if __name__ == '__main__':
    from PIL import Image
    C = {'k': (0, 0, 0), 's': (252, 152, 56), 'h': (124, 8, 0), 'w': (252, 252, 252), 'c': (60, 188, 252), 'o': (252, 252, 252)}
    N = len(VIEWS)
    im = Image.new('RGB', (N * 110, 2 * 135), (0, 0, 0))
    for ci in range(2):
        C['c'] = (60, 188, 252) if ci == 0 else (248, 56, 152)
        for k, (g, _) in enumerate(views(ci)):
            for y, r in enumerate(g):
                for x, v in enumerate(r):
                    if v != '.' and x < 110 and y < 135: im.putpixel((k * 110 + x, ci * 135 + y), C.get(v, (255, 0, 255)))
    im.resize((im.width * 2, im.height * 2), Image.NEAREST).save('hybrid.png')
