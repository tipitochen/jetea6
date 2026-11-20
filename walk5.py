"""Ciclo de caminata mejorado: ancla estable (cabeza/torso) y piernas espejadas para alternar pies."""
from sprite3 import frame

def head_anchor(g):
    H = len(g); W = len(g[0])
    top = next(y for y in range(H) if any(c != '.' for c in g[y]))
    xs = [x for y in range(top, min(H, top + 18)) for x in range(W) if g[y][x] in 'shku']
    return sum(xs) / len(xs)

def torso_anchor(g):
    H = len(g); W = len(g[0])
    xs = [x for y in range(int(H * .45), int(H * .7)) for x in range(W) if g[y][x] != '.']
    return sum(xs) / len(xs)

def hip_row(g):
    H = len(g)
    ys = [y for y in range(H) if 'c' in g[y] or 'u' in g[y]]
    hr = max(y for y in ys if y < H - 4) + 1 if ys else H - 10
    return min(hr, H - 8)

def mirror_legs(g, ax):
    """espeja las piernas (de la cadera hacia abajo) alrededor de ax; devuelve (grilla, nuevo ancla)."""
    H = len(g); W = len(g[0]); hr = hip_row(g)
    xs = [x for y in range(hr, min(H, hr + 3)) for x in range(W) if g[y][x] != '.']
    a2 = min(xs) + max(xs)
    rows = [r[:] for r in g]
    pad = 8
    out = [['.'] * (W + 2 * pad) for _ in range(H)]
    for y in range(H):
        for x in range(W):
            if g[y][x] == '.': continue
            if y < hr: out[y][x + pad] = g[y][x]
    for y in range(hr, H):
        for x in range(W):
            if g[y][x] == '.': continue
            nx = a2 - x
            if 0 <= nx + pad < W + 2 * pad: out[y][nx + pad] = g[y][x]
    # recortar columnas vacias
    l = min(x for r in out for x, c in enumerate(r) if c != '.')
    r_ = max(x for r in out for x, c in enumerate(r) if c != '.')
    out = [r[l:r_ + 1] for r in out]
    return out, ax + pad - l

def walk_frames(row, src=(1, 2, 3, 4)):
    """8 cuadros: src normales + src con piernas espejadas. Devuelve lista de (grilla, ancla_x)."""
    res = []
    for c in src:
        g = frame(row, c); res.append((g, head_anchor(g)))
    for c in src:
        g = frame(row, c); ax = head_anchor(g)
        res.append(mirror_legs(g, ax))
    return res

if __name__ == '__main__':
    from PIL import Image
    C = {'k': (20, 20, 20), 's': (240, 150, 100), 'h': (140, 62, 35), 'w': (246, 246, 246), 'g': (128, 128, 135), 'c': (20, 180, 225), 'u': (0, 0, 200)}
    im = Image.new('RGB', (8 * 40, 2 * 50), (60, 60, 90))
    for r in range(2):
        for i, (g, ax) in enumerate(walk_frames(r)):
            H = len(g)
            ox = i * 40 + 20 - int(round(ax)); oy = r * 50 + 46 - H
            for y in range(H):
                for x, c in enumerate(g[y]):
                    if c != '.': im.putpixel((ox + x, oy + y), C.get(c, (255, 0, 255)))
            for y in range(r * 50, r * 50 + 50): im.putpixel((i * 40 + 20, y), (255, 255, 0))
    im.resize((im.width * 4, im.height * 4), Image.NEAREST).save('walk_view.png')
