import sys, time
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x10000); a.assemble('game2.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
shots = []
def run(n, f=lambda fr: 0):
    for i in range(n): nes.run_frame(f(nes.frame))
def shot(): shots.append(nes.render())
run(120); shot()
run(2, lambda f: 0x10); run(30); shot()
run(2, lambda f: 0x01); run(20); shot()
run(2, lambda f: 0x10)
run(60); shot(); run(60); shot(); run(60); shot(); run(60); shot()
run(40); print('state', R('state')); shot()
run(160); print('state', R('state'), 'irq', nes.irq_count); shot()
def play(fr):
    b = 0x01 | (0x40 if fr % 16 < 8 else 0)
    if fr % 50 < 14: b |= 0x80
    return b
run(100, play); shot()
run(150, play); shot()
print('px', R('px_lo')+256*R('px_hi'), 'py', R('py'), 'cam', R('cam_lo')+256*R('cam_hi'), 'pveh', R('pveh'), 'hp', R('hp'), 'lives', R('lives'), 'dead', R('dead_timer'))
W = Image.new('RGB', (256*4, 240*((len(shots)+3)//4)))
for i, im in enumerate(shots): W.paste(im, ((i%4)*256, (i//4)*240))
W.save('t2.png')
