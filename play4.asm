; =====================================================================
;  JUEGO v4 (2 jugadores, armas, patrulleros)
; =====================================================================
W_PUNO = 0
W_PIST = 1
W_ESCO = 2
W_METR = 3
W_BAZU = 4

; ---------------------------------------------------------------- contexto de jugador
player_ptr:            ; X -> ptr = p_base + 32*X
    lda #<p_base
    cpx #0
    beq @a
    lda #<p_base+32
@a:
    sta ptr
    lda #>p_base
    sta ptr+1
    rts

load_player:           ; X = jugador
    cpx cur
    beq @pad
    stx cur
    jsr player_ptr
    ldy #31
@l:
    lda (ptr),y
    sta CTX,y
    dey
    bpl @l
@pad:
    lda pad_a,x
    sta pad
    lda padn_a,x
    sta pad_new
    rts

store_player:
    ldx cur
    jsr player_ptr
    ldy #31
@l:
    lda CTX,y
    sta (ptr),y
    dey
    bpl @l
    rts

; valores de un jugador sin cargar contexto: offsets
PO_XLO = 0
PO_XHI = 1
PO_Y = 3
PO_Z = 4
PO_DEAD = 29
PO_ON = 31
PO_ST = 10

; ---------------------------------------------------------------- inicio de nivel
level_init:
    lda level
    cmp #HELI_LVL
    bne @nh
    jmp heli_enter
@nh:
    cmp #AGUA_LVL
    bne @na
    jmp agua_enter
@na:
    jsr ppu_off
    lda #1
    jsr mus_play
    jsr lvl_index
    stx lvl_x
    lda level_tbl,x
    sta seq_ptr
    lda level_tbl+1,x
    sta seq_ptr+1
    lda level_tbl+2,x
    sta ptr
    lda level_tbl+3,x
    sta ptr+1
    lda level_tbl+4,x
    sta wave_ptr
    lda level_tbl+5,x
    sta wave_ptr+1
    lda level_tbl+8,x
    sta blk_ptr
    lda level_tbl+9,x
    sta blk_ptr+1
    lda level_tbl+10,x
    sta street_ptr
    lda level_tbl+11,x
    sta street_ptr+1
    lda level_tbl+12,x
    sta far_ptr
    lda level_tbl+13,x
    sta far_ptr+1
    lda level_tbl+18,x
    sta wtile_ptr
    lda level_tbl+19,x
    sta wtile_ptr+1
    lda level_tbl+20,x
    sta chr_r0
    lda level_tbl+21,x
    sta chr_r1
    lda level_tbl+22,x
    sta faction
    lda level_tbl+23,x
    sta stars
    lda level_tbl+24,x
    sta boss_id
    jsr load_palette
    jsr set_shirt
    lda #UNIT_COP
    ldx faction
    beq @c
    lda #UNIT_SOLDIER
@c:
    sta chr_r45
    ldx #0
    lda #0
@cl:
    sta $0300,x
    inx
    cpx #$B0
    bne @cl
    ldx #0
@cw:
    sta w_t,x
    inx
    cpx #$20
    bne @cw
    sta bgq_n
    sta cam_lo
    sta cam_hi
    sta tc_lo
    sta tc_hi
    sta col_pending
    sta attr_pending
    sta in_wave
    sta boss_on
    sta b_st
    sta alive
    sta go_t
    sta shake
    lda #$FF
    sta token
    lda #<$600
    sta cam_max_lo
    lda #>$600
    sta cam_max_hi
    ; jugadores
    ldx #0
@pl:
    stx tmp10
    lda #$FF
    sta cur
    jsr load_player
    lda p_on
    beq @np
    lda #16
    sta hp
    lda #0
    sta px_hi
    sta pz
    sta vz_lo
    sta vz_hi
    sta vx
    sta pst
    sta pdir
    sta pveh
    sta vhits
    sta dead_t
    sta combo
    sta shoot_cd
    lda #40
    ldx tmp10
    beq @x0
    lda #64
@x0:
    sta px_lo
    lda #188
    ldx tmp10
    beq @y0
    lda #212
@y0:
    sta py
    lda #60
    sta inv
    lda weap
    bne @hw
    lda #W_PIST
    sta weap
    lda #15
    sta ammo
@hw:
    jsr store_player
@np:
    ldx tmp10
    inx
    cpx #2
    bne @pl
    lda #$FF
    sta cur
    jsr next_wave_lock
    ; vehiculos estacionados
    ldx lvl_x
    lda level_tbl+6,x
    sta ptr2
    lda level_tbl+7,x
    sta ptr2+1
    ldy #0
    ldx #0
@v:
    lda (ptr2),y
    cmp #$FF
    beq @vd
    jsr mc_to_x
    lda tmp0
    sta vo_xlo,x
    lda tmp1
    sta vo_xhi,x
    iny
    lda (ptr2),y
    sta vo_t,x
    iny
    lda (ptr2),y
    sta vo_y,x
    iny
    inx
    cpx #NVO
    bne @v
@vd:
    ; armas colocadas en el nivel
    ldx lvl_x
    lda level_tbl+16,x
    sta ptr2
    lda level_tbl+17,x
    sta ptr2+1
    ldy #0
    ldx #0
@w:
    lda (ptr2),y
    cmp #$FF
    beq @wd
    jsr mc_to_x
    lda tmp0
    sta w_xlo,x
    lda tmp1
    sta w_xhi,x
    iny
    lda (ptr2),y
    sta w_t,x
    iny
    lda (ptr2),y
    sta w_y,x
    lda #0
    sta w_paint,x
    iny
    inx
    cpx #NW
    bne @w
@wd:
level_draw:
    lda #0
    jsr clear_nt
    jsr hud_static
    lda #$20
    jsr draw_far
    lda #$24
    jsr draw_far
    lda #$00
    ldx #0
    ldy #8
    jsr fill_attr
    lda #$55
    ldx #8
    ldy #8
    jsr fill_attr
    bit PPUSTATUS
    lda #$27
    sta PPUADDR
    lda #$C8
    sta PPUADDR
    ldx #8
    lda #$55
@a2:
    sta PPUDATA
    dex
    bne @a2
    lda #34
    sta col_cnt
@ic:
    jsr build_column
    jsr nmi_column
    inc tc_lo
    bne @i2
    inc tc_hi
@i2:
    dec col_cnt
    bne @ic
    jsr hud_prepare
    jsr clear_oam
    lda #ST_PLAY
    sta state
    lda #1
    sta game_irq
    jmp ppu_enable

; pausa: el codigo vive en el banco 7 (se mapea con NMI apagado un instante)
pause_open:            ; A = botones, X = jugador
    tay
    and #BTN_SEL
    beq @p
    ; SELECT: pantalla del arsenal (banco 7)
    stx pz_pl
    jsr ppu_off
    lda #7
    jsr r6_set
    jmp ars_init_b
@p:
    tya
    pha
    lda #7
    jsr bank_safe
    pla
    jsr pause_open_b
    jmp bank0_safe
st_pause:
    lda #7
    jsr bank_safe
    jsr pause_tick_b
    jmp bank0_safe
ars_exit:
    jsr ppu_off
    jsr r6_zero
    lda #$88
    sta ctrl_base
    jmp level_resume
; nivel helicoptero (banco 8): entrada y salidas
heli_enter:
    jsr ppu_off
    lda #8
    jsr r6_set
    jmp heli_init
agua_enter:
    jsr ppu_off
    lda #9
    jsr r6_set
    jmp agua_init
heli_out_clear:
    jsr ppu_off
    jsr r6_zero
    jmp level_clear
heli_out_dead:
    jsr ppu_off
    jsr r6_zero
    lda continues
    bne @c
    jmp gameover_init
@c:
    jmp cont_init
bank0_safe:
    lda #0
bank_safe:
    pha
    lda ctrl_base
    and #$7F
    sta PPUCTRL
    lda #6
    sta $8000
    pla
    sta $8001
    lda ctrl_base
    sta PPUCTRL
    rts

; volver al juego en el mismo lugar (despues de continuar)
level_resume:
    lda level
    cmp #HELI_LVL
    bne @nh
    jmp heli_enter
@nh:
    cmp #AGUA_LVL
    bne @na
    jmp agua_enter
@na:
    jsr ppu_off
    lda #1
    jsr mus_play
    jsr lvl_index
    stx lvl_x
    lda level_tbl+20,x
    sta chr_r0
    lda level_tbl+21,x
    sta chr_r1
    lda level_tbl+2,x
    sta ptr
    lda level_tbl+3,x
    sta ptr+1
    jsr load_palette
    jsr set_shirt
    lda #UNIT_COP
    ldx faction
    beq @c
    lda #UNIT_SOLDIER
@c:
    ldx boss_on
    beq @c2
    ldx boss_id
    lda boss_units,x
    sta chr_r45
    jsr boss_pal
    lda #2
    jsr mus_play
    jmp @c3
@c2:
    sta chr_r45
@c3:
    lda #0
    ldx #NW-1
@w:
    sta w_paint,x
    dex
    bpl @w
    sta bgq_n
    sta col_pending
    sta attr_pending
    ; tc = cam / 8
    lda cam_hi
    sta tc_hi
    lda cam_lo
    lsr tc_hi
    ror
    lsr tc_hi
    ror
    lsr tc_hi
    ror
    sta tc_lo
    jmp level_draw

lvl_index:             ; X = level*25 (entrada de level_tbl)
    lda level
    asl
    asl
    asl
    sta tmp0
    asl
    clc
    adc tmp0
    adc level
    tax
    rts

mc_to_x:               ; A = metacol -> tmp0/1 = A*16 (preserva X,Y)
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
    rts

set_shirt:             ; color de camisa (Luciana siempre rosa; en 2P la paleta es compartida)
    lda #$25
    ldx two_p
    bne @j
    ldx p_base+30
    bne @j
    lda #$2C
@j:
    sta pal_buf+23
    lda #1
    sta pal_dirty
    rts

hud_static:
    lda #<hud_common
    ldx #>hud_common
    jsr draw_ptr
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$21
    sta PPUADDR
    lda p_base+30
    jsr write_pname
    lda two_p
    beq @r
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$41
    sta PPUADDR
    lda p_base+32+30
    jsr write_pname
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$56
    sta PPUADDR
    lda #56
    sta PPUDATA
@r:
    rts

write_pname:           ; A = personaje
    asl
    asl
    tax
    ldy #4
@l:
    lda pnames,x
    sta PPUDATA
    inx
    dey
    bne @l
    rts
pnames:
    .text "JOSE"
    .text "LUCI"

draw_far:
    sta tmp2
    lda #0
    sta tmp3
@row:
    lda tmp3
    clc
    adc #4
    asl
    asl
    asl
    asl
    asl
    sta tmp0
    lda tmp2
    bit PPUSTATUS
    sta PPUADDR
    lda tmp0
    sta PPUADDR
    lda tmp3
    asl
    asl
    asl
    asl
    sta tmp4
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
    cmp #4
    bne @row
    rts

; ---------------------------------------------------------------- columnas
block_ptr:
    cpy #LEVEL_MC
    bcc @in
    lda #0
    beq @b
@in:
    lda (seq_ptr),y
@b:
    sta tmp0
    asl
    asl
    sta tmp2
    lda tmp0
    asl
    asl
    asl
    asl
    asl
    sec
    sbc tmp2
    clc
    adc blk_ptr
    sta ptr2
    lda blk_ptr+1
    adc #0
    sta ptr2+1
    rts

build_column:
    lda tc_lo
    and #31
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
    sta tmp8
    tay
    jsr block_ptr
    lda tc_lo
    and #1
    beq @h0
    lda #10
@h0:
    tay
    ldx #0
@r:
    lda (ptr2),y
    sta col_buf,x
    iny
    inx
    cpx #10
    bne @r
    lda tc_lo
    and #3
    tay
@s:
    lda (street_ptr),y
    sta col_buf,x
    iny
    iny
    iny
    iny
    inx
    cpx #22
    bne @s
    lda tc_lo
    and #3
    bne @na
    lda col_addr_hi
    and #$24
    ora #$03
    sta attr_hi
    lda tc_lo
    lsr
    lsr
    and #7
    sta attr_col
    ldy #20
    ldx #0
@lp:
    lda (ptr2),y
    sta tmp0,x
    iny
    inx
    cpx #5
    bne @lp
    ldy tmp8
    iny
    jsr block_ptr
    ldy #20
    ldx #0
@rp:
    lda (ptr2),y
    sta tmp5,x
    iny
    inx
    cpx #5
    bne @rp
    lda tmp6
    asl
    asl
    asl
    asl
    ora tmp1
    asl
    asl
    asl
    asl
    ora tmp5
    asl
    asl
    ora tmp0
    sta attr_buf
    lda tmp8
    asl
    asl
    asl
    asl
    ora tmp3
    asl
    asl
    ora tmp7
    asl
    asl
    ora tmp2
    sta attr_buf+1
    lda #$F0
    ora tmp4
    sta tmp10
    lda tmp9
    asl
    asl
    ora tmp10
    sta attr_buf+2
    lda #$FF
    sta attr_buf+3
    sta attr_buf+4
    sta attr_buf+5
    lda #1
    sta attr_pending
@na:
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

; ---------------------------------------------------------------- armas en el piso (tiles de fondo)
bgq_add:               ; tmp0 hi, tmp1 lo, A tile
    ldx bgq_n
    cpx #8
    bcs @r
    sta bgq_t,x
    lda tmp0
    sta bgq_hi,x
    lda tmp1
    sta bgq_lo,x
    inc bgq_n
@r:
    rts

; tmp2/tmp3 = columna de tile (16 bits), tmp4 = fila -> tmp0/tmp1 = direccion PPU
tile_addr:
    lda tmp4
    sta tmp1
    lda #0
    sta tmp0
    ldx #5
@s:
    asl tmp1
    rol tmp0
    dex
    bne @s
    lda tmp2
    and #31
    ora tmp1
    sta tmp1
    lda tmp2
    and #32
    lsr
    lsr
    lsr
    ora #$20
    ora tmp0
    sta tmp0
    rts

weap_tiles:            ; X slot -> tmp2/3 col, tmp4 fila
    lda w_xhi,x
    sta tmp3
    lda w_xlo,x
    lsr tmp3
    ror
    lsr tmp3
    ror
    lsr tmp3
    ror
    sta tmp2
    lda w_y,x
    lsr
    lsr
    lsr
    sec
    sbc #1
    sta tmp4
    rts

weap_paint:            ; X slot, Y = 0 pintar / 1 borrar
    sty tmp9
    stx tmp8
    jsr weap_tiles
    lda #0
    sta tmp5
@h:
    jsr tile_addr
    lda tmp9
    bne @erase
    ldx tmp8
    lda w_t,x
    sec
    sbc #1
    asl
    clc
    adc tmp5
    tay
    lda (wtile_ptr),y
    jmp @q
@erase:
    lda tmp4
    sec
    sbc #18
    asl
    asl
    sta tmp6
    lda tmp2
    and #3
    ora tmp6
    tay
    lda (street_ptr),y
@q:
    jsr bgq_add
    inc tmp2
    bne @n
    inc tmp3
@n:
    inc tmp5
    lda tmp5
    cmp #2
    bne @h
    ldx tmp8
    ; atributo: cuadrante a paleta 0 (negro/blanco/rojo) para que se vea sobre la calle
    jsr weap_tiles
    lda #$23
    sta tmp0
    lda tmp2
    and #32
    beq @nt
    lda #$27
    sta tmp0
@nt:
    lda tmp4
    and #$FC
    asl
    sta tmp1
    lda tmp2
    and #31
    lsr
    lsr
    ora tmp1
    ora #$C0
    sta tmp1
    lda #$FF
    ldy tmp9
    bne @at
    lda tmp4
    and #2
    sta tmp6
    lda tmp2
    and #2
    lsr
    ora tmp6
    tay
    lda heart_mask,y
@at:
    jsr bgq_add
    ldx tmp8
@done:
    rts
heart_mask: .byte $FC, $F3, $CF, $3F

weapons_update:
    ldx #0
@l:
    lda w_t,x
    beq @n
    ; detras de la camara: desaparece
    lda w_xlo,x
    clc
    adc #16
    sta tmp0
    lda w_xhi,x
    adc #0
    sta tmp1
    lda tmp0
    cmp cam_lo
    lda tmp1
    sbc cam_hi
    bcs @vis
    lda #0
    sta w_t,x
    jmp @n
@vis:
    lda w_paint,x
    bne @n
    ; columna ya construida? (col+2 < tc) y en pantalla
    jsr weap_tiles
    lda tmp2
    clc
    adc #4
    sta tmp0
    lda tmp3
    adc #0
    sta tmp1
    lda tmp0
    cmp tc_lo
    lda tmp1
    sbc tc_hi
    bcs @n
    lda w_xlo,x
    cmp cam_lo
    lda w_xhi,x
    sbc cam_hi
    bcc @n
    lda bgq_n
    cmp #5
    bcs @n
    lda #1
    sta w_paint,x
    ldy #0
    jsr weap_paint
@n:
    inx
    cpx #NW
    bne @l
    rts

; A = tipo, np_xlo/hi, np_y
drop_weapon:
    sta tmp7
    ldx #0
@f:
    lda w_t,x
    beq @g
    inx
    cpx #NW
    bne @f
    rts
@g:
    lda tmp7
    sta w_t,x
    lda np_xlo
    and #$F0
    sta w_xlo,x
    lda np_xhi
    sta w_xhi,x
    lda np_y
    cmp #208
    bcs @y
    lda #208
@y:
    sta w_y,x
    lda #0
    sta w_paint,x
    rts

random_drop:           ; segun faccion -> A tipo
    jsr rand
    and #15
    ldx faction
    beq @p
    tax
    lda drop_mil,x
    rts
@p:
    tax
    lda drop_pol,x
    rts
drop_pol: .byte 1, 1, 1, 1, 2, 2, 3, 1, 5, 1, 2, 5, 1, 3, 5, 1
drop_mil: .byte 3, 3, 3, 2, 2, 4, 4, 1, 5, 3, 2, 4, 3, 5, 1, 6
ammo_tbl: .byte 0, 15, 8, 40, 4, 0, 3

try_pickup:            ; contexto cargado
    lda pveh
    beq @__n867_0
    jmp @r
@__n867_0:
    lda pz
    beq @__n871_1
    jmp @r
@__n871_1:
    ldx #0
@l:
    lda w_t,x
    bne @__n877_2
    jmp @n
@__n877_2:
    lda w_xlo,x
    clc
    adc #8
    sta tmp0
    lda w_xhi,x
    adc #0
    sta tmp1
    lda tmp0
    sec
    sbc px_lo
    sta tmp0
    lda tmp1
    sbc px_hi
    sta tmp1
    jsr abs16
    lda tmp2
    cmp #12
    bcc @__n985_0
    jmp @n
@__n985_0:
    lda w_y,x
    sec
    sbc py
    bcs @a
    eor #$FF
    adc #1
@a:
    cmp #10
    bcs @n
    ; recoger
    lda w_t,x
    cmp #W_CORA
    bne @arma
    lda hp
    clc
    adc #8
    cmp #16
    bcc @h
    lda #16
@h:
    sta hp
    jmp @tk
@arma:
    lda w_t,x
    cmp weap
    beq @same
    ; va al inventario del jugador
    sta tmp0
    lda cur
    asl
    asl
    asl
    ora tmp0
    tay
    lda tmp0
    pha
    lda inv_ammo,y
    sty tmp1
    ldy tmp0
    clc
    adc ammo_tbl,y
    cmp #99
    bcc @i9
    lda #99
@i9:
    ldy tmp1
    sta inv_ammo,y
    pla
    ldy weap
    bne @tk
    ; con las manos vacias: la equipa
    sta weap
    ldy tmp1
    lda inv_ammo,y
    sta ammo
    lda #0
    sta inv_ammo,y
    jmp @tk
@same:
    tay
    lda ammo
    clc
    adc ammo_tbl,y
    cmp #99
    bcc @s
    lda #99
@s:
    sta ammo
@tk:
    lda w_paint,x
    beq @np
    ldy #1
    jsr weap_paint
@np:
    lda #0
    sta w_t,x
    jsr sfx_power
    rts
@n:
    inx
    cpx #NW
    beq @__n952_3
    jmp @l
@__n952_3:
@r:
    rts

; ---------------------------------------------------------------- oleadas y camara
next_wave_lock:
    ldy #0
    lda (wave_ptr),y
    cmp #$FF
    beq @none
    jsr mc_to_x
    lda tmp0
    sta lock_lo
    lda tmp1
    sta lock_hi
    rts
@none:
    lda cam_max_lo
    sta lock_lo
    lda cam_max_hi
    sta lock_hi
    rts

players_span:          ; tmp4/5 = x maximo, tmp6/7 = x minimo de jugadores vivos; C=0 si ninguno
    lda #0
    sta tmp4
    sta tmp5
    lda #$FF
    sta tmp6
    sta tmp7
    lda #0
    sta tmp8
    ldx #0
@l:
    lda p_base+PO_ON,x
    beq @n
    lda p_base+PO_DEAD,x
    bne @n
    inc tmp8
    lda p_base+PO_XLO,x
    cmp tmp4
    lda p_base+PO_XHI,x
    sbc tmp5
    bcc @nm
    lda p_base+PO_XLO,x
    sta tmp4
    lda p_base+PO_XHI,x
    sta tmp5
@nm:
    lda p_base+PO_XLO,x
    cmp tmp6
    lda p_base+PO_XHI,x
    sbc tmp7
    bcs @n
    lda p_base+PO_XLO,x
    sta tmp6
    lda p_base+PO_XHI,x
    sta tmp7
@n:
    txa
    clc
    adc #32
    tax
    cpx #64
    bne @l
    lda tmp8
    cmp #1
    rts

camera_update:
    lda in_wave
    beq @a
    jmp @r
@a:
    lda boss_on
    beq @b
    jmp @r
@b:
    jsr players_span
    bcs @c
    jmp @r
@c:
    ; objetivo = max - 112, pero no mas que min - 16
    lda tmp4
    sec
    sbc #112
    sta tmp0
    lda tmp5
    sbc #0
    sta tmp1
    lda tmp6
    sec
    sbc #16
    sta tmp2
    lda tmp7
    sbc #0
    sta tmp3
    lda tmp2
    cmp tmp0
    lda tmp3
    sbc tmp1
    bcs @t
    lda tmp2
    sta tmp0
    lda tmp3
    sta tmp1
@t:
    lda tmp1
    bmi @chk
    lda tmp0
    cmp lock_lo
    lda tmp1
    sbc lock_hi
    bcc @lim
    lda lock_lo
    sta tmp0
    lda lock_hi
    sta tmp1
@lim:
    lda tmp0
    sec
    sbc cam_lo
    sta tmp2
    lda tmp1
    sbc cam_hi
    bmi @chk
    bne @big
    lda tmp2
    beq @chk
    lsr
    lsr
    clc
    adc #1
    cmp #6
    bcc @add
@big:
    lda #6
@add:
    clc
    adc cam_lo
    sta cam_lo
    bcc @chk
    inc cam_hi
@chk:
    lda cam_lo
    cmp lock_lo
    bne @r
    lda cam_hi
    cmp lock_hi
    bne @r
    ldy #0
    lda (wave_ptr),y
    cmp #$FF
    beq @boss
    iny
    lda (wave_ptr),y
    sta to_spawn
    iny
    lda (wave_ptr),y
    sta cars_left
    lda #1
    sta in_wave
    lda #20
    sta spawn_cd
    lda wave_ptr
    clc
    adc #3
    sta wave_ptr
    bcc @r
    inc wave_ptr+1
@r:
    rts
@boss:
    jmp boss_spawn

waves_update:
    lda go_t
    beq @ng
    dec go_t
@ng:
    lda in_wave
    beq @r
    lda spawn_cd
    beq @sp
    dec spawn_cd
    rts
@sp:
    lda to_spawn
    beq @end
    lda alive
    cmp #2
    bcs @r
    lda to_spawn
    cmp #1
    bne @g
    lda cars_left
    beq @g
    jsr spawn_car
    jmp @c
@g:
    jsr spawn_grunt
@c:
    bcc @r
    dec to_spawn
    lda #50
    sta spawn_cd
@r:
    rts
@end:
    lda alive
    bne @r
    lda #0
    sta in_wave
    lda #150
    sta go_t
    jmp next_wave_lock

free_slot:             ; -> X, C=1 si hay
    ldx #0
@f:
    lda en_t,x
    beq @got
    inx
    cpx #NEN
    bne @f
    clc
    rts
@got:
    lda #0
    sta en_z,x
    sta en_vz,x
    sta en_st,x
    sta en_inv,x
    sta en_dead,x
    sta en_flash,x
    sta en_anim,x
    sta en_tgt,x
    sec
    rts

spawn_grunt:
    jsr free_slot
    bcs @ok
    rts
@ok:
    lda #1
    sta en_t,x
    inc alive
    lda spawn_side
    eor #1
    sta spawn_side
    beq @left
    lda cam_lo
    clc
    adc #20
    sta en_xlo,x
    lda cam_hi
    adc #1
    sta en_xhi,x
    lda #1
    sta en_dir,x
    jmp @y
@left:
    lda cam_lo
    sec
    sbc #20
    sta en_xlo,x
    lda cam_hi
    sbc #0
    sta en_xhi,x
    lda #0
    sta en_dir,x
@y:
    jsr rand_lane
    sta en_y,x
    lda #10
    ldy faction
    beq @hp
    lda #14
@hp:
    clc
    adc level
    sta en_hp,x
    jsr rand
    and #1
    sta en_mode,x
    lda #40
    sta en_cd,x
    sec
    rts

rand_lane:
    jsr rand
    and #63
    clc
    adc #YMIN
    cmp #YMAX
    bcc @r
    lda #YMAX
@r:
    rts

spawn_car:
    jsr free_slot
    bcs @ok
    rts
@ok:
    dec cars_left
    lda #2
    sta en_t,x
    inc alive
    lda cam_lo
    clc
    adc #40
    sta en_xlo,x
    lda cam_hi
    adc #1
    sta en_xhi,x
    lda #1
    sta en_dir,x
    jsr rand_lane
    sta en_y,x
    lda #16
    clc
    adc level
    adc level
    sta en_hp,x
    lda #50
    sta en_cd,x
    sec
    rts

; ---------------------------------------------------------------- bucle de juego
st_play:
    ; START = pausa, SELECT = inventario (lo abre el jugador que lo pide)
    lda padn1
    and #BTN_START|BTN_SEL
    beq @q2
    ldx p_base+PO_ON
    beq @q2
    ldx #0
    jmp pause_open
@q2:
    lda two_p
    beq @q3
    lda padn2
    and #BTN_START|BTN_SEL
    beq @q3
    ldx p_base+32+PO_ON
    beq @q3
    ldx #1
    jmp pause_open
@q3:
    lda pad1
    sta pad_a
    lda padn1
    sta padn_a
    lda pad2
    sta pad_a+1
    lda padn2
    sta padn_a+1
    ldx #0
    jsr player_tick
    ldx #1
    jsr player_tick
    ; alguien vivo?
    lda p_base+PO_ON
    ora p_base+32+PO_ON
    bne @ok
    lda continues
    bne @cn
    jmp gameover_init
@cn:
    jmp cont_init
@ok:
    jsr camera_update
    jsr stream_columns
    jsr waves_update
    jsr weapons_update
    jsr enemies_update
    jsr boss_update
    lda state
    cmp #ST_PLAY
    bne @out
    jsr proj_update
    jsr fx_update
    jsr hud_prepare
    jsr draw_all
@out:
    rts

player_tick:           ; X = jugador
    lda p_base+PO_ON
    cpx #0
    beq @a
    lda p_base+32+PO_ON
@a:
    cmp #0
    bne @on
    ; fuera de juego: START usa un continue
    cpx #0
    beq @pp
    lda two_p
    beq @nr
@pp:
    lda continues
    beq @nr
    lda padn_a,x
    and #BTN_START
    beq @nr
    jmp revive_player
@nr:
    rts
@on:
    jsr load_player
    lda dead_t
    beq @alive
    dec dead_t
    bne @st
    dec lives
    beq @out
    lda #16
    sta hp
    lda #0
    sta pst
    sta pveh
    sta pz
    sta vz_lo
    sta vz_hi
    lda #120
    sta inv
    lda #W_PIST
    sta weap
    lda #15
    sta ammo
    lda cam_lo
    clc
    adc #48
    sta px_lo
    lda cam_hi
    adc #0
    sta px_hi
    lda #196
    sta py
    jmp @st
@out:
    lda #0
    sta p_on
    jmp @st
@alive:
    jsr player_update
@st:
    jmp store_player

revive_player:         ; X = jugador: continuar en el mismo lugar
    dec continues
    lda #0
    sta cont_t
    stx tmp10
    jsr load_player
    lda #1
    sta p_on
    lda #3
    sta lives
    lda #16
    sta hp
    lda #0
    sta dead_t
    sta pst
    sta pveh
    sta pz
    sta vz_lo
    sta vz_hi
    sta vx
    sta combo
    sta shoot_cd
    lda #120
    sta inv
    lda #W_PIST
    sta weap
    lda #15
    sta ammo
    lda #48
    ldx tmp10
    beq @x
    lda #80
@x:
    clc
    adc cam_lo
    sta px_lo
    lda cam_hi
    adc #0
    sta px_hi
    lda #196
    sta py
    jsr sfx_power
    jmp store_player

; ---------------------------------------------------------------- jugador
veh_max: .byte 22, 52, 60, 40
veh_acc: .byte 4, 3, 2, 6
veh_half: .byte 8, 18, 24, 8

player_update:
    lda inv
    beq @i0
    dec inv
@i0:
    lda shoot_cd
    beq @i1
    dec shoot_cd
@i1:
    lda combo_t
    beq @i2
    dec combo_t
    bne @i2
    lda #0
    sta combo
@i2:
    lda combo_cd
    beq @i3
    dec combo_cd
@i3:
    jsr combo_check
    jsr try_pickup
    lda pst
    asl
    tax
    lda ps_tbl+1,x
    pha
    lda ps_tbl,x
    pha
    rts
ps_tbl:
    .word ps_norm-1, ps_punch-1, ps_shoot-1, ps_hurt-1, ps_down-1, ps_kick-1, ps_dead-1

ps_dead:
    lda #15
    sta pframe
    rts

combo_check:
    lda pad_new
    and #BTN_A
    beq @a1
    lda #0
    sta a_age
    beq @a2
@a1:
    lda a_age
    cmp #255
    beq @a2
    inc a_age
@a2:
    lda pad_new
    and #BTN_B
    beq @b1
    lda #0
    sta b_age
    beq @b2
@b1:
    lda b_age
    cmp #255
    beq @b2
    inc b_age
@b2:
    lda pad
    and #BTN_A|BTN_B
    cmp #BTN_A|BTN_B
    bne @no
    lda pad_new
    and #BTN_A|BTN_B
    beq @no
    lda a_age
    cmp #5
    bcs @no
    lda b_age
    cmp #5
    bcs @no
    lda combo_cd
    bne @no
    lda pst
    cmp #PS_NORM
    beq @t
    cmp #PS_PUNCH
    beq @t
    cmp #PS_SHOOT
    bne @no
@t:
    jsr toggle_vehicle
    bcc @no
    lda #16
    sta combo_cd
    lda #PS_NORM
    sta pst
    lda #0
    sta pz
    sta vz_lo
    sta vz_hi
    sta pad_new
@no:
    rts

move_player:
    ldx pveh
    bne @m0
    ldy cur
    lda run_f,y
    beq @m0
    ldx #3                 ; corriendo
@m0:
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
    beq @fr
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
@fr:
    lda vx
    beq @setv
    bmi @fn
    sec
    sbc #4
    bpl @setv
    lda #0
    beq @setv
@fn:
    clc
    adc #4
    bmi @setv
    lda #0
@setv:
    sta vx
    lda pad
    and #BTN_UP
    beq @nu
    lda py
    cmp #YMIN+1
    bcc @nu
    dec py
    lda pveh
    beq @nu
    lda frame
    and #1
    beq @nu
    lda py
    cmp #YMIN+1
    bcc @nu
    dec py
@nu:
    lda pad
    and #BTN_DOWN
    beq @nd
    lda py
    cmp #YMAX
    bcs @nd
    inc py
    lda pveh
    beq @nd
    lda frame
    and #1
    beq @nd
    lda py
    cmp #YMAX
    bcs @nd
    inc py
@nd:
apply_vx:
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
    bcc @p
    dey
@p:
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
clamp_px:
    lda cam_lo
    clc
    adc #12
    sta tmp0
    lda cam_hi
    adc #0
    sta tmp1
    lda px_lo
    cmp tmp0
    lda px_hi
    sbc tmp1
    bcs @l
    lda tmp0
    sta px_lo
    lda tmp1
    sta px_hi
    lda #0
    sta vx
@l:
    lda cam_lo
    clc
    adc #244
    sta tmp0
    lda cam_hi
    adc #0
    sta tmp1
    lda tmp0
    cmp px_lo
    lda tmp1
    sbc px_hi
    bcs @r
    lda tmp0
    sta px_lo
    lda tmp1
    sta px_hi
    lda #0
    sta vx
@r:
    rts

do_gravity:
    lda pz
    ora vz_hi
    ora vz_lo
    beq @ground
    lda z_frac
    clc
    adc vz_lo
    sta z_frac
    lda pz
    adc vz_hi
    sta pz
    lda vz_lo
    sec
    sbc #$40
    sta vz_lo
    lda vz_hi
    sbc #0
    sta vz_hi
    lda pz
    beq @land
    bmi @land
    clc
    rts
@land:
    lda #0
    sta pz
    sta vz_lo
    sta vz_hi
    sta z_frac
    sec
    rts
@ground:
    clc
    rts

ps_norm:
    lda pveh
    beq @foot
    jmp veh_update
@foot:
    jsr run_check
    jsr move_player
    lda pad_new
    and #BTN_A
    beq @nj
    lda pz
    bne @nj
    lda #$C0
    sta vz_lo
    lda #$04
    sta vz_hi
    lda #1
    sta pz
@nj:
    lda pad_new
    and #BTN_B
    beq @nb
    ; corriendo + golpe = patada voladora
    ldy cur
    lda run_f,y
    beq @nr
    lda pz
    bne @nr
    lda #2
    sta run_f,y
    lda #$80
    sta vz_lo
    lda #$03
    sta vz_hi
    lda #1
    sta pz
    lda #PS_KICK
    sta pst
    lda #0
    sta hitdone
    jmp @nb
@nr:
    lda pz
    beq @gb
    lda #PS_KICK
    sta pst
    lda #0
    sta hitdone
    jmp @nb
@gb:
    jsr enemy_in_reach
    bcs @punch
    lda weap
    beq @punch
    lda shoot_cd
    bne @nb
    lda #PS_SHOOT
    sta pst
    lda #14
    sta ptm
    lda #0
    sta vx
    jmp @nb
@punch:
    lda #PS_PUNCH
    sta pst
    lda #14
    sta ptm
    lda #0
    sta hitdone
    sta vx
@nb:
    ; metralleta: mantener B dispara en rafaga
    lda weap
    cmp #W_METR
    bne @nm
    lda pad
    and #BTN_B
    beq @nm
    lda pz
    bne @nm
    lda shoot_cd
    bne @nm
    lda pst
    bne @nm
    lda #PS_SHOOT
    sta pst
    lda #14
    sta ptm
@nm:
    jsr do_gravity
    lda pz
    beq @g
    lda #6
    sta pframe
    rts
@g:
    ldy cur
    lda run_f,y
    beq @nrun
    ; animacion de correr
    lda frame
    lsr
    lsr
    and #1
    clc
    adc #5
    sta pframe
    rts
@nrun:
    lda vx
    bne @walk
    lda pad
    and #BTN_UP|BTN_DOWN
    bne @walk2
    lda frame
    lsr
    lsr
    lsr
    lsr
    lsr
    and #1
    sta pframe
    rts
@walk2:
    lda #10
    jmp @wa
@walk:
    lda vx
    bpl @wa
    eor #$FF
    clc
    adc #1
@wa:
    clc
    adc walk_t
    sta walk_t
    lsr
    lsr
    lsr
    lsr
    lsr
    and #7
    tax
    lda walk_seq,x
    sta pframe
    rts
walk_seq: .byte 16, 17, 18, 19, 16, 17, 18, 19

combo_frames: .byte 7, 13, 5
combo_dmg: .byte 1, 1, 3

ps_punch:
    ldx combo
    lda combo_frames,x
    sta pframe
    dec ptm
    lda ptm
    cmp #9
    bne @nh
    ldx combo
    lda combo_dmg,x
    ldy #0
    cpx #2
    bne @k
    ldy #1
@k:
    jsr player_melee
@nh:
    lda ptm
    bne @r
    lda #PS_NORM
    sta pst
    lda #24
    sta combo_t
    inc combo
    lda combo
    cmp #3
    bcc @r
    lda #0
    sta combo
@r:
    rts

shoot_cdt: .byte 0, 10, 22, 4, 30, 0, 36
ps_shoot:
    dec ptm
    lda ptm
    cmp #12
    bne @nf
    jsr player_fire
@nf:
    lda ptm
    cmp #13
    bcs @f9
    cmp #8
    bcs @f8
    lda #10
    bne @s
@f9:
    lda #9
    bne @s
@f8:
    lda #8
@s:
    sta pframe
    lda weap
    cmp #W_METR
    bne @nm
    lda ptm
    cmp #9
    bcs @nm
    lda #0
    sta ptm
@nm:
    lda ptm
    bne @r
    lda #PS_NORM
    sta pst
    ldx weap
    lda shoot_cdt,x
    sta shoot_cd
@r:
    rts

ps_hurt:
    lda #14
    sta pframe
    dec ptm
    jsr knock_move
    jsr do_gravity
    lda ptm
    bne @r
    lda #PS_NORM
    sta pst
@r:
    rts

ps_down:
    lda #15
    sta pframe
    dec ptm
    lda ptm
    cmp #30
    bcc @nm
    jsr knock_move
@nm:
    jsr do_gravity
    lda ptm
    bne @r
    lda #PS_NORM
    sta pst
    lda #50
    sta inv
@r:
    rts

knock_move:
    lda kvx
    sta vx
    jsr apply_vx
    lda #0
    sta vx
    rts

ps_kick:
    lda #5
    ldy cur
    ldx run_f,y
    beq @k1
    lda #7                 ; patada voladora
@k1:
    sta pframe
    jsr move_player
    lda hitdone
    bne @nh
    lda #2
    ldy cur
    ldx run_f,y
    beq @k2
    lda #4
@k2:
    ldy #1
    jsr player_melee
    bcc @nh
    lda #1
    sta hitdone
@nh:
    jsr do_gravity
    bcc @r
    lda #PS_NORM
    sta pst
    ldy cur
    lda #0
    sta run_f,y
@r:
    rts

; doble toque adelante = correr (mientras se mantenga la direccion)
run_check:
    ldy cur
    lda tap_t,y
    beq @t0
    sec
    sbc #1
    sta tap_t,y
@t0:
    lda pz
    bne @r
    lda pad_new
    and #BTN_RIGHT|BTN_LEFT
    beq @hold
    and #BTN_RIGHT
    beq @d1
    lda #0
    beq @d
@d1:
    lda #1
@d:
    sta tmp0
    lda tap_t,y
    beq @first
    lda tap_d,y
    cmp tmp0
    bne @first
    lda #1
    sta run_f,y
    lda #0
    sta tap_t,y
    rts
@first:
    lda tmp0
    sta tap_d,y
    lda #14
    sta tap_t,y
@hold:
    lda run_f,y
    beq @r
    ; soltar la direccion corta la carrera
    lda tap_d,y
    bne @hl
    lda pad
    and #BTN_RIGHT
    bne @r
    beq @st
@hl:
    lda pad
    and #BTN_LEFT
    bne @r
@st:
    lda #0
    sta run_f,y
@r:
    rts

; ---------------------------------------------------------------- vehiculos
veh_update:
    jsr move_player
    lda pveh
    cmp #1
    bne @noj
    lda pad_new
    and #BTN_A
    beq @noj
    lda pz
    bne @noj
    lda #$00
    sta vz_lo
    lda #$04
    sta vz_hi
    lda #1
    sta pz
@noj:
    jsr do_gravity
    ; en vehiculo se dispara el arma que se lleva, con las mismas balas (limitadas)
    lda pad
    and #BTN_B
    beq @nf
    lda shoot_cd
    bne @nf
    lda weap
    beq @nf
    jsr player_fire
    ldx weap
    lda shoot_cdt,x
    cmp #10
    bcs @cd
    lda #10
@cd:
    sta shoot_cd
@nf:
    lda vx
    bpl @a
    eor #$FF
    clc
    adc #1
@a:
    cmp #16
    bcc @nr
    ldx #0
@e:
    lda en_t,x
    cmp #1
    bne @ne
    lda en_st,x
    cmp #ES_DOWN
    bcs @ne
    lda en_z,x
    bne @ne
    jsr en_dx
    ldy pveh
    lda tmp2
    cmp veh_half,y
    bcs @ne
    jsr en_dy
    cmp #11
    bcs @ne
    stx tmp11
    lda #5
    ldy #1
    jsr enemy_take
    ldx tmp11
    lda #3
    sta shake
@ne:
    inx
    cpx #NEN
    bne @e
@nr:
    lda vx
    bpl @w
    eor #$FF
    clc
    adc #1
@w:
    clc
    adc walk_t
    sta walk_t
    rol
    rol
    rol
    and #1
    sta tmp0
    lda pveh
    sec
    sbc #1
    asl
    ora tmp0
    sta pframe
    rts

toggle_vehicle:
    lda pveh
    bne @exit
    lda pz
    bne @no
    ldx #0
@s:
    lda vo_t,x
    beq @n
    lda vo_xlo,x
    sec
    sbc px_lo
    sta tmp0
    lda vo_xhi,x
    sbc px_hi
    sta tmp1
    lda tmp0
    clc
    adc #26
    sta tmp0
    lda tmp1
    adc #0
    bne @n
    lda tmp0
    cmp #52
    bcs @n
    lda vo_y,x
    sec
    sbc py
    clc
    adc #14
    cmp #28
    bcs @n
    lda vo_t,x
    sta pveh
    lda vo_xlo,x
    sta px_lo
    lda vo_xhi,x
    sta px_hi
    lda vo_y,x
    sta py
    lda #0
    sta vo_t,x
    sta vhits
    sta vx
    sta pdir
    jsr sfx_power
    sec
    rts
@n:
    inx
    cpx #NVO
    bne @s
@no:
    clc
    rts
@exit:
    lda pz
    bne @no
    ldx #0
@f:
    lda vo_t,x
    beq @got
    inx
    cpx #NVO
    bne @f
    clc
    rts
@got:
    lda pveh
    sta vo_t,x
    lda px_lo
    sta vo_xlo,x
    lda px_hi
    sta vo_xhi,x
    lda py
    sta vo_y,x
    lda #0
    sta pveh
    sta vx
    lda #24
    sta inv
    lda py
    cmp #YMAX-14
    bcs @up
    clc
    adc #14
    sta py
    jmp @ok
@up:
    sec
    sbc #14
    sta py
@ok:
    jsr sfx_shoot
    sec
    rts

veh_destroy:
    lda px_lo
    sta np_xlo
    lda px_hi
    sta np_xhi
    lda py
    sta np_y
    jsr fx_spawn
    lda px_lo
    clc
    adc #12
    sta np_xlo
    lda px_hi
    adc #0
    sta np_xhi
    jsr fx_spawn
    lda #0
    sta pveh
    lda #10
    sta shake
    lda #PS_DOWN
    sta pst
    lda #50
    sta ptm
    lda #$C0
    ldx pdir
    beq @k
    lda #$40
@k:
    sta kvx
    lda #3
    sta vz_hi
    lda #1
    sta pz
    jmp sfx_boom

; ---------------------------------------------------------------- dano al jugador (contexto cargado; guarda al final)
player_hit:
    jsr player_hit2
    jmp store_player
player_hit2:
    sta tmp10
    lda inv
    bne @r
    lda dead_t
    bne @r
    lda pst
    cmp #PS_DOWN
    beq @r
    lda pveh
    beq @foot
    inc vhits
    lda #40
    sta inv
    lda #4
    sta shake
    lda vhits
    cmp #2
    bcc @hs
    jmp veh_destroy
@hs:
    jmp sfx_hit
@foot:
    lda hp
    sec
    sbc tmp10
    bcs @ok
    lda #0
@ok:
    sta hp
    beq @die
    lda #$E0
    ldx tmp9
    beq @kd
    lda #$20
@kd:
    sta kvx
    cpy #1
    beq @down
    lda #PS_HURT
    sta pst
    lda #16
    sta ptm
    lda #40
    sta inv
    jmp sfx_hit
@down:
    lda #PS_DOWN
    sta pst
    lda #50
    sta ptm
    lda #3
    sta vz_hi
    lda #1
    sta pz
    lda #6
    sta shake
    jmp sfx_hit
@die:
    lda #PS_DEAD
    sta pst
    lda #0
    sta pveh
    sta pz
    sta weap
    sta ammo
    lda #120
    sta dead_t
    lda #6
    sta shake
    jmp sfx_boom
@r:
    rts

; ---------------------------------------------------------------- distancias
en_dx:
    lda en_xlo,x
    sec
    sbc px_lo
    sta tmp0
    lda en_xhi,x
    sbc px_hi
    sta tmp1
abs16:
    lda tmp1
    bmi @neg
    beq @lo
    lda #255
    sta tmp2
    rts
@lo:
    lda tmp0
    sta tmp2
    rts
@neg:
    cmp #$FF
    bne @sat
    lda tmp0
    eor #$FF
    clc
    adc #1
    beq @sat
    sta tmp2
    rts
@sat:
    lda #255
    sta tmp2
    rts

en_dy:
    lda en_y,x
    sec
    sbc py
    bcs @r
    eor #$FF
    adc #1
@r:
    rts

in_front:
    lda tmp1
    bmi @left
    lda pdir
    bne @no
    sec
    rts
@left:
    lda pdir
    beq @no
    sec
    rts
@no:
    clc
    rts

enemy_in_reach:
    ldx #0
@e:
    lda en_t,x
    cmp #1
    bne @n
    lda en_st,x
    cmp #ES_DOWN
    bcs @n
    jsr en_dx
    lda tmp2
    cmp #40
    bcs @n
    jsr in_front
    bcc @n
    jsr en_dy
    cmp #13
    bcs @n
    sec
    rts
@n:
    inx
    cpx #NEN
    bne @e
    lda boss_on
    beq @no
    lda b_st
    cmp #9
    beq @no
    jsr boss_dx
    lda b_w
    lsr
    clc
    adc #30
    cmp tmp2
    bcc @no
    beq @no
    jsr in_front
    bcc @no
    lda b_z
    cmp #20
    bcs @no
    jsr boss_dy
    cmp #15
    bcs @no
    sec
    rts
@no:
    clc
    rts

player_melee:
    sta tmp10
    sty tmp11
    lda #0
    sta tmp9
    ldx #0
@e:
    lda en_t,x
    beq @n
    lda en_st,x
    cmp #ES_DOWN
    bcs @n
    lda en_inv,x
    bne @n
    jsr en_dx
    lda tmp2
    ldy en_t,x
    cpy #2
    bne @gr
    cmp #34
    bcs @n
    bcc @cf
@gr:
    cmp #36
    bcs @n
@cf:
    jsr in_front
    bcc @n
    jsr en_dy
    cmp #13
    bcs @n
    lda en_z,x
    sec
    sbc pz
    bcs @zp
    eor #$FF
    adc #1
@zp:
    cmp #24
    bcs @n
    stx tmp8
    lda tmp10
    ldy tmp11
    jsr enemy_take
    ldx tmp8
    lda #1
    sta tmp9
@n:
    inx
    cpx #NEN
    bne @e
    lda boss_on
    beq @fin
    lda b_st
    cmp #9
    beq @fin
    lda b_inv
    bne @fin
    jsr boss_dx
    lda b_w
    lsr
    clc
    adc #26
    cmp tmp2
    bcc @fin
    jsr in_front
    bcc @fin
    jsr boss_dy
    cmp #15
    bcs @fin
    lda b_z
    sec
    sbc pz
    bcs @bz
    eor #$FF
    adc #1
@bz:
    cmp #28
    bcs @fin
    lda tmp10
    jsr boss_take
    lda #1
    sta tmp9
@fin:
    lda tmp9
    beq @no
    jsr sfx_punch
    lda #2
    sta shake
    sec
    rts
@no:
    clc
    rts

; ---------------------------------------------------------------- disparos del jugador
player_fire:
    lda weap
    bne @w
    rts
@w:
    sta tmp11
    jsr fire_weapon
    dec ammo
    bne @r
    lda #W_PUNO
    sta weap
@r:
    rts

fire_weapon:           ; tmp11 = arma
    ; la bala sale de la pistola en la mano (a pie, en moto o en auto)
    ldx pveh
    lda veh_mdz,x
    clc
    adc pz
    sta np_z
    lda py
    sta np_y
    lda veh_mdx,x
    sta tmp0
    lda pdir
    bne @l
    lda px_lo
    clc
    adc tmp0
    sta np_xlo
    lda px_hi
    adc #0
    sta np_xhi
    lda #6
    jmp @v
@l:
    lda px_lo
    sec
    sbc tmp0
    sta np_xlo
    lda px_hi
    sbc #0
    sta np_xhi
    lda #$FA
@v:
    sta np_vx
    lda #1
    sta np_vz
    lda tmp11
    cmp #W_ESCO
    beq @sg
    cmp #W_BAZU
    beq @bz
    cmp #W_LANZ
    beq @lz
    cmp #W_METR
    bne @p
    lda frame
    and #3
    sec
    sbc #1
    clc
    adc np_y
    sta np_y
@p:
    lda #1
    jsr proj_spawn
    jmp sfx_shoot
@sg:
    lda #2
    sta np_vz
    lda #6
    jsr proj_spawn
    lda np_y
    sec
    sbc #8
    sta np_y
    lda #6
    jsr proj_spawn
    lda np_y
    clc
    adc #16
    sta np_y
    lda #6
    jsr proj_spawn
    jmp sfx_boom
@lz:
    ; lanzacohetes: dos cohetes rapidos y fuertes
    lda #3
    sta np_vz
    lda #5
    jsr proj_spawn
    lda np_y
    clc
    adc #6
    sta np_y
    lda #5
    jsr proj_spawn
    jmp sfx_boom
@bz:
    lda np_vx
    cmp #$80
    ror
    sta np_vx
    lda #5
    jsr proj_spawn
    jmp sfx_shoot

; ---------------------------------------------------------------- enemigos
enemy_take:            ; X slot, A dano, Y derriba
    sta tmp7
    lda en_st,x
    cmp #ES_DOWN
    bcs @r
    lda en_inv,x
    bne @r
    lda #8
    sta en_inv,x
    lda #8
    sta en_flash,x
    cpx token
    bne @nt
    lda #$FF
    sta token
@nt:
    lda en_hp,x
    sec
    sbc tmp7
    bcs @a
    lda #0
@a:
    sta en_hp,x
    lda en_t,x
    cmp #2
    beq @car
    lda en_hp,x
    bne @alive
    lda #1
    sta en_dead,x
    ldy #1
@alive:
    lda en_xlo,x
    cmp px_lo
    lda en_xhi,x
    sbc px_hi
    lda #2
    bcs @kd
    lda #$FE
@kd:
    sta en_kvx,x
    cpy #1
    beq @down
    lda #ES_HURT
    sta en_st,x
    lda #14
    sta en_tm,x
    rts
@down:
    lda #ES_DOWN
    sta en_st,x
    lda #4
    sta en_vz,x
    lda #1
    sta en_z,x
    lda #0
    sta en_tm,x
@r:
    rts
@car:
    lda en_hp,x
    bne @r
    ; patrullero destruido
    lda #ES_DIE
    sta en_st,x
    lda #30
    sta en_tm,x
    stx tmp8
    lda en_xlo,x
    sta np_xlo
    lda en_xhi,x
    sta np_xhi
    lda en_y,x
    sta np_y
    jsr fx_spawn
    lda np_xlo
    clc
    adc #16
    sta np_xlo
    lda np_xhi
    adc #0
    sta np_xhi
    jsr fx_spawn
    jsr random_drop
    jsr drop_weapon
    lda #5
    ldy #3
    jsr add_score
    lda #8
    sta shake
    jsr sfx_boom
    ldx tmp8
    rts

pick_target:           ; X slot -> en_tgt, carga contexto; C=0 si no hay jugadores vivos
    stx tmp11
    lda #$FF
    sta tmp10
    lda #255
    sta tmp9
    ldy #0
@l:
    lda p_base+PO_ON,y
    beq @n
    lda p_base+PO_DEAD,y
    bne @n
    lda p_base+PO_XLO,y
    sec
    sbc en_xlo,x
    sta tmp0
    lda p_base+PO_XHI,y
    sbc en_xhi,x
    sta tmp1
    jsr abs16
    lda tmp2
    cmp tmp9
    bcs @n
    sta tmp9
    tya
    sta tmp10
@n:
    tya
    clc
    adc #32
    tay
    cpy #64
    bne @l
    lda tmp10
    cmp #$FF
    beq @none
    lsr
    lsr
    lsr
    lsr
    lsr
    sta en_tgt,x
    tax
    jsr load_player
    ldx tmp11
    sec
    rts
@none:
    ldx tmp11
    clc
    rts

enemies_update:
    ldx #0
@l:
    lda en_t,x
    beq @n
    lda en_inv,x
    beq @i
    dec en_inv,x
@i:
    lda en_flash,x
    beq @f
    dec en_flash,x
@f:
    lda en_cd,x
    beq @c
    dec en_cd,x
@c:
    inc en_anim,x
    jsr pick_target
    bcs @tg
    lda en_st,x
    cmp #ES_DOWN
    bcs @tg
    jmp @n
@tg:
    lda en_t,x
    cmp #2
    bne @gr
    jmp car_update
@gr:
    lda en_st,x
    asl
    tay
    lda es_tbl+1,y
    pha
    lda es_tbl,y
    pha
    rts
@n:
    inx
    cpx #NEN
    bne @l
    rts
es_tbl:
    .word es_walk-1, es_punch-1, es_shoot-1, es_hurt-1, es_down-1, es_die-1
en_cont:
    ldx tmp11
    inx
    cpx #NEN
    beq @r
    jmp enemies_update_l
@r:
    rts
enemies_update_l = enemies_update+2

face_x:
    lda en_xlo,x
    cmp px_lo
    lda en_xhi,x
    sbc px_hi
    lda #0
    bcc @r
    lda #1
@r:
    sta en_dir,x
    rts

es_walk:
    stx tmp11
    lda token
    cmp #$FF
    bne @ht
    lda en_cd,x
    bne @ht
    stx token
@ht:
    cpx token
    bne @wait
    lda #24
    ldy en_mode,x
    beq @md
    lda #84
@md:
    sta tmp3
    lda py
    sta tmp4
    jmp @side
@wait:
    ; espera lejos en profundidad (menos sprites por linea)
    lda #100
    sta tmp3
    lda py
    cmp #197
    bcs @wu
    lda #YMAX
    jmp @wy
@wu:
    lda #YMIN
@wy:
    sta tmp4
@side:
    lda en_xlo,x
    cmp px_lo
    lda en_xhi,x
    sbc px_hi
    bcc @lft
    lda px_lo
    clc
    adc tmp3
    sta tmp5
    lda px_hi
    adc #0
    sta tmp6
    jmp @clamp
@lft:
    lda px_lo
    sec
    sbc tmp3
    sta tmp5
    lda px_hi
    sbc #0
    sta tmp6
@clamp:
    lda cam_lo
    clc
    adc #12
    sta tmp0
    lda cam_hi
    adc #0
    sta tmp1
    lda tmp5
    cmp tmp0
    lda tmp6
    sbc tmp1
    bcs @c1
    lda tmp0
    sta tmp5
    lda tmp1
    sta tmp6
@c1:
    lda cam_lo
    clc
    adc #244
    sta tmp0
    lda cam_hi
    adc #0
    sta tmp1
    lda tmp0
    cmp tmp5
    lda tmp1
    sbc tmp6
    bcs @c2
    lda tmp0
    sta tmp5
    lda tmp1
    sta tmp6
@c2:
    lda #0
    sta tmp7
    lda tmp5
    sec
    sbc en_xlo,x
    sta tmp0
    lda tmp6
    sbc en_xhi,x
    sta tmp1
    jsr abs16
    lda tmp2
    cmp #3
    bcc @nx
    inc tmp7
    lda tmp1
    bmi @ml
    inc en_xlo,x
    bne @nx
    inc en_xhi,x
    jmp @nx
@ml:
    lda en_xlo,x
    bne @d2
    dec en_xhi,x
@d2:
    dec en_xlo,x
@nx:
    lda tmp4
    sec
    sbc en_y,x
    beq @ny
    sta tmp0
    lda frame
    and #1
    bne @ny
    inc tmp7
    lda tmp0
    bmi @mu
    inc en_y,x
    jmp @ny
@mu:
    dec en_y,x
@ny:
    jsr face_x
    lda tmp7
    beq @idle
    ; caminata de 8 cuadros con piernas alternadas
    lda en_anim,x
    lsr
    lsr
    and #7
    tay
    lda ewalk_seq,y
    sta en_fr,x
    jmp @att
@idle:
    lda #EF_IDLE
    sta en_fr,x
@att:
    cpx token
    bne @done
    lda tmp2
    cmp #4
    bcs @done
    jsr en_dy
    cmp #3
    bcs @done
    lda pz
    cmp #20
    bcs @done
    lda en_mode,x
    bne @sh
    lda #ES_PUNCH
    sta en_st,x
    lda #26
    sta en_tm,x
    jmp en_cont
@sh:
    lda #ES_SHOOT
    sta en_st,x
    lda #34
    sta en_tm,x
@done:
    jmp en_cont
ewalk_seq: .byte 0, 1, 2, 1, 0, 7, 8, 7

end_attack:
    lda #ES_WALK
    sta en_st,x
    lda #$FF
    sta token
    jsr rand
    and #31
    clc
    adc #40
    sec
    sbc level
    sbc level
    sta en_cd,x
    jsr rand
    and #1
    sta en_mode,x
    rts

es_punch:
    stx tmp11
    dec en_tm,x
    lda en_tm,x
    cmp #18
    bcs @wind
    cmp #6
    bcc @wind
    lda #EF_PUNCH
    sta en_fr,x
    lda en_tm,x
    cmp #14
    bne @nh
    jsr en_dx
    lda tmp2
    cmp #34
    bcs @nh
    jsr en_dy
    cmp #12
    bcs @nh
    lda pz
    cmp #14
    bcs @nh
    lda en_dir,x
    eor #1
    sta tmp9
    lda #2
    ldy faction
    beq @d
    lda #3
@d:
    ldy #0
    jsr player_hit
    ldx tmp11
@nh:
    jmp @chk
@wind:
    lda #EF_IDLE
    sta en_fr,x
@chk:
    lda en_tm,x
    bne @r
    jsr end_attack
@r:
    jmp en_cont

es_shoot:
    stx tmp11
    lda #EF_AIM
    sta en_fr,x
    dec en_tm,x
    lda en_tm,x
    cmp #18
    bne @nf
    lda en_y,x
    sta np_y
    lda #17
    sta np_z
    lda #0
    sta np_vz
    lda en_dir,x
    bne @l
    lda en_xlo,x
    clc
    adc #16
    sta np_xlo
    lda en_xhi,x
    adc #0
    sta np_xhi
    lda #3
    jmp @v
@l:
    lda en_xlo,x
    sec
    sbc #16
    sta np_xlo
    lda en_xhi,x
    sbc #0
    sta np_xhi
    lda #$FD
@v:
    sta np_vx
    lda #2
    jsr proj_spawn
    jsr sfx_shoot
    ldx tmp11
@nf:
    lda en_tm,x
    bne @r
    jsr end_attack
@r:
    jmp en_cont

es_hurt:
    stx tmp11
    lda #EF_HURT
    sta en_fr,x
    dec en_tm,x
    lda en_tm,x
    cmp #8
    bcc @nm
    jsr en_push
@nm:
    lda en_tm,x
    bne @r
    lda #ES_WALK
    sta en_st,x
@r:
    jmp en_cont

en_push:
    lda en_kvx,x
    ldy #0
    cmp #$80
    bcc @p
    dey
@p:
    clc
    adc en_xlo,x
    sta en_xlo,x
    tya
    adc en_xhi,x
    sta en_xhi,x
    rts

es_down:
    stx tmp11
    lda en_z,x
    ora en_vz,x
    beq @lying
    lda #EF_HURT
    sta en_fr,x
    jsr en_push
    lda en_z,x
    clc
    adc en_vz,x
    sta en_z,x
    bmi @land
    beq @land
    lda frame
    and #1
    bne @r
    dec en_vz,x
    jmp en_cont
@land:
    lda #0
    sta en_z,x
    sta en_vz,x
    lda #44
    sta en_tm,x
    lda #2
    sta shake
@lying:
    lda #EF_DOWN
    sta en_fr,x
    dec en_tm,x
    bne @r
    lda en_dead,x
    beq @up
    lda #ES_DIE
    sta en_st,x
    lda #36
    sta en_tm,x
    ; suelta arma
    lda en_xlo,x
    sta np_xlo
    lda en_xhi,x
    sta np_xhi
    lda en_y,x
    sta np_y
    jsr random_drop
    jsr drop_weapon
    ldx tmp11
    jmp en_cont
@up:
    lda #ES_WALK
    sta en_st,x
    lda #36
    sta en_inv,x
    lda #30
    sta en_cd,x
@r:
    jmp en_cont

es_die:
    stx tmp11
    lda en_t,x
    cmp #2
    beq @c
    lda #EF_DOWN
    sta en_fr,x
@c:
    dec en_tm,x
    bne @r
    lda #0
    sta en_t,x
    dec alive
    lda #3
    ldy #3
    jsr add_score
@r:
    jmp en_cont

; ---- patrullero / jeep enemigo
car_update:
    stx tmp11
    lda en_st,x
    cmp #ES_DIE
    bne @drv
    jmp es_die
@drv:
    ; avanzar
    lda #2
    ldy faction
    beq @sp
    lda frame
    and #1
    clc
    adc #2
@sp:
    ldy en_dir,x
    beq @r
    eor #$FF
    clc
    adc #1
@r:
    ldy #0
    cmp #$80
    bcc @p
    dey
@p:
    clc
    adc en_xlo,x
    sta en_xlo,x
    tya
    adc en_xhi,x
    sta en_xhi,x
    ; fuera de pantalla -> dar la vuelta en el carril del jugador
    lda en_xlo,x
    sec
    sbc cam_lo
    sta tmp0
    lda en_xhi,x
    sbc cam_hi
    sta tmp1
    lda en_dir,x
    bne @movl
    lda tmp1
    beq @lane
    bmi @lane
    lda tmp0
    cmp #40
    bcc @lane
    lda #1
    jmp @turn
@movl:
    lda tmp1
    bpl @lane
    lda tmp0
    cmp #$D0
    bcs @lane
    lda #0
@turn:
    sta en_dir,x
    lda py
    sta en_y,x
    jmp @shoot
@lane:
    ; acercarse al carril del jugador lentamente
    lda frame
    and #3
    bne @shoot
    lda en_y,x
    cmp py
    beq @shoot
    bcc @dn
    dec en_y,x
    jmp @shoot
@dn:
    inc en_y,x
@shoot:
    lda en_cd,x
    bne @ram
    jsr en_dy
    cmp #10
    bcs @ram
    ; el jugador esta delante?
    jsr en_dx
    lda tmp1
    bmi @pl
    lda en_dir,x
    beq @ram
    jmp @fire
@pl:
    lda en_dir,x
    bne @ram
@fire:
    lda tmp2
    cmp #200
    bcs @ram
    lda en_y,x
    sta np_y
    lda #20
    sta np_z
    lda #0
    sta np_vz
    lda en_xlo,x
    sta np_xlo
    lda en_xhi,x
    sta np_xhi
    lda #3
    ldy en_dir,x
    beq @fv
    lda #$FD
@fv:
    sta np_vx
    lda #2
    jsr proj_spawn
    jsr sfx_shoot
    ldx tmp11
    lda #60
    sec
    sbc level
    sbc level
    sta en_cd,x
@ram:
    ; embestida
    jsr en_dx
    lda tmp2
    cmp #26
    bcs @done
    jsr en_dy
    cmp #10
    bcs @done
    lda pz
    cmp #16
    bcs @done
    lda en_dir,x
    sta tmp9
    lda #3
    ldy #1
    jsr player_hit
    ldx tmp11
@done:
    jmp en_cont

; ---------------------------------------------------------------- proyectiles
; tipos: 1 bala jugador, 2 bala enemiga, 3 granada, 4 bomba, 5 cohete, 6 perdigon
proj_spawn:
    ldx #0
@f:
    ldy pr_t,x
    beq @got
    inx
    cpx #NPR
    bne @f
    rts
@got:
    sta pr_t,x
    lda np_xlo
    sta pr_xlo,x
    lda np_xhi
    sta pr_xhi,x
    lda np_y
    sta pr_y,x
    lda np_z
    sta pr_z,x
    lda np_vx
    sta pr_vx,x
    lda np_vz
    sta pr_vz,x
    lda #0
    sta pr_tm,x
    rts

proj_update:
    ldx #0
@l:
    lda pr_t,x
    bne @a
    jmp @n
@a:
    inc pr_tm,x
    lda pr_vx,x
    ldy #0
    cmp #$80
    bcc @p
    dey
@p:
    clc
    adc pr_xlo,x
    sta pr_xlo,x
    tya
    adc pr_xhi,x
    sta pr_xhi,x
    lda pr_xlo,x
    sec
    sbc cam_lo
    lda pr_xhi,x
    sbc cam_hi
    beq @on
    jmp @kill
@on:
    lda pr_t,x
    cmp #6
    bne @np
    lda pr_tm,x
    cmp #16
    bcc @pp
    jmp @kill
@pp:
    jmp @pb
@np:
    cmp #5
    bne @nr
    lda pr_tm,x
    cmp #50
    bcc @rk
    jmp @rboom
@rk:
    jmp @pb
@nr:
    cmp #3
    bcs @arc
    cmp #1
    bne @eb
    jmp @pb
@eb:
    jmp @ebul
@arc:
    lda pr_tm,x
    and #3
    bne @nz
    dec pr_vz,x
@nz:
    lda pr_z,x
    clc
    adc pr_vz,x
    sta pr_z,x
    bmi @boom
    beq @boom
    jmp @n
@boom:
    stx tmp11
    lda pr_xlo,x
    sta np_xlo
    lda pr_xhi,x
    sta np_xhi
    lda pr_y,x
    sta np_y
    jsr fx_spawn
    jsr sfx_boom
    ; dano de area a jugadores
    ldy #0
@pl:
    sty tmp10
    lda p_base+PO_ON,y
    beq @pn
    ldx tmp11
    lda pr_xlo,x
    sec
    sbc p_base+PO_XLO,y
    sta tmp0
    lda pr_xhi,x
    sbc p_base+PO_XHI,y
    sta tmp1
    jsr abs16
    lda tmp2
    cmp #24
    bcs @pn
    lda pr_y,x
    sec
    sbc p_base+PO_Y,y
    bcs @ay
    eor #$FF
    adc #1
@ay:
    cmp #16
    bcs @pn
    lda p_base+PO_Z,y
    cmp #20
    bcs @pn
    tya
    lsr
    lsr
    lsr
    lsr
    lsr
    tax
    jsr load_player
    lda tmp1
    rol
    lda #0
    rol
    sta tmp9
    lda tmp10
    pha
    lda #4
    ldy #1
    jsr player_hit
    pla
    sta tmp10
@pn:
    ldy tmp10
    tya
    clc
    adc #32
    tay
    cpy #64
    bne @pl
    ldx tmp11
    jmp @kill
@ebul:
    ; bala enemiga vs jugadores
    stx tmp11
    ldy #0
@ep:
    sty tmp10
    lda p_base+PO_ON,y
    beq @en
    lda p_base+PO_DEAD,y
    bne @en
    ldx tmp11
    lda pr_xlo,x
    sec
    sbc p_base+PO_XLO,y
    sta tmp0
    lda pr_xhi,x
    sbc p_base+PO_XHI,y
    sta tmp1
    jsr abs16
    ldy tmp10
    lda p_base+16,y
    tay
    lda veh_half,y
    cmp tmp2
    bcc @en
    ldy tmp10
    lda pr_y,x
    sec
    sbc p_base+PO_Y,y
    bcs @by
    eor #$FF
    adc #1
@by:
    cmp #11
    bcs @en
    lda pr_z,x
    sec
    sbc p_base+PO_Z,y
    bcc @en
    cmp #32
    bcs @en
    lda p_base+PO_ST,y
    cmp #PS_DOWN
    beq @en
    ; impacto
    tya
    lsr
    lsr
    lsr
    lsr
    lsr
    tax
    jsr load_player
    ldx tmp11
    lda pr_vx,x
    rol
    rol
    and #1
    eor #1
    sta tmp9
    lda #0
    sta pr_t,x
    lda #2
    ldy #0
    jsr player_hit
    ldx tmp11
    jmp @n
@en:
    ldy tmp10
    tya
    clc
    adc #32
    tay
    cpy #64
    beq @__n3604_4
    jmp @ep
@__n3604_4:
    ldx tmp11
    jmp @n
@kill:
    lda #0
    sta pr_t,x
@n:
    inx
    cpx #NPR
    beq @r
    jmp @l
@r:
    rts
@pb:
    ; bala/cohete/perdigon del jugador vs enemigos y jefe
    stx tmp11
    ldy #0
@e:
    lda en_t,y
    beq @ne
    lda en_st,y
    cmp #ES_DOWN
    bcs @ne
    lda en_inv,y
    bne @ne
    lda pr_xlo,x
    sec
    sbc en_xlo,y
    sta tmp0
    lda pr_xhi,x
    sbc en_xhi,y
    sta tmp1
    jsr abs16
    lda en_t,y
    cmp #2
    beq @cw
    lda tmp2
    cmp #10
    bcs @ne
    bcc @ey0
@cw:
    lda tmp2
    cmp #24
    bcs @ne
@ey0:
    lda pr_y,x
    sec
    sbc en_y,y
    bcs @ey
    eor #$FF
    adc #1
@ey:
    cmp #11
    bcs @ne
    lda pr_t,x
    cmp #5
    beq @rboom
    lda #0
    sta pr_t,x
    lda pr_vz,x
    sta tmp10
    tya
    tax
    lda tmp10
    ldy #0
    jsr enemy_take
    jsr sfx_hit
    ldx tmp11
    jmp @n
@ne:
    iny
    cpy #NEN
    bne @e
    lda boss_on
    beq @nb
    lda b_st
    cmp #9
    beq @nb
    lda pr_xlo,x
    sec
    sbc b_xlo
    sta tmp0
    lda pr_xhi,x
    sbc b_xhi
    sta tmp1
    jsr abs16
    lda b_w
    lsr
    cmp tmp2
    bcc @nb
    lda pr_y,x
    sec
    sbc b_y
    bcs @bby
    eor #$FF
    adc #1
@bby:
    cmp #16
    bcs @nb
    lda pr_z,x
    sec
    sbc b_z
    bcc @nb
    cmp b_h
    bcs @nb
    lda pr_t,x
    cmp #5
    beq @rboom
    lda #0
    sta pr_t,x
    lda pr_vz,x
    jsr boss_take
    ldx tmp11
@nb:
    jmp @n
@rboom:
    ; explosion de cohete: dano de area
    ldx tmp11
    lda #0
    sta pr_t,x
    lda pr_xlo,x
    sta np_xlo
    lda pr_xhi,x
    sta np_xhi
    lda pr_y,x
    sta np_y
    sta tmp6
    jsr fx_spawn
    jsr sfx_boom
    lda #6
    sta shake
    ldx #0
@ra:
    lda en_t,x
    beq @rn
    lda en_xlo,x
    sec
    sbc np_xlo
    sta tmp0
    lda en_xhi,x
    sbc np_xhi
    sta tmp1
    jsr abs16
    lda tmp2
    cmp #34
    bcs @rn
    lda en_y,x
    sec
    sbc tmp6
    bcs @ry
    eor #$FF
    adc #1
@ry:
    cmp #18
    bcs @rn
    stx tmp8
    lda #6
    ldy #1
    jsr enemy_take
    ldx tmp8
@rn:
    inx
    cpx #NEN
    bne @ra
    lda boss_on
    beq @rb
    lda b_xlo
    sec
    sbc np_xlo
    sta tmp0
    lda b_xhi
    sbc np_xhi
    sta tmp1
    jsr abs16
    lda b_w
    lsr
    clc
    adc #24
    cmp tmp2
    bcc @rb
    lda #6
    jsr boss_take
@rb:
    ldx tmp11
    jmp @n

; ---------------------------------------------------------------- explosiones
fx_spawn:
    ldx #0
@f:
    lda fx_t,x
    beq @g
    inx
    cpx #NFX
    bne @f
    rts
@g:
    lda #16
    sta fx_t,x
    lda np_xlo
    sta fx_xlo,x
    lda np_xhi
    sta fx_xhi,x
    lda np_y
    sta fx_y,x
    rts

fx_update:
    ldx #NFX-1
@l:
    lda fx_t,x
    beq @n
    dec fx_t,x
@n:
    dex
    bpl @l
    rts

; ---------------------------------------------------------------- HUD
hud_player:            ; Y = desplazamiento en p_base (0/32), X = indice en hud_buf
    lda p_base+PO_ON,y
    bne @on
    lda continues
    beq @blk
    cpy #0
    beq @ct
    lda two_p
    beq @blk
@ct:
    ; "SEGUIR? START 9" + creditos
    ldy #0
@cl:
    lda cont_lab,y
    sta hud_buf,x
    inx
    iny
    cpy #15
    bne @cl
    lda frame
    and #16
    bne @vis
    lda #0
    sta hud_buf-7,x
    sta hud_buf-6,x
    sta hud_buf-5,x
    sta hud_buf-4,x
    sta hud_buf-3,x
@vis:
    lda cont_t
    beq @nt
    clc
    adc #$10
    cmp #$1A
    bcc @d9
    lda #$19
@d9:
    sta hud_buf-1,x
@nt:
    lda continues
    clc
    adc #$10
    sta hud_buf,x
    inx
    rts
@blk:
    lda #$44
    ldy #16
@c:
    sta hud_buf,x
    inx
    dey
    bne @c
    rts
@on:
    sty tmp11
    lda p_base+13,y
    sta tmp0
    jsr bar8
    ldy tmp11
    ; arma (tambien arriba de un vehiculo: las balas son las mismas)
    lda p_base+27,y
    asl
    asl
    tay
    lda #4
    sta tmp1
@lb:
    lda wlab,y
    sta hud_buf,x
    iny
    inx
    dec tmp1
    bne @lb
    ldy tmp11
    jmp @am
    ; fichas del vehiculo
    lda #$44
    sta hud_buf,x
    lda #$45
    sta hud_buf+1,x
    lda p_base+17,y
    bne @t1
    lda #$45
    bne @t2
@t1:
    lda #$44
@t2:
    sta hud_buf+2,x
    jmp @l3
@am:
    lda p_base+27,y
    bne @num
    lda #$44
    sta hud_buf,x
    sta hud_buf+1,x
    sta hud_buf+2,x
    jmp @l3
@num:
    lda #26
    sta hud_buf,x
    lda p_base+28,y
    ldy #$10
@d10:
    cmp #10
    bcc @d1
    sbc #10
    iny
    jmp @d10
@d1:
    sta tmp1
    tya
    sta hud_buf+1,x
    lda tmp1
    clc
    adc #$10
    sta hud_buf+2,x
@l3:
    inx
    inx
    inx
    ldy tmp11
    lda p_base+14,y
    clc
    adc #$10
    sta hud_buf,x
    inx
    rts

cont_lab: .text "SEGUIR? START  "
wlab:
    .text "PUNO"
    .text "PIST"
    .text "ESCO"
    .text "METR"
    .text "BAZU"
    .text "CORA"
    .text "LANZ"
    .text "MOTO"
    .text "AUTO"

hud_prepare:
    ldx #0
    ldy #0
    jsr hud_player     ; 0..15
    ldx #0
@s:
    lda score,x
    clc
    adc #$10
    sta hud_buf+16,x
    inx
    cpx #6
    bne @s
    ldx #22
    ldy #32
    jsr hud_player     ; 22..37
    ; derecha: estrellas o GO>>
    lda go_t
    beq @st
    lda frame
    and #16
    beq @st
    ldx #4
@g:
    lda go_lab,x
    sta hud_buf+38,x
    dex
    bpl @g
    jmp @bu
@st:
    ldx #0
@sl:
    lda #$44
    cpx stars
    bcs @e
    lda #$43
@e:
    sta hud_buf+38,x
    inx
    cpx #5
    bne @sl
@bu:
    ; unidades de la barra del jefe = ceil(b_hp*28/hpmax)
    lda boss_on
    beq @r
    lda b_hpmax
    beq @r
    lda b_hp
    sta tmp1
    lda #0
    sta tmp2
    ; *28 = *32 - *4
    ldx #5
@m:
    asl tmp1
    rol tmp2
    dex
    bne @m
    lda b_hp
    asl
    asl
    sta tmp3
    lda #0
    rol
    sta tmp4
    lda tmp1
    sec
    sbc tmp3
    sta tmp1
    lda tmp2
    sbc tmp4
    sta tmp2
    lda #0
    sta tmp0
@q:
    lda tmp1
    sec
    sbc b_hpmax
    tay
    lda tmp2
    sbc #0
    bcc @qd
    sta tmp2
    sty tmp1
    inc tmp0
    jmp @q
@qd:
    lda tmp1
    beq @qe
    inc tmp0
@qe:
    lda tmp0
    sta b_units
@r:
    rts
go_lab: .text "GO>>_"

bar8:
    ldy #0
@l:
    lda tmp0
    cmp #2
    bcs @full
    cmp #1
    beq @half
    lda #$42
    bne @put
@full:
    sec
    sbc #2
    sta tmp0
    lda #$40
    bne @put
@half:
    lda #0
    sta tmp0
    lda #$41
@put:
    sta hud_buf,x
    inx
    iny
    cpy #8
    bne @l
    rts

hud_common:
    .str $2036, "X"
    .byte 0

; ---------------------------------------------------------------- dibujo
draw_all:
    lda #0
    sta def_n
    jsr clear_oam
    jsr reset_draw
    jsr draw_bossbar
    jsr draw_projs
    jsr reset_draw
    jsr draw_plane
    ; lista de profundidad: 0-1 jugadores, 2-4 enemigos, 5 jefe, 6-8 vehiculos
    ldx #0
    ldy #0
@p:
    lda p_base+PO_ON,y
    beq @np
    lda p_base+PO_Y,y
    sta dl_y,x
    tya
    lsr
    lsr
    lsr
    lsr
    lsr
    sta dl_id,x
    inx
@np:
    tya
    clc
    adc #32
    tay
    cpy #64
    bne @p
    ldy #0
@e:
    lda en_t,y
    beq @ne
    lda en_y,y
    sta dl_y,x
    tya
    clc
    adc #2
    sta dl_id,x
    inx
@ne:
    iny
    cpy #NEN
    bne @e
    lda boss_on
    beq @nb
    lda b_y
    sta dl_y,x
    lda #5
    sta dl_id,x
    inx
@nb:
    ldy #0
@v:
    lda vo_t,y
    beq @nv
    lda vo_y,y
    sta dl_y,x
    tya
    clc
    adc #6
    sta dl_id,x
    inx
@nv:
    iny
    cpy #NVO
    bne @v
    stx tmp10
    ldx #1
@o:
    cpx tmp10
    bcs @od
    txa
    tay
@in:
    lda dl_y-1,y
    cmp dl_y,y
    bcs @nx
    lda dl_y,y
    pha
    lda dl_y-1,y
    sta dl_y,y
    pla
    sta dl_y-1,y
    lda dl_id,y
    pha
    lda dl_id-1,y
    sta dl_id,y
    pla
    sta dl_id-1,y
    dey
    bne @in
@nx:
    inx
    jmp @o
@od:
    ; 1 jugador: siempre primero (nunca parpadea)
    lda two_p
    bne @all
    lda p_base+PO_ON
    beq @all
    ldx #0
    jsr draw_player
    jsr reset_draw
@all:
    ; el resto alterna orden cada cuadro (reparte el limite de 8 por linea)
    lda frame
    and #1
    sta dl_rev
    beq @fw
    ldx tmp10
    dex
    jmp @dl
@fw:
    ldx #0
@dl:
    cpx tmp10
    bcs @fin
    stx dl_i
    lda dl_id,x
    cmp #2
    bcc @pl
    cmp #5
    bcc @en
    beq @bs
    jmp @dn               ; vehiculos estacionados: al final
@pl:
    tax
    bne @pd
    ldy two_p
    beq @dn
@pd:
    jsr draw_player
    jmp @dn
@en:
    sec
    sbc #2
    tax
    jsr draw_enemy
    jmp @dn
@bs:
    jsr draw_boss
@dn:
    jsr reset_draw
    ldx dl_i
    lda dl_rev
    bne @dec
    inx
    jmp @dl
@dec:
    dex
    jmp @dl
@fin:
    ; detalles superpuestos de los jugadores (ojos, etc.): despues de TODOS los cuerpos.
    ; si hay mas de 8 sprites en una linea se pierde un detalle, no un pedazo de un policia
    jsr draw_deferred
    ; vehiculos estacionados con menor prioridad (los personajes no parpadean por ellos)
    ldx #0
@vl:
    cpx tmp10
    bcs @vf
    stx dl_i
    lda dl_id,x
    cmp #6
    bcc @vn
    sbc #6
    tax
    lda frame
    and #1
    sta srev
    jsr draw_vo
    jsr reset_draw
@vn:
    ldx dl_i
    inx
    jmp @vl
@vf:
    jmp draw_fxs
dl_i = $87

draw_player:           ; X = jugador
    jsr load_player
    lda dead_t
    beq @alive
    lda frame
    and #4
    beq @alive
    rts
@alive:
    lda inv
    beq @vis
    lda pst
    cmp #PS_DOWN
    beq @vis
    cmp #PS_HURT
    beq @vis
    lda frame
    and #2
    beq @vis
    rts
@vis:
    lda px_lo
    sta tmp0
    lda px_hi
    sta tmp1
    jsr world_sx
    lda pz
    beq @ns
    lda py
    sta sy
    lda #MF_SHADOW
    jsr draw_misc
    jsr reset_draw
@ns:
    lda py
    sec
    sbc pz
    sta sy
    lda pdir
    beq @f
    lda #$40
@f:
    sta sflip
    ldx cur
    beq @p1
    lda #$40
    sta stile
@p1:
    ldy pframe
    lda pveh
    beq @foot
    lda char
    bne @lr
    lda jose_ride_bk,y
    jsr set_pbank
    lda jose_ride_lo,y
    ldx jose_ride_hi,y
    jmp @go
@lr:
    lda luci_ride_bk,y
    jsr set_pbank
    lda luci_ride_lo,y
    ldx luci_ride_hi,y
    jmp @go
@foot:
    lda char
    bne @lf
    lda jose_bk,y
    jsr set_pbank
    lda jose_lo,y
    ldx jose_hi,y
    jmp @go
@lf:
    lda luci_bk,y
    jsr set_pbank
    lda luci_lo,y
    ldx luci_hi,y
@go:
    sta fptr
    stx fptr+1
    jsr draw_frame
    ; la lista de superpuestos esta justo despues de la base: fptr + 1 + 4*n -> diferida
    ldy #0
    lda (fptr),y
    asl
    asl
    sec                   ; +1
    adc fptr
    sta tmp0
    lda fptr+1
    adc #0
    sta tmp1
    ldx def_n
    cpx #2
    bcs @nd
    lda tmp0
    sta def_lo,x
    lda tmp1
    sta def_hi,x
    lda sx_lo
    sta def_sxl,x
    lda sx_hi
    sta def_sxh,x
    lda sy
    sta def_sy,x
    lda sflip
    sta def_fl,x
    lda stile
    sta def_st,x
    inc def_n
@nd:
    rts

draw_deferred:
    ldx #0
@l:
    cpx def_n
    bcs @f
    stx tmp9
    jsr reset_draw
    ldx tmp9
    lda def_lo,x
    sta fptr
    lda def_hi,x
    sta fptr+1
    lda def_sxl,x
    sta sx_lo
    lda def_sxh,x
    sta sx_hi
    lda def_sy,x
    sta sy
    lda def_fl,x
    sta sflip
    lda def_st,x
    sta stile
    jsr draw_frame
    ldx tmp9
    inx
    jmp @l
@f:
    lda #0
    sta def_n
    jmp reset_draw

set_pbank:             ; A = banco -> R2 (jugador 1) o R3 (jugador 2)
    ldx cur
    bne @p2
    sta chr_r2
    rts
@p2:
    sta chr_r3
    rts

draw_enemy:            ; X slot
    lda en_st,x
    cmp #ES_DIE
    bne @v
    lda en_t,x
    cmp #2
    beq @v
    lda frame
    and #2
    beq @v
    rts
@v:
    lda en_xlo,x
    sta tmp0
    lda en_xhi,x
    sta tmp1
    jsr world_sx
    lda en_y,x
    sec
    sbc en_z,x
    sta sy
    lda en_dir,x
    beq @f
    lda #$40
@f:
    sta sflip
    lda en_flash,x
    and #2
    beq @nf
    lda #1
    sta spal
@nf:
    lda en_t,x
    cmp #2
    bne @gr
    jmp draw_car_enemy
@gr:
    ldy en_fr,x
    lda faction
    bne @sol
    lda cop_lo,y
    sta fptr
    lda cop_hi,y
    sta fptr+1
    jmp @d
@sol:
    lda soldier_lo,y
    sta fptr
    lda soldier_hi,y
    sta fptr+1
@d:
    stx tmp9
    jsr draw_frame
    ldx tmp9
    lda en_st,x
    cmp #ES_SHOOT
    bne @r
    lda en_tm,x
    cmp #19
    bcs @r
    cmp #13
    bcc @r
    jsr reset_draw
    lda en_dir,x
    beq @fr
    lda #$40
    sta sflip
    lda sx_lo
    sec
    sbc #20
    sta sx_lo
    lda sx_hi
    sbc #0
    sta sx_hi
    jmp @fy
@fr:
    lda sx_lo
    clc
    adc #20
    sta sx_lo
    lda sx_hi
    adc #0
    sta sx_hi
@fy:
    lda en_y,x
    sec
    sbc #15
    sta sy
    lda #MF_FLASH
    jmp draw_misc
@r:
    rts

draw_car_enemy:        ; carroceria desde R2 con paleta del enemigo + conductor
    stx tmp9
    lda en_st,x
    cmp #ES_DIE
    bne @ok
    lda frame
    and #2
    beq @ok
    rts
@ok:
    lda sx_lo
    pha
    lda sx_hi
    pha
    ; conductor (cuadro quieto recortado)
    lda #0
    sta spal
    lda sy
    pha
    clc
    adc #4
    sta sy
    lda #$F0
    sta sclip
    lda #4
    ldx sflip
    beq @dx
    lda #$FC
@dx:
    eor #$FF
    clc
    adc #1
    ldy #0
    cmp #$80
    bcc @dp
    dey
@dp:
    clc
    adc sx_lo
    sta sx_lo
    tya
    adc sx_hi
    sta sx_hi
    lda faction
    bne @hs
    lda cop_lo
    sta fptr
    lda cop_hi
    sta fptr+1
    jmp @hd
@hs:
    lda soldier_lo
    sta fptr
    lda soldier_hi
    sta fptr+1
@hd:
    jsr draw_frame
    lda #0
    sta sclip
    pla
    sta sy
    pla
    sta sx_hi
    pla
    sta sx_lo
    ; carroceria
    lda #2
    sta sforce
    ldx tmp9
    lda en_flash,x
    and #2
    beq @nf
    lda #3
    sta sforce
@nf:
    lda park_lo
    sta fptr
    lda park_hi
    sta fptr+1
    lda #0
    sta stile
    jsr draw_frame
    ; sirena sobre el parabrisas
    lda #0
    sta sforce
    lda sy
    sec
    sbc #19
    sta sy
    lda #10
    ldx sflip
    beq @sd
    lda #$F6
@sd:
    ldy #0
    cmp #$80
    bcc @sp
    dey
@sp:
    clc
    adc sx_lo
    sta sx_lo
    tya
    adc sx_hi
    sta sx_hi
    lda frame
    and #8
    asl
    asl
    asl
    eor sflip
    sta sflip
    lda #MF_SIREN
    jmp draw_misc

draw_vo:
    lda vo_xlo,x
    sta tmp0
    lda vo_xhi,x
    sta tmp1
    jsr world_sx
    lda vo_y,x
    sta sy
    stx tmp9
    lda vo_t,x
    cmp #2
    beq @car
    ; moto estacionada: sus tiles no estan en los bancos de "manejando" del jugador 1
    lda p_base+16
    beq @mok
    rts
@mok:
    lda park_lo+1
    sta fptr
    lda park_hi+1
    sta fptr+1
    jmp @d
@car:
    lda park_lo
    sta fptr
    lda park_hi
    sta fptr+1
@d:
    jsr draw_frame
    jsr reset_draw
    ; indicador A+B cerca de algun jugador a pie
    ldx tmp9
    ldy #0
@pl:
    lda p_base+PO_ON,y
    beq @pn
    lda p_base+16,y
    bne @pn
    lda vo_xlo,x
    sec
    sbc p_base+PO_XLO,y
    sta tmp0
    lda vo_xhi,x
    sbc p_base+PO_XHI,y
    sta tmp1
    jsr abs16
    lda tmp2
    cmp #34
    bcs @pn
    lda frame
    and #16
    beq @r
    lda vo_y,x
    sec
    sbc #40
    sta sy
    lda #MF_AB
    jmp draw_misc
@pn:
    tya
    clc
    adc #32
    tay
    cpy #64
    bne @pl
@r:
    rts

; avion muy en el fondo (detras del horizonte lejano)
draw_plane:
    lda plane_on
    bne @on
    dec plane_t
    bne @r
    jsr rand
    and #7
    clc
    adc #38
    sta plane_y
    lda #250
    sta plane_x
    sta plane_on
@r:
    rts
@on:
    lda frame
    and #3
    bne @d
    dec plane_x
    lda plane_x
    cmp #4
    bcs @d
    lda #0
    sta plane_on
    jsr rand
    ora #$80
    sta plane_t
    rts
@d:
    lda plane_x
    sta sx_lo
    lda #0
    sta sx_hi
    lda plane_y
    sta sy
    lda #$20
    sta spal
    lda #$40
    sta sflip
    lda #MF_PLANE
    jsr draw_misc
    jmp reset_draw

draw_projs:
    ldx #0
@l:
    lda pr_t,x
    beq @n
    stx tmp9
    lda pr_xlo,x
    sta tmp0
    lda pr_xhi,x
    sta tmp1
    jsr world_sx
    lda pr_y,x
    sec
    sbc pr_z,x
    clc
    adc #2
    sta sy
    lda pr_vx,x
    and #$80
    lsr
    sta sflip
    lda pr_t,x
    tay
    cpy #3
    beq @bx
    cpy #4
    beq @bx
    lda proj_mf-1,y
    jsr draw_misc
    jmp @sh
@bx:
    lda proj_bx-3,y
    jsr draw_bossx
@sh:
    jsr reset_draw
    ldx tmp9
    lda pr_t,x
    cmp #3
    bcc @n
    cmp #5
    bcs @n
    lda pr_y,x
    sta sy
    lda #MF_SHADOW
    jsr draw_misc
    ldx tmp9
@n:
    inx
    cpx #NPR
    bne @l
    rts
veh_mdx: .byte 18, 12, 8
veh_mdz: .byte 16, 26, 20
proj_mf: .byte MF_PB, MF_EB, 0, 0, MF_ROCKET, MF_PB
proj_bx: .byte BX_SHELL, BX_BOMB

draw_bossx:
    tax
    lda bossx_lo,x
    sta fptr
    lda bossx_hi,x
    sta fptr+1
    jmp draw_frame

draw_fxs:
    ldx #0
@l:
    lda fx_t,x
    beq @n
    stx tmp9
    lda fx_xlo,x
    sta tmp0
    lda fx_xhi,x
    sta tmp1
    jsr world_sx
    lda fx_y,x
    sta sy
    lda #MF_EX1
    ldy fx_t,x
    cpy #8
    bcc @k
    lda #MF_EX0
@k:
    jsr draw_misc
    ldx tmp9
@n:
    inx
    cpx #NFX
    bne @l
    rts

draw_bossbar:          ; barra vertical estilo Mega Man
    lda boss_on
    beq @r
    lda b_st
    cmp #9
    beq @r
    lda #0
    sta sx_hi
    lda #14
    sta sx_lo
    lda #104
    sta sy
    lda b_units
    sta tmp10
    ldx #7
@l:
    stx tmp11
    lda tmp10
    cmp #4
    bcc @p
    lda #4
@p:
    pha
    lda tmp10
    sec
    sbc #4
    bcs @s
    lda #0
@s:
    sta tmp10
    pla
    clc
    adc #BX_BAR0
    jsr draw_bossx
    lda sy
    sec
    sbc #8
    sta sy
    ldx tmp11
    dex
    bne @l
@r:
    rts
