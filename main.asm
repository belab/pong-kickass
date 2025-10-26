#import "Sprite.asm"
#import "Registers.asm"
#import "Kernal.asm"
#import "MemoryMap.asm"

BasicUpstart2(main)

*=GAME_CODE_ADDRESS "Game Code"
main:
	jsr Kernal.CLRSCR

    // lda #100
    // sta $d000       // pos x
    // sta $d001       // pos y

	// SpriteActivate(0, Sprites.Bat, YELLOW, SpriteColorMono, SpriteExpandY, false)

	// SpritePosition(0, 100, 75)
	// stb #0:r3L
	// stb #120:r4L
	// stb #100:r5L
	// jsr Sprite.SetPos


	SpriteActivate(0, Sprites.Ball, YELLOW, SpriteColorMono, SpriteExpandX, false)
	SpriteActivate(1, Sprites.Bat, GREEN, SpriteColorMono, SpriteExpandX, false)
	// SpritePosition(1, 120, 100)

    // lda Sprite.Active
    // ora #(1 << 0)
    // sta Sprite.Active
    // lda #100
    // sta $d000       // pos x
    // sta $d001       // pos x


    // lda #SpritePage(Sprites.Ball)
    // ldx #0
    // sta Sprite.DataPointers,x
    // lda Sprite.Active
    // ora #(1 << 0)
    // sta Sprite.Active
    lda #75
    sta $d000       // pos x
    sta $d001       // pos y
    lda #90
    sta $d002       // pos x
    sta $d003       // pos y



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
