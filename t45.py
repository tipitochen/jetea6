exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
run(30)
nes.ram[0xEB]=1; nes.ram[0xEC]=12
run(1, 0x20); run(12)
shots = []
for k in range(17):
    run(4); shots.append(nes.render())
im = Image.new('RGB', (100 * 17, 130))
for i, s in enumerate(shots): im.paste(s.crop((0, 30, 100, 160)), (i * 100, 0))
im.save('t45_%s.png' % ('l' if '--luci' in sys.argv else 'j'))
