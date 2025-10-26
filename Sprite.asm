#importonce

#import "Utils.asm"

*=* "Sprite Routines"

.namespace Sprite {
  .label DataPointers = $7f8
  .label Active = $d015
  .label Colors = $d027
  .label ExpandX = $d01d
  .label ExpandY = $d017

}

.function SpritePage(addr) {
  .return (addr & $3fff) / 64
}

.enum {SpriteColorMono, SpriteColorMulti}
.enum {SpriteExpandNO, SpriteExpandX, SpriteExpandY, SpriteExpandXY}
.macro SpriteActivate(nr, addr, color, colorMode, expandMode, bgPrio) {
  lda #SpritePage(addr)
  ldx #nr
  sta Sprite.DataPointers,x
  lda Sprite.Active
  ora #(1 << nr)
  sta Sprite.Active
  lda #color
  sta Sprite.Colors,x
}
