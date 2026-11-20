; cadenas que se dibujan con la pantalla apagada (banco 2)
cont_strs:
    .str $214B, "CONTINUAR?"
    .str $21CB, "PUNTOS"
    .str $224B, "CREDITOS X"
    .str $22C9, "PRESIONA START"
    .byte 0
end_both:
    .str $2149, "JOSE Y LUCIANA"
    .byte 0
select_strs:
    .str $2067, "ELIGE TU PERSONAJE"
    .str $2188, "JOSE"
    .str $2253, "LUCIANA"
    .str $22C3, "B GOLPE/DISPARO    A SALTO"
    .str $2303, "A+B VEHICULO  SELECT ARMAS"
    .str $2343, "ARRIBA/ABAJO PROFUNDIDAD"
    .str $2381, "2X ADELANTE CORRE  START PAUSA"
    .byte 0
intro_strs:
    .str $210B, "NIVEL"
    .str $228A, "BUSCADO"
    .str $230A, "VIDAS X"
    .str $234A, "CONTIN X"
    .str $220D, "JEFE:"
    .byte 0
pol_str:
    .str $2386, "LA POLICIA TE PERSIGUE!"
    .byte 0
mil_str:
    .str $2386, "EL EJERCITO TE PERSIGUE!"
    .byte 0
clear_strs:
    .str $2149, "ESCAPASTE!"
    .str $2187, "NIVEL COMPLETADO"
    .str $21CC, "PTS"
    .byte 0
gameover_strs:
    .str $210B, "ARRESTADO"
    .str $214B, "GAME OVER"
    .str $21CC, "PTS"
    .str $2289, "PRESIONA START"
    .byte 0
ending_strs:
    .str $20CA, "LO LOGRASTE!"
    .str $2187, "ESCAPO CON EL BOTIN"
    .str $21CC, "PTS"
    .str $2287, "GRACIAS POR JUGAR"
    .str $2307, "LA PROXIMA CIUDAD:"
    .str $2347, "PAYSANDU - URUGUAY"
    .byte 0
end_jose:
    .str $2149, "JOSE DUALCORE"
    .byte 0
end_luci:
    .str $2147, "LUCIANA CARRETERAS"
    .byte 0
