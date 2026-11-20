from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
shots = []
for f in range(420):
    nes.run_frame(0)
    if f in (60, 85, 110, 128, 132, 200, 330, 400): shots.append(nes.render())
print('state', R('state'))
im = Image.new('RGB', (1024, 480))
for i, s in enumerate(shots): im.paste(s, ((i % 4) * 256, (i // 4) * 240))
im.save('t36.png')
