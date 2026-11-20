import sys
exec(open('t13.py').read().split('shots = {}')[0])
for i in range(int(sys.argv[4])):
    st = R('state')
    for k in range(2):
        if nes.ram[0x500+32*k+31]:
            nes.ram[0x500+32*k+13] = 16
            if R('cur') == k: nes.ram[0xDD] = 16
    fr = nes.frame
    nes.run_frame(bot(0, fr) if st == 4 else (0x10 if fr % 50 == 0 else 0))
print('state', R('state'), 'lvl', R('level'), 'cam', R('cam_lo')+256*R('cam_hi'), 'lock', R('lock_lo')+256*R('lock_hi'), 'in_wave', R('in_wave'), 'to_spawn', R('to_spawn'), 'alive', R('alive'), 'boss', R('boss_on'), R('b_st'))
print('token', R('token'), [nes.ram[S['en_cd']+i] for i in range(3)], [nes.ram[S['en_tgt']+i] for i in range(3)], [nes.ram[S['en_mode']+i] for i in range(3)])
print('p1', list(nes.ram[0x500:0x520]))
print('en', [(nes.ram[S['en_t']+i], nes.ram[S['en_st']+i], nes.ram[S['en_xlo']+i]+256*nes.ram[S['en_xhi']+i], nes.ram[S['en_y']+i], nes.ram[S['en_hp']+i]) for i in range(3)])
print('w', [(nes.ram[S['w_t']+i], nes.ram[S['w_xlo']+i]+256*nes.ram[S['w_xhi']+i], nes.ram[S['w_y']+i], nes.ram[S['w_paint']+i]) for i in range(4)])
nes.render().resize((512,480)).save('t20.png')
for j in range(12):
    for i in range(50):
        for k in range(2):
            if nes.ram[0x500+32*k+31]:
                nes.ram[0x500+32*k+13] = 16
                if R('cur') == k: nes.ram[0xDD] = 16
        fr = nes.frame; nes.run_frame(bot(0, fr))
    print(nes.ram[0xD0]+256*nes.ram[0xD1], nes.ram[0xD3], 'pst', nes.ram[0xDA], 'en', [(nes.ram[S['en_st']+i], nes.ram[S['en_xlo']+i]+256*nes.ram[S['en_xhi']+i], nes.ram[S['en_y']+i], nes.ram[S['en_hp']+i]) for i in range(2)], 'tok', R('token'), 'cd', [nes.ram[S['en_cd']+i] for i in range(2)])
