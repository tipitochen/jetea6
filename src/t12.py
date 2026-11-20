from asm import Assembler
from emu import NES
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
def run(n, b=0, b2=0):
    for i in range(n): nes.run_frame(b, b2)
run(40); run(2,0x10); run(20); run(2,0x10); run(20); run(120); run(2,0x10); run(20); run(2,0x10); run(30)
print('p1', list(nes.ram[0x500:0x520]))
print('ctx', list(nes.ram[0xD0:0xF0]))
o=nes.oam
print([tuple(o[i*4:i*4+4]) for i in range(64) if o[i*4]<240])
print('chr', [nes.ram[S[k]] for k in ('chr_r0','chr_r1','chr_r2','chr_r3','chr_r45')], nes.regs)
print('ctrl', hex(nes.ctrl), 'cam', nes.ram[S['cam_lo']])
cnt={}
orig=nes.step
watch={S[k]:k for k in ('st_play','player_tick','player_update','load_player','store_player','gameover_init','camera_update','draw_player','draw_all')}
def st():
    if nes.pc in watch: cnt[watch[nes.pc]]=cnt.get(watch[nes.pc],0)+1
    orig()
nes.step=st
run(5)
print(cnt)
print('inv', nes.ram[0x50F], 'cur', nes.ram[S['cur']])
