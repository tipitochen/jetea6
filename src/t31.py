exec(open('t13.py').read().split('shots = {}')[0])
lf = 0
for i in range(3000):
    fr = nes.frame
    b = nes.late_w
    nes.run_frame(bot(0, fr))
    if nes.late_w > b:
        lf += 1
        if lf < 6: print('frame', nes.frame, 'late writes', nes.late_w - b, 'linea', nes.late_max, 'col', R('col_pending'), 'pal', R('pal_dirty'))
print('frames tarde', lf)
