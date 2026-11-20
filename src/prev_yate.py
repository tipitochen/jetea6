import agua_gen as G
from sprite3 import nes
from PIL import Image
tl, mp, attr, img = G.sea_bg()
yt, rows, yattr = G.yacht_bg(img, mp, tl, attr)
nt = [list(r) for r in mp]
for i, r in enumerate(rows): nt[G.YR0 + i - 4] = r
PP = [None, G.SEA_PAL[0:4], G.SEA_PAL[4:8], G.SEA_PAL[8:12]]
bg = Image.new('RGB', (256, 208))
for ty, r in enumerate(nt):
    for tx, t in enumerate(r):
        sy = ty + 4
        q = ((sy % 4) // 2) * 2 + (tx % 4) // 2
        p = (yattr[(sy // 4) * 8 + tx // 4] >> (q * 2)) & 3
        tile = tl[t - 0x80] if t >= 0x80 else yt[t - 0x48]
        for y, row in enumerate(tile):
            for x, ch in enumerate(row):
                c = 0x0F if ch == '.' else PP[p][int(ch)]
                bg.putpixel((tx * 8 + x, ty * 8 + y), tuple(nes(c)))
bg.resize((512, 416), Image.NEAREST).save('prev_yate.png')
