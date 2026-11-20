; =====================================================================
;  JUEGO
; =====================================================================
np_xlo = $88
np_xhi = $89
np_y = $8A
np_z = $8B
np_vx = $8C
np_vz = $8D
lvl_x = $8E

level_init:
    jsr ppu_off
    lda #1
    jsr mus_play
    lda level
    asl
    asl
    asl
    sta tmp0
    asl
    clc
    adc tmp0
    tax
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
    lda level_tbl+6,x
    sta ptr2
    lda level_tbl+7,x
    sta ptr2+1
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
    lda level_tbl+16,x
    sta chr_r0
    lda level_tbl+17,x
    sta chr_r1
    lda level_tbl+18,x
    sta faction
    lda level_tbl+19,x
    sta stars
    lda level_tbl+20,x
    sta boss_id
    jsr load_palette
    jsr set_shirt
    lda #UNIT_MISC
    sta chr_r3
    lda #UNIT_COP
    ldx faction
    beq @c
    lda #UNIT_SOLDIER
@c:
    sta chr_r45
    ; limpiar
    ldx #0
    lda #0
@cl:
    sta $0300,x
    inx
    cpx #$B0
    bne @cl
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
    sta pveh
    sta vhits
    sta pz
    sta vz_lo
    sta vz_hi
    sta vx
    sta pst
    sta pdir
    sta dead_t
    sta shake
    sta combo
    lda #$FF
    sta token
    lda #<$600
    sta cam_max_lo
    lda #>$600
    sta cam_max_hi
    lda #16
    sta hp
    lda #40
    sta px_lo
    lda #0
    sta px_hi
    lda #196
    sta py
    lda #60
    sta inv
    jsr next_wave_lock
    ; vehiculos estacionados
    ldy #0
    ldx #0
@v:
    lda (ptr2),y
    cmp #$FF
    beq @vd
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
    ; pantalla
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
@ic:
    jsr build_column
    jsr nmi_column
    inc tc_lo
    lda tc_lo
    cmp #34
    bne @ic
    jsr hud_prepare
    jsr clear_oam
    lda #ST_PLAY
    sta state
    lda #1
    sta game_irq
    jsr ppu_enable
    rts

set_shirt:
    lda #$2C
    ldx char
    beq @j
    lda #$25
@j:
    sta pal_buf+23
    lda #1
    sta pal_dirty
    rts

hud_static:
    lda char
    bne @l
    lda #<hud_jose
    ldx #>hud_jose
    jmp @d
@l:
    lda #<hud_luci
    ldx #>hud_luci
@d:
    jsr draw_ptr
    lda #<hud_common
    ldx #>hud_common
    jsr draw_ptr
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$41
    sta PPUADDR
    ldx #0
@s:
    lda #$44
    cpx stars
    bcs @e
    lda #$43
@e:
    sta PPUDATA
    inx
    cpx #5
    bne @s
    rts

draw_far:              ; A = $20/$24 ; filas 4-7 desde far_ptr (16x4) repetido
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
block_ptr:             ; Y = metacol -> ptr2 = registro del bloque (28 bytes)
    cpy #LEVEL_MC
    bcc @in
    lda #0
    beq @b
@in:
    lda (seq_ptr),y
@b:
    sta tmp0
    lda #0
    sta tmp1
    ; *28 = *32 - *4
    lda tmp0
    asl
    asl
    sta tmp2           ; *4
    lda tmp0
    asl
    asl
    asl
    asl
    asl                ; *32 (b<8)
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
    sta tmp8           ; metacol
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
    ; atributos
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
    sta tmp0,x         ; tmp0..tmp4 = paletas izq
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
    sta tmp5,x         ; tmp5..tmp9 = paletas der
    iny
    inx
    cpx #5
    bne @rp
    ; ar2
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
    ; ar3
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
    ; ar4
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

; ---------------------------------------------------------------- oleadas y camara
next_wave_lock:        ; lock = mc*16 de la proxima oleada, o cam_max
    ldy #0
    lda (wave_ptr),y
    cmp #$FF
    beq @none
    sta tmp0
    lda #0
    sta tmp1
    ldx #4
@s:
    asl tmp0
    rol tmp1
    dex
    bne @s
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

camera_update:
    lda in_wave
    beq @__n505_1
    jmp @r
@__n505_1:
    lda boss_on
    bne @r
    lda #112
    ldx pveh
    beq @t
    lda #96
@t:
    sta tmp2
    lda px_lo
    sec
    sbc tmp2
    sta tmp0
    lda px_hi
    sbc #0
    sta tmp1
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
    ; llego al candado?
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
    lda #1
    sta in_wave
    lda #20
    sta spawn_cd
    lda wave_ptr
    clc
    adc #2
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
    jsr spawn_grunt
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

spawn_grunt:           ; C=1 si aparecio
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
    jsr rand
    and #63
    clc
    adc #YMIN
    cmp #YMAX
    bcc @yo
    lda #YMAX
@yo:
    sta en_y,x
    lda #8
    ldy faction
    beq @hp
    lda #12
@hp:
    clc
    adc level
    sta en_hp,x
    lda #0
    sta en_z,x
    sta en_vz,x
    sta en_st,x
    sta en_inv,x
    sta en_dead,x
    sta en_flash,x
    sta en_anim,x
    jsr rand
    and #1
    sta en_mode,x
    lda #40
    sta en_cd,x
    sec
    rts

; ---------------------------------------------------------------- juego por cuadro
st_play:
    lda dead_t
    beq @alive
    dec dead_t
    bne @dd
    dec lives
    bne @resp
    jmp gameover_init
@resp:
    lda #16
    sta hp
    lda #0
    sta pst
    sta pveh
    lda #120
    sta inv
    jmp @alive
@dd:
    jsr enemies_update
    jsr proj_update
    jsr fx_update
    jmp @draw
@alive:
    jsr player_update
    jsr camera_update
    jsr stream_columns
    jsr waves_update
    jsr enemies_update
    jsr boss_update
    lda state
    cmp #ST_PLAY
    bne @out
    jsr proj_update
    jsr fx_update
@draw:
    jsr hud_prepare
    jsr draw_all
@out:
    rts

; ---------------------------------------------------------------- jugador
veh_max: .byte 22, 52, 60
veh_acc: .byte 4, 3, 2
veh_half: .byte 8, 18, 24

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

; edades de A/B para el combo A+B
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
    lda #0
    sta pad_new
@no:
    rts

; movimiento comun (velocidad suave + profundidad)
move_player:
    ldx pveh
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
    ; profundidad
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
    ; px >= cam+12
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

do_gravity:            ; z/vz del jugador; C=1 si aterrizo
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
    jsr move_player
    ; salto
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
    lda pz
    beq @gb
    lda #PS_KICK
    sta pst
    lda #0
    sta hitdone
    jmp @nb
@gb:
    jsr enemy_in_reach
    bcc @shoot
    lda #PS_PUNCH
    sta pst
    lda #14
    sta ptm
    lda #0
    sta hitdone
    sta vx
    jmp @nb
@shoot:
    lda shoot_cd
    bne @nb
    lda #PS_SHOOT
    sta pst
    lda #16
    sta ptm
    lda #0
    sta vx
@nb:
    jsr do_gravity
    ; cuadro
    lda pz
    beq @g
    lda #6
    sta pframe
    rts
@g:
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
    lsr
    and #3
    tax
    lda walk_seq,x
    sta pframe
    rts
walk_seq: .byte 2, 3, 4, 3

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
    lda ptm
    bne @r
    lda #PS_NORM
    sta pst
    lda #6
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
    sta pframe
    jsr move_player
    lda hitdone
    bne @nh
    lda #2
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
    lda pad
    and #BTN_B
    beq @nf
    lda shoot_cd
    bne @nf
    jsr player_fire
    lda #10
    sta shoot_cd
@nf:
    ; atropellar
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
    beq @ne
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
    lda #4
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
    ; rueda
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
    sta pframe
    rts

toggle_vehicle:        ; C=1 si hizo algo
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

; ---------------------------------------------------------------- dano al jugador
; A = dano, Y = 1 derriba ; tmp9 = direccion del golpe (0 desde izq, 1 desde der)
player_hit:
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
    txa
    pha
    jsr veh_destroy
    pla
    tax
    rts
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
    lda #120
    sta dead_t
    lda #6
    sta shake
    jmp sfx_boom
@r:
    rts

; ---------------------------------------------------------------- utilidades de distancia
en_dx:                 ; X slot -> tmp0/1 = ex - px ; tmp2 = |dx| (saturado 255)
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

en_dy:                 ; X slot -> A = |ey - py|
    lda en_y,x
    sec
    sbc py
    bcs @r
    eor #$FF
    adc #1
@r:
    rts

in_front:              ; tmp1 signo de dx -> C=1 si esta delante del jugador
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

enemy_in_reach:        ; C=1 si hay enemigo/jefe a distancia de golpe
    ldx #0
@e:
    lda en_t,x
    beq @n
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

player_melee:          ; A=dano Y=derriba -> C=1 si golpeo algo
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
    cmp #36
    bcs @n
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

player_fire:
    lda pz
    clc
    adc #16
    ldx pveh
    beq @f
    lda #14
    clc
    adc pz
@f:
    sta np_z
    lda py
    sta np_y
    lda #18
    ldx pveh
    beq @o
    lda #24
@o:
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
    lda #0
    sta np_vz
    lda #1
    jsr proj_spawn
    jmp sfx_shoot

; ---------------------------------------------------------------- enemigos
; X slot, A dano, Y derriba
enemy_take:
    sta tmp7
    lda en_st,x
    cmp #ES_DOWN
    bcs @r
    lda en_inv,x
    bne @r
    lda #10
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
    bne @alive
    lda #1
    sta en_dead,x
    ldy #1
@alive:
    ; direccion del empujon: lejos del jugador
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
; cada manejador termina en jmp en_cont
en_cont:
    ldx tmp11
    inx
    cpx #NEN
    beq @r
    jmp enemies_update_l
@r:
    rts
enemies_update_l = enemies_update+2

face_x:                ; X slot -> en_dir hacia el jugador
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
    ; turno de ataque
    lda token
    cmp #$FF
    bne @ht
    lda en_cd,x
    bne @ht
    lda pst
    cmp #PS_DEAD
    beq @ht
    stx token
@ht:
    ; objetivo
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
    lda #104
    sta tmp3
    lda py
    cmp #197
    bcs @wu
    clc
    adc #34
    cmp #YMAX
    bcc @wy
    lda #YMAX
    jmp @wy
@wu:
    sec
    sbc #34
@wy:
    sta tmp4
@side:
    ; tx = px +/- tmp3 segun lado del enemigo
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
    ; mantener dentro de pantalla [cam+10, cam+246]
    lda cam_lo
    clc
    adc #10
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
    adc #246
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
    ; mover en x
    lda #0
    sta tmp7               ; se movio?
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
    lda faction
    bne @go
    lda frame
    and #3
    beq @nx
@go:
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
    ; mover en y
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
    ; cuadro
    lda tmp7
    beq @idle
    lda en_anim,x
    lsr
    lsr
    lsr
    and #1
    clc
    adc #EF_WALK1
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

end_attack:
    lda #ES_WALK
    sta en_st,x
    lda #$FF
    sta token
    jsr rand
    and #31
    clc
    adc #46
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
    ; golpe: jugador delante y cerca
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
    sta tmp9
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
    ; disparo
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

en_push:               ; x += en_kvx (signed)
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
    lda #EF_DOWN
    sta en_fr,x
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

; ---------------------------------------------------------------- proyectiles
; A = tipo ; np_* = datos
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
    ; x += vx
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
    ; fuera de pantalla?
    lda pr_xlo,x
    sec
    sbc cam_lo
    lda pr_xhi,x
    sbc cam_hi
    beq @on
    jmp @kill
@on:
    lda pr_t,x
    cmp #3
    bcc @bul
    ; granada / bomba: z con gravedad
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
    ldx tmp11
    ; dano de area
    lda pr_xlo,x
    sec
    sbc px_lo
    sta tmp0
    lda pr_xhi,x
    sbc px_hi
    sta tmp1
    jsr abs16
    lda tmp2
    cmp #24
    bcc @__n2419_2
    jmp @kill
@__n2419_2:
    lda pr_y,x
    sec
    sbc py
    bcs @ay
    eor #$FF
    adc #1
@ay:
    cmp #16
    bcs @kill
    lda pz
    cmp #20
    bcs @kill
    lda tmp1
    rol
    lda #0
    rol
    sta tmp9
    lda #4
    ldy #1
    jsr player_hit
    ldx tmp11
    jmp @kill
@bul:
    cmp #1
    beq @pb
    ; bala enemiga vs jugador
    lda dead_t
    bne @n
    lda pr_xlo,x
    sec
    sbc px_lo
    sta tmp0
    lda pr_xhi,x
    sbc px_hi
    sta tmp1
    jsr abs16
    ldy pveh
    lda veh_half,y
    cmp tmp2
    bcc @n
    lda pr_y,x
    sec
    sbc py
    bcs @by
    eor #$FF
    adc #1
@by:
    cmp #11
    bcs @n
    lda pr_z,x
    sec
    sbc pz
    bcc @n
    cmp #32
    bcs @n
    lda pst
    cmp #PS_DOWN
    beq @n
    stx tmp11
    lda pr_vx,x
    rol
    rol
    and #1
    eor #1
    sta tmp9
    lda #2
    ldy #0
    jsr player_hit
    ldx tmp11
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
    ; bala del jugador vs enemigos/jefe
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
    lda tmp2
    cmp #10
    bcs @ne
    lda pr_y,x
    sec
    sbc en_y,y
    bcs @ey
    eor #$FF
    adc #1
@ey:
    cmp #11
    bcs @ne
    ; impacto
    lda #0
    sta pr_t,x
    tya
    tax
    lda #1
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
    lda #0
    sta pr_t,x
    lda #1
    jsr boss_take
    ldx tmp11
@nb:
    jmp @n

; ---------------------------------------------------------------- explosiones
fx_spawn:              ; np_xlo/hi, np_y
    ldx #0
@f:
    lda fx_t,x
    beq @g
    inx
    cpx #NFX
    bne @f
    rts
@g:
    lda #18
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
hud_prepare:
    ldx #0
    lda hp
    sta tmp0
    jsr bar8
    lda lives
    clc
    adc #$10
    sta hud_buf+8
    ldx #0
@s:
    lda score,x
    clc
    adc #$10
    sta hud_buf+9,x
    inx
    cpx #6
    bne @s
    ; vehiculo
    lda pveh
    asl
    asl
    tay
    ldx #0
@v:
    lda veh_lab,y
    sta hud_buf+15,x
    iny
    inx
    cpx #4
    bne @v
    lda #$44
    sta hud_buf+19
    sta hud_buf+20
    lda pveh
    beq @nv
    lda #$45
    sta hud_buf+19
    lda vhits
    bne @nv
    lda #$45
    sta hud_buf+20
@nv:
    ; jefe
    lda boss_on
    beq @nb
    lda b_st
    cmp #9
    beq @nb
    ldx #0
@j:
    lda jefe_lab,x
    sta hud_buf+21,x
    inx
    cpx #4
    bne @j
    ; tmp0 = ceil(b_hp*16/hpmax)
    lda b_hp
    asl
    asl
    asl
    asl
    sta tmp1
    lda #0
    rol
    sta tmp2           ; tmp2:tmp1 = b_hp*16
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
    ldx #25
    jsr bar8
    rts
@nb:
    ldx #0
    lda #$44
@cl:
    sta hud_buf+21,x
    inx
    cpx #12
    bne @cl
    rts

bar8:                  ; tmp0 = valor 0..16, X = indice en hud_buf
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

veh_lab:
    .text "____"
    .text "MOTO"
    .text "AUTO"
jefe_lab:
    .text "JEFE"
hud_jose:
    .str $2021, "JOSE"
    .byte 0
hud_luci:
    .str $2021, "LUCIANA"
    .byte 0
hud_common:
    .str $2032, "X"
    .byte 0

; ---------------------------------------------------------------- dibujo
draw_all:
    jsr clear_oam
    jsr reset_draw
    jsr draw_go
    jsr draw_projs
    jsr draw_fxs
    ; lista de profundidad
    ldx #0
    lda py
    sta dl_y,x
    lda #0
    sta dl_id,x
    inx
    ldy #0
@e:
    lda en_t,y
    beq @ne
    lda en_y,y
    sta dl_y,x
    tya
    clc
    adc #1
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
    lda #4
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
    adc #5
    sta dl_id,x
    inx
@nv:
    iny
    cpy #NVO
    bne @v
    stx tmp10          ; cantidad
    ; ordenar por y descendente (insercion)
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
    ldx #0
@dl:
    cpx tmp10
    bcs @fin
    stx tmp11
    lda dl_id,x
    beq @pl
    cmp #4
    bcc @en
    beq @bs
    sec
    sbc #5
    tax
    jsr draw_vo
    jmp @dn
@pl:
    jsr draw_player
    jmp @dn
@en:
    sec
    sbc #1
    tax
    jsr draw_enemy
    jmp @dn
@bs:
    jsr draw_boss
@dn:
    jsr reset_draw
    ldx tmp11
    inx
    jmp @dl
@fin:
    rts

draw_player:
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
    ; sombra al saltar
    lda pz
    beq @ns
    lda py
    sta sy
    lda #MF_SHADOW
    jsr draw_misc
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
    ldy pframe
    lda pveh
    beq @foot
    cmp #1
    beq @moto
    ; auto
    lda char
    bne @lc
    lda jose_car_bk,y
    sta chr_r2
    lda jose_car_lo,y
    ldx jose_car_hi,y
    jmp @go
@lc:
    lda luci_car_bk,y
    sta chr_r2
    lda luci_car_lo,y
    ldx luci_car_hi,y
    jmp @go
@moto:
    lda char
    bne @lm
    lda jose_moto_bk,y
    sta chr_r2
    lda jose_moto_lo,y
    ldx jose_moto_hi,y
    jmp @go
@lm:
    lda luci_moto_bk,y
    sta chr_r2
    lda luci_moto_lo,y
    ldx luci_moto_hi,y
    jmp @go
@foot:
    lda char
    bne @lf
    lda jose_bk,y
    sta chr_r2
    lda jose_lo,y
    ldx jose_hi,y
    jmp @go
@lf:
    lda luci_bk,y
    sta chr_r2
    lda luci_lo,y
    ldx luci_hi,y
@go:
    sta fptr
    stx fptr+1
    jmp draw_frame

draw_enemy:            ; X slot
    lda en_st,x
    cmp #ES_DIE
    bne @v
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
    ; fogonazo
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

draw_vo:               ; X slot vehiculo estacionado
    lda vo_xlo,x
    sta tmp0
    lda vo_xhi,x
    sta tmp1
    jsr world_sx
    lda vo_y,x
    sta sy
    lda #MF_CAR
    ldy vo_t,x
    cpy #2
    beq @c
    lda #MF_MOTO
@c:
    stx tmp9
    jsr draw_misc
    ; indicador A+B
    lda pveh
    bne @r
    ldx tmp9
    lda vo_xlo,x
    sec
    sbc px_lo
    sta tmp0
    lda vo_xhi,x
    sbc px_hi
    sta tmp1
    jsr abs16
    lda tmp2
    cmp #34
    bcs @r
    lda frame
    and #16
    beq @r
    lda vo_y,x
    sec
    sbc #40
    sta sy
    lda #MF_AB
    jmp draw_misc
@r:
    rts

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
    lda pr_t,x
    tay
    lda proj_mf-1,y
    jsr draw_misc
    ldx tmp9
    lda pr_t,x
    cmp #3
    bcc @n
    ; sombra objetivo
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
proj_mf: .byte MF_PB, MF_EB, MF_SHELL, MF_BOMB

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
    lda fx_t,x
    lsr
    lsr
    lsr
    tay
    lda fx_seq,y
    jsr draw_misc
    ldx tmp9
@n:
    inx
    cpx #NFX
    bne @l
    rts
fx_seq: .byte MF_EX2, MF_EX1, MF_EX0

draw_go:
    lda go_t
    beq @r
    lda frame
    and #16
    beq @r
    lda #216
    sta sx_lo
    lda #0
    sta sx_hi
    lda #110
    sta sy
    lda #MF_GO
    jmp draw_misc
@r:
    rts
