from art4 import *
from sprite3 import frame, quantize, CLS_RGB
from emu import PAL as NP
from PIL import Image
def show(g, pals, cls, scale=3):
    e = quantize(g, pals, cls)
    pmap = dict(pals)
    img = Image.new('RGB', (72 * scale, 64 * scale), (84, 154, 250))
    for dx, dy, pix, ap in e:
        for y in range(8):
            for x in range(8):
                v = pix[y][x]
                if v:
                    X = (24 + dx + x) * scale; Y = (60 + dy + y) * scale
                    img.paste(NP[pmap[ap][v - 1]], (X, Y, X + scale, Y + scale))
    return img, len(e)
ims = []
jp = [(0, [0x0F, 0x27, 0x17]), (1, [0x0F, 0x30, 0x2C]), (3, [0x0F, 0x27, 0x30])]
cj = dict(CLS_RGB); cj['c'] = (20, 180, 225)
ims.append(show(car(frame(0, 0), 0), jp, cj))
ims.append(show(moto(frame(0, 7), 0), jp, cj))
ims.append(show(car(None, 0), jp, cj))
for i, f in enumerate(BOSSES):
    u, v = BOSS_COL[i]
    cls = dict(CLS_RGB); cls['u'] = NP[u]; cls['v'] = NP[v]; cls['o'] = NP[0x27]
    pals = [(2, [0x0F, u, v]), (3, [0x0F, 0x27, 0x30])]
    ims.append(show(f(0), pals, cls))
for k in range(4): ims.append(show(explosion(k), [(3, [0x0F, 0x27, 0x30])], CLS_RGB))
W = Image.new('RGB', (216 * 6, 192 * 3), (40, 40, 40))
for i, (im, n) in enumerate(ims):
    W.paste(im, ((i % 6) * 216, (i // 6) * 192))
    print(i, n, 'tiles')
W.save('prev4.png')
