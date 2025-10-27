#import "Sprite.asm"
#import "Registers.asm"
#import "Kernal.asm"
#import "MemoryMap.asm"

BasicUpstart2(main)

*=GAME_CODE_ADDRESS "Game Code"
main:
	// jsr Kernal.CLRSCR


	SpriteActivate(0, Sprites.Ball, YELLOW, SpriteColorMulti, SpriteExpandXY, false)
	SpriteActivate(1, Sprites.Bat, GREEN, SpriteColorMono, SpriteExpandXY, true)
	SpritePosition(0, 75, 65)
	SpritePosition(1, 190, 65)

    lda #%00000010  // multicolor 2
    sta $d01c
    lda #GREEN
    sta $d028       // store color


    lda #WHITE     // sprite multicolor 1
    sta $d025
    lda #RED        // sprite multicolor 2
    sta $d026


loop:
	jmp loop

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
