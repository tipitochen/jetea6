exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
def px(): return nes.ram[0xD0] + 256 * nes.ram[0xD1]
for i in range(900):
    nes.ram[0xDD] = 16
    b = 0
    if px() < 286: b |= 0x01
    elif px() > 290: b |= 0x02
    if nes.ram[0xD3] < 199: b |= 0x04
    elif nes.ram[0xD3] > 201: b |= 0x08
    nes.run_frame(b)
    if not b: break
run(2, 0xC0); run(10)
print('montado pveh', nes.ram[0xE0], 'weap', nes.ram[0xEB], 'ammo', nes.ram[0xEC])
for i in range(400):
    nes.ram[0xDD] = 16
    nes.run_frame(0x40 if i % 4 == 0 else 0)
print('tras disparar pveh', nes.ram[0xE0], 'weap', nes.ram[0xEB], 'ammo', nes.ram[0xEC])
nes.render().save('t55.png')
