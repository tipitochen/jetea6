import sys
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
two = '--2p' in sys.argv
luci = '--luci' in sys.argv
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(330)
for b in (0x08, 0x08, 0x04, 0x04, 0x02, 0x01, 0x02, 0x01, 0x40, 0x80):
    run(1, b); run(3)
run(1, 0x01); run(4)
if two: run(1, 0x08); run(4)
run(1, 0x10); run(30)
if not two:
    if luci: run(1, 0x04); run(5)
    run(1, 0x10); run(30)
run(1, 0x10); run(4)
print('state', R('state'), 'intro', nes.ram[0x61C])
caps = []
for f in range(900):
    nes.run_frame(0)
    if f % 40 == 0 and len(caps) < 20: caps.append(nes.render())
    if nes.ram[0x61C] == 0: print('termino en', f); caps.append(nes.render()); break
run(60); caps.append(nes.render())
print('state', R('state'), 'wi', nes.ram[0x608], 'r2', R('chr_r2'))
im = Image.new('RGB', (256 * 4, 240 * ((len(caps) + 3) // 4)))
for i, c in enumerate(caps): im.paste(c, ((i % 4) * 256, (i // 4) * 240))
im.save('t56%s.png' % ('_2p' if two else '_l' if luci else ''))
