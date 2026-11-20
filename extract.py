"""Extrae los cuadros de la hoja de referencia a pixel art nativo (deteccion de grilla)."""
from PIL import Image
import numpy as np, math
SHEET = 'ref/sheet.png'
XS = [2,194,386,578,770,962,1154,1346,1538,1730,1922,2114,2306,2498,2690,2882,3069]
YS = [(5, 248), (258, 505)]
_im = np.asarray(Image.open(SHEET).convert('RGB')).astype(np.int32)

def bgmask(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (b > 170) & (b > r + 60) & (g > 100) & (g < 200)

def grid_fit(cell, s0=6.55):
    best = None
    H, W, _ = cell.shape
    for s in np.arange(6.2, 6.95, 0.05):
        for oy in np.arange(0, s, 0.5):
            for ox in np.arange(0, s, 0.5):
                # costo: suma de varianza en bloques (muestreo de 9 puntos internos)
                cost = 0; n = 0
                for gy in range(2, int((H - oy) / s) - 1, 2):
                    for gx in range(2, int((W - ox) / s) - 1, 2):
                        y0 = oy + gy * s; x0 = ox + gx * s
                        pts = cell[int(y0 + s * .2):int(y0 + s * .8), int(x0 + s * .2):int(x0 + s * .8)]
                        if pts.size == 0: continue
                        cost += pts.reshape(-1, 3).std(axis=0).sum(); n += 1
                c = cost / max(1, n)
                if best is None or c < best[0]: best = (c, s, ox, oy)
    return best

FIT = None
def cell_rgb(row, col):
    x0, x1 = XS[col] + 5, XS[col + 1] - 4
    y0, y1 = YS[row]
    return _im[y0:y1, x0:x1]

def extract(row, col, s=None, ox=None, oy=None):
    cell = cell_rgb(row, col)
    if s is None:
        _, s, ox, oy = grid_fit(cell)
    H, W, _ = cell.shape
    nh, nw = int((H - oy) / s), int((W - ox) / s)
    out = np.zeros((nh, nw, 3), np.int32); m = np.zeros((nh, nw), bool)
    for gy in range(nh):
        for gx in range(nw):
            y0 = oy + gy * s; x0 = ox + gx * s
            blk = cell[int(y0 + s * .25):int(y0 + s * .75) + 1, int(x0 + s * .25):int(x0 + s * .75) + 1].reshape(-1, 3)
            bm = bgmask(blk)
            if bm.mean() > 0.5: continue
            px = blk[~bm]
            out[gy, gx] = np.median(px, axis=0); m[gy, gx] = True
    ys, xs = np.where(m)
    return out[ys.min():ys.max() + 1, xs.min():xs.max() + 1], m[ys.min():ys.max() + 1, xs.min():xs.max() + 1], (s, ox, oy)

if __name__ == '__main__':
    for col in (0,):
        rgb, m, fit = extract(0, col)
        print(fit, rgb.shape)
        img = Image.fromarray(np.where(m[..., None], rgb, [84, 154, 250]).astype(np.uint8))
        img.resize((img.width * 8, img.height * 8), Image.NEAREST).save('ref/x0.png')
