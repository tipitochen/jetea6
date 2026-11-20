; codigo del titulo (banco 2 mapeado en $8000 durante el titulo)
title_init_b:
    lda #0
    jsr mus_play
    lda #TITLE_UNIT
    sta chr_r0
    lda #TITLE_UNIT+2
    sta chr_r1
    lda #0
    sta tfill
    sta sel
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR
    lda #<title_nt
    sta ptr
    lda #>title_nt
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
    lda #<title_pal
    ldx #>title_pal
    jsr load_pal_ptr
    lda #<title_strs
    ldx #>title_strs
    jsr draw_ptr
    jsr clear_oam
    lda #0
    sta cam_lo
    sta cam_hi
    sta cut_t
    lda #0
    sta kon_i
    sta lsel_on
    sta start_lvl
    lda #ST_TITLE
    sta state
    lda #TITLE_UNIT+4
    sta irq_b0
    lda #TITLE_UNIT+6
    sta irq_b1
    lda #TITLE_IRQ
    sta irq_ln
    lda #2
    sta game_irq
    jmp ppu_enable

TCUR0 = $22C4
TCUR1 = $22D0
st_title:
    inc cut_t
    ; ---- codigo konami: arriba arriba abajo abajo izq der izq der B A -> elegir nivel
    lda pad_new
    beq @kd
    ldx kon_i
    cmp kon_seq,x
    bne @kr
    inx
    stx kon_i
    cpx #10
    bne @kd
    lda #0
    sta kon_i
    lda #1
    sta lsel_on
    sta lsel_dirty
    jmp sfx_power
@kr:
    ldx #0
    cmp kon_seq
    bne @k0
    inx
@k0:
    stx kon_i
@kd:
    lda lsel_on
    beq @nl
    ; con el selector activo: izquierda/derecha cambian el nivel
    lda pad_new
    and #BTN_LEFT|BTN_RIGHT
    beq @dw
    and #BTN_RIGHT
    beq @lft
    ldx start_lvl
    inx
    cpx #11
    bcc @sv
    ldx #0
    jmp @sv
@lft:
    ldx start_lvl
    dex
    bpl @sv
    ldx #10
@sv:
    stx start_lvl
    lda #1
    sta lsel_dirty
    jsr sfx_shoot
@dw:
    lda lsel_dirty
    beq @nl
    lda str_pending
    bne @nl
    lda cut_t
    and #$1F
    beq @nl
    jsr lsel_draw
@nl:
    ; parpadeo de PRESIONA START
    lda cut_t
    and #$1F
    bne @nb
    lda cut_t
    and #$20
    beq @on
    lda #<blank14
    sta ptr
    lda #>blank14
    sta ptr+1
    jmp @ql
@on:
    lda #<press_str
    sta ptr
    lda #>press_str
    sta ptr+1
@ql:
    lda #25
    jsr queue_line
@nb:
    lda #BTN_LEFT|BTN_RIGHT|BTN_SEL|BTN_UP|BTN_DOWN
    ldx lsel_on
    beq @mk
    lda #BTN_SEL|BTN_UP|BTN_DOWN
@mk:
    and pad_new
    beq @nm
    lda sel
    eor #1
    sta sel
    jsr sfx_shoot
@nm:
    ; cursor
    lda bgq_n
    bne @nc
    lda #>TCUR0
    sta tmp0
    lda #<TCUR0
    sta tmp1
    lda sel
    beq @c0
    lda #0
    jmp @c1
@c0:
    lda #30
@c1:
    jsr bgq_add
    lda #>TCUR1
    sta tmp0
    lda #<TCUR1
    sta tmp1
    lda sel
    bne @c2
    lda #0
    jmp @c3
@c2:
    lda #30
@c3:
    jsr bgq_add
@nc:
    lda pad_new
    and #BTN_START|BTN_A
    beq @r
    jsr sfx_power
    lda sel
    sta two_p
    beq @one
    ; 2 jugadores: Jose y Luciana
    lda #0
    jsr init_p1
    lda #1
    jsr init_p2
    jmp title_to_game
@one:
    jmp title_to_sel
@r:
    rts

kon_seq: .byte BTN_UP, BTN_UP, BTN_DOWN, BTN_DOWN, BTN_LEFT, BTN_RIGHT, BTN_LEFT, BTN_RIGHT, BTN_B, BTN_A

; linea del selector de nivel (fila 24): "< NIVEL 02  CIELOS DE NICE >"
lsel_draw:
    lda #0
    sta lsel_dirty
    ldx #0
    lda #13               ; '-'
    sta lsel_buf+1,x
    inx
    lda #0
    sta lsel_buf+1,x
    inx
    ldy #0
@p:
    lda lsel_pre,y
    sta lsel_buf+1,x
    inx
    iny
    cpy #6
    bne @p
    lda start_lvl
    cmp #10
    bcs @fin
    ; numero 01..10
    clc
    adc #1
    ldy #$10
@d:
    cmp #10
    bcc @u
    sbc #10
    iny
    jmp @d
@u:
    clc
    adc #$10
    pha
    tya
    sta lsel_buf+1,x
    inx
    pla
    sta lsel_buf+1,x
    inx
    lda #0
    sta lsel_buf+1,x
    inx
    sta lsel_buf+1,x
    inx
    ; nombre
    lda start_lvl
    asl
    tay
    lda lsel_names,y
    sta ptr
    lda lsel_names+1,y
    sta ptr+1
    jmp @nm
@fin:
    lda #<lsel_fin
    sta ptr
    lda #>lsel_fin
    sta ptr+1
@nm:
    ldy #0
    lda (ptr),y
    sta tmp2
    iny
@c:
    lda (ptr),y
    sta lsel_buf+1,x
    inx
    iny
    dec tmp2
    bne @c
    lda #0
    sta lsel_buf+1,x
    inx
    lda #13
    sta lsel_buf+1,x
    inx
    stx lsel_buf
    lda #<lsel_buf
    sta ptr
    lda #>lsel_buf
    sta ptr+1
    lda #24
    jmp queue_line
lsel_pre: .byte 46,41,54,37,44,0     ; NIVEL
lsel_fin: .ltext "FINAL DEL JUEGO"
lsel_names: .word lsn0,lsn1,lsn2,lsn3,lsn4,lsn5,lsn6,lsn7,lsn8,lsn9
lsn0: .ltext "PLAYA NICE"
lsn1: .ltext "CIELOS DE NICE"
lsn2: .ltext "PUERTO DEL SOL"
lsn3: .ltext "LOS CAYOS"
lsn4: .ltext "AUTOPISTA 95"
lsn5: .ltext "BAHIA DE NICE"
lsn6: .ltext "DISTRITO ART DECO"
lsn7: .ltext "AEROPUERTO"
lsn8: .ltext "CENTRO NOCTURNO"
lsn9: .ltext "LA MANSION"

title_strs:
    .str $22C5, "1 JUGADOR"
    .str $22D1, "2 JUGADORES"
    .str $2329, "PRESIONA START"
    .str $2367, "2026 HOMEBREW MMC3"
    .byte 0
press_str: .ltext "PRESIONA START"
blank14: .ltext "              "
