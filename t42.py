exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
got = {}
for i in range(4000):
    nes.ram[0xDD] = 16
    fr = nes.frame; nes.run_frame(bot(0, fr))
    if nes.ram[0x5E3] and 60 < nes.ram[0x5E0] < 200 and 'avion' not in got: got['avion'] = nes.render()
    if any(nes.ram[S['w_t']+k] and nes.ram[S['w_paint']+k] for k in range(4)) and 'arma' not in got:
        run(2); got['arma'] = nes.render()
    if len(got) == 2: break
print(list(got), nes.frame)
im = Image.new('RGB', (512, 240))
for i, s in enumerate(got.values()): im.paste(s, (i * 256, 0))
im.resize((1024, 480), Image.NEAREST).save('t42.png')
