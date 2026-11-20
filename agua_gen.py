"""Nivel 6: BAHIA DE NICE (persecucion en motos de agua). Arte y datos para el banco 9."""
import random
from art import Canvas
from art4 import to_grid, paste
from sprite3 import quantize, quantize_layered, nes, CLS_RGB, frame

AGUA_BG_UNIT = 202        # 2 KB (R1): cielo, costa, mar
AGUA_PL_UNIT = 204        # 3 KB: moto del jugador (Jose / Luciana / los dos) -> R2
AGUA_EN_UNIT = 207        # R3: policias en moto de agua + tiburones
AGUA_BOSS_UNIT = 208      # R3 durante el jefe: el yate
ASC_R1 = 210              # 2 KB: escena del muelle (tiles $80-$FF)
ASC_A = 212               # 2 KB: fuente + tiles $48-$7F de la escena
ASC_SPR = 214             # 2 KB (R4/R5): moto vacia y policias de la escena
AGUA_FONT = 216           # 2 KB (R0 del nivel): fuente + tiles $48-$7F del yate (fondo)
YC0, YR0, YR1 = 22, 12, 26   # el yate ocupa columnas 22..31, filas 12..25 de la pantalla

K, W, C, S, H, U, V, G = 1, 2, 3, 4, 5, 6, 7, 8
SYM = {K: 'k', W: 'w', C: 'c', S: 's', H: 'h', U: 'u', V: 'v', G: 'g'}


def jetski(ph, body, flip=False):
    """moto de agua mirando a la derecha (38x15). body = clase del casco (c camisa / u azul policia)"""
    cv = Canvas(40, 16)
    # casco
    cv.poly([(1, 7), (30, 6), (39, 9), (34, 13), (4, 13)], W)
    cv.poly([(2, 10), (36, 10), (34, 13), (4, 13)], body)          # franja de color abajo
    cv.line(4, 9, 33, 9, body)
    # asiento
    cv.rect(6, 4, 20, 6, K)
    # tablero + manubrio
    cv.poly([(22, 6), (27, 2), (31, 6)], body)
    cv.line(25, 1, 28, 0, K); cv.rect(24, 1, 25, 2, K)
    cv.outline(K)
    # espuma atras
    if ph == 0:
        cv.rect(0, 13, 2, 14, W); cv.set(-1, 12, W)
    else:
        cv.rect(0, 12, 1, 13, W); cv.set(2, 14, W)
    g = to_grid(cv, SYM)
    if flip: g = [list(reversed(r)) for r in g]
    return g


def upper(g, rows):
    """parte de arriba del personaje (cabeza + torso)"""
    t = [r[:] for r in g[:rows]]
    while all(v == '.' for v in t[0]): t.pop(0)
    return t


def rider_grid(chars, ph):
    """chars: lista de (fila del personaje, recolor) del de adelante al de atras"""
    Wd = 40 + 16 * (len(chars) - 1)
    out = [['.'] * Wd for _ in range(40)]
    bodies = []
    for row, rec in chars:
        t = upper(frame(row, 0), 25)
        if rec: t = [[rec.get(v, v) for v in r] for r in t]
        bodies.append(t)
    js = jetski(ph, 'c')
    if len(chars) == 2:   # moto mas larga para dos
        js = [r[:20] + r[4:20] + r[20:] for r in js]
    oy = 40 - len(js)
    # de atras hacia adelante (el de adelante tapa al de atras)
    for i in range(len(bodies) - 1, -1, -1):
        b = bodies[i]
        x = (Wd - 40) + 2 - 16 * i if len(bodies) == 2 else 2
        x = 2 + 16 * (len(bodies) - 1 - i)
        y = oy + 6 - len(b) + ((ph if i == 0 else 1 - ph) if len(chars) == 1 else 0)
        paste(out, b, x, y)
    paste(out, js, 0, oy)
    while all(v == '.' for v in out[0]): out.pop(0)
    return out


def cop_jetski(ph):
    """policia de la calle (pose apuntando) arriba de una moto de agua policial, mirando a la izquierda"""
    from enemy4 import make_enemy2
    c = make_enemy2(frame(0, 9), 'cop')
    c = [list(reversed(r)) for r in c]
    t = upper(c, 23)
    js = jetski(ph, 'u', flip=True)
    Wd = 40
    out = [['.'] * Wd for _ in range(40)]
    oy = 40 - len(js)
    paste(out, t, 10, oy + 6 - len(t))
    paste(out, js, 0, oy)
    while all(v == '.' for v in out[0]): out.pop(0)
    return out


def shark(ph):
    """tiburon saltando (ph 0 subiendo, 1 arriba, 2 bajando), mirando a la izquierda"""
    cv = Canvas(44, 30)
    import math
    ang = {0: -0.45, 1: 0.0, 2: 0.45}[ph]
    def P(x, y):   # rota alrededor del centro
        cx, cy = 22, 15
        dx, dy = x - cx, y - cy
        return (cx + dx * math.cos(ang) - dy * math.sin(ang), cy + dx * math.sin(ang) + dy * math.cos(ang))
    body = [P(x, y) for x, y in [(2, 15), (8, 10), (20, 8), (32, 10), (38, 14), (32, 18), (18, 20), (6, 19)]]
    cv.poly(body, U)
    belly = [P(x, y) for x, y in [(3, 16), (10, 17), (24, 19), (34, 16), (32, 18), (18, 20), (6, 19)]]
    cv.poly(belly, W)
    cv.poly([P(x, y) for x, y in [(18, 9), (24, 1), (26, 9)]], U)              # aleta dorsal
    cv.poly([P(x, y) for x, y in [(36, 13), (44, 5), (41, 14), (44, 23), (36, 16)]], U)   # cola
    cv.poly([P(x, y) for x, y in [(16, 19), (22, 26), (24, 19)]], U)          # aleta de abajo
    # boca con dientes
    m = [P(x, y) for x, y in [(3, 15), (11, 14), (11, 17), (5, 18)]]
    cv.poly(m, K)
    for x in (5, 7, 9):
        a = P(x, 15); cv.set(round(a[0]), round(a[1]), W)
    e = P(9, 12); cv.set(round(e[0]), round(e[1]), K); cv.set(round(e[0]) + 1, round(e[1]), K)
    for gx in (13, 15, 17):                                                     # agallas
        a = P(gx, 12); b = P(gx, 16); cv.line(a[0], a[1], b[0], b[1], K)
    cv.outline(K)
    return to_grid(cv, SYM)


def fin():
    """aleta de tiburon asomando + estela (mirando a la izquierda)"""
    cv = Canvas(24, 10)
    cv.poly([(4, 8), (10, 0), (13, 8)], U)
    cv.line(10, 1, 12, 7, W)
    cv.outline(K)
    cv.line(0, 9, 23, 9, W); cv.line(14, 8, 22, 8, W)
    return to_grid(cv, SYM)


def yacht(ph):
    """la punta de un yate (mirando a la izquierda) con dos tiradores en la cubierta (56x40)"""
    cv = Canvas(56, 40)
    # casco blanco con franja azul
    cv.poly([(0, 20), (56, 18), (56, 39), (18, 39)], W)
    cv.poly([(7, 25), (56, 23), (56, 27), (10, 29)], U)
    cv.line(2, 21, 56, 19, K)
    for x in (30, 40, 50): cv.ellipse(x, 33, 1.6, 1.6, K)            # ojos de buey
    cv.poly([(4, 18), (56, 16), (56, 19), (2, 20)], S)                # cubierta de madera
    # cabina
    cv.poly([(28, 16), (33, 4), (56, 4), (56, 16)], W)
    cv.poly([(32, 8), (35, 6), (56, 6), (56, 11), (31, 11)], K)       # vidrio oscuro
    cv.line(37, 7, 43, 7, U); cv.line(47, 7, 53, 7, U)
    cv.rect(42, 1, 56, 4, W); cv.rect(46, 0, 47, 1, K)
    # baranda
    cv.line(3, 14, 27, 14, K)
    for x in range(5, 27, 6): cv.line(x, 14, x, 17, K)
    # tiradores (gorra azul)
    for i, hx in enumerate((11, 21)):
        cv.rect(hx - 2, 9, hx + 2, 16, U)
        cv.ellipse(hx, 6, 2.2, 2.2, S)
        cv.rect(hx - 3, 3, hx + 2, 4, U)
        up = (ph + i) % 2 == 0
        cv.line(hx - 3, 11, hx - 8, 13 if up else 10, K)
        if up: cv.set(hx - 9, 14, S)
    cv.outline(K)
    return to_grid(cv, SYM)


def gunman(ph):
    """tirador en la cubierta del yate (mirando a la izquierda), apuntando hacia abajo"""
    cv = Canvas(16, 20)
    cv.rect(7, 8, 11, 17, U)                  # cuerpo
    cv.rect(7, 17, 8, 19, K); cv.rect(10, 17, 11, 19, K)
    cv.ellipse(9, 5, 2.6, 2.6, S)             # cabeza
    cv.rect(5, 1, 11, 3, U); cv.rect(4, 3, 8, 3, U)   # gorra
    cv.set(7, 5, K)
    cv.line(7, 10, 2, 13, K); cv.line(7, 11, 2, 14, K)  # arma hacia abajo/adelante
    cv.rect(5, 10, 7, 12, S)
    if ph: cv.rect(0, 14, 1, 16, S); cv.set(0, 13, W)   # fogonazo
    cv.outline(K)
    return to_grid(cv, SYM)


def yacht_bg_img():
    """yate visto de costado, la proa a la izquierda: 80x112 (columnas 22..31, filas 12..25).
    formas alineadas a la grilla de 8x8 para repetir tiles. clases: 'w' blanco, 'l' sombra, 'k' negro, 'b' franja"""
    Wd, Hd = 80, 112
    g = [['.'] * Wd for _ in range(Hd)]
    def R(x0, y0, x1, y1, c):
        for yy in range(y0, y1 + 1):
            for xx in range(x0, x1 + 1):
                if 0 <= xx < Wd and 0 <= yy < Hd: g[yy][xx] = c
    # casco: proa en diagonal (pendiente 1) desde (0,56) hasta la linea de agua
    for yy in range(56, 104):
        for xx in range(max(0, yy - 56), Wd):
            g[yy][xx] = 'w'
        if yy - 56 < Wd: g[yy][yy - 56] = 'k'
    for yy in range(64, 72):
        for xx in range(yy - 55, Wd): g[yy][xx] = 'k' if yy in (64, 71) else 'l'   # franja
    for yy in range(88, 104):
        for xx in range(yy - 55, Wd):
            if g[yy][xx] == 'w': g[yy][xx] = 'l'                # sombra
    R(0, 56, 79, 56, 'k')                                       # borde de la cubierta
    for cx in (44, 60, 76):                                     # ojos de buey (uno por tile)
        R(cx - 2, 78, cx + 1, 81, 'k'); R(cx - 1, 79, cx, 80, 'l')
    # baranda de la proa (postes cada 8)
    R(0, 48, 39, 48, 'k')
    for xx in range(4, 40, 8): R(xx, 48, xx, 55, 'k')
    # cabina baja
    R(40, 32, 79, 55, 'w'); R(40, 32, 79, 32, 'k'); R(40, 32, 40, 55, 'k')
    R(42, 40, 79, 46, 'k')                                      # ventanal
    for xx in range(44, 80, 8): R(xx, 41, xx + 2, 41, 'l')
    R(41, 52, 79, 55, 'l')
    # cabina alta
    R(56, 16, 79, 31, 'w'); R(56, 16, 79, 16, 'k'); R(56, 16, 56, 31, 'k')
    R(58, 21, 79, 26, 'k')
    for xx in range(60, 80, 8): R(xx, 22, xx + 2, 22, 'l')
    # mastil + radar
    R(70, 4, 71, 15, 'k'); R(64, 2, 78, 4, 'w'); R(64, 1, 78, 1, 'k'); R(64, 5, 78, 5, 'k')
    return g


def yacht_bg(sea_img, sea_mp, sea_tl, sea_attr):
    """-> tiles nuevos (para $48..), filas de nametable 12..25 completas, atributos completos"""
    y = yacht_bg_img()
    new = []
    rows = []
    for ty in range(YR0, YR1):
        row = list(sea_mp[ty - 4])
        for tx in range(YC0, 32):
            t = []
            part = any(y[(ty - YR0) * 8 + py][(tx - YC0) * 8 + px] != '.' for py in range(8) for px in range(8))
            for py in range(8):
                r = ''
                for px in range(8):
                    yy, xx = (ty - YR0) * 8 + py, (tx - YC0) * 8 + px
                    c = y[yy][xx]
                    if c == '.':
                        sc = sea_img[(ty - 4) * 8 + py][tx * 8 + px][0]
                        r += '1' if part else {'O': '2', 'F': '3'}.get(sc, '1')
                    else: r += {'w': '2', 'l': '3', 'k': '.', 'b': '1'}[c]
                t.append(r)
            t = tuple(t)
            if t in sea_tl: row[tx] = 0x80 + sea_tl.index(t)
            else:
                if t not in new: new.append(t)
                row[tx] = 0x48 + new.index(t)
        rows.append(row)
    assert len(new) <= 56, ('yate: tiles', len(new))
    # atributos: los bloques del yate con la paleta 1 (blanco)
    attr = list(sea_attr)
    for ty in range(YR0, YR1, 2):
        for tx in range(YC0, 32, 2):
            ay, ax = ty // 4, tx // 4
            q = ((ty % 4) // 2) * 2 + (tx % 4) // 2
            i = ay * 8 + ax
            attr[i] = (attr[i] & ~(3 << (q * 2))) | (1 << (q * 2))
    return new, rows, attr


def cls_for():
    c = dict(CLS_RGB)
    c.update(k=tuple(nes(0x0F)), w=tuple(nes(0x30)), s=tuple(nes(0x27)), h=tuple(nes(0x17)),
             c=tuple(nes(0x2C)), u=tuple(nes(0x12)), g=tuple(nes(0x30)))
    return c


def pix_rows(p): return tuple(''.join(str(v) if v else '.' for v in r) for r in p)


class Bank:
    def __init__(s, base, cap): s.base, s.cap, s.t = base, cap, [tuple(['........'] * 8)]
    def tid(s, rows):
        if rows not in s.t: s.t.append(rows)
        assert len(s.t) <= s.cap, ('banco lleno', s.base, len(s.t))
        return s.base + s.t.index(rows)


VARS = [[(0, None)], [(1, None)], [(0, {'c': 'w'}), (1, None)]]   # Jose, Luciana, los dos (Jose maneja)


def build():
    """-> (bancos de jugador [3], banco enemigos, banco yate, asm)"""
    A = ['; ---- datos del nivel motos de agua (generado por agua_gen.py) ----']
    for n in ('AGUA_BG_UNIT', 'AGUA_PL_UNIT', 'AGUA_EN_UNIT', 'AGUA_BOSS_UNIT', 'ASC_R1', 'ASC_A', 'ASC_SPR', 'AGUA_FONT'):
        A.append('%s = %d' % (n, globals()[n]))
    cp = cls_for()
    pal_p = [(1, [0x0F, 0x30, 0x2C]), (0, [0x0F, 0x27, 0x17]), (3, [0x0F, 0x27, 0x30])]
    pal_e = [(2, [0x0F, 0x27, 0x12]), (3, [0x0F, 0x27, 0x30])]
    frames = []
    def add(name, ents, bank):
        frames.append((name, [(dy, dx, bank.tid(pix_rows(p)), ap) for dx, dy, p, ap in ents]))
    pbanks = []
    for vi, ch in enumerate(VARS):
        b = Bank(0x00, 64)
        for ph in range(2):
            ents = quantize(rider_grid(ch, ph), pal_p, cp)
            if vi == 0: add('pl%d' % ph, ents, b)
            else:
                L = [(dy, dx, b.tid(pix_rows(p)), ap) for dx, dy, p, ap in ents]
                frames.append(('pl%d_v%d' % (ph, vi), L))
        pbanks.append(b.t)
    be = Bank(0x40, 64)
    for ph in range(2): add('cj%d' % ph, quantize(cop_jetski(ph), pal_e, cp), be)
    for ph in range(2): add('sk%d' % ph, quantize(shark(ph), pal_e, cp), be)
    # bajando = el de subida dado vuelta verticalmente (mismos tiles, atributo $80)
    up = frames[-2][1]
    top = min(e[0] for e in up); bot = max(e[0] for e in up) + 8
    frames.append(('sk2', [(top + bot - dy - 8, dx, t, ap | 0x80) for dy, dx, t, ap in up]))
    add('fn', quantize(fin(), pal_e, cp), be)
    bb = Bank(0x40, 64)
    for ph in range(2): add('gm%d' % ph, quantize(gunman(ph), pal_e, cp), bb)
    bs = Bank(0x80, 128)
    add('je', quantize(jetski(0, 'c'), pal_p, cp), bs)
    for ph in range(2): add('scj%d' % ph, quantize(cop_jetski(ph), pal_e, cp), bs)
    for name, L in frames:
        flat = [len(L)]
        for dy, dx, t, ap in L: flat += [dy & 255, dx & 255, t, ap]
        A.append('af_%s: .byte %s' % (name, ','.join('$%02X' % v for v in flat)))
    A.append('af_lo: .byte ' + ','.join('<af_%s' % n for n, _ in frames))
    A.append('af_hi: .byte ' + ','.join('>af_%s' % n for n, _ in frames))
    for i, (n, L) in enumerate(frames):
        A.append('AF_%s = %d' % (n.upper(), i))
    print('agua sprites: jugador %s tiles, enemigos %d, yate %d; sprites por cuadro %s' % (
        [len(t) for t in pbanks], len(be.t), len(bb.t), [(n, len(L)) for n, L in frames]))
    return pbanks, be.t, bb.t, bs.t, A


# ------------------------------------------------------------ fondo: cielo, costa de Nice City y el mar
def sea_bg():
    """filas 4..29 (26 filas). colores: cielo 1/2/3 (paleta 1), costa (paleta 2), mar (paleta 3)"""
    Wd, Hd = 256, 26 * 8
    img = [[('S', 0)] * Wd for _ in range(Hd)]
    R = random.Random(11)
    SKY_END = 4 * 8          # filas 4..7 cielo con nubes
    COAST_END = 8 * 8        # filas 8..11 costa (edificios sobre el cielo)
    def cloud(cx, cy, w, h):
        for y in range(SKY_END):
            for x in range(Wd):
                for k in range(5):
                    bx = cx + (k - 2) * w * 0.22
                    by = cy + (abs(k - 2) * h * 0.18)
                    rx = w * (0.30 if k != 2 else 0.36); ry = h * (0.55 if k != 2 else 0.75)
                    dx = min(abs(x - bx), Wd - abs(x - bx))
                    if (dx / rx) ** 2 + ((y - by) / ry) ** 2 <= 1:
                        img[y][x] = ('W', 0) if (y - by) <= ry * 0.35 else ('L', 0)
    cloud(60, 12, 50, 10); cloud(180, 20, 60, 12); cloud(250, 6, 30, 6)
    # costa lejana: edificios de Nice City (silueta gris con ventanas) sobre la linea de agua
    x = 0
    while x < Wd:
        w = R.choice([1, 2, 2, 3]) * 8; h = R.choice([2, 3, 4, 5, 6]) * 4 + 4
        top = COAST_END - h
        for yy in range(max(SKY_END, top), COAST_END):
            for xx in range(x, min(Wd, x + w)):
                img[yy][xx] = ('B', 1)
                if (yy - top) % 4 == 2 and (xx - x) % 4 == 1: img[yy][xx] = ('Y', 1)
        x += w
    for yy in range(COAST_END - 3, COAST_END):
        for xx in range(Wd): img[yy][xx] = ('P', 1)                 # palmeras / playa (linea)
    for xx in range(0, Wd, 24):                                      # palmeras chicas
        for yy in range(COAST_END - 10, COAST_END - 3): img[yy][xx + 3] = ('P', 1)
        for dx in range(-3, 4): img[COAST_END - 10][xx + 3 + dx] = ('P', 1)
    # el mar: ondas en filas, mas juntas cerca del horizonte (patron que se repite cada 64 px)
    for y in range(COAST_END, Hd):
        for xx in range(Wd): img[y][xx] = ('M', 2)
    y = COAST_END + 1
    k = 0
    while y < Hd - 1:
        d = y - COAST_END
        per = 5 if d < 20 else 8 if d < 60 else 11
        ln = 5 if d < 20 else 9 if d < 60 else 14
        off = (k * 23) % 64
        for xx in range(Wd):
            u = (xx + off) % 64
            if u < ln or (32 <= u < 32 + ln // 2): img[y][xx] = ('O', 2)
            if d > 20 and 1 <= u < ln - 1 and y + 1 < Hd: img[y + 1][xx] = ('F', 2) if u % 7 < 3 else ('O', 2)
        y += per; k += 1
    PIDX = [{'S': '.', 'W': '2', 'L': '3'},           # paleta 1 cielo: 0F? no: el fondo es el color 1
            {'S': '1', 'B': '2', 'Y': '3', 'P': '3'},
            {'M': '1', 'O': '2', 'F': '3'}]
    tl = []; mp = []; pal_of = {}
    for ty in range(26):
        row = []
        for tx in range(32):
            blk = [img[ty * 8 + y][tx * 8:tx * 8 + 8] for y in range(8)]
            p = 0 if ty < 4 else 1 if ty < 8 else 2
            rows = []
            for r in blk:
                s_ = ''
                for c, pp in r:
                    if p == 0: s_ += {'W': '2', 'L': '3'}.get(c, '1')
                    elif p == 1: s_ += {'B': '2', 'Y': '3', 'P': '3'}.get(c, '1')
                    else: s_ += {'O': '2', 'F': '3'}.get(c, '1')
                rows.append(s_)
            key = tuple(rows)
            if key not in tl: tl.append(key)
            row.append(0x80 + tl.index(key))
            pal_of[(tx, ty)] = p + 1
        mp.append(row)
    assert len(tl) <= 128, len(tl)
    attr = []
    for ay in range(8):
        for ax in range(8):
            v = 0
            for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                ty = ay * 4 + dy * 2; tx = ax * 4 + dx * 2
                if ty < 4: p = 0
                else: p = pal_of[(tx, min(ty, 29) - 4)]
                v |= p << (q * 2)
            attr.append(v)
    return tl, mp, attr, img


# paletas de fondo del nivel: 1 cielo, 2 costa, 3 mar (la 0 es la del HUD)
SEA_PAL = [0x0F, 0x21, 0x30, 0x31, 0x0F, 0x21, 0x00, 0x38, 0x0F, 0x21, 0x11, 0x31]


YACHT_TILES = []
def bg_asm():
    tl, mp, attr, img = sea_bg()
    yt, yrows, yattr = yacht_bg(img, mp, tl, attr)
    YACHT_TILES[:] = yt
    A = ['yacht_rows:']
    for r in yrows: A.append('    .byte ' + ','.join('$%02X' % v for v in r))
    A.append('yacht_attr: .byte ' + ','.join('$%02X' % v for v in yattr))
    A.append('YR0 = %d' % YR0)
    A.append('YNROWS = %d' % (YR1 - YR0))
    print('yate (fondo): %d tiles nuevos' % len(yt))
    A.append('agua_map:')
    for r in mp: A.append('    .byte ' + ','.join('$%02X' % v for v in r))
    A.append('agua_attr: .byte ' + ','.join('$%02X' % v for v in attr))
    A.append('agua_bgpal: .byte ' + ','.join('$%02X' % v for v in SEA_PAL))
    print('agua fondo: %d tiles' % len(tl))
    return tl, A


# ------------------------------------------------------------ escena: el muelle con la moto de agua
SC_RGB = {'S': (100, 176, 255), 'W': (252, 252, 252), 'L': (184, 220, 255), 'B': (124, 124, 124), 'Y': (240, 208, 176),
          'M': (60, 188, 252), 'O': (0, 88, 248), 'F': (164, 228, 252), 'D': (136, 112, 0), 'd': (80, 48, 0),
          'R': (248, 56, 0), 'K': (0, 0, 0)}
SC_PALS = {1: ['S', 'W', 'L'], 2: ['M', 'O', 'F'], 3: ['D', 'd', 'Y']}


def dock_img():
    """256x176 (filas de pantalla 8..29): costa lejos, mar y un muelle de madera a la izquierda"""
    Wd, Hd = 256, 176
    img = [['S'] * Wd for _ in range(Hd)]
    R = random.Random(3)
    def ell(cx, cy, rx, ry, c):
        for y in range(max(0, int(cy - ry)), min(Hd, int(cy + ry) + 1)):
            for x in range(max(0, int(cx - rx)), min(Wd, int(cx + rx) + 1)):
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1: img[y][x] = c
    for cx, cy, w in ((50, 14, 30), (190, 22, 40), (120, 8, 20)):
        ell(cx, cy, w, 6, 'W'); ell(cx - w * 0.4, cy - 3, w * 0.4, 5, 'W'); ell(cx, cy + 3, w * 0.9, 3, 'L')
    HOR = 56
    # el mar
    for y in range(HOR, Hd):
        d = y - HOR
        for x in range(Wd):
            img[y][x] = 'M'
            per = 6 if d < 30 else 12
            if d % per == 0 and (x + d * 3) % 28 < (5 if d < 30 else 10): img[y][x] = 'O'
            if d % per == 1 and d > 30 and 3 < (x + d * 3) % 28 < 8: img[y][x] = 'F'
    # un velero lejos
    for y in range(36, HOR):
        for x in range(200, 200 + (y - 36) // 2): img[y][x] = 'W'
    for x in range(194, 216): img[HOR - 1][x] = 'B'; img[HOR - 2][x] = 'B'
    # muelle (vista lateral): tablones sobre pilotes, de x=0 a x=120, a la altura y=96..104
    for y in range(96, 106):
        for x in range(0, 124):
            img[y][x] = 'D' if y < 103 else 'd'
            if x % 16 == 0 and y < 103: img[y][x] = 'd'
    for px in range(4, 124, 24):
        for y in range(106, 150):
            for x in range(px, px + 6):
                img[y][x] = 'd' if x in (px, px + 5) else 'D'
        for x in range(px - 1, px + 7):
            if y < Hd: img[149][x] = 'O'
    # bolardos y una soga
    for bx in (20, 92):
        for y in range(90, 96):
            for x in range(bx, bx + 6): img[y][x] = 'd'
    # baranda/poste de luz
    for y in range(60, 96): img[y][110] = 'd'; img[y][111] = 'd'
    for x in range(106, 116):
        for y in range(56, 61): img[y][x] = 'Y'
    # cartel "NICE" (bloque claro)
    return img


def dock_build():
    img = dock_img()
    Hh = len(img)
    attr_blk = {}
    for by in range(Hh // 16):
        for bx in range(16):
            best = None
            for pi, P in SC_PALS.items():
                err = sum(1 for y in range(by * 16, by * 16 + 16) for x in range(bx * 16, bx * 16 + 16)
                          if img[y][x] != 'K' and img[y][x] not in P)
                if best is None or err < best[0]: best = (err, pi)
            attr_blk[(bx, by)] = best[1]
    def tile(tx, ty):
        P = SC_PALS[attr_blk[(tx // 2, ty // 2)]]
        rows = []
        for y in range(8):
            r = ''
            for x in range(8):
                v = img[ty * 8 + y][tx * 8 + x]
                if v == 'K': r += '.'
                elif v in P: r += str(P.index(v) + 1)
                else:
                    c = SC_RGB[v]
                    d = [sum((a - b) ** 2 for a, b in zip(c, SC_RGB[p])) for p in P] + [sum(a * a for a in c)]
                    k = d.index(min(d)); r += str(k + 1) if k < 3 else '.'
            rows.append(r)
        return tuple(rows)
    r0 = []; r1 = []; mp = []
    for ty in range(22):
        row = []
        for tx in range(32):
            t = tile(tx, ty)
            if t not in r1 and t not in r0:
                if len(r1) < 128: r1.append(t)
                else: r0.append(t)
            row.append(0x80 + r1.index(t) if t in r1 else 0x48 + r0.index(t))
        mp.append(row)
    print('escena muelle: %d tiles en R1, %d en R0 (max 56)' % (len(r1), len(r0)))
    assert len(r0) <= 56
    attr = []
    for ay in range(8):
        for ax in range(8):
            v = 0
            for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                ty = ay * 4 + dy * 2; tx = ax * 4 + dx * 2
                if ty < 4: p = 0
                elif ty < 8: p = 1
                else: p = attr_blk[(tx // 2, min(10, (ty - 8) // 2))]
                v |= p << (q * 2)
            attr.append(v)
    A = ['dock_map:']
    for r in mp: A.append('    .byte ' + ','.join('$%02X' % v for v in r))
    A.append('dock_attr: .byte ' + ','.join('$%02X' % v for v in attr))
    A.append('dock_pal: .byte $0F,$21,$30,$31, $0F,$21,$11,$31, $0F,$17,$07,$37')
    return r0, r1, A


if __name__ == '__main__':
    from PIL import Image
    CC = {'k': (0, 0, 0), 'w': (250, 250, 250), 'c': (0, 220, 210), 's': (250, 160, 70), 'h': (200, 80, 10),
          'u': (30, 60, 200), 'v': (80, 160, 40), 'g': (160, 160, 160), '.': (60, 188, 252)}
    gs = [rider_grid(VARS[0], 0), rider_grid(VARS[1], 1), rider_grid(VARS[2], 0), cop_jetski(0), cop_jetski(1),
          shark(0), shark(1), shark(2), yacht(0)]
    Hm = max(len(g) for g in gs)
    im = Image.new('RGB', (sum(len(g[0]) + 6 for g in gs), Hm), CC['.'])
    x0 = 0
    for g in gs:
        for y, r in enumerate(g):
            for x, v in enumerate(r):
                if v != '.': im.putpixel((x0 + x, Hm - len(g) + y), CC[v])
        x0 += len(g[0]) + 6
    im.resize((im.width * 3, im.height * 3), Image.NEAREST).save('agua_art.png')
    img = dock_img()
    bg = Image.new('RGB', (256, 176))
    for y in range(176):
        for x in range(256): bg.putpixel((x, y), SC_RGB[img[y][x]])
    bg.resize((512, 352), Image.NEAREST).save('agua_dock.png')
    tl, mp, attr, _ = sea_bg()
    print('mar', len(tl))
    PP = [SEA_PAL[0:4], SEA_PAL[4:8], SEA_PAL[8:12]]
    bg = Image.new('RGB', (256, 208))
    # paleta por tile segun atributo
    for ty, r in enumerate(mp):
        for tx, t in enumerate(r):
            ay, ax = (ty + 4) // 4, tx // 4
            q = (((ty + 4) % 4) // 2) * 2 + (tx % 4) // 2
            p = (attr[ay * 8 + ax] >> (q * 2)) & 3
            for y, row in enumerate(tl[t - 0x80]):
                for x, ch in enumerate(row):
                    c = 0x0F if ch == '.' else PP[p - 1][int(ch)] if p else 0x30
                    bg.putpixel((tx * 8 + x, ty * 8 + y), tuple(nes(c)))
    bg.resize((512, 416), Image.NEAREST).save('agua_bg.png')
