import sys, random
from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(330)
for b in (0x08, 0x08, 0x04, 0x04, 0x02, 0x01, 0x02, 0x01, 0x40, 0x80):
    run(1, b); run(3)
run(1, 0x01); run(4)
run(1, 0x10); run(30); run(1, 0x10); run(30); run(1, 0x10); run(10)
print('state', R('state'))
# no hacer nada: que lo maten
st = []
for f in range(8000):
    nes.run_frame(0)
    s = R('state')
    if not st or st[-1] != s: st.append(s); print('f', f, 'state', s, 'lives', nes.ram[0x50E], 'cont', R('continues'))
    if s == 9 and f > 100:
        run(30); run(1, 0x10); run(40); print('tras continuar state', R('state'), 'lives', nes.ram[0x50E], 'hp', nes.ram[0x50D]); break
run(200)
nes.render().save('t54.png'); print('final state', R('state'))
