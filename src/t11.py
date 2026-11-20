import sys
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
two = '--2p' in sys.argv
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
shots = []
def shot(): shots.append(nes.render())
run(40)
if two: run(2, 0x01); run(4)
run(2, 0x10); run(20); shot()
if not two:
    run(2, 0x10); run(20); shot()
run(120); shot()
run(2, 0x10); run(20); shot()   # salta cutscene
run(2, 0x10); run(10)            # salta intro
print('state', nes.ram[S['state']], 'p_on', nes.ram[0x51F], nes.ram[0x53F], 'two_p', nes.ram[S['two_p']])
for k in range(3):
    run(40, 0x01 | (0x40 if k % 2 else 0), 0x01 if two else 0); shot()
print('busy', nes.idle_cyc if hasattr(nes,'idle_cyc') else None)
W = 256 * 3
img = Image.new('RGB', (W, 240 * ((len(shots) + 2) // 3)))
for i, s in enumerate(shots): img.paste(s, ((i % 3) * 256, (i // 3) * 240))
img.save('t11%s.png' % ('_2p' if two else ''))
