exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
run(20)
x0 = nes.ram[0xD0]
run(3, 0x01); run(3, 0); run(1, 0x01)
print('run_f', nes.ram[0x5B8])
shots = []
for i in range(30):
    nes.run_frame(0x01)
    if i in (10, 13): shots.append(nes.render())
print('run_f', nes.ram[0x5B8], 'vx', nes.ram[0xD8], 'dx', nes.ram[0xD0] - x0)
nes.run_frame(0x41)
for i in range(12):
    nes.run_frame(0x01)
    if i == 5: shots.append(nes.render())
print('pst', nes.ram[0xDA], 'pframe', nes.ram[0xDC], 'run_f', nes.ram[0x5B8])
run(30, 0x01); print('after', nes.ram[0xDA], nes.ram[0x5B8])
im = Image.new('RGB', (768, 240))
for i, s in enumerate(shots): im.paste(s, (i * 256, 0))
im.save('t41.png')
