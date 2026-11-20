MF_CAR = 0
MF_MOTO = 1
MF_EX0 = 2
MF_EX1 = 3
MF_EX2 = 4
MF_PB = 5
MF_EB = 6
MF_FLASH = 7
MF_SHADOW = 8
MF_SHELL = 9
MF_BOMB = 10
MF_GO = 11
MF_AB = 12
MF_BAG = 13
LEVEL_MC = 112
level_tbl:
    .word lvl0_seq, lvl0_pal, lvl0_waves, lvl0_veh, blk_A, street_A, far_A, lvl0_bpal
    .byte 2, 10, 0, 1, 0, 0, 0, 0
    .word lvl1_seq, lvl1_pal, lvl1_waves, lvl1_veh, blk_B, street_B, far_B, lvl1_bpal
    .byte 4, 12, 0, 1, 1, 0, 0, 0
    .word lvl2_seq, lvl2_pal, lvl2_waves, lvl2_veh, blk_C, street_C, far_C, lvl2_bpal
    .byte 6, 14, 0, 2, 2, 0, 0, 0
    .word lvl3_seq, lvl3_pal, lvl3_waves, lvl3_veh, blk_A, street_A, far_A, lvl3_bpal
    .byte 2, 10, 0, 2, 3, 0, 0, 0
    .word lvl4_seq, lvl4_pal, lvl4_waves, lvl4_veh, blk_B, street_B, far_B, lvl4_bpal
    .byte 4, 12, 0, 3, 4, 0, 0, 0
    .word lvl5_seq, lvl5_pal, lvl5_waves, lvl5_veh, blk_C, street_C, far_C, lvl5_bpal
    .byte 6, 14, 1, 3, 5, 0, 0, 0
    .word lvl6_seq, lvl6_pal, lvl6_waves, lvl6_veh, blk_A, street_A, far_A, lvl6_bpal
    .byte 2, 10, 1, 4, 6, 0, 0, 0
    .word lvl7_seq, lvl7_pal, lvl7_waves, lvl7_veh, blk_D, street_D, far_D, lvl7_bpal
    .byte 8, 16, 1, 4, 7, 0, 0, 0
    .word lvl8_seq, lvl8_pal, lvl8_waves, lvl8_veh, blk_B, street_B, far_B, lvl8_bpal
    .byte 4, 12, 1, 5, 8, 0, 0, 0
    .word lvl9_seq, lvl9_pal, lvl9_waves, lvl9_veh, blk_D, street_D, far_D, lvl9_bpal
    .byte 8, 16, 1, 5, 9, 0, 0, 0
chr_sets:
UNIT_COP = 34
UNIT_SOLDIER = 36
UNIT_MISC = 38
boss_units: .byte 39,41,43,45,47,49,51,53,55,57
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
bname_tbl:
    .word bname0,bname1,bname2,bname3,bname4,bname5,bname6,bname7,bname8,bname9
bname0:
    .str $2246, "PATRULLERO BLINDADO"
    .byte 0
bname1:
    .str $224A, "MOTO-POLICIA"
    .byte 0
bname2:
    .str $224A, "CAMION SWAT"
    .byte 0
bname3:
    .str $224A, "HELICOPTERO"
    .byte 0
bname4:
    .str $2247, "ROBOT ANTIMOTINES"
    .byte 0
bname5:
    .str $2249, "JEEP ARTILLADO"
    .byte 0
bname6:
    .str $224D, "TANQUE"
    .byte 0
bname7:
    .str $2248, "AVION DE ATAQUE"
    .byte 0
bname8:
    .str $2249, "MECHA MILITAR"
    .byte 0
bname9:
    .str $224A, "SUPER TANQUE"
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

