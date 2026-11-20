import sys, collections, bisect
exec(open('t13.py').read().split('shots = {}')[0])
labs = sorted((v, k) for k, v in S.items() if 0xC000 <= v < 0x10000 and '@' not in k)
addrs = [v for v, k in labs]
prof = collections.Counter()
orig = nes.step
def step():
    pc = nes.pc; c0 = nes.cyc
    orig()
    i = bisect.bisect_right(addrs, pc) - 1
    prof[labs[i][1]] += nes.cyc - c0
worst = (0, None); lag = 0; n = 0
N = int(sys.argv[4]) if len(sys.argv) > 4 else 1500
for step_ in range(N):
    if R('state') != 4: nes.run_frame(0x10 if nes.frame % 50 == 0 else 0); continue
    fr = nes.frame
    nes.step = step; prof.clear()
    ic = nes.idle_cyc
    nes.run_frame(bot(0, fr), bot(1, fr) if two else 0)
    nes.step = orig
    busy = 29780 - (nes.idle_cyc - ic); n += 1
    if busy >= 29780: lag += 1
    if busy > worst[0]: worst = (busy, collections.Counter(prof))
print('frames', n, 'lag', lag, 'worst', worst[0])
for k, v in worst[1].most_common(22): print('%-18s %6d' % (k, v))
