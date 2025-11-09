//-----------------------------------------------
// Dark Breath – tiefer, unheimlich modulierte SID-Sound
// auf Voice 2 mit Filterbewegung
//-----------------------------------------------
BasicUpstart2(next)

next:

.label SID_BASE = $d400

// Voice 2
.label FREQ_LO2   = SID_BASE + $0e
.label FREQ_HI2   = SID_BASE + $0f
.label PW_LO2     = SID_BASE + $10
.label PW_HI2     = SID_BASE + $11
.label CTRL2      = SID_BASE + $12
.label AD2        = SID_BASE + $13
.label SR2        = SID_BASE + $14

// Filter / Lautstärke
.label FC_LO      = SID_BASE + $15
.label FC_HI      = SID_BASE + $16
.label RES_FILT   = SID_BASE + $17
.label MODE_VOL   = SID_BASE + $18

//-----------------------------------------------
// Initialisierung
//-----------------------------------------------
        sei

// Master-Volume auf Maximum
        lda #%00001111
        sta MODE_VOL

// Filter: tiefer Start, Resonanz mittel
        lda #%00000100   // Resonanz 4
        sta RES_FILT
        lda #$20         // Cutoff low
        sta FC_LO
        lda #$00
        sta FC_HI

// Filter auf Stimme 2 anwenden
        lda #%00000010   // Bit1 = Voice 2
        ora #%00010000   // Tiefpass aktivieren
        sta MODE_VOL

//-----------------------------------------------
// Frequenz & Pulsweite
//-----------------------------------------------
        lda #$10
        sta FREQ_LO2
        lda #$01
        sta FREQ_HI2

        lda #$00
        sta PW_LO2
        lda #$08
        sta PW_HI2

//-----------------------------------------------
// ADSR: langsames Attack / langsames Release
//-----------------------------------------------
        lda #%11100000   // A=E, D=0
        sta AD2
        lda #%00011111   // S=1, R=F
        sta SR2

//-----------------------------------------------
// Stimme aktivieren: Pulse + Noise + Gate
//-----------------------------------------------
        lda #%01010001
        sta CTRL2

//-----------------------------------------------
// Modulations-Loop:
// - leichte Pulsweitenmodulation (PWM)
// - tiefe Filterbewegung (Cutoff-Wobble)
//-----------------------------------------------
loop:
        ldy #$00

modloop:
        // Pulsweite verändern
        lda PW_LO2
        clc
        adc #$03
        sta PW_LO2
        bcc skip_pw
        inc PW_HI2
skip_pw:

        // Filter-Cutoff langsam "atmen" lassen
        lda FC_LO
        clc
        adc #$01
        sta FC_LO
        lda FC_HI
        adc #$00
        sta FC_HI

        // langsamer Wobble
        dey
        bne modloop

        jmp loop
