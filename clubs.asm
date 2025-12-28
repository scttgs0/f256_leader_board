
;======================================
;
;====================================== ;[[V]]
GetUserInput    .proc
                stz joystick            ; no input
                jsr ReadJoystick

                lda #joyButton0         ; button pushed?
                bit joystick
                beq _XIT                ;   no

                ldx #xformDELTA_Z
                jsr VertexTransform

                txa
                clc
                adc xMarginOverscan
                sta xPosBallShadow
                stz xPosBallShadow+1

                tya
                clc
                adc yMarginOverscan
                sta yPosBallShadow

                lda #TRUE
                sta isSwingInProgress

                jsr ClearBallShadow
                jmp ClearAimTarget

; - - - - - - - - - - - - - - - - - - -
_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[V]]
ChangeClub      .proc
;   check delay timer
                lda timerIsActive+1     ; timer 1 active?
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              sta joystick            ; reset
                jsr ReadJoystick

                lda #joyUP              ; up deflection?
                bit joystick
                beq _2                  ;   no

;   /// UP ///
                dec activeClub
                bpl _4                  ; no overflow

                lda #$0C                ; overflow, wrap around to the pitching wedge
                sta activeClub

                bra _4

; - - - - - - - - - - - - - - - - - - -
_2              lda #joyDOWN            ; down deflection?
                bit joystick
                bne _3                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
;   /// DOWN ///
_3              inc activeClub
                lda activeClub
                cmp #$0D                ; too far?
                bne _4                  ;   no, we're good

                stz activeClub          ; wrap around to the 1-wood

_4              jsr DrawClub

;   set delay timer to introduce a pause before allowing further club changes
                lda #$18                ; duration
                ldx #$01                ; timer 1
                jsr SetTimer

;   record the club change
                ldx activePlayer
                lda activeClub
                sta playerClub,X

;   play sound
                jmp PlaySoundInputAction

                .endproc


;======================================
;
;====================================== ;[[V]]
DrawClub        .proc
                ldx #stagePLAY
                stx nStage

;   clone the active club text into _activeClub
                lda activeClub
                asl                     ; *2
                pha                     ; preserve

                tax
                lda _golfclub,X         ; first character
                sta _activeClub

                pla                     ; restore
                tax

                lda _golfclub+1,X       ; second character
                sta _activeClub+1

;   render the text
                .frsTextXY 37,17,$90,DrawClub._activeClub

                rts

;--------------------------------------

_activeClub     .null '1W'

_golfclub       .text '1W'              ; [0]
                .text '3W'              ; [1]
                .text '5W'              ; [2]
                .text '1I'              ; [3]
                .text '2I'              ; [4]
                .text '3I'              ; [5]
                .text '4I'              ; [6]
                .text '5I'              ; [7]
                .text '6I'              ; [8]
                .text '7I'              ; [9]
                .text '8I'              ; [A]
                .text '9I'              ; [B]
                .text 'PW'              ; [C]

                .endproc


;======================================
;
;====================================== ;[[F]]
SwingAnimControl .proc
                lda isSwingInProgress   ; swing anim in progress?
                bne _1                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              lda timerIsActive       ; timer 0 active?
                beq _2                  ;   no

                rts

; - - - - - - - - - - - - - - - - - - -
_2              inc golferSwingFrame
                ldx golferSwingFrame
                cpx #$20                ; =32? (MAX)
                bne _3                  ;   no

                lda #FALSE              ;   yes, stop swing animation
                sta isSwingInProgress

                lda #$FF
                sta golferSwingFrame

                rts

; - - - - - - - - - - - - - - - - - - -
_3              lda tblDuration,X       ; duration
                ldx #$00                ; timer #0
                jsr SetTimer

;--------------------------------------
;   POWER
                ldx golferSwingFrame
                cpx #$01                ; frame 1?
                bne _4                  ;   no
                jmp SetGaugePower       ;   yes, switch to POWER phase (ascending)

; - - - - - - - - - - - - - - - - - - -
_4              cpx #$0A                ; frame 10? (max backswing)
                bne _5                  ;   no
                jmp SyncSwingGauge      ;   yes

;--------------------------------------
;   TIMING
_5              cpx #$0B                ; frame 11?
                bne _6                  ;   no
                jmp SetGaugeTiming      ;   yes, switch to TIMING phase (descending)

; - - - - - - - - - - - - - - - - - - -
_6              cpx #$10                ; frame 16?
                bne _7                  ;   no
                jmp SyncSwingGauge      ;   yes

;--------------------------------------
;   SNAP
_7              cpx #$11                ; frame 17?
                bne _8                  ;   no
                jmp SetGaugeSnap        ;   yes, switch to SNAP phase

; - - - - - - - - - - - - - - - - - - -
_8              cpx #$16                ; frame 22?
                bne _XIT                ;   no
                jmp SyncSwingGauge      ;   yes

;--------------------------------------
_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[U]]
ResetGauge      .proc
                sei

                jsr DisableTimer16bit

                lda #>$FFF0             ; $1B4F5E / $FFF0 = $1B (1/27 sec)
                ;!!sta AUDF1               ; 16-bit timer duration (HI)
                sta EnableTimer16bit._tmrDuration_HI

                lda #<$FFF0
                eor DoTimers.timer16bitMask_LO
                ;!!sta AUDF2               ; 16-bit timer duration (LO)
                sta EnableTimer16bit._tmrDuration_LO

                jsr EnableTimer16bit

                lda #gaugeINACTIVE
                sta gaugeStage

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
SetGaugePower   .proc
                sei

                jsr DisableTimer16bit

                lda #>$FFFF             ; $1B4F5E / $FFFF = $1B (1/27 sec)
                sta EnableTimer16bit._tmrDuration_HI
                ;!!sta AUDF1               ; 16-bit timer duration (HI)

                lda #<$FFFF
                sta EnableTimer16bit._tmrDuration_LO
                ;!!sta AUDF2               ; 16-bit timer duration (LO)

                stz gaugeValue          ; reset

                jsr EnableTimer16bit

                lda #gaugeASCENDING
                sta gaugeStage          ; = Power Increasing

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
SetGaugeTiming  .proc
                sei

                jsr DisableTimer16bit

                lda #>$865C             ; $1B4F5E / $865C = $34 (1/52 sec)
                sta EnableTimer16bit._tmrDuration_HI
                ;!!sta AUDF1               ; 16-bit timer duration (HI)

                lda #<$865C
                sta EnableTimer16bit._tmrDuration_LO
                ;!!sta AUDF2               ; 16-bit timer duration (LO)

                lda #$10
                sta gaugeValue          ; = peak power

                jsr EnableTimer16bit

                lda #gaugeDESCENDING
                sta gaugeStage          ; = Power Decreasing

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
SetGaugeSnap    .proc
                sei

                jsr DisableTimer16bit

                lda #>$0646             ; $1B4F5E / $0646 = $45A (1/1114 sec)
                sta EnableTimer16bit._tmrDuration_HI
                ;!!sta AUDF1               ; 16-bit timer duration (HI)

                lda #<$0646
                sta EnableTimer16bit._tmrDuration_LO
                ;!!sta AUDF2               ; 16-bit timer duration (LO)

                lda #$20
                sta gaugeValue          ; beginning of snap

                jsr EnableTimer16bit

                lda #gaugeSNAP
                sta gaugeStage

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SyncSwingGauge  .proc
                sei

                jsr DisableTimer16bit

                ldx gaugeStage
                dex                     ; clamp to range[0:2]

                lda gaugeValue
                sta cacheGaugeValue,X

                lda EnableTimer16bit._tmrDuration_HI
                sta cacheTimer16bit_HI,X
                lda EnableTimer16bit._tmrDuration_LO
                sta cacheTimer16bit_LO,X

                cpx #$02                ; =snap?
                bne _1                  ;   no

                jsr ResetGauge

_1              cli
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
DisableTimer16bit .proc
                ;!!lda POKMSK
                ;!!and #$FD                ; disable 16-bit timer
                ;!!sta POKMSK
                ;!!sta IRQEN

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
EnableTimer16bit    .proc
                lda _tmrDuration_HI
                ;!!sta AUDF1               ; 16-bit timer duration (HI)
                lda _tmrDuration_LO
                ;!!sta AUDF2               ; 16-bit timer duration (LO)
                ;!!sta STIMER              ; begin countdown

                ;!!lda POKMSK
                ;!!ora #$02                ; enable 16-bit timer (count down to zero)
                ;!!sta POKMSK
                ;!!sta IRQEN

                rts

;--------------------------------------

_tmrDuration_HI .byte $FF
_tmrDuration_LO .byte $FF

                .endproc
