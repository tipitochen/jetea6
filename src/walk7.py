"""Caminata tipo 'pisotones': piernas del dibujo quieto, levantando apenas un pie por vez."""
from sprite3 import frame
from deshine import deshine

def hip_row(g):
    H = len(g)
    for y in range(H // 2, H):
        if sum(1 for c in g[y] if c == 'w') >= 4 and 'c' not in g[y]: return y
    return H - 10

def stomp_poses(row):
    from arsenal_gen import clean_face
    base = clean_face(frame(row, 0))
    H = len(base); W = len(base[0])
    hr = hip_row(base)
    top = hr + 3                       # debajo del short
    # columna que separa las piernas: la mas vacia en las filas de abajo
    best = None
    for x in range(W // 3, 2 * W // 3 + 1):
        n = sum(1 for y in range(top, H) if base[y][x] != '.')
        if best is None or n < best[0]: best = (n, x)
    split = best[1]
    out = []
    for lift_left, lift_right in ((0, 0), (2, 0), (0, 0), (0, 2)):
        g = [r[:] for r in base]
        for y in range(top, H):
            for x in range(W):
                g[y][x] = '.'
        for y in range(top, H):
            for x in range(W):
                c = base[y][x]
                if c == '.': continue
                lift = lift_left if x < split else lift_right
                yy = y - lift
                if yy < top - 1 and lift:      # no pisar el short
                    yy = top - 1
                g[yy][x] = c
        # rellenar la pierna levantada con piel (el muslo no desaparece)
        out.append(g)
    return out

if __name__ == '__main__':
    from PIL import Image
    C = {'k': (20, 20, 20), 's': (240, 150, 100), 'h': (140, 62, 35), 'w': (246, 246, 246), 'g': (128, 128, 135), 'c': (20, 180, 225)}
    im = Image.new('RGB', (8 * 30, 40), (60, 60, 90))
    for r in range(2):
        for i, g in enumerate(stomp_poses(r)):
            for y in range(len(g)):
                for x, c in enumerate(g[y]):
                    if c != '.': im.putpixel(((r * 4 + i) * 30 + x, 40 - len(g) + y), C.get(c, (255, 0, 255)))
    im.resize((im.width * 4, im.height * 4), Image.NEAREST).save('walk7_view.png')
