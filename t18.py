import sys
exec(open('t13.py').read().split('shots = {}')[0])
prev = None
hist = []
orig = nes.step
def step():
    hist.append(nes.pc)
    if len(hist) > 4000: del hist[:2000]
    orig()
nes.step = step
for i in range(600):
    st = R('state')
    if st != prev: print('frame', nes.frame, 'state', st, 'level', R('level')); prev = st
    if st == 0 and nes.frame > 200:
        break
    fr = nes.frame
    nes.run_frame(bot(0, fr) if st == 4 else 0)
labs = sorted((v, k) for k, v in S.items() if '@' not in k)
import bisect
av = [v for v, k in labs]
seen = []
for pc in hist[-3000:]:
    k = labs[bisect.bisect_right(av, pc) - 1][1]
    if not seen or seen[-1] != k: seen.append(k)
print(seen[-60:])
