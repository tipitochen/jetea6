; =====================================================================
;  banco 7: presentacion NIKITA (se ejecuta mapeado en $8000)
; =====================================================================
    .include "bank7data.asm"
LOGO_ROW = 12

logo_init_b:
    lda #0
    jsr clear_nt
    lda #NK_UNIT
    sta chr_r0
    lda #NK_UNIT+2
    sta chr_r1
    lda #<nk_pal
    ldx #>nk_pal
    jsr load_pal_ptr
    jsr clear_oam
    lda #0
    sta mus_on
    sta lg_step
    sta lg_row
    sta lg_t
    sta lg_ph
    sta game_irq
    lda #$30
    sta $4000
    sta $4004
    sta $400C
    lda #$80
    sta $4008
    lda #ST_LOGO
    sta state
    jmp ppu_enable

st_logo:
    inc lg_t
    lda pad_new
    and #BTN_START|BTN_A
    beq @nk
    jmp logo_exit
@nk:
    lda lg_ph
    bne @p1
    ; espera inicial en negro
    lda lg_t
    cmp #40
    bcc @r
    lda #1
    sta lg_ph
@r:
    rts
@p1:
    cmp #1
    beq @write
    cmp #2
    bne @fd
    jmp @hold
@fd:
    jmp @fade
@write:
    lda str_pending
    bne @r
    lda lg_row
    cmp #6
    bcc @__n65_0
    jmp @done
@__n65_0:
    ; ptr = nk_nt + paso*192 + fila*32
    lda #<nk_nt
    sta ptr
    lda #>nk_nt
    sta ptr+1
    ldx lg_step
    beq @rw
@sx:
    lda ptr
    clc
    adc #192
    sta ptr
    bcc @s1
    inc ptr+1
@s1:
    dex
    bne @sx
@rw:
    lda lg_row
    asl
    asl
    asl
    asl
    asl
    clc
    adc ptr
    sta ptr
    bcc @s2
    inc ptr+1
@s2:
    ldy #31
@cp:
    lda (ptr),y
    sta str_buf,y
    dey
    bpl @cp
    ; direccion = $2000 + (LOGO_ROW + fila) * 32
    lda lg_row
    clc
    adc #LOGO_ROW
    sta tmp0
    lda #0
    sta tmp1
    ldx #5
@m:
    asl tmp0
    rol tmp1
    dex
    bne @m
    lda tmp0
    sta str_lo
    lda tmp1
    ora #$20
    sta str_hi
    lda #1
    sta str_pending
    inc lg_row
    lda lg_row
    cmp #6
    bne @r2
    ; paso completo: sonido
    lda #0
    sta lg_t
    lda lg_step
    cmp #NK_STEPS-1
    beq @zap
    tax
    lda #$86
    sta $4004
    lda #0
    sta $4005
    lda chime_p,x
    sta $4006
    lda #$08
    sta $4007
@r2:
    rts
@zap:
    ; rayos: ruido + barrido hacia abajo + destello
    lda #$04
    sta $400C
    lda #$06
    sta $400E
    lda #$18
    sta $400F
    lda #$84
    sta $4000
    lda #$B3
    sta $4001
    lda #$30
    sta $4002
    lda #$08
    sta $4003
    lda #$30
    sta pal_buf
    sta pal_buf+16
    lda #1
    sta pal_dirty
    rts
@done:
    lda lg_step
    cmp #NK_STEPS-1
    beq @last
    lda lg_t
    cmp #10
    bcc @r3
    inc lg_step
    lda #0
    sta lg_row
@r3:
    rts
@last:
    lda #2
    sta lg_ph
    lda #0
    sta lg_t
    rts
@hold:
    ; destello del fondo y los rayos que titilan
    lda lg_t
    cmp #4
    bne @h1
    lda #$0F
    sta pal_buf
    sta pal_buf+16
    lda #1
    sta pal_dirty
@h1:
    lda lg_t
    cmp #20
    bne @h2
    ; tintineo final (dos notas)
    lda #$84
    sta $4004
    lda #0
    sta $4005
    lda #$23
    sta $4006
    lda #$08
    sta $4007
@h2:
    lda lg_t
    and #3
    bne @h3
    lda lg_t
    and #4
    beq @hy
    lda #$38
    bne @hs
@hy:
    lda #$28
@hs:
    sta pal_buf+2
    lda #1
    sta pal_dirty
@h3:
    lda lg_t
    cmp #130
    bcc @r4
    lda #3
    sta lg_ph
    lda #0
    sta lg_t
@r4:
    rts
@fade:
    lda lg_t
    and #7
    bne @r5
    lda lg_t
    lsr
    lsr
    lsr
    tax
    cpx #4
    bcs @out
    lda fade_w,x
    sta pal_buf+1
    lda fade_y,x
    sta pal_buf+2
    lda #1
    sta pal_dirty
@r5:
    rts
@out:
    jmp logo_exit

chime_p: .byte $54, $46, $38, $2F, $29, $23, $1F
fade_w:  .byte $30, $10, $00, $0F
fade_y:  .byte $28, $18, $08, $0F
nk_pal:
    .byte $0F,$30,$28,$16, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F
    .byte $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F

; =====================================================================
;  PAUSA e INVENTARIO (banco 7)
; =====================================================================
INV_ROW = 27
slot_t: .byte 0, 1, 2, 3, 4, 6

pause_open_b:          ; A = botones nuevos, X = jugador
    and #BTN_SEL
    beq @p
    lda #1
@p:
    sta pz_mode
    stx pz_pl
    jsr load_player
    lda #0
    sta pz_ph
    sta mus_on
    lda #$30
    sta $4000
    sta $4004
    sta $400C
    lda #$80
    sta $4008
    ; cursor en el arma actual
    ldx #5
@c:
    lda slot_t,x
    cmp weap
    beq @cf
    dex
    bne @c
@cf:
    stx pz_cur
    lda #ST_PAUSE
    sta state
    jmp sfx_power

; ammo del tipo A para el jugador en pausa -> A (Z si no tiene)
inv_count:
    cmp weap
    bne @i
    lda ammo
    rts
@i:
    sta tmp2
    lda pz_pl
    asl
    asl
    asl
    ora tmp2
    tay
    lda inv_ammo,y
    rts

; slot X disponible? (C=1 si)
slot_ok:
    cpx #0
    beq @y
    lda slot_t,x
    jsr inv_count
    beq @n
@y:
    sec
    rts
@n:
    clc
    rts

pause_tick_b:
    lda pz_ph
    cmp #10
    bcs @nw
    jmp pz_write
@nw:
    beq @int
    jmp pz_restore
@int:
    ldx pz_pl
    lda padn1
    cpx #0
    beq @pd
    lda padn2
@pd:
    sta tmp5
    lda pz_mode
    bne @inv
    lda tmp5
    and #BTN_START
    beq @r
    jmp pz_close
@r:
    rts
@inv:
    lda tmp5
    and #BTN_START|BTN_SEL|BTN_A|BTN_B
    beq @mv
    ldx pz_cur
    lda slot_t,x
    jsr pz_equip
    jmp pz_close
@mv:
    lda tmp5
    and #BTN_RIGHT|BTN_DOWN
    beq @lf
    ldx pz_cur
@nx:
    inx
    cpx #6
    bcc @n1
    ldx #0
@n1:
    jsr slot_ok
    bcc @nx
    jmp @set
@lf:
    lda tmp5
    and #BTN_LEFT|BTN_UP
    beq @r
    ldx pz_cur
@pv:
    dex
    bpl @p1
    ldx #5
@p1:
    jsr slot_ok
    bcc @pv
@set:
    stx pz_cur
    lda #2                ; reescribir filas de iconos y numeros
    sta pz_ph
    jmp sfx_shoot

pz_equip:              ; A = tipo
    cmp weap
    beq @r
    pha
    lda weap
    beq @g
    lda pz_pl
    asl
    asl
    asl
    ora weap
    tay
    lda inv_ammo,y
    clc
    adc ammo
    cmp #99
    bcc @c
    lda #99
@c:
    sta inv_ammo,y
@g:
    pla
    sta weap
    lda #0
    sta ammo
    lda weap
    beq @r
    lda pz_pl
    asl
    asl
    asl
    ora weap
    tay
    lda inv_ammo,y
    sta ammo
    lda #0
    sta inv_ammo,y
@r:
    rts

pz_close:
    lda #20
    sta pz_ph
    jmp sfx_power

; tile de la barra: A = indice dentro de wtile (12/13 puno, 14 borde, 15 relleno)
wt_tile:
    tay
    lda (wtile_ptr),y
    rts

; fila tmp6 (0 borde, 1 iconos, 2 numeros) en linebuf
pz_line:
    lda #15
    jsr wt_tile
    sta tmp3
    ldx #31
    lda tmp6
    bne @f
    lda #14
    jsr wt_tile
    sta tmp3
@f:
    lda tmp3
@cl:
    sta linebuf,x
    dex
    bpl @cl
    lda tmp6
    bne @r0
    rts
@r0:
    lda pz_mode
    bne @inv
    lda tmp6
    cmp #1
    bne @rr
    ldx #4
@pt:
    lda pausa_t,x
    sta linebuf+13,x
    dex
    bpl @pt
@rr:
    rts
@inv:
    ldx #0
@sl:
    stx tmp7
    jsr slot_ok
    bcc @nx
    ; columna = 1 + 5*slot
    lda tmp7
    asl
    asl
    clc
    adc tmp7
    adc #1
    tay
    lda tmp6
    cmp #1
    bne @num
    ; fila de iconos: cursor + icono de 2 tiles
    ldx tmp7
    lda #30               ; '>'
    cpx pz_cur
    beq @cu
    lda tmp3
@cu:
    sta linebuf,y
    iny
    sty tmp1
    lda slot_t,x
    bne @wi
    lda #12               ; puño
    bne @wj
@wi:
    sec
    sbc #1
    asl
@wj:
    sta tmp2
    jsr wt_tile
    ldy tmp1
    sta linebuf,y
    lda tmp2
    clc
    adc #1
    jsr wt_tile
    ldy tmp1
    sta linebuf+1,y
    jmp @nx
@num:
    ; fila de numeros (el puño no tiene)
    ldx tmp7
    beq @nx
    iny
    sty tmp1
    lda slot_t,x
    jsr inv_count
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
    ldy tmp1
    sta linebuf,y
    pla
    sta linebuf+1,y
@nx:
    ldx tmp7
    inx
    cpx #6
    bne @sl
    rts

; fase -> fila (26..28) y pantalla: ph 0..5 => fila = 26 + ph/2, pantalla = ph&1
pz_addr:
    lda tmp4
    lsr
    clc
    adc #26
    sta tmp0
    lda #0
    sta tmp1
    ldx #5
@m:
    asl tmp0
    rol tmp1
    dex
    bne @m
    lda tmp0
    sta str_lo
    lda tmp4
    and #1
    beq @a
    lda #$24
@a:
    ora #$20
    ora tmp1
    sta str_hi
    rts

; atributos de las filas 24-31: A = valor, tmp4 = lote 0..3 (8 bytes c/u)
pz_attr:
    sta tmp3
    lda bgq_n
    bne @no
    lda tmp4
    and #2
    beq @a
    lda #$27
    bne @b
@a:
    lda #$23
@b:
    sta tmp0
    lda tmp4
    and #1
    asl
    asl
    asl
    ora #$F0
    sta tmp1
    lda #8
    sta tmp2
@l:
    lda tmp3
    jsr bgq_add
    inc tmp1
    dec tmp2
    bne @l
    sec
    rts
@no:
    clc
    rts

pz_write:
    lda pz_ph
    cmp #6
    bcc @rows
    ; atributos a paleta 0 (fondo propio de la barra)
    sec
    sbc #6
    sta tmp4
    lda #$00
    jsr pz_attr
    bcc @r
    inc pz_ph
@r:
    rts
@rows:
    lda str_pending
    bne @r
    lda pz_ph
    sta tmp4
    lsr
    sta tmp6
    jsr pz_line
    lda cam_lo
    lsr
    lsr
    lsr
    sta tmp5
    ldx #0
@ro:
    txa
    clc
    adc tmp5
    and #31
    tay
    lda linebuf,x
    sta str_buf,y
    inx
    cpx #32
    bne @ro
    jsr pz_addr
    lda #1
    sta str_pending
    inc pz_ph
    rts

pz_restore:
    lda pz_ph
    cmp #26
    bcs @at
    lda str_pending
    bne @r
    lda pz_ph
    sec
    sbc #20
    sta tmp4
    ; fila de calle: street_ptr + (x & 3) + 4*(fila-18)
    lsr
    asl
    asl
    clc
    adc #32
    sta tmp5
    ldx #0
@x:
    txa
    and #3
    clc
    adc tmp5
    tay
    lda (street_ptr),y
    sta str_buf,x
    inx
    cpx #32
    bne @x
    jsr pz_addr
    lda #1
    sta str_pending
    inc pz_ph
@r:
    rts
@at:
    cmp #30
    beq @end
    sec
    sbc #26
    sta tmp4
    lda #$FF
    jsr pz_attr
    bcc @r
    inc pz_ph
    rts
@end:
    jsr store_player
    lda #0
    ldx #NW-1
@w:
    sta w_paint,x
    dex
    bpl @w
    lda #ST_PLAY
    sta state
    lda track
    jmp mus_play

pausa_t: .byte 48, 33, 53, 51, 33      ; P A U S A

; =====================================================================
;  ARSENAL: personaje grande girando + menu de armas (banco 7)
; =====================================================================
    .include "ars_data.asm"
ars_c   = $05E4      ; personaje
ars_i   = $05E5      ; indice en la secuencia de giro
ars_a   = $05E6      ; angulo actual (0..4)
ars_t   = $05E7

ars_init_b:            ; ppu apagada, banco 7 mapeado, pz_pl = jugador
    ldx pz_pl
    jsr load_player
    lda char
    sta ars_c
    lda #0
    sta ars_i
    sta ars_a
    sta ars_t
    sta game_irq
    sta tfill
    jsr clear_nt
    ; celdas de la figura: filas 4..18, columnas 0..11, ids 64 + fila*12 + col
    lda #64
    sta tmp2
    lda #0
    sta tmp3              ; fila
@fr:
    lda tmp3
    clc
    adc #4
    sta tmp0
    lda #0
    sta tmp1
    ldx #5
@m:
    asl tmp0
    rol tmp1
    dex
    bne @m
    bit PPUSTATUS
    lda tmp1
    ora #$20
    sta PPUADDR
    lda tmp0
    sta PPUADDR
    ldx #12
@fc:
    lda tmp2
    sta PPUDATA
    inc tmp2
    dex
    bne @fc
    inc tmp3
    lda tmp3
    cmp #15
    bne @fr
    lda #<ars_strs
    ldx #>ars_strs
    jsr draw_ptr
    ; nombre del personaje
    lda ars_c
    bne @nl
    lda #<ars_nj
    ldx #>ars_nj
    jmp @nd
@nl:
    lda #<ars_nl
    ldx #>ars_nl
@nd:
    jsr draw_ptr
    ; balas de cada arma
    ldx #1
@am:
    stx tmp7
    jsr ars_ammo_addr
    ldx tmp7
    jsr slot_ok
    bcc @no
    ldx tmp7
    lda slot_t,x
    jsr inv_count
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
    sty PPUDATA
    sta PPUDATA
    jmp @nx
@no:
    lda #13               ; '-'
    sta PPUDATA
    sta PPUDATA
@nx:
    ldx tmp7
    inx
    cpx #6
    bne @am
    ; atributos: todo paleta 3, despues la figura
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR
    ldx #64
    lda #$FF
@at:
    sta PPUDATA
    dex
    bne @at
    jsr ars_attr_ptr
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C8
    sta PPUADDR
    ldy #0
@a2:
    lda (ptr),y
    sta PPUDATA
    iny
    cpy #32
    bne @a2
    ; paleta
    lda ars_c
    bne @pl
    lda #<ars_pal0
    ldx #>ars_pal0
    jmp @pp
@pl:
    lda #<ars_pal1
    ldx #>ars_pal1
@pp:
    jsr load_pal_ptr
    ; bancos: fuente (R2), figura (R3..R5), sprites (R0/R1)
    lda #0
    sta chr_r2
    jsr ars_banks
    ldx ars_c
    lda ars_sunit,x
    sta chr_r0
    clc
    adc #2
    sta chr_r1
    ; cursor en el arma actual
    ldx #5
@c:
    lda slot_t,x
    cmp weap
    beq @cf
    dex
    bne @c
@cf:
    stx pz_cur
    jsr clear_oam
    lda #$90              ; fondo en $1000, sprites en $0000
    sta ctrl_base
    lda #ST_ARS
    sta state
    jmp ppu_enable

ars_ammo_addr:         ; X = slot -> PPUADDR en fila 7+3X, columna 23
    stx tmp0
    txa
    asl
    clc
    adc tmp0
    adc #7
    sta tmp0
    lda #0
    sta tmp1
    ldy #5
@m:
    asl tmp0
    rol tmp1
    dey
    bne @m
    bit PPUSTATUS
    lda tmp1
    ora #$20
    sta PPUADDR
    lda tmp0
    ora #23
    sta PPUADDR
    rts

ars_idx:               ; A = personaje*NV + vista (no toca X ni Y)
    lda ars_c
    beq @z
    lda #ARS_NV
@z:
    clc
    adc ars_a
    rts

ars_banks:
    jsr ars_idx
    tax
    lda ars_units,x
    sta chr_r3
    clc
    adc #1
    sta chr_r45
    rts

ars_attr_ptr:          ; ptr = ars_attr + idx*32
    jsr ars_idx
    sta tmp0
    lda #0
    sta tmp1
    ldx #5
@m:
    asl tmp0
    rol tmp1
    dex
    bne @m
    lda tmp0
    clc
    adc #<ars_attr
    sta ptr
    lda tmp1
    adc #>ars_attr
    sta ptr+1
    rts

st_ars:
    inc ars_t
    ; girar: 16 pasos por vuelta (un solo sprite que gira), uno cada 4 cuadros
    lda ars_t
    and #3
    bne @ng
    lda str_pending
    bne @ng
    inc ars_i
    lda ars_i
    cmp #ARS_NSEQ
    bcc @si
    lda #0
@si:
    sta ars_i
    tax
    lda ars_seq,x
    sta ars_a
    jsr ars_banks
    jsr ars_attr_ptr
    ldy #31
@cp:
    lda (ptr),y
    sta str_buf,y
    dey
    bpl @cp
    lda #$23
    sta str_hi
    lda #$C8
    sta str_lo
    lda #1
    sta str_pending
@ng:
    ; controles del jugador que abrio el menu
    ldx pz_pl
    lda padn1
    cpx #0
    beq @pd
    lda padn2
@pd:
    sta tmp5
    and #BTN_A|BTN_B|BTN_START
    beq @nb
    ldx pz_cur
    lda slot_t,x
    jsr pz_equip
    jsr sfx_power
    jmp ars_close
@nb:
    lda tmp5
    and #BTN_SEL
    beq @mv
    jmp ars_close
@mv:
    lda tmp5
    and #BTN_DOWN|BTN_RIGHT
    beq @up
    ldx pz_cur
@n1:
    inx
    cpx #6
    bcc @n2
    ldx #0
@n2:
    jsr slot_ok
    bcc @n1
    stx pz_cur
    jsr sfx_shoot
    jmp @dr
@up:
    lda tmp5
    and #BTN_UP|BTN_LEFT
    beq @dr
    ldx pz_cur
@u1:
    dex
    bpl @u2
    ldx #5
@u2:
    jsr slot_ok
    bcc @u1
    stx pz_cur
    jsr sfx_shoot
@dr:
    jmp ars_draw

ars_close:
    jsr store_player
    jmp ars_exit

; sprites: correcciones del angulo + arma en la mano + flecha del menu
ars_draw:
    jsr clear_oam
    ldx #0                ; indice OAM
    jsr ars_idx
    tay
    lda ars_ov_lo,y
    sta ptr
    lda ars_ov_hi,y
    sta ptr+1
    ldy #0
    lda (ptr),y
    sta tmp3
    iny
    lda tmp3
    beq @ow
@ol:
    lda (ptr),y
    sta OAM,x
    iny
    lda (ptr),y
    sta OAM+1,x
    iny
    lda (ptr),y
    sta OAM+2,x
    iny
    lda (ptr),y
    sta OAM+3,x
    iny
    inx
    inx
    inx
    inx
    dec tmp3
    bne @ol
@ow:
    stx tmp4
    ; iconos de las armas (sin letras), uno por fila
    lda #0
    sta tmp2              ; slot
@icl:
    ldx tmp2
    lda ars_ic_lo,x
    sta ptr
    lda ars_ic_hi,x
    sta ptr+1
    txa                   ; y = 51 + 24*slot
    asl
    asl
    asl
    sta tmp1
    asl
    clc
    adc tmp1
    adc #51
    sta tmp1
    ldy #0
    lda (ptr),y
    sta tmp3
    iny
    ldx tmp4
@iw:
    lda (ptr),y           ; dy
    clc
    adc tmp1
    sta OAM,x
    iny
    lda (ptr),y           ; tile
    sta OAM+1,x
    iny
    lda #3
    sta OAM+2,x
    lda (ptr),y           ; dx
    clc
    adc #140
    sta OAM+3,x
    iny
    inx
    inx
    inx
    inx
    dec tmp3
    bne @iw
    stx tmp4
    inc tmp2
    lda tmp2
    cmp #6
    bne @icl
@arr:
    ; flecha que se mueve al lado del arma elegida
    ldx tmp4
    lda pz_cur            ; y = 55 + 24*slot
    asl
    asl
    asl
    sta tmp1
    asl
    clc
    adc tmp1
    adc #55
    sta OAM,x
    lda #ARS_ARROW
    sta OAM+1,x
    lda #3
    sta OAM+2,x
    lda ars_t
    lsr
    lsr
    and #3
    clc
    adc #124
    sta OAM+3,x
    rts

ars_strs:
    .str $20B3, "ARSENAL"
    .byte 0
ars_nj:
    .str $2283, "JOSE DUALCORE"
    .byte 0
ars_nl:
    .str $2281, "LUCIANA CARRETERAS"
    .byte 0
