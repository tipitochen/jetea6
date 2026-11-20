import sys
from asm import Assembler
from emu import NES
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(360)
nes.render().resize((512,480)).save('t10_title.png')
print('state', nes.ram[S['state']], 'irq', nes.irq_count)
print(sorted(set(nes.line_chr)))
for y in range(90,110): print(y, nes.line_chr[y], end='; ')
