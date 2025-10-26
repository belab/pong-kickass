#importonce

/* MULT2: multiply the accumulator by 2 */
.pseudocommand mult2 {
  asl
}

/* STB: store byte */
.pseudocommand stb value:address {
  lda value
  sta address
}