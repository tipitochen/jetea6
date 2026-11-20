import sys
exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
run(20)
fr = []
for i in range(64):
    b = 0x01 if i < 56 else 0
    nes.run_frame(b)
    if i % 2 == 0:
        sx = nes.ram[0xD0] + 256 * nes.ram[0xD1] - (R('cam_lo') + 256 * R('cam_hi'))
        fr.append(nes.render().crop((sx - 24, 150, sx + 24, 215)))
im = Image.new('RGB', (len(fr) * 48, 65))
for i, f in enumerate(fr): im.paste(f, (i * 48, 0))
im.resize((im.width * 2, 130), Image.NEAREST).save('walk_strip.png')
