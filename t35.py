exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
caps = []
def px(): return nes.ram[0xD0] + 256 * nes.ram[0xD1]
for vi, (tx, ty) in enumerate(((288, 200), (800, 200))):
    for i in range(900):
        nes.ram[0xDD] = 16
        b = 0
        if px() < tx - 2: b |= 0x01
        elif px() > tx + 2: b |= 0x02
        if nes.ram[0xD3] < ty - 1: b |= 0x04
        elif nes.ram[0xD3] > ty + 1: b |= 0x08
        nes.run_frame(b)
        if not b: break
    run(2, 0xC0); run(10)
    print('pveh', nes.ram[0xE0], 'px', px())
    for i in range(12):
        nes.run_frame(0x40 if i % 6 == 0 else 0)
        if i in (3, 4): caps.append(nes.render())
    run(2, 0xC0); run(20)   # bajar
im = Image.new('RGB', (1024, 240))
for i, s in enumerate(caps): im.paste(s, (i * 256, 0))
im.save('t35.png')
