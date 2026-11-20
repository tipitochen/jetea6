; =====================================================================
;  GTA6 - LA GRAN PERSECUCION   beat 'em up  (NES, MMC3)
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
pad_old = $15
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
px_lo = $23
px_hi = $24
py = $25
pz = $26
vz_lo = $27
vz_hi = $28
pdir = $29
pst = $2A
ptm = $2B
pveh = $2C
inv = $2D
hp = $2E
lives = $2F
char = $30
shoot_cd = $31
level = $32
seq_ptr = $33
combo = $35
combo_t = $36
vhits = $37
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
dead_t = $42
px_frac = $43
sx_lo = $44
sx_hi = $45
sy = $46
sflip = $47
spal = $48
stile = $49
fcount = $4A
hitdone = $4B
pframe = $4C
walk_t = $4D
sremap = $4E
oam_full = $4F
score = $50
vx = $56
lock_lo = $57
lock_hi = $58
in_wave = $59
to_spawn = $5A
spawn_cd = $5B
wave_ptr = $5C
go_t = $5E
z_frac = $5F
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
a_age = $7C
b_age = $7D
combo_cd = $7E
kvx = $7F
chr_r3 = $80
chr_r45 = $81
wave_side = $82
spawn_side = $83
sp_tmp = $84
pal_ptr = $85
vlab = $87
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
mus_p = $90
mus_sp = $96
mus_cp = $9C
mus_ct = $9D
mus_cn = $9E
sfx_timer = $9F
mus_on = $A0

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

; =====================================================================
    .base $0000, $8000
    .include "bank0.asm"
    .base $2000, $A000
    .include "music2.asm"
    .include "bank1.asm"
; =====================================================================
    .base $1C000, $C000
    .include "core3.asm"
    .include "play3.asm"
    .include "boss3.asm"
    .include "menus3.asm"
    .include "data3.asm"
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
