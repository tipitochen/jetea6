THUG_TILE = 48
MOTO_TILE = 60
BOSS_TILE = 68
EXPL_TILE = 80
PB_TILE = 84
EB_TILE = 85
ARROW_TILE = 86
T_GTOP = $80
T_GFILL = $81
T_PLAT = $82
T_WIN = $83
T_WALL = $84
T_ROOF = $85
T_WATER = $86
LEVEL_LEN = 160
level_tbl:
    .word lvl0_cols
    .byte LEVEL_LEN
    .word lvl0_spawn
    .byte 2
    .word pal_lvl0
    .word lvl1_cols
    .byte LEVEL_LEN
    .word lvl1_spawn
    .byte 2
    .word pal_lvl1
    .word lvl2_cols
    .byte LEVEL_LEN
    .word lvl2_spawn
    .byte 4
    .word pal_lvl2
    .word lvl3_cols
    .byte LEVEL_LEN
    .word lvl3_spawn
    .byte 2
    .word pal_lvl3
    .word lvl4_cols
    .byte LEVEL_LEN
    .word lvl4_spawn
    .byte 4
    .word pal_lvl4
    .word lvl5_cols
    .byte LEVEL_LEN
    .word lvl5_spawn
    .byte 2
    .word pal_lvl5
    .word lvl6_cols
    .byte LEVEL_LEN
    .word lvl6_spawn
    .byte 2
    .word pal_lvl6
    .word lvl7_cols
    .byte LEVEL_LEN
    .word lvl7_spawn
    .byte 4
    .word pal_lvl7
    .word lvl8_cols
    .byte LEVEL_LEN
    .word lvl8_spawn
    .byte 4
    .word pal_lvl8
    .word lvl9_cols
    .byte LEVEL_LEN
    .word lvl9_spawn
    .byte 2
    .word pal_lvl9
pal_lvl0:
    .byte $21,$35,$1C,$30,$21,$07,$37,$2C,$21,$30,$10,$00,$21,$30,$16,$28
    .byte $21,$0F,$37,$2A,$21,$0F,$37,$16,$21,$0F,$30,$16,$21,$0F,$10,$27
pal_lvl1:
    .byte $22,$27,$17,$38,$22,$00,$10,$2A,$22,$30,$10,$00,$22,$30,$16,$28
    .byte $22,$0F,$37,$2A,$22,$0F,$37,$16,$22,$0F,$30,$16,$22,$0F,$10,$27
pal_lvl2:
    .byte $26,$13,$0F,$25,$26,$0F,$00,$2C,$26,$30,$10,$00,$26,$30,$16,$28
    .byte $26,$0F,$37,$2A,$26,$0F,$37,$16,$26,$0F,$30,$16,$26,$0F,$10,$27
pal_lvl3:
    .byte $31,$3A,$1A,$30,$31,$07,$37,$2C,$31,$30,$10,$00,$31,$30,$16,$28
    .byte $31,$0F,$37,$2A,$31,$0F,$37,$16,$31,$0F,$30,$16,$31,$0F,$10,$27
pal_lvl4:
    .byte $14,$04,$28,$13,$14,$0F,$00,$28,$14,$30,$10,$00,$14,$30,$16,$28
    .byte $14,$0F,$37,$2A,$14,$0F,$37,$16,$14,$0F,$30,$16,$14,$0F,$10,$27
pal_lvl5:
    .byte $3B,$1A,$0A,$29,$3B,$0A,$19,$2C,$3B,$30,$10,$00,$3B,$30,$16,$28
    .byte $3B,$0F,$37,$2A,$3B,$0F,$37,$16,$3B,$0F,$30,$16,$3B,$0F,$10,$27
pal_lvl6:
    .byte $34,$2C,$1C,$30,$34,$07,$37,$2C,$34,$30,$10,$00,$34,$30,$16,$28
    .byte $34,$0F,$37,$2A,$34,$0F,$37,$16,$34,$0F,$30,$16,$34,$0F,$10,$27
pal_lvl7:
    .byte $11,$10,$00,$30,$11,$0F,$00,$30,$11,$30,$10,$00,$11,$30,$16,$28
    .byte $11,$0F,$37,$2A,$11,$0F,$37,$16,$11,$0F,$30,$16,$11,$0F,$10,$27
pal_lvl8:
    .byte $0F,$02,$28,$12,$0F,$0F,$00,$24,$0F,$30,$10,$00,$0F,$30,$16,$28
    .byte $0F,$0F,$37,$2A,$0F,$0F,$37,$16,$0F,$0F,$30,$16,$0F,$0F,$10,$27
pal_lvl9:
    .byte $01,$13,$0F,$25,$01,$0F,$03,$24,$01,$30,$10,$00,$01,$30,$16,$28
    .byte $01,$0F,$37,$2A,$01,$0F,$37,$16,$01,$0F,$30,$16,$01,$0F,$10,$27
skyline:
    .byte $0E,$0E,$0E,$0E,$0E,$1E,$0C,$0C,$0C,$0C,$0C,$0C,$1E,$0A,$0A,$0A
    .byte $0A,$1E,$1E,$0C,$0C,$0C,$0C,$0C,$0C,$1E,$1E,$12,$12,$12,$1E,$0C
name_tbl:
    .word name0,name1,name2,name3,name4,name5,name6,name7,name8,name9
name0:
    .str $21EB, "PLAYA VICE"
    .byte 0
name1:
    .str $21EB, "CALLE OCHO"
    .byte 0
name2:
    .str $21E9, "PUERTO DEL SOL"
    .byte 0
name3:
    .str $21EB, "LOS CAYOS"
    .byte 0
name4:
    .str $21EA, "AUTOPISTA 95"
    .byte 0
name5:
    .str $21EA, "LOS PANTANOS"
    .byte 0
name6:
    .str $21E7, "DISTRITO ART DECO"
    .byte 0
name7:
    .str $21EB, "AEROPUERTO"
    .byte 0
name8:
    .str $21E8, "CENTRO NOCTURNO"
    .byte 0
name9:
    .str $21EB, "LA MANSION"
    .byte 0
sun_strs:
    .strb $21CD, $43,$43,$43,$43,$43,$43
    .strb $21EB, $43,$43,$43,$43,$43,$43,$43,$43,$43,$43
    .strb $220A, $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44
    .strb $2229, $42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42,$42
    .strb $2249, $45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45
    .strb $2268, $41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41
    .byte 0
logo_strs:
    .strb $20A4, $00,$43,$43,$43,$00,$00,$43,$43,$43,$43,$43,$00,$00,$43,$43,$43,$00,$00,$00,$00,$43,$43,$00
    .strb $20C4, $43,$00,$00,$00,$43,$00,$00,$00,$43,$00,$00,$00,$43,$00,$00,$00,$43,$00,$00,$43,$00,$00,$00
    .strb $20E4, $44,$00,$00,$00,$00,$00,$00,$00,$44,$00,$00,$00,$44,$00,$00,$00,$44,$00,$44,$00,$00,$00,$00
    .strb $2104, $42,$00,$42,$42,$42,$00,$00,$00,$42,$00,$00,$00,$42,$42,$42,$42,$42,$00,$42,$42,$42,$42,$00
    .strb $2124, $45,$00,$00,$00,$45,$00,$00,$00,$45,$00,$00,$00,$45,$00,$00,$00,$45,$00,$45,$00,$00,$00,$45
    .strb $2144, $41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$41,$00,$00,$00,$41
    .strb $2164, $00,$41,$41,$41,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$00,$41,$00,$00,$41,$41,$41,$00
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
