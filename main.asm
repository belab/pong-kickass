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
	.label DIRECTION_RIGHT = 0
	.label DIRECTION_LEFT = 1
	.label DIRECTION_DOWN = 0
	.label DIRECTION_UP = 1
	DirectionX: .byte DIRECTION_RIGHT
	DirectionY: .byte DIRECTION_DOWN
//  .printnow "PosX=$" + toHexString(PosX)
// .printnow "PosY=$" + toHexString(PosY)
	PosX: .word 170
	PosY: .byte 138

	reset:{
		mov16 #170 : PosX
		mov #138 : PosY
		SpritePosition(0, 170, 138)
		rts
	}

	update:{
		lda DirectionY
		bne toDown
		inc PosY
		jmp moveOnX
	toDown:
		dec PosY

	moveOnX:
		lda DirectionX
		bne checkLeftBat
		TestBitAt(2, Sprite.Collisions)	// check collision with right bat
		beq stepRight
		mov #DIRECTION_LEFT : DirectionX	// change dir to left
		dec16 PosX
		jmp updateSprite
	stepRight:
		inc16 PosX						// ==>
		jmp checkRightEdge
	checkLeftBat:
		TestBitAt(1, Sprite.Collisions)	// check collision with left bat
		beq stepLeft
		mov #DIRECTION_RIGHT : DirectionX
		inc16 PosX						// ==>
		jmp updateSprite
	stepLeft:
		dec16 PosX						// <==
		jmp checkLeftEdge
	checkRightEdge:
		lda PosX
		cmp #325-255					// low-byte when at right edge
		bne updateSprite
		inc P1Score
		jsr Ball.reset
		jmp updateSprite
	checkLeftEdge:
		lda PosX
		cmp #Border.LEFT
		bne updateSprite
		inc P2Score
		jsr Ball.reset
	updateSprite:
		// mov PosY : Sprite.Positions + 1
		mov PosX : Sprite.Positions
		lda PosX + 1
		bne setXHigh					// if high byte != 0, in right region
		ClearBitAt(0, Sprite.PosXHiBits)
		jmp done
	setXHigh:
		SetBitAt(0, Sprite.PosXHiBits)
	done:
		rts
	}

// 	update:{
// 		lda DirectionY
// 		bne toDown
// 		inc PosY
// 		jmp movSpriteY
// 	toDown:
// 		dec PosY
// 	movSpriteY:
// 		mov PosY : Sprite.Positions+1

// 		lda PosY
// 		cmp #Border.BOTTOM
// 		bne checkTopY
// 		mov #DIRECTION_UP : DirectionY
// 		jmp noBounceY

// 	checkTopY:
// 		cmp #Border.TOP
// 		bne	noBounceY
// 		mov #DIRECTION_DOWN : DirectionY
// 	noBounceY:

// // Ball horizontal movement and collision logic
// 		lda DirectionX
// 		bne moveLeft              // DirectionX != 0 → moving left
// 		inc16 PosX                // move right
// 		jmp movSpriteX
// 	moveLeft:
// 		dec16 PosX                // move left

// // Update sprite X position registers
// movSpriteX:
//         mov PosX : Sprite.Positions
//         lda PosX + 1
//         bne checkRightX           // if high byte != 0, in right region
//         ClearBitAt(0, Sprite.PosXHiBits)
//         jmp checkLeftX

// // Check for right wall or paddle 2 collision
// checkRightX:
//         TestBitAt(2, Sprite.Collisions)
//         bne bounceRight           // if collision bit set, reflect

//         SetBitAt(0, Sprite.PosXHiBits)

//         // --- NEW: check direction before testing border scoring ---
//         lda DirectionX
//         bne checkLeftX            // if moving left, skip right-bound test

//         lda PosX
//         cmp #325-255              // low-byte when at right edge
//         bne checkLeftX

//         // Ball crossed right border → Player 1 scores
//         inc P1Score
//         jsr Ball.reset

// // Reflect ball from right side (Player 2 paddle)
// bounceRight:
// 		mov #DIRECTION_LEFT : DirectionX
//         jmp noBounceX

// // Check for left wall or paddle 1 collision
// checkLeftX:
//         TestBitAt(1, Sprite.Collisions)
//         bne bounceLeft           // if collision bit set, reflect

//         lda PosX
//         cmp #Border.LEFT
//         bne noBounceX

//         // --- NEW: check direction before testing border scoring ---
//         lda DirectionX
//         beq noBounceX             // if moving right, skip left-bound test

//         // Ball crossed left border → Player 2 scores
//         inc P2Score
//         jsr Ball.reset
// bounceLeft:
//         mov #DIRECTION_RIGHT : DirectionX                    // change dir → right

// // End of horizontal movement update
// noBounceX:
//         mov P1Score : Screen.Content + 10
//         mov P2Score : Screen.Content + 30
//         rts

// 	}
}

P1Score: .byte '0'
P2Score: .byte '0'

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
.byte $00, $00, $00, $00, $00, $00, $00, $0c, $00, $00, $18
.byte $00, $00, $38, $00, $01, $ff, $00, $02, $fe, $80, $06
.byte $7c, $c0, $0f, $ef, $e0, $0d, $c7, $60, $0c, $fe, $60
.byte $0c, $00, $60, $06, $00, $c0, $03, $01, $80, $01, $ff
.byte $00, $00, $7c, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $07

Bat:
.byte $00, $28, $00, $00, $28, $00, $00, $28, $00, $00, $28
.byte $00, $00, $28, $00, $00, $28, $00, $00, $28, $00, $00
.byte $28, $00, $00, $28, $00, $00, $28, $00, $00, $28, $00
.byte $00, $55, $00, $00, $14, $00, $00, $3c, $00, $00, $3c
.byte $00, $00, $15, $00, $00, $15, $00, $00, $55, $00, $00
.byte $51, $00, $01, $44, $00, $00, $00, $00
}
