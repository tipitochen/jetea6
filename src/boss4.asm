; =====================================================================
;  JEFES  (0 embestida, 1 estacion, 2 volador, 3 caminante)
; =====================================================================
;              blind moto swat heli robot jeep tank jet mecha super
boss_ai:   .byte 0,   0,   1,   2,   3,    0,   1,   2,  3,    1
boss_mask: .byte 1,   1,   1,   4,   2,    16,  3,   4,  2,    19
boss_w:    .byte 44,  36,  44,  40,  32,   44,  44,  44, 36,   44
boss_h:    .byte 30,  36,  38,  24,  44,   36,  36,  20, 44,   48
; paleta del jefe en P2 de sprites
boss_pal:
    ldx lvl_x
    lda level_tbl+14,x
    sta ptr
    lda level_tbl+15,x
    sta ptr+1
    ldy #1
@p:
    lda (ptr),y
    sta pal_buf+24,y
    iny
    cpy #4
    bne @p
    lda #1
    sta pal_dirty
    rts

boss_hp:   .byte 32,  35,  40,  38,  45,   45,  51,  48, 58,   72
boss_rt:   .byte 1,   1,   1,   0,   1,    1,   0,   0,  0,    0
bf_lo: .byte <boss0_f0,<boss0_f1,<boss1_f0,<boss1_f1,<boss2_f0,<boss2_f1,<boss3_f0,<boss3_f1,<boss4_f0,<boss4_f1
       .byte <boss5_f0,<boss5_f1,<boss6_f0,<boss6_f1,<boss7_f0,<boss7_f1,<boss8_f0,<boss8_f1,<boss9_f0,<boss9_f1
bf_hi: .byte >boss0_f0,>boss0_f1,>boss1_f0,>boss1_f1,>boss2_f0,>boss2_f1,>boss3_f0,>boss3_f1,>boss4_f0,>boss4_f1
       .byte >boss5_f0,>boss5_f1,>boss6_f0,>boss6_f1,>boss7_f0,>boss7_f1,>boss8_f0,>boss8_f1,>boss9_f0,>boss9_f1

boss_spawn:
    lda #1
    sta boss_on
    sta b_st
    ldx boss_id
    lda boss_ai,x
    sta b_ai
    lda boss_w,x
    sta b_w
    lda boss_h,x
    sta b_h
    lda boss_hp,x
    clc
    adc level
    sta b_hp
    sta b_hpmax
    lda boss_units,x
    sta chr_r45
    lda #28
    sta b_units
    jsr boss_pal
    lda cam_lo
    clc
    adc #44
    sta b_xlo
    lda cam_hi
    adc #1
    sta b_xhi
    lda #196
    sta b_y
    lda #0
    sta b_z
    sta b_inv
    sta b_flash
    sta b_vz
    lda b_ai
    cmp #2
    bne @nz
    lda #44
    sta b_z
    lda #150
    sta b_y
@nz:
    lda #1
    sta b_dir
    lda #60
    sta b_tm
    sta b_cd
    lda #2
    jmp mus_play

boss_dx:
    lda b_xlo
    sec
    sbc px_lo
    sta tmp0
    lda b_xhi
    sbc px_hi
    sta tmp1
    jmp abs16

boss_dy:
    lda b_y
    sec
    sbc py
    bcs @r
    eor #$FF
    adc #1
@r:
    rts

boss_face:
    lda b_xlo
    cmp px_lo
    lda b_xhi
    sbc px_hi
    lda #0
    bcc @r
    lda #1
@r:
    sta b_dir
    rts

boss_take:             ; A = dano
    sta tmp7
    lda b_inv
    bne @r
    lda #4
    sta b_inv
    lda #8
    sta b_flash
    lda b_hp
    sec
    sbc tmp7
    bcs @a
    lda #0
@a:
    sta b_hp
    bne @r
    lda #9
    sta b_st
    lda #160
    sta clear_t
    lda #5
    ldy #2
    jsr add_score
    lda #20
    sta shake
    lda #0
    sta pr_t
    sta pr_t+1
    sta pr_t+2
    sta pr_t+3
    sta pr_t+4
    sta pr_t+5
    sta pr_t+6
    sta pr_t+7
    jmp sfx_boom
@r:
    rts

; contacto: A = margen extra x, dano 4 y derribo
boss_contact:
    sta tmp8
    jsr boss_dx
    lda b_w
    lsr
    clc
    adc tmp8
    cmp tmp2
    bcc @r
    jsr boss_dy
    cmp #14
    bcs @r
    lda b_z
    sec
    sbc pz
    bcs @z
    eor #$FF
    adc #1
@z:
    cmp #24
    bcs @r
    lda tmp1
    rol
    lda #0
    rol
    eor #1
    sta tmp9
    lda #4
    ldy #1
    jmp player_hit
@r:
    rts

bmove_x:               ; A = velocidad con signo
    ldy #0
    cmp #$80
    bcc @p
    dey
@p:
    clc
    adc b_xlo
    sta b_xlo
    tya
    adc b_xhi
    sta b_xhi
    rts

bmove_y_to_player:
    lda frame
    and #1
    bne @r
    lda b_y
    cmp py
    beq @r
    bcc @d
    dec b_y
    rts
@d:
    inc b_y
@r:
    rts

bscreen_x:             ; A = x en pantalla del jefe (saturado), C=1 si fuera
    lda b_xlo
    sec
    sbc cam_lo
    sta tmp0
    lda b_xhi
    sbc cam_hi
    rts

b_fire_bullet:         ; A = carril y
    sta np_y
    lda b_z
    clc
    adc #14
    sta np_z
    lda #0
    sta np_vz
    lda b_dir
    bne @l
    lda b_xlo
    clc
    adc #20
    sta np_xlo
    lda b_xhi
    adc #0
    sta np_xhi
    lda #3
    bne @v
@l:
    lda b_xlo
    sec
    sbc #20
    sta np_xlo
    lda b_xhi
    sbc #0
    sta np_xhi
    lda #$FD
@v:
    sta np_vx
    lda #2
    jmp proj_spawn

b_fire_shell:          ; granada hacia el jugador
    lda px_lo
    sec
    sbc b_xlo
    sta tmp0
    lda px_hi
    sbc b_xhi
    ; vx = dx/32 con signo (aprox)
    cmp #$80
    ror
    ror tmp0
    cmp #$80
    ror
    ror tmp0
    cmp #$80
    ror
    ror tmp0
    cmp #$80
    ror
    ror tmp0
    cmp #$80
    ror
    ror tmp0
    lda tmp0
    sta np_vx
    lda b_xlo
    sta np_xlo
    lda b_xhi
    sta np_xhi
    lda py
    sta np_y
    lda b_z
    clc
    adc #26
    sta np_z
    lda #4
    sta np_vz
    lda #3
    jsr proj_spawn
    jmp sfx_shoot

b_drop_bomb:
    lda b_xlo
    sta np_xlo
    lda b_xhi
    sta np_xhi
    lda py
    sta np_y
    lda b_z
    clc
    adc #8
    sta np_z
    lda #0
    sta np_vz
    lda #0
    ldx b_dir
    beq @s
    lda #0
@s:
    sta np_vx
    lda #4
    jmp proj_spawn

boss_attack:           ; dispara segun mascara
    ldx boss_id
    lda boss_mask,x
    sta tmp10
    and #1
    beq @n1
    lda b_y
    jsr b_fire_bullet
@n1:
    lda tmp10
    and #16
    beq @n2
    lda b_y
    sec
    sbc #14
    jsr b_fire_bullet
    lda b_y
    clc
    adc #14
    jsr b_fire_bullet
    lda b_y
    jsr b_fire_bullet
@n2:
    lda tmp10
    and #2
    beq @n3
    jsr b_fire_shell
@n3:
    lda tmp10
    and #4
    beq @n4
    jsr b_drop_bomb
@n4:
    jmp sfx_shoot

boss_target:           ; carga el jugador vivo mas cercano; C=0 si no hay
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
    sbc b_xlo
    sta tmp0
    lda p_base+PO_XHI,y
    sbc b_xhi
    sta tmp1
    jsr abs16
    lda tmp2
    cmp tmp9
    bcs @n
    sta tmp9
    sty tmp10
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
    tax
    jsr load_player
    sec
    rts
@none:
    clc
    rts

boss_update:
    lda boss_on
    bne @on
    rts
@on:
    lda b_st
    cmp #9
    beq @tok
    jsr boss_target
    bcs @tok
    rts
@tok:
    lda b_inv
    beq @i
    dec b_inv
@i:
    lda b_flash
    beq @f
    dec b_flash
@f:
    inc b_anim
    lda b_anim
    lsr
    lsr
    lsr
    and #1
    sta b_fr
    lda b_st
    cmp #9
    bne @alive
    ; muerte: explosiones
    lda clear_t
    and #7
    bne @nx
    jsr rand
    and #31
    sec
    sbc #16
    ldy #0
    cmp #$80
    bcc @p
    dey
@p:
    clc
    adc b_xlo
    sta np_xlo
    tya
    adc b_xhi
    sta np_xhi
    jsr rand
    and #15
    clc
    adc b_y
    sec
    sbc #8
    sec
    sbc b_z
    sta np_y
    jsr fx_spawn
    jsr sfx_boom
    lda #4
    sta shake
@nx:
    dec clear_t
    bne @r
    lda #0
    sta boss_on
    jmp level_clear
@r:
    rts
@alive:
    cmp #1
    bne @fight
    ; entrada desde la derecha
    lda #$FE
    jsr bmove_x
    jsr bscreen_x
    bne @r
    lda tmp0
    cmp #196
    bcs @r
    lda #2
    sta b_st
    rts
@fight:
    lda b_ai
    asl
    tax
    lda bai_tbl+1,x
    pha
    lda bai_tbl,x
    pha
    rts
bai_tbl:
    .word ai_charge-1, ai_station-1, ai_fly-1, ai_walk-1

; ---- embestida (patrullero, moto, jeep)
ai_charge:
    lda b_st
    cmp #3
    beq @dash
    jsr boss_face
    jsr bmove_y_to_player
    dec b_cd
    bne @nc
    jsr boss_attack
    lda #24
    sec
    sbc level
    sta b_cd
@nc:
    lda #4
    jsr boss_contact
    dec b_tm
    bne @r
    lda #3
    sta b_st
    lda #4
    ldx b_dir
    beq @v
    lda #$FC
@v:
    sta b_vx
    lda boss_id
    cmp #1
    bne @r
    asl b_vx           ; la moto embiste mas rapido
@r:
    rts
@dash:
    lda b_vx
    jsr bmove_x
    lda #8
    jsr boss_contact
    jsr bscreen_x
    bmi @end
    bne @end
    lda tmp0
    cmp #24
    bcc @end
    cmp #232
    bcs @end
    rts
@end:
    ; volver dentro de pantalla
    lda b_vx
    eor #$FF
    clc
    adc #1
    jsr bmove_x
    lda #2
    sta b_st
    lda #100
    sta b_tm
    lda #25
    sta b_cd
    lda #4
    sta shake
    rts

; ---- estacion (SWAT, tanque, super tanque)
ai_station:
    jsr boss_face
    jsr bmove_y_to_player
    jsr bscreen_x
    lda tmp0
    cmp #200
    bcc @l
    lda #$FF
    jsr bmove_x
    jmp @cd
@l:
    cmp #180
    bcs @cd
    lda #1
    jsr bmove_x
@cd:
    lda #2
    jsr boss_contact
    dec b_cd
    bne @r
    jsr boss_attack
    ; rafaga extra del super tanque
    lda #80
    sec
    sbc level
    sbc level
    sbc level
    sta b_cd
@r:
    rts

; ---- voladores (helicoptero, avion)
ai_fly:
    lda boss_id
    cmp #7
    beq ai_jet
    ; helicoptero: sigue al jugador, baja de vez en cuando
    jsr boss_face
    lda b_anim
    and #128
    beq @a
    lda #56
    bne @b
@a:
    lda #$C8
@b:
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
    lda tmp0
    cmp b_xlo
    lda tmp1
    sbc b_xhi
    lda #1
    bcs @mv
    lda #$FF
@mv:
    jsr bmove_x
    jsr bmove_y_to_player
    ; altura: baja cada ~4 s
    lda b_anim
    and #$FF
    cmp #200
    bcc @hi
    lda b_z
    cmp #10
    bcc @z
    dec b_z
    jmp @z
@hi:
    lda b_z
    cmp #44
    bcs @z
    inc b_z
@z:
    dec b_cd
    bne @r
    jsr b_drop_bomb
    lda b_z
    cmp #20
    bcs @nb
    lda b_y
    jsr b_fire_bullet
@nb:
    lda #44
    sec
    sbc level
    sta b_cd
@r:
    lda #2
    jmp boss_contact

ai_jet:
    lda b_st
    cmp #4
    beq @wait
    lda #16
    sta b_z
    lda #3
    ldx b_dir
    beq @v
    lda #$FD
@v:
    jsr bmove_x
    dec b_cd
    bne @nb
    jsr b_drop_bomb
    lda #20
    sta b_cd
@nb:
    lda #2
    jsr boss_contact
    jsr bscreen_x
    lda tmp1
    beq @r
    ; fuera de pantalla
    lda #4
    sta b_st
    lda #60
    sta b_tm
@r:
    rts
@wait:
    dec b_tm
    bne @r
    lda py
    sta b_y
    lda b_dir
    eor #1
    sta b_dir
    lda #2
    sta b_st
    lda #20
    sta b_cd
    rts

; ---- caminantes (robot, mecha)
ai_walk:
    lda b_st
    cmp #5
    beq @slam
    cmp #6
    bne @w
    jmp @jump
@w:
    jsr boss_face
    jsr bmove_y_to_player
    jsr boss_dx
    lda tmp2
    cmp #34
    bcc @near
    lda frame
    and #1
    bne @nm
    lda #1
    ldx b_dir
    beq @mv
    lda #$FF
@mv:
    jsr bmove_x
@nm:
    jmp @cd
@near:
    jsr boss_dy
    cmp #12
    bcs @cd
    lda #5
    sta b_st
    lda #30
    sta b_tm
    rts
@cd:
    lda #0
    jsr boss_contact
    dec b_cd
    bne @r
    jsr boss_attack
    lda #137
    sta b_cd
    ; el mecha salta
    lda boss_id
    cmp #8
    bne @r
    lda #6
    sta b_st
    lda #6
    sta b_vz
    lda #2
    ldx b_dir
    beq @jv
    lda #$FE
@jv:
    sta b_vx
@r:
    rts
@slam:
    dec b_tm
    lda b_tm
    cmp #15
    bne @ns
    lda #10
    sta shake
    lda #14
    jsr boss_contact
    jsr sfx_boom
@ns:
    lda b_tm
    bne @r
    lda #2
    sta b_st
    rts
@jump:
    lda b_vx
    jsr bmove_x
    lda b_z
    clc
    adc b_vz
    sta b_z
    bmi @land
    lda frame
    and #3
    bne @r
    dec b_vz
    rts
@land:
    lda #0
    sta b_z
    lda #2
    sta b_st
    lda #12
    sta shake
    lda b_xlo
    sta np_xlo
    lda b_xhi
    sta np_xhi
    lda b_y
    sta np_y
    jsr fx_spawn
    jsr sfx_boom
    lda #16
    jmp boss_contact

draw_boss:
    lda b_st
    cmp #9
    bne @v
    lda frame
    and #2
    beq @v
    rts
@v:
    lda b_xlo
    sta tmp0
    lda b_xhi
    sta tmp1
    jsr world_sx
    lda b_z
    beq @ns
    lda b_y
    sta sy
    lda #MF_SHADOW
    jsr draw_misc
    jsr reset_draw
@ns:
    lda b_y
    sec
    sbc b_z
    sta sy
    ldx boss_id
    lda b_dir
    eor boss_rt,x
    bne @nf
    lda #$40
    sta sflip
@nf:
    lda b_flash
    and #2
    beq @nfl
    lda #1
    sta spal
@nfl:
    lda boss_id
    asl
    ora b_fr
    tax
    lda bf_lo,x
    sta fptr
    lda bf_hi,x
    sta fptr+1
    jmp draw_frame
