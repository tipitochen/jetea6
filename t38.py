exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
for i in range(900):
    nes.ram[0xDD] = 16
    fr = nes.frame; nes.run_frame(bot(0, fr))
nes.ram[0xEB]=1; nes.ram[0xEC]=12; nes.ram[0x5A2]=8; nes.ram[0x5A6]=3; nes.ram[0x5A4]=4
print('weap', nes.ram[0xEB], 'ammo', nes.ram[0xEC], 'inv', list(nes.ram[0x5A0:0x5A8]))
shots = []
run(1, 0x20); run(14); shots.append(nes.render()); print('state', R('state'), 'cur', nes.ram[0x5B2])
run(1, 0x01); run(10); shots.append(nes.render()); print('cur', nes.ram[0x5B2])
run(1, 0x80); run(20); shots.append(nes.render()); print('state', R('state'), 'weap', nes.ram[0xEB], 'ammo', nes.ram[0xEC], 'inv', list(nes.ram[0x5A0:0x5A8]))
run(1, 0x10); run(14); shots.append(nes.render()); print('state', R('state'))
run(1, 0x10); run(20); print('state', R('state'))
im = Image.new('RGB', (1024, 240))
for i, s in enumerate(shots): im.paste(s, (i * 256, 0))
im.save('t38.png')
