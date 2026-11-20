from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
def run(n, b=0):
    for i in range(n): nes.run_frame(b)
run(330)
for b in (0x08, 0x08, 0x04, 0x04, 0x02, 0x01, 0x02, 0x01, 0x40, 0x80):
    run(1, b); run(3)
for i in range(1): run(1, 0x01); run(4)
run(1, 0x10); run(30); run(1, 0x01); run(5); run(1, 0x10); run(30); run(1, 0x10); run(10)
print('state', R('state'), 'level', R('level'), 'char', nes.ram[0x51E])
run(10, 0x80)   # saltear escena
caps = []
f = 0
while R('state') == 13 and f < 20000:
    run(1); f += 1
    if f % 1500 == 0: caps.append(nes.render())
print('murio en', f, 'state', R('state'))
run(30); caps.append(nes.render())
run(1, 0x10); run(80)
print('despues de continuar: state', R('state'), 'level', R('level'))
run(1, 0x10); run(60); caps.append(nes.render())
print('state', R('state'), 'intro', nes.ram[0x61C])
im = Image.new('RGB', (1024, 240 * ((len(caps) + 3) // 4)))
for i, c in enumerate(caps): im.paste(c, ((i % 4) * 256, (i // 4) * 240))
im.save('t60h.png')
