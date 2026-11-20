; =====================================================================
;  GTA6 - LA GRAN PERSECUCION   (NES, mapper 4 / MMC3)
;  PRG 64KB: banco0 $8000 niveles/mapas, banco1 $A000 musica, 6-7 codigo
;  CHR 64KB: fuente 0-1, banco 6-7, tilesetA 16-23 (4 cuadros agua),
;            tilesetB 24-31, Jose 32-33, Luciana 34-35, vehiculos 36,
;            policia 37, militar 38, varios 39
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

E_COP    = 1
E_CROUCH = 2
E_MOTO   = 3
E_BOSS   = 4
E_EXPL   = 5
E_CAR    = 6
E_POLCAR = 7
E_DYING  = 8
E_BAG    = 9

IRQ_L1    = 30
IRQ_L2    = 48
NUM_EN    = 10

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
py_frac = $26
vy_lo = $27
vy_hi = $28
pdir = $29
onground = $2A
anim = $2B
pveh = $2C
inv = $2D
hp = $2E
lives = $2F
char = $30
shoot_cd = $31
level = $32
lvl_ptr = $33
lvl_len = $35
spawn_ptr = $36
boss_state = $38
timer = $39
pal_dirty = $3A
oam_i = $3B
sel = $3C
rng = $3D
irq_x = $3E
irq_ctrl = $3F
cam_max_lo = $40
cam_max_hi = $41
dead_timer = $42
px_frac = $43
spr_xlo = $44
spr_xhi = $45
spr_y = $46
spr_tile = $47
spr_w = $48
spr_h = $49
spr_attr = $4A
pfeet_old = $4B
lim_lo = $4C
lim_hi = $4D
hud_bar = $4E
oam_full = $4F
score = $50          ; $50-$55
vx = $56
veh_hp = $57
spr_attr2 = $58
spr_split = $59
clear_timer = $5A
run_acc = $5B
run_idx = $5C
pframe = $5D
chr_r2 = $5E
chr_r1 = $5F
tmp8 = $60
tmp9 = $61
tmp10 = $62
tmp11 = $63
eb_y_t = $64
eb_dx_t = $65
eb_dy_t = $66
lvl_tileset = $67
tw = $68
th = $69
dm_r = $6A
dm_c = $6B
dm_y = $6C
dm_xl = $6D
dm_xh = $6E
dm_rb = $6F
far_x = $70
far_ctrl = $71
irq_stage = $72
faction = $73
stars = $74
crouch = $75
flash_t = $76
shake = $77
aim = $78
cut_t = $79
str_pending = $7A
str_lo = $7B
str_hi = $7C
en_rot = $7D
track = $7E
hurt_t = $7F
far_ptr = $80        ; 2
dust_t = $82
dust_xlo = $83
dust_xhi = $84
dust_y = $85
veh_anim = $86
cut_x = $87
cut_cx = $88
cut_mode = $89
boss_t = $8A
combo_cd = $8B
wheel_acc = $8C
col_mc = $8D
pol_flip = $8E
mus_p = $90          ; 3 punteros: $90 pulso, $92 triangulo, $94 ruido
mus_sp = $96         ; inicios: $96 $98 $9A
mus_cp = $9C
mus_ct = $9D
mus_cn = $9E
sfx_timer = $9F
mus_on = $A0
a_age = $A1
b_age = $A2
jump_age = $A3
jump_y = $A4
combo_f = $A5

; ---------------- RAM
OAM      = $0200
e_type   = $0300
e_xlo    = $030A
e_xhi    = $0314
e_y      = $031E
e_hp     = $0328
e_tm     = $0332
e_dir    = $033C
e_anim   = $0346
e_flash  = $0350
e_state  = $035A
e_vy     = $0364
e_vx     = $036E
pb_on    = $0380
pb_xlo   = $0385
pb_xhi   = $038A
pb_y     = $038F
pb_dx    = $0394
pb_dy    = $0399
eb_on    = $03A0
eb_xlo   = $03A8
eb_xhi   = $03B0
eb_y     = $03B8
eb_dx    = $03C0
eb_dy    = $03C8
col_buf  = $0400
attr_buf = $0420
pal_buf  = $0430
str_buf  = $0450

; =====================================================================
    .base $0000, $8000
    .include "levels2.asm"
    .base $2000, $A000
    .include "music2.asm"
; =====================================================================
    .base $C000, $C000

main_reset:
    ldx #$FF
    txs
    inx
    stx PPUCTRL
    stx PPUMASK
    stx $4010
    stx $E000
@vb1:
    bit PPUSTATUS
    bpl @vb1
    txa
@clr:
    sta $00,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne @clr
    lda #$FF
@clr2:
    sta $0200,x
    inx
    bne @clr2
@vb2:
    bit PPUSTATUS
    bpl @vb2
    jsr mmc3_init
    cli
    jsr sound_init
    lda #$A5
    sta rng
    lda #$88
    sta ctrl_base
    sta PPUCTRL
    jsr title_init
main_loop:
    jsr wait_nmi
    jsr read_pad
    jsr run_state
    jmp main_loop

run_state:
    lda state
    asl
    tax
    lda state_tbl+1,x
    pha
    lda state_tbl,x
    pha
    rts
state_tbl:
    .word st_title-1, st_select-1, st_cut-1, st_intro-1, st_play-1, st_clear-1, st_wait_start-1, st_wait_start-1

; ---------------------------------------------------------------- MMC3
mmc3_init:
    lda #0
    sta $A000
    lda #$80
    sta $A001
    ldx #0
@l:
    stx $8000
    lda bank_init,x
    sta $8001
    inx
    cpx #8
    bne @l
    lda #16
    sta chr_r1
    lda #32
    sta chr_r2
    rts
bank_init:
    .byte 0, 16, 32, 36, 37, 39, 0, 1

set_bank:              ; X = registro, A = banco (solo con PPU apagada)
    stx $8000
    sta $8001
    rts

; ---------------------------------------------------------------- utilidades
wait_nmi:
    lda #0
    sta nmi_flag
@w:
    lda nmi_flag
    beq @w
    rts

read_pad:
    lda pad
    sta pad_old
    lda #1
    sta $4016
    lda #0
    sta $4016
    ldx #8
@l:
    lda $4016
    lsr
    rol pad
    dex
    bne @l
    lda pad_old
    eor #$FF
    and pad
    sta pad_new
    rts

rand:
    lda rng
    asl
    bcc @n
    eor #$1D
@n:
    sta rng
    rts

ppu_off:
    jsr wait_nmi
    lda #0
    sta ppu_on
    sta game_irq
    sta str_pending
    sta $E000
    sta PPUMASK
    rts

ppu_enable:
    lda #1
    sta ppu_on
    jsr wait_nmi
    rts

clear_nt:
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #0
    sta PPUADDR
    ldy #8
    ldx #0
@l:
    sta PPUDATA
    inx
    bne @l
    dey
    bne @l
    rts

draw_strings:
    ldy #0
    lda (ptr),y
    beq @done
    bit PPUSTATUS
    sta PPUADDR
    iny
    lda (ptr),y
    sta PPUADDR
    iny
    lda (ptr),y
    tax
    iny
@c:
    lda (ptr),y
    sta PPUDATA
    iny
    dex
    bne @c
    tya
    clc
    adc ptr
    sta ptr
    bcc draw_strings
    inc ptr+1
    jmp draw_strings
@done:
    rts

load_palette:
    ldy #31
@l:
    lda (ptr),y
    sta pal_buf,y
    dey
    bpl @l
    lda #1
    sta pal_dirty
    rts

fill_attr:             ; A=valor X=offset desde $23C0 Y=cantidad
    pha
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    txa
    clc
    adc #$C0
    sta PPUADDR
    pla
@l:
    sta PPUDATA
    dey
    bne @l
    rts

clear_oam:
    lda #$FF
    ldx #0
@l:
    sta OAM,x
    inx
    inx
    inx
    inx
    bne @l
    lda #0
    sta oam_i
    sta oam_full
    rts

write_score:
    ldx #0
@l:
    lda score,x
    clc
    adc #$10
    sta PPUDATA
    inx
    cpx #6
    bne @l
    rts

write_level_num:
    lda level
    clc
    adc #1
    ldx #$10
    cmp #10
    bcc @one
    sbc #10
    ldx #$11
@one:
    stx PPUDATA
    clc
    adc #$10
    sta PPUDATA
    rts

write_stars:           ; escribe 5 estrellas segun 'stars'
    ldx #0
@l:
    lda #$48
    cpx stars
    bcs @e
    lda #$47
@e:
    sta PPUDATA
    inx
    cpx #5
    bne @l
    rts

add_score:             ; A=cantidad Y=digito
    clc
    adc score,y
    cmp #10
    bcc @ok
    sbc #10
    sta score,y
    lda #1
    dey
    bpl add_score
    rts
@ok:
    sta score,y
    rts

queue_line:            ; A=fila, ptr -> [len, texto]  (centrado, 32 columnas)
    pha
    ldx #31
    lda #0
@c:
    sta str_buf,x
    dex
    bpl @c
    ldy #0
    lda (ptr),y
    sta tmp0
    lda #32
    sec
    sbc tmp0
    lsr
    tax
    iny
@t:
    lda (ptr),y
    sta str_buf,x
    inx
    iny
    dec tmp0
    bne @t
    pla
    sta tmp0
    lda #0
    sta tmp1
    asl tmp0
    rol tmp1
    asl tmp0
    rol tmp1
    asl tmp0
    rol tmp1
    asl tmp0
    rol tmp1
    asl tmp0
    rol tmp1
    lda tmp0
    sta str_lo
    lda tmp1
    ora #$20
    sta str_hi
    lda #1
    sta str_pending
    rts

load_pal_ptr:          ; A/X = lo/hi
    sta ptr
    stx ptr+1
    jmp load_palette

draw_ptr:
    sta ptr
    stx ptr+1
    jmp draw_strings

; ---------------------------------------------------------------- NMI / IRQ
nmi:
    pha
    txa
    pha
    tya
    pha
    lda ppu_on
    bne @ppu
    jmp @after
@ppu:
    lda #0
    sta OAMADDR
    lda #2
    sta OAMDMA
    lda pal_dirty
    beq @nopal
    bit PPUSTATUS
    lda #$3F
    sta PPUADDR
    lda #0
    sta PPUADDR
    ldx #0
@pl:
    lda pal_buf,x
    sta PPUDATA
    inx
    cpx #32
    bne @pl
    lda #0
    sta pal_dirty
@nopal:
    lda col_pending
    beq @nocol
    jsr nmi_column
@nocol:
    lda str_pending
    beq @nostr
    bit PPUSTATUS
    lda str_hi
    sta PPUADDR
    lda str_lo
    sta PPUADDR
    ldx #0
@sl:
    lda str_buf,x
    sta PPUDATA
    inx
    cpx #32
    bne @sl
    lda #0
    sta str_pending
@nostr:
    lda game_irq
    beq @nohud
    jsr nmi_hud
@nohud:
    ; bancos CHR animados
    lda #2
    sta $8000
    lda chr_r2
    sta $8001
    lda #1
    sta $8000
    lda game_irq
    beq @noanim
    lda frame
    lsr
    lsr
    and #$06
    clc
    adc chr_r1
    sta $8001
    jmp @scr
@noanim:
    lda chr_r1
    sta $8001
@scr:
    bit PPUSTATUS
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    lda ctrl_base
    sta PPUCTRL
    lda #$1E
    sta PPUMASK
    lda game_irq
    beq @after
    ; scroll lejano = cam/4
    lda cam_hi
    sta tmp7
    lda cam_lo
    lsr tmp7
    ror
    lsr tmp7
    ror
    sta far_x
    lda tmp7
    and #1
    ora ctrl_base
    sta far_ctrl
    lda cam_lo
    ldx shake
    beq @nsh
    dec shake
    lda frame
    and #2
    asl
    clc
    adc cam_lo
@nsh:
    sta irq_x
    lda cam_hi
    and #1
    ora ctrl_base
    sta irq_ctrl
    lda #0
    sta irq_stage
    sta $E000
    lda #IRQ_L1
    sta $C000
    sta $C001
    sta $E001
@after:
    jsr music_update
    inc frame
    lda #1
    sta nmi_flag
    pla
    tay
    pla
    tax
    pla
    rti

irq:
    pha
    sta $E000
    lda irq_stage
    bne @s1
    lda far_x
    sta PPUSCROLL
    lda #0
    sta PPUSCROLL
    lda far_ctrl
    sta PPUCTRL
    lda #IRQ_L2
    sta $C000
    sta $C001
    sta $E001
    inc irq_stage
    pla
    rti
@s1:
    lda irq_x
    sta PPUSCROLL
    lda #0
    sta PPUSCROLL
    lda irq_ctrl
    sta PPUCTRL
    pla
    rti

nmi_column:
    lda ctrl_base
    ora #4
    sta PPUCTRL
    lda col_addr_hi
    sta PPUADDR
    lda col_addr_lo
    sta PPUADDR
    ldx #0
@l:
    lda col_buf,x
    sta PPUDATA
    inx
    cpx #20
    bne @l
    lda ctrl_base
    sta PPUCTRL
    lda attr_pending
    beq @done
    ldx #0
@a:
    lda attr_hi
    sta PPUADDR
    txa
    asl
    asl
    asl
    clc
    adc #$D0
    adc attr_col
    sta PPUADDR
    lda attr_buf,x
    sta PPUDATA
    inx
    cpx #6
    bne @a
    lda #0
    sta attr_pending
@done:
    lda #0
    sta col_pending
    rts

nmi_hud:
    lda #$20
    sta PPUADDR
    lda #$22
    sta PPUADDR
    ldx #0
@h:
    lda #0
    cpx hp
    bcs @e
    lda #$40
@e:
    sta PPUDATA
    inx
    cpx #3
    bne @h
    lda #$20
    sta PPUADDR
    lda #$2C
    sta PPUADDR
    lda lives
    clc
    adc #$10
    sta PPUDATA
    lda #$20
    sta PPUADDR
    lda #$38
    sta PPUADDR
    jsr write_score
    lda #$20
    sta PPUADDR
    lda #$42
    sta PPUADDR
    lda pveh
    asl
    asl
    clc
    adc pveh
    tax
    ldy #5
@lb:
    lda veh_names,x
    sta PPUDATA
    inx
    dey
    bne @lb
    lda #0
    sta PPUDATA
    ldx #0
@m:
    lda #0
    cpx hud_bar
    bcs @me
    lda #$46
@me:
    sta PPUDATA
    inx
    cpx #8
    bne @m
    rts
veh_names:
    .text "A PIE"
    .text "MOTO "
    .text "AUTO "

; ---------------------------------------------------------------- sonido
sound_init:
    lda #$0F
    sta $4015
    lda #$30
    sta $4000
    sta $4004
    sta $400C
    lda #$80
    sta $4008
    lda #$08
    sta $4001
    sta $4005
    lda #0
    jmp mus_play

mus_play:              ; A = pista
    sta track
    asl
    sta tmp0
    asl
    clc
    adc tmp0
    tax
    lda #0
    sta mus_on
    ldy #0
@c:
    lda track_tbl,x
    sta mus_p,y
    sta mus_sp,y
    inx
    iny
    cpy #6
    bne @c
    lda #1
    sta mus_cp
    sta mus_ct
    sta mus_cn
    sta mus_on
    lda #$30
    sta $4000
    lda #$80
    sta $4008
    rts

music_update:
    lda sfx_timer
    beq @st
    dec sfx_timer
@st:
    lda mus_on
    beq @off
    dec mus_cp
    bne @t
    ldx #0
    jsr mus_fetch
    sty mus_cp
    tax
    bne @pp
    lda #$30
    sta $4000
    jmp @t
@pp:
    lda #$86
    sta $4000
    lda note_lo,x
    sta $4002
    lda note_hi,x
    ora #$08
    sta $4003
@t:
    dec mus_ct
    bne @n
    ldx #2
    jsr mus_fetch
    sty mus_ct
    tax
    bne @tp
    lda #$80
    sta $4008
    sta $400B
    jmp @n
@tp:
    lda #$30
    sta $4008
    lda note_lo,x
    sta $400A
    lda note_hi,x
    ora #$08
    sta $400B
@n:
    dec mus_cn
    bne @off
    ldx #4
    jsr mus_fetch
    sty mus_cn
    ldx sfx_timer
    bne @off
    tax
    beq @off
    lda drum_c-1,x
    sta $400C
    lda drum_e-1,x
    sta $400E
    lda drum_f-1,x
    sta $400F
@off:
    rts
drum_c: .byte $1C, $1A, $14
drum_e: .byte $0C, $06, $02
drum_f: .byte $28, $38, $18

mus_fetch:             ; X = canal*2 -> A nota, Y duracion
    lda (mus_p,x)
    cmp #$FF
    bne @ok
    lda mus_sp,x
    sta mus_p,x
    lda mus_sp+1,x
    sta mus_p+1,x
    jmp mus_fetch
@ok:
    pha
    jsr @inc
    lda (mus_p,x)
    tay
    jsr @inc
    pla
    rts
@inc:
    inc mus_p,x
    bne @r
    inc mus_p+1,x
@r:
    rts

sfx_shoot:
    lda #$84
    sta $4004
    lda #$8B
    sta $4005
    lda #$40
    sta $4006
    lda #$08
    sta $4007
    rts
sfx_power:
    lda #$84
    sta $4004
    lda #$F9
    sta $4005
    lda #$00
    sta $4006
    lda #$09
    sta $4007
    rts
sfx_boom:
    lda #$0F
    sta $400C
    lda #$0D
    sta $400E
    lda #$08
    sta $400F
    lda #40
    sta sfx_timer
    rts
sfx_hit:
    lda #$04
    sta $400C
    lda #$06
    sta $400E
    lda #$08
    sta $400F
    lda #10
    sta sfx_timer
    rts

; ---------------------------------------------------------------- titulo
title_init:
    jsr ppu_off
    lda #0
    jsr mus_play
    lda #16
    sta chr_r1
    ldx #1
    jsr set_bank
    lda #33
    sta chr_r2
    ldx #3
    lda #36
    jsr set_bank
    ldx #5
    lda #39
    jsr set_bank
    jsr clear_nt
    lda #<logo_strs
    ldx #>logo_strs
    jsr draw_ptr
    lda #<sun_strs
    ldx #>sun_strs
    jsr draw_ptr
    lda #<title_strs
    ldx #>title_strs
    jsr draw_ptr
    lda #$55
    ldx #8
    ldy #32
    jsr fill_attr
    lda #$AA
    ldx #40
    ldy #8
    jsr fill_attr
    lda #<pal_title
    ldx #>pal_title
    jsr load_pal_ptr
    jsr clear_oam
    lda #0
    sta cam_lo
    sta cam_hi
    sta cut_t
    sta char
    lda #ST_TITLE
    sta state
    jsr ppu_enable
    rts

st_title:
    inc cut_t
    lda frame
    and #$1F
    bne @nb
    lda pal_buf+9
    eor #$3F
    sta pal_buf+9
    lda #1
    sta pal_dirty
@nb:
    ; desfile: moto perseguida por patrullero
    jsr clear_oam
    lda frame
    sta veh_anim
    lda #0
    sta pol_flip
    lda cut_t
    sta spr_xlo
    lda #0
    sta spr_xhi
    sta pdir
    lda #186
    sta spr_y
    jsr draw_rider_at
    lda cut_t
    sec
    sbc #80
    sta spr_xlo
    lda #0
    sbc #0
    sta spr_xhi
    lda #202
    sta spr_y
    jsr draw_polcar_at
    lda pad_new
    and #BTN_START|BTN_A
    beq @r
    jsr sfx_power
    jmp select_init
@r:
    rts

; spr_xlo/xhi = x de la moto, spr_y = y del jinete (moto en y+16)
draw_rider_at:
    lda spr_xlo
    clc
    adc #8
    sta tmp8
    lda spr_xhi
    adc #0
    sta tmp9
    lda spr_y
    sta tmp10
    lda #2
    sta spr_w
    lda #4
    sta spr_h
    lda #48
    sta spr_tile
    lda #0
    ldx pdir
    beq @f
    lda #$40
@f:
    sta spr_attr
    ora #1
    sta spr_attr2
    lda #2
    sta spr_split
    lda tmp8
    sta spr_xlo
    lda tmp9
    sta spr_xhi
    jsr draw_meta
    lda tmp8
    sec
    sbc #8
    sta spr_xlo
    lda tmp9
    sbc #0
    sta spr_xhi
    lda tmp10
    clc
    adc #16
    sta spr_y
    lda veh_anim
    and #4
    asl
    clc
    adc #V_MOTO
    sta spr_tile
    lda #4
    sta spr_w
    lda #2
    sta spr_h
    lda spr_attr
    and #$40
    ora #3
    sta spr_attr
    lda #$FF
    sta spr_split
    jmp draw_meta

draw_polcar_at:        ; spr_xlo/xhi, spr_y (arriba del auto)
    lda #V_POL
    sta spr_tile
    lda #6
    sta spr_w
    lda #2
    sta spr_h
    lda #2
    ora pol_flip
    sta spr_attr
    lda #$FF
    sta spr_split
    lda spr_xlo
    sta tmp8
    lda spr_xhi
    sta tmp9
    jsr draw_meta
    ; sirena
    lda tmp9
    bne @r
    lda tmp8
    clc
    adc #20
    bcs @r
    sta tmp0
    lda spr_y
    sec
    sbc #5
    sta tmp1
    lda #M_SIREN
    sta tmp2
    lda frame
    and #8
    asl
    asl
    asl
    ora #3
    sta tmp3
    jmp put_spr
@r:
    rts

; ---------------------------------------------------------------- seleccion
select_init:
    jsr ppu_off
    lda #32
    sta chr_r2
    ldx #3
    lda #34
    jsr set_bank
    jsr clear_nt
    lda #<select_strs
    ldx #>select_strs
    jsr draw_ptr
    lda #<pal_select
    ldx #>pal_select
    jsr load_pal_ptr
    jsr clear_oam
    lda #ST_SELECT
    sta state
    lda #0
    sta sel
    jsr ppu_enable
    rts

st_select:
    lda pad_new
    and #BTN_LEFT|BTN_RIGHT|BTN_SEL
    beq @nolr
    lda sel
    eor #1
    sta sel
    jsr sfx_shoot
@nolr:
    lda pad_new
    and #BTN_START|BTN_A
    beq @draw
    lda sel
    sta char
    lda #3
    sta lives
    lda #0
    sta level
    ldx #5
@sc:
    sta score,x
    dex
    bpl @sc
    jsr sfx_power
    jmp cut_init
@draw:
    jsr clear_oam
    lda #2
    sta spr_w
    lda #4
    sta spr_h
    lda #2
    sta spr_split
    lda #0
    sta spr_xhi
    ; Jose
    lda #72
    sta spr_xlo
    lda #88
    sta spr_y
    lda #0
    sta spr_attr
    lda #1
    sta spr_attr2
    ldx #0
    jsr sel_frame
    sta spr_tile
    jsr draw_meta
    ; Luciana (tiles $40+, paletas 2/3)
    lda #168
    sta spr_xlo
    lda #2
    sta spr_attr
    lda #3
    sta spr_attr2
    ldx #1
    jsr sel_frame
    clc
    adc #$40
    sta spr_tile
    jsr draw_meta
    ; flecha
    lda #76
    ldx sel
    beq @a
    lda #172
@a:
    sta tmp0
    lda frame
    lsr
    lsr
    and #3
    clc
    adc #70
    sta tmp1
    lda #M_ARROW
    sta tmp2
    lda #0
    sta tmp3
    jmp put_spr

sel_frame:             ; X = personaje -> A = tile (cuadro*8)
    cpx sel
    bne @idle
    lda frame
    lsr
    lsr
    lsr
    and #7
    cmp #6
    bcc @ok
    sbc #6
@ok:
    clc
    adc #2
    jmp @t
@idle:
    lda frame
    lsr
    lsr
    lsr
    lsr
    lsr
    and #1
@t:
    asl
    asl
    asl
    rts

; ---------------------------------------------------------------- escena del robo
cut_init:
    jsr ppu_off
    lda #6
    sta chr_r1
    ldx #1
    jsr set_bank
    lda char
    asl
    clc
    adc #32
    sta chr_r2
    ldx #3
    lda #36
    jsr set_bank
    ldx #4
    lda #37
    jsr set_bank
    ; nametable del banco
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR
    lda #<bank_nt
    sta ptr
    lda #>bank_nt
    sta ptr+1
    ldx #4
    ldy #0
@l:
    lda (ptr),y
    sta PPUDATA
    iny
    bne @l
    inc ptr+1
    dex
    bne @l
    lda #<pal_cut
    ldx #>pal_cut
    jsr load_pal_ptr
    jsr load_char_pal
    jsr clear_oam
    lda #0
    sta cut_t
    sta cut_mode
    lda #ST_CUT
    sta state
    jsr ppu_enable
    lda #<cut_l1
    sta ptr
    lda #>cut_l1
    sta ptr+1
    lda #1
    jsr queue_line
    rts

load_char_pal:
    lda char
    asl
    asl
    asl
    tax
    ldy #0
@l:
    lda char_pals,x
    sta pal_buf+16,y
    inx
    iny
    cpy #8
    bne @l
    lda pal_buf
    sta pal_buf+16
    lda #1
    sta pal_dirty
    rts

char_pals:
    .byte $0F, $0F, $27, $2A, $0F, $0F, $27, $18
    .byte $0F, $0F, $37, $25, $0F, $0F, $37, $21

; eventos de texto: tiempo, fila, puntero
cut_events:
    .byte 50, 3
    .word cut_l2
    .byte 150, 1
    .word cut_l3
    .byte 151, 3
    .word cut_l4
    .byte 230, 1
    .word cut_l5
    .byte 231, 3
    .word cut_l6
    .byte 0

st_cut:
    inc cut_t
    lda cut_t
    bne @nw
    lda #255
    sta cut_t
@nw:
    lda pad_new
    and #BTN_START
    beq @ns
    jmp @end
@ns:
    lda cut_t
    cmp #250
    bcc @go
@end:
    lda #0
    sta level
    jmp intro_init
@go:
    ; eventos de texto
    ldx #0
@ev:
    lda cut_events,x
    beq @evd
    cmp cut_t
    bne @evn
    lda cut_events+2,x
    sta ptr
    lda cut_events+3,x
    sta ptr+1
    lda cut_events+1,x
    ; nombre segun personaje
    cpx #4
    bne @q
    lda char
    beq @q0
    lda #<cut_l3b
    sta ptr
    lda #>cut_l3b
    sta ptr+1
@q0:
    lda #1
@q:
    jsr queue_line
    jmp @evd
@evn:
    inx
    inx
    inx
    inx
    jmp @ev
@evd:
    ; alarma: fondo parpadeante desde t=40
    lda cut_t
    cmp #40
    bcc @noal
    lda frame
    and #8
    beq @blue
    lda #$06
    bne @sa
@blue:
    lda #$01
@sa:
    sta pal_buf
    sta pal_buf+16
    lda #1
    sta pal_dirty
@noal:
    jsr clear_oam
    ; patrullero: entra desde la izquierda t=90..150
    lda cut_t
    cmp #90
    bcc @nocar
    sec
    sbc #90
    cmp #64
    bcc @cx
    lda #64
@cx:
    sec
    sbc #48
    sta spr_xlo
    lda #0
    sbc #0
    sta spr_xhi
    lda cut_t
    cmp #154
    bcc @ncx
    lda #16
    sta spr_xlo
    lda #0
    sta spr_xhi
@ncx:
    lda #204
    sta spr_y
    lda #0
    sta pol_flip
    jsr draw_polcar_at
@nocar:
    ; policias salen t>=160 corriendo y disparando
    lda cut_t
    cmp #160
    bcc @nocop
    sec
    sbc #160
    clc
    adc #40
    sta spr_xlo
    lda #0
    sta spr_xhi
    lda #160
    sta spr_y
    lda #2
    sta spr_w
    lda #4
    sta spr_h
    lda #2
    sta spr_attr
    lda #$FF
    sta spr_split
    lda frame
    lsr
    lsr
    and #3
    asl
    asl
    asl
    clc
    adc #$80
    sta spr_tile
    jsr draw_meta
    lda cut_t
    and #16
    beq @nocop
    lda spr_xlo
    clc
    adc #16
    adc cut_t
    and #$7F
    adc #60
    sta tmp0
    lda #172
    sta tmp1
    lda #M_EB
    sta tmp2
    lda #3
    sta tmp3
    jsr put_spr
@nocop:
    ; moto estacionada / jugador
    lda cut_t
    cmp #60
    bcs @pl
    ; solo moto estacionada
    lda #200
    sta spr_xlo
    lda #0
    sta spr_xhi
    lda #176
    sta spr_y
    lda #V_MOTO
    sta spr_tile
    lda #4
    sta spr_w
    lda #2
    sta spr_h
    lda #3
    sta spr_attr
    lda #$FF
    sta spr_split
    jmp draw_meta
@pl:
    cmp #140
    bcc @__n1612_0
    jmp @ride
@__n1612_0:
    ; corre desde la puerta (x 120) hasta 200 con la bolsa
    sec
    sbc #60
    clc
    adc #120
    cmp #204
    bcc @px
    lda #204
@px:
    sta cut_x
    sta spr_xlo
    lda #0
    sta spr_xhi
    lda #160
    sta spr_y
    lda #2
    sta spr_w
    lda #4
    sta spr_h
    lda #0
    sta spr_attr
    lda #1
    sta spr_attr2
    lda #2
    sta spr_split
    lda frame
    lsr
    lsr
    and #7
    cmp #6
    bcc @rf
    sbc #4
@rf:
    clc
    adc #2
    asl
    asl
    asl
    sta spr_tile
    jsr draw_meta
    ; bolsa
    lda cut_x
    sec
    sbc #10
    sta spr_xlo
    lda #0
    sta spr_xhi
    lda #170
    sta spr_y
    lda #M_BAG
    sta spr_tile
    lda #2
    sta spr_w
    sta spr_h
    lda #3
    sta spr_attr
    lda #$FF
    sta spr_split
    jsr draw_meta
    ; moto esperando
    lda #200
    sta spr_xlo
    lda #0
    sta spr_xhi
    lda #176
    sta spr_y
    lda #V_MOTO
    sta spr_tile
    lda #4
    sta spr_w
    lda #2
    sta spr_h
    lda #3
    sta spr_attr
    jmp draw_meta
@ride:
    ; en la moto, acelera hacia la derecha
    lda chr_r2
    ora #1
    sta chr_r2
    lda cut_t
    sec
    sbc #140
    sta tmp0
    lsr
    lsr
    sta tmp1
    lda tmp0
    lsr
    clc
    adc tmp1
    clc
    adc #200
    sta spr_xlo
    lda #0
    adc #0
    sta spr_xhi
    lda #160
    sta spr_y
    lda #0
    sta pdir
    lda frame
    sta veh_anim
    jmp draw_rider_at

; ---------------------------------------------------------------- intro de nivel
intro_init:
    jsr ppu_off
    lda #0
    jsr mus_play
    lda level
    asl
    asl
    asl
    asl
    tax
    lda level_tbl+11,x
    sta stars
    lda level_tbl+8,x
    sta faction
    jsr clear_nt
    lda #<intro_strs
    ldx #>intro_strs
    jsr draw_ptr
    bit PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$11
    sta PPUADDR
    jsr write_level_num
    bit PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$12
    sta PPUADDR
    jsr write_stars
    bit PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$90
    sta PPUADDR
    lda lives
    clc
    adc #$10
    sta PPUDATA
    lda level
    asl
    tax
    lda name_tbl,x
    sta ptr
    lda name_tbl+1,x
    sta ptr+1
    jsr draw_strings
    lda faction
    bne @mil
    lda #<pol_str
    ldx #>pol_str
    jmp @fs
@mil:
    lda #<mil_str
    ldx #>mil_str
@fs:
    jsr draw_ptr
    lda #$AA
    ldx #32
    ldy #8
    jsr fill_attr
    lda #<pal_intro
    ldx #>pal_intro
    jsr load_pal_ptr
    jsr clear_oam
    lda #ST_INTRO
    sta state
    lda #150
    sta timer
    jsr ppu_enable
    rts

st_intro:
    dec timer
    beq @go
    lda pad_new
    and #BTN_START
    beq @r
@go:
    jmp level_init
@r:
    rts

; ---------------------------------------------------------------- pantallas de texto
text_screen:           ; A/X = cadenas, Y = estado
    sty tmp6
    pha
    txa
    pha
    jsr ppu_off
    lda #0
    jsr mus_play
    jsr clear_nt
    pla
    tax
    pla
    jsr draw_ptr
    lda ptr2+1
    beq @nx
    lda ptr2
    sta ptr
    lda ptr2+1
    sta ptr+1
    jsr draw_strings
@nx:
    bit PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$D3
    sta PPUADDR
    jsr write_score
    lda #<pal_intro
    ldx #>pal_intro
    jsr load_pal_ptr
    jsr clear_oam
    lda tmp6
    sta state
    lda #90
    sta timer
    jmp ppu_enable

clear_init:
    lda #0
    sta ptr2+1
    lda #<clear_strs
    ldx #>clear_strs
    ldy #ST_CLEAR
    jmp text_screen

st_clear:
    dec timer
    bne @r
    jmp intro_init
@r:
    rts

gameover_init:
    lda #0
    sta ptr2+1
    lda #<gameover_strs
    ldx #>gameover_strs
    ldy #ST_GAMEOVER
    jmp text_screen

ending_init:
    lda char
    bne @l
    lda #<end_jose
    sta ptr2
    lda #>end_jose
    sta ptr2+1
    jmp @d
@l:
    lda #<end_luci
    sta ptr2
    lda #>end_luci
    sta ptr2+1
@d:
    lda #<ending_strs
    ldx #>ending_strs
    ldy #ST_ENDING
    jmp text_screen

st_wait_start:
    lda timer
    beq @k
    dec timer
    rts
@k:
    lda pad_new
    and #BTN_START
    beq @r
    jmp title_init
@r:
    rts

level_clear:
    inc level
    lda level
    cmp #10
    bcc @n
    jmp ending_init
@n:
    jmp clear_init

; ---------------------------------------------------------------- inicio de nivel
level_init:
    jsr ppu_off
    lda #1
    jsr mus_play
    lda level
    asl
    asl
    asl
    asl
    tax
    lda level_tbl,x
    sta lvl_ptr
    lda level_tbl+1,x
    sta lvl_ptr+1
    lda level_tbl+2,x
    sta lvl_len
    lda level_tbl+3,x
    sta spawn_ptr
    lda level_tbl+4,x
    sta spawn_ptr+1
    lda level_tbl+5,x
    sta lvl_tileset
    sta chr_r1
    lda level_tbl+8,x
    sta faction
    lda level_tbl+9,x
    sta far_ptr
    lda level_tbl+10,x
    sta far_ptr+1
    lda level_tbl+11,x
    sta stars
    lda level_tbl+6,x
    sta ptr
    lda level_tbl+7,x
    sta ptr+1
    jsr load_palette
    jsr load_char_pal
    ; bancos de sprites
    lda char
    asl
    clc
    adc #32
    sta chr_r2
    lda chr_r1
    ldx #1
    jsr set_bank
    ldx #3
    lda #36
    jsr set_bank
    lda faction
    clc
    adc #37
    ldx #4
    jsr set_bank
    ldx #5
    lda #39
    jsr set_bank
    ; limites de camara
    lda lvl_len
    sta cam_max_lo
    lda #0
    sta cam_max_hi
    ldx #4
@sh:
    asl cam_max_lo
    rol cam_max_hi
    dex
    bne @sh
    dec cam_max_hi
    lda cam_max_lo
    clc
    adc #224
    sta lim_lo
    lda cam_max_hi
    adc #0
    sta lim_hi
    lda #0
    sta cam_lo
    sta cam_hi
    sta tc_lo
    sta tc_hi
    sta boss_state
    sta pveh
    sta col_pending
    sta attr_pending
    sta dead_timer
    sta shoot_cd
    sta hud_bar
    sta shake
    sta dust_t
    sta flash_t
    sta vx
    ldx #0
@ce:
    sta e_type,x
    inx
    cpx #NUM_EN
    bne @ce
    ldx #0
@cb:
    sta pb_on,x
    inx
    cpx #5
    bne @cb
    ldx #0
@cc:
    sta eb_on,x
    inx
    cpx #8
    bne @cc
    jsr clear_nt
    lda #<hud_strs
    ldx #>hud_strs
    jsr draw_ptr
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$5A
    sta PPUADDR
    jsr write_level_num
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$2F
    sta PPUADDR
    jsr write_stars
    lda #$FF
    ldx #0
    ldy #8
    jsr fill_attr
    ; banda lejana en ambas tablas (filas 4-9)
    lda #$20
    jsr draw_far
    lda #$24
    jsr draw_far
    ; atributos fila 1 (filas 4-7) paleta 2
    lda #$AA
    ldx #8
    ldy #8
    jsr fill_attr
    bit PPUSTATUS
    lda #$27
    sta PPUADDR
    lda #$C8
    sta PPUADDR
    ldx #8
    lda #$AA
@a2:
    sta PPUDATA
    dex
    bne @a2
@ic:
    jsr build_column
    jsr nmi_column
    inc tc_lo
    lda tc_lo
    cmp #34
    bne @ic
    lda #3
    sta hp
    jsr respawn
    lda #60
    sta inv
    jsr clear_oam
    lda #ST_PLAY
    sta state
    lda #1
    sta game_irq
    jsr ppu_enable
    rts

draw_far:              ; A = $20 o $24
    sta tmp2
    lda #0
    sta tmp3           ; fila
@row:
    ; direccion = base + (4+fila)*32
    lda tmp3
    clc
    adc #4
    asl
    asl
    asl
    asl
    asl
    sta tmp0
    lda #0
    rol
    ora tmp2
    bit PPUSTATUS
    sta PPUADDR
    lda tmp0
    sta PPUADDR
    lda tmp3
    asl
    asl
    asl
    asl
    sta tmp4           ; offset fila en mapa (16 por fila)
    ldx #2
@rep:
    ldy tmp4
    lda #16
    sta tmp5
@c:
    lda (far_ptr),y
    sta PPUDATA
    iny
    dec tmp5
    bne @c
    dex
    bne @rep
    inc tmp3
    lda tmp3
    cmp #6
    bne @row
    rts

; ---------------------------------------------------------------- columnas
get_col_y:
    cpy lvl_len
    bcs @out
    lda (lvl_ptr),y
    rts
@out:
    lda #$02
    rts

col_gattr:             ; Y = metacol (col_mc) -> A = metafila suelo, tmp7 = metafila palmera
    jsr get_col_y
    sta tmp6
    and #$0F
    beq @p
    sta tmp7
    lda #14
    sec
    sbc tmp7
    sta tmp7
    lda tmp6
    and #$F0
    bne @np
    jsr palm_here
    bcc @np
    lda tmp7
    pha
    sec
    sbc #5
    sta tmp7
    pla
    rts
@np:
    lda tmp7
    pha
    lda #$FF
    sta tmp7
    pla
    rts
@p:
    lda #$FF
    sta tmp7
    lda #13
    rts

palm_here:             ; usa metacol guardada en col_mc -> C=1 si hay palmera
    lda col_mc
    asl
    and #30
    tax
    lda skyline,x
    cmp #30
    beq @y
    clc
    rts
@y:
    sec
    rts

build_column:
    lda tc_lo
    and #31
    clc
    adc #$40
    sta col_addr_lo
    lda tc_lo
    and #32
    lsr
    lsr
    lsr
    ora #$21
    sta col_addr_hi
    lda tc_hi
    lsr
    lda tc_lo
    ror
    sta tmp4
    sta col_mc
    tay
    jsr get_col_y
    sta tmp5
    lda #0
    sta tmp3
    sta tmp8           ; fila superior palmera (0 = no)
    lda tmp5
    and #$0F
    beq @pit
    sta tmp0
    lda #14
    sec
    sbc tmp0
    asl
    sta tmp1
    lda tmp5
    and #$F0
    bne @gp
    jsr palm_here
    bcc @gp
    lda tmp1
    sec
    sbc #10
    sta tmp8
    jmp @gp
@pit:
    lda #26
    sta tmp1
    lda #1
    sta tmp3
@gp:
    lda tmp5
    lsr
    lsr
    lsr
    lsr
    beq @nop
    sta tmp0
    lda #14
    sec
    sbc tmp0
    asl
    jmp @sp
@nop:
    lda #$FF
@sp:
    sta tmp2
    lda tc_lo
    and #31
    tax
    lda skyline,x
    sta tmp6
    and #$7F
    sta tmp9           ; fila techo
    lda tmp6
    and #$80
    sta tmp6           ; estilo
    ldx #0
@row:
    txa
    clc
    adc #10
    sta tmp7
    cmp tmp1
    bcc @notg
    lda tmp3
    bne @water
    lda tmp7
    cmp tmp1
    bne @g2
    lda #T_GTOP
    bne @put
@g2:
    sec
    sbc tmp1
    cmp #1
    bne @g3
    lda #T_GSUB
    bne @put
@g3:
    lda tmp7
    eor tc_lo
    and #1
    clc
    adc #T_G1
    bne @put
@water:
    lda tmp7
    cmp #26
    bne @w2
    lda #T_WTOP
    bne @put
@w2:
    lda #T_WATER
    bne @put
@notg:
    cmp tmp2
    bne @notp
    lda #T_PLAT
    bne @put
@notp:
    lda tmp8
    beq @nopalm
    lda tmp7
    cmp tmp8
    bcc @nopalm
    jsr palm_tile
    jmp @put
@nopalm:
    lda tmp7
    cmp tmp9
    bcc @sky
    bne @bld
    lda #T_ROOF1
    ldy tmp6
    beq @put
    lda #T_ROOF2
    bne @put
@bld:
    lda tmp7
    ora tc_lo
    and #1
    bne @wall
    ; ventana: variante por hash
    lda tmp7
    asl
    adc tc_lo
    adc tmp7
    and #4
    beq @wa
    lda #1
@wa:
    clc
    adc #T_WIN1A
    ldy tmp6
    beq @put
    clc
    adc #4
    bne @put
@wall:
    lda #T_WALL1
    ldy tmp6
    beq @put
    lda #T_WALL2
    bne @put
@sky:
    lda #0
@put:
    sta col_buf,x
    inx
    cpx #20
    beq @rowsdone
    jmp @row
@rowsdone:
    lda tc_lo
    and #3
    bne @noattr
    jsr build_attr
@noattr:
    lda #1
    sta col_pending
    rts

palm_tile:             ; tmp7 fila, tmp8 fila superior -> A tile
    lda tmp7
    sec
    sbc tmp8
    beq @top
    cmp #1
    beq @mid
    lda #T_TR_L
    bne @lr
@top:
    lda #T_P_TL
    bne @lr
@mid:
    lda #T_P_BL
@lr:
    ldy tc_lo
    sta tmp10
    tya
    and #1
    clc
    adc tmp10
    rts

build_attr:
    lda col_addr_hi
    and #$24
    ora #$03
    sta attr_hi
    lda tc_lo
    lsr
    lsr
    and #7
    sta attr_col
    lda tmp4
    sta col_mc
    tay
    jsr col_gattr
    sta tmp0
    lda tmp7
    sta tmp10
    inc col_mc
    ldy col_mc
    jsr col_gattr
    sta tmp1
    lda tmp7
    sta tmp11
    ldx #0
@ar:
    txa
    clc
    adc #2
    asl
    sta tmp2           ; metafila superior
    lda #0
    sta tmp3
    ; TL
    lda tmp2
    ldy tmp0
    sty tmp5
    ldy tmp10
    jsr quad_pal
    sta tmp3
    lda tmp2
    ldy tmp1
    sty tmp5
    ldy tmp11
    jsr quad_pal
    asl
    asl
    ora tmp3
    sta tmp3
    lda tmp2
    clc
    adc #1
    ldy tmp0
    sty tmp5
    ldy tmp10
    jsr quad_pal
    asl
    asl
    asl
    asl
    ora tmp3
    sta tmp3
    lda tmp2
    clc
    adc #1
    ldy tmp1
    sty tmp5
    ldy tmp11
    jsr quad_pal
    asl
    asl
    asl
    asl
    asl
    asl
    ora tmp3
    sta attr_buf,x
    inx
    cpx #6
    bne @ar
    lda #1
    sta attr_pending
    rts

quad_pal:              ; A=metafila, tmp5=inicio suelo, Y=inicio palmera -> A paleta
    cmp #4
    beq @far
    cmp tmp5
    bcs @g
    sty tmp6
    cmp tmp6
    bcs @palm
    lda #0
    rts
@g:
    lda #1
    rts
@far:
@palm:
    lda #2
    rts

stream_columns:
    lda col_pending
    bne @r
    lda cam_hi
    sta tmp1
    lda cam_lo
    lsr tmp1
    ror
    lsr tmp1
    ror
    lsr tmp1
    ror
    clc
    adc #33
    sta tmp0
    lda tmp1
    adc #0
    sta tmp1
    lda tmp0
    cmp tc_lo
    lda tmp1
    sbc tc_hi
    bcc @r
    jsr build_column
    inc tc_lo
    bne @r
    inc tc_hi
@r:
    rts

; ---------------------------------------------------------------- terreno
x_to_mc:
    lda tmp1
    cmp #16
    bcs @big
    asl
    asl
    asl
    asl
    sta tmp2
    lda tmp0
    lsr
    lsr
    lsr
    lsr
    ora tmp2
    rts
@big:
    lda #$FF
    rts

surf_at:               ; tmp0/1 = x -> A = y suelo (FF pozo), tmp3 = y plataforma
    jsr x_to_mc
    tay
    jsr get_col_y
    sta tmp2
    lsr
    lsr
    lsr
    lsr
    beq @np
    asl
    asl
    asl
    asl
    sta tmp3
    lda #224
    sec
    sbc tmp3
    sta tmp3
    jmp @g
@np:
    lda #$FF
    sta tmp3
@g:
    lda tmp2
    and #$0F
    beq @pit
    asl
    asl
    asl
    asl
    sta tmp2
    lda #224
    sec
    sbc tmp2
    rts
@pit:
    lda #$FF
    rts

wall_check:            ; tmp0/1 = x -> C=1 bloqueado (suelo mas alto que pies-4)
    jsr surf_at
    sta tmp2
    lda py
    clc
    adc #28
    bcs @no
    cmp tmp2
    rts
@no:
    clc
    rts

; ---------------------------------------------------------------- juego
st_play:
    lda dead_timer
    beq @alive
    jmp play_dead
@alive:
    jsr player_update
    lda dead_timer
    bne @skip
    jsr camera_update
@skip:
    jsr stream_columns
    jsr spawn_update
    jsr pbullets_update
    jsr bullet_hits
    jsr enemies_update
    jsr ebullets_update
    jsr boss_check
    lda state
    cmp #ST_PLAY
    bne @out
    jsr draw_all
@out:
    rts

play_dead:
    dec dead_timer
    bne @draw
    dec lives
    beq @go
    lda #3
    sta hp
    jsr respawn
    rts
@go:
    jmp gameover_init
@draw:
    jsr enemies_update
    jsr ebullets_update
    jsr draw_all
    rts

respawn:
    lda #0
    sta pveh
    sta vy_lo
    sta vy_hi
    sta vx
    sta onground
    sta pdir
    sta hud_bar
    sta crouch
    lda #120
    sta inv
    ldx #7
    lda #0
@c:
    sta eb_on,x
    dex
    bpl @c
    lda cam_lo
    clc
    adc #32
    sta px_lo
    lda cam_hi
    adc #0
    sta px_hi
    ldx #12
@s:
    lda px_lo
    clc
    adc #8
    sta tmp0
    lda px_hi
    adc #0
    sta tmp1
    jsr surf_at
    cmp #$FF
    bne @ok
    lda px_lo
    clc
    adc #16
    sta px_lo
    bcc @nc
    inc px_hi
@nc:
    dex
    bne @s
    lda #120
@ok:
    sec
    sbc #32
    sta py
    lda #0
    sta py_frac
    rts

; tablas por vehiculo (0 pie, 1 moto, 2 auto)
veh_max:   .byte 24, 52, 62
veh_acc:   .byte 4, 3, 2
veh_fric:  .byte 4, 2, 2
veh_rgt:   .byte 12, 22, 30
veh_lft:   .byte 3, $FA, $F2
veh_jlo:   .byte $80, $C0, $60
veh_jhi:   .byte $F9, $F9, $FA
veh_hpm:   .byte 0, 4, 8
veh_w:     .byte 16, 32, 48
veh_type:  .byte 0, E_MOTO, E_CAR

player_update:
    lda inv
    beq @ni
    dec inv
@ni:
    lda shoot_cd
    beq @ns
    dec shoot_cd
@ns:
    lda flash_t
    beq @nf
    dec flash_t
@nf:
    lda hurt_t
    beq @nh
    dec hurt_t
@nh:
    lda combo_cd
    beq @nc
    dec combo_cd
@nc:
    ; --- A+B: subir/bajar (ambos apretados casi a la vez)
    lda pad_new
    and #BTN_A
    beq @na1
    lda #0
    sta a_age
    beq @na2
@na1:
    lda a_age
    cmp #255
    beq @na2
    inc a_age
@na2:
    lda pad_new
    and #BTN_B
    beq @nb1
    lda #0
    sta b_age
    beq @nb2
@nb1:
    lda b_age
    cmp #255
    beq @nb2
    inc b_age
@nb2:
    lda jump_age
    cmp #255
    beq @ja
    inc jump_age
@ja:
    lda #0
    sta combo_f
    lda pad
    and #BTN_A|BTN_B
    cmp #BTN_A|BTN_B
    bne @nocombo
    lda pad_new
    and #BTN_A|BTN_B
    beq @nocombo
    lda a_age
    cmp #5
    bcs @nocombo
    lda b_age
    cmp #5
    bcs @nocombo
    lda combo_cd
    bne @nocombo
    lda pveh
    beq @tg
    ; bajar: cancelar salto recien iniciado
    lda onground
    bne @tg
    lda jump_age
    cmp #6
    bcs @nocombo
    lda jump_y
    sta py
    lda #0
    sta vy_lo
    sta vy_hi
    lda #1
    sta onground
@tg:
    jsr toggle_vehicle
    bcc @nocombo
    lda #1
    sta combo_f
    lda #12
    sta combo_cd
@nocombo:
    ; barra
    lda pveh
    beq @hb0
    lda veh_hp
    ldx pveh
    cpx #1
    bne @hb
    asl
@hb:
    cmp #9
    bcc @hbs
    lda #8
    bne @hbs
@hb0:
    lda #0
@hbs:
    sta hud_bar
    ; --- agacharse / apuntar
    lda #0
    sta crouch
    sta aim
    lda pveh
    bne @nodown
    lda pad
    and #BTN_DOWN
    beq @nodown
    lda onground
    beq @nodown
    lda #1
    sta crouch
@nodown:
    lda pad
    and #BTN_UP
    beq @noaim
    lda #2
    sta aim
    lda pad
    and #BTN_LEFT|BTN_RIGHT
    beq @noaim
    lda #1
    sta aim
@noaim:
    ; --- velocidad horizontal suave
    ldx pveh
    lda crouch
    bne @fric
    lda pad
    and #BTN_RIGHT
    beq @nr
    lda #0
    sta pdir
    lda vx
    clc
    adc veh_acc,x
    bvs @capr
    cmp veh_max,x
    bmi @setv
@capr:
    lda veh_max,x
    jmp @setv
@nr:
    lda pad
    and #BTN_LEFT
    beq @fric
    lda #1
    sta pdir
    lda veh_max,x
    eor #$FF
    clc
    adc #1
    sta tmp5
    lda vx
    sec
    sbc veh_acc,x
    bvs @capl
    cmp tmp5
    bpl @setv
@capl:
    lda tmp5
    jmp @setv
@fric:
    lda vx
    beq @setv
    bmi @fneg
    sec
    sbc veh_fric,x
    bpl @setv
    lda #0
    beq @setv
@fneg:
    clc
    adc veh_fric,x
    bmi @setv
    lda #0
@setv:
    sta vx
    ; --- aplicar vx (1/16 px) a px (24 bits)
    lda px_lo
    sta tmp6
    lda px_hi
    sta tmp7
    lda px_frac
    sta tmp4
    lda vx
    asl
    asl
    asl
    asl
    sta tmp0
    lda vx
    cmp #$80
    ror
    cmp #$80
    ror
    cmp #$80
    ror
    cmp #$80
    ror
    sta tmp1
    ldy #0
    cmp #$80
    bcc @pos
    dey
@pos:
    lda px_frac
    clc
    adc tmp0
    sta px_frac
    lda px_lo
    adc tmp1
    sta px_lo
    tya
    adc px_hi
    sta px_hi
    ; --- choque con paredes
    lda vx
    beq @nowall
    bmi @wl
    lda veh_rgt,x
    jmp @wx
@wl:
    lda veh_lft,x
@wx:
    ldy #0
    cmp #$80
    bcc @wp
    dey
@wp:
    clc
    adc px_lo
    sta tmp0
    tya
    adc px_hi
    sta tmp1
    jsr wall_check
    bcc @nowall
    lda tmp6
    sta px_lo
    lda tmp7
    sta px_hi
    lda tmp4
    sta px_frac
    lda #0
    sta vx
@nowall:
    ; --- limites: izquierda = camara
    ldx pveh
    lda veh_lft,x
    ldy #0
    cmp #$80
    bcc @lp
    dey
@lp:
    clc
    adc px_lo
    sta tmp0
    tya
    adc px_hi
    sta tmp1
    lda tmp0
    cmp cam_lo
    lda tmp1
    sbc cam_hi
    bcs @lok
    lda cam_lo
    sec
    sbc veh_lft,x
    sta px_lo
    lda cam_hi
    ldy veh_lft,x
    bpl @lpp
    sbc #$FF
    jmp @lps
@lpp:
    sbc #0
@lps:
    sta px_hi
    lda #0
    sta vx
@lok:
    lda px_lo
    cmp lim_lo
    lda px_hi
    sbc lim_hi
    bcc @rok
    lda lim_lo
    sta px_lo
    lda lim_hi
    sta px_hi
    lda #0
    sta vx
@rok:
    ; --- animacion de carrera proporcional a la velocidad
    lda vx
    bpl @ab
    eor #$FF
    clc
    adc #1
@ab:
    sta tmp5
    clc
    adc run_acc
    sta run_acc
    cmp #48
    bcc @na
    sbc #48
    sta run_acc
    inc run_idx
    lda run_idx
    cmp #6
    bcc @na
    lda #0
    sta run_idx
@na:
    lda tmp5
    clc
    adc wheel_acc
    sta wheel_acc
    ; --- salto
    lda pad_new
    and #BTN_A
    beq @nj
    lda combo_f
    bne @nj
@jok:
    lda onground
    beq @nj
    lda crouch
    bne @nj
    ldx pveh
    lda veh_jlo,x
    sta vy_lo
    lda veh_jhi,x
    sta vy_hi
    lda #0
    sta onground
    sta jump_age
    lda py
    sta jump_y
@nj:
    lda pad
    and #BTN_A
    bne @hold
    lda vy_hi
    bpl @hold
    cmp #$FE
    bcs @hold
    lda #$FE
    sta vy_hi
    lda #0
    sta vy_lo
@hold:
    lda vy_lo
    clc
    adc #$58
    sta vy_lo
    lda vy_hi
    adc #0
    sta vy_hi
    bmi @nocap
    cmp #7
    bcc @nocap
    lda #7
    sta vy_hi
    lda #0
    sta vy_lo
@nocap:
    lda py
    clc
    adc #32
    sta pfeet_old
    lda py_frac
    clc
    adc vy_lo
    sta py_frac
    lda py
    adc vy_hi
    sta py
    ; --- aterrizaje
    lda onground
    sta tmp9
    lda #0
    sta onground
    lda vy_hi
    bmi @air
    ldx pveh
    lda probe_l,x
    jsr probe_surf
    sta tmp4
    ldx pveh
    lda probe_r,x
    jsr probe_surf
    cmp tmp4
    bcs @mn
    sta tmp4
@mn:
    lda tmp3
    cmp #$FF
    beq @gnd
    lda py
    clc
    adc #32
    cmp tmp3
    bcc @gnd
    lda pfeet_old
    cmp tmp3
    beq @landp
    bcs @gnd
@landp:
    lda tmp3
    jmp @land
@gnd:
    lda tmp4
    cmp #$FF
    beq @air
    lda py
    clc
    adc #32
    cmp tmp4
    bcc @air
    lda tmp4
@land:
    sec
    sbc #32
    sta py
    lda #0
    sta vy_lo
    sta vy_hi
    sta py_frac
    lda #1
    sta onground
    lda tmp9
    bne @air
    jsr make_dust
@air:
    lda vy_hi
    bmi @nopit
    lda py
    cmp #206
    bcc @nopit
    cmp #240
    bcs @nopit
    lda #0
    sta pveh
    jmp player_die
@nopit:
    ; --- disparo
    lda pad
    and #BTN_B
    beq @nofire
    lda combo_f
    bne @nofire
@fok:
    lda shoot_cd
    bne @nofire
    jsr fire_player
@nofire:
    jsr player_frame
    rts

probe_l: .byte 4, $FC, $F6
probe_r: .byte 12, 20, 26
probe_surf:            ; A = desplazamiento con signo desde px -> surf_at
    ldy #0
    cmp #$80
    bcc @p
    dey
@p:
    clc
    adc px_lo
    sta tmp0
    tya
    adc px_hi
    sta tmp1
    jmp surf_at

make_dust:
    lda #16
    sta dust_t
    lda px_lo
    sta dust_xlo
    lda px_hi
    sta dust_xhi
    lda py
    clc
    adc #26
    sta dust_y
    rts

player_frame:
    lda pveh
    beq @foot
    lda #14
    bne @set
@foot:
    lda hurt_t
    beq @nh
    lda #13
    bne @set
@nh:
    lda onground
    bne @g
    lda vy_hi
    bmi @up
    lda #9
    bne @set
@up:
    lda #8
    bne @set
@g:
    lda crouch
    beq @nc
    lda #10
    bne @set
@nc:
    lda aim
    beq @na
    cmp #2
    beq @au
    lda #12
    bne @set
@au:
    lda #11
    bne @set
@na:
    lda vx
    beq @idle
    lda run_idx
    clc
    adc #2
    bne @set
@idle:
    lda frame
    lsr
    lsr
    lsr
    lsr
    lsr
    and #1
@set:
    sta pframe
    rts

toggle_vehicle:
    lda pveh
    beq @enter
    ; --- bajar: dejar vehiculo estacionado
    lda onground
    bne @ok1
    clc
    rts
@ok1:
    ldx #0
@f:
    lda e_type,x
    beq @got
    inx
    cpx #NUM_EN-1
    bne @f
    clc
    rts
@got:
    ldy pveh
    lda veh_type,y
    sta e_type,x
    lda veh_hp
    sta e_hp,x
    lda veh_w,y
    lsr
    sec
    sbc #8
    sta tmp0
    lda px_lo
    sec
    sbc tmp0
    sta e_xlo,x
    lda px_hi
    sbc #0
    sta e_xhi,x
    lda py
    clc
    adc #16
    sta e_y,x
    lda pdir
    sta e_dir,x
    lda #0
    sta e_anim,x
    sta e_flash,x
    sta pveh
    sta vx
    lda #20
    sta inv
    jsr sfx_shoot
    sec
    rts
@enter:
    ldx #0
@s:
    lda e_type,x
    cmp #E_MOTO
    beq @chk
    cmp #E_CAR
    beq @__n3303_0
    jmp @nx
@__n3303_0:
@chk:
    ; centro jugador vs vehiculo: dx = px+8 - ex  en [0, w)
    ldy #1
    cmp #E_MOTO
    beq @w1
    ldy #2
@w1:
    sty tmp5
    lda px_lo
    clc
    adc #8
    sta tmp0
    lda px_hi
    adc #0
    sta tmp1
    lda tmp0
    sec
    sbc e_xlo,x
    sta tmp0
    lda tmp1
    sbc e_xhi,x
    bne @nx
    lda tmp0
    ldy tmp5
    cmp veh_w,y
    bcs @nx
    lda py
    clc
    adc #16
    sec
    sbc e_y,x
    clc
    adc #12
    cmp #24
    bcs @nx
    ; subir
    lda tmp5
    sta pveh
    lda e_hp,x
    sta veh_hp
    lda e_dir,x
    sta pdir
    lda #0
    sta e_type,x
    sta vx
    ldy tmp5
    lda veh_w,y
    lsr
    sec
    sbc #8
    clc
    adc e_xlo,x
    sta px_lo
    lda e_xhi,x
    adc #0
    sta px_hi
    lda e_y,x
    sec
    sbc #16
    sta py
    lda #0
    sta vy_lo
    sta vy_hi
    lda #10
    sta inv
    jsr sfx_power
    sec
    rts
@nx:
    inx
    cpx #NUM_EN
    beq @nf
    jmp @s
@nf:
    clc
    rts

fire_player:
    ldx #4
@f:
    lda pb_on,x
    beq @got
    dex
    bpl @f
    rts
@got:
    lda #8
    sta shoot_cd
    lda #4
    sta flash_t
    lda #1
    sta pb_on,x
    ; direccion
    lda #0
    sta pb_dy,x
    lda aim
    cmp #2
    bne @nup
    lda #0
    sta pb_dx,x
    lda #$FA
    sta pb_dy,x
    lda px_lo
    clc
    adc #9
    sta pb_xlo,x
    lda px_hi
    adc #0
    sta pb_xhi,x
    lda py
    sta pb_y,x
    jmp sfx_shoot
@nup:
    cmp #1
    bne @hz
    lda #$FB
    sta pb_dy,x
    lda #5
    ldy pdir
    beq @d1
    lda #$FB
@d1:
    sta pb_dx,x
    jmp @pos
@hz:
    lda #7
    ldy pdir
    beq @d2
    lda #$F9
@d2:
    sta pb_dx,x
@pos:
    ; x
    lda pdir
    bne @pl
    lda px_lo
    clc
    adc #14
    sta pb_xlo,x
    lda px_hi
    adc #0
    sta pb_xhi,x
    jmp @py
@pl:
    lda px_lo
    sec
    sbc #6
    sta pb_xlo,x
    lda px_hi
    sbc #0
    sta pb_xhi,x
@py:
    lda py
    clc
    adc #9
    ldy crouch
    beq @c1
    clc
    adc #7
@c1:
    ldy pveh
    cpy #2
    bne @c2
    clc
    adc #10
@c2:
    sta pb_y,x
    jmp sfx_shoot

player_hurt:           ; preserva X
    lda inv
    bne @r
    lda dead_timer
    bne @r
    lda pveh
    beq @foot
    dec veh_hp
    lda #40
    sta inv
    lda #4
    sta shake
    lda veh_hp
    bne @snd
    ; vehiculo destruido
    txa
    pha
    jsr veh_explode
    pla
    tax
    rts
@snd:
    jmp sfx_hit
@foot:
    lda #20
    sta hurt_t
    dec hp
    beq player_die
    lda #90
    sta inv
    jmp sfx_hit
@r:
    rts

veh_explode:
    ldx #0
@f:
    lda e_type,x
    beq @got
    inx
    cpx #NUM_EN-1
    bne @f
    jmp @noex
@got:
    lda #E_EXPL
    sta e_type,x
    lda px_lo
    sta e_xlo,x
    lda px_hi
    sta e_xhi,x
    lda py
    clc
    adc #12
    sta e_y,x
    lda #18
    sta e_tm,x
@noex:
    lda #0
    sta pveh
    lda #$FB
    sta vy_hi
    lda #0
    sta vy_lo
    sta onground
    lda #90
    sta inv
    lda #20
    sta hurt_t
    lda #10
    sta shake
    jmp sfx_boom

player_die:
    lda #0
    sta hp
    sta pveh
    sta hud_bar
    lda #110
    sta dead_timer
    lda #8
    sta shake
    jmp sfx_boom

camera_update:
    ; objetivo = px - 112 (mas adelante en vehiculo)
    lda #112
    ldx pveh
    beq @t
    lda #88
@t:
    sta tmp2
    lda px_lo
    sec
    sbc tmp2
    sta tmp0
    lda px_hi
    sbc #0
    sta tmp1
    bmi @r
    lda tmp0
    cmp cam_max_lo
    lda tmp1
    sbc cam_max_hi
    bcc @lim
    lda cam_max_lo
    sta tmp0
    lda cam_max_hi
    sta tmp1
@lim:
    ; diff = objetivo - cam
    lda tmp0
    sec
    sbc cam_lo
    sta tmp2
    lda tmp1
    sbc cam_hi
    bmi @r
    bne @big
    lda tmp2
    beq @r
    lsr
    lsr
    clc
    adc #1
    cmp #7
    bcc @add
@big:
    lda #7
@add:
    clc
    adc cam_lo
    sta cam_lo
    bcc @r
    inc cam_hi
@r:
    rts

; ---------------------------------------------------------------- aparicion
spawn_update:
    ldy #0
    lda (spawn_ptr),y
    cmp #$FF
    beq @r
    sta tmp4
    lda cam_lo
    clc
    adc #$10
    sta tmp0
    lda cam_hi
    adc #1
    sta tmp1
    jsr x_to_mc
    cmp tmp4
    bcc @r
    ldx #0
@f:
    lda e_type,x
    beq @got
    inx
    cpx #NUM_EN-1
    bne @f
    jmp @adv
@got:
    ldy #1
    lda (spawn_ptr),y
    sta e_type,x
    iny
    lda (spawn_ptr),y
    sta e_y,x
    lda tmp4
    asl
    asl
    asl
    asl
    sta e_xlo,x
    lda tmp4
    lsr
    lsr
    lsr
    lsr
    sta e_xhi,x
    lda #0
    sta e_dir,x
    sta e_anim,x
    sta e_flash,x
    sta e_state,x
    sta e_vx,x
    sta e_vy,x
    jsr rand
    and #63
    clc
    adc #30
    sta e_tm,x
    lda e_type,x
    tay
    lda spawn_hp-1,y
    clc
    adc faction
    sta e_hp,x
@adv:
    lda spawn_ptr
    clc
    adc #3
    sta spawn_ptr
    bcc @r
    inc spawn_ptr+1
@r:
    rts
spawn_hp: .byte 1, 2, 4, 30, 0, 8, 6, 0, 1

; ---------------------------------------------------------------- balas jugador
pbullets_update:
    ldx #4
@l:
    lda pb_on,x
    beq @n
    ldy #0
    lda pb_dx,x
    bpl @p
    dey
@p:
    clc
    adc pb_xlo,x
    sta pb_xlo,x
    tya
    adc pb_xhi,x
    sta pb_xhi,x
    lda pb_y,x
    clc
    adc pb_dy,x
    sta pb_y,x
    cmp #28
    bcc @kill
    cmp #232
    bcs @kill
    lda pb_xlo,x
    sec
    sbc cam_lo
    lda pb_xhi,x
    sbc cam_hi
    beq @n
@kill:
    lda #0
    sta pb_on,x
@n:
    dex
    bpl @l
    rts

; caja de colision por tipo: ancho, alto, desplazamiento y
hit_w:  .byte 16, 16, 0, 48, 0, 0, 48, 0, 16
hit_h:  .byte 30, 18, 0, 16, 0, 0, 16, 0, 16
hit_oy: .byte 2, 14, 0, 8, 0, 0, 0, 0, 0

bullet_hits:
    ldx #4
@b:
    lda pb_on,x
    bne @act
    jmp @nb
@act:
    stx tmp10
    ldy #0
@e:
    lda e_type,y
    beq @ne
    cmp #E_COP
    beq @ok
    cmp #E_CROUCH
    beq @ok
    cmp #E_BOSS
    beq @ok
    cmp #E_POLCAR
    bne @ne
@ok:
    sty tmp11
    tay
    lda hit_w-1,y
    sta tw
    lda hit_h-1,y
    sta th
    lda hit_oy-1,y
    sta tmp5
    ldy tmp11
    lda pb_xlo,x
    clc
    adc #3
    sta tmp0
    lda pb_xhi,x
    adc #0
    sta tmp1
    lda tmp0
    sec
    sbc e_xlo,y
    sta tmp0
    lda tmp1
    sbc e_xhi,y
    bne @ne
    lda tmp0
    cmp tw
    bcs @ne
    lda e_y,y
    clc
    adc tmp5
    sta tmp5
    lda pb_y,x
    clc
    adc #3
    sec
    sbc tmp5
    bcc @ne
    cmp th
    bcs @ne
    jmp @hit
@ne:
    iny
    cpy #NUM_EN
    bne @e
    jmp @nb
@hit:
    lda #0
    sta pb_on,x
    lda #6
    sta e_flash,y
    lda e_hp,y
    sec
    sbc #1
    sta e_hp,y
    beq @kill
    bcc @kill
    jsr sfx_hit
    jmp @nb
@kill:
    lda pb_dx,x
    sta tmp5
    tya
    tax
    lda tmp5
    jsr kill_enemy
    ldx tmp10
@nb:
    dex
    bmi @done
    jmp @b
@done:
    rts

kill_enemy:            ; X = slot, A = dx del impacto (direccion de caida)
    sta tmp5
    lda e_type,x
    cmp #E_BOSS
    bne @nb
    jmp boss_dead
@nb:
    cmp #E_POLCAR
    bne @cop
    lda #5
    ldy #3
    jsr add_score
    lda #4
    sta shake
    jmp make_expl
@cop:
    lda #1
    ldy #3
    jsr add_score
    lda #E_DYING
    sta e_type,x
    lda #$FD
    sta e_vy,x
    lda #1
    ldy tmp5
    bpl @r
    lda #$FF
@r:
    sta e_vx,x
    lda #48
    sta e_tm,x
    jmp sfx_hit

make_expl:             ; convierte slot X en explosion centrada
    lda #E_EXPL
    sta e_type,x
    lda e_xlo,x
    clc
    adc #16
    sta e_xlo,x
    lda e_xhi,x
    adc #0
    sta e_xhi,x
    lda #18
    sta e_tm,x
    jmp sfx_boom

boss_dead:
    lda #5
    ldy #2
    jsr add_score
    lda #2
    sta boss_state
    lda #160
    sta clear_timer
    lda #40
    sta shake
    ldy #7
    lda #0
@cb:
    sta eb_on,y
    dey
    bpl @cb
    jmp make_expl

; ---------------------------------------------------------------- enemigos
enemies_update:
    ldx #0
eu_loop:
    lda e_type,x
    bne @has
    jmp en_done
@has:
    lda e_xlo,x
    sec
    sbc cam_lo
    sta tmp8
    lda e_xhi,x
    sbc cam_hi
    sta tmp9
    bpl @onr
    lda tmp8
    cmp #$C0
    bcs @onr
    lda #0
    sta e_type,x
    jmp en_done
@onr:
    lda e_flash,x
    beq @nf
    dec e_flash,x
@nf:
    lda e_type,x
    asl
    tay
    lda en_tbl-1,y
    pha
    lda en_tbl-2,y
    pha
    rts
en_tbl:
    .word en_cop-1, en_crouch-1, en_parked-1, en_boss-1, en_expl-1, en_parked-1, en_polcar-1, en_dying-1, en_bag-1

; los manejadores terminan con jmp en_done
en_done:
    inx
    cpx #NUM_EN
    beq @r
    jmp eu_loop
@r:
    rts

face_player:
    lda px_lo
    cmp e_xlo,x
    lda px_hi
    sbc e_xhi,x
    lda #0
    bcs @r
    lda #1
@r:
    sta e_dir,x
    rts

; jugador (caja) vs entidad: tw/th tamano entidad, tmp5 desplazamiento y
touch_test:
    ldy pveh
    lda veh_lft,y
    pha
    clc
    adc px_lo
    sta tmp0
    pla
    and #$80
    beq @p
    lda #$FF
@p:
    adc px_hi
    sta tmp1
    ; dx = ex + tw - pleft  en [0, tw + pw)
    lda e_xlo,x
    clc
    adc tw
    sta tmp2
    lda e_xhi,x
    adc #0
    sta tmp3
    lda tmp2
    sec
    sbc tmp0
    sta tmp2
    lda tmp3
    sbc tmp1
    bne @no
    ldy pveh
    lda veh_rgt,y
    sec
    sbc veh_lft,y
    clc
    adc tw
    cmp tmp2
    bcc @no
    beq @no
    ; vertical: dy = ey + oy + th - (py+top)  en [0, th + ph)
    lda py
    clc
    adc #6
    ldy crouch
    beq @nc
    adc #10
@nc:
    ldy pveh
    beq @nv
    adc #8
@nv:
    sta tmp0
    lda e_y,x
    clc
    adc tmp5
    adc th
    sec
    sbc tmp0
    bcc @no
    sta tmp2
    lda #32
    sec
    sbc tmp0
    clc
    adc py
    clc
    adc th
    cmp tmp2
    bcc @no
    sec
    rts
@no:
    clc
    rts

contact:               ; contacto cuerpo a cuerpo con policia
    lda #12
    sta tw
    lda #26
    sta th
    lda #4
    sta tmp5
    jsr touch_test
    bcc @r
    lda pveh
    beq @hurt
    lda #8
    sta shake
    lda vx
    jmp kill_enemy
@hurt:
    jmp player_hurt
@r:
    rts

on_ground_ahead:       ; X slot, A desplazamiento x -> A = y suelo
    clc
    adc e_xlo,x
    sta tmp0
    lda e_xhi,x
    adc #0
    sta tmp1
    jmp surf_at

en_cop:
    jsr contact
    lda e_type,x
    cmp #E_COP
    beq @alive
    jmp en_done
@alive:
    lda e_vx,x
    beq @nocd
    dec e_vx,x
@nocd:
    lda e_state,x
    beq @run
    ; --- apuntando
    dec e_tm,x
    lda e_tm,x
    cmp #14
    bne @nf
    lda tmp9
    bne @nf
    jsr enemy_fire
@nf:
    lda e_tm,x
    bne @dn
    lda #0
    sta e_state,x
    jsr rand
    and #63
    adc #50
    sta e_vx,x
@dn:
    jmp en_done
@run:
    jsr face_player
    ; distancia
    lda e_vx,x
    bne @mv
    lda tmp9
    bne @mv
    lda e_xlo,x
    sec
    sbc px_lo
    bcs @ad
    eor #$FF
    adc #1
@ad:
    cmp #96
    bcs @mv
    lda #1
    sta e_state,x
    lda #36
    sec
    sbc faction
    sbc faction
    sbc faction
    sta e_tm,x
    jmp en_done
@mv:
    ; avanza 1 px (militar 1.5)
    lda faction
    bne @go
    lda frame
    and #3
    beq @dn2
@go:
    inc e_anim,x
    lda e_dir,x
    bne @ml
    lda #15
    jsr on_ground_ahead
    sta tmp2
    lda e_y,x
    clc
    adc #32
    cmp tmp2
    bne @stop
    inc e_xlo,x
    bne @dn2
    inc e_xhi,x
    jmp en_done
@ml:
    lda #0
    jsr on_ground_ahead
    sta tmp2
    lda e_y,x
    clc
    adc #32
    cmp tmp2
    bne @stop
    lda e_xlo,x
    bne @d2
    dec e_xhi,x
@d2:
    dec e_xlo,x
@dn2:
    jmp en_done
@stop:
    lda e_vx,x
    beq @dn2
    lda #0
    sta e_vx,x
    jmp en_done

en_crouch:
    jsr contact
    lda e_type,x
    cmp #E_CROUCH
    bne @r
    jsr face_player
    dec e_tm,x
    bne @r
    lda #80
    sec
    sbc level
    sbc level
    sbc level
    sbc level
    sta e_tm,x
    lda tmp9
    bne @r
    jsr enemy_fire
@r:
    jmp en_done

en_parked:
    inc e_anim,x
    jmp en_done

en_bag:
    inc e_anim,x
    lda #16
    sta tw
    sta th
    lda #0
    sta tmp5
    jsr touch_test
    bcc @r
    lda #0
    sta e_type,x
    lda #1
    ldy #2
    jsr add_score
    jsr sfx_power
@r:
    jmp en_done

en_expl:
    dec e_tm,x
    bne @r
    lda #0
    sta e_type,x
@r:
    jmp en_done

en_dying:
    inc e_anim,x
    ; movimiento
    lda e_vx,x
    ldy #0
    cmp #$80
    bcc @p
    dey
@p:
    clc
    adc e_xlo,x
    sta e_xlo,x
    tya
    adc e_xhi,x
    sta e_xhi,x
    lda e_y,x
    clc
    adc e_vy,x
    sta e_y,x
    lda e_anim,x
    and #3
    bne @ng
    inc e_vy,x
@ng:
    ; suelo
    lda e_vy,x
    bmi @air
    lda #8
    jsr on_ground_ahead
    cmp #$FF
    beq @air
    sta tmp2
    lda e_y,x
    clc
    adc #32
    cmp tmp2
    bcc @air
    lda tmp2
    sec
    sbc #32
    sta e_y,x
    lda #0
    sta e_vy,x
    sta e_vx,x
@air:
    lda e_y,x
    cmp #224
    bcs @kill
    dec e_tm,x
    bne @r
@kill:
    lda #0
    sta e_type,x
@r:
    jmp en_done

en_polcar:
    ; arranca cuando entra en pantalla
    lda e_state,x
    bne @drive
    lda tmp9
    bne @r0
    lda tmp8
    cmp #232
    bcs @r0
    lda #1
    sta e_state,x
@r0:
    jmp en_done
@drive:
    inc e_anim,x
    ; contacto
    lda #48
    sta tw
    lda #16
    sta th
    lda #0
    sta tmp5
    jsr touch_test
    bcc @nt
    lda pveh
    beq @foot
    ; choque de vehiculos
    lda inv
    bne @nt
    jsr player_hurt
    lda e_hp,x
    sec
    sbc #3
    sta e_hp,x
    beq @boom
    bcc @boom
    lda #$E0
    sta vx
    lda #20
    sta e_vx,x
    jmp @nt
@boom:
    lda #0
    jmp kill_enemy_done
@foot:
    jsr player_hurt
@nt:
    ; velocidad: -2 px (o retroceso)
    lda e_vx,x
    beq @fw
    dec e_vx,x
    lda e_xlo,x
    clc
    adc #1
    sta e_xlo,x
    bcc @ter
    inc e_xhi,x
    jmp @ter
@fw:
    lda e_xlo,x
    sec
    sbc #2
    sta e_xlo,x
    bcs @ter
    dec e_xhi,x
@ter:
    ; terreno bajo el centro
    lda #24
    jsr on_ground_ahead
    cmp #$FF
    beq @fall
    sec
    sbc #16
    sta e_y,x
    jmp en_done
@fall:
    lda e_y,x
    clc
    adc #4
    sta e_y,x
    cmp #220
    bcc @r
    lda #0
    sta e_type,x
@r:
    jmp en_done

kill_enemy_done:
    jsr kill_enemy
    jmp en_done

en_boss:
    inc e_anim,x
    lda #48
    sta tw
    lda #16
    sta th
    lda #8
    sta tmp5
    jsr touch_test
    bcc @nt
    jsr player_hurt
@nt:
    ; entrada desde la derecha
    lda e_state,x
    bne @hover
    lda e_xlo,x
    sec
    sbc #1
    sta e_xlo,x
    bcs @e1
    dec e_xhi,x
@e1:
    lda tmp8
    sec
    sbc #1
    cmp #176
    bcs @r
    lda #1
    sta e_state,x
@r:
    jmp en_done
@hover:
    ; y = 64 + seno
    inc boss_t
    lda boss_t
    lsr
    and #31
    tay
    lda sine32,y
    clc
    adc #56
    sta e_y,x
    ; x oscila lento
    lda boss_t
    and #127
    cmp #64
    bcc @fwd
    lda frame
    and #1
    bne @fire
    lda e_xlo,x
    clc
    adc #1
    sta e_xlo,x
    bcc @fire
    inc e_xhi,x
    jmp @fire
@fwd:
    lda frame
    and #1
    bne @fire
    lda e_xlo,x
    sec
    sbc #1
    sta e_xlo,x
    bcs @fire
    dec e_xhi,x
@fire:
    dec e_tm,x
    bne @r
    lda #64
    sec
    sbc level
    sbc level
    sbc level
    sta e_tm,x
    lda e_xlo,x
    sta tmp10
    lda e_xhi,x
    sta tmp11
    lda e_y,x
    clc
    adc #12
    sta eb_y_t
    lda #$FD
    sta eb_dx_t
    lda #$FF
    sta eb_dy_t
    jsr spawn_eb
    lda #0
    sta eb_dy_t
    jsr spawn_eb
    lda #1
    sta eb_dy_t
    jsr spawn_eb
    lda boss_t
    and #64
    beq @nf2
    lda #2
    sta eb_dy_t
    jsr spawn_eb
@nf2:
    jsr sfx_hit
    jmp en_done

sine32:
    .byte 32,38,44,49,54,58,61,63,64,63,61,58,54,49,44,38
    .byte 32,26,20,15,10,6,3,1,0,1,3,6,10,15,20,26

enemy_fire:            ; X slot -> bala apuntada
    lda e_xlo,x
    clc
    adc #6
    ldy e_dir,x
    bne @l
    adc #8
@l:
    sta tmp10
    lda e_xhi,x
    adc #0
    sta tmp11
    lda e_y,x
    clc
    adc #10
    ldy e_type,x
    cpy #E_CROUCH
    bne @ny
    adc #7
@ny:
    sta eb_y_t
    lda #2
    ldy e_dir,x
    beq @dx
    lda #$FE
@dx:
    sta eb_dx_t
    lda #0
    sta eb_dy_t
    lda py
    clc
    adc #16
    sta tmp2
    lda eb_y_t
    sec
    sbc tmp2
    bcs @pos
    eor #$FF
    adc #1
    cmp #24
    bcc @go
    lda #1
    sta eb_dy_t
    jmp @go
@pos:
    cmp #24
    bcc @go
    lda #$FF
    sta eb_dy_t
@go:
    jmp spawn_eb

spawn_eb:
    ldy #0
@f:
    lda eb_on,y
    beq @got
    iny
    cpy #8
    bne @f
    rts
@got:
    lda #1
    sta eb_on,y
    lda tmp10
    sta eb_xlo,y
    lda tmp11
    sta eb_xhi,y
    lda eb_y_t
    sta eb_y,y
    lda eb_dx_t
    sta eb_dx,y
    lda eb_dy_t
    sta eb_dy,y
    rts

ebullets_update:
    ldx #7
@l:
    lda eb_on,x
    bne @act
    jmp @n
@act:
    ldy #0
    lda eb_dx,x
    bpl @p
    dey
@p:
    clc
    adc eb_xlo,x
    sta eb_xlo,x
    tya
    adc eb_xhi,x
    sta eb_xhi,x
    lda eb_y,x
    clc
    adc eb_dy,x
    sta eb_y,x
    cmp #28
    bcs @__n4495_2
    jmp @kill
@__n4495_2:
    cmp #232
    bcc @__n4499_3
    jmp @kill
@__n4499_3:
    lda eb_xlo,x
    sec
    sbc cam_lo
    lda eb_xhi,x
    sbc cam_hi
    beq @__n4507_4
    jmp @kill
@__n4507_4:
    lda dead_timer
    beq @__n4511_5
    jmp @n
@__n4511_5:
    ; impacto con jugador: caja segun vehiculo
    ldy pveh
    lda eb_xlo,x
    clc
    adc #3
    sta tmp0
    lda eb_xhi,x
    adc #0
    sta tmp1
    lda veh_lft,y
    pha
    clc
    adc px_lo
    sta tmp2
    pla
    and #$80
    beq @pp
    lda #$FF
@pp:
    adc px_hi
    sta tmp3
    lda tmp0
    sec
    sbc tmp2
    sta tmp0
    lda tmp1
    sbc tmp3
    bne @n
    ldy pveh
    lda veh_rgt,y
    sec
    sbc veh_lft,y
    cmp tmp0
    bcc @n
    ; vertical
    lda py
    clc
    adc #4
    ldy crouch
    beq @c
    adc #12
@c:
    ldy pveh
    cpy #2
    bne @c2
    adc #12
@c2:
    sta tmp2
    lda eb_y,x
    clc
    adc #3
    sec
    sbc tmp2
    bcc @n
    sta tmp3
    lda py
    clc
    adc #32
    sec
    sbc tmp2
    cmp tmp3
    bcc @n
    lda #0
    sta eb_on,x
    txa
    pha
    jsr player_hurt
    pla
    tax
    jmp @n
@kill:
    lda #0
    sta eb_on,x
@n:
    dex
    bmi @done
    jmp @l
@done:
    rts

boss_check:
    lda boss_state
    bne @s
    lda cam_lo
    cmp cam_max_lo
    bne @r
    lda cam_hi
    cmp cam_max_hi
    bne @r
    ldx #NUM_EN-1
    lda #E_BOSS
    sta e_type,x
    lda cam_lo
    clc
    adc #250
    sta e_xlo,x
    lda cam_hi
    adc #0
    sta e_xhi,x
    lda #60
    sta e_y,x
    lda level
    asl
    asl
    clc
    adc #28
    sta e_hp,x
    lda #90
    sta e_tm,x
    lda #0
    sta e_state,x
    sta e_flash,x
    lda #1
    sta boss_state
    lda #2
    jmp mus_play
@r:
    rts
@s:
    cmp #2
    bne @r
    ; explosiones extra
    lda clear_timer
    and #15
    bne @ne
    lda clear_timer
    cmp #80
    bcc @ne
    ldx #0
@f:
    lda e_type,x
    beq @g
    inx
    cpx #NUM_EN
    bne @f
    jmp @ne
@g:
    lda #E_EXPL
    sta e_type,x
    jsr rand
    and #63
    clc
    adc cam_lo
    adc #140
    sta e_xlo,x
    lda cam_hi
    adc #0
    sta e_xhi,x
    jsr rand
    and #63
    adc #50
    sta e_y,x
    lda #18
    sta e_tm,x
    jsr sfx_boom
@ne:
    dec clear_timer
    bne @r
    jmp level_clear

; ---------------------------------------------------------------- sprites
draw_all:
    jsr clear_oam
    jsr draw_player
    jsr draw_pbullets
    jsr draw_dust
    ; enemigos con rotacion (parpadeo justo)
    lda en_rot
    clc
    adc #3
    cmp #NUM_EN
    bcc @ok
    sbc #NUM_EN
@ok:
    sta en_rot
    sta tmp11
    lda #NUM_EN
    sta tmp7
@el:
    ldx tmp11
    jsr draw_enemy
    inc tmp11
    lda tmp11
    cmp #NUM_EN
    bcc @nw
    lda #0
    sta tmp11
@nw:
    dec tmp7
    bne @el
    jsr draw_ebullets
    rts

put_spr:               ; tmp0 x, tmp1 y, tmp2 tile, tmp3 atributo
    lda oam_full
    bne @r
    ldy oam_i
    lda tmp1
    sta OAM,y
    lda tmp2
    sta OAM+1,y
    lda tmp3
    sta OAM+2,y
    lda tmp0
    sta OAM+3,y
    tya
    clc
    adc #4
    sta oam_i
    bne @r
    inc oam_full
@r:
    rts

draw_meta:             ; spr_xlo/xhi, spr_y, spr_tile, spr_w, spr_h, spr_attr, spr_attr2/spr_split
    lda oam_full
    beq @go
    rts
@go:
    lda #0
    sta dm_r
    sta dm_rb
    lda spr_y
    sta dm_y
@row:
    lda #0
    sta dm_c
    lda spr_xlo
    sta dm_xl
    lda spr_xhi
    sta dm_xh
@col:
    lda dm_xh
    bne @skip
    lda dm_y
    cmp #232
    bcs @skip
    lda spr_attr
    and #$40
    beq @nf
    lda spr_w
    sec
    sbc #1
    sec
    sbc dm_c
    jmp @tc
@nf:
    lda dm_c
@tc:
    clc
    adc dm_rb
    clc
    adc spr_tile
    ldy oam_i
    sta OAM+1,y
    lda dm_y
    sec
    sbc #1
    sta OAM,y
    lda dm_r
    cmp spr_split
    lda spr_attr
    bcc @a1
    lda spr_attr2
@a1:
    sta OAM+2,y
    lda dm_xl
    sta OAM+3,y
    tya
    clc
    adc #4
    sta oam_i
    bne @skip
    inc oam_full
    rts
@skip:
    lda dm_xl
    clc
    adc #8
    sta dm_xl
    bcc @nc
    inc dm_xh
@nc:
    inc dm_c
    lda dm_c
    cmp spr_w
    bne @col
    lda dm_y
    clc
    adc #8
    sta dm_y
    lda dm_rb
    clc
    adc spr_w
    sta dm_rb
    inc dm_r
    lda dm_r
    cmp spr_h
    beq @__n4812_6
    jmp @row
@__n4812_6:
    rts

world_to_screen:       ; tmp0/tmp1 = x mundo -> spr_xlo/xhi
    lda tmp0
    sec
    sbc cam_lo
    sta spr_xlo
    lda tmp1
    sbc cam_hi
    sta spr_xhi
    rts

draw_player:
    lda px_lo
    sta tmp0
    lda px_hi
    sta tmp1
    jsr world_to_screen
    lda dead_timer
    beq @alive
    cmp #70
    bcc @corpse
    ; explosion / caida
    lda py
    clc
    adc #12
    sta spr_y
    lda #M_EXPL+4
    sta spr_tile
    lda #2
    sta spr_w
    sta spr_h
    lda #3
    sta spr_attr
    lda #$FF
    sta spr_split
    jmp draw_meta
@corpse:
    lda #15
    sta pframe
    jmp @draw
@alive:
    lda inv
    beq @vis
    lda hurt_t
    bne @vis
    lda frame
    and #2
    beq @vis
    rts
@vis:
    lda pveh
    cmp #2
    bne @nocar
    jmp draw_car
@nocar:
    cmp #1
    bne @draw
    jmp draw_moto
@draw:
    ; banco R2 y tile del cuadro
    lda pframe
    lsr
    lsr
    lsr
    sta tmp0
    lda char
    asl
    clc
    adc #32
    adc tmp0
    sta chr_r2
    lda pframe
    and #7
    asl
    asl
    asl
    sta spr_tile
    lda py
    sta spr_y
    lda #2
    sta spr_w
    lda #4
    sta spr_h
    lda #0
    ldx pdir
    beq @f
    lda #$40
@f:
    sta spr_attr
    ora #1
    sta spr_attr2
    ldx pframe
    lda pal_split,x
    sta spr_split
    jsr draw_meta
    ; fogonazo
    lda flash_t
    beq @r
    lda pveh
    bne @r
    lda spr_xhi
    bne @r
    lda aim
    cmp #2
    beq @fu
    lda pdir
    bne @fl
    lda spr_xlo
    clc
    adc #15
    bcs @r
    jmp @fx
@fl:
    lda spr_xlo
    sec
    sbc #7
    bcc @r
@fx:
    sta tmp0
    lda py
    clc
    adc #9
    ldx crouch
    beq @fy
    adc #7
@fy:
    sta tmp1
    lda #M_FLASH
    sta tmp2
    lda pdir
    beq @fa
    lda #$40
@fa:
    ora #3
    sta tmp3
    jmp put_spr
@fu:
    lda spr_xlo
    clc
    adc #6
    sta tmp0
    lda py
    sec
    sbc #8
    sta tmp1
    lda #M_FLASH
    sta tmp2
    lda #3
    sta tmp3
    jmp put_spr
@r:
    rts
pal_split:
    .byte 2,2,2,2,2,2,2,2,2,2,3,2,2,2,2,3

draw_moto:
    lda char
    asl
    clc
    adc #33
    sta chr_r2
    lda py
    sta spr_y
    lda spr_xlo
    sec
    sbc #8
    sta spr_xlo
    lda spr_xhi
    sbc #0
    sta spr_xhi
    lda wheel_acc
    lsr
    lsr
    lsr
    lsr
    sta veh_anim
    jmp draw_rider_at

draw_car:
    lda spr_xlo
    sec
    sbc #16
    sta spr_xlo
    lda spr_xhi
    sbc #0
    sta spr_xhi
    lda py
    clc
    adc #16
    sta spr_y
    lda frame
    and #4
    beq @a
    lda vx
    beq @a
    lda #12
@a:
    clc
    adc #V_CAR
    sta spr_tile
    lda #6
    sta spr_w
    lda #2
    sta spr_h
    lda #3
    ldx pdir
    beq @f
    lda #$43
@f:
    sta spr_attr
    lda #$FF
    sta spr_split
    jmp draw_meta

draw_dust:
    lda dust_t
    beq @r
    dec dust_t
    lda dust_xlo
    sta tmp0
    lda dust_xhi
    sta tmp1
    jsr world_to_screen
    lda dust_y
    sta spr_y
    lda #M_DUST
    sta spr_tile
    lda #2
    sta spr_w
    lda #1
    sta spr_h
    lda #3
    sta spr_attr
    lda #$FF
    sta spr_split
    jmp draw_meta
@r:
    rts

draw_pbullets:
    ldx #4
@l:
    lda pb_on,x
    beq @n
    lda pb_xlo,x
    sec
    sbc cam_lo
    sta tmp0
    lda pb_xhi,x
    sbc cam_hi
    bne @n
    lda pb_y,x
    sta tmp1
    lda #M_PB
    sta tmp2
    lda #3
    sta tmp3
    jsr put_spr
@n:
    dex
    bpl @l
    rts

draw_ebullets:
    ldx #7
@l:
    lda eb_on,x
    beq @n
    lda eb_xlo,x
    sec
    sbc cam_lo
    sta tmp0
    lda eb_xhi,x
    sbc cam_hi
    bne @n
    lda eb_y,x
    sta tmp1
    lda #M_EB
    sta tmp2
    lda #3
    sta tmp3
    jsr put_spr
@n:
    dex
    bpl @l
    rts

draw_enemy:            ; X = slot
    lda e_type,x
    bne @d
    rts
@d:
    stx tmp10
    lda e_xlo,x
    sta tmp0
    lda e_xhi,x
    sta tmp1
    jsr world_to_screen
    lda e_y,x
    sta spr_y
    lda #$FF
    sta spr_split
    lda e_type,x
    asl
    tay
    lda dr_tbl-1,y
    pha
    lda dr_tbl-2,y
    pha
    rts
dr_tbl:
    .word dr_cop-1, dr_crouch-1, dr_moto-1, dr_boss-1, dr_expl-1, dr_car-1, dr_polcar-1, dr_dying-1, dr_bag-1

dr_human:              ; A = cuadro (0-7) del banco enemigo
    asl
    asl
    asl
    clc
    adc #$80
    sta spr_tile
    lda #2
    sta spr_w
    lda #4
    sta spr_h
    lda e_dir,x
    beq @nf
    lda #$40
@nf:
    ora #2
    ldy e_flash,x
    beq @nfl
    eor #1
@nfl:
    sta spr_attr
    jmp draw_meta

dr_cop:
    lda e_state,x
    beq @run
    lda #4
    jmp dr_human
@run:
    lda e_anim,x
    lsr
    lsr
    lsr
    and #3
    jmp dr_human
dr_crouch:
    lda #5
    jmp dr_human
dr_dying:
    lda e_tm,x
    cmp #16
    bcs @v
    lda frame
    and #2
    beq @v
    rts
@v:
    lda #6
    ldy e_vy,x
    bmi @a
    lda #7
@a:
    jmp dr_human

dr_moto:
    lda #V_MOTO
    sta spr_tile
    lda #4
    sta spr_w
    lda #2
    sta spr_h
    jmp dr_veh
dr_car:
    lda #V_CAR
    sta spr_tile
    lda #6
    sta spr_w
    lda #2
    sta spr_h
dr_veh:
    lda e_dir,x
    beq @f
    lda #$40
@f:
    ora #3
    sta spr_attr
    jsr draw_meta
    ; indicador A+B si el jugador esta cerca y a pie
    lda pveh
    bne @r
    ldx tmp10
    lda e_xlo,x
    sec
    sbc px_lo
    clc
    adc #40
    cmp #72
    bcs @r
    lda frame
    and #16
    beq @r
    lda spr_xhi
    bne @r
    lda spr_xlo
    clc
    adc #4
    bcs @r
    sta tmp0
    lda spr_y
    sec
    sbc #12
    sta tmp1
    lda #M_AB
    sta tmp2
    lda #0
    sta tmp3
    jsr put_spr
    lda tmp0
    clc
    adc #9
    sta tmp0
    inc tmp2
    jmp put_spr
@r:
    rts

dr_polcar:
    lda e_flash,x
    beq @n
    lda frame
    and #2
    bne @r
@n:
    lda #$40
    sta pol_flip
    jsr draw_polcar_at
    ldx tmp10
@r:
    rts

dr_boss:
    ; cuerpo
    lda #M_HELI
    sta spr_tile
    lda #6
    sta spr_w
    lda #2
    sta spr_h
    lda #3
    ldy e_flash,x
    beq @nf
    lda #2
@nf:
    sta spr_attr
    lda spr_xlo
    sta tmp8
    lda spr_xhi
    sta tmp9
    lda spr_y
    clc
    adc #8
    sta spr_y
    jsr draw_meta
    ; rotor
    lda tmp8
    sta spr_xlo
    lda tmp9
    sta spr_xhi
    lda spr_y
    sec
    sbc #8
    sta spr_y
    lda #M_ROTOR
    ldy frame
    tya
    and #2
    beq @ok
    lda #M_ROTOR+6
    bne @ok2
@ok:
    lda #M_ROTOR
@ok2:
    sta spr_tile
    lda #1
    sta spr_h
    lda #3
    sta spr_attr
    jmp draw_meta

dr_expl:
    lda e_tm,x
    lsr
    lsr
    lsr
    tay
    lda expl_seq,y
    sta spr_tile
    lda #2
    sta spr_w
    sta spr_h
    lda #3
    sta spr_attr
    jmp draw_meta
expl_seq:
    .byte M_EXPL+8, M_EXPL+4, M_EXPL+0

dr_bag:
    lda e_anim,x
    lsr
    lsr
    lsr
    and #3
    tay
    lda e_y,x
    clc
    adc bob_tbl,y
    sta spr_y
    lda #M_BAG
    sta spr_tile
    lda #2
    sta spr_w
    sta spr_h
    lda #3
    sta spr_attr
    jmp draw_meta
bob_tbl: .byte 0, 1, 2, 1

; ---------------------------------------------------------------- textos y paletas
title_strs:
    .str $21A6, "LA GRAN PERSECUCION"
    .str $2289, "PRESIONA START"
    .str $2386, "2026  HOMEBREW  MMC3"
    .byte 0
select_strs:
    .str $2087, "ELIGE TU PERSONAJE"
    .str $21E8, "JOSE"
    .str $2226, "DUALCORE"
    .str $21F3, "LUCIANA"
    .str $2231, "CARRETERAS"
    .str $22C4, "B DISPARA     A SALTA"
    .str $2304, "A+B SUBIR / BAJAR VEHICULO"
    .str $2344, "ARRIBA APUNTA  ABAJO AGACHA"
    .byte 0
intro_strs:
    .str $210B, "NIVEL"
    .str $220A, "BUSCADO"
    .str $2289, "VIDAS X"
    .byte 0
pol_str:
    .str $2306, "LA POLICIA TE PERSIGUE!"
    .byte 0
mil_str:
    .str $2306, "EL EJERCITO TE PERSIGUE!"
    .byte 0
hud_strs:
    .str $2026, "VIDAS"
    .str $2054, "NIVEL"
    .byte 0
clear_strs:
    .str $2149, "ESCAPASTE!"
    .str $2187, "NIVEL COMPLETADO"
    .str $21CC, "PTS"
    .byte 0
gameover_strs:
    .str $210B, "ARRESTADO"
    .str $214B, "GAME OVER"
    .str $21CC, "PTS"
    .str $2289, "PRESIONA START"
    .byte 0
ending_strs:
    .str $20CA, "LO LOGRASTE!"
    .str $2187, "ESCAPO CON EL BOTIN"
    .str $21CC, "PTS"
    .str $2287, "GRACIAS POR JUGAR"
    .byte 0
end_jose:
    .str $2149, "JOSE DUALCORE"
    .byte 0
end_luci:
    .str $2147, "LUCIANA CARRETERAS"
    .byte 0

cut_l1: .ltext "VICE CITY  -  3:00 AM"
cut_l2: .ltext "ALARMA EN EL BANCO!"
cut_l3: .ltext "JOSE DUALCORE"
cut_l3b: .ltext "LUCIANA CARRETERAS"
cut_l4: .ltext "ACABA DE ROBAR EL BANCO"
cut_l5: .ltext "POLICIA Y EJERCITO EN CAMINO"
cut_l6: .ltext "ESCAPA!"

pal_title:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$2C,$00, $0F,$2C,$30,$00
    .byte $0F,$0F,$27,$2A, $0F,$0F,$27,$18, $0F,$0F,$27,$12, $0F,$0F,$30,$16
pal_select:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$2C,$00, $0F,$2C,$30,$00
    .byte $0F,$0F,$27,$2A, $0F,$0F,$27,$18, $0F,$0F,$37,$25, $0F,$0F,$37,$21
pal_intro:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$16,$28, $0F,$2C,$30,$00
    .byte $0F,$0F,$27,$2A, $0F,$0F,$27,$18, $0F,$0F,$27,$12, $0F,$0F,$30,$16
pal_cut:
    .byte $0F,$00,$10,$30, $0F,$2D,$10,$28, $0F,$30,$10,$00, $0F,$28,$16,$28
    .byte $0F,$0F,$27,$2A, $0F,$0F,$27,$18, $0F,$0F,$27,$12, $0F,$0F,$30,$16

    .include "data2.asm"

; ---------------------------------------------------------------- reset
    .base $FF00, $FF00
reset:
    sei
    cld
    ldx #$40
    stx $4017
    lda #0
    sta $8000
    sta $E000
    jmp main_reset

    .base $FFFA, $FFFA
    .word nmi, reset, irq
