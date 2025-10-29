#import "Sprite.asm"
#import "Registers.asm"
#import "Kernal.asm"
#import "MemoryMap.asm"
#import "Screen.asm"
#import "Joystick.asm"

.namespace Player1 {
	.label SpriteNr = 1
	.label PosY = Sprite.Positions + SpriteNr * 2 + 1
}
.namespace Player2 {
	.label SpriteNr = 2
	.label PosY = Sprite.Positions + SpriteNr * 2 + 1
}

BasicUpstart2(main)

*=GAME_CODE_ADDRESS "Game Code"
main:
    mov #DARK_GRAY : Screen.BorderColor
    mov #BLACK : Screen.BackgroundColor

	jsr Kernal.CLRSCR

    mov #WHITE : Sprite.MultiColor1
    mov #RED : Sprite.MultiColor2

	SpriteActivate(0, Sprites.Ball, YELLOW, SpriteColorMono, SpriteExpandNo, false)
	SpriteActivate(1, Sprites.Bat, GREEN, SpriteColorMulti, SpriteExpandY, false)
	SpriteActivate(2, Sprites.Bat, PURPLE, SpriteColorMulti, SpriteExpandY, false)

	SpritePosition(0, 320/2, 255/2)
	SpritePosition(1, 19, 255/2)
	SpritePosition(2, 326, 255/2)

	jsr Ball.reset

loop:
	ldx #0
slowDownLoop:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

	inx
	cpx #255
	bne slowDownLoop

{
	Joystick1Up()
	bne joyDown
	dec Player1.PosY
joyDown:
	Joystick1Down()
	bne joyEnd
	inc Player1.PosY
joyEnd:
}

{
	Joystick2Up()
	bne joyDown
	dec Player2.PosY
joyDown:
	Joystick2Down()
	bne joyEnd
	inc Player2.PosY
joyEnd:
}

	jmp loop

Ball:{
	SpeedX: .byte -1
	SpeedY: .byte 1
	PosX: .word 255/2
	PosY: .byte 255/2

	reset:
		mov16 #255/2 : PosX
		mov #255/2 : PosY
		SpritePosition(0, 330/2, 255/2)
		rts
}



*=SPRITES_ADDRESS "Sprites"
Sprites:{
Ball:
.byte  $00, $00, $00, $00, $00, $00, $00, $0c, $00, $00, $18
.byte  $00, $00, $38, $00, $01, $ff, $00, $02, $fe, $80, $06
.byte  $7c, $c0, $0f, $ef, $e0, $0d, $c7, $60, $0c, $fe, $60
.byte  $0c, $00, $60, $06, $00, $c0, $03, $01, $80, $01, $ff
.byte  $00, $00, $7c, $00, $00, $00, $00, $00, $00, $00, $00
.byte  $00, $00, $00, $00, $00, $00, $00, $00, $07

Bat:
.byte $00, $28, $00, $00, $28, $00, $00, $28, $00, $00, $28
.byte $00, $00, $28, $00, $00, $28, $00, $00, $28, $00, $00
.byte $28, $00, $00, $28, $00, $00, $28, $00, $00, $28, $00
.byte $00, $55, $00, $00, $14, $00, $00, $3c, $00, $00, $3c
.byte $00, $00, $15, $00, $00, $15, $00, $00, $55, $00, $00
.byte $51, $00, $01, $44, $00, $00, $00, $00
}
