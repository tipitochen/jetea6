exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
run(30)
nes.ram[0xEB] = 6; nes.ram[0xEC] = 3
run(1, 0x40); run(6)
im = nes.render()
print('ammo', nes.ram[0xEC], 'pr', [nes.ram[S['pr_t']+i] for i in range(8)])
run(1,0x40); run(30); run(1,0x40); run(30); run(1,0x40); run(10)
print('weap', nes.ram[0xEB], 'ammo', nes.ram[0xEC], 'state', R('state'))
im.resize((512,480)).save('t39.png')
