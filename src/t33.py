exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
got = []
for i in range(9000):
    nes.ram[0x50D] = 16
    if R('cur') == 0: nes.ram[0xDD] = 16
    fr = nes.frame
    nes.run_frame(bot(0, fr))
    cam = R('cam_lo') + 256 * R('cam_hi')
    for e in range(3):
        if nes.ram[S['en_t']+e] == 2:
            x = nes.ram[S['en_xlo']+e] + 256*nes.ram[S['en_xhi']+e] - cam; y = nes.ram[S['en_y']+e]
            if 40 < x < 216:
                nes.sprite_limit = False
                got.append(nes.render().crop((x - 36, y - 52, x + 36, y + 8)))
                nes.sprite_limit = True
    if len(got) >= 8: break
im = Image.new('RGB', (72 * 8, 60))
for i, g in enumerate(got): im.paste(g, (i * 72, 0))
im.resize((im.width * 3, 180), Image.NEAREST).save('police.png')
print(len(got))
