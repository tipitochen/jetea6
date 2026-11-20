from asm import Assembler
from emu import NES
a = Assembler(0x20000); a.assemble('game3.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
def run(n, f=lambda fr: 0):
    for i in range(n): nes.run_frame(f(nes.frame))
run(60); run(2, lambda f: 0x10); run(20); run(2, lambda f: 0x10); run(10); run(2, lambda f: 0x10); run(10); run(2, lambda f: 0x10); run(10)
run(200, lambda f: 0x01)
while nes.pc != S['wait_nmi@w']: nes.step()
print('cam', R('cam_lo')+256*R('cam_hi'), 'inwave', R('in_wave'), 'alive', R('alive'), 'tospawn', R('to_spawn'))
for i in range(3):
    print('en', i, nes.ram[S['en_t']+i], nes.ram[S['en_xlo']+i]+256*nes.ram[S['en_xhi']+i], nes.ram[S['en_y']+i], 'st', nes.ram[S['en_st']+i], 'fr', nes.ram[S['en_fr']+i])
oam = nes.ram[0x200:0x300]
spr = [(oam[i], oam[i+1], oam[i+2], oam[i+3]) for i in range(0, 256, 4) if oam[i] < 240]
print(len(spr), spr[:40])
print('chr45', R('chr_r45'), 'regs', nes.regs)
for k in range(400):
    nes.run_frame(0x00)
    ex = nes.ram[S['en_xlo']]+256*nes.ram[S['en_xhi']] - (R('cam_lo')+256*R('cam_hi'))
    if 60 < ex < 200 and nes.ram[S['en_t']]:
        break
while nes.pc != S['wait_nmi@w']: nes.step()
print('ex screen', ex, 'k', k)
oam = nes.ram[0x200:0x300]
print([(oam[i], oam[i+1], oam[i+2], oam[i+3]) for i in range(0, 256, 4) if oam[i] < 240][16:40])
nes.run_frame(0)
nes.render().resize((512,480),0).save('t9.png')
