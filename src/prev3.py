from sprite3 import *
from PIL import Image
CH = {0: dict(p0=[0x0F, 0x27, 0x17], p1=[0x0F, 0x30, 0x2C], c=(20, 180, 225)),
      1: dict(p0=[0x0F, 0x27, 0x17], p1=[0x0F, 0x30, 0x25], c=(235, 55, 125))}
def render(entries, pals, scale=4):
    img = Image.new('RGB', (48 * scale, 48 * scale), (84, 154, 250))
    for dx, dy, pix, ap in entries:
        cols = pals[ap]
        for y in range(8):
            for x in range(8):
                v = pix[y][x]
                if v:
                    c = NESPAL[cols[v - 1]]
                    X = (24 + dx + x) * scale; Y = (44 + dy + y) * scale
                    img.paste(c, (X, Y, X + scale, Y + scale))
    return img
rows = []
for row in (0, 1):
    cr = dict(CLS_RGB); cr['c'] = CH[row]['c']
    pals = [(0, CH[row]['p0']), (1, CH[row]['p1']), (3, [0x0F, 0x27, 0x30])]
    ims = []
    for col in range(16):
        e = quantize(frame(row, col), pals, cr)
        ims.append(render(e, {0: CH[row]['p0'], 1: CH[row]['p1'], 3: [0x0F, 0x27, 0x30]}))
    rows.append(ims)
for kind, u in (('cop', 0x12), ('soldier', 0x1A)):
    cr = dict(CLS_RGB); cr['u'] = NESPAL[u]
    pal = [0x0F, 0x27, u]
    ims = []
    for col in (0, 1, 2, 3, 4, 7, 9, 14, 15):
        g = make_enemy(frame(0, col), kind)
        e = quantize(g, [(2, pal)], cr)
        ims.append(render(e, {2: pal}))
    rows.append(ims)
W = Image.new('RGB', (16 * 48 * 4 // 2, 4 * 48 * 4 // 2))
for r, ims in enumerate(rows):
    for i, im in enumerate(ims):
        W.paste(im.resize((96, 96)), (i * 96, r * 96))
W.save('prev3.png')
