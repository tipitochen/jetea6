from asm import Assembler
from emu import NES
from PIL import Image
import sys
a = Assembler(0x10000); a.assemble('game2.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
sel = int(sys.argv[1]) if len(sys.argv) > 1 else 0
lvl = int(sys.argv[2]) if len(sys.argv) > 2 else 0
for f in range(30): nes.run_frame(0)
seq = [0x10,0,0] + ([0x01,0] if sel else []) + [0x10,0,0,0x10] + [0]*5
for b in seq: nes.run_frame(b)
nes.ram[S['level']] = lvl
for f in range(160): nes.run_frame(0)
print('state', R('state'))
shots = []; maxbusy = 0
def px(): return R('px_lo') + 256*R('px_hi')
def vehicles():
    out = []
    for i in range(10):
        t = nes.ram[S['e_type']+i]
        if t in (3, 6): out.append((t, nes.ram[S['e_xlo']+i] + 256*nes.ram[S['e_xhi']+i]))
    return out
phase = 0; log = []
import bisect
labs = sorted((v, k) for k, v in S.items() if 0xC000 <= v < 0x10000)
addrs=[v for v,k in labs]
ow = nes.wr
def wr(ad, v):
    if ad == 0x2C and v == 0 and nes.ram[0x2C] != 0:
        i = bisect.bisect_right(addrs, nes.pc)-1
        print('WRITE pveh=0 at', hex(nes.pc), labs[i][1], 'frame', nes.frame)
    ow(ad, v)
nes.wr = wr
for f in range(1500):
    nes.ram[S['inv']] = max(nes.ram[S['inv']], 2) if '--god' in sys.argv else nes.ram[S['inv']]
    b = 0
    pv = R('pveh')
    vs = vehicles()
    here = px()
    if pv == 0:
        tgt = [x for t, x in vs if x + 4 > here - 40]
        b = 0x01 | (0x40 if f % 12 < 6 else 0)
        if tgt and 0 <= here + 8 - tgt[0] < 24 and R('onground'):
            b = 0xC0 if f % 4 == 0 else 0
    else:
        b = 0x01 | (0x40 if f % 10 < 5 else 0)
        lp = R('lvl_ptr') + 256*nes.ram[S['lvl_ptr']+1]
        def col(x):
            mc = x >> 4
            return nes.rd(lp + mc) & 15 if mc < 160 else 2
        here_h = col(here + 8)
        if any(col(here + 8 + d) == 0 or col(here + 8 + d) > here_h for d in (16, 28, 40)) and f % 30 < 15: b |= 0x80
        if pv == 1 and f > 600 and phase == 0:
            b = 0xC0 if f % 4 == 0 else 0; 
    if pv != (log[-1][1] if log else -1):
        log.append((f, pv, here)); print('frame', f, 'btn', hex(b), 'vhp', R('veh_hp'), 'dead', R('dead_timer'), 'py', R('py'), 'pveh', pv, 'px', here, 'cam', R('cam_lo')+256*R('cam_hi'))
        if pv == 0 and len(log) > 1: phase = 1
    ic = nes.idle_cyc
    st0 = R('state')
    nes.run_frame(b)
    if R('state') == 4 and st0 == 4 and R('dead_timer') != 109: maxbusy = max(maxbusy, 29780 - (nes.idle_cyc - ic))
    if f in (40, 200, 400, 700, 1000, 1300): shots.append(nes.render())
print('maxbusy', maxbusy, 'hp', R('hp'), 'lives', R('lives'), 'score', list(nes.ram[0x50:0x56]))
W = Image.new('RGB', (256*3, 240*2))
for i, im in enumerate(shots): W.paste(im, ((i%3)*256, (i//3)*240))
W.save('t4.png')
