#!/usr/bin/env python3
import subprocess, sys
from asm import Assembler
if '--nogen' not in sys.argv:
    subprocess.check_call([sys.executable, 'gen4.py'])
    subprocess.check_call([sys.executable, 'music4.py'])
a = Assembler(0x20000)
prg = a.assemble('game4.asm')
chr_ = open('chr4.bin', 'rb').read()
assert len(chr_) == 0x40000
header = bytes([0x4E, 0x45, 0x53, 0x1A, 8, 32, 0x40, 0x00]) + bytes(8)
open('JETEA6.nes', 'wb').write(header + bytes(prg) + chr_)
hi = max(v for k, v in a.syms.items() if 0xC000 <= v < 0xFF00)
print("ROM ok. codigo hasta $%04X (limite $FF00)" % hi)
