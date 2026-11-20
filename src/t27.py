import sys
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
mode = sys.argv[1]
def run(n, b=0):
    for i in range(n): nes.run_frame(b)
run(330)
if mode == '2p': run(2, 0x01); run(4); run(2, 0x10)
else:
    run(2, 0x10); run(20)
    if mode == 'luci': run(2, 0x01); run(4)
    run(2, 0x10)
shots = []
for k in range(40):
    run(30)
    if R('state') == 8 and R('st_ph') == 3 and (not shots or shots[-1][0] != (R('st_scene'), R('st_p'))):
        shots.append(((R('st_scene'), R('st_p')), nes.render()))
    if R('state') == 2: break
print('state', R('state'), len(shots))
for k in range(8):
    run(30); shots.append((None, nes.render()))
im = Image.new('RGB', (256 * 4, 240 * ((len(shots) + 3) // 4)))
for i, (_, s) in enumerate(shots): im.paste(s, ((i % 4) * 256, (i // 4) * 240))
im.save('t27_%s.png' % mode)
