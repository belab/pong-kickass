#import "Sprite.asm"
#import "Registers.asm"
#import "Kernal.asm"
#import "MemoryMap.asm"
#import "Screen.asm"
#import "Joystick.asm"

.struct Player{
	JoystickPort,
	SpriteNr,
	PosY
}
.var P1 = Player(Joystick.PortA, 1, Sprite.Positions + 1 * 2 + 1)
.var P2 = Player(Joystick.PortB, 2, Sprite.Positions + 2 * 2 + 1)

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

	SpritePosition(0, 320/2, 255/2)
	SpritePosition(1, 19, 255/2)
	SpritePosition(2, 326, 255/2)

	lda Sprite.Active
	SetBit(3)
	sta Sprite.Active
	SpritePosition(3, 24, 229)
	lda Sprite.ColorMode
    ClearBit(3)
    sta Sprite.ColorMode

	jsr Ball.reset

loop:
	lda Screen.RasterLine
	cmp #250
	bne loop
	jsr UpdatePlayers
	jsr SlowDownLoop
	jsr Ball.update
	jmp loop

Ball:{
	SpeedX: .byte 0
	SpeedY: .byte 0
//  .printnow "PosX=$" + toHexString(PosX)
// .printnow "PosY=$" + toHexString(PosY)
	PosX: .word 255/2
	PosY: .byte 255/2

	reset:
		mov16 #255/2 : PosX
		mov #255/2 : PosY
		SpritePosition(0, 330/2, 255/2)
		rts

	update:

		lda SpeedY
		bne toDown
		inc PosY
		jmp movSpriteY
toDown:
		dec PosY
movSpriteY:
		mov PosY : Sprite.Positions+1

		lda PosY
		cmp #Screen.Height+30
		bne checkTopY
		lda #1
		sta SpeedY
		jmp noBounceY

checkTopY:
		cmp #30
		bne	noBounceY
		lda #0
		sta SpeedY
noBounceY:

		lda SpeedX
		bne toRight
		inc PosX
		jmp movSpriteX
toRight:
		dec PosX
movSpriteX:
		mov PosX : Sprite.Positions

		lda PosX
		cmp #255
		bne checkLeftX
		lda #1
		sta SpeedX
		jmp noBounceX

checkLeftX:
		cmp #0
		bne	noBounceX
		lda #0
		sta SpeedX
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

SlowDownLoop:
{
	ldx #0
loop:
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
	bne loop
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
