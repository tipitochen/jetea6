import sys, time
from asm import Assembler
from emu import NES
a = Assembler(); a.assemble('game.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
def run(n, btn=0, f=None):
    for i in range(n):
        b = f(nes.frame) if f else btn
        nes.run_frame(b)
t=time.time()
run(60); nes.render().save('s_title.png')
run(3, 0x10); run(30); nes.render().save('s_select.png')
run(3, 0x01); run(20); nes.render().save('s_select2.png')
run(3, 0x10); run(30); nes.render().save('s_intro.png')
run(170); nes.render().save('s_level.png')
print('state',nes.ram[S['state']],'irqs',nes.irq_count,'t',time.time()-t)
def play(fr):
    b = 0x01 | (0x40 if fr%20<10 else 0)
    if fr % 50 < 3: b |= 0x80
    return b
run(240, f=play); nes.render().save('s_play1.png')
print('px',nes.ram[S['px_hi']]*256+nes.ram[S['px_lo']],'py',nes.ram[S['py']],'cam',nes.ram[S['cam_hi']]*256+nes.ram[S['cam_lo']],'hp',nes.ram[S['hp']],'lives',nes.ram[S['lives']],'moto',nes.ram[S['moto']], 'dead', nes.ram[S['dead_timer']])
run(300, f=play); nes.render().save('s_play2.png')
print('px',nes.ram[S['px_hi']]*256+nes.ram[S['px_lo']],'py',nes.ram[S['py']],'cam',nes.ram[S['cam_hi']]*256+nes.ram[S['cam_lo']],'hp',nes.ram[S['hp']],'lives',nes.ram[S['lives']],'moto',nes.ram[S['moto']],'score',list(nes.ram[0x50:0x56]))
print('time',time.time()-t)
