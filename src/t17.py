import sys, collections
exec(open('t13.py').read().split('shots = {}')[0])
c = collections.Counter()
orig = nes.step
df = S['draw_frame']
def step():
    if nes.pc == df:
        c[(R('sx_hi'), R('sx_lo') // 40, R('sclip'), R('sremap'), R('sforce'), nes.ram[S['fptr']+1] >= 0x80)] += 1
    orig()
nes.step = step
for i in range(1500):
    if R('state') != 4: nes.run_frame(0x10 if nes.frame % 50 == 0 else 0); continue
    fr = nes.frame; nes.run_frame(bot(0, fr), 0)
for k, v in c.most_common(20): print(k, v)
