import sys, time
from asm import Assembler
from emu import NES
a = Assembler(); a.assemble('game.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
maxbusy = 0
def run(n, f):
    global maxbusy
    for i in range(n):
        ic = nes.idle_cyc
        nes.run_frame(f(nes.frame))
        if R('state') == 3:
            busy = 29780 - (nes.idle_cyc - ic)
            maxbusy = max(maxbusy, busy)
run(30, lambda f: 0); run(2, lambda f: 0x10); run(10, lambda f:0); run(2, lambda f:0x10); run(10, lambda f:0)
cheat = '--cheat' in sys.argv
def play(fr):
    b = 0x01 | (0x40 if fr % 16 < 8 else 0)
    if R('boss_state') == 1:
        bx = nes.ram[S['e_xlo']+7] + 256*nes.ram[S['e_xhi']+7]
        px = R('px_lo') + 256*R('px_hi')
        b = (0x40 if fr % 16 < 8 else 0) | (0x02 if px > bx - 60 else 0)
        if px < bx - 90: b |= 0x01
        if fr % 60 < 20: b |= 0x80
        return b
    px = R('px_lo') + 256*R('px_hi')
    lp = R('lvl_ptr') + 256*nes.ram[S['lvl_ptr']+1]
    def col(x):
        mc = x >> 4
        return nes.rd(lp + mc) if mc < 160 else 2
    here = col(px+8) & 15
    ahead = [col(px + 8 + d) & 15 for d in (10, 18, 26)]
    if any(a == 0 or a > here for a in ahead) or fr % 90 < 6:
        if fr % 30 < 18: b |= 0x80
    if (fr // 200) % 4 == 3: b |= 0x08
    return b
lastlvl = -1; shots = 0
for step in range(2400):
    st = R('state')
    if st == 3:
        if cheat: nes.ram[S['inv']] = 5; nes.ram[S['hp']] = 3; nes.ram[S['lives']] = 3
        run(25, play)
    else:
        run(25, lambda f: 0x10 if f % 30 == 0 else 0)
    if R('level') != lastlvl:
        lastlvl = R('level'); print('nivel', lastlvl, 'frame', nes.frame, 'lives', R('lives'))
    if st == 3 and R('boss_state') == 1 and shots < 1:
        nes.render().save('s_boss.png'); shots += 1
    if step % 80 == 0: print('  f',nes.frame,'lvl',R('level'),'px',R('px_lo')+256*R('px_hi'),'boss',R('boss_state'))
    if st in (5, 6): print('estado final', st, 'frame', nes.frame); break
print('maxbusy ciclos', maxbusy, 'score', list(nes.ram[0x50:0x56]), 'state', R('state'), 'level', R('level'))
nes.render().save('s_end.png')
