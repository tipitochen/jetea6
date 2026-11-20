exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
caps = []
prev = R('cam_lo')
for i in range(1500):
    for k in range(1):
        nes.ram[0x50D] = 16
        if R('cur') == 0: nes.ram[0xDD] = 16
    fr = nes.frame
    nes.run_frame(bot(0, fr))
    c = R('cam_lo')
    if (prev > 200 and c < 60) or (len(caps) and len(caps) % 6 and len(caps) < 36):
        caps.append(nes.render())
    prev = c
    if len(caps) >= 36: break
print(len(caps), nes.frame)
im = Image.new('RGB', (256 * 6, 240 * 6))
for i, s in enumerate(caps): im.paste(s, ((i % 6) * 256, (i // 6) * 240))
im.save('t30.png')
