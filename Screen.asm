#importonce

.namespace Screen {
  .label Width = 320
  .label Height = 200
  .label BorderColor = $d020
  .label BackgroundColor = $d021
  .label RasterLine = $d012
  .label Content = $0400
  .label CharColor = $d800
}

.macro print(msgAddr, column, row, color) {
  .var offset = row * 40 + column
  ldx #0
for_x:
  lda msgAddr,x
  beq exit
  sta Screen.Content + offset,x
  lda #color
  sta Screen.CharColor + offset,x
  inx
  jmp for_x
exit:
}

.macro clear(msgAddr, column, row) {
  .var offset = row * 40 + column
  ldx #0
for_x:
  lda msgAddr,x
  beq exit
  lda #' '
  sta Screen.Content + offset,x
  inx
  jmp for_x
exit:
}
