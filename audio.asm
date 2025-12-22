
;   timers 11,12,13 used for audio timing

;--------------------------------------
;
;-------------------------------------- ;[[U]]+
ClearAudio      .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

tickFREQ3       .byte $00
tickFREQ4       .byte $00

tblFreq3        .byte $80,$A0,$80,$A0
                .byte $80,$A0,$80,$A0


;   3 channels, 9 sounds    [last byte is unused]
;                     FREQ     WAVE     CTL  ATT  DCY  n/a
tblSounds       .byte $00,$28, $00,$08, $40, $00, $00, $00     ; [0]   putt
                .byte $00,$40, $00,$00, $80, $98, $00, $00     ; [1]   club swing
                .byte $00,$30, $00,$00, $80, $03, $00, $00     ; [2]   hit leaves sound
                .byte $00,$10, $00,$00, $80, $02, $00, $00     ; [3]   ball stuck sound
                .byte $00,$20, $00,$00, $14, $04, $00, $00     ; [4]   }
                .byte $00,$24, $00,$00, $80, $02, $00, $00     ; [5]   } ball in cup?? (group)
                .byte $00,$28, $00,$00, $10, $03, $00, $00     ; [6]   }
                .byte $00,$30, $00,$00, $80, $2A, $00, $00     ; [7]   splash
                .byte $00,$30, $00,$00, $10, $02, $00, $00     ; [8]   input action


;======================================
;
;====================================== ;[[U]]
PlaySoundHighTone .proc
                rts
                .endproc


;======================================
; Ball in cup???
;====================================== ;[[U]]
PlaySoundInCup  .proc
                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
PlaySoundInputAction .proc
                jsr SetVoice1

                ldy #$08                ; sound 8 (input action)
                ldx #$01                ; channel 1
                jsr FetchSound
                jsr PlayAudio

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]+
ProcessAudio    .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
DoRTS3          rts


;======================================
; Play Audio - Putt (with timer)
;====================================== ;[[F]]
PlaySoundPutt   .proc
                jsr SetResonance

                ldy #$00                ; sound 0
                ldx #$00                ; channel 0
                jsr FetchSound
                jsr PlayAudio

                lda #$01
                sta audioTimer

                lda #$05                ; duration
                ldx #$0A                ; timer 10
                jsr SetTimer

                rts
                .endproc


;--------------------------------------
; Play Audio - Driver Swing (with timer)
;-------------------------------------- ;[[F]]
PlaySoundSwingClub .proc
                lda #$2F
                sta audioVolume

                jsr SetChannel

                lda audioChannel
                sec
                sbc #$30

                jsr SetCutoff
                jsr SetResonance
                jsr SetVoice1
                jsr SetVoice1and2

                ldy #$04                ; sound 4
                ldx #$00                ; channel 0
                jsr FetchSound

                ldy #$05                ; sound 5
                inx                     ; channel 1
                jsr FetchSound

                ldy #$06                ; sound 6
                inx                     ; channel 2
                jsr FetchSound
                jsr PlayAudio

                dex                     ; channel 1
                jsr PlayAudio

                dex                     ; channel 0
                jsr PlayAudio

                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]+
SetAudio4       .proc
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]+
SetAudio4Max    .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------
;--------------------------------------


;======================================
;
;====================================== ;[[F]]
SetChannel      .proc
                lda @w polyVertY_HI
                sec
                sbc #$08
                bcs _1

                lda #$00
_1              asl                     ; *4
                asl
                bpl _2

                lda #$7F
_2              clc
                adc #$80
                sta audioChannel

                jsr SetCutoff

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
FetchSound      .proc
                txa                     ; preserve X (channel)
                pha

                tya                     ; sound index
                asl                     ; *8
                asl
                asl
                tay

                lda tblSounds,Y         ; frequency
                sta audioFreq_LO,X
                lda tblSounds+1,Y
                sta audioFreq_HI,X

                lda tblSounds+2,Y       ; pulse wave
                sta audioPulseWave_LO,X
                lda tblSounds+3,Y
                sta audioPulseWave_HI,X

                lda tblSounds+4,Y       ; control
                sta audioControl,X

                lda tblSounds+5,Y       ; attack/decay
                sta audioAttkDcy,X

                lda tblSounds+6,Y       ; sustain/release
                sta audioSusRel,X

                pla                     ; restore X (channel)
                tax
                rts
                .endproc


;--------------------------------------
;--------------------------------------

audioFreq_LO        .byte $00,$00,$00   ; 3 channels, 12 sounds
audioFreq_HI        .byte $00,$00,$00

audioPulseWave_LO   .byte $00,$00,$00
audioPulseWave_HI   .byte $00,$00,$00

audioControl        .byte $00,$00,$00

audioAttkDcy        .byte $00,$00,$00
audioSusRel         .byte $00,$00,$00

audioCutoff_LO      .byte $00
audioCutoff_HI      .byte $40

audioResonanceMask  .byte $F0
audioVolume         .byte $0F
audioChannel        .byte $00
audioCutoffDelta    .byte $00
audioTimer          .byte $00


;======================================
;
;====================================== ;[[V]]
PlayAudio       .proc
                jsr CalcChannelIndex    ; = channel * 7

                lda #$00
                sta SID1_SUREL1,Y

                lda audioFreq_LO,X
                sta SID1_FREQ1,Y
                lda audioFreq_HI,X
                sta SID1_FREQ1+1,Y

                lda audioPulseWave_LO,X
                sta SID1_PULSE1,Y
                lda audioPulseWave_HI,X
                sta SID1_PULSE1+1,Y

                lda audioAttkDcy,X
                sta SID1_ATDCY1,Y

                lda audioSusRel,X
                sta SID1_SUREL1,Y

                lda audioControl,X
                sta SID1_CTRL1,Y

                ora #$01                ; set bit0_Gate
                sta SID1_CTRL1,Y

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
SetResonance    .proc
                lda #$01
_ENTRY1         ora audioResonanceMask
_ENTRY2         sta audioResonanceMask
                sta SID1_RESON

                lda audioVolume
                sta SID1_SIGVOL

                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetVoice2       .proc
                lda #$FE
_ENTRY1         and audioResonanceMask
                jmp SetResonance._ENTRY2

                .endproc


;======================================
;
;====================================== ;[[V]]
SetVoice1       .proc
                lda #$FD
                jmp SetVoice2._ENTRY1

                .endproc


;======================================
;
;====================================== ;[[F]]
SetVoice1and2   .proc
                lda #$FB
                jmp SetVoice2._ENTRY1

                .endproc


;======================================
;
;====================================== ;[[V]]
CalcChannelIndex .proc
                stx audioChannel

                txa
                asl                     ; *8
                asl
                asl

                sec                     ; too much, reduce to *7
                sbc audioChannel

                tay
                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
SetCutoff       .proc
                ldy audioCutoffDelta
                bmi _negative

                clc
                adc audioCutoffDelta
                bcc _apply

                lda #$FF
_apply          sta audioCutoff_HI
                sta SID1_CUTOFF+1
                lda audioCutoff_LO
                sta SID1_CUTOFF

                rts

; - - - - - - - - - - - - - - - - - - -
_negative       clc
                adc audioCutoffDelta
                bcs _apply

                lda #$00
                jmp _apply

                .endproc
