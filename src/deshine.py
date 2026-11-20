"""Quitar brillos blancos sobre piel y pelo (los ojos y la ropa se mantienen)."""
def deshine(g):
    H = len(g); W = len(g[0])
    g = [r[:] for r in g]
    seen = set()
    for y in range(H):
        for x in range(W):
            if g[y][x] != 'w' or (x, y) in seen: continue
            comp = []; st = [(x, y)]; seen.add((x, y))
            while st:
                a, b = st.pop(); comp.append((a, b))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    c, d = a + dx, b + dy
                    if 0 <= c < W and 0 <= d < H and (c, d) not in seen and g[d][c] == 'w':
                        seen.add((c, d)); st.append((c, d))
            if len(comp) > 4: continue
            nb = []
            cs = set(comp)
            for a, b in comp:
                for dx in (-1, 0, 1):
                    for dy in (-1, 0, 1):
                        c, d = a + dx, b + dy
                        if (c, d) in cs or not (0 <= c < W and 0 <= d < H): continue
                        nb.append(g[d][c])
            sh = sum(1 for c in nb if c in 'sh')
            if 'c' in nb or 'u' in nb or 'g' in nb: continue
            if sh >= len(nb) * 0.5:
                rep = 's' if nb.count('s') >= nb.count('h') else 'h'
                for a, b in comp: g[b][a] = rep
    return g
