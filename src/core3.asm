; ---------------------------------------------------------------- nucleo
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
    lda #0
    sta $A000
    lda #$80
    sta $A001
    lda #6
    sta $8000
    lda #0
    sta $8001
    lda #7
    sta $8000
    lda #1
    sta $8001
    lda #0
    sta chr_r0
    lda #18
    sta chr_r1
    lda #20
    sta chr_r2
    lda #UNIT_MISC
    sta chr_r3
    lda #UNIT_COP
    sta chr_r45
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
    .word st_title-1, st_select-1, st_cut-1, st_intro-1, st_play-1, st_clear-1, st_wait_start-1, st_wait_start-1

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
    sta str_pending
    sta $E000
    sta PPUMASK
    rts

ppu_enable:
    lda #1
    sta ppu_on
    jsr wait_nmi
    rts

clear_nt:              ; A = valor de relleno
    pha
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #0
    sta PPUADDR
    pla
    ldy #8
    ldx #0
@l:
    sta PPUDATA
    inx
    bne @l
    dey
    bne @l
    rts

draw_strings:
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

draw_ptr:
    sta ptr
    stx ptr+1
    jmp draw_strings

load_palette:
    ldy #31
@l:
    lda (ptr),y
    sta pal_buf,y
    dey
    bpl @l
    lda #1
    sta pal_dirty
    rts

load_pal_ptr:
    sta ptr
    stx ptr+1
    jmp load_palette

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

write_score:
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

write_level_num:
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

write_stars:           ; tiles $47 llena / $48 vacia (pagina de menus)
    ldx #0
@l:
    lda #$48
    cpx stars
    bcs @e
    lda #$47
@e:
    sta PPUDATA
    inx
    cpx #5
    bne @l
    rts

add_score:             ; A=cantidad Y=digito
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

queue_line:            ; A=fila, ptr -> [len, texto], centrado sobre barra negra (tile tfill)
    pha
    ldx #31
    lda tfill
@c:
    sta str_buf,x
    dex
    bpl @c
    ldy #0
    lda (ptr),y
    sta tmp0
    lda #32
    sec
    sbc tmp0
    lsr
    tax
    iny
@t:
    lda (ptr),y
    sta str_buf,x
    inx
    iny
    dec tmp0
    bne @t
    pla
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
    ora #$20
    sta str_hi
    lda #1
    sta str_pending
    rts
tfill = $8F

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
    lda str_pending
    beq @nostr
    bit PPUSTATUS
    lda str_hi
    sta PPUADDR
    lda str_lo
    sta PPUADDR
    ldx #0
@sl:
    lda str_buf,x
    sta PPUDATA
    inx
    cpx #32
    bne @sl
    lda #0
    sta str_pending
@nostr:
    lda game_irq
    beq @nohud
    jsr nmi_hud
@nohud:
    ; bancos CHR
    lda #0
    sta $8000
    lda chr_r0
    sta $8001
    lda #1
    sta $8000
    lda chr_r1
    sta $8001
    lda #2
    sta $8000
    lda chr_r2
    sta $8001
    lda #3
    sta $8000
    lda chr_r3
    sta $8001
    lda #4
    sta $8000
    lda chr_r45
    sta $8001
    lda #5
    sta $8000
    lda chr_r45
    clc
    adc #1
    sta $8001
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
    lda cam_hi
    sta tmp7
    lda cam_lo
    lsr tmp7
    ror
    lsr tmp7
    ror
    sta far_x
    lda tmp7
    and #1
    ora ctrl_base
    sta far_ctrl
    lda cam_lo
    ldx shake
    beq @nsh
    dec shake
    lda frame
    and #2
    asl
    clc
    adc cam_lo
@nsh:
    sta irq_x
    lda cam_hi
    and #1
    ora ctrl_base
    sta irq_ctrl
    lda #0
    sta irq_stage
    sta $E000
    lda #IRQ_L1
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

irq:
    pha
    sta $E000
    lda irq_stage
    bne @s1
    lda far_x
    sta PPUSCROLL
    lda #0
    sta PPUSCROLL
    lda far_ctrl
    sta PPUCTRL
    lda #IRQ_L2
    sta $C000
    sta $C001
    sta $E001
    inc irq_stage
    pla
    rti
@s1:
    lda irq_x
    sta PPUSCROLL
    lda #0
    sta PPUSCROLL
    lda irq_ctrl
    sta PPUCTRL
    pla
    rti

nmi_column:            ; 22 tiles desde fila 8
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
    cpx #22
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
    adc #$D0
    adc attr_col
    sta PPUADDR
    lda attr_buf,x
    sta PPUDATA
    inx
    cpx #6
    bne @a
    lda #0
    sta attr_pending
@done:
    lda #0
    sta col_pending
    rts

; HUD: corridas (direccion, largo) desde hud_buf
hud_runs:
    .byte $20, $29, 8
    .byte $20, $33, 1
    .byte $20, $37, 6
    .byte $20, $47, 6
    .byte $20, $4F, 12
nmi_hud:
    ldx #0
    ldy #0
@r:
    lda hud_runs,y
    sta PPUADDR
    lda hud_runs+1,y
    sta PPUADDR
    lda hud_runs+2,y
    sta tmp7
@c:
    lda hud_buf,x
    sta PPUDATA
    inx
    dec tmp7
    bne @c
    iny
    iny
    iny
    cpy #15
    bne @r
    rts

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
    lda #0
    jmp mus_play

mus_play:
    cmp track
    bne @go
    lda mus_on
    bne @r
    lda track
@go:
    sta track
    asl
    sta tmp0
    asl
    clc
    adc tmp0
    tax
    lda #0
    sta mus_on
    ldy #0
@c:
    lda track_tbl,x
    sta mus_p,y
    sta mus_sp,y
    inx
    iny
    cpy #6
    bne @c
    lda #1
    sta mus_cp
    sta mus_ct
    sta mus_cn
    sta mus_on
    lda #$30
    sta $4000
    lda #$80
    sta $4008
@r:
    rts

music_update:
    lda sfx_timer
    beq @st
    dec sfx_timer
@st:
    lda mus_on
    beq @off
    dec mus_cp
    bne @t
    ldx #0
    jsr mus_fetch
    sty mus_cp
    tax
    bne @pp
    lda #$30
    sta $4000
    jmp @t
@pp:
    lda #$86
    sta $4000
    lda note_lo,x
    sta $4002
    lda note_hi,x
    ora #$08
    sta $4003
@t:
    dec mus_ct
    bne @n
    ldx #2
    jsr mus_fetch
    sty mus_ct
    tax
    bne @tp
    lda #$80
    sta $4008
    sta $400B
    jmp @n
@tp:
    lda #$30
    sta $4008
    lda note_lo,x
    sta $400A
    lda note_hi,x
    ora #$08
    sta $400B
@n:
    dec mus_cn
    bne @off
    ldx #4
    jsr mus_fetch
    sty mus_cn
    ldx sfx_timer
    bne @off
    tax
    beq @off
    lda drum_c-1,x
    sta $400C
    lda drum_e-1,x
    sta $400E
    lda drum_f-1,x
    sta $400F
@off:
    rts
drum_c: .byte $1C, $1A, $14
drum_e: .byte $0C, $06, $02
drum_f: .byte $28, $38, $18

mus_fetch:
    lda (mus_p,x)
    cmp #$FF
    bne @ok
    lda mus_sp,x
    sta mus_p,x
    lda mus_sp+1,x
    sta mus_p+1,x
    jmp mus_fetch
@ok:
    pha
    jsr @inc
    lda (mus_p,x)
    tay
    jsr @inc
    pla
    rts
@inc:
    inc mus_p,x
    bne @r
    inc mus_p+1,x
@r:
    rts

sfx_shoot:
    lda #$84
    sta $4004
    lda #$8B
    sta $4005
    lda #$40
    sta $4006
    lda #$08
    sta $4007
    rts
sfx_punch:
    lda #$02
    sta $400C
    lda #$0A
    sta $400E
    lda #$08
    sta $400F
    lda #6
    sta sfx_timer
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
    lda #$0F
    sta $400C
    lda #$0D
    sta $400E
    lda #$08
    sta $400F
    lda #40
    sta sfx_timer
    rts
sfx_hit:
    lda #$04
    sta $400C
    lda #$06
    sta $400E
    lda #$08
    sta $400F
    lda #10
    sta sfx_timer
    rts

; ---------------------------------------------------------------- metasprites
; fptr -> [n, (dy dx tile attr)*n]; sx_lo/hi, sy (pies), sflip ($00/$40), spal (eor), stile (suma), sremap
draw_frame:
    ldy #0
    lda (fptr),y
    bne @go
    rts
@go:
    sta fcount
    iny
@e:
    lda oam_full
    beq @ok
    rts
@ok:
    lda (fptr),y
    sta tmp4               ; dy
    iny
    lda (fptr),y
    sta tmp5               ; dx
    iny
    lda (fptr),y
    sta tmp6               ; tile
    iny
    lda (fptr),y
    sta tmp7               ; attr
    iny
    ; y
    lda sy
    clc
    adc tmp4
    bcc @skip
    cmp #232
    bcs @skip
    sta tmp4
    ; x
    lda tmp5
    ldx sflip
    beq @nf
    eor #$FF
    sec
    sbc #7
@nf:
    sta tmp5
    clc
    adc sx_lo
    sta tmp3
    lda tmp5
    and #$80
    beq @p
    lda #$FF
@p:
    adc sx_hi
    bne @skip
    ; atributo
    lda tmp7
    ldx sremap
    beq @nr
    cmp #1
    bne @nr
    lda #2
@nr:
    eor sflip
    eor spal
    sta tmp7
    ldx oam_i
    lda tmp4
    sec
    sbc #1
    sta OAM,x
    lda tmp6
    clc
    adc stile
    sta OAM+1,x
    lda tmp7
    sta OAM+2,x
    lda tmp3
    sta OAM+3,x
    txa
    clc
    adc #4
    sta oam_i
    bne @skip
    inc oam_full
    rts
@skip:
    dec fcount
    beq @__n855_0
    jmp @e
@__n855_0:
    rts

; preparar dibujo: X = mundo lo, A = mundo hi en tmp... ayudante
world_sx:              ; tmp0/tmp1 = x mundo -> sx_lo/hi
    lda tmp0
    sec
    sbc cam_lo
    sta sx_lo
    lda tmp1
    sbc cam_hi
    sta sx_hi
    rts

reset_draw:
    lda #0
    sta sflip
    sta spal
    sta stile
    sta sremap
    rts

; dibuja cuadro de 'misc' A = indice
draw_misc:
    tax
    lda misc_lo,x
    sta fptr
    lda misc_hi,x
    sta fptr+1
    jmp draw_frame
