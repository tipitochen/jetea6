import numpy as np, pickle, time
from extract import cell_rgb, extract
def fit_off(cell, s):
    H, W, _ = cell.shape
    best = None
    for oy in np.arange(0, s, 0.35):
        for ox in np.arange(0, s, 0.35):
            cost = 0; n = 0
            for gy in range(1, int((H - oy) / s) - 1):
                for gx in range(1, int((W - ox) / s) - 1, 2):
                    y0 = oy + gy * s; x0 = ox + gx * s
                    pts = cell[int(y0 + s * .2):int(y0 + s * .8), int(x0 + s * .2):int(x0 + s * .8)]
                    cost += pts.reshape(-1, 3).std(axis=0).sum(); n += 1
            c = cost / n
            if best is None or c < best[0]: best = (c, ox, oy)
    return best
out = {}
t = time.time()
for row in (0, 1):
    for col in range(16):
        cell = cell_rgb(row, col)
        best = None
        for s in (6.25, 6.3, 6.35):
            c, ox, oy = fit_off(cell, s)
            if best is None or c < best[0]: best = (c, s, ox, oy)
        rgb, m, fit = extract(row, col, best[1], best[2], best[3])
        out[(row, col)] = (rgb, m)
        print(row, col, rgb.shape, round(best[1], 2), round(time.time() - t))
pickle.dump(out, open('ref/frames.pkl', 'wb'))
