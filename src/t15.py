import sys, collections
exec(open('t13.py').read().split('shots = {}')[0])
hist = collections.Counter(); comp = collections.Counter()
worst = None
for step in range(int(sys.argv[4]) if len(sys.argv)>4 else 3000):
    if R('state') != 4: nes.run_frame(0x10 if nes.frame % 50 == 0 else 0); continue
    fr = nes.frame
    nes.run_frame(bot(0, fr), bot(1, fr) if two else 0)
    cnt = [0] * 240
    for i in range(64):
        y = nes.oam[i * 4] + 1
        if y < 240:
            for yy in range(y, min(240, y + 8)): cnt[yy] += 1
    m = max(cnt); hist[m] += 1
    ne = sum(1 for i in range(3) if nes.ram[S['en_t']+i]); nv = sum(1 for i in range(3) if nes.ram[S['vo_t']+i])
    npr = sum(1 for i in range(8) if nes.ram[S['pr_t']+i])
    if m > 8: comp[(ne, R('boss_on'), npr>0)] += 1
    if worst is None or m > worst[0]: worst = (m, nes.render(), list(nes.oam))
print(sorted(hist.items())); print(comp.most_common(8))
im = worst[1]; o = worst[2]
from PIL import ImageDraw
d = ImageDraw.Draw(im)
for i in range(64):
    if o[i*4] < 239: d.rectangle((o[i*4+3], o[i*4]+1, o[i*4+3]+7, o[i*4]+8), outline=(255,0,0))
im.resize((512,480)).save('t15.png')
