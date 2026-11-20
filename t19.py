import sys, bisect
exec(open('t13.py').read().split('shots = {}')[0])
hist = []
orig = nes.step
def step():
    hist.append((nes.pc, nes.sp))
    if len(hist) > 30000: del hist[:15000]
    orig()
hooked = False; prev = None
for i in range(14000):
    st = R('state'); lv = R('level')
    if (st, lv) != prev: print('frame', nes.frame, 'state', st, 'level', lv); prev = (st, lv)
    if lv >= 1 and not hooked: nes.step = step; hooked = True
    if hooked and lv == 0: break
    for k in range(2):
        if nes.ram[0x500+32*k+31]:
            nes.ram[0x500+32*k+13] = 16
            if R('cur') == k: nes.ram[0xDD] = 16
    fr = nes.frame
    nes.run_frame(bot(0, fr) if st == 4 else (0x10 if fr % 50 == 0 else 0))
labs = sorted((v, k) for k, v in S.items() if '@' not in k)
av = [v for v, k in labs]
seen = []
for pc, sp in hist:
    k = labs[bisect.bisect_right(av, pc) - 1][1]
    if not seen or seen[-1][0] != k: seen.append((k, sp, hex(pc)))
for x in seen[-80:]: print(x)
