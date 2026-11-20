import sys, bisect
exec(open('t13.py').read().split('shots = {}')[0])
run(30)
nes.ram[S['boss_on']] = 1; nes.ram[S['b_st']] = 9; nes.ram[S['clear_t']] = 2
prev = None
hist = []
orig = nes.step
def step():
    hist.append((nes.pc, nes.sp))
    if len(hist) > 60000: del hist[:30000]
    orig()
for i in range(1500):
    st = R('state'); lv = R('level')
    if (st, lv) != prev:
        print('frame', nes.frame, 'state', st, 'level', lv, 'cont', nes.ram[S['continues']], 'p_on', nes.ram[0x51F]); prev = (st, lv)
        if lv == 1 and st == 4: nes.step = step
        if lv == 0 and st != 4 and nes.step == step: break
    fr = nes.frame
    nes.run_frame(bot(0, fr) if st == 4 else (0x10 if fr % 50 == 0 else 0))
labs = sorted((v, k) for k, v in S.items() if '@' not in k)
av = [v for v, k in labs]
seen = []
for pc, sp in hist:
    k = labs[bisect.bisect_right(av, pc) - 1][1]
    if not seen or seen[-1][0] != k: seen.append((k, sp, hex(pc)))
for x in seen[-50:]: print(x)
