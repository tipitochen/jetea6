from asm import Assembler
from emu import NES
a = Assembler(0x10000); a.assemble('game2.asm'); S = a.syms
nes = NES('GTA6.nes', idle_addr=S['wait_nmi@w'])
R = lambda n: nes.ram[S[n]]
for f in range(60): nes.run_frame(0)
for b in [0x10,0,0,0,0x10]+[0]*3: nes.run_frame(b)
for f in range(170):
    nes.run_frame(0)
    t = R('cut_t')
    if t in (149,150,151,152,153):
        row3 = bytes(nes.vram[3*32:3*32+32]); row1 = bytes(nes.vram[32:64])
        print(t, R('str_pending'), ''.join(chr(c+32) if c<64 else '#' for c in row1), '|', ''.join(chr(c+32) if c<64 else '#' for c in row3))
