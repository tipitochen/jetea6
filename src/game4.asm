; =====================================================================
;  JETEA 6 - LA GRAN PERSECUCION   beat 'em up  (NES, MMC3)
;  PRG 128KB: b0 $8000 metasprites, b1 $A000 musica+niveles, b14-15 codigo
;  CHR 64KB (ver gen3.py)
; =====================================================================
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014
BTN_A     = $80
BTN_B     = $40
BTN_SEL   = $20
BTN_START = $10
BTN_UP    = $08
BTN_DOWN  = $04
BTN_LEFT  = $02
BTN_RIGHT = $01
ST_TITLE    = 0
ST_SELECT   = 1
ST_CUT      = 2
ST_INTRO    = 3
ST_PLAY     = 4
ST_CLEAR    = 5
ST_GAMEOVER = 6
ST_ENDING   = 7
ST_STORY    = 8
ST_CONT     = 9
ST_LOGO     = 10
ST_PAUSE    = 11
ST_ARS      = 12
ST_HELI     = 13
HELI_LVL    = 1
ST_AGUA     = 14
AGUA_LVL    = 5
IRQ_L1 = 30
IRQ_L2 = 32
YMIN = 164
YMAX = 230
NEN = 3
NPR = 8
NFX = 4
NVO = 3
; estados jugador
PS_NORM = 0
PS_PUNCH = 1
PS_SHOOT = 2
PS_HURT = 3
PS_DOWN = 4
PS_KICK = 5
PS_DEAD = 6
; estados enemigo
ES_WALK = 0
ES_PUNCH = 1
ES_SHOOT = 2
ES_HURT = 3
ES_DOWN = 4
ES_DIE = 5
; cuadros enemigo
EF_IDLE = 0
EF_WALK1 = 1
EF_WALK2 = 2
EF_PUNCH = 3
EF_AIM = 4
EF_HURT = 5
EF_DOWN = 6
W_CORA = 5
W_LANZ = 6
TITLE_IRQ = 97

; ---------------- zero page
tmp0 = $00
tmp1 = $01
tmp2 = $02
tmp3 = $03
tmp4 = $04
tmp5 = $05
tmp6 = $06
tmp7 = $07
ptr  = $08
ptr2 = $0A
fptr = $0C
frame = $10
nmi_flag = $11
ppu_on = $12
game_irq = $13
pad = $14
pad_new = $16
state = $17
ctrl_base = $18
cam_lo = $19
cam_hi = $1A
col_pending = $1B
col_addr_lo = $1C
col_addr_hi = $1D
attr_pending = $1E
attr_hi = $1F
attr_col = $20
tc_lo = $21
tc_hi = $22
pad1 = $23
pad2 = $24
padn1 = $25
padn2 = $26
two_p = $27
cur = $28
srev = $29
dl_rev = $2A
level = $32
seq_ptr = $33
boss_on = $38
timer = $39
pal_dirty = $3A
oam_i = $3B
sel = $3C
rng = $3D
irq_x = $3E
irq_ctrl = $3F
cam_max_lo = $40
cam_max_hi = $41
sx_lo = $44
sx_hi = $45
sy = $46
sflip = $47
spal = $48
stile = $49
fcount = $4A
sremap = $4E
oam_full = $4F
start_lvl = $0700       ; nivel elegido con el codigo konami (10 = final)
kon_i = $0701
lsel_on = $0702
lsel_dirty = $0703
lsel_buf = $0704
def_n = $05E8         ; sprites superpuestos diferidos (jugadores)
def_lo = $05E9
def_hi = $05EB
def_sxl = $05ED
def_sxh = $05EF
def_sy = $05F1
def_fl = $05F3
def_st = $05F5
score = $50
lock_lo = $57
lock_hi = $58
in_wave = $59
to_spawn = $5A
spawn_cd = $5B
wave_ptr = $5C
go_t = $5E
sforce = $5F
tmp8 = $60
tmp9 = $61
tmp10 = $62
tmp11 = $63
token = $64
alive = $65
blk_ptr = $66
street_ptr = $68
far_ptr = $6A
faction = $6C
stars = $6D
boss_id = $6E
clear_t = $6F
far_x = $70
far_ctrl = $71
irq_stage = $72
shake = $73
cut_t = $74
str_pending = $75
str_lo = $76
str_hi = $77
track = $78
chr_r2 = $79
chr_r1 = $7A
chr_r0 = $7B
cars_left = $7C
wtile_ptr = $7D
chr_r3 = $80
chr_r45 = $81
spawn_side = $83
bgq_n = $84
sclip = $85
b_units = $86
np_xlo = $88
np_xhi = $89
np_y = $8A
np_z = $8B
np_vx = $8C
np_vz = $8D
lvl_x = $8E
tfill = $8F
mus_p = $90
mus_sp = $98
mus_cnt = $A0
mus_on = $A4
sfx_timer = $A5
sfx_p2 = $A6
np_d = $A7
b_st = $B0
b_tm = $B1
b_xlo = $B2
b_xhi = $B3
b_y = $B4
b_z = $B5
b_hp = $B6
b_dir = $B7
b_flash = $B8
b_vz = $B9
b_cd = $BA
b_fr = $BB
b_ai = $BC
b_hpmax = $BD
b_w = $BE
b_h = $BF
b_mcd = $C0
b_vx = $C1
b_anim = $C2
b_inv = $C3
; contexto del jugador activo ($D0-$EF), copia de p_base + 32*jugador
px_lo = $D0
px_hi = $D1
px_frac = $D2
py = $D3
pz = $D4
z_frac = $D5
vz_lo = $D6
vz_hi = $D7
vx = $D8
pdir = $D9
pst = $DA
ptm = $DB
pframe = $DC
hp = $DD
lives = $DE
inv = $DF
pveh = $E0
vhits = $E1
shoot_cd = $E2
combo = $E3
combo_t = $E4
combo_cd = $E5
a_age = $E6
b_age = $E7
hitdone = $E8
walk_t = $E9
kvx = $EA
weap = $EB
ammo = $EC
dead_t = $ED
char = $EE
p_on = $EF
CTX = $D0
p_base = $0500
pad_a = $0540
padn_a = $0542

; ---------------- RAM
OAM     = $0200
en_t    = $0300
en_xlo  = $0303
en_xhi  = $0306
en_y    = $0309
en_z    = $030C
en_vz   = $030F
en_hp   = $0312
en_st   = $0315
en_tm   = $0318
en_dir  = $031B
en_fr   = $031E
en_inv  = $0321
en_anim = $0324
en_cd   = $0327
en_mode = $032A
en_kvx  = $032D
en_dead = $0330
en_flash = $0333
en_tgt  = $0336
vo_t    = $0340
vo_xlo  = $0343
vo_xhi  = $0346
vo_y    = $0349
pr_t    = $0350
pr_xlo  = $0358
pr_xhi  = $0360
pr_y    = $0368
pr_z    = $0370
pr_vx   = $0378
pr_vz   = $0380
pr_tm   = $0388
fx_t    = $0390
fx_xlo  = $0394
fx_xhi  = $0398
fx_y    = $039C
dl_y    = $03B0
dl_id   = $03B8
col_buf = $0400
attr_buf = $0420
pal_buf = $0430
str_buf = $0450
hud_buf = $0470
w_t     = $0560
w_xlo   = $0564
w_xhi   = $0568
w_y     = $056C
w_paint = $0570
bgq_hi  = $0580
bgq_lo  = $0588
bgq_t   = $0590
NW = 4
continues = $0544
cont_t  = $0545
cont_fr = $0546
ts_state = $0547
oam_ready = $0553
hud_end = $0552
col_cnt = $0554
lg_step = $0555
lg_row = $0556
lg_t = $0557
lg_ph = $0558
inv_ammo = $05A0
pz_pl = $05B0
pz_mode = $05B1
pz_cur = $05B2
pz_ph = $05B3
linebuf = $05C0
run_f = $05B8
plane_x = $05E0
plane_y = $05E1
plane_t = $05E2
plane_on = $05E3
tap_t = $05BA
tap_d = $05BC
irq_b0 = $0548
irq_b1 = $0549
irq_ln = $054A
st_scene = $054B
st_ph   = $054C
st_len  = $054D
st_pos  = $054E
st_t    = $054F
st_col  = $0550
st_fl   = $0551
st_p    = $2B
cact    = $2D

; =====================================================================
    .base $0000, $8000
    .include "bank0.asm"
end_b0:
    .base $2000, $A000
    .include "music4.asm"
    .include "bank1.asm"
end_b1:
    .base $4000, $8000
    .include "bank2.asm"
    .include "bank2code.asm"
    .include "strs_b2.asm"
    .include "names4.asm"
end_b2:
    .base $6000, $8000
    .include "bank3.asm"
end_b3:
    .base $8000, $8000
    .include "bank4.asm"
end_b4:
    .base $A000, $8000
    .include "bank5.asm"
end_b5:
    .base $C000, $8000
    .include "bank6.asm"
end_b6:
    .base $E000, $8000
    .include "bank7.asm"
end_b7:
    .base $10000, $8000
    .include "heli.asm"
end_b8:
    .base $12000, $8000
    .include "agua.asm"
end_b9:
    .base $14000, $A000
    .include "agua_bgdata.asm"
end_b10:
; =====================================================================
    .base $1C000, $C000
    .include "core4.asm"
    .include "play4.asm"
    .include "boss4.asm"
    .include "menus4.asm"
    .include "data4.asm"
    .base $1FF00, $FF00
reset:
    sei
    cld
    ldx #$40
    stx $4017
    lda #0
    sta $8000
    sta $E000
    jmp main_reset
    .base $1FFFA, $FFFA
    .word nmi, reset, irq
