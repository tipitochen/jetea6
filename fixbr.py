import re, sys
from asm import Assembler, AsmError
INV = {'BCC':'bcs','BCS':'bcc','BEQ':'bne','BNE':'beq','BMI':'bpl','BPL':'bmi','BVC':'bvs','BVS':'bvc'}
top = sys.argv[1] if len(sys.argv) > 1 else 'game3.asm'
for it in range(200):
    try:
        Assembler(0x20000).assemble(top); print('ok after', it); break
    except AsmError as e:
        m = re.search(r'([\w./]+\.asm):(\d+): salto fuera de rango', str(e))
        if not m: print(e); sys.exit(1)
        fn, ln = m.group(1), int(m.group(2))
        L = open(fn).read().split('\n')
        mm = re.match(r'(\s*)(\w+)\s+(\S+)', L[ln-1])
        ind, op, tgt = mm.groups()
        lab = '@__n%d_%d' % (ln, it)
        L[ln-1:ln] = ['%s%s %s' % (ind, INV[op.upper()], lab), '%sjmp %s' % (ind, tgt), '%s:' % lab]
        open(fn,'w').write('\n'.join(L))
