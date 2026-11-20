import sys, random
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
god = '--god' in sys.argv
two = '--2p' in sys.argv
maxf = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 20000
start_level = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else 0
tag = sys.argv[3] if len(sys.argv) > 3 and not sys.argv[3].startswith('--') else 'run'
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(330)
if two: run(2, 0x01); run(4)
run(2, 0x10); run(20)
if not two:
    if '--luci' in sys.argv: run(2, 0x01); run(6)
    run(2, 0x10); run(20)
run(2, 0x10); run(20)   # historia
run(2, 0x10); run(20)   # cutscene
nes.ram[S['level']] = start_level
run(2, 0x10); run(10)
PB = 0x500
def P(k, off): return nes.ram[PB + 32 * k + off]
def bot(k, fr):
    if not P(k, 31): return 0x10 if fr % 30 == k * 15 else 0
    px = P(k, 0) + 256 * P(k, 1); py = P(k, 3)
    targets = []
    for i in range(3):
        if nes.ram[S['en_t'] + i] and nes.ram[S['en_st'] + i] < 4:
            targets.append((nes.ram[S['en_xlo'] + i] + 256 * nes.ram[S['en_xhi'] + i], nes.ram[S['en_y'] + i]))
    if R('boss_on') and R('b_st') in (2, 3, 4, 5, 6):
        targets.append((R('b_xlo') + 256 * R('b_xhi'), R('b_y')))
    # recoger cosas del piso
    for i in range(4):
        if nes.ram[S['w_t'] + i]:
            wx = nes.ram[S['w_xlo'] + i] + 256 * nes.ram[S['w_xhi'] + i] + 8; wy = nes.ram[S['w_y'] + i]
            cam = R('cam_lo') + 256 * R('cam_hi')
            if abs(wx - px) < 50 and cam + 8 < wx < cam + 232 and (not targets or nes.ram[S['w_t'] + i] == 5):
                b = (0x01 if wx > px + 3 else 0x02 if wx < px - 3 else 0) | (0x08 if wy < py - 2 else 0x04 if wy > py + 2 else 0)
                return b
    b = 0
    if targets:
        tx, ty = min(targets, key=lambda t: abs(t[0] - px) + abs(t[1] - py))
        dx = tx - px
        if ty < py - 2: b |= 0x08
        elif ty > py + 2: b |= 0x04
        if abs(dx) > 34 + 10 * k: b |= 0x01 if dx > 0 else 0x02
        elif abs(dx) < 18: b |= 0x02 if dx > 0 else 0x01
        else:
            if (dx > 0) != (P(k, 9) == 0): b |= 0x01 if dx > 0 else 0x02
        if fr % 8 == k * 4: b |= 0x40
    else:
        b = 0x01
    return b
shots = {}
maxbusy = 0; last = None; maxline = 0; overl = 0; frames = 0
stats = dict(hearts_drop=0, hearts_pick=0, cont_used=0, cars=0, picks=0)
prevw = [0] * 4; prevcont = 3; prevcar = 0
for step in range(maxf):
    st = R('state')
    if st != 4:
        nes.run_frame(0x10 if nes.frame % 50 == 0 else 0)
        if st in (6, 7): print('fin estado', st, 'frame', nes.frame, 'nivel', R('level')); shots['fin'] = nes.render(); break
        continue
    if god:
        for k in range(2):
            if P(k, 31):
                nes.ram[PB + 32 * k + 13] = 16; nes.ram[PB + 32 * k + 14] = 3
                if R('cur') == k: nes.ram[0xDD] = 16; nes.ram[0xDE] = 3
    lvl = R('level')
    if last is not None and lvl != last and '--one' in sys.argv:
        print('nivel completado', last, 'frame', nes.frame); break
    if lvl != last:
        last = lvl; print('nivel', lvl, 'frame', nes.frame, 'score', ''.join(map(str, nes.ram[0x50:0x56])), 'cont', nes.ram[S['continues']])
    fr = nes.frame
    b1 = bot(0, fr); b2 = bot(1, fr) if two else 0
    ic = nes.idle_cyc
    nes.run_frame(b1, b2)
    if R('state') != 4: continue
    frames += 1
    maxbusy = max(maxbusy, 29780 - (nes.idle_cyc - ic))
    # sprites por linea
    cnt = [0] * 240
    for i in range(64):
        y = nes.oam[i * 4] + 1
        if y < 240:
            for yy in range(y, min(240, y + 8)): cnt[yy] += 1
    m = max(cnt); maxline = max(maxline, m)
    if m > 8: overl += 1
    for i in range(4):
        t = nes.ram[S['w_t'] + i]
        if t == 5 and prevw[i] != 5: stats['hearts_drop'] += 1
        if t == 0 and prevw[i] == 5 and nes.ram[S['w_paint'] + i]: stats['hearts_pick'] += 1
        if t == 0 and prevw[i] in (2, 3, 4): stats['picks'] += 1
        prevw[i] = t
    if any(nes.ram[S['en_t'] + i] == 2 for i in range(3)) and prevcar == 0: stats['cars'] += 1
    prevcar = int(any(nes.ram[S['en_t'] + i] == 2 for i in range(3)))
    c = nes.ram[S['continues']]
    if c < prevcont: stats['cont_used'] += prevcont - c
    prevcont = c
    if any(nes.ram[S['en_t'] + i] == 2 for i in range(3)) and 'patrullero' not in shots and fr % 10 == 0:
        shots['patrullero'] = nes.render()
    if any(nes.ram[S['w_t'] + i] == 5 and nes.ram[S['w_paint'] + i] for i in range(4)) and 'corazon' not in shots:
        run(1); shots['corazon'] = nes.render()
    if any(nes.ram[S['w_t'] + i] in (2, 3, 4) and nes.ram[S['w_paint'] + i] for i in range(4)) and 'arma' not in shots:
        shots['arma'] = nes.render()
    if R('cont_t') and 'continue' not in shots and R('cont_t') < 8: shots['continue'] = nes.render()
    if R('boss_on') and R('b_st') in (2, 3, 5, 6) and ('boss%d' % lvl) not in shots and fr % 9 == 0:
        bx = R('b_xlo') + 256 * R('b_xhi') - (R('cam_lo') + 256 * R('cam_hi'))
        if 50 < bx < 210 and (R('b_anim') & 63) > 40: shots['boss%d' % lvl] = nes.render()
print('maxbusy', maxbusy, 'max spr/linea', maxline, 'frames >8', overl, 'de', frames)
print('level', R('level'), 'state', R('state'), stats)
ims = list(shots.items())
Wd = Image.new('RGB', (256 * 4, 240 * ((len(ims) + 3) // 4 or 1)))
for i, (k, im) in enumerate(ims): Wd.paste(im, ((i % 4) * 256, (i // 4) * 240))
Wd.save('t13_%s.png' % tag); print(list(shots.keys()))
nes.render().save('t13_%s_end.png' % tag)
