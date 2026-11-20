from bg4 import *
from PIL import Image
from emu import PAL as NP
PALS = {'A': ([0x21], [0x07, 0x2A, 0x30], [0x0F, 0x35, 0x30], [0x0F, 0x37, 0x27]),
        'B': ([0x22], [0x0F, 0x24, 0x2C], [0x0F, 0x17, 0x27], [0x0F, 0x00, 0x10]),
        'C': ([0x26], [0x0F, 0x28, 0x30], [0x0F, 0x16, 0x21], [0x0F, 0x00, 0x10]),
        'D': ([0x11], [0x0F, 0x16, 0x30], [0x0F, 0x18, 0x28], [0x0F, 0x00, 0x2D])}
for th in 'ABCD':
    bg, p1, p2, p3 = PALS[th]
    img = Image.new('RGB', (256, 240), NP[bg[0]])
    px = img.load()
    fb = farband(th, 3)
    for y in range(32):
        for x in range(256):
            v = fb[y][x % 128]
            if v: px[x, 32 + y] = NP[p1[v - 1]]
    blocks = THEMES[th]()
    R = random.Random(1)
    for b in range(16):
        c, pals = blocks[R.randrange(len(blocks))]
        for y in range(80):
            for x in range(16):
                v = c.p[y][x]
                if v:
                    pal = p1 if pals[y // 16] == 1 else p2
                    px[b * 16 + x, 64 + y] = NP[pal[v - 1]]
    st = street(th)
    for y in range(96):
        for x in range(256):
            v = st.p[y][x % 32]
            if v and 144 + y < 240: px[x, 144 + y] = NP[p3[v - 1]]
    img.resize((512, 480), 0).save('bg_%s.png' % th)
W = Image.new('RGB', (1024, 960))
for i, th in enumerate('ABCD'):
    W.paste(Image.open('bg_%s.png' % th), ((i % 2) * 512, (i // 2) * 480))
W.save('prevbg.png')
