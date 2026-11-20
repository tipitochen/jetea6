import sys
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game3.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
god = '--god' in sys.argv
maxf = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 20000
start_level = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else 0
def run(n, f=lambda fr: 0):
    for i in range(n): nes.run_frame(f(nes.frame))
run(60); run(2, lambda f: 0x10); run(20)
if '--luci' in sys.argv: run(2, lambda f: 0x01); run(4)
run(2, lambda f: 0x10); run(10); run(2, lambda f: 0x10); run(10)
nes.ram[S['level']] = start_level
run(2, lambda f: 0x10); run(10)
shots = {}
maxbusy = 0; last = None
def W(n): return nes.ram[S[n]] + 256 * nes.ram[S[n] + 1] if False else None
for step in range(maxf):
    st = R('state')
    if st != 4:
        nes.run_frame(0x10 if nes.frame % 50 == 0 else 0)
        if st in (6, 7): print('fin estado', st, 'frame', nes.frame); break
        continue
    if god:
        nes.ram[S['hp']] = 16; nes.ram[S['lives']] = 3
    lvl = R('level')
    if lvl != last:
        last = lvl; print('nivel', lvl, 'frame', nes.frame, 'score', ''.join(map(str, nes.ram[0x50:0x56])))
    px = R('px_lo') + 256 * R('px_hi'); py = R('py'); fr = nes.frame
    targets = []
    for i in range(3):
        if nes.ram[S['en_t'] + i] and nes.ram[S['en_st'] + i] < 4:
            targets.append((nes.ram[S['en_xlo'] + i] + 256 * nes.ram[S['en_xhi'] + i], nes.ram[S['en_y'] + i]))
    if R('boss_on') and R('b_st') in (2, 3, 4, 5, 6):
        targets.append((R('b_xlo') + 256 * R('b_xhi'), R('b_y')))
    b = 0
    if targets:
        tx, ty = min(targets, key=lambda t: abs(t[0] - px) + abs(t[1] - py))
        dx = tx - px
        want = 28 if abs(dx) > 0 else 28
        if ty < py - 2: b |= 0x08
        elif ty > py + 2: b |= 0x04
        if abs(dx) > 34: b |= 0x01 if dx > 0 else 0x02
        elif abs(dx) < 18: b |= 0x02 if dx > 0 else 0x01
        else:
            if (dx > 0) != (R('pdir') == 0): b |= 0x01 if dx > 0 else 0x02
        if fr % 8 == 0: b |= 0x40
    else:
        b = 0x01
        # subir a vehiculos cercanos
        for i in range(3):
            if nes.ram[S['vo_t'] + i] and not R('pveh'):
                vx = nes.ram[S['vo_xlo'] + i] + 256 * nes.ram[S['vo_xhi'] + i]
                vy = nes.ram[S['vo_y'] + i]
                if abs(vx - px) < 60:
                    b = (0x01 if vx > px + 4 else 0x02 if vx < px - 4 else 0) | (0x08 if vy < py else 0x04 if vy > py else 0)
                    if abs(vx - px) < 10 and abs(vy - py) < 6 and fr % 20 == 0: b = 0xC0
    ic = nes.idle_cyc
    nes.run_frame(b)
    if R('state') == 4:
        maxbusy = max(maxbusy, 29780 - (nes.idle_cyc - ic))
        if targets and fr % 7 == 0 and len([k for k in shots if k.startswith('f')]) < 4:
            near = [t for t in targets if abs(t[0]-px) < 70]
            if near and fr % 35 == 0 and False: shots['f%d' % fr] = nes.render()
        if R('pveh') == 2 and 'car' not in shots and fr % 5 == 0: shots['car'] = nes.render()
        if R('pveh') == 1 and 'moto' not in shots and fr % 5 == 0: shots['moto'] = nes.render()
        if R('boss_on') and R('b_st') in (2,3,5,6) and ('boss%d' % lvl) not in shots and fr % 9 == 0:
            bx = R('b_xlo') + 256*R('b_xhi') - (R('cam_lo')+256*R('cam_hi'))
            if 50 < bx < 210 and (R('b_anim') & 63) > 40: shots['boss%d' % lvl] = nes.render()
print('maxbusy', maxbusy, 'level', R('level'), 'state', R('state'), 'hp', R('hp'), 'lives', R('lives'))
ims = list(shots.items())
Wd = Image.new('RGB', (256 * 4, 240 * ((len(ims) + 3) // 4 or 1)))
for i, (k, im) in enumerate(ims): Wd.paste(im, ((i % 4) * 256, (i // 4) * 240))
Wd.save('t8.png'); print(list(shots.keys()))
nes.render().save('t8_end.png')
