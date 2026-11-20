from art import *
from PIL import Image
PALS = {'jose': [(0,0,0,0),(20,20,20),(228,150,90),(76,208,32)], 'jose_b':[(0,0,0,0),(20,20,20),(228,150,90),(160,170,0)],
        'luciana':[(0,0,0,0),(20,20,20),(236,196,160),(236,88,180)], 'luciana_b':[(0,0,0,0),(20,20,20),(236,196,160),(76,154,236)],
        'cop':[(0,0,0,0),(20,20,20),(228,150,90),(8,76,196)], 'soldier':[(0,0,0,0),(20,20,20),(228,150,90),(8,124,0)],
        'veh':[(0,0,0,0),(20,20,20),(236,238,236),(200,30,30)], 'pol':[(0,0,0,0),(20,20,20),(228,150,90),(8,76,196)]}
def img(cv, pal, pal2=None, split=16):
    im = Image.new('RGB', (cv.w, cv.h), (100,160,230))
    for y in range(cv.h):
        for x in range(cv.w):
            c = cv.p[y][x]
            if c: im.putpixel((x,y), (pal2 if (pal2 and y>=split) else pal)[c])
    return im
S = 4
W = Image.new('RGB', (16*16*S+16*S, 32*5*S+40*S+16*S*3), (60,60,60))
for r, k in enumerate(['jose','luciana']):
    for i, cv in enumerate(char_frames(k)):
        W.paste(img(cv, PALS[k], PALS[k+'_b'], PALSPLIT[i]*8).resize((16*S,32*S),0), (i*17*S, r*33*S))
for r, k in enumerate(['cop','soldier']):
    for i, cv in enumerate(enemy_frames(k)):
        W.paste(img(cv, PALS[k]).resize((16*S,32*S),0), (i*17*S, (2+r)*33*S))
y0 = 4*33*S
W.paste(img(moto(0),PALS['veh']).resize((32*S,16*S),0),(0,y0))
W.paste(img(moto(1),PALS['veh']).resize((32*S,16*S),0),(33*S,y0))
W.paste(img(luxury_car(0),PALS['veh']).resize((48*S,16*S),0),(66*S,y0))
W.paste(img(police_car(),PALS['pol']).resize((48*S,16*S),0),(115*S,y0))
W.paste(img(heli_body(),PALS['veh']).resize((48*S,16*S),0),(164*S,y0+8*S))
W.paste(img(heli_rotor(0),PALS['veh']).resize((48*S,8*S),0),(164*S,y0))
for k in range(3): W.paste(img(explosion(k),PALS['veh']).resize((16*S,16*S),0),(213*S+k*17*S,y0))
W.save('preview.png')
