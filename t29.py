exec(open('t13.py').read().split('shots = {}')[0])
from PIL import Image
# enemigo caminando: capturar 16 cuadros siguiendo al enemigo
got = []
for i in range(3000):
    fr = nes.frame
    nes.run_frame(0x01 if not any(nes.ram[S['en_t']+j] for j in range(3)) else 0)
    e = [j for j in range(3) if nes.ram[S['en_t']+j] == 1 and nes.ram[S['en_st']+j] == 0]
    if e:
        j = e[0]
        cam = R('cam_lo') + 256 * R('cam_hi')
        x = nes.ram[S['en_xlo']+j] + 256 * nes.ram[S['en_xhi']+j] - cam; y = nes.ram[S['en_y']+j]
        if 30 < x < 226:
            if len(got)==10: nes.render().resize((512,480)).save('enemy_full.png'); nes.sprite_limit=False; nes.render().resize((512,480)).save('enemy_full2.png'); nes.sprite_limit=True
            got.append(nes.render().crop((x - 24, y - 40, x + 24, y + 14)))
    if len(got) >= 32: break
im = Image.new('RGB', (48 * 16, 54))
for i, g in enumerate(got[1::2]): im.paste(g, (i * 48, 0))
im.resize((im.width * 2, 108), Image.NEAREST).save('enemy_walk.png')
