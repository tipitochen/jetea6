exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
caps = []
for i in range(700):
    nes.ram[0xDD] = 16
    nes.run_frame(0x01 if (i // 60) % 3 != 2 else 0, 0x01 if two and (i // 60) % 3 != 2 else 0)
    n = sum(1 for k in range(4) if nes.ram[S['en_t'] + k])
    if i > 200 and n >= 3 and len(caps) < 4: caps.append(nes.render())
    if len(caps) >= 4: break
print(len(caps))
im = Image.new('RGB', (512, 480))
for i, s in enumerate(caps): im.paste(s, ((i % 2) * 256, (i // 2) * 240))
im.save('t47.png')
