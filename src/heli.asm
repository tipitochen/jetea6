; =====================================================================
;  NIVEL 2: EN LOS CIELOS  (banco 8 en $8000 durante todo el nivel)
;  Helicoptero: 1 jugador maneja y dispara; 2 jugadores: el 1 maneja, el 2 dispara (y apunta).
;  Enemigos: policias con propulsor, helicopteros policiales. Jefe: helicoptero militar.
; =====================================================================
    .include "heli_data.asm"

HE_N = 5               ; pocos enemigos a la vez: menos parpadeo
HB_N = 8
HQ_N = 7
HX_N = 4
h_x     = $0600
h_y     = $0601
h_inv   = $0602
h_cd    = $0603
h_dead  = $0604
h_pause = $0605
h_t     = $0606
h_wt    = $0607
h_wi    = $0608
h_boss  = $0609
h_end   = $060A
h_rnd   = $060B
h_sv    = $060C
bs_x    = $0610
bs_y    = $0611
bs_vy   = $0612
bs_hp   = $0613
bs_t    = $0614
bs_fl   = $0615
bs_ph   = $0616
bs_n    = $0617
hi_jx   = $0618
hi_lx   = $0619
hi_ph   = $061A
hi_tm   = $061B
h_intro = $061C
hi_f    = $061D
hi_jy   = $061E
hi_ly   = $061F
sc_dy   = $0664         ; escena de los drones: y / x de 3 drones
sc_dx   = $0667
e_t     = $0620
e_x     = $0626
e_fx    = $062C
e_y     = $0632
e_fy    = $0638
e_vx    = $063E
e_vy    = $0644
e_hp    = $064A
e_tm    = $0650
e_fl    = $0656
e_cd    = $065C
pb_t    = $0670
pb_x    = $0678
pb_y    = $0680
pb_dx   = $0688
pb_dy   = $0690
q_t     = $06A0
q_x     = $06AA
q_fx    = $06B4
q_y     = $06BE
q_fy    = $06C8
q_vx    = $06D2
q_vy    = $06DC
x_t     = $06E8
x_x     = $06EC
x_y     = $06F0
BOSS_HP = 160

; ---------------------------------------------------------------- inicio (PPU apagada, banco 8 mapeado)
heli_init:
    lda #$88
    sta ctrl_base
    ; variables
    ldx #0
    lda #0
@z:
    sta $0600,x
    inx
    bne @z
    ; escena: los personajes caminan por la azotea y se suben al helicoptero grande
    lda #1
    sta h_intro
    lda #214
    sta hi_jy
    sta hi_ly
    lda #40
    sta hi_jx
    lda #10
    sta hi_lx
    lda two_p
    bne @dos
    lda #$FF
    sta hi_lx             ; en 1 jugador solo uno
@dos:
    lda #60
    sta h_wt
    lda #0
    sta cam_lo
    sta cam_hi
    sta boss_on
    sta shake
    sta p_base+16
    sta p_base+32+16
    ; si alguien entra sin vida (despues de continuar), se le da
    lda p_base+13
    bne @h1
    lda #16
    sta p_base+13
@h1:
    jsr scene_setup
    lda #1
    jsr mus_play
    jsr hud_prepare
    jsr clear_oam
    lda #ST_HELI
    sta state
    lda #1
    sta game_irq
    jmp ppu_enable

; paleta base del nivel 1 (HUD) + paletas propias
heli_palette:
    ldx #0
    lda level_tbl+2,x
    sta ptr
    lda level_tbl+3,x
    sta ptr+1
    jsr load_palette
    ldx #23
@pp:
    lda heli_pal,x
    sta pal_buf+8,x
    dex
    bpl @pp
    jmp set_shirt

; ---- la azotea con el helicoptero grande (pantalla fija)
scene_setup:
    lda #SCENE_A
    sta chr_r0
    lda #SCENE_R1
    sta chr_r1
    lda boss_units+1
    sta chr_r45
    jsr heli_palette
    ldx #7
@sp:
    lda scene_pal,x
    sta pal_buf+4,x       ; BG paletas 1 y 2
    dex
    bpl @sp
    ldx #3
@s3:
    lda scene_pal3,x
    sta pal_buf+12,x
    dex
    bpl @s3
    lda pal_buf+23        ; el helicoptero del color de la ropa (rosa en 2 jugadores)
    sta pal_buf+11
    lda #0
    jsr clear_nt
    jsr hud_static
    ; filas 4..7: cielo
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$80
    sta PPUADDR
    lda scene_map
    ldx #128
@f:
    sta PPUDATA
    dex
    bne @f
    ; filas 8..29
    lda #<scene_map
    sta ptr
    lda #>scene_map
    sta ptr+1
    lda #$21
    jsr put_704
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$C0
    sta PPUADDR
    ldx #0
@a:
    lda scene_attr,x
    sta PPUDATA
    inx
    cpx #64
    bne @a
    rts

; ---- el cielo del nivel (se arma con la PPU apagada)
sky_setup:
    ldx #0
    lda level_tbl+20,x    ; fuente + horizonte lejano del tema A
    sta chr_r0
    lda #HELI_BG_UNIT
    sta chr_r1
    lda #HELI_SPR_UNIT
    sta chr_r2
    lda #HELI_BOSS_UNIT
    sta chr_r3
    lda boss_units+1      ; misc (balas, explosiones) + barra del jefe
    sta chr_r45
    jsr heli_palette
    ldx #0
    lda level_tbl+12,x
    sta far_ptr
    lda level_tbl+13,x
    sta far_ptr+1
    lda #0
    jsr clear_nt
    jsr hud_static
    ; cielo celeste con nubes (filas 4..29) en las dos pantallas
    lda #$20
    jsr heli_put_map
    lda #$24
    jsr heli_put_map
    lda #$23
    jsr heli_put_attr
    lda #$27
    jmp heli_put_attr

heli_put_map:          ; A = $20 o $24 -> filas 4..29 desde heli_map (832 bytes)
    bit PPUSTATUS
    sta PPUADDR
    lda #$80
    sta PPUADDR
    lda #<heli_map
    sta ptr
    lda #>heli_map
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
put_704:               ; A = pagina alta del PPU ($21/$25), ptr = datos
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

heli_put_attr:         ; A = $23 o $27
    bit PPUSTATUS
    sta PPUADDR
    lda #$C0
    sta PPUADDR
    ldx #0
@l:
    lda heli_attr,x
    sta PPUDATA
    inx
    cpx #64
    bne @l
    rts

; ---------------------------------------------------------------- cuadro
st_heli:
    lda h_intro
    bne @np
    lda padn1
    ora padn2
    and #BTN_START
    beq @np
    lda h_pause
    eor #1
    sta h_pause
    jsr sfx_power
@np:
    lda h_pause
    beq @run
    rts
@run:
    inc h_t
    lda h_intro
    beq @play
    jsr hud_prepare
    jmp heli_intro
@play:
    ; el cielo avanza
    inc cam_lo
    bne @c
    inc cam_hi
@c:
    jsr rand
    jsr heli_player
    jsr heli_fire
    jsr heli_pbullets
    jsr heli_waves
    jsr heli_enemies
    jsr heli_boss
    jsr heli_qbullets
    jsr heli_fx
    jsr hud_prepare
    jsr heli_draw
    ; muerte del helicoptero: explosiones y despues continuar / fin
    lda h_dead
    beq @nd
    dec h_dead
    bne @nd
    lda #0
    sta p_base+31
    sta p_base+32+31
    jmp heli_out_dead
@nd:
    lda h_end
    beq @r
    dec h_end
    bne @r
    jmp heli_out_clear
@r:
    rts

; ---------------------------------------------------------------- escena de subida al helicoptero
heli_intro:
    lda hi_ph
    cmp #3
    bcs @sk               ; despegando en el cielo: no se saltea
    lda padn1
    ora padn2
    and #BTN_A|BTN_B
    beq @sk
    jmp hi_skip           ; A/B: saltear
@sk:
    lda hi_ph
    bne @p1
    ; caminando hacia la puerta
    ldx #0
    jsr hi_walk
    ldx #1
    jsr hi_walk
    lda #8
    jsr hi_rotor
    lda hi_jx
    and hi_lx
    cmp #$FF
    beq @__n356_0
    jmp @dr
@__n356_0:
    lda #1
    sta hi_ph
    lda #40
    sta hi_tm
    jmp @dr
@p1:
    cmp #1
    bne @p2
    ; arranca el motor
    lda #4
    jsr hi_rotor
    dec hi_tm
    beq @__n373_0
    jmp @dr
@__n373_0:
    lda #2
    sta hi_ph
    lda #96
    sta hi_tm
    jsr sfx_power
    jmp @dr
@p2:
    cmp #2
    bne @p3
    ; rotor a fondo, tiembla todo y la pantalla se va a blanco
    lda #2
    jsr hi_rotor
    lda #2
    sta shake
    lda hi_tm
    cmp #32
    bcs @nf
    and #7
    bne @nf
    jsr hi_fade
@nf:
    dec hi_tm
    bne @dr
    ; al cielo
    jsr ppu_off
    jsr sky_setup
    lda #0
    sta shake
    lda #56
    sta h_x
    lda #236
    sta h_y
    ; escena: los policias lanzan los drones
    lda #hc_unit
    sta chr_r45
    ldx #1
@di:
    lda dr_x0,x
    sta sc_dx,x
    lda #190              ; los drones arrancan a la altura de la cabeza de los policias
    sta sc_dy,x
    dex
    bpl @di
    lda #0
    sta hi_tm
    lda #4
    sta hi_ph
    lda #1
    sta game_irq
    jsr clear_oam
    jmp ppu_enable
@p3:
    cmp #4
    bne @p3b
    jmp hi_drones
@p3b:
    ; despegue en el cielo: sube hasta su lugar
    lda h_y
    sec
    sbc #2
    sta h_y
    cmp #141
    bcs @d3
    jmp hi_done
@d3:
    jmp hi_draw_sky
@dr:
    jmp hi_draw

; ---- los policias de la calle levantan los drones al vuelo
dr_x0: .byte 92, 196
dr_cx: .byte 70, 172
hi_drones:
    inc hi_tm
    ldx #1
@l:
    ; cada dron arranca un poco despues del anterior
    txa
    asl
    asl
    asl
    asl
    asl
    clc
    adc #50
    cmp hi_tm
    bcs @n
    lda sc_dy,x
    cmp #112
    bcc @fly
    dec sc_dy,x
    jmp @n
@fly:
    ; ya arriba: se van volando hacia la derecha
    lda sc_dx,x
    cmp #250
    bcs @n
    clc
    adc #2
    sta sc_dx,x
    lda h_t
    and #3
    bne @n
    dec sc_dy,x
@n:
    dex
    bpl @l
    ; termina cuando se fue el ultimo
    lda sc_dx+1
    cmp #250
    bcc @dr
    lda boss_units+1
    sta chr_r45
    lda #3
    sta hi_ph
@dr:
    ; dibujo: policias (señalando cuando largan) y drones
    jsr clear_oam
    jsr reset_draw
    lda #0
    sta sx_hi
    ldx #1
@c:
    stx h_sv
    lda dr_cx,x
    sta sx_lo
    lda #232
    sta sy
    ldy #0
    lda hi_tm
    cmp #44
    bcc @f0
    iny
@f0:
    lda hc_lo,y
    sta fptr
    lda hc_hi,y
    sta fptr+1
    jsr draw_frame
    ldx h_sv
    lda sc_dx,x
    cmp #250
    bcs @nd
    sta sx_lo
    lda sc_dy,x
    sta sy
    lda h_t
    lsr
    and #1
    clc
    adc #HF_JC0
    jsr hdraw
    ldx h_sv
@nd:
    dex
    bpl @c
    rts

hi_rotor:              ; A = cada cuantos cuadros cambia el rotor (potencia de 2)
    sec
    sbc #1
    and h_t
    bne @r
    lda chr_r0
    cmp #SCENE_A
    beq @b
    lda #SCENE_A
    sta chr_r0
    rts
@b:
    lda #SCENE_B
    sta chr_r0
@r:
    rts

hi_fade:               ; aclara toda la paleta un paso (hacia blanco)
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

hi_skip:               ; saltear la escena: directo al cielo
    jsr ppu_off
    jsr sky_setup
    lda #0
    sta shake
    jsr hi_done
    lda #1
    sta game_irq
    jsr clear_oam
    jmp ppu_enable

hi_walk:               ; X = 0 (jugador 1) / 1 (jugador 2)
    lda hi_jx,x
    cmp #$FF
    beq @r
    cmp #146
    bcs @up
    clc
    adc #1
    sta hi_jx,x
    rts
@up:
    ; en la puerta: sube al helicoptero
    lda hi_jy,x
    sec
    sbc #2
    sta hi_jy,x
    cmp #196
    bcs @r
    lda #$FF              ; adentro
    sta hi_jx,x
    jsr sfx_hit
@r:
    rts

hi_done:
    lda #0
    sta h_intro
    lda #56
    sta h_x
    lda #140
    sta h_y
    lda #60
    sta h_inv
    lda #60
    sta h_wt
    lda #HELI_SPR_UNIT
    sta chr_r2
    lda #HELI_BOSS_UNIT
    sta chr_r3
    lda boss_units+1
    sta chr_r45
    rts

hi_draw_sky:
    jsr clear_oam
    jsr reset_draw
    lda #0
    sta sx_hi
    lda h_x
    sta sx_lo
    lda h_y
    sta sy
    lda h_t
    lsr
    and #1
    clc
    adc #HF_PL0
    jmp hdraw

hi_draw:
    jsr clear_oam
    jsr reset_draw
    lda #0
    sta sx_hi
    ; personajes
    lda h_t
    lsr
    lsr
    lsr
    and #3
    clc
    adc #1
    sta hi_f              ; cuadros de caminata 16..19
    ldx #0
    jsr hi_char
    ldx #1
    jsr hi_char
    jmp reset_draw

hi_char:               ; X = jugador
    lda hi_jx,x
    cmp #$FF
    beq @r
    sta sx_lo
    lda hi_jy,x
    sta sy
    lda #0
    sta sflip
    txa
    beq @p1
    lda #$40
@p1:
    sta stile
    stx h_sv
    ; personaje elegido: p_base+30 (0 Jose, 1 Luciana)
    txa
    asl
    asl
    asl
    asl
    asl
    tay
    lda p_base+30,y
    ldy hi_f
    cmp #0
    bne @lu
    lda hj_unit,y
    jsr hi_bank
    lda hj_lo,y
    sta fptr
    lda hj_hi,y
    sta fptr+1
    jmp @d
@lu:
    lda hl_unit,y
    jsr hi_bank
    lda hl_lo,y
    sta fptr
    lda hl_hi,y
    sta fptr+1
@d:
    jsr draw_frame
    ldx h_sv
@r:
    rts

hi_bank:               ; A = unidad de CHR -> R2 (jugador 1) o R3 (jugador 2)
    ldx h_sv
    bne @b3
    sta chr_r2
    rts
@b3:
    sta chr_r3
    rts

; ---------------------------------------------------------------- jugador (el 1 maneja)
heli_player:
    lda h_dead
    bne @r
    lda h_inv
    beq @i
    dec h_inv
@i:
    lda pad1
    and #BTN_LEFT
    beq @nl
    lda h_x
    cmp #26
    bcc @nl
    sbc #2
    sta h_x
@nl:
    lda pad1
    and #BTN_RIGHT
    beq @nr
    lda h_x
    cmp #212
    bcs @nr
    adc #2
    sta h_x
@nr:
    lda pad1
    and #BTN_UP
    beq @nu
    lda h_y
    cmp #66
    bcc @nu
    sbc #2
    sta h_y
@nu:
    lda pad1
    and #BTN_DOWN
    beq @r
    lda h_y
    cmp #218
    bcs @r
    adc #2
    sta h_y
@r:
    rts

; ---------------------------------------------------------------- disparo (1P: el 1; 2P: el 2 dispara y apunta)
heli_fire:
    lda h_cd
    beq @c
    dec h_cd
    rts
@c:
    lda h_dead
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
    ldx #HB_N-1
@f:
    lda pb_t,x
    beq @ok
    dex
    bpl @f
@r:
    rts
@ok:
    lda #1
    sta pb_t,x
    lda tmp2
    sta pb_dx,x
    lda tmp3
    sta pb_dy,x
    lda h_y
    sec
    sbc #9
    sta pb_y,x
    lda tmp2
    bmi @bk
    lda h_x
    clc
    adc #18
    jmp @bx
@bk:
    lda h_x
    sec
    sbc #22
@bx:
    sta pb_x,x
    lda #6
    sta h_cd
    jmp sfx_shoot

heli_pbullets:
    ldx #HB_N-1
@l:
    lda pb_t,x
    beq @n
    lda pb_x,x
    clc
    adc pb_dx,x
    sta pb_x,x
    cmp #250
    bcs @k
    cmp #4
    bcc @k
    lda pb_y,x
    clc
    adc pb_dy,x
    sta pb_y,x
    cmp #36
    bcc @k
    cmp #232
    bcs @k
    jsr pb_hits
    jmp @n
@k:
    lda #0
    sta pb_t,x
@n:
    dex
    bpl @l
    rts

; bala X contra enemigos y jefe
pb_hits:
    stx tmp4
    ldy #HE_N-1
@e:
    lda e_t,y
    beq @ne
    ; |bx - ex| < 12, by en [ey-20, ey+2]
    lda pb_x,x
    sec
    sbc e_x,y
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #13
    bcs @ne
    lda e_y,y
    sec
    sbc pb_y,x
    cmp #24
    bcs @ne
    ; impacto
    lda #0
    sta pb_t,x
    lda #4
    sta e_fl,y
    lda e_hp,y
    sec
    sbc #1
    sta e_hp,y
    bne @hit
    tya
    tax
    jsr enemy_kill
    ldx tmp4
    rts
@hit:
    jmp sfx_hit
@ne:
    dey
    bpl @e
    ; jefe
    lda h_boss
    cmp #1
    bne @r
    lda pb_x,x
    sec
    sbc bs_x
    bcs @bp
    eor #$FF
    adc #1
@bp:
    cmp #26
    bcs @r
    lda bs_y
    sec
    sbc pb_y,x
    cmp #32
    bcs @r
    lda #0
    sta pb_t,x
    lda #4
    sta bs_fl
    jsr sfx_hit
    dec bs_hp
    bne @r
    ; jefe derrotado
    lda #2
    sta h_boss
    lda #120
    sta bs_t
    lda #1
    ldy #2
    jsr add_score
@r:
    rts

enemy_kill:            ; X = enemigo
    lda #0
    sta e_t,x
    lda e_x,x
    sta tmp0
    lda e_y,x
    sec
    sbc #10
    sta tmp1
    jsr fx_add
    jsr sfx_boom
    lda #1
    ldy #3
    jmp add_score

fx_add:                ; tmp0 = x, tmp1 = y
    ldy #HX_N-1
@l:
    lda x_t,y
    beq @ok
    dey
    bpl @l
    rts
@ok:
    lda #20
    sta x_t,y
    lda tmp0
    sta x_x,y
    lda tmp1
    sta x_y,y
    rts

heli_fx:
    ldx #HX_N-1
@l:
    lda x_t,x
    beq @n
    dec x_t,x
@n:
    dex
    bpl @l
    rts

; ---------------------------------------------------------------- oleadas
; guion: [espera (cuadros/4), tipo, y]  tipo 1 = policia con propulsor, 2 = helicoptero, 3 = trio de policias,
;        $FF = jefe
heli_waves:
    lda h_boss
    beq @__n526_0
    jmp @r
@__n526_0:
    dec h_wt
    beq @__n530_1
    jmp @r
@__n530_1:
    lda h_wi
    asl
    clc
    adc h_wi
    tay
    lda heli_script,y
    cmp #$FF
    beq @boss
    sta tmp2
    lda heli_script+1,y
    sta tmp3
    lda heli_script+2,y
    asl
    asl
    sta h_wt
    inc h_wi
    lda tmp2
    cmp #3
    bne @one
    ; pareja en formacion
    lda tmp3
    sec
    sbc #20
    jsr spawn_cop
    lda tmp3
    clc
    adc #20
    jmp spawn_cop
@one:
    cmp #2
    beq @hel
    lda tmp3
    jmp spawn_cop
@hel:
    lda tmp3
    jmp spawn_heli
@boss:
    ; jefe: helicoptero militar
    lda #1
    sta h_boss
    sta boss_on
    lda #255
    sta bs_x
    lda #120
    sta bs_y
    lda #1
    sta bs_vy
    lda #BOSS_HP
    sta bs_hp
    lda #60
    sta bs_t
    lda #0
    sta bs_ph
    sta bs_n
    ; paleta del jefe (P2 de sprites = verde militar)
    lda #$0A
    sta pal_buf+26
    lda #$1A
    sta pal_buf+27
    lda #1
    sta pal_dirty
    lda #2
    jmp mus_play
@r:
    rts

free_enemy:            ; -> X libre (C=1) o C=0
    ldx #HE_N-1
@l:
    lda e_t,x
    beq @ok
    dex
    bpl @l
    clc
    rts
@ok:
    lda #0
    sta e_fx,x
    sta e_fy,x
    sta e_tm,x
    sta e_fl,x
    sta e_vy,x
    sec
    rts

spawn_cop:             ; A = y
    pha
    jsr free_enemy
    pla
    bcc @r
    sta e_y,x
    lda #1
    sta e_t,x
    lda #248
    sta e_x,x
    lda #$E8              ; -0.75 px
    sta e_vx,x
    lda #2
    sta e_hp,x
    lda h_rnd
    clc
    adc #73
    sta h_rnd
    and #63
    adc #20
    sta e_cd,x
@r:
    rts

spawn_heli:            ; A = y
    pha
    jsr free_enemy
    pla
    bcc @r
    sta e_y,x
    lda #2
    sta e_t,x
    lda #248
    sta e_x,x
    lda #$E0              ; -1 px
    sta e_vx,x
    lda #9
    sta e_hp,x
    lda #50
    sta e_cd,x
@r:
    rts

; ---------------------------------------------------------------- enemigos
heli_enemies:
    ldx #HE_N-1
@l:
    lda e_t,x
    bne @a
    jmp @n
@a:
    stx tmp4
    lda e_fl,x
    beq @f
    dec e_fl,x
@f:
    lda e_t,x
    cmp #2
    bne @fi
    lda e_tm,x
    cmp #250
    bcs @f2
@fi:
    inc e_tm,x
@f2:
    lda e_t,x
    cmp #2
    beq @hel
    ; policia con propulsor: ondea arriba/abajo
    lda e_tm,x
    lsr
    lsr
    and #15
    tay
    lda sine16,y
    sta e_vy,x
    jmp @mv
@hel:
    ; helicoptero: entra, se queda flotando y despues se va
    lda e_tm,x
    cmp #250
    bcc @h1
    lda #$C0
    sta e_vx,x
    jmp @h2
@h1:
    lda e_x,x
    cmp #196
    bcs @h2
    lda #0
    sta e_vx,x
@h2:
    lda e_tm,x
    lsr
    lsr
    lsr
    and #15
    tay
    lda sine16,y
    cmp #$80
    ror
    sta e_vy,x
@mv:
    lda e_vx,x
    jsr e_addx
    lda e_vy,x
    jsr e_addy
    ; fuera de pantalla
    lda e_x,x
    cmp #4
    bcs @__n730_2
    jmp @kill
@__n730_2:
    cmp #252
    bcc @__n1213_1
    jmp @kill
@__n1213_1:
    ; disparo
    dec e_cd,x
    bne @col
    lda e_t,x
    cmp #2
    beq @hs
    ; dron: dispara mas seguido y de a dos balas
    lda #50
    sta e_cd,x
    lda e_x,x
    cmp #236
    bcs @col
    sec
    sbc #6
    sta tmp0
    lda e_y,x
    sec
    sbc #4
    sta tmp1
    lda #54
    jsr shoot_aimed
    lda tmp1
    sec
    sbc #7
    sta tmp1
    lda #46
    jsr shoot_aimed
    jmp @col
@hs:
    lda #58
    sta e_cd,x
    lda e_x,x
    cmp #236
    bcs @col
    sec
    sbc #14
    sta tmp0
    lda e_y,x
    sec
    sbc #8
    sta tmp1
    jsr shoot_3way
@col:
    ; choque con el helicoptero del jugador
    lda h_dead
    bne @n
    lda e_x,x
    sec
    sbc h_x
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #24
    bcs @n
    lda e_y,x
    sec
    sbc h_y
    bcs @p2
    eor #$FF
    adc #1
@p2:
    cmp #16
    bcs @n
    stx tmp4
    jsr enemy_kill
    lda #4
    jsr heli_hurt
    ldx tmp4
    jmp @n
@kill:
    lda #0
    sta e_t,x
@n:
    dex
    bmi @r
    jmp @l
@r:
    rts

sine16: .byte 0,8,15,19,20,19,15,8,0,$F8,$F1,$ED,$EC,$ED,$F1,$F8

; suma velocidad (A, con signo, en 1/32 px) a la posicion 8.8
e_addx:
    jsr vel16
    clc
    lda e_fx,x
    adc tmp8
    sta e_fx,x
    lda e_x,x
    adc tmp9
    sta e_x,x
    rts
e_addy:
    jsr vel16
    clc
    lda e_fy,x
    adc tmp8
    sta e_fy,x
    lda e_y,x
    adc tmp9
    sta e_y,x
    rts
q_addx:
    jsr vel16
    clc
    lda q_fx,x
    adc tmp8
    sta q_fx,x
    lda q_x,x
    adc tmp9
    sta q_x,x
    rts
q_addy:
    jsr vel16
    clc
    lda q_fy,x
    adc tmp8
    sta q_fy,x
    lda q_y,x
    adc tmp9
    sta q_y,x
    rts
vel16:                 ; A (signo, 1/32) -> tmp8/tmp9 = A*8 (16 bits)
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
free_q:                ; -> Y libre (C=1)
    ldy #HQ_N-1
@l:
    lda q_t,y
    beq @ok
    dey
    bpl @l
    clc
    rts
@ok:
    sec
    rts

; tmp0/tmp1 = origen, A = rapidez (vel. en 1/32: 40 = 1.25 px) hacia el jugador
shoot_aimed:
    sta tmp10
    jsr free_q
    bcs @ok
    rts
@ok:
    jsr q_setpos
    ; dx = jugador - origen
    lda h_x
    sec
    sbc tmp0
    sta tmp2
    lda h_y
    sec
    sbc #9
    sec
    sbc tmp1
    sta tmp3
    jsr aim_dir           ; -> tmp2 (vx), tmp3 (vy)
    lda tmp2
    sta q_vx,y
    lda tmp3
    sta q_vy,y
    rts

q_setpos:
    lda #1
    sta q_t,y
    lda tmp0
    sta q_x,y
    lda tmp1
    sta q_y,y
    lda #$80
    sta q_fx,y
    sta q_fy,y
    rts

; tmp2 = dx, tmp3 = dy (con signo, -128..127) -> velocidad (1.25 px) en 6 direcciones por cuadrante
aim_dir:
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
    lda aim_vx,x
    sta tmp2
    lda aim_vy,x
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
aim_vx: .byte 40,37,32,22,14,0
aim_vy: .byte 0,15,24,33,38,40

shoot_3way:            ; tmp0/tmp1 origen: tres balas hacia la izquierda
    ldx #2
@l:
    stx tmp11
    jsr free_q
    bcc @r
    jsr q_setpos
    ldx tmp11
    lda w3_vx,x
    sta q_vx,y
    lda w3_vy,x
    sta q_vy,y
    dex
    bpl @l
@r:
    ldx tmp4
    rts
w3_vx: .byte $D8,$DA,$D8
w3_vy: .byte $F0,0,$10

shoot_5way:            ; tmp0/tmp1 origen
    ldx #4
@l:
    stx tmp11
    jsr free_q
    bcc @r
    jsr q_setpos
    ldx tmp11
    lda w5_vx,x
    sta q_vx,y
    lda w5_vy,x
    sta q_vy,y
    dex
    bpl @l
@r:
    rts
w5_vx: .byte $DC,$D8,$D6,$D8,$DC
w5_vy: .byte $E4,$F2,0,$0E,$1C

heli_qbullets:
    ldx #HQ_N-1
@l:
    lda q_t,x
    beq @n
    lda q_vx,x
    jsr q_addx
    lda q_vy,x
    jsr q_addy
    lda q_x,x
    cmp #4
    bcc @k
    cmp #252
    bcs @k
    lda q_y,x
    cmp #36
    bcc @k
    cmp #236
    bcs @k
    ; contra el jugador (caja chica: el cuerpo del helicoptero)
    lda h_dead
    bne @n
    lda q_x,x
    sec
    sbc h_x
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #14
    bcs @n
    lda h_y
    sec
    sbc #9
    sec
    sbc q_y,x
    bcs @p2
    eor #$FF
    adc #1
@p2:
    cmp #8
    bcs @n
    lda #0
    sta q_t,x
    stx tmp4
    lda #3
    jsr heli_hurt
    ldx tmp4
    jmp @n
@k:
    lda #0
    sta q_t,x
@n:
    dex
    bpl @l
    rts

; ---------------------------------------------------------------- danio al helicoptero (A = danio)
heli_hurt:
    ldy h_inv
    bne @r
    ldy h_dead
    bne @r
    sta tmp2
    jsr sfx_hit
    lda #6
    sta shake
    lda #70
    sta h_inv
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
    lda h_x
    sta tmp0
    lda h_y
    sec
    sbc #8
    sta tmp1
    jsr fx_add
    jsr sfx_boom
    lda #16
    sta p_base+13
    sta p_base+32+13
    lda #150
    sta h_inv
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
    sta h_dead
    rts

; ---------------------------------------------------------------- jefe: helicoptero militar
heli_boss:
    lda h_boss
    bne @on
    rts
@on:
    cmp #2
    bne @alive
    ; explotando
    lda h_t
    and #7
    bne @e1
    lda h_rnd
    clc
    adc #37
    sta h_rnd
    and #31
    clc
    adc bs_x
    sec
    sbc #16
    sta tmp0
    lda h_rnd
    lsr
    lsr
    and #15
    sta tmp1
    lda bs_y
    sec
    sbc tmp1
    sec
    sbc #4
    sta tmp1
    jsr fx_add
    jsr sfx_boom
@e1:
    dec bs_t
    bne @r
    lda #3
    sta h_boss
    lda #0
    sta boss_on
    lda #90
    sta h_end
@r:
    rts
@alive:
    lda bs_fl
    beq @f
    dec bs_fl
@f:
    ; entrada
    lda bs_x
    cmp #200
    bcc @bob
    dec bs_x
    rts
@bob:
    ; sube y baja
    lda h_t
    and #1
    bne @at
    lda bs_y
    clc
    adc bs_vy
    sta bs_y
    cmp #84
    bcs @b1
    lda #1
    sta bs_vy
@b1:
    lda bs_y
    cmp #196
    bcc @at
    lda #$FF
    sta bs_vy
@at:
    ; ataques
    dec bs_t
    bne @r2
    lda bs_ph
    and #3
    tax
    lda bs_phase_t,x
    sta bs_t
    lda bs_x
    sec
    sbc #22
    sta tmp0
    lda bs_y
    sec
    sbc #11
    sta tmp1
    lda bs_ph
    and #3
    beq @a5
    cmp #2
    beq @a5
    ; rafaga apuntada (3 balas rapidas)
    lda #58
    jsr shoot_aimed
    lda tmp1
    sec
    sbc #6
    sta tmp1
    lda #52
    jsr shoot_aimed
    lda tmp1
    clc
    adc #12
    sta tmp1
    lda #52
    jsr shoot_aimed
    jmp @nx
@a5:
    jsr shoot_5way
@nx:
    inc bs_ph
@r2:
    ; choque
    lda h_dead
    bne @r3
    lda bs_x
    sec
    sbc h_x
    bcs @p
    eor #$FF
    adc #1
@p:
    cmp #34
    bcs @r3
    lda bs_y
    sec
    sbc h_y
    bcs @p2
    eor #$FF
    adc #1
@p2:
    cmp #20
    bcs @r3
    lda #4
    jsr heli_hurt
@r3:
    rts
bs_phase_t: .byte 48,42,56,34

; ---------------------------------------------------------------- dibujo
heli_draw:
    jsr clear_oam
    jsr reset_draw
    lda #0
    sta sx_hi
    ; con el jefe en pantalla se alterna quien va primero (mas de 8 sprites por linea: parpadean los dos)
    lda frame
    and #1
    beq @pfirst
    jsr heli_draw_boss
    jsr hd_player
    jmp @after
@pfirst:
    jsr hd_player
    jsr heli_draw_boss
@after:
    jmp hd_rest

hd_player:
    lda h_dead
    bne @nop
    lda h_inv
    and #2
    bne @nop
    lda h_x
    sta sx_lo
    lda h_y
    sta sy
    lda h_t
    lsr
    and #1
    clc
    adc #HF_PL0
    jmp hdraw
@nop:
    rts

hd_rest:
    ; enemigos (orden alternado: reparte el parpadeo)
    lda frame
    and #1
    beq @fw
    ldx #0
@el:
    jsr hd_enemy
    inx
    cpx #HE_N
    bne @el
    jmp @fx
@fw:
    ldx #HE_N-1
@er:
    jsr hd_enemy
    dex
    bpl @er
@fx:
    ; explosiones
    ldx #HX_N-1
@xl:
    lda x_t,x
    beq @xn
    stx h_sv
    lda x_x,x
    sta sx_lo
    lda x_y,x
    sta sy
    lda x_t,x
    and #4
    lsr
    lsr
    clc
    adc #MF_EX0
    jsr hmisc
    ldx h_sv
@xn:
    dex
    bpl @xl
    ; balas del jugador
    ldx #HB_N-1
@pb:
    lda pb_t,x
    beq @pn
    stx h_sv
    lda pb_x,x
    sta sx_lo
    lda pb_y,x
    clc
    adc #3
    sta sy
    lda #0
    ldy pb_dx,x
    bpl @rf
    lda #$40
@rf:
    sta sflip
    lda #MF_ROCKET
    jsr hmisc
    ldx h_sv
@pn:
    dex
    bpl @pb
    ; balas enemigas
    ldx #HQ_N-1
@qb:
    lda q_t,x
    beq @qn
    stx h_sv
    lda q_x,x
    sta sx_lo
    lda q_y,x
    clc
    adc #4
    sta sy
    lda #MF_EB
    jsr hmisc
    ldx h_sv
@qn:
    dex
    bpl @qb
    rts

hd_enemy:              ; X = enemigo (se preserva)
    lda e_t,x
    beq @r
    lda e_fl,x
    and #2
    bne @r
    stx h_sv
    lda e_x,x
    sta sx_lo
    lda e_y,x
    sta sy
    lda e_t,x
    cmp #2
    beq @h
    lda h_t
    lsr
    lsr
    and #1
    clc
    adc #HF_JC0
    jmp @d
@h:
    lda h_t
    lsr
    and #1
    clc
    adc #HF_PH0
@d:
    jsr hdraw
    ldx h_sv
@r:
    rts

heli_draw_boss:
    lda h_boss
    beq @r
    cmp #3
    beq @r
    lda bs_fl
    and #2
    bne @bar
    lda bs_x
    sta sx_lo
    lda bs_y
    sta sy
    lda h_t
    lsr
    and #1
    clc
    adc #HF_BS0
    jsr hdraw
@bar:
    lda h_boss
    cmp #1
    bne @r
    ; barra de vida del jefe (vertical, estilo Mega Man): 28 unidades
    lda bs_hp
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
    lda hbx_lo,x
    sta fptr
    lda hbx_hi,x
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

hdraw:                 ; A = cuadro del nivel helicoptero
    tax
    lda hf_lo,x
    sta fptr
    lda hf_hi,x
    sta fptr+1
    jmp draw_frame
hmisc:                 ; A = cuadro misc (copia en este banco)
    tax
    lda hm_lo,x
    sta fptr
    lda hm_hi,x
    sta fptr+1
    jmp draw_frame

; ---------------------------------------------------------------- guion de enemigos (espera en cuadros/4)
heli_script:
    .byte 1, 120, 29
    .byte 1, 90, 29
    .byte 1, 160, 36
    .byte 3, 128, 44
    .byte 2, 110, 44
    .byte 1, 80, 25
    .byte 1, 180, 36
    .byte 3, 150, 44
    .byte 2, 90, 29
    .byte 2, 170, 44
    .byte 1, 70, 22
    .byte 1, 200, 22
    .byte 1, 130, 36
    .byte 3, 110, 44
    .byte 2, 140, 36
    .byte 1, 190, 22
    .byte 1, 75, 36
    .byte 3, 160, 44
    .byte 2, 100, 29
    .byte 2, 180, 44
    .byte 3, 120, 43
    .byte 1, 90, 22
    .byte 1, 170, 22
    .byte 2, 140, 44
    .byte $FF, 0, 0

scene_pal:             ; BG paleta 1 (cielo/nubes) y 2 (helicoptero grande)
    .byte $0F,$21,$30,$31, $0F,$21,$30,$2C
scene_pal3: .byte $0F,$00,$10,$28   ; azotea
heli_pal:              ; BG paletas 2-3, sprites 0-3
    .byte $0F,$21,$30,$31, $0F,$21,$0C,$28
    .byte $0F,$0F,$27,$17, $0F,$0F,$30,$2C, $0F,$0F,$27,$12, $0F,$0F,$27,$30
