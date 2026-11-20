import sys
exec(open('t13.py').read().split('shots = {}')[0])
# saltar oleadas: puntero al terminador
wp = S['lvl%d_waves' % start_level] + 15
nes.ram[S['wave_ptr']] = wp & 255; nes.ram[S['wave_ptr'] + 1] = wp >> 8
nes.ram[S['lock_lo']] = 0; nes.ram[S['lock_hi']] = 6
f = 0
while not R('boss_on') and f < 3000:
    fr = nes.frame; nes.run_frame(0x01, 0x01 if two else 0); f += 1
print('boss at', f, R('b_st'))
shots = []
maxb = 0
for i in range(400):
    for k in range(2):
        if nes.ram[0x500+32*k+31]:
            nes.ram[0x500+32*k+13] = 16
            if R('cur') == k: nes.ram[0xDD] = 16
    fr = nes.frame
    ic = nes.idle_cyc
    nes.run_frame(bot(0, fr), bot(1, fr) if two else 0)
    maxb = max(maxb, 29780 - (nes.idle_cyc - ic))
    if i in (150, 151, 250, 251): shots.append(nes.render())
print('maxbusy', maxb, 'b_hp', R('b_hp'), R('b_hpmax'), 'units', R('b_units'), 'bst', R('b_st'))
from PIL import Image
im = Image.new('RGB', (1024, 240))
for i, s in enumerate(shots): im.paste(s, (i * 256, 0))
im.save('t23_%s.png' % tag)
print('en', [(nes.ram[S['en_t']+i], nes.ram[S['en_st']+i], nes.ram[S['en_xlo']+i]+256*nes.ram[S['en_xhi']+i]) for i in range(3)])
print('boss', R('b_xlo')+256*R('b_xhi'), R('b_y'), R('b_z'), 'cam', R('cam_lo')+256*R('cam_hi'), 'id', R('boss_id'), 'r45', R('chr_r45'), 'ai', R('b_ai'))
o=nes.oam; print([tuple(o[i*4:i*4+4]) for i in range(64) if o[i*4]<240][:40])
print('p', [(nes.ram[0x500+32*k]+256*nes.ram[0x501+32*k], nes.ram[0x503+32*k], nes.ram[0x51F+32*k], nes.ram[0x50A+32*k], nes.ram[0x510+32*k]) for k in range(2)])
print('oam_i', R('oam_i'), R('oam_full'), 'b_units', R('b_units'))
nes.render().resize((512,480)).save('t23_last.png')
nes.sprite_limit=False
nes.render().resize((512,480)).save('t23_last_nolim.png')
print('regs', nes.regs, 'ctrl', hex(nes.ctrl), 'pal', [hex(x) for x in nes.palram[16:32]])
for t in (32, 150, 165):
    pa = 0x1000 + t*16
    print(t, [nes.chr[nes.chr_addr(pa+r)] for r in range(16)])
o = nes.oam
for i in range(64):
    if o[i*4] < 240 and o[i*4+1] in (32, 150):
        print('entry', i, o[i*4:i*4+4])
print(type(o), len(o))
calls = []
orig = nes.step
tg = {S['draw_player']: 'dp', S['draw_frame']: 'df', S['draw_fast']: 'fast', S['draw_boss']: 'db', S['draw_all']: 'da'}
def stp():
    if nes.pc in tg: calls.append((tg[nes.pc], R('sx_lo'), R('sx_hi'), R('cur'), R('dl_rev'), R('srev'), R('oam_i')))
    orig()
nes.step = stp
nes.run_frame(0, 0)
print(calls)
print('dl', [nes.ram[S['dl_id']+i] for i in range(6)], [nes.ram[S['dl_y']+i] for i in range(6)])
import bisect, collections
labs = sorted((v, k) for k, v in S.items() if '@' not in k and v >= 0xC000)
av = [v for v, k in labs]
cc = collections.Counter()
def stp2():
    cc[labs[bisect.bisect_right(av, nes.pc) - 1][1]] += 1
    orig()
nes.step = stp2
for i in range(3): nes.run_frame(0, 0)
print(cc.most_common(8))
