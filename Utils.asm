#importonce

.macro SetBit(nr) {
    ora #(1 << nr)
}

.macro ClearBit(nr) {
    and #($ff ^ (1 << nr))
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