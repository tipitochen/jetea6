from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(330); run(2, 0x01); run(4); run(2, 0x10); run(60); run(2, 0x10); run(10)
print('state', R('state'))
shots = []
for t in (30, 90, 140, 175, 220):
    while R('cut_t') < t and R('state') == 2: run(1)
    shots.append(nes.render())
run(80); print('state', R('state'))
run(2, 0x10); run(30); shots.append(nes.render())
for i in range(60): run(1, 0x01, 0x01)
shots.append(nes.render())
im = Image.new('RGB', (256 * 4, 480))
for i, s in enumerate(shots): im.paste(s, ((i % 4) * 256, (i // 4) * 240))
im.save('t28.png')
