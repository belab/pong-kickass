#importonce
#import "Utils.asm"


// param vol max = $0f
.macro SoundInit(vol) {
    lda #(vol & $0f)
    sta Sound.Volume
}

.namespace Sound {
    .label Volume = $d418
    .label Freq1 = $d400
    .label Freq1L = $d400
    .label Freq1H = $d401
    .label AtkDecy1 = $d405
    .label SusRel1 = $d406
    .label Freq2 = $d407
    .label Freq2L = $d407
    .label Freq2H = $d408
    .label Wave2 = $d40b // NOISE = 129;RECT = 65; SAW = 33; TRI = 17
    .label AtkDecy2 = $d40c
    .label SusRel2 = $d40d
    .label Wave1GateOn = $d404

    hold:{
        dec HoldTime
        bne done
        mov #$10 : Wave1GateOn       // Gate off
    done:
        rts
    }

    StopMusic:{
        lda #$00
        sta PlayMusic.CurrentNote
        sta PlayMusic.Playing
        sta Wave2
        rts
    }

    PlayMusic:{
    	lda Playing
        beq done
        dec FrameCountdown
        bne done
        ldx CurrentNote
        inc CurrentNote

        lda Song.NotesL,x
        cmp #$FF
        bne !+
        jsr StopMusic
        rts
    !:	sta Sound.Freq2L
        mov Song.NotesH,x : Sound.Freq2H

        mov #$00 : Sound.AtkDecy2     // Attack=0, Decay=0
        mov #$19 : Sound.SusRel2      // Sustain=max, Release=0
        mov #$51 : Sound.Wave2        // Triangle waveform
        mov #40 : FrameCountdown
    done:
        rts

    CurrentNote: .byte 0
    FrameCountdown: .byte 5        
    Playing: .byte 0

    }

// =====================================================
// RetriggerVoice1
// Stops any current sound and immediately starts new one
// X/Y: new frequency (lo/hi) e.g. 0, 5
// =====================================================
bounce:
    txa
    sta Freq1L           // freq low byte
    tya
    sta Freq1H           // freq high byte

    mov #$09 : AtkDecy1     // Attack=0, Decay=0
    mov #$f9 : SusRel1      // Sustain=max, Release=0
    mov #$11 : Wave1GateOn   // Gate on + Triangle waveform

    mov #5 : HoldTime
    rts

noise:
    mov #5 : Freq1L
    mov #1 : Freq1H
    mov #$15 : AtkDecy1
    mov #$5b : SusRel1
    mov #$81 : Wave1GateOn   // Gate on + noise waveform

    mov #30 : HoldTime
    rts

HoldTime: .byte 5
}


Song: {
	NotesH: .byte $04, $04, $04, $05, $04, $06, $06, $06, $06, $FF
	NotesL: .byte $54, $54, $54, $26, $dc, $df, $df, $7c, $7c, $FF
}