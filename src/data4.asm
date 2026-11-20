MF_PB = 0
MF_EB = 1
MF_FLASH = 2
MF_SHADOW = 3
MF_EX0 = 4
MF_EX1 = 5
MF_AB = 6
MF_ROCKET = 7
MF_SIREN = 8
MF_ARROW = 9
MF_PLANE = 10
BX_BAR0 = 0
BX_BAR1 = 1
BX_BAR2 = 2
BX_BAR3 = 3
BX_BAR4 = 4
BX_SHELL = 5
BX_BOMB = 6
LEVEL_MC = 112
level_tbl:
    .word lvl0_seq, lvl0_pal, lvl0_waves, lvl0_veh, blk_A, street_A, far_A, lvl0_bpal, lvl0_weap, wtile_A
    .byte 2, 10, 0, 1, 0
    .word lvl1_seq, lvl1_pal, lvl1_waves, lvl1_veh, blk_B, street_B, far_B, lvl1_bpal, lvl1_weap, wtile_B
    .byte 4, 12, 0, 1, 1
    .word lvl2_seq, lvl2_pal, lvl2_waves, lvl2_veh, blk_C, street_C, far_C, lvl2_bpal, lvl2_weap, wtile_C
    .byte 6, 14, 0, 2, 2
    .word lvl3_seq, lvl3_pal, lvl3_waves, lvl3_veh, blk_A, street_A, far_A, lvl3_bpal, lvl3_weap, wtile_A
    .byte 2, 10, 0, 2, 3
    .word lvl4_seq, lvl4_pal, lvl4_waves, lvl4_veh, blk_B, street_B, far_B, lvl4_bpal, lvl4_weap, wtile_B
    .byte 4, 12, 0, 3, 4
    .word lvl5_seq, lvl5_pal, lvl5_waves, lvl5_veh, blk_C, street_C, far_C, lvl5_bpal, lvl5_weap, wtile_C
    .byte 6, 14, 1, 3, 5
    .word lvl6_seq, lvl6_pal, lvl6_waves, lvl6_veh, blk_A, street_A, far_A, lvl6_bpal, lvl6_weap, wtile_A
    .byte 2, 10, 1, 4, 6
    .word lvl7_seq, lvl7_pal, lvl7_waves, lvl7_veh, blk_D, street_D, far_D, lvl7_bpal, lvl7_weap, wtile_D
    .byte 8, 16, 1, 4, 7
    .word lvl8_seq, lvl8_pal, lvl8_waves, lvl8_veh, blk_B, street_B, far_B, lvl8_bpal, lvl8_weap, wtile_B
    .byte 4, 12, 1, 5, 8
    .word lvl9_seq, lvl9_pal, lvl9_waves, lvl9_veh, blk_D, street_D, far_D, lvl9_bpal, lvl9_weap, wtile_D
    .byte 8, 16, 1, 5, 9
UNIT_COP = 55
UNIT_SOLDIER = 57
boss_units: .byte 59,61,63,65,67,69,71,73,75,77
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

TITLE_UNIT = 120
TITLE_SPLIT = 13
