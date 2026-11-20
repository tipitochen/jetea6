exec(open('t13.py').read().split('shots = {}')[0])
got = None
for i in range(9000):
    for k in range(2):
        if nes.ram[0x500+32*k+31]:
            nes.ram[0x500+32*k+13] = 16
            if R('cur') == k: nes.ram[0xDD] = 16
    fr = nes.frame
    nes.run_frame(bot(0, fr), bot(1, fr) if two else 0)
    cam = R('cam_lo') + 256 * R('cam_hi')
    for e in range(3):
        if nes.ram[S['en_t']+e] == 2:
            x = nes.ram[S['en_xlo']+e] + 256*nes.ram[S['en_xhi']+e] - cam
            if 60 < x < 200 and nes.ram[S['en_st']+e] < 3:
                got = nes.render(); break
    if got: break
print('frame', nes.frame)
if got: got.save('cap_patrullero.png')
