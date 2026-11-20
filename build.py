#!/usr/bin/env python3
import subprocess, sys
from asm import Assembler
subprocess.check_call([sys.executable, 'gen.py'])
a = Assembler(0x8000)
prg = a.assemble('game.asm')
chr_ = open('chr.bin', 'rb').read()
# iNES: PRG 2x16KB, CHR 2x8KB, mapper 4 (MMC3)
header = bytes([0x4E, 0x45, 0x53, 0x1A, 2, 2, 0x40, 0x00]) + bytes(8)
open('GTA6.nes', 'wb').write(header + bytes(prg) + chr_)
end = a.syms.get('main_reset')
print("ROM ok. codigo $C000.. ; uso banco fijo hasta ~$%04X" % max(v for k, v in a.syms.items() if 0xC000 <= v < 0xFF00 and not k.startswith('_')))
