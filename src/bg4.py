"""Escenarios v3: bloques de fachada (16x80), calle (filas 18-29), banda lejana. 4 temas."""
import random, math
from art import Canvas

def cv(): return Canvas(16, 80)

def windows(c, y0, y1, step=16, col=3, frame=1, w=10, h=9, x0=3):
    for y in range(y0, y1, step):
        c.rect(x0, y, x0 + w - 1, y + h - 1, frame)
        c.rect(x0 + 1, y + 1, x0 + w - 2, y + h - 2, col)
        c.line(x0 + 1, y + h // 2, x0 + w - 2, y + h // 2, frame)

def text_on(c, txt, x, y, col):
    from gen import FONT
    for i, ch in enumerate(txt):
        g = FONT.get(ch)
        if not g: continue
        for yy, r in enumerate(g):
            for xx, p in enumerate(r):
                if p == '#': c.set(x + xx, y + i * 8 + yy, col)

# -------------------------------------------------------------- tema A: playa / art deco
def A_blocks():
    B = []
    # 0 hotel con ventanas
    c = cv(); c.rect(0, 10, 15, 79, 2); c.rect(0, 10, 15, 12, 3); c.line(0, 13, 15, 13, 1)
    windows(c, 18, 70, 16, col=3, frame=1); c.line(0, 79, 15, 79, 1)
    B.append((c, [2, 2, 2, 2, 2]))
    # 1 hotel con letrero vertical HOTEL (neon)
    c = cv(); c.rect(0, 10, 15, 79, 2); c.rect(0, 10, 15, 12, 3)
    c.rect(3, 16, 12, 60, 1); text_on(c, "HOTEL", 6, 17, 2)
    c.rect(2, 66, 13, 79, 1); c.rect(4, 68, 11, 79, 3)
    B.append((c, [2, 1, 1, 1, 2]))
    # 2 entrada con toldo a rayas
    c = cv(); c.rect(0, 10, 15, 79, 2); c.rect(0, 10, 15, 12, 3)
    windows(c, 18, 40, 16, col=3, frame=1)
    for x in range(0, 16): c.line(x, 46, x, 54, 3 if (x // 2) % 2 else 2)
    c.line(0, 54, 15, 54, 1); c.rect(3, 58, 12, 79, 1); c.rect(4, 59, 11, 79, 3)
    B.append((c, [2, 2, 1, 2, 2]))
    # 3 palmera (cielo atras)
    c = cv()
    for y in range(28, 80): c.set(7 + int(2 * math.sin(y / 12)), y, 1); c.set(8 + int(2 * math.sin(y / 12)), y, 1)
    for a in range(0, 360, 40):
        r = math.radians(a)
        for t in range(1, 9):
            c.set(8 + t * math.cos(r), 26 + t * math.sin(r) * .6 + t * t * .05, 2)
    c.ellipse(8, 27, 2, 2, 1)
    B.append((c, [1, 1, 1, 1, 1]))
    # 4 tienda SURF con vitrina
    c = cv(); c.rect(0, 30, 15, 79, 2); c.rect(0, 30, 15, 32, 1)
    c.rect(1, 36, 14, 46, 1); text_on(c, "", 0, 0, 1)
    c.rect(2, 52, 13, 76, 1); c.rect(3, 53, 12, 75, 3); c.line(8, 53, 8, 75, 1)
    for y in range(37, 46, 2): c.line(2, y, 13, y, 3)
    B.append((c, [1, 1, 2, 2, 2]))
    # 5 baranda baja (cielo)
    c = cv(); c.rect(0, 64, 15, 79, 2); c.line(0, 64, 15, 64, 3); c.line(0, 56, 15, 56, 3)
    for x in (1, 6, 11): c.line(x, 56, x, 64, 3)
    B.append((c, [1, 1, 1, 2, 2]))
    return B

# -------------------------------------------------------------- tema B: calle / neon
def B_blocks():
    B = []
    def brick(c, y0):
        c.rect(0, y0, 15, 79, 2)
        for y in range(y0, 80, 4):
            c.line(0, y, 15, y, 1)
            off = 0 if (y // 4) % 2 else 4
            for x in range(off, 16, 8): c.line(x, y, x, y + 3, 1)
    c = cv(); brick(c, 6); windows(c, 12, 60, 16, col=3, frame=1); B.append((c, [2, 2, 2, 2, 2]))
    c = cv(); brick(c, 6); c.rect(1, 20, 14, 46, 1); text_on(c, "BAR", 5, 22, 3)
    c.rect(2, 54, 13, 79, 1); c.rect(3, 55, 12, 79, 3); B.append((c, [2, 1, 1, 2, 2]))
    c = cv(); brick(c, 6); windows(c, 12, 30, 16, col=3, frame=1)
    for x in range(16): c.line(x, 36, x, 44, 3 if (x // 2) % 2 else 2)
    c.rect(1, 50, 14, 76, 1); c.rect(2, 51, 13, 75, 3)
    c.line(2, 63, 13, 63, 1); B.append((c, [2, 2, 1, 2, 2]))
    c = cv(); c.rect(0, 0, 15, 79, 1)                                # callejon oscuro
    c.rect(2, 60, 13, 79, 2); c.line(2, 60, 13, 60, 3); B.append((c, [2, 2, 2, 2, 2]))
    c = cv(); brick(c, 6)
    for y in range(14, 60, 12): c.line(0, y, 15, y, 3); c.line(0, y + 1, 15, y + 1, 1)
    c.line(13, 14, 13, 60, 3); c.rect(4, 62, 11, 79, 1); B.append((c, [2, 2, 2, 2, 2]))
    c = cv(); brick(c, 6); text_on(c, "GT", 4, 30, 3); c.set(2, 50, 3); c.set(12, 40, 3)
    B.append((c, [2, 1, 1, 2, 2]))
    return B

# -------------------------------------------------------------- tema C: puerto
def C_blocks():
    B = []
    def cont(c, y0, y1, col):
        c.rect(0, y0, 15, y1, col); c.rect(0, y0, 15, y0, 1); c.rect(0, y1, 15, y1, 1)
        for x in range(1, 16, 3): c.line(x, y0 + 2, x, y1 - 2, 1)
    c = cv(); cont(c, 24, 50, 2); cont(c, 52, 79, 3); B.append((c, [1, 2, 2, 2, 2]))
    c = cv(); cont(c, 40, 79, 2); B.append((c, [1, 1, 2, 2, 2]))
    c = cv()                                                         # pata de grua
    c.line(3, 0, 3, 79, 2); c.line(12, 0, 12, 79, 2)
    for y in range(0, 80, 10): c.line(3, y, 12, y + 10, 2); c.line(12, y, 3, y + 10, 2)
    B.append((c, [1, 1, 1, 1, 1]))
    c = cv(); c.rect(0, 20, 15, 79, 2); c.rect(1, 40, 14, 79, 1)    # porton
    for y in range(41, 80, 3): c.line(1, y, 14, y, 3)
    c.rect(0, 20, 15, 23, 3); B.append((c, [1, 2, 2, 2, 2]))
    c = cv()                                                         # mar + bitas
    for y in range(52, 80):
        for x in range(16):
            if (x + y // 3) % 7 == 0: c.set(x, y, 3)
            else: c.set(x, y, 2)
    c.rect(5, 70, 9, 79, 1); B.append((c, [1, 1, 1, 1, 1]))
    c = cv(); c.rect(1, 50, 14, 79, 2)                               # cajas
    c.line(1, 50, 14, 79, 1); c.line(14, 50, 1, 79, 1); c.rect(1, 50, 14, 50, 1)
    c.rect(4, 34, 12, 49, 2); c.line(4, 34, 12, 49, 1); B.append((c, [1, 1, 2, 2, 2]))
    return B

# -------------------------------------------------------------- tema D: militar / aeropuerto
def D_blocks():
    B = []
    def corr(c, y0):
        c.rect(0, y0, 15, 79, 2)
        for x in range(0, 16, 3): c.line(x, y0, x, 79, 1)
    c = cv(); corr(c, 16); c.rect(0, 16, 15, 18, 3); B.append((c, [2, 2, 2, 2, 2]))
    c = cv(); corr(c, 16); c.rect(1, 30, 14, 79, 1); c.rect(2, 31, 13, 79, 2)
    text_on(c, "A1", 5, 36, 3); B.append((c, [2, 2, 1, 1, 2]))
    c = cv()                                                         # alambrado
    for y in range(30, 80):
        for x in range(16):
            if (x + y) % 6 == 0 or (x - y) % 6 == 0: c.set(x, y, 2)
    c.line(0, 30, 15, 30, 1); c.line(0, 26, 15, 26, 3)
    for x in range(0, 16, 4): c.set(x, 25, 3); c.set(x + 1, 27, 3)
    B.append((c, [1, 1, 2, 2, 2]))
    c = cv()                                                         # torre de vigilancia
    c.rect(2, 10, 13, 24, 2); c.rect(1, 8, 14, 10, 1); c.rect(4, 14, 11, 18, 1)
    c.line(3, 24, 1, 79, 1); c.line(12, 24, 14, 79, 1); c.line(2, 40, 13, 50, 1); c.line(13, 40, 2, 50, 1)
    B.append((c, [2, 2, 1, 1, 1]))
    c = cv()                                                         # sacos de arena
    for row, y in enumerate(range(62, 80, 6)):
        for x in range(-4 + (row % 2) * 4, 16, 8):
            c.ellipse(x + 4, y + 3, 4, 3, 2); c.line(x, y + 5, x + 8, y + 5, 1)
    B.append((c, [1, 1, 1, 2, 2]))
    c = cv(); c.rect(0, 30, 15, 79, 2); c.rect(0, 30, 15, 32, 1)
    windows(c, 38, 70, 18, col=3, frame=1); B.append((c, [1, 1, 2, 2, 2]))
    return B

THEMES = {'A': A_blocks, 'B': B_blocks, 'C': C_blocks, 'D': D_blocks}

def street(theme):
    """12 filas x 4 columnas de tile (32 px repetidos) para filas 18..29."""
    c = Canvas(32, 96)
    # 18-19: base de fachada / vereda posterior
    c.rect(0, 0, 31, 15, 2); c.line(0, 0, 31, 0, 1); c.line(0, 15, 31, 15, 1)
    for x in range(0, 32, 8): c.line(x, 1, x, 14, 1)
    # 20-29: calle negra con una sola linea (sin veredas)
    c.rect(0, 16, 31, 95, 1)
    c.rect(0, 56, 15, 57, 3)                                         # linea discontinua
    return c

def farband(theme, seed):
    R = random.Random(seed)
    W, H = 128, 32
    img = [[0] * W for _ in range(H)]
    for _ in range(4):
        cx, cy = R.randint(0, W), R.randint(3, 12)
        for k in range(4):
            ex, ey = cx + R.randint(-9, 9), cy + R.randint(-1, 2)
            rx, ry = R.randint(5, 9), R.randint(2, 3)
            for y in range(ey - ry, ey + ry + 1):
                for x in range(ex - rx, ex + rx + 1):
                    if ((x - ex) / rx) ** 2 + ((y - ey) / ry) ** 2 <= 1 and 0 <= y < H:
                        img[y][x % W] = 3
    x = 0
    while x < W:
        w = R.randint(5, 12); h = R.randint(6, 16) if theme in 'BD' else R.randint(4, 12)
        for xx in range(x, min(W, x + w)):
            for y in range(H - h, H): img[y][xx] = 1
        if theme == 'A' and R.random() < .5:
            px = x + w // 2
            for y in range(H - h - 7, H - h): img[y][px % W] = 1
            for d in range(-3, 4): img[H - h - 7 + abs(d) // 2][(px + d) % W] = 2
        for k in range(R.randint(1, 3)):
            lx, ly = x + R.randint(1, max(1, w - 2)), H - R.randint(2, max(3, h - 1))
            if 0 <= ly < H: img[ly][lx % W] = 2
        x += w + R.randint(0, 3)
    if theme == 'C':
        for gx in (30, 95):
            for y in range(4, H): img[y][gx] = 1
            for xx in range(gx - 14, gx + 8): img[4][xx % W] = 1
    return img

def tiles_from(img_rows, w, h):
    """img_rows: lista de listas (0-3). Devuelve grilla de tiles (tuplas de strings)."""
    out = []
    for ty in range(h // 8):
        row = []
        for tx in range(w // 8):
            t = tuple(''.join('.' if img_rows[ty * 8 + y][tx * 8 + x] == 0 else str(img_rows[ty * 8 + y][tx * 8 + x])
                              for x in range(8)) for y in range(8))
            row.append(t)
        out.append(row)
    return out
