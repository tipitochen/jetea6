"""Conversion de cuadros de referencia a metasprites NES + derivados (policia, soldado)."""
import pickle, numpy as np
from emu import PAL as NESPAL
FR = pickle.load(open('ref/frames.pkl', 'rb'))
PROTO = {'k': (28, 22, 22), 's': (240, 150, 100), 'h': (140, 62, 35), 'w': (246, 246, 246),
         'g': (128, 128, 135)}
SHIRT = {0: [(20, 180, 225), (90, 210, 240), (0, 130, 190)], 1: [(235, 55, 125), (250, 120, 170), (200, 30, 100)]}
def classify(rgb, m, row):
    H, W, _ = rgb.shape
    out = [['.'] * W for _ in range(H)]
    protos = list(PROTO.items()) + [('c', c) for c in SHIRT[row]]
    for y in range(H):
        for x in range(W):
            if not m[y, x]: continue
            p = rgb[y, x]
            best = min(protos, key=lambda kv: sum((int(p[i]) - kv[1][i]) ** 2 for i in range(3)))
            out[y][x] = best[0]
    return out

def frame(row, col):
    rgb, m = FR[(row, col)]
    g = classify(rgb, m, row)
    # quitar lineas separadoras (filas casi completas de negro en bordes)
    W = len(g[0])
    def sep(r): return sum(1 for c in r if c == 'k') > W * 0.7
    while g and sep(g[-1]): g.pop()
    while g and sep(g[0]): g.pop(0)
    # quitar restos separados por una fila vacia (abajo/arriba)
    def empty(r): return all(c == '.' for c in r)
    for i in range(len(g) - 1, len(g) - 6, -1):
        if empty(g[i]): g = g[:i]; break
    for i in range(0, 5):
        if empty(g[i]): g = g[i + 1:]; break
    # quitar filas/columnas vacias
    while g and all(c == '.' for c in g[-1]): g.pop()
    while g and all(c == '.' for c in g[0]): g.pop(0)
    while all(r[0] == '.' for r in g): g = [r[1:] for r in g]
    while all(r[-1] == '.' for r in g): g = [r[:-1] for r in g]
    return fill_holes(g)

def fill_holes(g):
    import collections
    H, W = len(g), len(g[0])
    out = [[False] * W for _ in range(H)]
    q = collections.deque()
    for y in range(H):
        for x in (0, W - 1):
            if g[y][x] == '.' and not out[y][x]: out[y][x] = True; q.append((y, x))
    for x in range(W):
        for y in (0, H - 1):
            if g[y][x] == '.' and not out[y][x]: out[y][x] = True; q.append((y, x))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            yy, xx = y + dy, x + dx
            if 0 <= yy < H and 0 <= xx < W and not out[yy][xx] and g[yy][xx] == '.':
                out[yy][xx] = True; q.append((yy, xx))
    g = [r[:] for r in g]
    for _ in range(0):
        for y in range(H):
            for x in range(W):
                if g[y][x] == '.' and not out[y][x]:
                    nb = collections.Counter()
                    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        yy, xx = y + dy, x + dx
                        if 0 <= yy < H and 0 <= xx < W and g[yy][xx] not in '.k': nb[g[yy][xx]] += 1
                    if nb: g[y][x] = nb.most_common(1)[0][0]
    for y in range(H):
        for x in range(W):
            if g[y][x] == '.' and not out[y][x]: g[y][x] = 'c'
    return g

def anchor(g):
    H = len(g); W = len(g[0])
    xs = [x for y in range(H - 6, H) for x in range(W) if g[y][x] != '.']
    return int(round(sum(xs) / len(xs))) if xs else W // 2

# ---------------------------------------------------------- derivados
def face_top(g):
    for y in range(len(g)):
        if 's' in g[y][:]:
            # primera fila con >=3 pixeles de piel juntos
            if g[y].count('s') >= 3 if isinstance(g[y], list) else False: return y
    return 8

def make_enemy(g, kind):
    g = [r[:] for r in g]
    H = len(g); W = len(g[0])
    ft = None
    for y in range(H // 2):
        if sum(1 for c in g[y] if c == 's') >= 3: ft = y; break
    ft = ft or 8
    xs = [x for x in range(W) if g[ft][x] != '.'] + [x for x in range(W) if g[ft + 1][x] != '.']
    hx0, hx1 = min(xs), max(xs)
    # quitar pelo en punta
    for y in range(0, ft):
        for x in range(W): g[y][x] = '.'
    for y in range(ft, H):
        for x in range(W):
            c = g[y][x]
            if c == 'h': g[y][x] = 'k'
    # gorra / casco
    top = ft - (5 if kind == 'cop' else 6)
    shift = max(0, -top)
    if shift:
        g = [['.'] * W for _ in range(shift)] + g
        ft += shift; top += shift; H += shift
    for y in range(top, ft):
        k = y - top
        if kind == 'cop':
            inset = [3, 1, 0, 0, 0][k]
        else:
            inset = [4, 2, 1, 0, 0, 0][k]
        x0, x1 = hx0 + inset, hx1 - inset
        for x in range(x0, x1 + 1):
            edge = (x in (x0, x1)) or y == top
            g[y][x] = 'k' if edge else 'u'
    if kind == 'cop':
        for x in range(hx0, min(W, hx1 + 4)):
            if ft - 1 >= 0: g[ft - 1][x] = 'k'
        g[top + 2][(hx0 + hx1) // 2] = 's'      # placa
    else:
        for x in range(hx0 - 1, hx1 + 2):
            if 0 <= x < W: g[ft - 1][x] = 'k'
        for x in range(hx0 + 2, hx1 - 1, 3): g[top + 2][x] = 'k'   # textura
    # cuerpo: uniforme
    hip = None
    for y in range(H - 1, H // 2, -1):
        if sum(1 for c in g[y] if c == 'w') >= 6 and y < H - 4: hip = y; break
    for y in range(ft + 6, H):
        for x in range(W):
            c = g[y][x]
            if c in ('c', 'w'):
                g[y][x] = 'k' if y >= H - 4 else 'u'
            elif c == 's' and hip is not None and y > hip and y < H - 4:
                g[y][x] = 'u'
            elif c == 'g':
                g[y][x] = 'k'
    return g

# ---------------------------------------------------------- cuantizacion NES por tile
def nes(c): return NESPAL[c & 63]
def quantize(g, pals, cls_rgb, ax=None, avoid=None):
    best = None
    for oy in range(8):
        for ox in range(8):
            r = quantize_off(g, pals, cls_rgb, ax, ox, oy)
            score = r[1] + len(r[0]) * 20000
            if best is None or score < best[0]: best = (score, r[0])
    return best[1]

def quantize_off(g, pals, cls_rgb, ax, gox, goy):
    """g: grilla de clases. pals: lista de (attrpal, [c1,c2,c3]) NES. cls_rgb: clase->rgb.
    Devuelve lista de (dx, dy, pixels8x8 (indices), attrpal) con dx/dy relativos al ancla (pies)."""
    H = len(g); W = len(g[0])
    if ax is None: ax = anchor(g)
    ox = -ax
    # alinear grilla de tiles a la izquierda de la imagen
    tw = (W + gox + 7) // 8; th = (H + goy + 7) // 8
    padT = th * 8 - H
    out = []; total = 0
    for ty in range(th):
        for tx in range(tw):
            pix = []
            any_ = False
            for y in range(8):
                gy = ty * 8 + y - padT
                row = []
                for x in range(8):
                    gx = tx * 8 + x - gox
                    c = g[gy][gx] if 0 <= gy < H and 0 <= gx < W else "."
                    row.append(c)
                    if c != '.': any_ = True
                pix.append(row)
            if not any_: continue
            best = None
            for ap, cols in pals:
                rgbs = [nes(c) for c in cols]
                err = 0; idx = []
                for row in pix:
                    ir = []
                    for c in row:
                        if c == '.': ir.append(0); continue
                        t = cls_rgb[c]
                        d = [sum((t[i] - r[i]) ** 2 for i in range(3)) for r in rgbs]
                        k = int(np.argmin(d)); err += d[k]; ir.append(k + 1)
                    idx.append(ir)
                if best is None or err < best[0]: best = (err, ap, idx)
            total += best[0]
            out.append((tx * 8 + ox - gox, ty * 8 - th * 8, best[2], best[1]))
    return out, total

CLS_RGB = dict(k=(28, 22, 22), s=(240, 150, 100), h=(140, 62, 35), w=(246, 246, 246), g=(160, 160, 160),
               u=(8, 76, 196), c=(20, 180, 225))

def quantize_layered(g, pals, cls_rgb, ax=None, thr=2500, max_split=4):
    """como quantize, pero si un tile mezcla colores de dos paletas (p.ej. piel sobre camisa)
    agrega un segundo sprite superpuesto con la otra paleta, en vez de pintar mal (manchas blancas)."""
    best = None
    for oy in range(8):
        for ox in range(8):
            r = quantize_off(g, pals, cls_rgb, ax, ox, oy)
            sc = r[1] + len(r[0]) * 20000
            if best is None or sc < best[0]: best = (sc, ox, oy)
    _, gox, goy = best
    H = len(g); W = len(g[0])
    if ax is None: ax = anchor(g)
    tw = (W + gox + 7) // 8; th = (H + goy + 7) // 8
    padT = th * 8 - H
    out = []; extra = []
    PR = [(ap, [nes(c) for c in cols]) for ap, cols in pals]
    for ty in range(th):
        for tx in range(tw):
            pix = []
            for y in range(8):
                gy = ty * 8 + y - padT
                pix.append([g[gy][tx * 8 + x - gox] if 0 <= gy < H and 0 <= tx * 8 + x - gox < W else '.' for x in range(8)])
            if all(c == '.' for r in pix for c in r): continue
            def fit(rgbs, mask=None):
                err = 0; idx = []; bad = []
                for y in range(8):
                    ir = []
                    for x in range(8):
                        c = pix[y][x]
                        if c == '.' or (mask is not None and not mask[y][x]): ir.append(0); continue
                        t = cls_rgb[c]
                        d = [sum((t[i] - r[i]) ** 2 for i in range(3)) for r in rgbs]
                        k = int(np.argmin(d)); err += d[k]; ir.append(k + 1)
                        if d[k] > thr: bad.append((x, y))
                    idx.append(ir)
                return err, idx, bad
            res = sorted(((fit(rgbs), ap, rgbs) for ap, rgbs in PR), key=lambda t: t[0][0])
            (err, idx, bad), ap, rgbs = res[0]
            dx = tx * 8 - ax - gox; dy = ty * 8 - th * 8
            if len(bad) >= 1:
                mask = [[(x, y) in bad for x in range(8)] for y in range(8)]
                cand = sorted(((fit(r2, mask), a2) for a2, r2 in PR if a2 != ap), key=lambda t: t[0][0])
                (e2, idx2, bad2), a2 = cand[0]
                if len(bad2) < len(bad):
                    plain = [r[:] for r in idx]
                    for x, y in bad: idx[y][x] = 0
                    extra.append((dx, dy, idx, ap, idx2, a2, plain))
                    continue
            out.append((dx, dy, idx, ap))
    # limitar la cantidad de tiles dobles (los de mayor area mala primero)
    extra.sort(key=lambda e: e[1])          # la cara (arriba) tiene prioridad
    for i, (dx, dy, idx, ap, idx2, a2, plain) in enumerate(extra):
        if i < max_split:
            out.insert(0, (dx, dy, idx, ap)); out.append((dx, dy, idx2, a2))
        else:
            out.append((dx, dy, plain, ap))
    return out
