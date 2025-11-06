BasicUpstart2(next)

.label DELAY = 10

next:
        sei
        jsr initSid
loop:
        lda FrameCountdown
        bne !+
        ldx #0
        ldy #5
        lda #$11
        jsr BounceSound2
        lda #DELAY
        sta FrameCountdown
!:      lda #111
!:      cmp $d012
        bne !-
        dec FrameCountdown

        jmp loop

// -----------------------
initSid:
        lda #$0f           // master volume 15
        sta $d418
        rts


BounceSound2:
        lda #$03
        sta $d402
        lda #$03
        sta $d403

        lda #$35
        sta $d405          // Attack/Decay
        lda #$99
        sta $d406          // Sustain/Release

        lda #$00
        sta $d400          // frequency low
        lda #$09
        sta $d401          // frequency high

        lda #$81           // Triangle waveform + Gate ON
        sta $d404

        // --- short delay loop ---
        ldx #$10
delay:
        dex
        bne delay

        // --- Gate OFF to let envelope release ---
        // lda #$10           // same waveform, gate bit OFF
        // sta $d404
        rts

FrameCountdown: .byte DELAY
