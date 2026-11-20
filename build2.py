#!/usr/bin/env python3
import subprocess, sys
from asm import Assembler
subprocess.check_call([sys.executable, 'gen2.py'])
a = Assembler(0x10000)
prg = a.assemble('game2.asm')
chr_ = open('chr2.bin', 'rb').read()
header = bytes([0x4E, 0x45, 0x53, 0x1A, 4, 8, 0x40, 0x00]) + bytes(8)
open('GTA6.nes', 'wb').write(header + bytes(prg) + chr_)
hi = max(v for k, v in a.syms.items() if 0xC000 <= v < 0xFF00)
print("ROM ok, codigo hasta $%04X (limite $FF00)" % hi)
