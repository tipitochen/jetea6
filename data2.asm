V_MOTO = 64
V_CAR = 80
V_POL = 104
M_HELI = 192
M_ROTOR = 204
M_EXPL = 216
M_PB = 228
M_EB = 229
M_FLASH = 230
M_SIREN = 231
M_ARROW = 232
M_BAG = 233
M_DUST = 237
M_AB = 239
LEVEL_LEN = 160
FAR_TILE = 160
T_GTOP = $80
T_GSUB = $81
T_G1 = $82
T_G2 = $83
T_PLAT = $84
T_WTOP = $85
T_WATER = $86
T_ROOF1 = $87
T_WALL1 = $88
T_WIN1A = $89
T_WIN1B = $8A
T_ROOF2 = $8B
T_WALL2 = $8C
T_WIN2A = $8D
T_WIN2B = $8E
T_P_TL = $8F
T_P_TR = $90
T_P_BL = $91
T_P_BR = $92
T_TR_L = $93
T_TR_R = $94
level_tbl:
    .word lvl0_cols
    .byte LEVEL_LEN
    .word lvl0_spawn
    .byte 16
    .word pal_lvl0
    .byte 0
    .word far_A
    .byte 1, 0, 0, 0, 0
    .word lvl1_cols
    .byte LEVEL_LEN
    .word lvl1_spawn
    .byte 16
    .word pal_lvl1
    .byte 0
    .word far_A
    .byte 1, 0, 0, 0, 0
    .word lvl2_cols
    .byte LEVEL_LEN
    .word lvl2_spawn
    .byte 24
    .word pal_lvl2
    .byte 0
    .word far_B
    .byte 2, 0, 0, 0, 0
    .word lvl3_cols
    .byte LEVEL_LEN
    .word lvl3_spawn
    .byte 16
    .word pal_lvl3
    .byte 0
    .word far_A
    .byte 2, 0, 0, 0, 0
    .word lvl4_cols
    .byte LEVEL_LEN
    .word lvl4_spawn
    .byte 24
    .word pal_lvl4
    .byte 0
    .word far_B
    .byte 3, 0, 0, 0, 0
    .word lvl5_cols
    .byte LEVEL_LEN
    .word lvl5_spawn
    .byte 16
    .word pal_lvl5
    .byte 1
    .word far_A
    .byte 3, 0, 0, 0, 0
    .word lvl6_cols
    .byte LEVEL_LEN
    .word lvl6_spawn
    .byte 16
    .word pal_lvl6
    .byte 1
    .word far_A
    .byte 4, 0, 0, 0, 0
    .word lvl7_cols
    .byte LEVEL_LEN
    .word lvl7_spawn
    .byte 24
    .word pal_lvl7
    .byte 1
    .word far_B
    .byte 4, 0, 0, 0, 0
    .word lvl8_cols
    .byte LEVEL_LEN
    .word lvl8_spawn
    .byte 24
    .word pal_lvl8
    .byte 1
    .word far_B
    .byte 5, 0, 0, 0, 0
    .word lvl9_cols
    .byte LEVEL_LEN
    .word lvl9_spawn
    .byte 16
    .word pal_lvl9
    .byte 1
    .word far_A
    .byte 5, 0, 0, 0, 0
pal_lvl0:
    .byte $21,$35,$1C,$30,$21,$07,$37,$2C,$21,$13,$2A,$30,$21,$30,$16,$28
    .byte $21,$0F,$27,$2A,$21,$0F,$27,$18,$21,$0F,$27,$12,$21,$0F,$30,$16
pal_lvl1:
    .byte $22,$27,$17,$38,$22,$00,$10,$2A,$22,$02,$29,$30,$22,$30,$16,$28
    .byte $22,$0F,$27,$2A,$22,$0F,$27,$18,$22,$0F,$27,$12,$22,$0F,$30,$16
pal_lvl2:
    .byte $26,$13,$0F,$25,$26,$0F,$00,$2C,$26,$04,$28,$36,$26,$30,$16,$28
    .byte $26,$0F,$27,$2A,$26,$0F,$27,$18,$26,$0F,$27,$12,$26,$0F,$30,$16
pal_lvl3:
    .byte $31,$3A,$1A,$30,$31,$07,$37,$2C,$31,$1B,$2A,$30,$31,$30,$16,$28
    .byte $31,$0F,$27,$2A,$31,$0F,$27,$18,$31,$0F,$27,$12,$31,$0F,$30,$16
pal_lvl4:
    .byte $14,$04,$28,$13,$14,$0F,$00,$28,$14,$03,$28,$24,$14,$30,$16,$28
    .byte $14,$0F,$27,$2A,$14,$0F,$27,$18,$14,$0F,$27,$12,$14,$0F,$30,$16
pal_lvl5:
    .byte $3B,$1A,$0A,$29,$3B,$0A,$19,$2C,$3B,$09,$2A,$30,$3B,$30,$16,$28
    .byte $3B,$0F,$27,$2A,$3B,$0F,$27,$18,$3B,$0F,$27,$1A,$3B,$0F,$30,$16
pal_lvl6:
    .byte $34,$2C,$1C,$30,$34,$07,$37,$2C,$34,$14,$2A,$30,$34,$30,$16,$28
    .byte $34,$0F,$27,$2A,$34,$0F,$27,$18,$34,$0F,$27,$1A,$34,$0F,$30,$16
pal_lvl7:
    .byte $11,$10,$00,$30,$11,$0F,$00,$30,$11,$01,$28,$31,$11,$30,$16,$28
    .byte $11,$0F,$27,$2A,$11,$0F,$27,$18,$11,$0F,$27,$1A,$11,$0F,$30,$16
pal_lvl8:
    .byte $0F,$02,$28,$12,$0F,$0F,$00,$24,$0F,$01,$28,$13,$0F,$30,$16,$28
    .byte $0F,$0F,$27,$2A,$0F,$0F,$27,$18,$0F,$0F,$27,$1A,$0F,$0F,$30,$16
pal_lvl9:
    .byte $01,$13,$0F,$25,$01,$0F,$03,$24,$01,$0F,$2A,$12,$01,$30,$16,$28
    .byte $01,$0F,$27,$2A,$01,$0F,$27,$18,$01,$0F,$27,$1A,$01,$0F,$30,$16
skyline:
    .byte $8F,$8F,$8F,$8F,$8F,$8F,$1E,$1E,$0A,$0A,$0A,$0A,$0A,$0A,$1E,$1E
    .byte $12,$12,$12,$12,$12,$12,$1E,$1E,$91,$91,$91,$91,$1E,$1E,$1E,$1E
name_tbl:
    .word name0,name1,name2,name3,name4,name5,name6,name7,name8,name9
name0:
    .str $21CB, "PLAYA VICE"
    .byte 0
name1:
    .str $21CB, "CALLE OCHO"
    .byte 0
name2:
    .str $21C9, "PUERTO DEL SOL"
    .byte 0
name3:
    .str $21CB, "LOS CAYOS"
    .byte 0
name4:
    .str $21CA, "AUTOPISTA 95"
    .byte 0
name5:
    .str $21CA, "LOS PANTANOS"
    .byte 0
name6:
    .str $21C7, "DISTRITO ART DECO"
    .byte 0
name7:
    .str $21CB, "AEROPUERTO"
    .byte 0
name8:
    .str $21C8, "CENTRO NOCTURNO"
    .byte 0
name9:
    .str $21CB, "LA MANSION"
    .byte 0
logo_strs:
    .strb $2084, $00,$43,$43,$43,$00,$00,$43,$43,$43,$43,$43,$00,$00,$43,$43,$43,$00,$00,$00,$00,$43,$43,$00
    .strb $20A4, $43,$00,$00,$00,$43,$00,$00,$00,$43,$00,$00,$00,$43,$00,$00,$00,$43,$00,$00,$43,$00,$00,$00
    .strb $20C4, $44,$00,$00,$00,$00,$00,$00,$00,$44,$00,$00,$00,$44,$00,$00,$00,$44,$00,$44,$00,$00,$00,$00
    .strb $20E4, $42,$00,$42,$42,$42,$00,$00,$00,$42,$00,$00,$00,$42,$42,$42,$42,$42,$00,$42,$42,$42,$42,$00
    .strb $2104, $45,$00,$00,$00,$45,$00,$00,$00,$45,$00,$00,$00,$45,$00,$00,$00,$45,$00,$45,$00,$00,$00,$45
    .strb $2124, $41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$41,$00,$00,$00,$41
    .strb $2144, $00,$41,$41,$41,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$41,$41,$41,$00
    .byte 0
sun_strs:
    .strb $21CD, $43,$43,$43,$43,$43,$43
    .strb $21EB, $49,$49,$49,$49,$49,$49,$49,$49,$49,$49
    .strb $220A, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
    .strb $2229, $4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A,$4A
    .strb $2249, $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45
    .strb $2268, $4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
    .byte 0
note_lo:
    .byte 0
    .byte $AD,$4D,$F3,$9D,$4C,$00,$B8,$74,$34,$F8,$BF,$89,$56,$26,$F9,$CE
    .byte $A6,$80,$5C,$3A,$1A,$FB,$DF,$C4,$AB,$93,$7C,$67,$52,$3F,$2D,$1C
    .byte $0C,$FD,$EF,$E1,$D5,$C9,$BD,$B3,$A9,$9F,$96,$8E,$86,$7E,$77,$70
    .byte $6A,$64,$5E,$59,$54,$4F,$4B,$46,$42,$3F,$3B,$38
note_hi:
    .byte 0
    .byte $06,$06,$05,$05,$05,$05,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02
    .byte $02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
