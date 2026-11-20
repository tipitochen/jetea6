from enemy4 import *
from sprite3 import quantize, CLS_RGB
from emu import PAL as NP
from PIL import Image
rows = []
for kind, u in (('cop', 0x12), ('soldier', 0x1A)):
    cls = dict(CLS_RGB); cls['u'] = NP[u]
    pal = [0x0F, 0x27, u]
    ims = []
    for c in EFR4:
        g = make_enemy2(frame(0, c), kind)
        e = quantize(g, [(2, pal)], cls)
        img = Image.new('RGB', (48, 48), (84, 154, 250))
        for dx, dy, pix, ap in e:
            for y in range(8):
                for x in range(8):
                    v = pix[y][x]
                    if v: img.putpixel((20 + dx + x, 46 + dy + y), NP[pal[v - 1]])
        ims.append(img.resize((192, 192), 0))
        print(kind, c, len(e))
    rows.append(ims)
W = Image.new('RGB', (192 * 8, 192 * 2))
for r, ims in enumerate(rows):
    for i, im in enumerate(ims): W.paste(im, (i * 192, r * 192))
W.save('prev5.png')
