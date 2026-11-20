; =====================================================================
;  GTA6 - run and gun para NES (mapper 4 / MMC3)
;  PRG 32KB: banco0 $8000 niveles, banco1 $A000 musica, bancos 2-3 codigo
;  CHR 16KB: fuente(0-1) tilesetA(2-3) tilesetB(4-5) sprites(8-11)
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
ST_INTRO    = 2
ST_PLAY     = 3
ST_CLEAR    = 4
ST_GAMEOVER = 5
ST_ENDING   = 6

IRQ_LINE  = 30
NUM_EN    = 8
MOTO_TIME = 140

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
moto = $2C
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
moto_sub = $43
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
score = $50          ; 6 digitos $50-$55
mus_ptr1 = $58
mus_ptr2 = $5A
mus_cnt1 = $5C
mus_cnt2 = $5D
mus_on = $5E
clear_timer = $5F
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

; ---------------- RAM
OAM      = $0200
col_buf  = $0300
attr_buf = $0320
e_type   = $0330
e_xlo    = $0338
e_xhi    = $0340
e_y      = $0348
e_hp     = $0350
e_tm     = $0358
e_dir    = $0360
e_anim   = $0368
e_flash  = $0370
pb_on    = $0380
pb_xlo   = $0384
pb_xhi   = $0388
pb_y     = $038C
pb_dx    = $0390
pb_dy    = $0394
eb_on    = $03A0
eb_xlo   = $03A8
eb_xhi   = $03B0
eb_y     = $03B8
eb_dx    = $03C0
eb_dy    = $03C8
pal_buf  = $0400

; =====================================================================
; Banco 0 ($8000): niveles
; =====================================================================
    .base $0000, $8000
    .include "levels.asm"

; =====================================================================
; Banco 1 ($A000): musica
; =====================================================================
    .base $2000, $A000
    .include "music.asm"

; =====================================================================
; Bancos 2-3 fijos ($C000-$FFFF): codigo
; =====================================================================
    .base $4000, $C000

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
    .word st_title-1, st_select-1, st_intro-1, st_play-1, st_clear-1, st_gameover-1, st_ending-1

; ---------------------------------------------------------------- MMC3
mmc3_init:
    lda #0
    sta $A000          ; mirroring vertical
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
    rts
bank_init:
    .byte 0, 2, 8, 9, 10, 11, 0, 1

set_tileset:           ; A = unidad 1KB (2 o 4) para R1
    ldx #1
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
    sta $E000
    sta PPUMASK
    rts

ppu_enable:
    lda #1
    sta ppu_on
    jsr wait_nmi
    rts

clear_nt:              ; limpia $2000-$27FF
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

draw_strings:          ; ptr -> [hi lo len bytes...]... 0
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

load_palette:          ; ptr -> 32 bytes
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

write_score:           ; direccion PPU ya fijada
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

write_level_num:       ; escribe nivel+1 con 2 digitos
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

add_score:             ; A=cantidad Y=indice digito (0=mas significativo)
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
    lda game_irq
    beq @nohud
    jsr nmi_hud
@nohud:
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
    lda cam_lo
    sta irq_x
    lda cam_hi
    and #1
    ora ctrl_base
    sta irq_ctrl
    sta $E000
    lda #IRQ_LINE
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
    cpx #26
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
    adc #$C8
    adc attr_col
    sta PPUADDR
    lda attr_buf,x
    sta PPUDATA
    inx
    cpx #7
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
    lda #$47
    sta PPUADDR
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

irq:
    pha
    sta $E000
    bit PPUSTATUS
    lda irq_x
    sta PPUSCROLL
    lda #0
    sta PPUSCROLL
    lda irq_ctrl
    sta PPUCTRL
    pla
    rti

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
music_start:
    lda #<mus_pulse
    sta mus_ptr1
    lda #>mus_pulse
    sta mus_ptr1+1
    lda #<mus_tri
    sta mus_ptr2
    lda #>mus_tri
    sta mus_ptr2+1
    lda #1
    sta mus_cnt1
    sta mus_cnt2
    sta mus_on
    rts

music_update:
    lda mus_on
    beq @off
    dec mus_cnt1
    bne @t
    jsr mus_next1
@t:
    dec mus_cnt2
    bne @off
    jsr mus_next2
@off:
    rts

mus_next1:
    ldy #0
    lda (mus_ptr1),y
    cmp #$FF
    bne @n
    lda #<mus_pulse
    sta mus_ptr1
    lda #>mus_pulse
    sta mus_ptr1+1
    jmp mus_next1
@n:
    tax
    iny
    lda (mus_ptr1),y
    sta mus_cnt1
    lda mus_ptr1
    clc
    adc #2
    sta mus_ptr1
    bcc @nc
    inc mus_ptr1+1
@nc:
    cpx #0
    bne @play
    lda #$30
    sta $4000
    rts
@play:
    lda #$86
    sta $4000
    lda note_lo,x
    sta $4002
    lda note_hi,x
    ora #$08
    sta $4003
    rts

mus_next2:
    ldy #0
    lda (mus_ptr2),y
    cmp #$FF
    bne @n
    lda #<mus_tri
    sta mus_ptr2
    lda #>mus_tri
    sta mus_ptr2+1
    jmp mus_next2
@n:
    tax
    iny
    lda (mus_ptr2),y
    sta mus_cnt2
    lda mus_ptr2
    clc
    adc #2
    sta mus_ptr2
    bcc @nc
    inc mus_ptr2+1
@nc:
    cpx #0
    bne @play
    lda #$80
    sta $4008
    rts
@play:
    lda #$28
    sta $4008
    lda note_lo,x
    sta $400A
    lda note_hi,x
    ora #$08
    sta $400B
    rts

sfx_shoot:
    lda #$84
    sta $4004
    lda #$8B
    sta $4005
    lda #$50
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
    lda #$0E
    sta $400C
    lda #$0D
    sta $400E
    lda #$08
    sta $400F
    rts
sfx_hit:
    lda #$04
    sta $400C
    lda #$06
    sta $400E
    lda #$08
    sta $400F
    rts

; ---------------------------------------------------------------- pantalla titulo
title_init:
    jsr ppu_off
    lda #2
    jsr set_tileset
    jsr clear_nt
    lda #<logo_strs
    sta ptr
    lda #>logo_strs
    sta ptr+1
    jsr draw_strings
    lda #<sun_strs
    sta ptr
    lda #>sun_strs
    sta ptr+1
    jsr draw_strings
    lda #<title_strs
    sta ptr
    lda #>title_strs
    sta ptr+1
    jsr draw_strings
    lda #$55
    ldx #8
    ldy #32
    jsr fill_attr
    lda #$AA
    ldx #40
    ldy #8
    jsr fill_attr
    lda #<pal_title
    sta ptr
    lda #>pal_title
    sta ptr+1
    jsr load_palette
    jsr clear_oam
    lda #0
    sta cam_lo
    sta cam_hi
    lda #ST_TITLE
    sta state
    jsr ppu_enable
    rts

st_title:
    lda frame
    and #$1F
    bne @nb
    lda pal_buf+9
    eor #$3F
    sta pal_buf+9
    lda #1
    sta pal_dirty
@nb:
    lda pad_new
    and #BTN_START|BTN_A
    beq @r
    jsr sfx_power
    jmp select_init
@r:
    rts

; ---------------------------------------------------------------- seleccion de personaje
select_init:
    jsr ppu_off
    jsr clear_nt
    lda #<select_strs
    sta ptr
    lda #>select_strs
    sta ptr+1
    jsr draw_strings
    lda #<pal_select
    sta ptr
    lda #>pal_select
    sta ptr+1
    jsr load_palette
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
    jsr sfx_power
    jmp new_game
@draw:
    jsr clear_oam
    lda #0
    sta spr_xhi
    sta spr_attr
    lda #80
    sta spr_xlo
    lda #100
    sta spr_y
    lda #2
    sta spr_w
    lda #3
    sta spr_h
    ldx #0
    jsr sel_frame
    sta spr_tile
    jsr draw_meta
    lda #160
    sta spr_xlo
    lda #1
    sta spr_attr
    ldx #1
    jsr sel_frame
    sta spr_tile
    jsr draw_meta
    ; flecha
    lda #84
    ldx sel
    beq @a
    lda #164
@a:
    sta tmp0
    lda frame
    lsr
    lsr
    and #3
    clc
    adc #84
    sta tmp1
    lda #ARROW_TILE
    sta tmp2
    lda #2
    sta tmp3
    jsr put_spr
    rts

sel_frame:             ; X = personaje, devuelve A = tile
    lda #0
    cpx sel
    bne @st
    lda frame
    lsr
    lsr
    lsr
    and #1
    clc
    adc #1
@st:
    sta tmp0
    asl
    adc tmp0
    asl
    sta tmp0
    txa
    beq @m
    lda tmp0
    clc
    adc #24
    rts
@m:
    lda tmp0
    rts

new_game:
    lda #3
    sta lives
    lda #0
    sta level
    ldx #5
@s:
    sta score,x
    dex
    bpl @s
    jmp intro_init

; ---------------------------------------------------------------- intro de nivel
intro_init:
    jsr ppu_off
    jsr clear_nt
    lda #<intro_strs
    sta ptr
    lda #>intro_strs
    sta ptr+1
    jsr draw_strings
    bit PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$91
    sta PPUADDR
    jsr write_level_num
    bit PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$AF
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
    lda #<pal_intro
    sta ptr
    lda #>pal_intro
    sta ptr+1
    jsr load_palette
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
clear_init:
    jsr ppu_off
    jsr clear_nt
    lda #<clear_strs
    sta ptr
    lda #>clear_strs
    sta ptr+1
    jsr draw_strings
    bit PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$D3
    sta PPUADDR
    jsr write_score
    lda #<pal_intro
    sta ptr
    lda #>pal_intro
    sta ptr+1
    jsr load_palette
    jsr clear_oam
    lda #ST_CLEAR
    sta state
    lda #160
    sta timer
    jsr ppu_enable
    rts

st_clear:
    dec timer
    bne @r
    jmp intro_init
@r:
    rts

gameover_init:
    jsr ppu_off
    jsr clear_nt
    lda #<gameover_strs
    sta ptr
    lda #>gameover_strs
    sta ptr+1
    jsr draw_strings
    bit PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$D3
    sta PPUADDR
    jsr write_score
    lda #<pal_intro
    sta ptr
    lda #>pal_intro
    sta ptr+1
    jsr load_palette
    jsr clear_oam
    lda #ST_GAMEOVER
    sta state
    lda #60
    sta timer
    jsr ppu_enable
    rts

st_gameover:
st_ending:
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

ending_init:
    jsr ppu_off
    jsr clear_nt
    lda #<ending_strs
    sta ptr
    lda #>ending_strs
    sta ptr+1
    jsr draw_strings
    bit PPUSTATUS
    lda #$22
    sta PPUADDR
    lda #$13
    sta PPUADDR
    jsr write_score
    lda #<pal_title
    sta ptr
    lda #>pal_title
    sta ptr+1
    jsr load_palette
    jsr clear_oam
    lda #ST_ENDING
    sta state
    lda #60
    sta timer
    jsr ppu_enable
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
    lda level
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
    lda level_tbl+6,x
    sta ptr
    lda level_tbl+7,x
    sta ptr+1
    jsr load_palette
    lda char
    asl
    asl
    tax
    lda char_pals+1,x
    sta pal_buf+17
    lda char_pals+2,x
    sta pal_buf+18
    lda char_pals+3,x
    sta pal_buf+19
    lda lvl_tileset
    jsr set_tileset
    ; cam_max = len*16 - 256 ; lim = cam_max + 240
    lda lvl_len
    sta cam_max_lo
    lda #0
    sta cam_max_hi
    asl cam_max_lo
    rol cam_max_hi
    asl cam_max_lo
    rol cam_max_hi
    asl cam_max_lo
    rol cam_max_hi
    asl cam_max_lo
    rol cam_max_hi
    dec cam_max_hi
    lda cam_max_lo
    clc
    adc #240
    sta lim_lo
    lda cam_max_hi
    adc #0
    sta lim_hi
    ; limpiar estado
    lda #0
    sta cam_lo
    sta cam_hi
    sta tc_lo
    sta tc_hi
    sta boss_state
    sta moto
    sta col_pending
    sta attr_pending
    sta dead_timer
    sta shoot_cd
    sta hud_bar
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
    cpx #4
    bne @cb
    ldx #0
@cc:
    sta eb_on,x
    inx
    cpx #8
    bne @cc
    jsr clear_nt
    lda #<hud_strs
    sta ptr
    lda #>hud_strs
    sta ptr+1
    jsr draw_strings
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$35
    sta PPUADDR
    jsr write_level_num
    lda #$FF
    ldx #0
    ldy #8
    jsr fill_attr
    bit PPUSTATUS
    lda #$27
    sta PPUADDR
    lda #$C0
    sta PPUADDR
    ldx #8
    lda #$FF
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

char_pals:
    .byte $0F, $0F, $37, $2A
    .byte $0F, $0F, $37, $25

; ---------------------------------------------------------------- columnas del escenario
get_col_y:             ; Y = metacolumna -> A = byte
    cpy lvl_len
    bcs @out
    lda (lvl_ptr),y
    rts
@out:
    lda #$02
    rts

col_gattr:             ; Y = metacol -> A = primera metafila con paleta 1
    jsr get_col_y
    and #$0F
    beq @p
    sta tmp7
    lda #14
    sec
    sbc tmp7
    rts
@p:
    lda #13
    rts

build_column:
    lda tc_lo
    and #31
    clc
    adc #$80
    sta col_addr_lo
    lda tc_lo
    and #32
    lsr
    lsr
    lsr
    ora #$20
    sta col_addr_hi
    lda tc_hi
    lsr
    lda tc_lo
    ror
    sta tmp4
    tay
    jsr get_col_y
    sta tmp5
    lda #0
    sta tmp3
    lda tmp5
    and #$0F
    beq @pit
    sta tmp0
    lda #14
    sec
    sbc tmp0
    asl
    sta tmp1
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
    ldx #0
@row:
    txa
    clc
    adc #4
    sta tmp7
    cmp tmp1
    bcc @notg
    lda tmp3
    bne @water
    lda tmp7
    cmp tmp1
    bne @fill
    lda #T_GTOP
    bne @put
@fill:
    lda #T_GFILL
    bne @put
@water:
    lda #T_WATER
    bne @put
@notg:
    cmp tmp2
    bne @notp
    lda #T_PLAT
    bne @put
@notp:
    cmp tmp6
    bcc @sky
    bne @bld
    lda #T_ROOF
    bne @put
@bld:
    lda tmp7
    ora tc_lo
    and #1
    bne @wall
    lda #T_WIN
    bne @put
@wall:
    lda #T_WALL
    bne @put
@sky:
    lda #0
@put:
    sta col_buf,x
    inx
    cpx #26
    bne @row
    ; atributos cada 4 columnas
    lda tc_lo
    and #3
    bne @noattr
    lda col_addr_hi
    ora #3
    sta attr_hi
    lda tc_lo
    lsr
    lsr
    and #7
    sta attr_col
    ldy tmp4
    jsr col_gattr
    sta tmp0
    ldy tmp4
    iny
    jsr col_gattr
    sta tmp1
    ldx #0
@ar:
    txa
    clc
    adc #1
    asl
    sta tmp2
    lda #0
    sta tmp3
    lda tmp2
    cmp tmp0
    bcc @a1
    lda tmp3
    ora #$01
    sta tmp3
@a1:
    lda tmp2
    cmp tmp1
    bcc @a2
    lda tmp3
    ora #$04
    sta tmp3
@a2:
    ldy tmp2
    iny
    cpy tmp0
    bcc @a3
    lda tmp3
    ora #$10
    sta tmp3
@a3:
    cpy tmp1
    bcc @a4
    lda tmp3
    ora #$40
    sta tmp3
@a4:
    lda tmp3
    sta attr_buf,x
    inx
    cpx #7
    bne @ar
    lda #1
    sta attr_pending
@noattr:
    lda #1
    sta col_pending
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

; ---------------------------------------------------------------- consultas de terreno
x_to_mc:               ; tmp0/tmp1 = x -> A = metacolumna
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

surf_at:               ; tmp0/tmp1 = x -> A = y suelo (FF=pozo), tmp3 = y plataforma (FF=nada)
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

wall_check:            ; tmp0/tmp1 = x -> C=1 si bloqueado
    jsr surf_at
    sta tmp2
    lda py
    clc
    adc #20
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
    jsr respawn
    rts
@go:
    jmp gameover_init
@draw:
    jsr draw_all
    rts

respawn:
    lda #3
    sta hp
    lda #0
    sta moto
    sta vy_lo
    sta vy_hi
    sta onground
    sta pdir
    sta hud_bar
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
    sbc #24
    sta py
    lda #0
    sta py_frac
    rts

player_update:
    lda inv
    beq @ni
    dec inv
@ni:
    lda shoot_cd
    beq @ns
    dec shoot_cd
@ns:
    lda moto
    beq @nm
    dec moto_sub
    bpl @nm
    lda #3
    sta moto_sub
    dec moto
@nm:
    lda moto
    lsr
    lsr
    lsr
    lsr
    cmp #9
    bcc @hb
    lda #8
@hb:
    sta hud_bar
    ; --- movimiento horizontal
    lda pad
    and #BTN_RIGHT|BTN_LEFT
    beq @nomove
    lda moto
    beq @foot
    lda #3
    bne @setsp
@foot:
    lda frame
    and #1
    clc
    adc #1
@setsp:
    sta tmp5
    lda pad
    and #BTN_RIGHT
    beq @left
    lda #0
    sta pdir
    jmp @mv
@left:
    lda #1
    sta pdir
@mv:
    jsr step_x
    dec tmp5
    bne @mv
    inc anim
@nomove:
    ; --- salto
    lda pad_new
    and #BTN_A
    beq @nj
    lda onground
    beq @nj
    lda #0
    sta vy_lo
    sta onground
    lda #$FA
    sta vy_hi
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
    adc #$5A
    sta vy_lo
    lda vy_hi
    adc #0
    sta vy_hi
    bmi @nocap
    cmp #6
    bcc @nocap
    lda #6
    sta vy_hi
    lda #0
    sta vy_lo
@nocap:
    lda py
    clc
    adc #24
    sta pfeet_old
    lda py_frac
    clc
    adc vy_lo
    sta py_frac
    lda py
    adc vy_hi
    sta py
    ; --- aterrizaje
    lda #0
    sta onground
    lda vy_hi
    bmi @air
    lda px_lo
    clc
    adc #8
    sta tmp0
    lda px_hi
    adc #0
    sta tmp1
    jsr surf_at
    sta tmp4
    lda tmp3
    cmp #$FF
    beq @gnd
    lda py
    clc
    adc #24
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
    adc #24
    cmp tmp4
    bcc @air
    lda tmp4
@land:
    sec
    sbc #24
    sta py
    lda #0
    sta vy_lo
    sta vy_hi
    sta py_frac
    lda #1
    sta onground
@air:
    ; --- caida al vacio
    lda vy_hi
    bmi @nopit
    lda py
    cmp #212
    bcc @nopit
    jmp player_die
@nopit:
    ; --- disparo
    lda pad
    and #BTN_B
    beq @nofire
    lda shoot_cd
    bne @nofire
    jsr fire_player
@nofire:
    rts

step_x:
    lda pdir
    bne @l
    lda px_lo
    clc
    adc #13
    sta tmp0
    lda px_hi
    adc #0
    sta tmp1
    jsr wall_check
    bcs @blocked
    lda px_lo
    cmp lim_lo
    lda px_hi
    sbc lim_hi
    bcs @blocked
    inc px_lo
    bne @ok
    inc px_hi
@ok:
    rts
@l:
    lda px_lo
    clc
    adc #2
    sta tmp0
    lda px_hi
    adc #0
    sta tmp1
    jsr wall_check
    bcs @blocked
    lda cam_lo
    cmp px_lo
    lda cam_hi
    sbc px_hi
    bcs @blocked
    lda px_lo
    bne @d
    dec px_hi
@d:
    dec px_lo
@blocked:
    rts

fire_player:
    ldx #3
@f:
    lda pb_on,x
    beq @got
    dex
    bpl @f
    rts
@got:
    lda #9
    sta shoot_cd
    lda #1
    sta pb_on,x
    lda #0
    sta pb_dy,x
    lda pad
    and #BTN_UP
    beq @horiz
    lda pad
    and #BTN_LEFT|BTN_RIGHT
    bne @diag
    lda #0
    sta pb_dx,x
    lda #$FB
    sta pb_dy,x
    lda px_lo
    clc
    adc #4
    sta pb_xlo,x
    lda px_hi
    adc #0
    sta pb_xhi,x
    lda py
    sec
    sbc #4
    sta pb_y,x
    jmp sfx_shoot
@diag:
    lda #$FC
    sta pb_dy,x
    lda #4
    ldy pdir
    beq @dr
    lda #$FC
@dr:
    sta pb_dx,x
    jmp @pos
@horiz:
    lda #5
    ldy pdir
    beq @hr
    lda #$FB
@hr:
    sta pb_dx,x
@pos:
    lda pdir
    bne @pl
    lda px_lo
    clc
    adc #12
    sta pb_xlo,x
    lda px_hi
    adc #0
    sta pb_xhi,x
    jmp @py
@pl:
    lda px_lo
    sec
    sbc #4
    sta pb_xlo,x
    lda px_hi
    sbc #0
    sta pb_xhi,x
@py:
    lda py
    clc
    adc #6
    ldy moto
    beq @pyy
    sec
    sbc #4
@pyy:
    sta pb_y,x
    jmp sfx_shoot

player_hurt:
    lda inv
    bne @r
    lda dead_timer
    bne @r
    lda moto
    beq @foot
    lda #0
    sta moto
    sta hud_bar
    lda #90
    sta inv
    jmp sfx_hit
@foot:
    dec hp
    beq player_die
    lda #90
    sta inv
    jmp sfx_hit
@r:
    rts

player_die:
    lda #0
    sta hp
    sta moto
    sta hud_bar
    lda #100
    sta dead_timer
    jmp sfx_boom

camera_update:
    lda px_lo
    sec
    sbc #120
    sta tmp0
    lda px_hi
    sbc #0
    sta tmp1
    bmi @r
    lda cam_lo
    cmp tmp0
    lda cam_hi
    sbc tmp1
    bcs @r
    lda tmp0
    cmp cam_max_lo
    lda tmp1
    sbc cam_max_hi
    bcc @set
    lda cam_max_lo
    sta tmp0
    lda cam_max_hi
    sta tmp1
@set:
    lda tmp0
    sta cam_lo
    lda tmp1
    sta cam_hi
@r:
    rts

; ---------------------------------------------------------------- aparicion de enemigos
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
    lda #1
    sta e_dir,x
    sta e_hp,x
    lda #0
    sta e_anim,x
    sta e_flash,x
    jsr rand
    and #63
    clc
    adc #40
    sta e_tm,x
    lda e_type,x
    cmp #2
    bne @adv
    lda #2
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

; ---------------------------------------------------------------- balas del jugador
pbullets_update:
    ldx #3
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
    cmp #24
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

bullet_hits:
    ldx #3
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
    cmp #3
    beq @ne
    cmp #5
    beq @ne
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
    lda e_type,y
    cmp #4
    beq @wb
    lda tmp0
    cmp #16
    bcs @ne
    bcc @dy
@wb:
    lda tmp0
    cmp #32
    bcs @ne
@dy:
    lda pb_y,x
    clc
    adc #3
    sec
    sbc e_y,y
    bcc @ne
    cmp #24
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
    bne @snd
    tya
    tax
    jsr kill_enemy
    ldx tmp10
    jmp @nb
@snd:
    jsr sfx_hit
@nb:
    dex
    bmi @done
    jmp @b
@done:
    rts

kill_enemy:            ; X = slot
    lda e_type,x
    cmp #4
    beq @boss
    cmp #2
    bne @w
    lda #2
    bne @add
@w:
    lda #1
@add:
    ldy #3
    jsr add_score
    jmp @ex
@boss:
    lda #5
    ldy #2
    jsr add_score
    lda #2
    sta boss_state
    lda #150
    sta clear_timer
    lda e_xlo,x
    clc
    adc #8
    sta e_xlo,x
    lda e_xhi,x
    adc #0
    sta e_xhi,x
    ldy #7
    lda #0
@cb:
    sta eb_on,y
    dey
    bpl @cb
@ex:
    lda #5
    sta e_type,x
    lda #24
    sta e_tm,x
    jmp sfx_boom

; ---------------------------------------------------------------- enemigos
enemies_update:
    ldx #0
@l:
    lda e_type,x
    beq @next
    lda e_xlo,x
    sec
    sbc cam_lo
    sta tmp8
    lda e_xhi,x
    sbc cam_hi
    sta tmp9
    bpl @onr
    lda tmp8
    cmp #$E0
    bcs @onr
    lda #0
    sta e_type,x
    jmp @next
@onr:
    lda e_flash,x
    beq @nf
    dec e_flash,x
@nf:
    lda e_type,x
    cmp #1
    bne @t2
    jsr en_walker
    jmp @next
@t2:
    cmp #2
    bne @t3
    jsr en_shooter
    jmp @next
@t3:
    cmp #3
    bne @t4
    jsr en_moto
    jmp @next
@t4:
    cmp #4
    bne @t5
    jsr en_boss
    jmp @next
@t5:
    dec e_tm,x
    bne @next
    lda #0
    sta e_type,x
@next:
    inx
    cpx #NUM_EN
    bne @l
    rts

face_player:           ; X slot -> e_dir
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

contact:               ; X slot, tw/th -> dano o atropello
    jsr touch_test
    bcc @r
    lda moto
    beq @hurt
    lda e_type,x
    cmp #4
    beq @hurt
    jmp kill_enemy
@hurt:
    jmp player_hurt
@r:
    rts

touch_test:            ; centro jugador dentro de caja enemiga ampliada -> C
    lda px_lo
    sec
    sbc e_xlo,x
    sta tmp0
    lda px_hi
    sbc e_xhi,x
    sta tmp1
    lda tmp0
    clc
    adc #13
    sta tmp0
    lda tmp1
    adc #0
    bne @no
    lda tmp0
    cmp tw
    bcs @no
    lda py
    clc
    adc #22
    bcs @no
    sec
    sbc e_y,x
    bcc @no
    cmp th
    bcs @no
    sec
    rts
@no:
    clc
    rts

en_walker:
    inc e_anim,x
    lda #26
    sta tw
    lda #40
    sta th
    jsr contact
    lda e_type,x
    cmp #1
    bne @r
    jsr face_player
    lda frame
    and #1
    beq @mv
    lda level
    cmp #5
    bcc @fire
@mv:
    lda e_dir,x
    bne @ml
    lda e_xlo,x
    clc
    adc #14
    sta tmp0
    lda e_xhi,x
    adc #0
    sta tmp1
    jmp @probe
@ml:
    lda e_xlo,x
    clc
    adc #1
    sta tmp0
    lda e_xhi,x
    adc #0
    sta tmp1
@probe:
    jsr surf_at
    sta tmp2
    lda e_y,x
    clc
    adc #24
    cmp tmp2
    bne @fire
    lda e_dir,x
    bne @dl
    inc e_xlo,x
    bne @fire
    inc e_xhi,x
    jmp @fire
@dl:
    lda e_xlo,x
    bne @d2
    dec e_xhi,x
@d2:
    dec e_xlo,x
@fire:
    dec e_tm,x
    bne @r
    jsr rand
    and #63
    clc
    adc #100
    sta e_tm,x
    lda tmp9
    bne @r
    jsr enemy_fire
@r:
    rts

en_shooter:
    lda #26
    sta tw
    lda #40
    sta th
    jsr contact
    lda e_type,x
    cmp #2
    bne @r
    jsr face_player
    dec e_tm,x
    bne @r
    lda level
    asl
    asl
    sta tmp0
    lda #84
    sec
    sbc tmp0
    sta e_tm,x
    lda tmp9
    bne @r
    jsr enemy_fire
@r:
    rts

en_moto:
    inc e_anim,x
    lda #42
    sta tw
    lda #36
    sta th
    jsr touch_test
    bcc @r
    lda #0
    sta e_type,x
    lda #MOTO_TIME
    sta moto
    lda #3
    sta moto_sub
    lda #5
    ldy #3
    jsr add_score
    jsr sfx_power
@r:
    rts

en_boss:
    lda #42
    sta tw
    lda #40
    sta th
    jsr contact
    lda frame
    and #1
    bne @nm
    lda e_dir,x
    bne @up
    inc e_y,x
    lda e_y,x
    cmp #136
    bcc @nm
    lda #1
    sta e_dir,x
    bne @nm
@up:
    dec e_y,x
    lda e_y,x
    cmp #48
    bcs @nm
    lda #0
    sta e_dir,x
@nm:
    dec e_tm,x
    bne @r
    lda level
    asl
    asl
    sta tmp0
    lda #70
    sec
    sbc tmp0
    sta e_tm,x
    lda e_xlo,x
    sta tmp10
    lda e_xhi,x
    sta tmp11
    lda e_y,x
    clc
    adc #14
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
    jsr sfx_hit
@r:
    rts

enemy_fire:            ; X slot -> bala hacia el jugador
    lda e_xlo,x
    clc
    adc #4
    sta tmp10
    lda e_xhi,x
    adc #0
    sta tmp11
    lda e_y,x
    clc
    adc #7
    sta eb_y_t
    lda px_lo
    cmp e_xlo,x
    lda px_hi
    sbc e_xhi,x
    lda #2
    bcs @dx
    lda #$FE
@dx:
    sta eb_dx_t
    lda #0
    sta eb_dy_t
    lda py
    clc
    adc #24
    cmp e_y,x
    bcs @nu
    lda #$FF
    sta eb_dy_t
    jmp spawn_eb
@nu:
    lda e_y,x
    clc
    adc #24
    cmp py
    bcs @go
    lda #1
    sta eb_dy_t
@go:
    jmp spawn_eb

spawn_eb:              ; tmp10/11 x, eb_y_t, eb_dx_t, eb_dy_t  (preserva X)
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
    bcc @kill
    cmp #232
    bcs @kill
    lda eb_xlo,x
    sec
    sbc cam_lo
    lda eb_xhi,x
    sbc cam_hi
    bne @kill
    lda dead_timer
    bne @n
    lda eb_xlo,x
    sec
    sbc px_lo
    sta tmp0
    lda eb_xhi,x
    sbc px_hi
    bne @n
    lda tmp0
    cmp #10
    bcs @n
    lda eb_y,x
    clc
    adc #1
    sec
    sbc py
    bcc @n
    cmp #22
    bcs @n
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
    lda #4
    sta e_type,x
    lda cam_lo
    clc
    adc #200
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
    adc #16
    sta e_hp,x
    lda #60
    sta e_tm,x
    lda #0
    sta e_dir,x
    sta e_flash,x
    lda #1
    sta boss_state
@r:
    rts
@s:
    cmp #2
    bne @r
    dec clear_timer
    bne @r
    jmp level_clear

; ---------------------------------------------------------------- sprites
draw_all:
    jsr clear_oam
    jsr draw_player
    jsr draw_pbullets
    jsr draw_ebullets
    jsr draw_enemies
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

draw_meta:             ; spr_xlo/xhi (pantalla), spr_y, spr_tile, spr_w, spr_h, spr_attr
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
    lda spr_attr
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
    bne @row
    rts

draw_player:
    lda px_lo
    sec
    sbc cam_lo
    sta spr_xlo
    lda px_hi
    sbc cam_hi
    sta spr_xhi
    lda dead_timer
    beq @alive
    cmp #60
    bcc @r
    lda py
    clc
    adc #4
    sta spr_y
    lda #EXPL_TILE
    sta spr_tile
    lda #2
    sta spr_w
    sta spr_h
    lda #3
    sta spr_attr
    jmp draw_meta
@alive:
    lda inv
    beq @vis
    lda frame
    and #2
    beq @vis
@r:
    rts
@vis:
    lda #0
    ldx pdir
    beq @f
    lda #$40
@f:
    sta spr_attr
    lda #2
    sta spr_w
    lda moto
    bne @ride
    lda #3
    sta spr_h
    lda py
    sta spr_y
    lda onground
    beq @jmp
    lda pad
    and #BTN_LEFT|BTN_RIGHT
    beq @stand
    lda anim
    lsr
    lsr
    lsr
    and #1
    clc
    adc #1
    bne @fr
@stand:
    lda #0
    beq @fr
@jmp:
    lda #3
@fr:
    sta tmp0
    asl
    adc tmp0
    asl
    sta tmp0
    lda char
    beq @m
    lda #24
@m:
    clc
    adc tmp0
    sta spr_tile
    jmp draw_meta
@ride:
    lda #2
    sta spr_h
    lda py
    sec
    sbc #4
    sta spr_y
    lda char
    beq @m2
    lda #24
@m2:
    sta spr_tile
    jsr draw_meta
    lda spr_xlo
    sec
    sbc #8
    sta spr_xlo
    lda spr_xhi
    sbc #0
    sta spr_xhi
    lda py
    clc
    adc #8
    sta spr_y
    lda #MOTO_TILE
    sta spr_tile
    lda #4
    sta spr_w
    lda #2
    sta spr_h
    lda spr_attr
    and #$40
    ora #2
    sta spr_attr
    jmp draw_meta

draw_pbullets:
    ldx #3
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
    lda #PB_TILE
    sta tmp2
    lda #2
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
    lda #EB_TILE
    sta tmp2
    lda #2
    sta tmp3
    jsr put_spr
@n:
    dex
    bpl @l
    rts

draw_enemies:
    ldx #0
@l:
    lda e_type,x
    bne @d
@n:
    inx
    cpx #NUM_EN
    bne @l
    rts
@d:
    stx tmp10
    lda e_xlo,x
    sec
    sbc cam_lo
    sta spr_xlo
    lda e_xhi,x
    sbc cam_hi
    sta spr_xhi
    lda e_y,x
    sta spr_y
    lda e_type,x
    cmp #1
    beq @walker
    cmp #2
    beq @shooter
    cmp #3
    beq @moto
    cmp #4
    beq @boss
    lda #EXPL_TILE
    sta spr_tile
    lda #2
    sta spr_w
    sta spr_h
    lda #3
    sta spr_attr
    jmp @draw
@walker:
    lda e_anim,x
    lsr
    lsr
    lsr
    and #1
    beq @w0
    lda #6
@w0:
    clc
    adc #THUG_TILE
    jmp @hum
@shooter:
    lda #THUG_TILE
@hum:
    sta spr_tile
    lda #2
    sta spr_w
    lda #3
    sta spr_h
    lda e_dir,x
    beq @nf
    lda #$40
@nf:
    ora #1
    ldy e_flash,x
    beq @nfl
    ora #3
@nfl:
    sta spr_attr
    jmp @draw
@moto:
    lda e_anim,x
    and #8
    bne @skip
    lda #MOTO_TILE
    sta spr_tile
    lda #4
    sta spr_w
    lda #2
    sta spr_h
    lda #2
    sta spr_attr
    jmp @draw
@boss:
    lda #BOSS_TILE
    sta spr_tile
    lda #4
    sta spr_w
    lda #3
    sta spr_h
    lda #3
    ldy e_flash,x
    beq @bf
    lda #2
@bf:
    sta spr_attr
@draw:
    jsr draw_meta
@skip:
    ldx tmp10
    jmp @n

; ---------------------------------------------------------------- textos y paletas
title_strs:
    .str $21A3, "EDICION NES - RUN AND GUN"
    .str $22A9, "PRESIONA START"
    .str $2347, "2026  HOMEBREW  MMC3"
    .byte 0
select_strs:
    .str $20C7, "ELIGE TU PERSONAJE"
    .str $2228, "HOMBRE"
    .str $2233, "MUJER"
    .str $22C6, "MODA VERANIEGA DE MIAMI"
    .str $2327, "IZQ/DER Y START"
    .byte 0
intro_strs:
    .str $218B, "NIVEL"
    .str $22A8, "VIDAS X"
    .str $2309, "PREPARATE!"
    .byte 0
hud_strs:
    .str $2026, "VIDAS"
    .str $202F, "NIVEL"
    .str $2042, "MOTO"
    .byte 0
clear_strs:
    .str $2148, "NIVEL COMPLETADO!"
    .str $21CC, "PTS"
    .byte 0
gameover_strs:
    .str $2148, "   GAME OVER"
    .str $21CC, "PTS"
    .str $2289, "PRESIONA START"
    .byte 0
ending_strs:
    .str $2109, "FELICIDADES!"
    .str $2185, "LIMPIASTE LAS 10 ZONAS"
    .str $220C, "PTS"
    .str $2307, "GRACIAS POR JUGAR"
    .byte 0

pal_title:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$2C,$00, $0F,$2C,$30,$00
    .byte $0F,$0F,$37,$2A, $0F,$0F,$37,$25, $0F,$0F,$30,$16, $0F,$0F,$10,$27
pal_select:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$2C,$00, $0F,$2C,$30,$00
    .byte $0F,$0F,$37,$2A, $0F,$0F,$37,$25, $0F,$0F,$30,$28, $0F,$0F,$10,$27
pal_intro:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$2C,$00, $0F,$2C,$30,$00
    .byte $0F,$0F,$37,$2A, $0F,$0F,$37,$25, $0F,$0F,$30,$16, $0F,$0F,$10,$27

    .include "data.asm"

; ---------------------------------------------------------------- reset (ultimo banco, siempre mapeado)
    .base $7F00, $FF00
reset:
    sei
    cld
    ldx #$40
    stx $4017
    lda #0
    sta $8000          ; modo PRG 0: $C000 fijo
    sta $E000
    jmp main_reset

    .base $7FFA, $FFFA
    .word nmi, reset, irq
