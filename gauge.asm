
;======================================
;
;====================================== ;[[V]]
DoSwingGauge    .proc
                lda gaugeStage          ; is gaugeINACTIVE?
                beq _XIT                ;   yes

                jsr PowerMeterIncr      ; stage 1
                jsr PowerMeterDecr      ; stage 2
                jsr SnapMeter           ; stage 3
                jsr PowerTiming         ; stage 2

                inc gaugeValue

_XIT            jmp EnableTimer16bit

                .endproc


;======================================
;
;====================================== ;[[V]]
ResetSwingGauge .proc
                lda #<sprGaugeClean
                sta zpSource
                lda #>sprGaugeClean
                sta zpSource+1

                lda #<sprGauge
                sta zpDest
                lda #>sprGauge
                sta zpDest+1

                ldx #$04                ; 4 pages
_nextPage       ldy #$00
_next1          lda (zpSource),Y
                sta (zpDest),Y

                iny
                bne _next1

                inc zpSource+1
                inc zpDest+1

                dex
                bne _nextPage

                lda #$00
                sta swingAnimCounter    ; reset
                sta isPowerLocked       ; =false
                sta isSnapLocked        ; =false

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
PowerMeterIncr  .proc
                lda gaugeStage
                cmp #gaugeASCENDING     ; is Power increasing?
                beq _1                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              lda isPowerLocked
                beq _2                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_2              jsr CapturePower

                lda gaugeValue
                cmp #$10                ; max value [16]?
                bcc _3                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_3              tax                     ; scanline to update

                lda #<sprPowerFill
                sta zpSource
                lda #>sprPowerFill
                sta zpSource+1

                lda _powerAddr_LO,X
                sta zpDest
                lda _powerAddr_HI,X
                sta zpDest+1

                ldy #$0F
_next1          lda (zpSource),Y
                sta (zpDest),Y

                dey
                bpl _next1

                rts

;--------------------------------------

_powerAddr_HI   .byte >sprGauge+(15*32)
                .byte >sprGauge+(14*32)
                .byte >sprGauge+(13*32)
                .byte >sprGauge+(12*32)
                .byte >sprGauge+(11*32)
                .byte >sprGauge+(10*32)
                .byte >sprGauge+(9*32)
                .byte >sprGauge+(8*32)
                .byte >sprGauge+(7*32)
                .byte >sprGauge+(6*32)
                .byte >sprGauge+(5*32)
                .byte >sprGauge+(4*32)
                .byte >sprGauge+(3*32)
                .byte >sprGauge+(2*32)
                .byte >sprGauge+(1*32)
                .byte >sprGauge+(0*32)

_powerAddr_LO   .byte <sprGauge+(15*32)
                .byte <sprGauge+(14*32)
                .byte <sprGauge+(13*32)
                .byte <sprGauge+(12*32)
                .byte <sprGauge+(11*32)
                .byte <sprGauge+(10*32)
                .byte <sprGauge+(9*32)
                .byte <sprGauge+(8*32)
                .byte <sprGauge+(7*32)
                .byte <sprGauge+(6*32)
                .byte <sprGauge+(5*32)
                .byte <sprGauge+(4*32)
                .byte <sprGauge+(3*32)
                .byte <sprGauge+(2*32)
                .byte <sprGauge+(1*32)
                .byte <sprGauge+(0*32)

                .endproc


;======================================
; Power held beyond peak... decrease
;====================================== ;[[V]]
PowerMeterDecr  .proc
                lda gaugeStage
                cmp #gaugeDESCENDING    ; is Power decreasing?
                beq _1                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              jsr CapturePower

                lda isPowerLocked
                beq _2                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_2              lda gaugeValue
                cmp #$10                ; >=16? (beyond peak)
                bcs _3                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_3              cmp #$20                ; at max value?
                bcc _4                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_4              sec
                sbc #$10                ; clamp to range[0:15]
                tax                     ; scanline to update

                lda #<sprPowerReduce
                sta zpSource
                lda #>sprPowerReduce
                sta zpSource+1

                lda _powerAddr_LO,X
                sta zpDest
                lda _powerAddr_HI,X
                sta zpDest+1

                ldy #$0F
_next1          lda (zpSource),Y
                sta (zpDest),Y

                dey
                bpl _next1

                rts

;--------------------------------------

_powerAddr_HI   .byte >sprGauge+(0*32)
                .byte >sprGauge+(1*32)
                .byte >sprGauge+(2*32)
                .byte >sprGauge+(3*32)
                .byte >sprGauge+(4*32)
                .byte >sprGauge+(5*32)
                .byte >sprGauge+(6*32)
                .byte >sprGauge+(7*32)
                .byte >sprGauge+(8*32)
                .byte >sprGauge+(9*32)
                .byte >sprGauge+(10*32)
                .byte >sprGauge+(11*32)
                .byte >sprGauge+(12*32)
                .byte >sprGauge+(13*32)
                .byte >sprGauge+(14*32)
                .byte >sprGauge+(15*32)

_powerAddr_LO   .byte <sprGauge+(0*32)
                .byte <sprGauge+(1*32)
                .byte <sprGauge+(2*32)
                .byte <sprGauge+(3*32)
                .byte <sprGauge+(4*32)
                .byte <sprGauge+(5*32)
                .byte <sprGauge+(6*32)
                .byte <sprGauge+(7*32)
                .byte <sprGauge+(8*32)
                .byte <sprGauge+(9*32)
                .byte <sprGauge+(10*32)
                .byte <sprGauge+(11*32)
                .byte <sprGauge+(12*32)
                .byte <sprGauge+(13*32)
                .byte <sprGauge+(14*32)
                .byte <sprGauge+(15*32)

                .endproc


;======================================
;
;====================================== ;[[V]]
PowerTiming     .proc
                lda gaugeStage
                cmp #gaugeDESCENDING    ; is the gauge moving downward?
                beq _1                  ;   yes

_XIT1           rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              lda gaugeValue
                cmp #$10                ; less than peak?
                bcc _XIT1               ;   yes

; - - - - - - - - - - - - - - - - - - -
_2              sec
                sbc #$10                ; clamp to range[0:15]
                tax                     ; scanline to update

                lda #<sprTimingFill
                sta zpSource
                lda #>sprTimingFill
                sta zpSource+1

_3              lda _timingAddr_LO,X
                sta zpDest
                lda _timingAddr_HI,X
                sta zpDest+1

                ldy #$0F
_next1          lda (zpSource),Y
                sta (zpDest),Y

                dey
                cpy #$07
                bne _next1

                rts

;--------------------------------------

_timingAddr_HI  .byte >sprGauge+(0*32)
                .byte >sprGauge+(1*32)
                .byte >sprGauge+(2*32)
                .byte >sprGauge+(3*32)
                .byte >sprGauge+(4*32)
                .byte >sprGauge+(5*32)
                .byte >sprGauge+(6*32)
                .byte >sprGauge+(7*32)
                .byte >sprGauge+(8*32)
                .byte >sprGauge+(9*32)
                .byte >sprGauge+(10*32)
                .byte >sprGauge+(11*32)
                .byte >sprGauge+(12*32)
                .byte >sprGauge+(13*32)
                .byte >sprGauge+(14*32)
                .byte >sprGauge+(15*32)

_timingAddr_LO  .byte <sprGauge+(0*32)
                .byte <sprGauge+(1*32)
                .byte <sprGauge+(2*32)
                .byte <sprGauge+(3*32)
                .byte <sprGauge+(4*32)
                .byte <sprGauge+(5*32)
                .byte <sprGauge+(6*32)
                .byte <sprGauge+(7*32)
                .byte <sprGauge+(8*32)
                .byte <sprGauge+(9*32)
                .byte <sprGauge+(10*32)
                .byte <sprGauge+(11*32)
                .byte <sprGauge+(12*32)
                .byte <sprGauge+(13*32)
                .byte <sprGauge+(14*32)
                .byte <sprGauge+(15*32)

                .endproc


;======================================
;
;====================================== ;[[F]]
SnapMeter       .proc
                lda gaugeStage
                cmp #gaugeSNAP          ; is Snap?
                beq _1                  ;   yes

_XIT1           rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              lda isSnapLocked
                bne _XIT1               ;   yes

                jsr CaptureSnap

                lda gaugeValue
                cmp #$20                ; =top?
                bne _2                  ;   no

                ldx #$00                ;   yes, do timing gap
                lda #<sprTimingGap
                sta zpSource
                lda #>sprTimingGap
                sta zpSource+1

                bra _4

_2              cmp #$30                ; >=48?
                bcs _XIT1               ;   yes

                cmp #$28                ; =40? (mid-point)
                bne _3                  ;   no

                ldx #$08                ;   yes
                lda #<sprSnapMid
                sta zpSource
                lda #>sprSnapMid
                sta zpSource+1

                bra _4

; - - - - - - - - - - - - - - - - - - -
_3              sec
                sbc #$20                ; clamp to range[1:15]
                tax                     ; scanline to update

                lda #<sprSnapFill
                sta zpSource
                lda #>sprSnapFill
                sta zpSource+1

_4              lda _snapAddr_LO,X
                sta zpDest
                lda _snapAddr_HI,X
                sta zpDest+1

                ldy #$0F
_next1          lda (zpSource),Y
                sta (zpDest),Y

                dey
                bpl _next1

_XIT            rts

;--------------------------------------

_snapAddr_HI    .byte >sprGauge+(16*32) ; gap

                .byte >sprGauge+(17*32)
                .byte >sprGauge+(18*32)
                .byte >sprGauge+(19*32)
                .byte >sprGauge+(20*32)
                .byte >sprGauge+(21*32)
                .byte >sprGauge+(22*32)
                .byte >sprGauge+(23*32)
                .byte >sprGauge+(24*32) ; mid-point
                .byte >sprGauge+(25*32)
                .byte >sprGauge+(26*32)
                .byte >sprGauge+(27*32)
                .byte >sprGauge+(28*32)
                .byte >sprGauge+(29*32)
                .byte >sprGauge+(30*32)
                .byte >sprGauge+(31*32)

_snapAddr_LO    .byte <sprGauge+(16*32) ; gap

                .byte <sprGauge+(17*32)
                .byte <sprGauge+(18*32)
                .byte <sprGauge+(19*32)
                .byte <sprGauge+(20*32)
                .byte <sprGauge+(21*32)
                .byte <sprGauge+(22*32)
                .byte <sprGauge+(23*32)
                .byte <sprGauge+(24*32) ; mid-point
                .byte <sprGauge+(25*32)
                .byte <sprGauge+(26*32)
                .byte <sprGauge+(27*32)
                .byte <sprGauge+(28*32)
                .byte <sprGauge+(29*32)
                .byte <sprGauge+(30*32)
                .byte <sprGauge+(31*32)

                .endproc


;======================================
;
;====================================== ;;[F]
CapturePower    .proc
                lda isPowerLocked
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              sta joystick            ; =0, no input

                jsr ReadJoystick

                lda #$10
                bit joystick            ; button down?
                bne _XIT                ;   yes

                lda #$00                ;   no, no input
                sta joystick

                lda #TRUE
                sta isPowerLocked

                lda gaugeValue
                cmp #$10                ; past peak power?
                bcs _2                  ;   yes

                sta powerValue          ;   no, lock it in

                rts

; - - - - - - - - - - - - - - - - - - -
_2              ldx gaugeStage
                cpx #gaugeDESCENDING    ; stage >= Power Decrease?
                bcs _3                  ;   yes

                lda #$0F                ;   no
                sta powerValue

                rts

; - - - - - - - - - - - - - - - - - - -
_3              cmp #$20
                bcs _XIT

                eor #$FF                ; flip the bits
                and #$0F
                sta powerValue

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[F]]
PowerLocked     .proc
                lda isPowerLocked
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              sta powerValue

                lda #TRUE
                sta isPowerLocked

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
CaptureSnap     .proc
                lda isSnapLocked
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              sta joystick            ; =0, no input

                jsr ReadJoystick

                lda #joyButton0         ; button pushed?
                bit joystick
                beq _XIT                ;   no

                stz joystick            ;   yes, reset button

                lda #TRUE
                sta isSnapLocked

                lda gaugeValue
                cmp #$30                ; <48? (max value)
                bcc _2                  ;   yes

                lda #$2F                ; clamp
_2              and #$0F
                beq _3

                sec
                sbc #$01
_3              sta snapValue

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[F]]
SnapLocked      .proc
                lda isSnapLocked
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              lda #$0E
                sta snapValue

                lda #TRUE
                sta isSnapLocked

                rts
                .endproc
