#importonce

#import "Utils.asm"
#import "Registers.asm"

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
  .label Collisions = $d01E
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
  SetBitAt(nr, Sprite.Active)
  lda #color
  sta Sprite.Colors,x
  .if(colorMode == SpriteColorMulti){
    SetBitAt(nr, Sprite.ColorMode)
  } else {
    ClearBitAt(nr, Sprite.ColorMode)
  }
  .if(expandMode == SpriteExpandX || expandMode == SpriteExpandXY){
    SetBitAt(nr, Sprite.ExpandX)
  } else {
    ClearBitAt(nr, Sprite.ExpandX)
  }
  .if(expandMode == SpriteExpandY || expandMode == SpriteExpandXY){
    SetBitAt(nr, Sprite.ExpandY)
  } else {
    ClearBitAt(nr, Sprite.ExpandY)
  }
  .if(bgPrio){
    SetBitAt(nr, Sprite.BackgroundPriority)
  } else {
    ClearBitAt(nr, Sprite.BackgroundPriority)
  }

}

.macro SpritePosition(nr, posX, posY) {
  mov #posX : Sprite.Positions +nr*2
  .if(posX > $FF) {
    SetBitAt(nr, Sprite.PosXHiBits)
  }
  mov #posY : Sprite.Positions+1+nr*2
}

