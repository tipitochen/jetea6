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
for i in range(10): run(1, 0x01); run(3)
run(1, 0x10); run(30); run(1, 0x10); run(40)
caps = [nes.render()]
run(1, 0x10); run(60); caps.append(nes.render())
print('state', R('state'))
im = Image.new('RGB', (512, 240))
for i, c in enumerate(caps): im.paste(c, (i * 256, 0))
im.save('t59.png')
