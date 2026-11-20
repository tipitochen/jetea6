"""Musica v4 estilo GTA (hip-hop / G-funk). 4 canales: pulso1 lead, pulso2 acordes, triangulo bajo, ruido bateria."""
NOTE = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
def midi(s): return 12 * (int(s[-1]) + 1) + NOTE[s[0]] + (1 if '#' in s else 0)

def stream(tokens, step, tri=False, drum=False):
    out = []
    for t in tokens:
        if t == '-':
            if out and out[-1] + step < 250: out[-1] += step
            else: out += [out[-2] if out else 0, step]
        elif t == '.':
            if len(out) >= 2 and out[-2] == 0 and out[-1] + step < 250: out[-1] += step
            else: out += [0, step]
        elif drum:
            out += [{'K': 1, 'S': 2, 'H': 3}[t], step]
        else:
            out += [midi(t) + (12 if tri else 0) - 35, step]
    return out + [0xFF]

def bars(*b): return ' '.join(b).split()

# progresion Em - C - Am - B7
BASS = {
 'Em': "E2 . . E2 . . G2 . A2 . . E2 . D2 . .",
 'C':  "C2 . . C2 . . E2 . G2 . . C2 . B1 . .",
 'Am': "A1 . . A1 . . C2 . E2 . . A1 . G1 . .",
 'B7': "B1 . . B1 . . D#2 . F#2 . . B1 . A1 . .",
}
CHORD = {
 'Em': ". . . . G4 . . . . . . . B4 . D5 .",
 'C':  ". . . . E4 . . . . . . . G4 . C5 .",
 'Am': ". . . . C5 . . . . . . . E5 . A4 .",
 'B7': ". . . . D#5 . . . . . . . F#4 . A4 .",
}
LEAD = {
 'Em': "B4 - - - . . G4 A4 B4 - D5 - B4 - A4 -",
 'C':  "G4 - - - . . E4 G4 C5 - - - B4 - G4 -",
 'Am': "A4 - - - . . C5 - E5 - D5 - C5 - A4 -",
 'B7': "B4 - - - D#5 - F#5 - - - D#5 - B4 - - -",
}
LEAD2 = {
 'Em': "E5 - - - D5 - B4 - G4 - A4 - B4 - - -",
 'C':  "E5 - - - G5 - E5 - D5 - C5 - - - - -",
 'Am': "C5 - - - B4 - A4 - G4 - A4 - C5 - - -",
 'B7': "D#5 - - - - - B4 - F#5 - - - D#5 - - -",
}
REST = ". . . . . . . . . . . . . . . ."
D_A = "K . H . S . H K H . K . S . H ."
D_B = "K . H . S . H . K . K H S . H K"
PROG = ['Em', 'C', 'Am', 'B7']

def song_game():
    lead, chords, bass, drums = [], [], [], []
    for rep in range(3):
        for c in PROG:
            lead += (REST if rep == 0 else (LEAD[c] if rep == 1 else LEAD2[c])).split()
            chords += CHORD[c].split(); bass += BASS[c].split()
            drums += (D_A if c != 'B7' else D_B).split()
    return lead, chords, bass, drums, 8

def song_title():
    T = {'Em': "E5 - - - - - D5 - B4 - - - - - - -", 'C': "C5 - - - - - B4 - G4 - - - - - - -",
         'Am': "A4 - - - C5 - E5 - D5 - - - - - - -", 'B7': "D#5 - - - F#5 - - - B4 - - - - - - -"}
    lead, chords, bass, drums = [], [], [], []
    for rep in range(2):
        for c in PROG:
            lead += (T[c] if rep else REST).split()
            chords += CHORD[c].split(); bass += BASS[c].split()
            drums += "K . . . S . . . K . K . S . . .".split()
    return lead, chords, bass, drums, 10

def song_boss():
    B = {'Em': "E2 E2 E3 E2 G2 E2 A2 E2 E2 E2 E3 E2 B2 A2 G2 F#2",
         'C': "C2 C2 C3 C2 E2 C2 G2 C2 C2 C2 C3 C2 G2 F#2 E2 D2"}
    L = {'Em': "E5 - . E5 G5 - E5 . A5 - G5 - E5 - D5 -",
         'C': "E5 - . E5 G5 - C6 . B5 - G5 - E5 - F#5 -"}
    Ch = {'Em': "E4 . B4 . E4 . B4 . E4 . B4 . E4 . B4 .", 'C': "C4 . G4 . C4 . G4 . C4 . G4 . C4 . G4 ."}
    lead, chords, bass, drums = [], [], [], []
    for c in ['Em', 'Em', 'C', 'Em']:
        lead += L[c].split(); chords += Ch[c].split(); bass += B[c].split()
        drums += "K . H K S . H K K . H K S . K H".split()
    return lead, chords, bass, drums, 7

def emit():
    out = ['; ---- musica v4 (estilo GTA) ----']
    for k, f in enumerate((song_title, song_game, song_boss)):
        lead, chords, bass, drums, step = f()
        out += ['trk%d_p:' % k, fmt(stream(lead, step)), 'trk%d_q:' % k, fmt(stream(chords, step)),
                'trk%d_t:' % k, fmt(stream(bass, step, tri=True)), 'trk%d_n:' % k, fmt(stream(drums, step, drum=True))]
    out.append('track_tbl:')
    out.append('    .word ' + ','.join('trk%d_p,trk%d_q,trk%d_t,trk%d_n' % (k, k, k, k) for k in range(3)))
    open('music4.asm', 'w').write('\n'.join(out) + '\n')

def fmt(data):
    return '\n'.join('    .byte ' + ','.join('$%02X' % (b & 255) for b in data[i:i + 16]) for i in range(0, len(data), 16))

if __name__ == '__main__':
    emit()
    print('ok')
