"""Policias y militares v4: derivados del dibujo de Jose, con mas detalle."""
from sprite3 import frame

def _rows_with(g, ch, lo, hi, n=1):
    return [y for y in range(lo, hi) if sum(1 for c in g[y] if c == ch) >= n]

def make_enemy2(src, kind):
    g = [r[:] for r in src]
    H = len(g); W = len(g[0])
    ft = None
    for y in range(H // 2):
        if sum(1 for c in g[y] if c == 's') >= 3: ft = y; break
    ft = ft if ft is not None else 8
    # extension horizontal de la cabeza
    xs = [x for y in (ft, ft + 1, ft + 2) for x in range(W) if g[y][x] != '.']
    hx0, hx1 = min(xs), max(xs)
    # filas de ojos (blanco dentro de la cara)
    eyes = [y for y in range(ft, min(H, ft + 9)) if any(g[y][x] == 'w' for x in range(hx0, hx1 + 1))]
    ey = eyes[0] if eyes else ft + 4
    # short (pantalon)
    st = None
    for y in range(int(H * .55), H - 4):
        if sum(1 for c in g[y] if c == 'w') >= 4: st = y; break
    st = st or int(H * .7)
    # --- quitar pelo, agregar gorra/casco
    top = ft - (5 if kind == 'cop' else 6)
    shift = max(0, -top)
    if shift:
        g = [['.'] * W for _ in range(shift)] + g
        ft += shift; top += shift; H += shift; ey += shift; st += shift
    for y in range(0, ft):
        for x in range(W): g[y][x] = '.'
    for y in range(ft, H):
        for x in range(W):
            if g[y][x] == 'h': g[y][x] = 'k'
    if kind == 'cop':
        ins = [3, 1, 0, 0, 0]
        for k, y in enumerate(range(top, ft)):
            x0, x1 = hx0 + ins[k], hx1 - ins[k]
            for x in range(x0, x1 + 1):
                g[y][x] = 'k' if (x in (x0, x1) or y == top) else 'u'
        for x in range(hx0, min(W, hx1 + 4)): g[ft - 1][x] = 'k'      # visera
        for x in range(hx0 + 1, hx1): g[ft - 2][x] = 'k' if (x + 1) % 4 else 'u'  # cinta
        g[top + 2][(hx0 + hx1) // 2 + 1] = 's'; g[top + 2][(hx0 + hx1) // 2 + 2] = 's'   # placa gorra
        # ojos: pupilas negras sobre piel (la paleta del enemigo no tiene blanco)
        for y in range(ey, ey + 4):
            for x in range(W):
                if g[y][x] == 'w': g[y][x] = 's'
        # bigote
        my = ey + 4
        if my < H:
            row = [x for x in range(hx0, hx1 + 1) if g[my][x] == 's']
            if len(row) > 4:
                for x in row[len(row) // 2 - 1: len(row) // 2 + 3]: g[my][x] = 'k'
    else:
        ins = [4, 2, 1, 0, 0, 0]
        for k, y in enumerate(range(top, ft)):
            x0, x1 = hx0 - 1 + ins[k], hx1 + 1 - ins[k]
            for x in range(max(0, x0), min(W, x1 + 1)):
                edge = x in (x0, x1) or y == top
                camo = (x * 3 + y * 5) % 7 == 0
                g[y][x] = 'k' if edge or camo else 'u'
        for x in range(max(0, hx0 - 1), min(W, hx1 + 2)): g[ft - 1][x] = 'k'
        # barbijo/correa
        for y in range(ey + 2, min(H, ey + 6)):
            for x in range(W):
                if g[y][x] == 'w': g[y][x] = 's'
        if ey + 5 < H:
            for x in (hx0 + 1, hx0 + 2):
                if g[ey + 3][x] == 's': g[ey + 3][x] = 'k'
        for y in (ey, ey + 1):
            for x in range(hx0, hx1 + 1):
                if g[y][x] == 'w': g[y][x] = 's'
    # --- cuerpo
    for y in range(ft + 7, H):
        for x in range(W):
            c = g[y][x]
            if y >= H - 4:
                if c != '.': g[y][x] = 'k' if c != 's' or y >= H - 3 else 'u'
            elif y >= st - 1:
                if c in 'swc': g[y][x] = 'u'
                if c == 'g': g[y][x] = 'k'
            else:
                if c in 'wc': g[y][x] = 'u'
                if c == 'g': g[y][x] = 'k'
    # cinturon
    belt = st - 1
    xs = [x for x in range(W) if g[belt][x] != '.']
    if xs:
        for x in range(min(xs) + 1, max(xs)):
            g[belt][x] = 'k'
        hb = (min(xs) + max(xs)) // 2
        g[belt][hb] = 's'
    # torso: placa / tirantes
    ty = ft + 11
    if ty < belt - 2:
        tx = [x for x in range(W) if g[ty][x] == 'u']
        if tx:
            if kind == 'cop':
                cx = tx[len(tx) // 3]
                g[ty][cx] = 's'; g[ty + 1][cx] = 's'; g[ty][cx + 1] = 's'
            else:
                for k in range(belt - ty):
                    x = tx[0] + 2 + k // 1
                    if x < W and g[ty + k][x] == 'u': g[ty + k][x] = 'k'
    # rodilleras / bolsillo
    for y in range(st + 1, H - 4):
        xs = [x for x in range(W) if g[y][x] == 'u']
        if kind == 'soldier' and len(xs) > 2 and (y - st) == 3:
            for x in xs[1:3]: g[y][x] = 'k'
    for y in range(len(g)):
        for x in range(W):
            if g[y][x] == 'c': g[y][x] = 'u'
    return g

EFR4 = [0, 2, 3, 4, 7, 9, 14, 15]   # quieto, caminar x3, golpe, apuntar, herido, caido
