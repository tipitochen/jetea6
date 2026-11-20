#!/usr/bin/env python3
import subprocess, sys
from asm import Assembler
if '--nogen' not in sys.argv:
    subprocess.check_call([sys.executable, 'gen3.py'])
a = Assembler(0x20000)
prg = a.assemble('game3.asm')
chr_ = open('chr3.bin', 'rb').read()
header = bytes([0x4E, 0x45, 0x53, 0x1A, 8, 8, 0x40, 0x00]) + bytes(8)
open('GTA6.nes', 'wb').write(header + bytes(prg) + chr_)
hi = max(v for k, v in a.syms.items() if 0xC000 <= v < 0xFF00)
b1 = max(v for k, v in a.syms.items() if 0xA000 <= v < 0xC000)
b0 = max(v for k, v in a.syms.items() if 0x8000 <= v < 0xA000)
print("ROM ok. codigo hasta $%04X, banco1 hasta $%04X, banco0 hasta $%04X" % (hi, b1, b0))
