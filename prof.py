from asm import Assembler
from emu import NES
import bisect, collections
a = Assembler(0x10000); a.assemble('game2.asm'); S = a.syms
labs = sorted((v, k) for k, v in S.items() if 0xC000 <= v < 0x10000 and '@' not in k)
addrs = [v for v, k in labs]
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
for f in range(30): nes.run_frame(0)
for b in [0x10,0,0,0x10,0,0,0x10]+[0]*3: nes.run_frame(b)
for f in range(200): nes.run_frame(0x10 if f%20==0 else 0)
print('state', R('state'))
prof = collections.Counter()
orig = nes.step
def step():
    pc = nes.pc; c0 = nes.cyc
    orig()
    i = bisect.bisect_right(addrs, pc) - 1
    prof[labs[i][1] if i >= 0 else '?'] += nes.cyc - c0
nes.step = step
for f in range(400):
    nes.ram[S['inv']] = 5
    b = 0x01 | (0x40 if f % 12 < 6 else 0) | (0x80 if f % 40 < 10 else 0)
    nes.run_frame(b)
tot = sum(v for k, v in prof.items() if k != 'wait_nmi')
for k, v in prof.most_common(25): print('%-20s %7d  %5.0f/frame' % (k, v, v/400))
