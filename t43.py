exec(open('t13.py').read().split('shots = {}')[0])
L = start_level
wp = S['lvl%d_waves' % L] + 15
nes.ram[S['wave_ptr']] = wp & 255; nes.ram[S['wave_ptr'] + 1] = wp >> 8
nes.ram[S['lock_lo']] = 0; nes.ram[S['lock_hi']] = 6
while not R('boss_on'): nes.run_frame(0x01)
run(60)
before = list(nes.palram[16:32]); print('antes', [hex(x) for x in before[8:12]], 'r45', R('chr_r45'))
nes.ram[0xED] = 1; nes.ram[0xDE] = 1
run(30); print('state', R('state'))
run(1, 0x10); run(40)
after = list(nes.palram[16:32]); print('despues', [hex(x) for x in after[8:12]], 'state', R('state'), 'r45', R('chr_r45'))
nes.render().save('t43.png')
