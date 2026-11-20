from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
def run(n, b=0):
    for i in range(n): nes.run_frame(b)
run(330); run(2, 0x10); run(20); run(30)
nes.sprite_limit = True
a1 = nes.render()
nes.sprite_limit = True
run(2, 0x10); run(20); run(2, 0x10); run(20); run(2, 0x10); run(20); run(2, 0x10); run(30)
run(40, 0x01)
a2 = nes.render()
im = Image.new('RGB', (512, 240)); im.paste(a1, (0, 0)); im.paste(a2, (256, 0))
im.resize((1024, 480), Image.NEAREST).save('t40.png')
print(R('state'))
