BasicUpstart2(next)

#import "Utils.asm"
#import "Sound.asm"
#import "System.asm"
#import "Joystick.asm"

.label DELAY = 100

next:
	SoundInit($0f)
	mov #1 : Playing
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
	lda Playing
	beq done
	dec FrameCountdown
	bne done
    ldx CurrentNote
	inc CurrentNote

	lda Song2.NotesL,x
	cmp #$FF
	bne !+
	mov #0 : Playing
	mov #0 : CurrentNote
	mov #$00 : Sound.Wave2
	rts
!:	sta Sound.Freq2L
	mov Song2.NotesH,x : Sound.Freq2H

    mov #$00 : Sound.AtkDecy2     // Attack=0, Decay=0
    mov #$39 : Sound.SusRel2      // Sustain=max, Release=0
    mov #$51 : Sound.Wave2        // Triangle waveform
    mov #40 : FrameCountdown
done:
    rts

CurrentNote: .byte 0
FrameCountdown: .byte 5
Playing: .byte 0
// Song2: .byte $04, $05, $06, $05, $05, $06, $06, $FF

Song2: {
	NotesH: .byte $04, $04, $04, $05, $04, $06, $06, $06, $06, $FF
	NotesL: .byte $54, $54, $54, $26, $dc, $df, $df, $7c, $7c, $FF
}
//           C2       C2     C2     D#2    D2     G#2    G#2    G2