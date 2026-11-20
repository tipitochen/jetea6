; ---- datos del ARSENAL ----
ARS_ARROW = 32
ars_units: .byte 128,131,134,137,140,143,146,149,152,155,158,161,164,167,170,173,176,179
ars_sunit: .byte 182,186
ars_seq: .byte 0,1,2,3,4,5,6,7,8,7,6,5,4,3,2,1
ars_pal0: .byte $0F,$27,$17,$30,$0F,$27,$17,$2C,$0F,$27,$30,$2C,$0F,$30,$17,$2C,$0F,$27,$17,$30,$0F,$27,$17,$2C,$0F,$27,$30,$2C,$0F,$0F,$30,$16
ars_pal1: .byte $0F,$27,$17,$30,$0F,$27,$17,$25,$0F,$27,$30,$25,$0F,$30,$17,$25,$0F,$27,$17,$30,$0F,$27,$17,$25,$0F,$27,$30,$25,$0F,$0F,$30,$16
ars_attr:
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$80,$00,$00,$FF,$FF,$FF,$FF,$FF,$84,$AA,$20,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$80,$20,$00,$FF,$FF,$FF,$FF,$FF,$84,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$20,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$20,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$20,$00,$FF,$FF,$FF,$FF,$FF,$00,$2A,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$80,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$80,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$80,$20,$FF,$FF,$FF,$FF,$FF,$00,$AA,$21,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$20,$FF,$FF,$FF,$FF,$FF,$80,$AA,$21,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$10,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$11,$FF,$FF,$FF,$FF,$FF,$00,$0A,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$10,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$A6,$11,$FF,$FF,$FF,$FF,$FF,$00,$0A,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$10,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$02,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$10,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$02,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$10,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$85,$00,$FF,$FF,$FF,$FF,$FF,$00,$02,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$40,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$08,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$40,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$00,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$08,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$40,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$44,$A9,$00,$FF,$FF,$FF,$FF,$FF,$00,$0A,$00,$FF,$FF,$FF,$FF,$FF
    .byte $00,$40,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$44,$AA,$00,$FF,$FF,$FF,$FF,$FF,$00,$0A,$00,$FF,$FF,$FF,$FF,$FF
ARS_NV = 9
ARS_NSEQ = 16
ars_base: .byte 0, 9
ars_ov_lo: .byte <ars_ov0,<ars_ov1,<ars_ov2,<ars_ov3,<ars_ov4,<ars_ov5,<ars_ov6,<ars_ov7,<ars_ov8,<ars_ov9,<ars_ov10,<ars_ov11,<ars_ov12,<ars_ov13,<ars_ov14,<ars_ov15,<ars_ov16,<ars_ov17
ars_ov_hi: .byte >ars_ov0,>ars_ov1,>ars_ov2,>ars_ov3,>ars_ov4,>ars_ov5,>ars_ov6,>ars_ov7,>ars_ov8,>ars_ov9,>ars_ov10,>ars_ov11,>ars_ov12,>ars_ov13,>ars_ov14,>ars_ov15,>ars_ov16,>ars_ov17
ars_ov0: .byte 1, 103,33,0,24
ars_ov1: .byte 0
ars_ov2: .byte 1, 95,34,0,56
ars_ov3: .byte 3, 95,35,0,56, 95,36,0,32, 103,37,0,32
ars_ov4: .byte 2, 103,38,0,40, 95,39,0,48
ars_ov5: .byte 3, 95,34,0,32, 95,40,0,56, 103,41,0,56
ars_ov6: .byte 1, 95,35,0,32
ars_ov7: .byte 0
ars_ov8: .byte 1, 103,42,0,64
ars_ov9: .byte 4, 127,33,0,32, 103,34,0,56, 95,35,0,32, 103,36,0,32
ars_ov10: .byte 7, 95,37,0,32, 127,38,0,32, 103,39,0,32, 127,40,0,40, 103,41,0,48, 103,42,0,56, 127,43,0,56
ars_ov11: .byte 4, 127,44,0,40, 95,45,0,32, 103,43,0,48, 103,40,0,56
ars_ov12: .byte 3, 127,46,0,40, 103,46,0,48, 111,47,0,56
ars_ov13: .byte 1, 127,48,0,40
ars_ov14: .byte 3, 111,49,0,32, 103,50,0,40, 127,50,0,48
ars_ov15: .byte 4, 127,38,0,48, 95,29,0,56, 103,43,0,32, 103,40,0,40
ars_ov16: .byte 7, 95,35,0,56, 127,44,0,56, 103,41,0,32, 127,40,0,32, 103,42,0,40, 127,43,0,48, 103,36,0,56
ars_ov17: .byte 4, 103,51,0,32, 127,52,0,56, 95,37,0,56, 103,39,0,56
ars_hand: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ars_w_lo: .byte <ars_w0,<ars_w1,<ars_w2,<ars_w3,<ars_w4,<ars_w6
ars_w_hi: .byte >ars_w0,>ars_w1,>ars_w2,>ars_w3,>ars_w4,>ars_w6
ars_w0: .byte 0
ars_ic_lo: .byte <ars_ic0,<ars_ic1,<ars_ic2,<ars_ic3,<ars_ic4,<ars_ic5
ars_ic_hi: .byte >ars_ic0,>ars_ic1,>ars_ic2,>ars_ic3,>ars_ic4,>ars_ic5
ars_ic0: .byte 6, 0,27,8, 0,28,16, 0,29,24, 8,30,8, 8,31,16, 8,23,24
ars_ic1: .byte 5, 0,1,0, 0,2,8, 0,3,16, 0,4,24, 8,5,8
ars_ic2: .byte 7, 0,6,0, 0,7,8, 0,8,16, 0,9,24, 8,10,0, 8,11,8, 8,12,16
ars_ic3: .byte 6, 0,13,0, 0,8,8, 0,14,16, 0,9,24, 8,15,8, 8,16,16
ars_ic4: .byte 8, 0,17,0, 0,18,8, 0,19,16, 0,20,24, 8,11,0, 8,21,8, 8,22,16, 8,23,24
ars_ic5: .byte 5, 0,24,0, 0,25,8, 0,25,16, 0,26,24, 8,5,8
ars_w1: .byte 5, 248,1,246, 248,2,254, 248,3,6, 248,4,14, 0,5,254
ars_w2: .byte 7, 250,6,242, 250,7,250, 250,8,2, 250,9,10, 2,10,242, 2,11,250, 2,12,2
ars_w3: .byte 6, 248,13,246, 248,8,254, 248,14,6, 248,9,14, 0,15,254, 0,16,6
ars_w4: .byte 8, 248,17,244, 248,18,252, 248,19,4, 248,20,12, 0,11,244, 0,21,252, 0,22,4, 0,23,12
ars_w6: .byte 5, 248,24,246, 248,25,254, 248,25,6, 248,26,14, 0,5,254
