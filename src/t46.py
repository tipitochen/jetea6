exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
caps = []
run(60)
vt = [nes.ram[S['vo_t'] + i] for i in range(4)]
vx = [nes.ram[S['vo_xlo'] + i] + 256 * nes.ram[S['vo_xhi'] + i] for i in range(4)]
print('vo', vt, vx)
nes.ram[S['vo_t']] = 2; vt[0] = 2; run(2)
caps.append(nes.render())
for i in range(4):
    if vt[i] == 2:
        nes.ram[0xD0] = vx[i] & 255; nes.ram[0xD1] = vx[i] >> 8; nes.ram[0xD3] = nes.ram[S['vo_y'] + i]
        run(3); run(2, 0xC0); run(10)
        print('pveh', nes.ram[0xE0])
        for k in range(12):
            nes.run_frame(0x40 if k % 6 == 0 else 0)
            if k in (3, 9): caps.append(nes.render())
        break
im = Image.new('RGB', (256 * len(caps), 240))
for i, s in enumerate(caps): im.paste(s, (i * 256, 0))
im.save('t46.png')
