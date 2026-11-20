exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
run(30)
nes.ram[0xEB]=1; nes.ram[0xEC]=12; nes.ram[0x5A2]=8; nes.ram[0x5A6]=3; nes.ram[0x5A4]=4
run(1, 0x20); run(30)
print('state', R('state'))
shots = [nes.render()]
for k in range(5):
    run(9); shots.append(nes.render())
run(1, 0x04); run(12); shots.append(nes.render())
run(1, 0x04); run(20); shots.append(nes.render())
run(1, 0x80); run(40)
print('state', R('state'), 'weap', nes.ram[0xEB], 'ammo', nes.ram[0xEC])
shots.append(nes.render())
im = Image.new('RGB', (256 * 3, 240 * 3))
for i, s in enumerate(shots[:9]): im.paste(s, ((i % 3) * 256, (i // 3) * 240))
im.save('t44.png')
