from asm import Assembler
from emu import NES
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(40); run(2,0x10); run(20); run(2,0x10); run(20); run(2,0x10); run(20); run(2,0x10); run(10)
# forzar un corazon delante del jugador
nes.ram[S['w_t']] = 5; nes.ram[S['w_xlo']] = 112; nes.ram[S['w_xhi']] = 0; nes.ram[S['w_y']] = 208; nes.ram[S['w_paint']] = 0
nes.ram[S['w_t']+1] = 3; nes.ram[S['w_xlo']+1] = 160; nes.ram[S['w_xhi']+1] = 0; nes.ram[S['w_y']+1] = 190; nes.ram[S['w_paint']+1] = 0
run(5)
print([nes.ram[S['w_paint']+i] for i in range(4)], R('cam_lo'), R('tc_lo'))
nes.render().resize((512,480)).save('t14.png')
nes.ram[0x50D]=6
for i in range(60): run(1, 0x01 if i<20 else 0x04)
print('hp', nes.ram[0x50D], [nes.ram[S['w_t']+i] for i in range(4)])
nes.render().resize((512,480)).save('t14b.png')
