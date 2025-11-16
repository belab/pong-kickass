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
	// jsr Sound.hold
	// JoystickFire(Joystick.PortA)
	// bne !+
	jsr PlayMusic
!:	rts

}

PlayMusic:
.printnow "PlayMusic=$" + toHexString(PlayMusic)
	dec FrameCountdown
	bne done
	// mov #$10 : Sound.Wave1GateOn       // Gate off
    ldx CurrentNote
	inc CurrentNote

	lda Song,x

	cmp #$FF
	bne !+
	mov #0 : CurrentNote
	ldx #0
	lda Song
!:	sta Sound.Freq1H
	lda #0
	sta Sound.Freq1L

    mov #$09 : Sound.AtkDecy1     // Attack=0, Decay=0
    mov #$f9 : Sound.SusRel1      // Sustain=max, Release=0
    mov #$11 : Sound.Wave1GateOn   // Gate on + Triangle waveform
    mov #55 : FrameCountdown
done:
    rts

CurrentNote: .byte 0
FrameCountdown: .byte 5

// Song: .byte $04, $05, $06, $05, $05, $06, $06, $FF
Song: .word $0454, $00454, $0454, $0526, $04dc, $06df, $067c, $FFFF
//           C2       C2     C2     D#2    D2     G#2    G2