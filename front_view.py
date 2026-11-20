"""Vistas de frente y de espaldas sintetizadas a partir del dibujo de perfil (espejando la mitad delantera)."""
from walk5 import head_anchor

def front(g):
    H = len(g); W = len(g[0])
    c = int(round(head_anchor(g)))
    half = max(W - c, c) + 1
    out = [['.'] * (2 * half + 1) for _ in range(H)]
    for y in range(H):
        for d in range(half):
            x = c + d
            v = g[y][x] if x < W else '.'
            out[y][half + d] = v
            out[y][half - d] = v
    # recortar
    l = min(x for r in out for x, v in enumerate(r) if v != '.')
    r_ = max(x for r in out for x, v in enumerate(r) if v != '.')
    return [r[l:r_ + 1] for r in out]

def back(g):
    f = front(g)
    H = len(f)
    # cabeza: hasta la primera fila con camisa/ropa; la cara pasa a ser pelo
    out = [r[:] for r in f]
    W = len(f[0])
    ft = next((y for y in range(H) if sum(1 for v in f[y] if v == 's') >= 3), 0)
    # fin de la cabeza: la linea del menton (fila casi toda contorno)
    def chin(y):
        n = [v for v in f[y] if v != '.']
        return len(n) >= 8 and sum(1 for v in n if v == 'k') >= 0.85 * len(n)
    top_body = next((y for y in range(ft + 4, H) if chin(y)), H // 2)
    for y in range(ft, top_body):
        for x in range(W):
            v = f[y][x]
            if v == '.': continue
            inner = all(0 <= x + dx < W and 0 <= y + dy < H and f[y + dy][x + dx] != '.' for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if inner and y < top_body - 2: out[y][x] = 'k' if (x % 4 == 0 and y < top_body - 4) else 'h'
            elif v in 'sw': out[y][x] = 'h'
    # espalda de la ropa: sin la remera/blanco del frente dentro del torso
    belt = next((y for y in range(top_body, H) if 'g' in f[y]), top_body + 8)
    for y in range(top_body + 1, belt - 1):
        xs = [x for x, v in enumerate(f[y]) if v == 'c']
        if len(xs) < 2: continue
        for x in range(min(xs), max(xs) + 1):
            if out[y][x] in 'wk' and f[y][x - 1] != '.' and f[y][x + 1] != '.':
                out[y][x] = 'c'
    return out

if __name__ == '__main__':
    from sprite3 import frame
    from PIL import Image
    C = {'k': (20, 20, 20), 's': (240, 150, 100), 'h': (140, 62, 35), 'w': (246, 246, 246), 'g': (128, 128, 135), 'c': (20, 180, 225)}
    im = Image.new('RGB', (4 * 40, 40), (60, 60, 90))
    for r in range(2):
        for k, f in enumerate((front(frame(r, 0)), back(frame(r, 0)))):
            for y, row in enumerate(f):
                for x, v in enumerate(row):
                    if v != '.': im.putpixel(((r * 2 + k) * 40 + x, y), C.get(v, (255, 0, 255)))
    im.resize((im.width * 5, im.height * 5), Image.NEAREST).save('front_view.png')
