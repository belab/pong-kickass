#importonce

.macro SetBit(nr) {
    ora #(1 << nr)
}

.macro ClearBit(nr) {
    and #($ff ^ (1 << nr))
}
