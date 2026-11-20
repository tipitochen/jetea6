; =====================================================================
;  MENUS / ESCENAS  (JETEA 6)
; =====================================================================
logo_init:
    jsr ppu_off
    lda #7
    jsr r6_set
    jmp logo_init_b
logo_exit:
    jsr ppu_off
    jsr r6_zero
    lda #$0F
    sta pal_buf
    jmp title_init

title_init:
    jsr ppu_off
    jsr r6_two
    jmp title_init_b
title_to_game:
    jsr ppu_off
    jsr r6_zero
    jmp new_game
title_to_sel:
    jsr ppu_off
    jsr r6_zero
    jmp select_init
r6_two:
    lda #2
    bne r6_set
r6_zero:
    lda #0
r6_set:
    pha
    lda #6
    sta $8000
    pla
    sta $8001
    rts

init_p1:               ; A = personaje
    ldx #0
    jmp init_ps
init_p2:
    ldx #32
init_ps:               ; X = desplazamiento, A = personaje
    pha
    ldy #32
    lda #0
@z:
    sta p_base,x
    inx
    dey
    bne @z
    txa
    sec
    sbc #32
    tax
    pla
    sta p_base+30,x
    lda #1
    sta p_base+31,x
    lda #3
    sta p_base+14,x
    lda #16
    sta p_base+13,x
    rts

new_game:
    lda #0
    ldx #15
@iv:
    sta inv_ammo,x
    dex
    bpl @iv
    sta level
    ldx #5
@sc:
    sta score,x
    dex
    bpl @sc
    lda #3
    sta continues
    lda #0
    sta cont_t
    lda #$FF
    sta cur
    ; codigo konami: empezar en el nivel elegido (10 = el final)
    lda start_lvl
    beq @st
    cmp #10
    bcc @lv
    jmp story_final
@lv:
    sta level
    jmp intro_init
@st:
    jmp story_init

; ---------------------------------------------------------------- mini historia (3 escenas)
ST_HDR = $8C20
ST_LINES = $8C28
story_init:
    lda #0
    sta st_scene
story_load:
    jsr ppu_off
    lda #6
    sta $8000
    lda st_scene
    clc
    adc #3
    sta $8001
    ; variante: 0 ambos, 1 Jose, 2 Luciana
    lda st_scene
    cmp #3
    bcs @v0
    lda two_p
    bne @v0
    lda p_base+30
    clc
    adc #1
    jmp @v
@v0:
    lda #0
@v:
    asl
    asl
    clc
    adc #$80
    sta ptr+1
    lda #$20
    sta ptr
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR
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
    lda #$00
    ldx #$80
    jsr load_pal_ptr
    lda ST_HDR
    sta chr_r0
    lda ST_HDR+1
    sta chr_r1
    lda ST_HDR+2
    sta irq_b0
    lda ST_HDR+3
    sta irq_b1
    lda ST_HDR+4
    sta irq_ln
    lda #<ST_LINES
    sta st_p
    lda #>ST_LINES
    sta st_p+1
    lda #0
    sta tfill
    sta st_ph
    sta st_t
    jsr clear_oam
    lda #ST_STORY
    sta state
    lda #2
    sta game_irq
    jmp ppu_enable

story_final:
    lda #3
    sta st_scene
    jmp story_load
story_final_end:
    jsr ppu_off
    jsr r6_zero
    jmp ending_init
story_end:
    jsr ppu_off
    jsr r6_zero
    jmp cut_init

st_story:
    inc st_t
    lda pad_new
    and #BTN_START
    beq @ns
    lda st_scene
    cmp #3
    bcs story_final_end
    jmp story_end
@ns:
    ; luces que parpadean
    lda frame
    and #15
    bne @nf
    ldx ST_HDR+5
    lda frame
    and #16
    beq @fa
    lda ST_HDR+7
    jmp @fs
@fa:
    lda ST_HDR+6
@fs:
    sta pal_buf,x
    lda #1
    sta pal_dirty
@nf:
    lda st_ph
    beq @ph0
    cmp #1
    beq @ph1
    cmp #2
    beq @ph2
    jmp @ph3
@ph0:
    ; nueva linea: nombre del que habla
    ldy #0
    lda (st_p),y
    cmp #$FF
    bne @nl
    inc st_scene
    lda st_scene
    cmp #3
    bcc @nx
    bne @fin
    jmp story_end
@fin:
    jmp story_final_end
@nx:
    jmp story_load
@nl:
    cmp #2
    bcs @nm
    ldx two_p
    bne @nm
    lda p_base+30
@nm:
    tax
    lda st_names_lo,x
    sta ptr
    lda st_names_hi,x
    sta ptr+1
    lda #24
    jsr queue_line
    inc st_ph
    rts
@ph1:
    lda str_pending
    bne @r
    lda #<st_blank
    sta ptr
    lda #>st_blank
    sta ptr+1
    lda #26
    jsr queue_line
    ldy #1
    lda (st_p),y
    sta st_len
    lda #32
    sec
    sbc st_len
    lsr
    sta st_col
    lda #0
    sta st_pos
    inc st_ph
@r:
    rts
@ph2:
    ; maquina de escribir
    lda str_pending
    bne @r
    lda bgq_n
    bne @r
    lda st_t
    and #1
    bne @r
    lda st_pos
    clc
    adc st_col
    adc #$40
    sta tmp1
    lda #$23
    sta tmp0
    lda st_pos
    clc
    adc #2
    tay
    lda (st_p),y
    jsr bgq_add
    inc st_pos
    lda st_pos
    cmp st_len
    bne @r
    lda #0
    sta st_t
    inc st_ph
    rts
@ph3:
    ; esperar boton o tiempo
    lda pad_new
    and #BTN_A|BTN_B
    bne @adv
    lda st_t
    cmp #150
    bcc @r
@adv:
    lda st_len
    clc
    adc #2
    adc st_p
    sta st_p
    lda st_p+1
    adc #0
    sta st_p+1
    lda #0
    sta st_ph
    rts

st_names_lo: .byte <st_n0, <st_n1, <st_n2, <st_n0, <st_n1, <st_blank
st_names_hi: .byte >st_n0, >st_n1, >st_n2, >st_n0, >st_n1, >st_blank
st_n0: .ltext "JOSE:"
st_n1: .ltext "LUCIANA:"
st_n2: .ltext "CAJERO:"
st_blank: .ltext " "

; ---------------------------------------------------------------- seleccion
select_init:
    jsr ppu_off
    jsr r6_two
    lda #0
    sta chr_r0
    lda #18
    sta chr_r1
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
    jsr r6_zero
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
    jsr init_p1
    lda #0
    sta p_base+32+31
    jsr sfx_power
    jmp new_game
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
    lda #92
    sta sy
    jsr draw_frame2
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
    lda #136
    sta sy
    lda #$40
    sta stile
    lda #1
    sta sremap
    lda #$40
    sta sflip
    jsr draw_frame2
    ; flecha que apunta al personaje elegido (del lado vacio)
    jsr reset_draw
    lda frame
    lsr
    lsr
    and #3
    sta tmp0
    lda sel
    bne @al
    lda #$40
    sta sflip
    lda #122
    clc
    adc tmp0
    sta sx_lo
    lda #76
    bne @ad
@al:
    lda #136
    sec
    sbc tmp0
    sta sx_lo
    lda #120
@ad:
    sta sy
    lda #0
    sta sx_hi
    lda #MF_ARROW
    jmp draw_misc

sel_frame:             ; X = personaje -> A = cuadro
    cpx sel
    bne @idle
    lda frame
    lsr
    lsr
    and #7
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
    lda two_p
    beq @q1
    lda #<cut_l3c
    sta ptr
    lda #>cut_l3c
    sta ptr+1
    jmp @q0
@q1:
    lda p_base+30
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
    lda #0
    sta cact
    jsr cut_actor
    lda two_p
    beq @r1
    lda #1
    sta cact
    jmp cut_actor
@r1:
    rts

; actor de la escena (cact = 0 jugador 1 / 1 jugador 2)
cact_dy: .byte 0, 26
cact_mx: .byte 212, 172
cact_rx: .byte 128, 110
cut_actor:
    jsr reset_draw
    ldx cact
    beq @a0
    lda #$40
    sta stile
@a0:
    lda cut_t
    cmp #60
    bcs @pl
    jmp @parked
@pl:
    cmp #160
    bcc @__n727_0
    jmp @ride
@__n727_0:
    ; sale corriendo del banco
    sec
    sbc #60
    clc
    adc cact_rx,x
    sta tmp0
    lda cact_mx,x
    sec
    sbc #8
    cmp tmp0
    bcs @px
    sta tmp0
@px:
    lda tmp0
    sta sx_lo
    lda #0
    sta sx_hi
    lda #200
    clc
    adc cact_dy,x
    sta sy
    lda frame
    lsr
    and #7
    tay
    lda walk_seq,y
    tay
    jsr cact_char
    bne @lc
    lda jose_bk,y
    jsr cact_bank
    lda jose_lo,y
    sta fptr
    lda jose_hi,y
    sta fptr+1
    jmp @dc
@lc:
    lda luci_bk,y
    jsr cact_bank
    lda luci_lo,y
    sta fptr
    lda luci_hi,y
    sta fptr+1
@dc:
    jsr draw_frame2
    jmp @pk
@parked:
    ; banco de quieto del personaje (contiene el prefijo de vehiculos)
    ldy #0
    jsr cact_char
    bne @pb
    lda jose_bk,y
    jmp @pc
@pb:
    lda luci_bk,y
@pc:
    jsr cact_bank
@pk:
    ldx cact
    lda cact_mx,x
    sta sx_lo
    lda #0
    sta sx_hi
    lda #204
    clc
    adc cact_dy,x
    sta sy
    lda park_lo+1
    sta fptr
    lda park_hi+1
    sta fptr+1
    jmp draw_frame
@ride:
    sec
    sbc #160
    asl
    clc
    adc cact_mx,x
    sta sx_lo
    lda #0
    adc #0
    sta sx_hi
    lda #204
    clc
    adc cact_dy,x
    sta sy
    lda frame
    lsr
    lsr
    and #1
    tay
    jsr cact_char
    bne @lm
    lda jose_ride_bk,y
    jsr cact_bank
    lda jose_ride_lo,y
    sta fptr
    lda jose_ride_hi,y
    sta fptr+1
    jmp draw_frame2
@lm:
    lda luci_ride_bk,y
    jsr cact_bank
    lda luci_ride_lo,y
    sta fptr
    lda luci_ride_hi,y
    sta fptr+1
    jmp draw_frame2

cact_char:             ; -> A = personaje del actor (con flags)
    ldx cact
    lda p_base+30
    cpx #0
    beq @c
    lda p_base+62
@c:
    cmp #0
    rts
cact_bank:             ; A = banco -> R2 (actor 0) o R3 (actor 1)
    ldx cact
    bne @b3
    sta chr_r2
    rts
@b3:
    sta chr_r3
    rts

; ---------------------------------------------------------------- intro de nivel
intro_init:
    jsr ppu_off
    jsr r6_two
    lda #0
    jsr mus_play
    lda #0
    sta chr_r0
    jsr lvl_index
    lda level_tbl+23,x
    sta stars
    lda level_tbl+22,x
    sta faction
    lda level_tbl+24,x
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
    lda #$11
    sta PPUADDR
    lda p_base+14
    clc
    adc #$10
    sta PPUDATA
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$52
    sta PPUADDR
    lda continues
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
    jsr r6_zero
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
    sty ts_state
    pha
    txa
    pha
    jsr ppu_off
    jsr r6_two
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
    lda ts_state
    sta state
    lda #90
    sta timer
    jsr r6_zero
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

; ---------------------------------------------------------------- continuar (pantalla negra)
cont_init:
    lda #10
    sta cont_t
    lda #60
    sta cont_fr
    lda #0
    sta ptr2+1
    lda #<cont_strs
    ldx #>cont_strs
    ldy #ST_CONT
    jmp text_screen

st_cont:
    dec cont_fr
    bne @s
    lda #60
    sta cont_fr
    dec cont_t
    bne @s
    jmp gameover_init
@s:
    lda bgq_n
    bne @k
    lda #$21
    sta tmp0
    lda #$90
    sta tmp1
    lda cont_t
    clc
    adc #$10
    cmp #$1A
    bcc @d
    lda #$19
@d:
    jsr bgq_add
    lda #$22
    sta tmp0
    lda #$56
    sta tmp1
    lda continues
    clc
    adc #$10
    jsr bgq_add
@k:
    lda padn1
    ora padn2
    and #BTN_START
    beq @r
    ldx #0
    jsr revive_player
    lda two_p
    beq @g
    inc continues
    ldx #1
    jsr revive_player
@g:
    jmp level_resume
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
    lda two_p
    beq @onep
    lda #<end_both
    sta ptr2
    lda #>end_both
    sta ptr2+1
    jmp @d
@onep:
    lda p_base+30
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
    jmp story_final
@n:
    jmp clear_init

; ---------------------------------------------------------------- textos
sel_jose: .ltext "JOSE DUALCORE"
sel_luci: .ltext "LUCIANA CARRETERAS"
cut_l1: .ltext "NICE CITY  -  3:00 AM"
cut_l2: .ltext "ALARMA EN EL BANCO!"
cut_l3: .ltext "JOSE DUALCORE"
cut_l3b: .ltext "LUCIANA CARRETERAS"
cut_l4: .ltext "EL ROBO DEL SIGLO!"
cut_l3c: .ltext "JOSE Y LUCIANA"
cut_l5: .ltext "POLICIA Y EJERCITO EN CAMINO"
cut_l6: .ltext "ESCAPA!"

pal_select:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$2C,$00, $0F,$2C,$30,$00
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$30,$25, $0F,$0F,$27,$30
pal_intro:
    .byte $0F,$30,$10,$00, $0F,$24,$27,$28, $0F,$30,$16,$28, $0F,$30,$16,$28
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$27,$12, $0F,$0F,$27,$30
pal_cut:
    .byte $0F,$00,$10,$30, $0F,$2D,$10,$28, $0F,$30,$10,$00, $0F,$28,$16,$28
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$27,$12, $0F,$0F,$27,$30
