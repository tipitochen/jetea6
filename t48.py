exec(open('t13.py').read().split('shots = {}')[0])
run(30)
run(1, 0x10); 
st = []
for i in range(60):
    run(1); st.append(R('state'))
print('tras START', st[::10])
x0 = nes.ram[0xD0]
run(30, 0x01); print('quieto en pausa?', nes.ram[0xD0] == x0, R('state'))
run(1, 0x10); run(30); print('despues', R('state'))
