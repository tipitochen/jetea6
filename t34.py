exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
for i in range(400):
    fr = nes.frame; nes.run_frame(bot(0, fr))
cam0 = R('cam_lo') + 256 * R('cam_hi')
nes.ram[0xED] = 1; nes.ram[0xDE] = 1
run(10)
print('state', R('state'), 'cont', nes.ram[S['continues']])
run(100); a = nes.render()
run(1, 0x10); run(40)
print('state', R('state'), 'cont', nes.ram[S['continues']], 'p', nes.ram[0x500] + 256 * nes.ram[0x501], 'cam', cam0, R('cam_lo') + 256 * R('cam_hi'))
b = nes.render()
for i in range(60):
    fr = nes.frame; nes.run_frame(bot(0, fr))
c = nes.render()
im = Image.new('RGB', (768, 240))
for i, s in enumerate((a, b, c)): im.paste(s, (i * 256, 0))
im.save('t34.png')
