#importonce

.macro SetBit(nr) {
    ora #(1 << nr)
}

.macro SetBitAt(nr, addr) {
    lda addr
    SetBit(nr)
    sta addr
}

.macro ClearBit(nr) {
    and #($ff ^ (1 << nr))
}

.macro ClearBitAt(nr, addr) {
    lda addr
    ClearBit(nr)
    sta addr
}

.macro TestBit(nr) {
    and #(1 << nr)
}

.macro TestBitAt(nr, addr) {
    lda addr
    and #(1 << nr)
}

.macro ToggleBitAt(nr, addr) {
    lda #(1 << nr)
    and addr
    sta addr
}

.function _16bitnextArgument(arg) {
    .if (arg.getType()==AT_IMMEDIATE)
        .return CmdArgument(arg.getType(),>arg.getValue())
    .return CmdArgument(arg.getType(),arg.getValue()+1)
}

/* MULT2: multiply the accumulator by 2 */
.pseudocommand mult2 {
  asl
}

/* move source to target */
.pseudocommand mov src:tar {
  lda src
  sta tar
}

.pseudocommand mov16 src:tar {
    lda src
    sta tar
    lda _16bitnextArgument(src)
    sta _16bitnextArgument(tar)
}

.pseudocommand inc16 arg {
    inc arg
    bne over
    inc _16bitnextArgument(arg)
over:
}

.pseudocommand dec16 arg {
    lda arg
    bne skip
    dec _16bitnextArgument(arg)
skip:
    dec arg
}

.pseudocommand add16 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg1
    clc
    lda arg1
    adc arg2
    sta tar
    lda _16bitnextArgument(arg1)
    adc _16bitnextArgument(arg2)
    sta _16bitnextArgument(tar)
}

.pseudocommand sub16 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg1
    sec
    lda arg1
    sbc arg2
    sta tar
    lda _16bitnextArgument(arg1)
    sbc _16bitnextArgument(arg2)
    sta _16bitnextArgument(tar)
}

.pseudocommand add8 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg1
    clc
    lda arg1
    adc arg2
    sta tar
}

.pseudocommand sub8 arg1 : arg2 : tar {
    .if (tar.getType()==AT_NONE) .eval tar=arg1
    sec
    lda arg1
    sbc arg2
    sta tar
}