import sys
exec(open('t13.py').read().split('shots = {}')[0])
L = start_level
wp = S['lvl%d_waves' % L] + 15
nes.ram[S['wave_ptr']] = wp & 255; nes.ram[S['wave_ptr'] + 1] = wp >> 8
nes.ram[S['lock_lo']] = 0; nes.ram[S['lock_hi']] = 6
f = 0
while not R('boss_on') and f < 3000:
    nes.run_frame(0x01, 0x01 if two else 0); f += 1
spawned = R('boss_on')
img = None; maxb = 0
for i in range(int(sys.argv[4]) if len(sys.argv) > 4 else 900):
    for k in range(2):
        if nes.ram[0x500+32*k+31]:
            nes.ram[0x500+32*k+13] = 16
            if R('cur') == k: nes.ram[0xDD] = 16
    if i == 200: img = nes.render()
    if i == 220 and R('boss_on') and R('b_st') != 9: nes.ram[S['b_hp']] = 1
    st = R('state')
    fr = nes.frame
    ic = nes.idle_cyc
    nes.run_frame(bot(0, fr) if st == 4 else (0x10 if fr % 40 == 0 else 0), bot(1, fr) if two and st == 4 else 0)
    if st == 4: maxb = max(maxb, 29780 - (nes.idle_cyc - ic))
    if R('level') != L and L < 9: break
    if R('state') == 7: run(60); nes.render().save('ending.png'); break
print('L', L, 'boss spawn', spawned, 'f', f, 'id', R('boss_id'), '-> level', R('level'), 'state', R('state'), 'maxbusy', maxb)
if img: img.save('boss_L%d.png' % L)
