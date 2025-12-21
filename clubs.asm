
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
                adc xPosDeltaBall
                sta xPosBallShadow

                tya
                clc
                adc yPosDeltaBall
                sta yPosBallShadow

                lda #TRUE
                sta isSwingInProgress

                ;;jsr ClearMissile0       ; clear the aim target
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
                jmp SyncGaugeAudio      ;   yes

;--------------------------------------
;   TIMING
_5              cpx #$0B                ; frame 11?
                bne _6                  ;   no
                jmp SetGaugeTiming      ;   yes, switch to TIMING phase (descending)

; - - - - - - - - - - - - - - - - - - -
_6              cpx #$10                ; frame 16?
                bne _7                  ;   no
                jmp SyncGaugeAudio      ;   yes

;--------------------------------------
;   SNAP
_7              cpx #$11                ; frame 17?
                bne _8                  ;   no
                jmp SetGaugeSnap        ;   yes, switch to SNAP phase

; - - - - - - - - - - - - - - - - - - -
_8              cpx #$16                ; frame 22?
                bne _XIT                ;   no
                jmp SyncGaugeAudio      ;   yes

;--------------------------------------
_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[F]]
ResetGauge      .proc
                sei

                jsr DisableTimer2

                lda #$FF
                ;!!sta AUDF1
                sta PlayClubSwing._swingFreq1

                lda #$F0
                ;!!eor audioF2Chaos
                ;!!sta AUDF2
                sta PlayClubSwing._swingFreq2

                jsr PlayClubSwing

                lda #gaugeINACTIVE
                sta gaugeStage

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetGaugePower   .proc
                sei

                jsr DisableTimer2

                lda #$FF
                sta PlayClubSwing._swingFreq1
                ;!!sta AUDF1

                lda #$FF
                sta PlayClubSwing._swingFreq2
                ;!!sta AUDF2

                lda #$00
                sta gaugeValue          ; reset

                jsr PlayClubSwing

                lda #gaugeASCENDING
                sta gaugeStage          ; = Power Increasing

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetGaugeTiming  .proc
                sei

                jsr DisableTimer2

                lda #$86
                sta PlayClubSwing._swingFreq1
                ;!!sta AUDF1

                lda #$5C
                sta PlayClubSwing._swingFreq2
                ;!!sta AUDF2

                lda #$10
                sta gaugeValue          ; = peak power

                jsr PlayClubSwing

                lda #gaugeDESCENDING
                sta gaugeStage          ; = Power Decreasing

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetGaugeSnap    .proc
                sei

                jsr DisableTimer2

                lda #$06
                sta PlayClubSwing._swingFreq1
                ;!!sta AUDF1

                lda #$46
                sta PlayClubSwing._swingFreq2
                ;!!sta AUDF2

                lda #$20
                sta gaugeValue          ; beginning of snap

                jsr PlayClubSwing

                lda #gaugeSNAP
                sta gaugeStage

                cli
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
SyncGaugeAudio  .proc
                sei

                jsr DisableTimer2

                ldx gaugeStage
                dex                     ; clamp to range[0:2]

                lda gaugeValue
                sta cacheGaugeValue,X

                lda PlayClubSwing._swingFreq1
                sta cacheSwingFreq1,X

                lda PlayClubSwing._swingFreq2
                sta cacheSwingFreq2,X

                cpx #$02                ; =snap?
                bne _1                  ;   no

                jsr ResetGauge

_1              cli
                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
DisableTimer2   .proc
                ;!!lda POKMSK
                ;!!and #$FD                ; disable timer-2
                ;!!sta POKMSK
                ;!!sta IRQEN

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
PlayClubSwing   .proc
                lda _swingFreq1
                ;!!sta AUDF1
                lda _swingFreq2
                ;!!sta AUDF2
                ;!!sta STIMER

                ;!!lda POKMSK
                ;!!ora #$02                ; enable timer-2
                ;!!sta POKMSK
                ;!!sta IRQEN

                rts

;--------------------------------------

_swingFreq1     .byte $FF
_swingFreq2     .byte $FF

                .endproc
