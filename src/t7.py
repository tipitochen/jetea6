import sys
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game3.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
shots = []
def run(n, f=lambda fr: 0):
    for i in range(n):
        nes.run_frame(f(nes.frame))
def shot(): shots.append(nes.render())
run(100); shot()
run(2, lambda f: 0x10); run(40); shot()
run(2, lambda f: 0x10); run(100); shot(); run(100); shot()
run(2, lambda f: 0x10); run(40); shot()
run(2, lambda f: 0x10); run(30); shot()
print('state', R('state'), 'px', R('px_lo')+256*R('px_hi'), 'py', R('py'), 'hp', R('hp'))
def play(fr):
    b = 0x01
    if fr % 30 < 2: b |= 0x40
    return b
run(160, play); shot()
print('state', R('state'), 'px', R('px_lo')+256*R('px_hi'), 'cam', R('cam_lo')+256*R('cam_hi'), 'wave', R('in_wave'), 'alive', R('alive'))
run(200, lambda f: 0x40 if f % 16 < 2 else 0); shot()
print('state', R('state'), 'hp', R('hp'), 'alive', R('alive'), 'en', [nes.ram[S['en_t']+i] for i in range(3)], [nes.ram[S['en_st']+i] for i in range(3)], [nes.ram[S['en_hp']+i] for i in range(3)])
W = Image.new('RGB', (256*4, 240*((len(shots)+3)//4)))
for i, im in enumerate(shots): W.paste(im, ((i%4)*256, (i//4)*240))
W.save('t7.png')
