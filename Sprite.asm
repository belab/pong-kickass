#importonce

#import "Utils.asm"

*=* "Sprite Routines"

.namespace Sprite {
  .label DataPointers = $7f8
  .label Active = $d015
  .label Colors = $d027
  .label ExpandX = $d01d
  .label ExpandY = $d017
  .label ColorMode = $d01c
  .label BackgroundPriority = $d01b
  .label MultiColor1 = $d025
  .label MultiColor2 = $d026
  .label PosXHiBits = $d010
  .label Positions = $d000
}

.function SpritePage(addr) {
  .return (addr & $3fff) / 64
}

.enum {SpriteColorMono, SpriteColorMulti}
.enum {SpriteExpandNo, SpriteExpandX, SpriteExpandY, SpriteExpandXY}

.macro SpriteActivate(nr, addr, color, colorMode, expandMode, bgPrio) {
  lda #SpritePage(addr)
  ldx #nr
  sta Sprite.DataPointers,x
  lda Sprite.Active
  SetBit(nr)
  sta Sprite.Active
  lda #color
  sta Sprite.Colors,x
  .if(colorMode == SpriteColorMulti){
    lda Sprite.ColorMode
    SetBit( nr )
    sta Sprite.ColorMode
  } else {
    lda Sprite.ColorMode
    ClearBit( nr )
    sta Sprite.ColorMode
  }
  .if(expandMode == SpriteExpandX || expandMode == SpriteExpandXY){
    lda Sprite.ExpandX
    SetBit( nr )
    sta Sprite.ExpandX
  } else {
    lda Sprite.ExpandX
    ClearBit( nr )
    sta Sprite.ExpandX
  }
  .if(expandMode == SpriteExpandY || expandMode == SpriteExpandXY){
    lda Sprite.ExpandY
    SetBit( nr )
    sta Sprite.ExpandY
  } else {
    lda Sprite.ExpandY
    ClearBit( nr )
    sta Sprite.ExpandY
  }
  .if(bgPrio){
    lda Sprite.BackgroundPriority
    SetBit( nr )
    sta Sprite.BackgroundPriority
  } else {
    lda Sprite.BackgroundPriority
    ClearBit( nr )
    sta Sprite.BackgroundPriority
  }

}

.macro SpritePosition(nr, posX, posY) {
  mov #posX : Sprite.Positions +nr*2
  .if(posX > $FF) {
    lda Sprite.PosXHiBits
    SetBit(nr)
    sta Sprite.PosXHiBits
  }
  mov #posY : Sprite.Positions+1+nr*2
}


