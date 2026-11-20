import sys
exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
L = 9
wp = S['lvl%d_waves' % L] + 15
nes.ram[S['wave_ptr']] = wp & 255; nes.ram[S['wave_ptr'] + 1] = wp >> 8
nes.ram[S['lock_lo']] = 0; nes.ram[S['lock_hi']] = 6
while not R('boss_on'): nes.run_frame(0x01)
run(200)
nes.ram[S['b_hp']] = 1
for i in range(600):
    nes.ram[0xDD] = 16
    fr = nes.frame; nes.run_frame(bot(0, fr))
    if R('state') == 8: break
shots = []
for k in range(14):
    run(60)
    shots.append(nes.render())
    if R('state') != 8: break
print('state', R('state'), len(shots))
im = Image.new('RGB', (1024, 240 * ((len(shots) + 3) // 4)))
for i, s in enumerate(shots): im.paste(s, ((i % 4) * 256, (i // 4) * 240))
im.save('t37.png')
