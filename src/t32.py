import collections
exec(open('t13.py').read().split('shots = {}')[0])
h = collections.Counter(); worst = []
for i in range(3000):
    fr = nes.frame
    nes.last_w = 0
    nes.run_frame(bot(0, fr))
    lw = nes.last_w
    if lw < 100: lw += 262
    h[lw] += 1
    if lw >= 258: worst.append((lw, R('col_pending'), R('pal_dirty'), R('bgq_n')))
print(sorted(h.items())[-12:])
print(worst[:10])
