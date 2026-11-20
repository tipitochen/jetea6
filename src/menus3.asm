; =====================================================================
;  MENUS / ESCENAS
; =====================================================================
title_init:
    jsr ppu_off
    lda #0
    jsr mus_play
    lda #0
    sta chr_r0
    sta tfill
    lda #18
    sta chr_r1
    lda jose_moto_bk
    sta chr_r2
    lda #UNIT_MISC
    sta chr_r3
    lda #UNIT_COP
    sta chr_r45
    lda #0
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
    jmp ppu_enable

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
    jsr clear_oam
    jsr reset_draw
    ; moto
    lda cut_t
    sta sx_lo
    lda #0
    sta sx_hi
    lda #222
    sta sy
    lda frame
    lsr
    lsr
    and #1
    tay
    lda jose_moto_lo,y
    sta fptr
    lda jose_moto_hi,y
    sta fptr+1
    jsr draw_frame
    ; policia persiguiendo
    lda cut_t
    sec
    sbc #56
    sta sx_lo
    lda #0
    sbc #0
    sta sx_hi
    lda #222
    sta sy
    lda frame
    lsr
    lsr
    lsr
    and #1
    clc
    adc #1
    tay
    lda cop_lo,y
    sta fptr
    lda cop_hi,y
    sta fptr+1
    jsr draw_frame
    lda pad_new
    and #BTN_START|BTN_A
    beq @r
    jsr sfx_power
    jmp select_init
@r:
    rts

; ---------------------------------------------------------------- seleccion
select_init:
    jsr ppu_off
    lda #0
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
    jmp sel_name

sel_name:
    lda sel
    bne @l
    lda #<sel_jose
    sta ptr
    lda #>sel_jose
    sta ptr+1
    jmp @q
@l:
    lda #<sel_luci
    sta ptr
    lda #>sel_luci
    sta ptr+1
@q:
    lda #20
    jmp queue_line

st_select:
    lda pad_new
    and #BTN_LEFT|BTN_RIGHT|BTN_SEL
    beq @nolr
    lda sel
    eor #1
    sta sel
    jsr sfx_shoot
    jsr sel_name
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
    jsr reset_draw
    ; Jose (R2)
    ldx #0
    jsr sel_frame
    tay
    lda jose_bk,y
    sta chr_r2
    lda jose_lo,y
    sta fptr
    lda jose_hi,y
    sta fptr+1
    lda #84
    sta sx_lo
    lda #0
    sta sx_hi
    lda #128
    sta sy
    jsr draw_frame
    ; Luciana (R3, +$40, camisa en P2)
    ldx #1
    jsr sel_frame
    tay
    lda luci_bk,y
    sta chr_r3
    lda luci_lo,y
    sta fptr
    lda luci_hi,y
    sta fptr+1
    lda #172
    sta sx_lo
    lda #$40
    sta stile
    lda #1
    sta sremap
    lda #$40
    sta sflip
    jmp draw_frame

sel_frame:             ; X = personaje -> A = cuadro
    cpx sel
    bne @idle
    lda frame
    lsr
    lsr
    lsr
    and #3
    tax
    lda walk_seq,x
    rts
@idle:
    lda frame
    lsr
    lsr
    lsr
    lsr
    lsr
    and #1
    rts

; ---------------------------------------------------------------- robo al banco
cut_init:
    jsr ppu_off
    lda #18
    sta chr_r1
    lda #0
    sta chr_r0
    lda #UNIT_MISC
    sta chr_r3
    lda #UNIT_COP
    sta chr_r45
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
    jsr set_shirt
    jsr clear_oam
    lda #0
    sta cut_t
    sta tfill
    lda #ST_CUT
    sta state
    jsr ppu_enable
    lda #<cut_l1
    sta ptr
    lda #>cut_l1
    sta ptr+1
    lda #1
    jmp queue_line

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
    lda pad_new
    and #BTN_START
    bne @end
    lda cut_t
    cmp #250
    bcc @go
@end:
    lda #0
    sta level
    jmp intro_init
@go:
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
    jsr reset_draw
    ; policias desde la izquierda (t>=110)
    lda cut_t
    cmp #110
    bcc @nocop
    sec
    sbc #110
    cmp #70
    bcc @cx
    lda #70
@cx:
    sta sx_lo
    lda #0
    sta sx_hi
    lda #200
    sta sy
    ldy #EF_WALK1
    lda cut_t
    cmp #180
    bcc @cw
    ldy #EF_AIM
    jmp @cf
@cw:
    lda frame
    lsr
    lsr
    lsr
    and #1
    clc
    adc #1
    tay
@cf:
    lda cop_lo,y
    sta fptr
    lda cop_hi,y
    sta fptr+1
    jsr draw_frame
    ; segundo policia
    lda sx_lo
    sec
    sbc #30
    sta sx_lo
    lda #0
    sbc #0
    sta sx_hi
    lda #214
    sta sy
    jsr draw_frame
@nocop:
    jsr reset_draw
    lda cut_t
    cmp #60
    bcs @pl
    jmp @parked
@pl:
    cmp #160
    bcs @ride
    ; sale corriendo con la bolsa
    sec
    sbc #60
    clc
    adc #128
    cmp #204
    bcc @px
    lda #204
@px:
    sta sx_lo
    lda #0
    sta sx_hi
    lda #200
    sta sy
    lda frame
    lsr
    lsr
    and #3
    tax
    ldy walk_seq,x
    lda char
    bne @lc
    lda jose_bk,y
    sta chr_r2
    lda jose_lo,y
    sta fptr
    lda jose_hi,y
    sta fptr+1
    jmp @dc
@lc:
    lda luci_bk,y
    sta chr_r2
    lda luci_lo,y
    sta fptr
    lda luci_hi,y
    sta fptr+1
@dc:
    jsr draw_frame
    lda sx_lo
    sec
    sbc #12
    sta sx_lo
    lda #186
    sta sy
    lda #MF_BAG
    jsr draw_misc
    jsr reset_draw
@parked:
    lda #212
    sta sx_lo
    lda #0
    sta sx_hi
    lda #204
    sta sy
    lda #MF_MOTO
    jmp draw_misc
@ride:
    sec
    sbc #160
    asl
    clc
    adc #212
    sta sx_lo
    lda #0
    adc #0
    sta sx_hi
    lda #204
    sta sy
    lda frame
    lsr
    lsr
    and #1
    tay
    lda char
    bne @lm
    lda jose_moto_bk,y
    sta chr_r2
    lda jose_moto_lo,y
    sta fptr
    lda jose_moto_hi,y
    sta fptr+1
    jmp draw_frame
@lm:
    lda luci_moto_bk,y
    sta chr_r2
    lda luci_moto_lo,y
    sta fptr
    lda luci_moto_hi,y
    sta fptr+1
    jmp draw_frame

; ---------------------------------------------------------------- intro de nivel
intro_init:
    jsr ppu_off
    lda #0
    jsr mus_play
    lda #0
    sta chr_r0
    lda level
    asl
    asl
    asl
    sta tmp0
    asl
    clc
    adc tmp0
    tax
    lda level_tbl+19,x
    sta stars
    lda level_tbl+18,x
    sta faction
    lda level_tbl+20,x
    sta boss_id
    lda #0
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
    lda #$92
    sta PPUADDR
    jsr write_stars
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$10
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
    lda boss_id
    asl
    tax
    lda bname_tbl,x
    sta ptr
    lda bname_tbl+1,x
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
    ldx #40
    ldy #8
    jsr fill_attr
    lda #$FF
    ldx #32
    ldy #8
    jsr fill_attr
    lda #<pal_intro
    ldx #>pal_intro
    jsr load_pal_ptr
    jsr clear_oam
    lda #ST_INTRO
    sta state
    lda #170
    sta timer
    jmp ppu_enable

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

; ---------------------------------------------------------------- texto
text_screen:           ; A/X = cadenas, Y = estado, ptr2 = extra
    sty tmp6
    pha
    txa
    pha
    jsr ppu_off
    lda #0
    sta chr_r0
    lda #0
    jsr mus_play
    lda #0
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

; ---------------------------------------------------------------- textos
title_strs:
    .str $21A6, "LA GRAN PERSECUCION"
    .str $2289, "PRESIONA START"
    .str $2386, "2026  HOMEBREW  MMC3"
    .byte 0
select_strs:
    .str $2087, "ELIGE TU PERSONAJE"
    .str $2208, "JOSE"
    .str $2213, "LUCIANA"
    .str $22E3, "B GOLPE/DISPARO    A SALTO"
    .str $2323, "A+B SUBIR/BAJAR VEHICULO"
    .str $2363, "ARRIBA/ABAJO PROFUNDIDAD"
    .byte 0
sel_jose: .ltext "JOSE DUALCORE"
sel_luci: .ltext "LUCIANA CARRETERAS"
intro_strs:
    .str $210B, "NIVEL"
    .str $228A, "BUSCADO"
    .str $230A, "VIDAS X"
    .str $220D, "JEFE:"
    .byte 0
pol_str:
    .str $2386, "LA POLICIA TE PERSIGUE!"
    .byte 0
mil_str:
    .str $2386, "EL EJERCITO TE PERSIGUE!"
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
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$27,$12, $0F,$0F,$27,$30
pal_select:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$2C,$00, $0F,$2C,$30,$00
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$30,$25, $0F,$0F,$27,$30
pal_intro:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$16,$28, $0F,$30,$16,$28
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$27,$12, $0F,$0F,$27,$30
pal_cut:
    .byte $0F,$00,$10,$30, $0F,$2D,$10,$28, $0F,$30,$10,$00, $0F,$28,$16,$28
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$27,$12, $0F,$0F,$27,$30
