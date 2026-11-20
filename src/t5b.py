import sys, time
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x10000); a.assemble('game2.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
god = '--god' in sys.argv
for f in range(30): nes.run_frame(0)
for b in [0x10,0,0,0,0x01,0,0,0x10]+[0]*4: nes.run_frame(b)   # Luciana
want = {'car': None, 'polcar': None, 'boss': None, 'moto': None, 'mil': None}
maxbusy = 0; lastlvl = -1
def ent(t):
    return [(nes.ram[S['e_xlo']+i] + 256*nes.ram[S['e_xhi']+i]) for i in range(10) if nes.ram[S['e_type']+i] == t]
for step in range(int(sys.argv[2]) if len(sys.argv)>2 else 60000):
    st = R('state')
    if st != 4:
        nes.run_frame(0x10 if nes.frame % 40 == 0 else 0); continue
    if R('level') != lastlvl:
        lastlvl = R('level'); print('nivel', lastlvl, 'frame', nes.frame, 'lives', R('lives'), 'score', ''.join(map(str, nes.ram[0x50:0x56])))
    if god:
        nes.ram[S['inv']] = max(1, R('inv')); nes.ram[S['lives']] = 3
    px = R('px_lo') + 256*R('px_hi'); pv = R('pveh'); fr = nes.frame
    lp = R('lvl_ptr') + 256*nes.ram[S['lvl_ptr']+1]
    def col(x):
        mc = x >> 4
        return nes.rd(lp + mc) & 15 if 0 <= mc < 160 else 2
    b = 0x01 | (0x40 if fr % 12 < 6 else 0)
    here = col(px + 8)
    rng = (14, 26, 38) if pv else (6, 14, 22)
    if any(col(px + 8 + d) == 0 or col(px + 8 + d) > here for d in rng) and fr % 24 < 16: b |= 0x80
    if pv == 0 and R('onground'):
        for x in ent(3) + ent(6):
            if 0 <= px + 8 - x < 30 and fr % 30 == 0: b = 0xC0
    if R('boss_state') == 1:
        bx = ent(4)
        if bx:
            b = (0x40 if fr % 10 < 5 else 0) | 0x08
            if px > bx[0] - 70: b |= 0x02
            elif px < bx[0] - 110: b |= 0x01
            if fr % 50 < 12: b |= 0x80
    if 1040 < fr < 1052: print('vy',R('vy_hi'),R('vy_lo'),'cf',R('combo_f'),'ja',R('jump_age'),' f',fr,'px',px,'py',R('py'),'og',R('onground'),'vx',R('vx'),'pv',pv,'b',hex(b),'cam',R('cam_lo')+256*R('cam_hi'), 'dead', R('dead_timer'))
    if 1040 < fr < 1046:
        nes.pad = b
        while nes.pc != S['wait_nmi@w']: nes.step()
        print('   at idle: py', R('py'), 'og', R('onground'), 'vy', R('vy_hi'), R('vy_lo'), 'vx', R('vx'), 'px', R('px_lo')+256*R('px_hi'))
    ic = nes.idle_cyc
    nes.run_frame(b)
    maxbusy = max(maxbusy, 29780 - (nes.idle_cyc - ic)) if R('state') == 4 else maxbusy
    if pv == 2 and want['car'] is None and fr % 7 == 0: want['car'] = nes.render()
    if pv == 1 and want['moto'] is None and ent(1) and fr % 7 == 0: want['moto'] = nes.render()
    if ent(7) and want['polcar'] is None and fr % 5 == 0:
        x = ent(7)[0] - (R('cam_lo') + 256*R('cam_hi'))
        if 40 < x < 200: want['polcar'] = nes.render()
    if R('boss_state') == 1 and want['boss'] is None and ent(4) and fr % 9 == 0 and R('level') == 0:
        if ent(4)[0] - (R('cam_lo')+256*R('cam_hi')) < 190: want['boss'] = nes.render()
    if R('level') == 6 and want['mil'] is None and len(ent(1)) >= 2: want['mil'] = nes.render()
    if R('state') in (6, 7): print('fin estado', R('state'), 'frame', nes.frame); break
print('maxbusy', maxbusy, 'level', R('level'), 'state', R('state'))
ims = [v for v in want.values() if v is not None]
W = Image.new('RGB', (256*3, 240*2))
for i, im in enumerate(ims): W.paste(im, ((i%3)*256, (i//3)*240))
W.save('t5.png')
nes.render().save('t5_end.png')
