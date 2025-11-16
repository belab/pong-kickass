BasicUpstart2(next)

#import "Utils.asm"
#import "Sound.asm"
#import "System.asm"
#import "Joystick.asm"

.label DELAY = 100

next:
	SoundInit($0f)
	mov #$10 : Sound.Wave1GateOn       // Gate off
	jsr System.setupRasterInterrupt

loop:
	jmp loop

GameUpdate:{
	jsr Sound.hold
	JoystickFire(Joystick.PortA)
	bne !+
	ldx #0
	ldy #5
	jsr Sound.bounce
!:
	jsr PlayMusic
	rts

}

PlayMusic:
	dec FrameCountdown
	bne done
    ldx CurrentNote
	inc CurrentNote

	lda Song.NotesL,x
	cmp #$FF
	bne !+
	mov #0 : CurrentNote
	ldx #0
	lda Song.NotesL
!:	sta Sound.Freq2L
	mov Song.NotesH,x : Sound.Freq2H

    mov #$09 : Sound.AtkDecy2     // Attack=0, Decay=0
    mov #$f9 : Sound.SusRel2      // Sustain=max, Release=0
    mov #$11 : Sound.Wave2        // Triangle waveform
    mov #40 : FrameCountdown
done:
    rts

CurrentNote: .byte 0
FrameCountdown: .byte 5

// Song: .byte $04, $05, $06, $05, $05, $06, $06, $FF

Song: {
	NotesH: .byte $04, $04, $04, $05, $04, $06, $06, $06, $06, $FF
	NotesL: .byte $54, $54, $54, $26, $dc, $df, $df, $7c, $7c, $FF
}
//           C2       C2     C2     D#2    D2     G#2    G#2    G2