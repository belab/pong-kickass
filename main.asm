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
main:{
    mov #DARK_GRAY : Screen.BorderColor
    mov #BLACK : Screen.BackgroundColor

	jsr Kernal.CLRSCR

    mov #LIGHT_GREY : Sprite.MultiColor1
    mov #RED : Sprite.MultiColor2

	SpriteActivate(0, Sprites.Ball, YELLOW, SpriteColorMono, SpriteExpandNo, false)
	SpriteActivate(P1.SpriteNr, Sprites.Bat, GREEN, SpriteColorMulti, SpriteExpandY, false)
	SpriteActivate(P2.SpriteNr, Sprites.Bat, PURPLE, SpriteColorMulti, SpriteExpandY, false)
	SpritePosition(0, 170, 138) // middle
	SpritePosition(1, 19, 255/2)
	SpritePosition(2, 326, 255/2)
	ClearBitAt(0, Sprite.Active)
	ClearBitAt(1, Sprite.Active)
	ClearBitAt(2, Sprite.Active)

	jsr SwitchToIntro
	// jsr SwitchToPlay
	jsr System.setupRasterInterrupt

loop:
	jmp loop
}

.label GAME_INTRO = 0
.label GAME_PLAYING = 1
.label GAME_OVER = 2
gameState: .byte GAME_INTRO

SwitchToIntro:{
	print(IntroMessage,14,12,GREY)
	mov #GAME_INTRO : gameState
	rts
}

SwitchToPlay:{
	clear(IntroMessage,14,12)
	jsr Ball.reset
	mov #GAME_PLAYING : gameState
	mov #'0' : P1Score
	mov #'0' : P2Score
	SetBitAt(0, Sprite.Active)
	SetBitAt(1, Sprite.Active)
	SetBitAt(2, Sprite.Active)
	rts
}

SwitchToGameOver:{
	print(GameOverMessage,14,12,GREY)
	mov #GAME_OVER : gameState
	mov #' ' : Screen.Content + 10
	mov #' ' : Screen.Content + 30
	ClearBitAt(0, Sprite.Active)
	ClearBitAt(1, Sprite.Active)
	ClearBitAt(2, Sprite.Active)
	mov #100 : FrameCountdown            // wait for next x frames
	rts
}

WaitForGameStart:{
	JoystickFire(P1.JoystickPort)
	bne waitForStart
	jsr SwitchToPlay
waitForStart:
	rts
}

GameUpdate:{
	lda gameState
	beq GameIntro
	cmp #GAME_PLAYING
	beq GamePlaying
	jmp GameOver

GameIntro:
	jsr WaitForGameStart
	rts

GameOver:
	lda FrameCountdown
	beq GameOverFinished
	dec FrameCountdown                  // consume one frame, keep flash this frame
	rts
GameOverFinished:
	clear(GameOverMessage,14,12)
	jsr SwitchToIntro
	rts


GamePlaying:
	jsr UpdatePlayers
	jsr Ball.update
	rts

}

Ball:{
	.label DIRECTION_RIGHT = 0
	.label DIRECTION_LEFT = 1
	.label DIRECTION_DOWN = 0
	.label DIRECTION_UP = 1
	.label Speed = 2
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
		bne stepDown
		add8 PosY : #Speed
		jmp checkBottomEdge
	stepDown:
		sub8 PosY : #Speed
	checkBottomEdge:
		lda PosY
		cmp #Border.BOTTOM
		bne checkTopEdge
		mov #DIRECTION_UP : DirectionY
		jmp moveHorizontal
	checkTopEdge:
		cmp #Border.TOP
		bne	moveHorizontal
		mov #DIRECTION_DOWN : DirectionY

	moveHorizontal:
		lda DirectionX
		bne checkLeftBat
		TestBitAt(2, Sprite.Collisions)	// check collision with right bat
		beq stepRight
		mov #DIRECTION_LEFT : DirectionX	// change dir to left
		sub16 PosX : #Speed
		jmp updateSprite
	stepRight:
		add16 PosX : #Speed
		jmp checkRightEdge
	checkLeftBat:
		TestBitAt(1, Sprite.Collisions)	// check collision with left bat
		beq stepLeft
		mov #DIRECTION_RIGHT : DirectionX
		add16 PosX : #Speed
		jmp updateSprite
	stepLeft:
		sub16 PosX : #Speed
		jmp checkLeftEdge
	checkRightEdge:
		TestBitAt(0, Sprite.PosXHiBits)
		beq updateSprite				// in left region, no right border check
		lda PosX
		cmp #325-255					// low-byte when at right edge
		bne updateSprite
		lda P1Score
		cmp #'0'+3
		bne scoreP1
		jsr SwitchToGameOver
		rts

	scoreP1:
		inc P1Score
		mov #2 : FrameCountdown			// flash for next x frames
		mov #DIRECTION_LEFT : DirectionX
		jsr Ball.reset
		jmp updateSprite
	checkLeftEdge:
		TestBitAt(0, Sprite.PosXHiBits)
		bne updateSprite				// in right region, no left border check
		lda PosX
		cmp #Border.LEFT
		bne updateSprite
		lda P2Score
		cmp #'0'+3
		bne scoreP2
		jsr SwitchToGameOver
		rts
	scoreP2:
		inc P2Score
		mov #2 : FrameCountdown            // flash for next x frames
		mov #DIRECTION_RIGHT : DirectionX
		jsr Ball.reset
	updateSprite:
		mov PosY : Sprite.Positions + 1
		mov PosX : Sprite.Positions
		lda PosX + 1
		bne setXHigh					// if high byte != 0, in right region
		ClearBitAt(0, Sprite.PosXHiBits)
		jmp done
	setXHigh:
		SetBitAt(0, Sprite.PosXHiBits)
	done:
		// handle border flash counter per-frame
		lda FrameCountdown
		beq noFlash
		dec FrameCountdown                  // consume one frame, keep flash this frame
		inc Screen.BorderColor
		jmp flashDone
	noFlash:
		mov #DARK_GRAY : Screen.BorderColor
	flashDone:
		mov P1Score : Screen.Content + 10
		mov P2Score : Screen.Content + 30
		rts
	}
}
FrameCountdown: .byte 0
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

IntroMessage:
	.text "insert coin"
    .byte $00

GameOverMessage:
	.text "game over"
    .byte $00


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
