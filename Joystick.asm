#importonce 


// struct JoyStick {
//   constexpr bool up() const { return !Utils::testBit(dataPort, 0); }
//   constexpr bool down() const { return !Utils::testBit(dataPort, 1); }
//   constexpr bool left() const { return !Utils::testBit(dataPort, 2); }
//   constexpr bool right() const { return !Utils::testBit(dataPort, 3); }
//   constexpr bool fire() const { return !Utils::testBit(dataPort, 4); }

//   enum struct Port : uint8_t { A = 1, B };
//   JoyStick(Port port) : dataPort(port == Port::B ? CIA1.pra : CIA1.prb) {}

//   auto direction() const {
//     return Vec2{left() ? -1 : (right() ? 1 : 0), up() ? -1 : (down() ? 1 : 0)};
//   }

//   volatile uint8_t &dataPort;
// };

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
    lda Joystick.PortA
    and #Joystick.Fire
}

// JoystickReadPortA:
//     lda Joystick.PortA
//     and #Joystick.Up
//     mov 
//     rts
