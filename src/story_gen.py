"""Mini historia inicial: 3 escenas con los personajes grandes (estilo titulo) + dialogos.
Cada escena: 256x176 de dibujo + caja de dialogo abajo. Variantes: ambos (2P), solo Jose, solo Luciana."""
import math
import numpy as np
from PIL import Image
from emu import PAL

SRC = 'title/ref.png'
SRCRGB = {'k': (0, 0, 0), 'w': (240, 240, 240), 'p': (240, 32, 128), 'c': (0, 220, 240),
          's': (240, 160, 96), 'b': (130, 48, 16), 'g': (115, 115, 115)}
BASE = {'k': 0x0F, 'w': 0x30, 'p': 0x25, 'c': 0x2C, 's': 0x27, 'b': 0x17, 'g': 0x00, 'G': 0x2A, 'r': 0x16, 'N': 0x02}
# division entre Jose y Luciana en la imagen de referencia (x por tramos de y)
CROWD_RGB = {'k': (0, 0, 0), 'w': (245, 245, 245), 's': (240, 150, 80), 'b': (130, 50, 10), 'c': (20, 110, 230),
             'G': (70, 195, 10), 'r': (215, 40, 30), 'p': (240, 120, 190), 'y': (245, 170, 70), 'g': (168, 168, 168)}
def crowd(W=200):
    """personajes del fondo (rehenes) tomados de la imagen del usuario, sin el fondo."""
    im = np.array(Image.open('story/crowd.png').convert('RGB')).astype(int)
    Hs, Ws = im.shape[:2]
    keys = ['.'] + list(CROWD_RGB)
    ref = np.array([CROWD_RGB[k] for k in keys[1:]])
    d = ((im[:, :, None, :] - ref[None, None]) ** 2).sum(3)
    q = d.argmin(2) + 1
    r_, g_, b_ = im[:, :, 0], im[:, :, 1], im[:, :, 2]
    sky = (b_ > 225) & (r_ > 32) & (r_ < 110) & (g_ > 110) & (g_ < 185)
    white = im.min(2) > 245
    black = im.max(2) < 40
    # negro grueso = edificios del fondo
    from numpy.lib.stride_tricks import sliding_window_view
    k = 15
    pad = np.pad(black, k // 2, constant_values=False)
    dense = sliding_window_view(pad, (k, k)).mean((2, 3)) > .93
    mag = (r_ > 200) & (g_ < 80) & (b_ > 100)
    bg = sky | dense | (mag & (np.arange(Hs)[:, None] < 200))
    # bloques blancos (recortes de la imagen)
    for (x0, y0, x1, y1) in ((262, 296, 580, 361), (398, 214, 580, 300), (428, 95, 462, 214)):
        bg[y0:y1, x0:x1] = True
    # agrandar fondo un poco por bordes negros pegados al fondo
    q[bg] = 0
    F = Ws / W; H = int(Hs / F)
    out = []
    for y in range(H):
        row = []
        for x in range(W):
            blk = q[int(y * F + F * .25):int(y * F + F * .75) + 1, int(x * F + F * .25):int(x * F + F * .75) + 1]
            row.append(keys[np.bincount(blk.ravel(), minlength=len(keys)).argmax()])
        out.append(row)
    # quitar negro suelto que no toca colores (restos del edificio)
    for y in range(H):
        for x in range(W):
            if out[y][x] == 'k':
                near = any(0 <= y + dy < H and 0 <= x + dx < W and out[y + dy][x + dx] not in '.k'
                           for dy in (-2, -1, 0, 1, 2) for dx in (-2, -1, 0, 1, 2))
                if not near: out[y][x] = '.'
    conv = {'y': 's', 'g': 'w'}
    out = [[conv.get(c, c) for c in r] for r in out]
    add = []
    for y in range(H):
        for x in range(W):
            if out[y][x] != '.': continue
            if any(0 <= y + dy < H and 0 <= x + dx < W and out[y + dy][x + dx] not in '.k' for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0))):
                add.append((x, y))
    for x, y in add: out[y][x] = 'k'
    return out

STAFF_RGB = {'k': (15, 15, 20), 'w': (240, 240, 240), 's': (235, 160, 110), 'b': (140, 70, 30), 'c': (90, 160, 230),
             'N': (45, 55, 85), 'r': (200, 40, 40), 'g': (150, 150, 160)}
def staff(W=212):
    """empleados del banco (imagen del usuario) recortados del fondo"""
    from scipy import ndimage
    im = np.array(Image.open('story/staff.png').convert('RGB')).astype(int)
    M = np.load('story/staff_mask.npy')
    lab, n = ndimage.label(M)
    sizes = ndimage.sum(M, lab, range(1, n + 1))
    keep = np.argsort(sizes)[-3:] + 1
    M = np.isin(lab, keep)
    y0, y1, x0, x1 = 88, 470, 20, 1010
    im = im[y0:y1, x0:x1]; M = M[y0:y1, x0:x1]
    keys = ['.'] + list(STAFF_RGB)
    ref = np.array([STAFF_RGB[k] for k in keys[1:]])
    d = ((im[:, :, None, :] - ref[None, None]) ** 2).sum(3)
    q = d.argmin(2) + 1
    q[~M] = 0
    Hs, Ws = q.shape
    F = Ws / W; H = int(Hs / F)
    out = []
    for y in range(H):
        row = []
        for x in range(W):
            blk = q[int(y * F + F * .2):int(y * F + F * .8) + 1, int(x * F + F * .2):int(x * F + F * .8) + 1]
            row.append(keys[np.bincount(blk.ravel(), minlength=len(keys)).argmax()])
        out.append(row)
    out = [[{'g': 'w', 'r': 'k'}.get(c, c) for c in r] for r in out]
    add = []
    for y in range(H):
        for x in range(W):
            if out[y][x] != '.': continue
            if any(0 <= y + dy < H and 0 <= x + dx < W and out[y + dy][x + dx] not in '.k' for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0))):
                add.append((x, y))
    for x, y in add: out[y][x] = 'k'
    return out

STAFF2_RGB = {'k': (5, 5, 5), 'w': (235, 235, 235), 's': (200, 120, 25), 'b': (100, 50, 5), 'N': (5, 20, 125), 'c': (55, 165, 185)}
def staff2():
    """empleados limpios que dibujo el usuario (imagen a 4x de la pantalla)"""
    im = np.array(Image.open('story/staff2.png').convert('RGB')).astype(int)
    F = im.shape[1] / 256
    H = int(320 / F)
    keys = list(STAFF2_RGB)
    ref = np.array([STAFF2_RGB[k] for k in keys])
    out = []
    for y in range(H):
        row = []
        for x in range(256):
            blk = im[int(y * F + 1):int((y + 1) * F - 1), int(x * F + 1):int((x + 1) * F - 1)].reshape(-1, 3)
            d = ((blk[:, None, :] - ref[None]) ** 2).sum(2).argmin(1)
            k = keys[np.bincount(d, minlength=len(keys)).argmax()]
            row.append('.' if k == 'w' and y < H else k)
        out.append(row)
    # el blanco dentro de las personas se conserva: blanco rodeado (horizontalmente) por no-blanco
    for y in range(H):
        r = out[y]
        xs = [x for x, c in enumerate(r) if c != '.']
    return out

SPLIT = [(85, 765), (160, 765), (260, 745), (335, 710), (460, 710), (510, 765), (595, 790)]
Y0, Y1 = 85, 592
F = 6.4   # escala de la referencia a pixeles NES


def split_x(y):
    for (ya, xa), (yb, xb) in zip(SPLIT, SPLIT[1:]):
        if ya <= y <= yb: return xa + (xb - xa) * (y - ya) / (yb - ya)
    return SPLIT[-1][1]


def bust(side):
    im = np.array(Image.open(SRC).convert('RGBA')).astype(int)
    x0, x1 = (190, 800) if side == 0 else (700, 1360)
    keys = ['.'] + list(SRCRGB)
    ref = np.array([SRCRGB[k] for k in keys[1:]])
    sub = im[Y0:Y1, x0:x1]
    d = ((sub[:, :, None, :3] - ref[None, None]) ** 2).sum(3)
    q = d.argmin(2) + 1
    q[sub[:, :, 3] < 128] = 0
    for yy in range(Y1 - Y0):
        sx = split_x(yy + Y0) - x0
        if side == 0: q[yy, int(sx):] = 0
        else: q[yy, :int(sx)] = 0
    H = int((Y1 - Y0) / F); W = int((x1 - x0) / F)
    out = []
    for y in range(H):
        row = []
        for x in range(W):
            blk = q[int(y * F + F * .25):int(y * F + F * .75) + 1, int(x * F + F * .25):int(x * F + F * .75) + 1]
            row.append(keys[np.bincount(blk.ravel(), minlength=len(keys)).argmax()])
        out.append(row)
    # recortar columnas vacias
    l = min(x for r in out for x, c in enumerate(r) if c != '.')
    rr = max(x for r in out for x, c in enumerate(r) if c != '.')
    return [r[l:rr + 1] for r in out]


# ---------------------------------------------------------------- lienzo
class G:
    def __init__(s, w=256, h=176, c='k'):
        s.w, s.h = w, h
        s.p = [[c] * w for _ in range(h)]
    def set(s, x, y, c):
        x = int(round(x)); y = int(round(y))
        if 0 <= x < s.w and 0 <= y < s.h: s.p[y][x] = c
    def rect(s, x0, y0, x1, y1, c):
        for y in range(int(y0), int(y1) + 1):
            for x in range(int(x0), int(x1) + 1): s.set(x, y, c)
    def frame(s, x0, y0, x1, y1, c):
        s.rect(x0, y0, x1, y0, c); s.rect(x0, y1, x1, y1, c); s.rect(x0, y0, x0, y1, c); s.rect(x1, y0, x1, y1, c)
    def disc(s, cx, cy, r, c):
        for y in range(int(cy - r - 1), int(cy + r + 2)):
            for x in range(int(cx - r - 1), int(cx + r + 2)):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r: s.set(x, y, c)
    def line(s, x0, y0, x1, y1, c, w=1):
        n = int(max(abs(x1 - x0), abs(y1 - y0))) * 2 + 1
        for i in range(n + 1):
            t = i / n; x = x0 + (x1 - x0) * t; y = y0 + (y1 - y0) * t
            for dx in range(w):
                for dy in range(w): s.set(x + dx, y + dy, c)
    def blit(s, img, ox, oy):
        for y, r in enumerate(img):
            for x, c in enumerate(r):
                if c != '.': s.set(ox + x, oy + y, c)
    def outline(s, inside, c='k'):
        """contorno negro alrededor de los pixeles de colores 'inside'"""
        add = []
        for y in range(s.h):
            for x in range(s.w):
                if s.p[y][x] in inside: continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < s.w and 0 <= yy < s.h and s.p[yy][xx] in inside: add.append((x, y)); break
        for x, y in add: s.p[y][x] = c


GLY = {  # letras grandes 5x7
 'B': ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."],
 'A': [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
 'N': ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"],
 'C': [".####", "#....", "#....", "#....", "#....", "#....", ".####"],
 'O': [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
 '$': ["..#..", ".####", "#.#..", ".###.", "..#.#", "####.", "..#.."],
 '!': ["..#..", "..#..", "..#..", "..#..", "..#..", ".....", "..#.."],
}
def bigtext(g, txt, x, y, c, sc=1):
    for ch in txt:
        gl = GLY[ch]
        for yy, r in enumerate(gl):
            for xx, v in enumerate(r):
                if v == '#': g.rect(x + xx * sc, y + yy * sc, x + xx * sc + sc - 1, y + yy * sc + sc - 1, c)
        x += 6 * sc


def person(g, x, y, shirt, hair='b', skin='s', mark='r', long_hair=False):
    """rehen asustado con las manos arriba; (x,y) = centro de la cabeza"""
    # contorno negro primero
    g.rect(x - 9, y + 7, x + 9, y + 60, 'k')
    g.line(x - 10, y + 10, x - 16, y - 12, 'k', 5); g.line(x + 7, y + 10, x + 13, y - 12, 'k', 5)
    g.disc(x, y, 9, 'k')
    g.rect(x - 8, y + 8, x + 8, y + 60, shirt)                 # cuerpo
    g.rect(x - 2, y + 8, x + 2, y + 11, skin)                  # cuello
    g.line(x - 9, y + 11, x - 15, y - 11, skin, 3)             # brazos arriba
    g.line(x + 8, y + 11, x + 14, y - 11, skin, 3)
    g.disc(x, y, 7.6, skin)                                    # cabeza
    for yy in range(int(y - 8), int(y - 2)):                   # pelo
        for xx in range(int(x - 8), int(x + 9)):
            if (xx - x) ** 2 + (yy - y) ** 2 <= 64: g.set(xx, yy, hair)
    if long_hair: g.rect(x - 8, y - 3, x - 7, y + 7, hair); g.rect(x + 7, y - 3, x + 8, y + 7, hair)
    g.rect(x - 4, y - 1, x - 2, y + 1, 'w'); g.rect(x + 2, y - 1, x + 4, y + 1, 'w')   # ojos asustados
    g.set(x - 3, y, 'k'); g.set(x + 3, y, 'k')
    g.rect(x - 1, y + 3, x + 1, y + 5, 'k')                   # boca abierta
    if mark: bigtext(g, '!', x + 12, y - 30, mark, 2) if False else bigtext(g, '!', x + 10, y - 24, mark)


def scene_bank():
    g = G(c='w')
    g.rect(0, 0, 255, 3, 'k')
    g.blit(staff2(), 0, 0)                                   # empleados asustados (dibujo del usuario)
    # mostrador
    g.rect(0, 84, 255, 103, 'b'); g.rect(0, 82, 255, 85, 's'); g.rect(0, 86, 255, 86, 'k'); g.rect(0, 81, 255, 81, 'k')
    for x in range(8, 256, 32): g.rect(x, 90, x + 23, 100, 'k'); g.rect(x + 1, 91, x + 22, 99, 'b')
    g.rect(0, 104, 255, 175, 'w')
    for y in range(104, 176, 16):
        for x in range(0, 256, 32):
            xx = x + (16 if (y // 16) % 2 else 0)
            g.rect(xx, y, xx + 15, y + 15, 'k')
    return g, ['k', 'w', 's', 'N'], {'N': 0x02}, (0, 0x0F, 0x0F)


def police_car(g, x, y, flip=False):
    """auto de policia de frente-costado; (x,y) = esquina inferior izquierda"""
    g.rect(x, y - 12, x + 46, y - 3, 'n'); g.rect(x + 9, y - 21, x + 35, y - 12, 'n')
    g.rect(x + 12, y - 19, x + 21, y - 13, 'k'); g.rect(x + 24, y - 19, x + 32, y - 13, 'k')
    g.rect(x + 2, y - 8, x + 44, y - 8, 'e')
    g.rect(x + 14, y - 25, x + 19, y - 22, 'r'); g.rect(x + 25, y - 25, x + 30, y - 22, 'e')   # sirena
    g.disc(x + 10, y - 1, 4, 'k'); g.disc(x + 36, y - 1, 4, 'k')
    g.disc(x + 10, y - 1, 1.5, 'e'); g.disc(x + 36, y - 1, 1.5, 'e')
    g.rect(x + 44, y - 11, x + 46, y - 9, 'r' if flip else 'e')


def scene_window():
    g = G(c='k')
    g.rect(14, 4, 241, 100, 'n')                               # cielo nocturno
    for i, (x, w, h) in enumerate(((16, 30, 40), (50, 22, 55), (76, 34, 30), (114, 26, 62), (144, 40, 36), (188, 24, 50), (216, 26, 44))):
        g.rect(x, 70 - h, x + w, 70, 'k')
        for yy in range(74 - h, 66, 8):
            for xx in range(x + 4, x + w - 3, 7): g.rect(xx, yy, xx + 2, yy + 3, 'n')
    g.rect(14, 70, 241, 100, 'k')
    for x in range(20, 240, 28): g.rect(x, 84, x + 12, 85, 'n')
    police_car(g, 40, 97); police_car(g, 150, 99, True)
    g.rect(10, 0, 13, 104, 'e'); g.rect(242, 0, 245, 104, 'e'); g.rect(10, 0, 245, 3, 'e'); g.rect(10, 101, 245, 104, 'e')
    g.rect(126, 0, 129, 104, 'e'); g.rect(10, 50, 245, 52, 'e')   # marco de la ventana
    g.rect(0, 105, 255, 175, 'k')
    for x in range(0, 256, 16): g.rect(x, 105, x, 175, 'n')
    return g, ['k', 'n', 'r', 'e'], {'n': 0x01, 'r': 0x16, 'e': 0x11}, (2, 0x16, 0x06)


def bag(g, x, y):
    g.disc(x, y, 9, 'b'); g.rect(x - 4, y - 13, x + 4, y - 8, 'b'); g.rect(x - 5, y - 9, x + 5, y - 9, 'k')
    bigtext(g, '$', x - 2, y - 3, 's')


def scene_street():
    g = G(c='d')
    g.rect(0, 0, 255, 30, 'k')
    for i in range(30): g.set((i * 37) % 256, (i * 13) % 26, 'l')
    g.rect(20, 18, 236, 26, 'l'); g.rect(10, 26, 246, 30, 'w')     # fronton
    g.rect(30, 8, 226, 18, 'l'); g.rect(30, 8, 226, 8, 'w')
    for x in range(30, 230, 32):                                   # columnas
        g.rect(x, 31, x + 14, 92, 'l'); g.rect(x + 2, 31, x + 4, 92, 'w'); g.rect(x + 13, 31, x + 14, 92, 'd')
    g.rect(108, 50, 148, 92, 'k')                                  # puerta
    bigtext(g, 'BANCO', 113, 19, 'k')
    for i, y in enumerate((93, 98, 103)):                          # escalones
        g.rect(10 - i * 6, y, 246 + i * 6, y + 4, 'w' if i % 2 == 0 else 'l')
    g.rect(0, 108, 255, 175, 'k')
    for x in range(0, 256, 32): g.rect(x + 4, 140, x + 20, 141, 'l')
    bag(g, 14, 120); bag(g, 242, 124); bag(g, 128, 116)
    for x in (6, 250):                                             # luces de patrullero acercandose
        g.disc(x, 60, 7, 'r'); g.disc(x, 60, 3, 'w')
    for y in range(176):
        for x in range(256):
            if g.p[y][x] == 'd': g.p[y][x] = 'k' if (x + y) % 2 else 'l'
    return g, ['k', 'l', 'w', 'r'], {'l': 0x10, 'w': 0x30, 'r': 0x16}, (3, 0x16, 0x06)


def scene_ending():
    """final: los dos se van de la mano hacia el atardecer (de espaldas)"""
    g = G(c='P')
    bands = [(0, 'V'), (26, 'M'), (48, 'P'), (70, 'O'), (92, 'Y')]
    for i, (y0, c) in enumerate(bands):
        y1 = bands[i + 1][0] if i + 1 < len(bands) else 104
        g.rect(0, y0, 255, y1 - 1, c)
        if i + 1 < len(bands):          # tramado entre bandas
            c2 = bands[i + 1][1]
            for y in range(y1 - 4, y1):
                for x in range(0, 256):
                    if (x + y) % 2 == 0 and y >= y1 - 2: g.set(x, y, c2)
                    elif (x + y) % 4 == 0: g.set(x, y, c2)
    g.disc(128, 104, 34, 'O'); g.disc(128, 104, 29, 'Y')            # sol
    for y in range(80, 104, 5): g.rect(94, y, 162, y, 'O')
    # ciudad que queda atras (izquierda) y palmeras
    for x, w, h in ((0, 14, 26), (14, 10, 36), (24, 16, 20), (40, 8, 30), (226, 12, 22), (238, 18, 34)):
        g.rect(x, 104 - h, x + w, 103, 'k')
    for px_ in (58, 202):
        g.line(px_, 104, px_ + 3, 64, 'k', 2)
        for dx, dy in ((-12, 4), (-8, -2), (10, -2), (13, 5), (0, -6)):
            g.line(px_ + 3, 64, px_ + 3 + dx, 64 + dy, 'k', 2)
    # ruta hacia el horizonte
    g.rect(0, 104, 255, 175, 'k')
    for y in range(104, 176):
        t = (y - 104) / 72
        hw = 6 + t * 120
        g.rect(128 - hw, y, 128 + hw, y, 'D')
        if int(y * (1 + t)) % 14 < 7: g.rect(127, y, 128 + int(t * 2), y, 'Y')
    for y in range(104, 176):
        t = (y - 104) / 72; hw = 6 + t * 120
        g.set(128 - hw, y, 'O'); g.set(128 + hw, y, 'O')
    # siluetas de espaldas tomadas de la mano
    def back(cx, y, girl):
        g.rect(cx - 7, y + 12, cx + 7, y + 34, 'k')          # torso
        g.disc(cx, y + 5, 8, 'k')                            # cabeza
        g.rect(cx - 6, y + 34, cx - 2, y + 50, 'k'); g.rect(cx + 2, y + 34, cx + 6, y + 50, 'k')   # piernas
        g.rect(cx - 7, y + 49, cx - 1, y + 52, 'k'); g.rect(cx + 1, y + 49, cx + 7, y + 52, 'k')
        if girl:
            g.disc(cx, y - 3, 4, 'k'); g.line(cx + 2, y - 2, cx + 9, y + 14, 'k', 3)   # cola de caballo
        else:
            g.disc(cx, y + 3, 9, 'k')                       # pelo corto, redondeado
    Y = 84
    back(112, Y, False); back(146, Y, True)
    g.line(119, Y + 16, 129, Y + 26, 'k', 3); g.line(139, Y + 16, 129, Y + 26, 'k', 3)   # brazos de la mano
    g.line(105, Y + 16, 102, Y + 32, 'k', 3); g.line(153, Y + 16, 157, Y + 32, 'k', 3)
    SUBS = [['k', 'V', 'M', 'P'], ['k', 'O', 'Y', 'P'], ['k', 'c', 'w', 'D'], ['k', 'D', 'O', 'Y']]
    return g, SUBS, {'V': 0x02, 'M': 0x04, 'P': 0x15, 'O': 0x27, 'Y': 0x38, 'D': 0x00}, (6, 0x38, 0x37)


SCENES = [scene_bank, scene_window, scene_street, scene_ending]
JX, LX = 26, 136          # posicion x de cada busto


def compose(scene, variant, bj, bl):
    g, pal, cols, flash = scene()
    if not isinstance(pal[0], list):
        if variant in (0, 1): g.blit(bj, JX, 176 - len(bj))
        if variant in (0, 2): g.blit(bl, LX, 176 - len(bl))
    full = [['k'] * 256 for _ in range(240)]
    for y in range(176):
        full[y] = g.p[y][:]
    # caja de dialogo celeste (paleta 2)
    for x in range(8, 248):
        full[180][x] = 'c'; full[181][x] = 'c'; full[230][x] = 'c'; full[231][x] = 'c'
    for y in range(180, 232):
        full[y][8] = full[y][9] = 'c'; full[y][246] = full[y][247] = 'c'
    return full, pal, cols, flash


def build_scene(si, font, used):
    bj, bl = bust(0), bust(1)
    vars_ = [compose(SCENES[si], v, bj, bl) for v in range(3)]
    pal = vars_[0][1]; cols = dict(BASE); cols.update(vars_[0][2]); flash = vars_[0][3]
    SUB = pal if isinstance(pal[0], list) else [pal, ['k', 's', 'b', 'w'], ['k', 'c', 'w', 's'], ['k', 'p', 'w', 's']]
    RGB = {k: np.array(PAL[v]) for k, v in cols.items()}
    results = []
    for full, _, _, _ in vars_:
        attr = [[0] * 16 for _ in range(15)]
        pix = [[0] * 256 for _ in range(240)]
        for by in range(15):
            for bx in range(16):
                cand = [2] if by >= 11 else range(4)
                best = None
                for pi in cand:
                    s = SUB[pi]; err = 0; idx = []
                    for y in range(16):
                        for x in range(16):
                            c = full[by * 16 + y][bx * 16 + x]
                            if c in s: idx.append(s.index(c)); continue
                            dd = [((RGB[c] - RGB[t]) ** 2).sum() for t in s]
                            i = int(np.argmin(dd)); err += dd[i]; idx.append(i)
                    if best is None or err < best[0]: best = (err, pi, idx)
                attr[by][bx] = best[1]
                for i, v in enumerate(best[2]): pix[by * 16 + i // 16][bx * 16 + i % 16] = v
        results.append((pix, attr))
    return results, SUB, cols, flash


def tile_of(pix, tx, ty):
    return tuple(''.join(str(pix[ty * 8 + y][tx * 8 + x]) if pix[ty * 8 + y][tx * 8 + x] else '.' for x in range(8)) for y in range(8))


def make_story(font, lines_text):
    """devuelve por escena: (top_tiles[256], bot_tiles[256], nts[3] (960+64), pal16, flash, split_row)"""
    used = sorted(set(''.join(lines_text)) | {' '})
    fontidx = {ch: ord(ch) - 32 for ch in used}
    reserved = set(fontidx.values())
    blank = tuple(['........'] * 8)
    out = []
    for si in range(len(SCENES)):
        res, SUB, cols, flash = build_scene(si, font, used)
        rows = [[[tile_of(pix, tx, ty) for tx in range(32)] for ty in range(30)] for pix, _ in res]
        best = None
        for R in range(5, 21):
            common = set(t for v in rows for t in v[R - 1]) - {blank}
            top = set(t for v in rows for r in v[:R - 1] for t in r) - common - {blank}
            bot = set(t for v in rows for r in v[R:] for t in r) - common - {blank}
            okk = 1 + len(common) + len(top) <= 256 and len(reserved) + len(common) + len(bot) <= 255
            sc = max(1 + len(common) + len(top), len(reserved) + len(common) + len(bot))
            if okk and (best is None or sc < best[0]): best = (sc, R, common, top, bot)
        assert best, ('escena', si, 'no entra')
        _, R, common, top, bot = best
        common = sorted(common); top = sorted(top); bot = sorted(bot)
        free_both = [i for i in range(1, 256) if i not in reserved]
        cmap = {blank: 0}
        for i, t in enumerate(common): cmap[t] = free_both[i]
        cused = set(cmap.values())
        tpool = [i for i in range(1, 256) if i not in cused]
        bpool = [i for i in free_both if i not in cused]
        tmap = dict(cmap); bmap = dict(cmap)
        for i, t in enumerate(top): tmap[t] = tpool[i]
        for i, t in enumerate(bot): bmap[t] = bpool[i]
        TS = [blank] * 256; BS = [blank] * 256
        for t, i in tmap.items(): TS[i] = t
        for t, i in bmap.items(): BS[i] = t
        for ch, i in fontidx.items():
            if ch == ' ': continue
            BS[i] = tuple(['.' + r.replace('#', '2').replace(' ', '.') + '..' for r in font[ch]] + ['........'])
        nts = []
        for vi, (pix, attr) in enumerate(res):
            nt = []
            for r in range(30):
                m = tmap if r < R else bmap
                nt += [m[t] for t in rows[vi][r]]
            at = []
            for ay in range(8):
                for ax in range(8):
                    v = 0
                    for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                        by, bx = ay * 2 + dy, ax * 2 + dx
                        v |= (attr[by][bx] if by < 15 else 2) << (q * 2)
                    at.append(v)
            nts.append(nt + at)
        pal = []
        for s in SUB: pal += [cols[c] for c in s]
        out.append((TS, BS, nts, pal, flash, R, len(top) + len(common), len(bot) + len(common)))
        print('escena %d: corte fila %d, tiles arriba %d abajo %d' % (si, R, out[-1][6], out[-1][7] + len(reserved)))
    return out


if __name__ == '__main__':
    bj, bl = bust(0), bust(1)
    for si in range(4):
        for v in range(3):
            full, pal, cols_, fl = compose(SCENES[si], v, bj, bl)
            cols = dict(BASE); cols.update(cols_)
            im = Image.new('RGB', (256, 240))
            for y in range(240):
                for x in range(256): im.putpixel((x, y), tuple(PAL[cols[full[y][x]]]))
            im.resize((512, 480), Image.NEAREST).save('story_raw_%d_%d.png' % (si, v))
