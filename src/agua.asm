; =====================================================================
;  NIVEL 6: BAHIA DE NICE  (banco 9 en $8000 durante todo el nivel)
;  Persecucion en moto de agua. 1 jugador maneja y dispara; 2 jugadores: el 1 maneja, el 2 dispara.
;  Enemigos: policias en moto de agua, tiburones que saltan (hay que esquivarlos).
;  Jefe: la punta de un yate con tiradores en la cubierta.
; =====================================================================
    .include "agua_data.asm"

wHE_N = 5
wHB_N = 8
wHQ_N = 7
wHX_N = 4
wh_x     = $0600
wh_y     = $0601
wh_inv   = $0602
wh_cd    = $0603
wh_dead  = $0604
wh_pause = $0605
wh_t     = $0606
wh_wt    = $0607
wh_wi    = $0608
wh_boss  = $0609
wh_end   = $060A
wh_rnd   = $060B
wh_sv    = $060C
wbs_x    = $0610
wbs_y    = $0611
wbs_vy   = $0612
wbs_hp   = $0613
wbs_t    = $0614
wbs_fl   = $0615
wbs_ph   = $0616
wbs_n    = $0617
whi_jx   = $0618
whi_lx   = $0619
whi_ph   = $061A
whi_tm   = $061B
wh_intro = $061C
whi_f    = $061D
whi_jy   = $061E
whi_ly   = $061F
wsc_dy   = $0664
wsc_dx   = $0667
we_t     = $0620
we_x     = $0626
we_fx    = $062C
we_y     = $0632
we_fy    = $0638
we_vx    = $063E
we_vy    = $0644
we_hp    = $064A
we_tm    = $0650
we_fl    = $0656
we_cd    = $065C
wpb_t    = $0670
wpb_x    = $0678
wpb_y    = $0680
wpb_dx   = $0688
wpb_dy   = $0690
wq_t     = $06A0
wq_x     = $06AA
wq_fx    = $06B4
wq_y     = $06BE
wq_fy    = $06C8
wq_vx    = $06D2
wq_vy    = $06DC
wx_t     = $06E8
wx_x     = $06EC
wx_y     = $06F0
wi_vy    = $06F4        ; salto de cada personaje al subir a la moto (2)
w_var    = $06F6        ; 0 Jose, 1 Luciana, 2 los dos
w_spd    = $06F7
w_pf     = $06F8        ; primer cuadro del jugador
w_stop   = $06F9        ; el mar deja de avanzar (jefe)
w_gfl    = $06FA        ; fogonazo de los tiradores
wBOSS_HP = 190
WY_MIN   = 118          ; el agua empieza aca (pies de la moto)
WY_MAX   = 220
DOCK_Y   = 160          ; pies sobre el muelle
JET_X    = 156          ; la moto estacionada
JET_Y    = 192

; ---------------------------------------------------------------- inicio (PPU apagada, banco 9 mapeado)
agua_init:
    lda #$88
    sta ctrl_base
    ldx #0
    lda #0
@z:
    sta $0600,x
    inx
    bne @z
    ; que moto: Jose / Luciana / los dos
    lda #2
    ldx two_p
    bne @v
    lda p_base+30
@v:
    sta w_var
    asl
    clc
    adc #AF_PL0
    sta w_pf
    ; escena del muelle
    lda #1
    sta wh_intro
    lda #DOCK_Y
    sta whi_jy
    sta whi_ly
    lda #40
    sta whi_jx
    lda #12
    sta whi_lx
    lda two_p
    bne @dos
    lda #$FF
    sta whi_lx
@dos:
    lda #JET_X
    sta wh_x
    lda #JET_Y
    sta wh_y
    lda #$FF
    sta wsc_dx
    sta wsc_dx+1
    lda #60
    sta wh_wt
    lda #0
    sta cam_lo
    sta cam_hi
    sta boss_on
    sta shake
    sta p_base+16
    sta p_base+32+16
    lda p_base+13
    bne @h1
    lda #16
    sta p_base+13
@h1:
    jsr dock_setup
    lda #1
    jsr mus_play
    jsr hud_prepare
    jsr clear_oam
    lda #ST_AGUA
    sta state
    lda #1
    sta game_irq
    jmp ppu_enable

; paleta del HUD (nivel 1) + sprites propios; A/X = puntero a 12 bytes de paletas de fondo 1-3
agua_palette:
    sta ptr2
    stx ptr2+1
    ldx #0
    lda level_tbl+2,x
    sta ptr
    lda level_tbl+3,x
    sta ptr+1
    jsr load_palette
    ldy #11
@b:
    lda (ptr2),y
    sta pal_buf+4,y
    dey
    bpl @b
    ldx #15
@pp:
    lda agua_spal,x
    sta pal_buf+16,x
    dex
    bpl @pp
    jmp set_shirt

; ---- el muelle (pantalla fija)
dock_setup:
    jmp dock_setup2
w_r7on:                ; mapas grandes en el banco 10 ($A000), sin NMI mientras tanto
    lda #0
    sta PPUCTRL
    lda #7
    sta $8000
    lda #10
    sta $8001
    rts
w_r7off:
    lda #7
    sta $8000
    lda #1
    sta $8001
    lda ctrl_base
    and #$7F
    ora #$80
    sta PPUCTRL
    rts
dock_setup2:
    lda #ASC_A
    sta chr_r0
    lda #ASC_R1
    sta chr_r1
    lda #ASC_SPR
    sta chr_r45
    lda #<dock_pal
    ldx #>dock_pal
    jsr agua_palette
    lda #0
    jsr clear_nt
    jsr hud_static
    jsr w_r7on
    ; filas 4..7: cielo
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$80
    sta PPUADDR
    lda dock_map
    ldx #128
@f:
    sta PPUDATA
    dex
    bne @f
    lda #<dock_map
    sta ptr
    lda #>dock_map
    sta ptr+1
    lda #$21
    jsr wput_704
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR
    ldx #0
@a:
    lda dock_attr,x
    sta PPUDATA
    inx
    cpx #64
    bne @a
    jmp w_r7off

; ---- el mar del nivel (PPU apagada)
sea_setup:
    jmp sea_setup2
sea_setup2:
    lda #AGUA_FONT        ; fuente + tiles del yate
    sta chr_r0
    lda #AGUA_BG_UNIT
    sta chr_r1
    lda w_var
    clc
    adc #AGUA_PL_UNIT
    sta chr_r2
    lda #AGUA_EN_UNIT
    sta chr_r3
    lda boss_units+1      ; misc (balas, explosiones) + barra del jefe
    sta chr_r45
    lda #<agua_bgpal
    ldx #>agua_bgpal
    jsr agua_palette
    lda #0
    jsr clear_nt
    jsr hud_static
    jsr w_r7on
    lda #$20
    jsr agua_put_map
    lda #$24
    jsr agua_put_map
    lda #$23
    jsr agua_put_attr
    lda #$27
    jsr agua_put_attr
    jmp w_r7off

agua_put_map:          ; A = $20 o $24 -> filas 4..29 (832 bytes)
    bit PPUSTATUS
    sta PPUADDR
    lda #$80
    sta PPUADDR
    lda #<agua_map
    sta ptr
    lda #>agua_map
    sta ptr+1
    ldx #3
    ldy #0
@l:
    lda (ptr),y
    sta PPUDATA
    iny
    bne @l
    inc ptr+1
    dex
    bne @l
@t:
    lda (ptr),y
    sta PPUDATA
    iny
    cpy #64
    bne @t
    rts
wput_704:              ; A = pagina alta del PPU ($21/$25), ptr = datos
    bit PPUSTATUS
    sta PPUADDR
    lda #0
    sta PPUADDR
    ldx #2
    ldy #0
@l:
    lda (ptr),y
    sta PPUDATA
    iny
    bne @l
    inc ptr+1
    dex
    bne @l
@t:
    lda (ptr),y
    sta PPUDATA
    iny
    cpy #192
    bne @t
    rts
agua_put_attr:         ; A = $23 o $27
    bit PPUSTATUS
    sta PPUADDR
    lda #$C0
    sta PPUADDR
    ldx #0
@l:
    lda agua_attr,x
    sta PPUDATA
    inx
    cpx #64
    bne @l
    rts

; ---------------------------------------------------------------- cuadro
st_agua:
    lda wh_intro
    bne @np
    lda padn1
    ora padn2
    and #BTN_START
    beq @np
    lda wh_pause
    eor #1
    sta wh_pause
    jsr sfx_power
@np:
    lda wh_pause
    beq @run
    rts
@run:
    inc wh_t
    lda wh_intro
    beq @play
    jsr hud_prepare
    jmp agua_intro
@play:
    lda w_stop
    bne @c
    inc cam_lo
    bne @c
    inc cam_hi
@c:
    jsr rand
    jsr agua_player
    jsr agua_fire
    jsr agua_pbullets
    jsr agua_waves
    jsr agua_enemies
    jsr agua_boss
    jsr agua_qbullets
    jsr agua_fx
    jsr hud_prepare
    jsr agua_draw
    lda wh_dead
    beq @nd
    dec wh_dead
    bne @nd
    lda #0
    sta p_base+31
    sta p_base+32+31
    jmp heli_out_dead
@nd:
    lda wh_end
    beq @r
    dec wh_end
    bne @r
    jmp heli_out_clear
@r:
    rts

; ---------------------------------------------------------------- escena: subir a la moto de agua
; fase 0: caminan por el muelle y saltan a la moto, 1: arranca, 2: sale disparada (y la policia atras),
; 3: fundido a blanco, 4: la moto entra en el mar abierto
agua_intro:
    lda whi_ph
    cmp #3
    bcs @sk
    lda padn1
    ora padn2
    and #BTN_A|BTN_B
    beq @sk
    jmp wai_skip
@sk:
    lda whi_ph
    bne @p1
    ldx #0
    jsr wai_walk
    ldx #1
    jsr wai_walk
    lda whi_jx
    and whi_lx
    cmp #$FF
    beq @__n388_0
    jmp @dr
@__n388_0:
    ; todos arriba
    lda #1
    sta whi_ph
    lda #60
    sta whi_tm
    lda w_var
    clc
    adc #AGUA_PL_UNIT
    sta chr_r2
    jsr sfx_power
    jmp @dr
@p1:
    cmp #1
    bne @p2
    ; arranca el motor: la moto se sacude
    lda #1
    sta shake
    dec whi_tm
    bne @dr
    lda #0
    sta shake
    lda #2
    sta whi_ph
    lda #0
    sta w_spd
    jmp @dr
@p2:
    cmp #2
    bne @p3
    jsr wai_go
    jmp @dr
@p3:
    cmp #3
    bne @p4
    lda whi_tm
    and #7
    bne @nf
    jsr whi_fade
@nf:
    dec whi_tm
    bne @r
    ; al mar abierto
    jsr ppu_off
    jsr sea_setup
    lda #0
    sta wh_x
    lda #176
    sta wh_y
    lda #4
    sta whi_ph
    lda #1
    sta game_irq
    jsr clear_oam
    jmp ppu_enable
@p4:
    lda wh_x
    clc
    adc #2
    sta wh_x
    cmp #56
    bcc @d4
    jmp wai_done
@d4:
    jmp whi_draw_sky
@dr:
    jmp wai_draw
@r:
    rts

wai_go:                 ; la moto acelera hacia la derecha; la policia aparece atras
    lda wh_t
    and #7
    bne @a
    lda w_spd
    cmp #5
    bcs @a
    inc w_spd
@a:
    lda wh_x
    cmp #$FF
    beq @c
    clc
    adc w_spd
    bcs @g
    cmp #250
    bcc @s
@g:
    lda #$FF
@s:
    sta wh_x
    ; cuando la moto va por la mitad salen los policias
    cmp #200
    bcc @c
    lda wsc_dx
    cmp #$FF
    bne @c
    lda #0
    sta wsc_dx
    lda #$E0
    sta wsc_dx+1          ; el segundo entra un poco despues
    lda #204
    sta wsc_dy
    lda #224
    sta wsc_dy+1
    jsr sfx_power
@c:
    ldx #1
@l:
    lda wsc_dx,x
    cmp #$FF
    beq @n
    clc
    adc #3
    bcs @o
    cmp #252
    bcc @w
@o:
    lda #$FE              ; ya paso
@w:
    sta wsc_dx,x
@n:
    dex
    bpl @l
    ; termina cuando pasaron los dos
    lda wsc_dx
    and wsc_dx+1
    cmp #$FE
    bne @r
    lda #3
    sta whi_ph
    lda #40
    sta whi_tm
@r:
    rts

whi_fade:              ; aclara toda la paleta un paso (hacia blanco)
    ldx #31
@l:
    lda pal_buf,x
    cmp #$0F
    bne @n
    lda #$00
    jmp @s
@n:
    clc
    adc #$10
    cmp #$40
    bcc @s
    lda #$30
@s:
    sta pal_buf,x
    dex
    bpl @l
    lda #1
    sta pal_dirty
    rts

wai_skip:
    jsr ppu_off
    jsr sea_setup
    lda #0
    sta shake
    jsr wai_done
    lda #1
    sta game_irq
    jsr clear_oam
    jmp ppu_enable

wai_walk:               ; X = 0 / 1: camina por el muelle y salta a la moto
    lda whi_jx,x
    cmp #$FF
    beq @r
    cmp #120
    bcs @jump
    clc
    adc #1
    sta whi_jx,x
    cmp #120
    bne @r
    lda #$FD              ; salto: arranca subiendo
    sta wi_vy,x
    jmp sfx_shoot
@jump:
    ; no salta si el de adelante todavia esta en el aire en el mismo lugar (2P): igual va
    clc
    adc #1
    sta whi_jx,x
    lda whi_jy,x
    clc
    adc wi_vy,x
    sta whi_jy,x
    lda wh_t
    and #3
    bne @g
    inc wi_vy,x
@g:
    lda wi_vy,x
    bmi @r
    lda whi_jy,x
    cmp #JET_Y-8
    bcc @r
    lda #$FF              ; arriba de la moto
    sta whi_jx,x
    jsr sfx_hit
@r:
    rts

wai_done:
    lda #0
    sta wh_intro
    lda #56
    sta wh_x
    lda #176
    sta wh_y
    lda #60
    sta wh_inv
    lda #60
    sta wh_wt
    rts

whi_draw_sky:          ; solo la moto (entrando al mar abierto)
    jsr clear_oam
    jsr reset_draw
    lda #0
    sta sx_hi
    lda wh_x
    sta sx_lo
    lda wh_y
    sta sy
    lda wh_t
    lsr
    lsr
    and #1
    clc
    adc w_pf
    jmp whdraw

wai_draw:
    jsr clear_oam
    jsr reset_draw
    lda #0
    sta sx_hi
    ; personajes caminando o saltando
    ldx #0
    jsr wai_char
    ldx #1
    jsr wai_char
    jsr reset_draw
    ; la moto: vacia hasta que suben todos
    lda wh_x
    cmp #$FF
    beq @cp
    sta sx_lo
    lda wh_y
    sta sy
    lda whi_ph
    bne @full
    lda #AF_JE
    jsr whdraw
    jmp @cp
@full:
    lda wh_t
    lsr
    lsr
    and #1
    clc
    adc w_pf
    jsr whdraw
@cp:
    ; los policias en sus motos (mirando a la derecha)
    ldx #1
@c:
    lda wsc_dx,x
    cmp #$FE
    bcs @nc
    stx wh_sv
    sta sx_lo
    lda wsc_dy,x
    sta sy
    lda #$40
    sta sflip
    lda wh_t
    lsr
    lsr
    and #1
    clc
    adc #AF_SCJ0
    jsr whdraw
    ldx wh_sv
@nc:
    dex
    bpl @c
    jmp reset_draw

wai_char:               ; X = jugador
    lda whi_jx,x
    cmp #$FF
    beq @r
    sta sx_lo
    lda whi_jy,x
    sta sy
    lda #0
    sta sflip
    txa
    beq @p1
    lda #$40
@p1:
    sta stile
    stx wh_sv
    ; cuadro: caminando (16..19) o quieto en el salto
    ldy #0
    lda whi_jx,x
    cmp #120
    bcs @f
    lda wh_t
    lsr
    lsr
    lsr
    and #3
    tay
    iny
@f:
    sty whi_f
    txa
    asl
    asl
    asl
    asl
    asl
    tay
    lda p_base+30,y
    ldy whi_f
    cmp #0
    bne @lu
    lda whj_unit,y
    jsr whi_bank
    lda whj_lo,y
    sta fptr
    lda whj_hi,y
    sta fptr+1
    jmp @d
@lu:
    lda whl_unit,y
    jsr whi_bank
    lda whl_lo,y
    sta fptr
    lda whl_hi,y
    sta fptr+1
@d:
    jsr draw_frame
    ldx wh_sv
@r:
    rts

whi_bank:              ; A = unidad de CHR -> R2 (jugador 1) o R3 (jugador 2)
    ldx wh_sv
    bne @b3
    sta chr_r2
    rts
@b3:
    sta chr_r3
    rts

; ---------------------------------------------------------------- jugador (el 1 maneja)
agua_player:
    lda wh_dead
    bne @r
    lda wh_inv
    beq @i
    dec wh_inv
@i:
    lda pad1
    and #BTN_LEFT
    beq @nl
    lda wh_x
    cmp #26
    bcc @nl
    sbc #2
    sta wh_x
@nl:
    lda pad1
    and #BTN_RIGHT
    beq @nr
    lda wh_boss
    beq @fr
    lda wh_x
    cmp #150              ; con el yate adelante no se puede pasar
    bcs @nr
@fr:
    lda wh_x
    cmp #212
    bcs @nr
    adc #2
    sta wh_x
@nr:
    lda pad1
    and #BTN_UP
    beq @nu
    lda wh_y
    cmp #WY_MIN+2
    bcc @nu
    sbc #2
    sta wh_y
@nu:
    lda pad1
    and #BTN_DOWN
    beq @r
    lda wh_y
    cmp #WY_MAX
    bcs @r
    adc #2
    sta wh_y
@r:
    rts

; ---------------------------------------------------------------- disparo
agua_fire:
    lda wh_cd
    beq @c
    dec wh_cd
    rts
@c:
    lda wh_dead
    bne @r
    lda two_p
    beq @p1
    lda pad2
    jmp @g
@p1:
    lda pad1
@g:
    sta tmp5
    and #BTN_A|BTN_B
    beq @r
    ; direccion: en 2P el artillero apunta con su cruz
    lda #4
    sta tmp2              ; dx
    lda #0
    sta tmp3              ; dy
    lda two_p
    beq @sp
    lda tmp5
    and #BTN_UP
    beq @dn
    lda #$FE
    sta tmp3
    lda #3
    sta tmp2
@dn:
    lda tmp5
    and #BTN_DOWN
    beq @lf
    lda #2
    sta tmp3
    lda #3
    sta tmp2
@lf:
    lda tmp5
    and #BTN_LEFT
    beq @sp
    lda tmp2
    eor #$FF
    clc
    adc #1
    sta tmp2
@sp:
    ldx #wHB_N-1
@f:
    lda wpb_t,x
    beq @ok
    dex
    bpl @f
@r:
    rts
@ok:
    lda #1
    sta wpb_t,x
    lda tmp2
    sta wpb_dx,x
    lda tmp3
    sta wpb_dy,x
    lda wh_y
    sec
    sbc #17
    sta wpb_y,x
    lda tmp2
    bmi @bk
    lda wh_x
    clc
    adc #18
    jmp @bx
@bk:
    lda wh_x
    sec
    sbc #22
@bx:
    sta wpb_x,x
    lda #6
    sta wh_cd
    jmp sfx_shoot

agua_pbullets:
    ldx #wHB_N-1
@l:
    lda wpb_t,x
    beq @n
    lda wpb_x,x
    clc
    adc wpb_dx,x
    sta wpb_x,x
    cmp #250
    bcs @k
    cmp #4
    bcc @k
    lda wpb_y,x
    clc
    adc wpb_dy,x
    sta wpb_y,x
    cmp #36
    bcc @k
    cmp #232
    bcs @k
    jsr wpb_hits
    jmp @n
@k:
    lda #0
    sta wpb_t,x
@n:
    dex
    bpl @l
    rts

; bala X contra enemigos y jefe
wpb_hits:
    stx tmp4
    ldy #wHE_N-1
@e:
    lda we_t,y
    beq @ne
    cmp #3
    bcs @ne               ; tiburones / aletas: no
    ; |bx - ex| < 12, by en [ey-30, ey+2]
    lda wpb_x,x
    sec
    sbc we_x,y
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #13
    bcs @ne
    lda we_y,y
    sec
    sbc wpb_y,x
    cmp #30
    bcs @ne
    ; impacto
    lda #0
    sta wpb_t,x
    lda #4
    sta we_fl,y
    lda we_hp,y
    sec
    sbc #1
    sta we_hp,y
    bne @hit
    tya
    tax
    jsr wenemy_kill
    ldx tmp4
    rts
@hit:
    jmp sfx_hit
@ne:
    dey
    bpl @e
    ; jefe
    lda wh_boss
    cmp #1
    bne @r
    lda wpb_x,x
    sec
    sbc wbs_x
    bcs @bp
    eor #$FF
    adc #1
@bp:
    cmp #32
    bcs @r
    lda wbs_y
    sec
    sbc wpb_y,x
    cmp #88
    bcs @r
    lda #0
    sta wpb_t,x
    lda #4
    sta wbs_fl
    jsr sfx_hit
    dec wbs_hp
    bne @r
    ; jefe derrotado
    lda #2
    sta wh_boss
    lda #120
    sta wbs_t
    lda #1
    ldy #2
    jsr add_score
@r:
    rts

wenemy_kill:            ; X = enemigo
    lda #0
    sta we_t,x
    lda we_x,x
    sta tmp0
    lda we_y,x
    sec
    sbc #10
    sta tmp1
    jsr wfx_add
    jsr sfx_boom
    lda #1
    ldy #3
    jmp add_score

wfx_add:                ; tmp0 = x, tmp1 = y
    ldy #wHX_N-1
@l:
    lda wx_t,y
    beq @ok
    dey
    bpl @l
    rts
@ok:
    lda #20
    sta wx_t,y
    lda tmp0
    sta wx_x,y
    lda tmp1
    sta wx_y,y
    rts

agua_fx:
    ldx #wHX_N-1
@l:
    lda wx_t,x
    beq @n
    dec wx_t,x
@n:
    dex
    bpl @l
    rts

; ---------------------------------------------------------------- oleadas
; guion: [tipo, y, espera (cuadros/4)]  1 = policia que dispara, 2 = policia embestida, 3 = pareja, 4 = tiburon,
;        $FF = jefe
agua_waves:
    lda wh_boss
    beq @a
    rts
@a:
    dec wh_wt
    beq @b
    rts
@b:
    lda wh_wi
    asl
    clc
    adc wh_wi
    tay
    lda agua_script,y
    cmp #$FF
    beq @boss
    sta tmp2
    lda agua_script+1,y
    sta tmp3
    lda agua_script+2,y
    asl
    asl
    sta wh_wt
    inc wh_wi
    lda tmp2
    cmp #3
    bne @one
    lda tmp3
    sec
    sbc #22
    ldx #1
    jsr spawn_wcop
    lda tmp3
    clc
    adc #22
    ldx #1
    jmp spawn_wcop
@one:
    cmp #4
    beq @sh
    tax
    lda tmp3
    jmp spawn_wcop
@sh:
    lda tmp3
    jmp spawn_shark
@boss:
    ; jefe: el yate se dibuja en el fondo de la pantalla que viene y aparece con el scroll
    ldx #wHE_N-1
    lda #0
@cl:
    sta we_t,x
    dex
    bpl @cl
    sta wbs_n
    sta wbs_ph
    lda #AGUA_BOSS_UNIT   ; los tiradores de la cubierta
    sta chr_r3
    lda #4
    sta wh_boss
    lda #196
    sta wbs_x
    lda #196
    sta wbs_y
    lda #wBOSS_HP
    sta wbs_hp
    lda #60
    sta wbs_t
    lda #2
    jmp mus_play

spawn_wcop:            ; A = y, X = tipo (1 dispara, 2 embiste)
    stx tmp5
    pha
    jsr wfree_enemy
    pla
    bcc @r
    sta we_y,x
    lda tmp5
    sta we_t,x
    lda #248
    sta we_x,x
    lda #$E8              ; -0.75 px
    ldy tmp5
    cpy #2
    bne @v
    lda #$A4              ; embestida: -2.9 px
@v:
    sta we_vx,x
    lda #4
    sta we_hp,x
    lda wh_rnd
    clc
    adc #73
    sta wh_rnd
    and #63
    adc #20
    sta we_cd,x
@r:
    rts

SH_FIN = 34            ; cuadros que la aleta nada antes del salto
spawn_shark:           ; A = y del agua
    pha
    jsr wfree_enemy
    pla
    bcc @r
    sta we_y,x
    sta we_cd,x           ; se guarda el nivel del agua
    lda #4
    sta we_t,x
    lda #232
    sta we_x,x
    lda #$D8              ; -1.25 px
    sta we_vx,x
    lda #1
    sta we_hp,x
@r:
    rts

; ---------------------------------------------------------------- enemigos
agua_enemies:
    ldx #wHE_N-1
@l:
    lda we_t,x
    bne @a
    jmp @n
@a:
    stx tmp4
    lda we_fl,x
    beq @f
    dec we_fl,x
@f:
    lda we_tm,x
    cmp #250
    bcs @f2
    inc we_tm,x
@f2:
    lda we_t,x
    cmp #4
    bne @cop
    jmp @shark
@cop:
    cmp #2
    beq @ram
    ; policia que dispara: entra, se queda cerca y despues se va
    lda we_tm,x
    cmp #250
    bcc @h1
    lda #$C0
    sta we_vx,x
    jmp @h2
@h1:
    lda we_x,x
    cmp #196
    bcs @h2
    lda #0
    sta we_vx,x
@h2:
@ram:
    ; se mece en el agua
    lda we_tm,x
    lsr
    lsr
    lsr
    and #15
    tay
    lda wsine16,y
    cmp #$80
    ror
    sta we_vy,x
    lda we_vx,x
    jsr we_addx
    lda we_vy,x
    jsr we_addy
    lda we_x,x
    cmp #4
    bcs @in
    jmp @kill
@in:
    cmp #252
    bcc @in2
    jmp @kill
@in2:
    lda we_t,x
    cmp #1
    bne @col
    dec we_cd,x
    bne @col
    lda #44
    sta we_cd,x
    lda we_x,x
    cmp #236
    bcs @col
    sec
    sbc #14
    sta tmp0
    lda we_y,x
    sec
    sbc #18
    sta tmp1
    lda #54
    jsr wshoot_aimed
    jmp @col
@shark:
    lda we_tm,x
    cmp #SH_FIN
    bcc @fin
    bne @air
    ; salta!
    lda #$90              ; -3.5 px
    sta we_vy,x
    lda #$C4              ; -1.9 px
    sta we_vx,x
    lda #0
    sta we_fy,x
    jsr sfx_shoot
@air:
    lda we_vy,x
    clc
    adc #3                ; gravedad
    bvs @gv
    sta we_vy,x
@gv:
    lda we_vx,x
    jsr we_addx
    lda we_vy,x
    jsr we_addy
    ; cae al agua
    lda we_vy,x
    bmi @sc
    lda we_y,x
    cmp we_cd,x
    bcc @sc
    jmp @kill
@sc:
    lda we_x,x
    cmp #6
    bcs @col
    jmp @kill
@fin:
    lda we_vx,x
    jsr we_addx
    jmp @n
@col:
    ; choque con la moto del jugador
    lda wh_dead
    bne @n
    lda we_x,x
    sec
    sbc wh_x
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #26
    bcs @n
    lda we_y,x
    sec
    sbc wh_y
    bcs @p2
    eor #$FF
    adc #1
@p2:
    cmp #18
    bcs @n
    stx tmp4
    lda we_t,x
    cmp #4
    beq @bite
    jsr wenemy_kill
@bite:
    lda #5
    jsr agua_hurt
    ldx tmp4
    jmp @n
@kill:
    lda #0
    sta we_t,x
@n:
    dex
    bmi @r
    jmp @l
@r:
    rts

wfree_enemy:           ; -> X libre (C=1) o C=0
    ldx #wHE_N-1
@l:
    lda we_t,x
    beq @ok
    dex
    bpl @l
    clc
    rts
@ok:
    lda #0
    sta we_fx,x
    sta we_fy,x
    sta we_tm,x
    sta we_fl,x
    sta we_vy,x
    sec
    rts

; ---------------------------------------------------------------- jefe: la punta del yate
agua_boss:
    lda wh_boss
    bne @on
    rts
@on:
    cmp #4
    bne @o2
    jmp yacht_arrive
@o2:
    cmp #2
    bne @alive
    ; explotando
    lda wh_t
    and #7
    bne @e1
    lda wh_rnd
    clc
    adc #37
    sta wh_rnd
    and #63
    clc
    adc #184
    sta tmp0
    lda wh_rnd
    lsr
    and #63
    sta tmp1
    lda wbs_y
    sec
    sbc tmp1
    sec
    sbc #4
    sta tmp1
    jsr wfx_add
    jsr sfx_boom
    lda #3
    sta shake
@e1:
    dec wbs_t
    bne @r
    lda #3
    sta wh_boss
    lda #0
    sta boss_on
    lda #90
    sta wh_end
@r:
    rts
@alive:
    lda wbs_fl
    beq @f
    dec wbs_fl
@f:
@at:
    dec wbs_t
    bne @r2
    lda wbs_ph
    and #3
    tax
    lda wbs_phase_t,x
    sta wbs_t
    lda wbs_ph
    and #3
    cmp #2
    beq @bow
    ; los tiradores de la cubierta disparan hacia abajo, al jugador
    lda #8
    sta w_gfl          ; fogonazo
    lda #GM1_X-8
    sta tmp0
    lda #GM_Y-12
    sta tmp1
    lda #56
    jsr wshoot_aimed
    lda #GM2_X-8
    sta tmp0
    lda #50
    jsr wshoot_aimed
    lda wbs_ph
    and #1
    beq @nx
    lda #GM1_X-8
    sta tmp0
    lda #GM_Y-4
    sta tmp1
    lda #46
    jsr wshoot_aimed
    jmp @nx
@bow:
    ; abanico desde la proa
    lda #180
    sta tmp0
    lda #158
    sta tmp1
    jsr wshoot_5way
@nx:
    inc wbs_ph
@r2:
    ; choque con el casco
    lda wh_dead
    bne @r3
    lda wbs_x
    sec
    sbc wh_x
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #40
    bcs @r3
    lda wbs_y
    sec
    sbc wh_y
    bcs @p2
    eor #$FF
    adc #1
@p2:
    cmp #40
    bcs @r3
    lda #5
    jsr agua_hurt
@r3:
    rts
wbs_phase_t: .byte 42,38,50,32
GM1_X = 196            ; tiradores en la cubierta (pies)
GM2_X = 212
GM_Y  = 151

; el yate llega: se escriben sus filas en la pantalla que todavia no se ve y despues aparece con el scroll
yacht_arrive:
    lda wbs_n
    cmp #YNROWS+2
    bcc @__n1517_0
    jmp @wait
@__n1517_0:
    lda str_pending
    beq @__n1521_1
    jmp @r
@__n1521_1:
    lda wbs_n
    bne @go
    ; recien se arranca si falta para que se vea la otra pantalla
    lda cam_lo
    cmp #140
    bcc @__n1529_2
    jmp @r
@__n1529_2:
    lda cam_hi
    and #1
    eor #1
    asl
    asl
    ora #$20
    sta wbs_vy            ; $20 o $24: la pantalla de la derecha
@go:
    lda wbs_n
    cmp #YNROWS
    bcs @at
    ; fila YR0+n: direccion = base + (YR0+n)*32
    clc
    adc #YR0
    sta tmp0
    lda #0
    sta tmp1
    ldx #5
@s:
    asl tmp0
    rol tmp1
    dex
    bne @s
    lda tmp0
    sta str_lo
    lda tmp1
    ora wbs_vy
    sta str_hi
    ; datos: yacht_rows + n*32
    lda wbs_n
    asl
    asl
    asl
    asl
    asl
    tay                   ; n*32 (n < 8) o se corre a la segunda pagina
    lda wbs_n
    lsr
    lsr
    lsr
    clc
    adc #>yacht_rows
    sta ptr+1
    lda #<yacht_rows
    sta ptr
    tya
    clc
    adc ptr
    sta ptr
    bcc @c
    inc ptr+1
@c:
    ldy #31
@cp:
    lda (ptr),y
    sta str_buf,y
    dey
    bpl @cp
    jmp @q
@at:
    ; atributos: dos mitades de 32
    sec
    sbc #YNROWS
    tax
    lda wbs_vy
    ora #3
    sta str_hi
    lda #$C0
    cpx #0
    beq @a0
    lda #$E0
@a0:
    sta str_lo
    txa
    asl
    asl
    asl
    asl
    asl
    tax
    ldy #0
@ca:
    lda yacht_attr,x
    sta str_buf,y
    inx
    iny
    cpy #32
    bne @ca
@q:
    lda #1
    sta str_pending
    inc wbs_n
@r:
    rts
@wait:
    ; listo: cuando la pantalla del yate queda alineada se frena el mar y empieza la pelea
    lda cam_lo
    bne @r
    lda cam_hi
    and #1
    asl
    asl
    ora #$20
    cmp wbs_vy
    bne @r
    lda #1
    sta w_stop
    sta wh_boss
    sta boss_on
    rts

; ---------------------------------------------------------------- guion (espera en cuadros/4)
agua_script:
    .byte 1, 150, 28
    .byte 1, 196, 28
    .byte 4, 214, 35
    .byte 3, 168, 42
    .byte 2, 140, 28
    .byte 1, 206, 28
    .byte 4, 176, 28
    .byte 4, 212, 38
    .byte 2, 190, 21
    .byte 1, 140, 31
    .byte 3, 176, 42
    .byte 4, 150, 24
    .byte 2, 210, 21
    .byte 2, 150, 28
    .byte 1, 188, 28
    .byte 4, 204, 24
    .byte 4, 160, 35
    .byte 3, 160, 42
    .byte 2, 200, 21
    .byte 1, 140, 28
    .byte 4, 186, 28
    .byte 1, 210, 28
    .byte 2, 160, 21
    .byte 4, 214, 35
    .byte 3, 180, 49
    .byte $FF, 0, 0

agua_spal:             ; sprites 0-3
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$27,$12, $0F,$0F,$27,$30

wsine16: .byte 0,8,15,19,20,19,15,8,0,$F8,$F1,$ED,$EC,$ED,$F1,$F8

; suma velocidad (A, con signo, en 1/32 px) a la posicion 8.8
we_addx:
    jsr wvel16
    clc
    lda we_fx,x
    adc tmp8
    sta we_fx,x
    lda we_x,x
    adc tmp9
    sta we_x,x
    rts
we_addy:
    jsr wvel16
    clc
    lda we_fy,x
    adc tmp8
    sta we_fy,x
    lda we_y,x
    adc tmp9
    sta we_y,x
    rts
wq_addx:
    jsr wvel16
    clc
    lda wq_fx,x
    adc tmp8
    sta wq_fx,x
    lda wq_x,x
    adc tmp9
    sta wq_x,x
    rts
wq_addy:
    jsr wvel16
    clc
    lda wq_fy,x
    adc tmp8
    sta wq_fy,x
    lda wq_y,x
    adc tmp9
    sta wq_y,x
    rts
wvel16:                 ; A (signo, 1/32) -> tmp8/tmp9 = A*8 (16 bits)
    sta tmp8
    lda #0
    sta tmp9
    lda tmp8
    bpl @p
    dec tmp9
@p:
    asl tmp8
    rol tmp9
    asl tmp8
    rol tmp9
    asl tmp8
    rol tmp9
    rts

; ---------------------------------------------------------------- balas enemigas
wfree_q:                ; -> Y libre (C=1)
    ldy #wHQ_N-1
@l:
    lda wq_t,y
    beq @ok
    dey
    bpl @l
    clc
    rts
@ok:
    sec
    rts

; tmp0/tmp1 = origen, A = rapidez (vel. en 1/32: 40 = 1.25 px) hacia el jugador
wshoot_aimed:
    sta tmp10
    jsr wfree_q
    bcs @ok
    rts
@ok:
    jsr wq_setpos
    ; dx = jugador - origen
    lda wh_x
    sec
    sbc tmp0
    sta tmp2
    lda wh_y
    sec
    sbc #16
    sec
    sbc tmp1
    sta tmp3
    jsr waim_dir           ; -> tmp2 (vx), tmp3 (vy)
    lda tmp2
    sta wq_vx,y
    lda tmp3
    sta wq_vy,y
    rts

wq_setpos:
    lda #1
    sta wq_t,y
    lda tmp0
    sta wq_x,y
    lda tmp1
    sta wq_y,y
    lda #$80
    sta wq_fx,y
    sta wq_fy,y
    rts

; tmp2 = dx, tmp3 = dy (con signo, -128..127) -> velocidad (1.25 px) en 6 direcciones por cuadrante
waim_dir:
    lda #0
    sta tmp5              ; signos
    lda tmp2
    bpl @ax
    eor #$FF
    clc
    adc #1
    sta tmp2
    lda #1
    sta tmp5
@ax:
    lda tmp3
    bpl @ay
    eor #$FF
    clc
    adc #1
    sta tmp3
    lda tmp5
    ora #2
    sta tmp5
@ay:
    lsr tmp2
    lsr tmp2
    lsr tmp3
    lsr tmp3              ; 0..63
    ; indice de pendiente
    ldx #0
    lda tmp3
    asl
    asl
    cmp tmp2              ; ay*4 <= ax
    bcc @k
    beq @k
    inx
    lda tmp3
    asl
    cmp tmp2              ; ay*2 <= ax
    bcc @k
    beq @k
    inx
    lda tmp3
    cmp tmp2              ; ay <= ax
    bcc @k
    beq @k
    inx
    lda tmp2
    asl
    cmp tmp3              ; ay <= ax*2
    bcs @k
    inx
    lda tmp2
    asl
    asl
    cmp tmp3              ; ay <= ax*4
    bcs @k
    inx
@k:
    lda waim_vx,x
    sta tmp2
    lda waim_vy,x
    sta tmp3
    lda tmp5
    and #1
    beq @sx
    lda tmp2
    eor #$FF
    clc
    adc #1
    sta tmp2
@sx:
    lda tmp5
    and #2
    beq @sy
    lda tmp3
    eor #$FF
    clc
    adc #1
    sta tmp3
@sy:
    ldx tmp4
    rts
waim_vx: .byte 40,37,32,22,14,0
waim_vy: .byte 0,15,24,33,38,40

wshoot_3way:            ; tmp0/tmp1 origen: tres balas hacia la izquierda
    ldx #2
@l:
    stx tmp11
    jsr wfree_q
    bcc @r
    jsr wq_setpos
    ldx tmp11
    lda ww3_vx,x
    sta wq_vx,y
    lda ww3_vy,x
    sta wq_vy,y
    dex
    bpl @l
@r:
    ldx tmp4
    rts
ww3_vx: .byte $D8,$DA,$D8
ww3_vy: .byte $F0,0,$10

wshoot_5way:            ; tmp0/tmp1 origen
    ldx #4
@l:
    stx tmp11
    jsr wfree_q
    bcc @r
    jsr wq_setpos
    ldx tmp11
    lda ww5_vx,x
    sta wq_vx,y
    lda ww5_vy,x
    sta wq_vy,y
    dex
    bpl @l
@r:
    rts
ww5_vx: .byte $DC,$D8,$D6,$D8,$DC
ww5_vy: .byte $E4,$F2,0,$0E,$1C

agua_qbullets:
    ldx #wHQ_N-1
@l:
    lda wq_t,x
    beq @n
    lda wq_vx,x
    jsr wq_addx
    lda wq_vy,x
    jsr wq_addy
    lda wq_x,x
    cmp #4
    bcc @k
    cmp #252
    bcs @k
    lda wq_y,x
    cmp #36
    bcc @k
    cmp #236
    bcs @k
    ; contra el jugador (caja chica: el cuerpo del helicoptero)
    lda wh_dead
    bne @n
    lda wq_x,x
    sec
    sbc wh_x
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #14
    bcs @n
    lda wh_y
    sec
    sbc #14
    sec
    sbc wq_y,x
    bcs @p2
    eor #$FF
    adc #1
@p2:
    cmp #11
    bcs @n
    lda #0
    sta wq_t,x
    stx tmp4
    lda #3
    jsr agua_hurt
    ldx tmp4
    jmp @n
@k:
    lda #0
    sta wq_t,x
@n:
    dex
    bpl @l
    rts

; ---------------------------------------------------------------- danio al helicoptero (A = danio)
agua_hurt:
    ldy wh_inv
    bne @r
    ldy wh_dead
    bne @r
    sta tmp2
    jsr sfx_hit
    lda #6
    sta shake
    lda #70
    sta wh_inv
    lda p_base+13
    sec
    sbc tmp2
    beq @dead
    bcc @dead
    sta p_base+13
    sta p_base+32+13
@r:
    rts
@dead:
    ; se pierde una vida
    lda wh_x
    sta tmp0
    lda wh_y
    sec
    sbc #8
    sta tmp1
    jsr wfx_add
    jsr sfx_boom
    lda #16
    sta p_base+13
    sta p_base+32+13
    lda #150
    sta wh_inv
    dec p_base+14
    lda two_p
    beq @l1
    dec p_base+32+14
@l1:
    lda p_base+14
    bne @r
    lda #0
    sta p_base+13
    sta p_base+32+13
    lda #110
    sta wh_dead
    rts

; ---------------------------------------------------------------- dibujo
agua_draw:
    jsr clear_oam
    jsr reset_draw
    lda #0
    sta sx_hi
    ; con el jefe en pantalla se alterna quien va primero (mas de 8 sprites por linea: parpadean los dos)
    lda frame
    and #1
    beq @pfirst
    jsr agua_draw_boss
    jsr whd_player
    jmp @after
@pfirst:
    jsr whd_player
    jsr agua_draw_boss
@after:
    jmp whd_rest

whd_player:
    lda wh_dead
    bne @nop
    lda wh_inv
    and #2
    bne @nop
    lda wh_x
    sta sx_lo
    lda wh_y
    sta sy
    lda wh_t
    lsr
    and #1
    clc
    adc w_pf
    jmp whdraw
@nop:
    rts

whd_rest:
    ; enemigos (orden alternado: reparte el parpadeo)
    lda frame
    and #1
    beq @fw
    ldx #0
@el:
    jsr whd_enemy
    inx
    cpx #wHE_N
    bne @el
    jmp @fx
@fw:
    ldx #wHE_N-1
@er:
    jsr whd_enemy
    dex
    bpl @er
@fx:
    ; explosiones
    ldx #wHX_N-1
@xl:
    lda wx_t,x
    beq @xn
    stx wh_sv
    lda wx_x,x
    sta sx_lo
    lda wx_y,x
    sta sy
    lda wx_t,x
    and #4
    lsr
    lsr
    clc
    adc #MF_EX0
    jsr whmisc
    ldx wh_sv
@xn:
    dex
    bpl @xl
    ; balas del jugador
    ldx #wHB_N-1
@pb:
    lda wpb_t,x
    beq @pn
    stx wh_sv
    lda wpb_x,x
    sta sx_lo
    lda wpb_y,x
    clc
    adc #3
    sta sy
    lda #0
    ldy wpb_dx,x
    bpl @rf
    lda #$40
@rf:
    sta sflip
    lda #MF_ROCKET
    jsr whmisc
    ldx wh_sv
@pn:
    dex
    bpl @pb
    ; balas enemigas
    ldx #wHQ_N-1
@qb:
    lda wq_t,x
    beq @qn
    stx wh_sv
    lda wq_x,x
    sta sx_lo
    lda wq_y,x
    clc
    adc #4
    sta sy
    lda #MF_EB
    jsr whmisc
    ldx wh_sv
@qn:
    dex
    bpl @qb
    rts

whd_enemy:              ; X = enemigo (se preserva)
    lda we_t,x
    beq @r
    lda we_fl,x
    and #2
    bne @r
    stx wh_sv
    lda we_x,x
    sta sx_lo
    lda we_y,x
    sta sy
    lda we_t,x
    cmp #3
    bcs @sh
    lda wh_t
    lsr
    lsr
    and #1
    clc
    adc #AF_CJ0
    jmp @d
@sh:
    ; tiburon: aleta (antes de saltar) o salto segun la velocidad vertical
    lda we_tm,x
    cmp #SH_FIN
    bcs @j
    lda #AF_FN
    jmp @d
@j:
    lda we_vy,x
    bpl @dn
    cmp #$D8
    bcs @mid
    lda #AF_SK0
    jmp @d
@mid:
    lda #AF_SK1
    jmp @d
@dn:
    cmp #$28
    bcc @mid
    lda #AF_SK2
@d:
    jsr whdraw
    ldx wh_sv
@r:
    rts

agua_draw_boss:
    lda wh_boss
    bne @__n2190_3
    jmp @r
@__n2190_3:
    cmp #4
    beq @arr
    cmp #1
    beq @__n2196_4
    jmp @r
@__n2196_4:
    lda #0
    sta tmp8              ; corrimiento: 0 (el mar esta frenado)
    lda #1
    sta tmp9
    jmp @gm
@arr:
    ; llegando: x en pantalla = x + 256 - cam_lo
    lda wbs_n
    cmp #YNROWS+2
    bcs @__n2208_5
    jmp @r
@__n2208_5:
    lda cam_lo
    eor #$FF
    clc
    adc #1
    sta tmp8
    lda #0
    adc #0
    sta tmp9              ; tmp9:tmp8 = 256 - cam_lo
@gm:
    lda tmp9
    beq @gm0
    lda tmp8
    beq @__n2223_6
    jmp @r
@__n2223_6:
@gm0:
    ldx #1
@g:
    stx wh_sv
    lda gm_x,x
    clc
    adc tmp8
    sta sx_lo
    lda #0
    adc #0
    sta sx_hi
    bne @ng
    lda #GM_Y
    sta sy
    ldy #AF_GM0
    lda w_gfl
    beq @nf
    ldy #AF_GM1
@nf:
    tya
    jsr whdraw
@ng:
    ldx wh_sv
    dex
    bpl @g
    lda #0
    sta sx_hi
    lda w_gfl
    beq @bar
    dec w_gfl
@bar:
    lda wh_boss
    cmp #1
    bne @r
    ; barra de vida del jefe (vertical): 28 unidades
    lda wbs_hp
    lsr
    lsr
    sta tmp10
    lda #14
    sta sx_lo
    lda #104
    sta sy
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
    tax
    lda whbx_lo,x
    sta fptr
    lda whbx_hi,x
    sta fptr+1
    jsr draw_frame
    lda sy
    sec
    sbc #8
    sta sy
    ldx tmp11
    dex
    bne @l
@r:
    rts
gm_x: .byte GM1_X, GM2_X

whdraw:                 ; A = cuadro del nivel helicoptero
    tax
    lda af_lo,x
    sta fptr
    lda af_hi,x
    sta fptr+1
    jmp draw_frame
whmisc:                 ; A = cuadro misc (copia en este banco)
    tax
    lda whm_lo,x
    sta fptr
    lda whm_hi,x
    sta fptr+1
    jmp draw_frame
