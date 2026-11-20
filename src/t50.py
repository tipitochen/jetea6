import sys
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
two = '--2p' in sys.argv
lv = int(sys.argv[1]) if len(sys.argv) > 1 else 1
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(330)
print('state', R('state'))
for b in (0x08, 0x08, 0x04, 0x04, 0x02, 0x01, 0x02, 0x01, 0x40, 0x80):
    run(1, b); run(3)
print('lsel', R('lsel_on'), R('start_lvl'))
for i in range(lv): run(1, 0x01); run(3)
run(40)
caps = [nes.render()]
print('start_lvl', R('start_lvl'))
if two: run(1, 0x08); run(4)
run(1, 0x10); run(30)
if not two: run(1, 0x10); run(30)
print('state', R('state'), 'level', R('level'))
run(1, 0x10); run(10)
print('state', R('state'), 'level', R('level'))
import random
rnd = random.Random(1)
for f in range(int(sys.argv[2]) if len(sys.argv) > 2 else 1500):
    b = 0x40 | rnd.choice([0, 0x08, 0x04, 0, 0x01, 0x02])
    b2 = 0x40 | rnd.choice([0, 0x08, 0x04]) if two else 0
    nes.run_frame(b, b2)
    if f % 300 == 150: caps.append(nes.render())
    if R('state') != 13 and f > 10: print('salio state', R('state'), 'f', f); caps.append(nes.render()); break
print('state', R('state'), 'boss', nes.ram[0x609], 'hp', nes.ram[0x500 + 13], 'lives', nes.ram[0x500 + 14], 'wi', nes.ram[0x608])
im = Image.new('RGB', (256 * 4, 240 * ((len(caps) + 3) // 4)))
for i, c in enumerate(caps): im.paste(c, ((i % 4) * 256, (i // 4) * 240))
im.save('t50.png')
print('h_t', nes.ram[0x606], 'pause', nes.ram[0x605], 'e_t', [nes.ram[0x620+i] for i in range(6)], 'e_x', [nes.ram[0x626+i] for i in range(6)], 'e_y', [nes.ram[0x632+i] for i in range(6)])
print('pc', hex(nes.pc)); import collections; c=collections.Counter()
for i in range(3000):
    nes.step(); c[nes.pc]+=1
print([(hex(k),v) for k,v in c.most_common(8)])
fp = nes.ram[0x0C] + 256 * nes.ram[0x0D]
print('fptr', hex(fp), 'fcount', nes.ram[S['fcount']], 'sx', nes.ram[S['sx_lo']], nes.ram[S['sx_lo']+1], 'sy', nes.ram[S['sy']], 'oam_i', nes.ram[S['oam_i']])
inv = {v: k for k, v in S.items() if 0x8000 <= v < 0xA000}
best = max((v for v in inv if v <= fp), default=None); print(inv.get(best), hex(best))
print([hex(nes.read(fp + i)) for i in range(12)] if hasattr(nes, 'read') else '')
