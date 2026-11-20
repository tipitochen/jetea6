from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(); a.assemble('game.asm'); S = a.syms
shots = []
for lv in range(10):
    nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
    R = lambda n: nes.ram[S[n]]
    for f in range(30): nes.run_frame(0)
    for b in [0x10,0,0,0,0, 0x01 if lv%2 else 0, 0, 0x10]+[0]*5: nes.run_frame(b)
    nes.ram[S['level']] = lv
    for f in range(170): nes.run_frame(0)
    for f in range(150 + lv*20):
        nes.ram[S['inv']] = 0
        b = 0x01 | (0x40 if f%16<8 else 0)
        if f % 45 < 10: b |= 0x80
        nes.run_frame(b)
    shots.append(nes.render())
    if lv == 9:
        nes.ram[S['boss_state']] = 2; nes.ram[S['clear_timer']] = 1
        for f in range(80): nes.run_frame(0)
        shots.append(nes.render())
W = Image.new('RGB', (256*4, 240*3))
for i, im in enumerate(shots): W.paste(im, ((i%4)*256, (i//4)*240))
W.save('levels_sheet.png')
