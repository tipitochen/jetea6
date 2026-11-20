import sys
from sprite3 import frame, quantize_layered, CLS_RGB, nes
from walk5 import head_anchor
from walk7 import stomp_poses
from PIL import Image
P3 = [0x0F, 0x27, 0x30]
def render(entries, pals, W=48, H=48):
    pm = dict(pals)
    im = Image.new('RGB', (W, H), (60, 60, 90))
    for dx, dy, idx, ap in reversed(entries):
        cols = pm[ap]
        for y in range(8):
            for x in range(8):
                v = idx[y][x]
                if v: im.putpixel((W // 2 + dx + x, H - 4 + dy + y), tuple(nes(cols[v - 1])))
    return im
def src(g, W=48, H=48):
    C = {'k': (20, 20, 20), 's': (240, 150, 100), 'h': (140, 62, 35), 'w': (246, 246, 246), 'g': (128, 128, 135), 'c': (20, 180, 225)}
    im = Image.new('RGB', (W, H), (60, 60, 90)); ax = int(round(head_anchor(g)))
    for y, r in enumerate(g):
        for x, c in enumerate(r):
            if c != '.': im.putpixel((W // 2 - ax + x, H - 4 - len(g) + y), C.get(c, (255, 0, 255)))
    return im
if __name__ == '__main__':
    out = Image.new('RGB', (48 * 8, 96))
    for row, shirt in ((0, 0x2C), (1, 0x25)):
        cls = dict(CLS_RGB); cls['c'] = tuple(nes(shirt))
        cls.update(k=tuple(nes(0x0F)), s=tuple(nes(0x27)), h=tuple(nes(0x17)), w=tuple(nes(0x30)), g=tuple(nes(0x10)))
        pals = [(0, [0x0F, 0x27, 0x17]), (1, [0x0F, 0x30, shirt]), (3, P3)]
        fr = [frame(row, 0), frame(row, 5), frame(row, 9), stomp_poses(row)[1]]
        for i, g in enumerate(fr):
            q = quantize_layered(g, pals, cls, ax=int(round(head_anchor(g))), max_split=int(sys.argv[1]) if len(sys.argv) > 1 else 3)
            out.paste(src(g), ((row * 4 + i) * 48, 0)); out.paste(render(q, pals), ((row * 4 + i) * 48, 48))
    out.resize((out.width * 4, out.height * 4), Image.NEAREST).save('qview.png')
