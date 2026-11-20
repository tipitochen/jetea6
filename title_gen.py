import numpy as np
from PIL import Image
from emu import PAL
SRC='title/ref.png'
COLS={'k':0x0F,'w':0x30,'p':0x25,'c':0x2C,'s':0x27,'b':0x17,'g':0x00}
RGB={k:np.array(PAL[v]) for k,v in COLS.items()}
SRCRGB={'k':(0,0,0),'w':(240,240,240),'p':(240,32,128),'c':(0,220,240),'s':(240,160,96),'b':(130,48,16),'g':(115,115,115)}
SUB=[['k','w','p','c'],['k','s','b','w'],['k','c','w','s'],['k','p','w','s']]
def build(W):
    im=np.array(Image.open(SRC).convert('RGBA')).astype(int)
    x0,x1,y0,y1=119,1424,85,955
    im=im[y0:y1,x0:x1]
    keys=list(SRCRGB); ref=np.array([SRCRGB[k] for k in keys])
    d=((im[:,:,None,:3]-ref[None,None])**2).sum(3)
    q=d.argmin(2); q[im[:,:,3]<128]=0
    f=(x1-x0)/W; H=int(round((y1-y0)/f))
    out=np.zeros((H,W),int)
    for y in range(H):
        for x in range(W):
            blk=q[int(y*f+f*.25):int(y*f+f*.75)+1, int(x*f+f*.25):int(x*f+f*.75)+1]
            out[y,x]=np.bincount(blk.ravel(),minlength=len(keys)).argmax()
    return [[keys[v] for v in r] for r in out]
def palettize(img, ox, oy, TW=32, TH=30):
    H=len(img); W=len(img[0])
    canvas=[['k']*(TW*8) for _ in range(TH*8)]
    for y in range(H):
        for x in range(W): canvas[oy+y][ox+x]=img[y][x]
    attr=[[0]*(TW//2) for _ in range(TH//2)]
    pix=[[0]*(TW*8) for _ in range(TH*8)]
    for by in range(TH//2):
        for bx in range(TW//2):
            best=None
            for pi,s in enumerate(SUB):
                err=0; idx=[]
                for y in range(16):
                    for x in range(16):
                        c=canvas[by*16+y][bx*16+x]
                        if c in s: idx.append(s.index(c)); continue
                        dd=[((RGB[c]-RGB[t])**2).sum() for t in s]
                        i=int(np.argmin(dd)); err+=dd[i]; idx.append(i)
                if best is None or err<best[0]: best=(err,pi,idx)
            attr[by][bx]=best[1]
            for i,v in enumerate(best[2]): pix[by*16+i//16][bx*16+i%16]=v
    return pix,attr
def tiles(pix, TW=32, TH=30):
    tl=[];nt=[]
    for ty in range(TH):
        for tx in range(TW):
            t=tuple(''.join(str(pix[ty*8+y][tx*8+x]) if pix[ty*8+y][tx*8+x] else '.' for x in range(8)) for y in range(8))
            if t not in tl: tl.append(t)
            nt.append(tl.index(t))
    return tl,nt
if __name__=='__main__':
    import sys
    W=int(sys.argv[1])
    img=build(W)
    H=len(img); print('H',H)
    pix,attr=palettize(img,(256-W)//2,8)
    tl,nt=tiles(pix); print('tiles',len(tl))
    o=Image.new('RGB',(256,240))
    for y in range(240):
        for x in range(256):
            o.putpixel((x,y),tuple(RGB[SUB[attr[y//16][x//16]][pix[y][x]]]))
    o.resize((512,480),Image.NEAREST).save('title/prev_%d.png'%W)

def rowtiles(pix, r):
    s=[]
    for tx in range(32):
        s.append(tuple(''.join(str(pix[r*8+y][tx*8+x]) if pix[r*8+y][tx*8+x] else '.' for x in range(8)) for y in range(8)))
    return s
def split_stats(pix):
    rows=[rowtiles(pix,r) for r in range(30)]
    for R in range(6,20):
        common=set(rows[R-1])|set(rows[R])
        top=set().union(*rows[:R-1])-common
        bot=set().union(*rows[R+1:])-common
        print(R,len(common),len(top),len(bot))

TITLE_TEXT = ["1 JUGADOR", "2 JUGADORES", "PRESIONA START", "2026 HOMEBREW MMC3", ">"]
SPLIT_ROW = 13
TPAL = [0x0F] + [x for s in SUB for x in [COLS[c] for c in s[1:]]]   # para info

def make_title(font):
    """font: dict char->glyph rows (5 ancho). Devuelve (units[4] de 128 tiles c/u como listas de filas, nametable 960, attr 64, paleta 16)."""
    img = build(240)
    pix, attr = palettize(img, 8, 6)
    rows = [rowtiles(pix, r) for r in range(30)]
    blank = tuple(['........'] * 8)
    R = SPLIT_ROW
    used = sorted(set(''.join(TITLE_TEXT)) | set('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-') | {' '})   # todo el alfabeto (selector de nivel)
    fontidx = {}
    for ch in used:
        fontidx[ch] = ord(ch) - 32
    reserved = set(fontidx.values())
    common = []
    for t in rows[R - 1]:
        if t not in common and t != blank: common.append(t)
    top = []
    for r in range(R - 1):
        for t in rows[r]:
            if t not in common and t not in top and t != blank: top.append(t)
    bot = []
    for r in range(R, 30):
        for t in rows[r]:
            if t not in common and t not in bot and t != blank: bot.append(t)
    free_both = [i for i in range(1, 256) if i not in reserved]
    cmap = {blank: 0}
    for i, t in enumerate(common): cmap[t] = free_both[i]
    cused = set(cmap.values())
    tpool = [i for i in range(1, 256) if i not in cused]
    bpool = [i for i in free_both if i not in cused]
    assert len(top) <= len(tpool), ('top', len(top), len(tpool))
    assert len(bot) <= len(bpool), ('bot', len(bot), len(bpool))
    tmap = dict(cmap); bmap = dict(cmap)
    for i, t in enumerate(top): tmap[t] = tpool[i]
    for i, t in enumerate(bot): bmap[t] = bpool[i]
    TS = [blank] * 256; BS = [blank] * 256
    for t, i in tmap.items(): TS[i] = t
    for t, i in bmap.items(): BS[i] = t
    for ch, i in fontidx.items():
        if ch == ' ': continue
        g = font[ch]
        BS[i] = tuple(['.' + r.replace('#', '1').replace(' ', '.') + '..' for r in g] + ['........'])
    nt = []
    for r in range(30):
        m = tmap if r < R else bmap
        nt += [m[t] for t in rows[r]]
    at = []
    for ay in range(8):
        for ax in range(8):
            v = 0
            for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                by, bx = ay * 2 + dy, ax * 2 + dx
                p = attr[by][bx] if by < 15 else 0
                v |= p << (q * 2)
            at.append(v)
    pal = []
    for s in SUB: pal += [COLS[c] for c in s]
    return TS, BS, nt, at, pal, len(top) + len(common), len(bot) + len(common)
