from asm import Assembler
from emu import NES
from PIL import Image
a = Assembler(0x20000); a.assemble('game4.asm'); S = a.syms
def boot(lv, two=False):
    nes = NES('JETEA6.nes', idle_addr=S['wait_nmi@w'])
    def run(n, b=0, b2=0):
        for i in range(n): nes.run_frame(b, b2)
    run(330)
    for b in (0x08, 0x08, 0x04, 0x04, 0x02, 0x01, 0x02, 0x01, 0x40, 0x80):
        run(1, b); run(3)
    for i in range(lv): run(1, 0x01); run(4)
    if two: run(1, 0x08); run(4)
    run(1, 0x10); run(30)
    if not two: run(1, 0x10); run(30)
    run(1, 0x10); run(10)
    return nes, run
caps = []
nes, run = boot(5, two=True)
for f in range(400):
    nes.run_frame(0)
    if f in (60, 150, 250, 300): caps.append(nes.render())
while nes.ram[0x61C]: nes.run_frame(0)
got_sh = got_cop = False; fr = 0; bossf = None; arr = 0
while fr < 9000:
    nes.ram[0x50D] = 16; nes.ram[0x52D] = 16
    hy = nes.ram[0x601]; ty = 170
    es = [(nes.ram[0x626 + i], nes.ram[0x632 + i]) for i in range(4) if nes.ram[0x620 + i] in (1, 2)]
    if nes.ram[0x609] == 1: ty = 190
    elif es: ty = min(es)[1]
    ty = max(122, min(218, ty))
    mv = 0x08 if hy > ty + 3 else 0x04 if hy < ty - 3 else 0
    mv |= 0x02 if nes.ram[0x600] > 50 else 0
    nes.run_frame(mv, 0x40 if fr % 2 else 0); fr += 1
    sh = [i for i in range(4) if nes.ram[0x620 + i] == 4 and nes.ram[0x650 + i] > 60 and nes.ram[0x644 + i] >= 0xF0]
    if sh and not got_sh: caps.append(nes.render()); got_sh = True
    if not got_cop and len([1 for i in range(4) if nes.ram[0x620 + i] in (1, 2) and nes.ram[0x626 + i] < 200]) >= 2:
        caps.append(nes.render()); got_cop = True
    if nes.ram[0x609] == 4 and nes.ram[S['cam_lo']] == 230 and arr == 0: caps.append(nes.render()); arr = 1
    if nes.ram[0x609] == 1 and bossf is None: bossf = fr
    if bossf and fr == bossf + 150: caps.append(nes.render())
    if nes.ram[0x609] == 2 and nes.ram[0x614] == 60: caps.append(nes.render())
    if nes.ram[S['state']] != 14: break
# nivel 2 (cielo)
nes, run = boot(1)
while nes.ram[0x61C]: nes.run_frame(0x80)
run(200, 0x40); caps.append(nes.render())
# final
nes, run = boot(10)
run(40); run(1, 0x10); run(60); caps.append(nes.render())
print(len(caps))
im = Image.new('RGB', (256 * 4, 240 * ((len(caps) + 3) // 4)))
for i, c in enumerate(caps): im.paste(c, ((i % 4) * 256, (i // 4) * 240))
im.save('capturas.png')
