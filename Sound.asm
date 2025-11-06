#importonce

updateSoundHold:
    dec SoundHoldTime
    bne done
    lda #$10           // Gate off + Triangle waveform
    sta $d404
done:
    rts

// -----------------------
// =====================================================
// RetriggerVoice1
// Stops any current sound and immediately starts new one
// X/Y: new frequency (lo/hi) e.g. 0, 5
// =====================================================
bounceSound:
    txa
    sta $d400          // freq low byte
    tya
    sta $d401          // freq high byte

    lda #$09
    sta $d405          // Attack=0, Decay=0
    lda #$f9
    sta $d406          // Sustain=max, Release=0


    lda #$11           // Gate on + Triangle waveform
    sta $d404

    lda #5
    sta SoundHoldTime
    rts

noiseSound:
    lda #5
    sta $d400          // freq low byte
    lda #1
    sta $d401          // freq high byte

    lda #$15
    sta $d405          // Attack=0, Decay=0
    lda #$5b
    sta $d406          // Sustain=max, Release=0


    lda #$81           // Gate on + noise waveform
    sta $d404

    lda #30
    sta SoundHoldTime
    rts

SoundHoldTime: .byte 5