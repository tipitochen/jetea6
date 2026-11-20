"""Caminata estilo Mega Man: piernas dibujadas en 4 poses (zancada, paso, zancada, paso) sobre el torso quieto."""
from sprite3 import frame


def hip_row(g):
    H = len(g)
    for y in range(H // 2, H):
        if sum(1 for c in g[y] if c == 'w') >= 4 and 'c' not in g[y]: return y
    return H - 10


def walk_poses(row):
    base = frame(row, 0)
    H = len(base); W = len(base[0])
    hr = hip_row(base)
    xs = [x for y in range(hr, hr + 3) for x in range(W) if base[y][x] != '.']
    cx = (min(xs) + max(xs)) / 2
    top_leg = hr + 3
    # (pie cercano dx, levanta), (pie lejano dx, levanta), bajada del cuerpo
    POSES = [((6, 0), (-5, 0), 1), ((1, 0), (-2, 3), 0), ((-5, 0), (6, 0), 1), ((-2, 3), (1, 0), 0)]
    out = []
    PAD = 6
    for near, far, bob in POSES:
        g = [['.'] * (W + 2 * PAD) for _ in range(H)]
        for y in range(top_leg):
            yy = y + bob
            if yy >= H: continue
            for x in range(W):
                if base[y][x] != '.': g[yy][x + PAD] = base[y][x]
        y0 = top_leg + bob; y1 = H - 3

        def leg(dx, lift, hipdx):
            hx = cx + hipdx + PAD
            fx = cx + dx + PAD
            fy = y1 - lift
            pts = []
            n = max(1, fy - y0)
            for i in range(n + 1):
                t = i / n
                x = hx + (fx - hx) * t; y = y0 + (fy - y0) * t
                pts.append((x, y))
            for x, y in pts:
                for ox in (-1, 0, 1):
                    xx = int(round(x + ox)); yy = int(round(y))
                    if 0 <= yy < H and 0 <= xx < len(g[0]): g[yy][xx] = 's'
            # zapatilla (punta hacia adelante = +x)
            sx = int(round(fx)) - 2
            for yy in range(fy, fy + 3):
                for xx in range(sx, sx + 6):
                    if 0 <= yy < H and 0 <= xx < len(g[0]): g[yy][xx] = 'w'
            return pts

        def outline(mark_from):
            add = []
            for yy in range(y0 - 1, H):
                for xx in range(len(g[0])):
                    if g[yy][xx] != '.' or yy < 0: continue
                    for ddx, ddy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        a, b = xx + ddx, yy + ddy
                        if 0 <= b < H and 0 <= a < len(g[0]) and b >= y0 and g[b][a] in 'sw':
                            add.append((xx, yy)); break
            for xx, yy in add: g[yy][xx] = 'k'

        hd = lambda d: 2 if d > 2 else (-2 if d < -2 else 0)
        leg(far[0], far[1], hd(far[0]))          # pierna lejana primero
        outline(None)
        leg(near[0], near[1], hd(near[0]))         # pierna cercana encima
        # contorno de la cercana (sin tapar la lejana con negro entero)
        add = []
        for yy in range(y0, H):
            for xx in range(len(g[0])):
                if g[yy][xx] != '.': continue
                for ddx, ddy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    a, b = xx + ddx, yy + ddy
                    if 0 <= b < H and 0 <= a < len(g[0]) and g[b][a] in 'sw':
                        add.append((xx, yy)); break
        for xx, yy in add: g[yy][xx] = 'k'
        # base de la zapatilla negra (suela)
        for xx in range(len(g[0])):
            if g[H - 1][xx] == 'w': g[H - 1][xx] = 'k'
        # recortar columnas vacias
        l = min(x for r in g for x, c in enumerate(r) if c != '.')
        r_ = max(x for r in g for x, c in enumerate(r) if c != '.')
        g = [r[l:r_ + 1] for r in g]
        out.append(g)
    return out


if __name__ == '__main__':
    from PIL import Image
    from walk5 import head_anchor
    C = {'k': (20, 20, 20), 's': (240, 150, 100), 'h': (140, 62, 35), 'w': (246, 246, 246), 'g': (128, 128, 135), 'c': (20, 180, 225)}
    im = Image.new('RGB', (8 * 40, 50), (60, 60, 90))
    for r in range(2):
        for i, g in enumerate(walk_poses(r)):
            ax = head_anchor(g)
            ox = (r * 4 + i) * 40 + 20 - int(round(ax)); oy = 46 - len(g)
            for y in range(len(g)):
                for x, c in enumerate(g[y]):
                    if c != '.': im.putpixel((ox + x, oy + y), C.get(c, (255, 0, 255)))
    im.resize((im.width * 4, im.height * 4), Image.NEAREST).save('walk6_view.png')
