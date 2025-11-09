BasicUpstart2(next)

#import "Utils.asm"
#import "Sound.asm"

.label DELAY = 100

next:
	SoundInit($0f)

	jsr System.setupRasterInterrupt

loop:
	jmp loop

FrameCountdown: .byte DELAY
