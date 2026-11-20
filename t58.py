import sys, random
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
two = '--2p' in sys.argv
god = '--god' in sys.argv
skip = '--skip' in sys.argv
luci = '--luci' in sys.argv
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(330)
for b in (0x08, 0x08, 0x04, 0x04, 0x02, 0x01, 0x02, 0x01, 0x40, 0x80):
    run(1, b); run(3)
for i in range(5): run(1, 0x01); run(4)
if two: run(1, 0x08); run(4)
run(1, 0x10); run(30)
if not two:
    if luci: run(1, 0x01); run(5)
    run(1, 0x10); run(30)
run(1, 0x10); run(10)
print('state', R('state'), 'level', R('level'))
caps = []
# escena
for f in range(700):
    nes.run_frame(0x80 if skip and f == 5 else 0)
    if f % 45 == 0 and len(caps) < 16: caps.append(nes.render())
    if nes.ram[0x61C] == 0: print('escena termino en', f); break
caps.append(nes.render())
busy = 0; over = 0; fr = 0; bossf = None
while fr < 12000:
    if god: nes.ram[0x500 + 13] = 16; nes.ram[0x500 + 32 + 13] = 16
    hy = nes.ram[0x601]
    ty = 170
    if nes.ram[0x609] == 1: ty = 200
    else:
        es = [(nes.ram[0x626 + i], nes.ram[0x632 + i]) for i in range(4) if nes.ram[0x620 + i] in (1, 2)]
        if es: ty = min(es)[1]
    ty = max(122, min(218, ty))
    mv = 0x08 if hy > ty + 3 else 0x04 if hy < ty - 3 else 0
    mv |= 0x02 if nes.ram[0x600] > 50 else 0
    b = mv | (0 if two else (0x40 if fr % 2 else 0))
    b2 = (0x40 if fr % 2 else 0) if two else 0
    ic = nes.idle_cyc
    nes.run_frame(b, b2); fr += 1
    if R('state') == 14:
        bz = 29780 - (nes.idle_cyc - ic); busy = max(busy, bz); over += bz >= 29780
    if nes.ram[0x609] == 1 and bossf is None: bossf = fr
    if nes.ram[0x609] == 4 and fr % 50 == 0 and len(caps) < 40: caps.append(nes.render())
    if bossf and fr == bossf + 200: caps.append(nes.render())
    if bossf and fr == bossf + 600: caps.append(nes.render())
    if fr % 900 == 250 and len(caps) < 40: caps.append(nes.render())
    if R('state') != 14:
        print('salio state', R('state'), 'level', R('level'), 'f', fr); run(60); caps.append(nes.render())
        for k in range(4): run(1, 0x10); run(120)
        print('siguiente: state', R('state'), 'level', R('level')); run(300, 0x01); caps.append(nes.render()); break
print('boss en', bossf, 'boss hp', nes.ram[0x613], 'hboss', nes.ram[0x609], 'lives', nes.ram[0x50E], 'busy', busy, 'overruns', over)
im = Image.new('RGB', (256 * 4, 240 * ((len(caps) + 3) // 4)))
for i, c in enumerate(caps): im.paste(c, ((i % 4) * 256, (i // 4) * 240))
im.save('t58%s.png' % ('_2p' if two else ''))
