#importonce 

.namespace Joystick {
    .label PortA = $dc00
    .label PortB = $dc01
    .label Up = $01
    .label Down = $02
    .label Left = $04
    .label Right = $08
    .label Fire = $10
}

.macro JoystickUp(portAddr) {
    lda portAddr
    and #Joystick.Up
}
.macro JoystickDown(portAddr) {
    lda portAddr
    and #Joystick.Down
}
.macro JoystickFire(portAddr) {
    lda portAddr
    and #Joystick.Fire
}

