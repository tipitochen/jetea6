"""Pantalla ARSENAL: personaje grande girando (fondo con bancos de CHR por angulo) + sprites de correccion + armas."""
import numpy as np
from sprite3 import frame, nes
from walk5 import head_anchor

SC = 3                    # escala del personaje
CW, CH = 12, 15           # celdas de la figura (96x120 px), en la pantalla: columnas 0-11, filas 4-18
OY = 32                   # y de pantalla de la region
OX = 0
MAXL = 3
import math
# 9 vistas = media vuelta (la otra media vuelta las recorre al reves): giro de 16 pasos
# vistas: (fuente, escala horizontal) ; fuente 0 = perfil, 1 = frente, 2 = espalda
VIEWS = [(0, 1.0), (0, 0.92), (0, 0.71), (1, 0.85), (1, 1.0), (0, -0.71), (0, -0.92), (0, -1.0), (2, 0.85), (2, 1.0)]
ANGLES = VIEWS
SEQ = [0, 1, 2, 3, 4, 3, 5, 6, 7, 6, 5, 8, 9, 8, 2, 1]


def clean_face(g):
    """quita puntitos de color de camisa sueltos en la cara (aro/brillo)"""
    g = [r[:] for r in g]
    H = len(g); W = len(g[0])
    top_shirt = next((y for y in range(H) if sum(1 for c in g[y] if c == 'c') >= 4), H)
    for y in range(min(top_shirt, H)):
        for x in range(W):
            if g[y][x] != 'c': continue
            nb = [g[y + dy][x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)) if 0 <= x + dx < W and 0 <= y + dy < H]
            if sum(1 for c in nb if c == 'c') <= 1 and sum(1 for c in nb if c in 'sk') >= 2:
                g[y][x] = 's'
    return g


def angle_image(g, s):
    H = len(g); W = len(g[0]); ax = head_anchor(g)
    img = [['.'] * (CW * 8) for _ in range(CH * 8)]
    cx = CW * 4; bottom = CH * 8 - 2
    # plataforma giratoria (elipse) bajo los pies
    for k in range(0, 360, 3):
        a = math.radians(k)
        X = int(round(cx + 40 * math.cos(a))); Y = int(round(bottom - 4 + 5 * math.sin(a)))
        if 0 <= X < CW * 8 and 0 <= Y < CH * 8: img[Y][X] = 'w'
    top = bottom - H * SC
    for Y in range(CH * 8):
        sy = (Y - top) // SC
        if not 0 <= sy < H: continue
        for X in range(CW * 8):
            u = (X - cx + 0.5) / (SC * s) + ax
            sx = int(np.floor(u))
            if 0 <= sx < W: img[Y][X] = g[sy][sx]
    return img


def hand_pos(g):
    """mano delantera (la piel mas a la derecha en la zona media) -> (x, y) en el dibujo"""
    H = len(g); W = len(g[0])
    best = None
    for y in range(int(H * .45), int(H * .75)):
        for x in range(W):
            if g[y][x] == 's' and (best is None or x > best[0]): best = (x, y)
    return best


# como la primera version: un solo sprite (el del juego) que gira como figura en bandeja:
# ancho = cos(angulo); la mitad de atras es el mismo sprite espejado. 16 pasos, 9 vistas distintas
STEPS = 16
SCALES = [math.cos(2 * math.pi * k / STEPS) for k in range(STEPS // 2 + 1)]
NV = len(SCALES)
SEQ = [k if k <= STEPS // 2 else STEPS - k for k in range(STEPS)]


def ref_image(ci, ai, V):
    """vista ai (exacta de la referencia) centrada por los pies en la region de la figura"""
    g, anc = V[ai]
    h, w = len(g), len(g[0])
    img = [['.'] * (CW * 8) for _ in range(CH * 8)]
    # el cuerpo ya viene centrado en la grilla (eje del giro en el medio)
    fx = w / 2
    ox = int(round(CW * 4 - fx)); oy = CH * 8 - h
    for y in range(h):
        for x in range(w):
            v = g[y][x]
            if v == '.': continue
            X, Y = ox + x, oy + y
            if 0 <= X < CW * 8 and 0 <= Y < CH * 8: img[Y][X] = v
    if anc: hand = (int(OX + ox + anc[0]), int(OY + oy + anc[1]), True, bool(anc[2]))
    else: hand = (0, 0, False, False)
    return img, hand


def build(row, shirt):
    ci = row
    g0 = clean_face(frame(row, 0))
    # 4 paletas de fondo para la figura (la 4a tiene el blanco en el indice 1: la usa tambien el menu)
    pals = [[0x27, 0x17, 0x30], [0x27, 0x17, shirt], [0x27, 0x30, shirt], [0x30, 0x17, shirt]]
    key = {'s': 0x27, 'h': 0x17, 'w': 0x30, 'c': shirt}
    rgb = {k: np.array(nes(v)) for k, v in key.items()}
    angles = []
    for ai in range(NV):
        sc = SCALES[ai]
        if abs(sc) < 0.14: sc = 0.14 if sc >= 0 else -0.14     # de canto: una tira finita, no desaparece
        img = angle_image(g0, sc)
        img = [[('w' if v == 'g' else v) for v in r] for r in img]
        hand = (0, 0, False, False)
        img = [[('.' if v in 'kg' else v) for v in r] for r in img]
        attr = [[0] * (CW // 2) for _ in range(CH // 2 + 1)]
        bgpix = [[0] * (CW * 8) for _ in range(CH * 8)]
        bad = set()
        for by in range((CH * 8 + 15) // 16):
            for bx in range(CW // 2):
                best = None
                for pi, P in enumerate(pals):
                    err = 0; nbad = []; idx = {}
                    for y in range(by * 16, min(CH * 8, by * 16 + 16)):
                        for x in range(bx * 16, bx * 16 + 16):
                            c = img[y][x]
                            if c == '.': continue
                            col = key[c]
                            if col in P: idx[(x, y)] = P.index(col) + 1
                            else:
                                d = [((rgb[c] - np.array(nes(t))) ** 2).sum() for t in P]
                                k = int(np.argmin(d)); idx[(x, y)] = k + 1; err += d[k]; nbad.append((x, y))
                    if best is None or (len(nbad), err) < (len(best[1]), best[0]): best = (err, nbad, pi, idx)
                _, nbad, pi, idx = best
                attr[by][bx] = pi
                for (x, y), v in idx.items(): bgpix[y][x] = v
                bad.update(nbad)
        over = []
        cells = sorted(set((x // 8, y // 8) for x, y in bad))
        for cx_, cy_ in cells:
            pts = [(x, y) for x, y in bad if x // 8 == cx_ and y // 8 == cy_]
            best = None
            for pi, P in enumerate(pals[:3]):
                t = [[0] * 8 for _ in range(8)]; miss = 0
                for x, y in pts:
                    col = key[img[y][x]]
                    if col in P: t[y % 8][x % 8] = P.index(col) + 1
                    else: miss += 1
                if best is None or miss < best[0]: best = (miss, pi, t)
            miss, pi, t = best
            over.append((OX + cx_ * 8, OY + cy_ * 8, t, pi, len(pts)))
        # limite: como mucho MAXL sprites de correccion por linea (deja lugar al arma y la flecha);
        # se descartan los que corrigen menos pixeles (ahi queda el color mas parecido)
        over.sort(key=lambda o: -o[4])
        kept = []
        for o in over:
            if o[4] <= 2: continue
            if all(sum(1 for k in kept if k[1] <= y < k[1] + 8) < MAXL for y in range(o[1], o[1] + 8)): kept.append(o)
        over = [o[:4] for o in kept]
        cells_t = []
        for cy_ in range(CH):
            for cx_ in range(CW):
                cells_t.append(tuple(''.join(str(bgpix[cy_ * 8 + y][cx_ * 8 + x]) if bgpix[cy_ * 8 + y][cx_ * 8 + x] else '.' for x in range(8)) for y in range(8)))
        angles.append(dict(cells=cells_t, attr=attr, over=over, hand=hand, img=img))
    return angles, pals


if __name__ == '__main__':
    from PIL import Image
    for row, shirt in ((0, 0x2C), (1, 0x25)):
        A, pals = build(row, shirt)
        out = Image.new("RGB", (100 * len(A), 130), (0, 0, 0))
        for i, a in enumerate(A):
            for cy_ in range(CH):
                for cx_ in range(CW):
                    t = a['cells'][cy_ * CW + cx_]
                    P = pals[a['attr'][cy_ // 2][cx_ // 2]]
                    for y in range(8):
                        for x in range(8):
                            v = t[y][x]
                            if v != '.': out.putpixel((i * 100 + cx_ * 8 + x, cy_ * 8 + y), tuple(nes(P[int(v) - 1])))
            for x0, y0, t, pi in a['over']:
                for y in range(8):
                    for x in range(8):
                        if t[y][x]: out.putpixel((i * 100 + x0 - OX + x, y0 - OY + y), tuple(nes(pals[pi][t[y][x] - 1])))
            hx, hy, vis, fl = a['hand']
            if vis: out.putpixel((i * 100 + hx - OX, hy - OY), (255, 0, 0))
            print(row, i, 'sprites correccion', len(a['over']), 'max por linea', max([sum(1 for o in a['over'] if o[1] <= y < o[1] + 8) for y in range(240)]))
        out.resize((out.width * 3, out.height * 3), Image.NEAREST).save('ars_%d.png' % row)
