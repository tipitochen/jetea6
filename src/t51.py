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
caps = []
for k in range(4):
    run(60); caps.append(nes.render().crop((0, 160, 256, 220)))
    for i in range(3): run(1, 0x01); run(8)
print(R('start_lvl'), R('lsel_dirty'), R('str_pending'))
im = Image.new('RGB', (256, 60 * 4))
for i, c in enumerate(caps): im.paste(c, (0, i * 60))
im.resize((768, 720), Image.NEAREST).save('c66.png')
