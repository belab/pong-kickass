*=LIBRARIES_ADDRESS "Libraries"
#import "Sprite.asm"
#import "Registers.asm"
#import "Kernal.asm"
#import "MemoryMap.asm"
#import "Screen.asm"
#import "Joystick.asm"
#import "System.asm"

.struct Player{
	JoystickPort,
	SpriteNr,
	PosY
}
.var P1 = Player(Joystick.PortA, 1, Sprite.Positions + 1 * 2 + 1)
.var P2 = Player(Joystick.PortB, 2, Sprite.Positions + 2 * 2 + 1)

.namespace Border {
	.label LEFT = 20
	.label RIGHT = 325
	.label TOP = 48
	.label BOTTOM = 234
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
	SpriteActivate(P1.SpriteNr, Sprites.Bat, GREEN, SpriteColorMulti, SpriteExpandY, false)
	SpriteActivate(P2.SpriteNr, Sprites.Bat, PURPLE, SpriteColorMulti, SpriteExpandY, false)

	// SpritePosition(0, 20, 48) // top left
	// SpritePosition(0, 20, 234) // bottom left
	// SpritePosition(0, 325, 48) // top right
	// SpritePosition(0, 325, 234) // top right
	SpritePosition(0, 170, 138) // middle
	SpritePosition(1, 19, 255/2)
	SpritePosition(2, 326, 255/2)

	jsr Ball.reset

	jsr System.setupRasterInterrupt

loop:
	jmp loop

Ball:{
	DirectionX: .byte 0
	DirectionY: .byte 0
//  .printnow "PosX=$" + toHexString(PosX)
// .printnow "PosY=$" + toHexString(PosY)
	PosX: .word 170
	PosY: .byte 138

	reset:
		mov16 #170 : PosX
		mov #138 : PosY
		SpritePosition(0, 170, 138)
		rts

	update:

		lda DirectionY
		bne toDown
		inc PosY
		jmp movSpriteY
toDown:
		dec PosY
movSpriteY:
		mov PosY : Sprite.Positions+1

		lda PosY
		cmp #Border.BOTTOM
		bne checkTopY
		lda #1
		sta DirectionY
		jmp noBounceY

checkTopY:
		cmp #Border.TOP
		bne	noBounceY
		lda #0
		sta DirectionY
noBounceY:

		lda DirectionX
		bne toRight

		inc16 PosX
		jmp movSpriteX
toRight:
		dec16 PosX
movSpriteX:
		mov PosX : Sprite.Positions
		lda PosX + 1
		bne !+
		lda Sprite.PosXHiBits
		ClearBit(0)
		sta Sprite.PosXHiBits
		jmp checkLeftX
!:
		lda Sprite.PosXHiBits
		SetBit(0)
		sta Sprite.PosXHiBits
		lda PosX
		cmp #325-255
		bne checkLeftX
		lda #1
		sta DirectionX
		jmp noBounceX

checkLeftX:
		lda PosX +1
		bne noBounceX
		lda PosX
		cmp #Border.LEFT
		bne	noBounceX
		lda #0
		sta DirectionX
noBounceX:


		rts
}

UpdatePlayers:
{
	JoystickUp(P1.JoystickPort)
	bne joyDown
	dec P1.PosY
joyDown:
	JoystickDown(P1.JoystickPort)
	bne joyEnd
	inc P1.PosY
joyEnd:
}

{
	JoystickUp(P2.JoystickPort)
	bne joyDown
	dec P2.PosY
joyDown:
	JoystickDown(P2.JoystickPort)
	bne joyEnd
	inc P2.PosY
joyEnd:
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
