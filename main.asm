
;--------------------------------------
;
;-------------------------------------- ;[[F]]
NewGame         .proc
                jsr ResetGame
                jsr SetAudSwing
                jsr DoConfig

                jsr ClearScreen

                lda #$00
                sta activePlayer
                sta isSwingDisabled
                sta isSwingInProgress
                sta swingAnimCounter    ; reset
                sta arrDeferredSum
                sta arrDeferredSum+1
                sta arrDeferredSum+2
                sta isSwingAnimCounterActive

                lda #$3C
                sta const_60

                lda #$00
                sta idxActiveHole       ; first hole

                lda #unitYARDS
                sta idxDistanceUnit

                jmp PlayNextHole

                .endproc


;======================================
;
;====================================== ;[[F]]
ResetGame       .proc
                lda numPlayers
                pha
                lda gameLength
                pha

;   preserve courses
                ldx #$03
_next1          lda tblCourseIndexes,X
                pha

                dex
                bpl _next1

;   clear state
                jsr ClearGameState

;   restore courses
                ldx #$00                ; pull in reverse
_next2          pla
                sta tblCourseIndexes,X

                inx
                cpx #$04
                bne _next2

                pla
                sta gameLength
                pla
                sta numPlayers

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
AdvNextScanline_D4 .proc
_ptr            = zpD4
;---

                pha                     ; preserve

                lda _ptr
                clc
                adc #<$0028             ; +40
                sta _ptr
                lda _ptr+1
                adc #>$0028
                sta _ptr+1

                pla                     ; restore
                rts
                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
PlayNextHole    .proc
                lda #FALSE
                sta isTeeOffDone
                sta unused_9D75

                jsr CalcHonorRanking
                jsr InitPlayers
                jsr SetWindRandom

                ldx holeInfoPolyCount
                dex
                stx unused_9D72         ; =$FF

                stz offscreenPlane

_next1          jsr SetNextPlayer

                lda #$00
                sta tickFREQ3           ; disable

                jsr ProcessStroke
                jmp _next1

                .endproc


;--------------------------------------
;-------------------------------------- ;[[U]]
SetStage3       .proc
                jsr ResetHW
                jsr ClearAllPlayers
                jsr ClearMissiles

                lda #stageCONFIG
                sta nStage

                jsr DrawScoreboard
                ;;jsr RenderCourseNo
                ;;jsr UpdateScore

                lda numPlayers
                sta idxPlayer

_next1          ;;jsr RenderPlayerName
                ;;jsr Render5Digits
                ;;jsr Render4Digits
                ;;jsr Render2or3Digits
                ;;jsr Render2or3Digits_2
                ;;jsr DoNothing3

                dec idxPlayer
                bpl _next1
                jmp InitScreenHW

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
GoNextHole      .proc
                jsr SetStage3
                jsr WaitForButton

                inc idxActiveHole
                lda idxActiveHole
                cmp #18                 ; finished?
                bne PlayNextHole        ;   no

                jsr ClearScore._preservehistory

                lda #$00
                sta idxActiveHole       ; first hole

                inc idxActiveCourse     ; next course
                lda idxActiveCourse
                cmp gameLength          ; finished?
                beq PlayNextHole        ;   no
                bcc PlayNextHole        ;   no

                jmp NewGame             ; done

                .endproc


;======================================
;
;====================================== ;[[U]]
MainLoop        .proc
                jsr ResetSwingGauge

                lda #$00
                sta flags_9D76
                sta tickFREQ3           ; disable
                sta gaugeValue          ; reset

                ldx activePlayer
                lda playerClub,X
                sta activeClub

                ;!!jsr DoWindStreamer
                ;!!jsr InitSprites
                jsr AimTarget
                jsr InitBall

                lda #$00
                sta animBallFrame
                sta nodeOperation       ; operPIXEL

                jsr DrawClub

                lda isDrivingRange      ; driving range?
                bne _next1              ;   yes

                jsr DrawDistanceToPin_m1

_next1          jsr ChangeClub
                jsr AimTarget._SKIPBALL
                jsr GetUserInput

                lda #$C0                ; ball(bit-6) and shadow(bit-7) are visible
                sta flagsBall_9D81
                sta flagsBall_9D83
                sta flags_BallVisible
                sta flagsBall_9DAF

                jsr ProcessESC
                jsr DemoInput
                jsr DrawClock

                lda CONSOL
                and #$04                ; OPTION pressed?
                bne _1                  ;   no

;   /// OPTION ///
                jsr PlaySoundInputAction

                pla
                pla
                pla
                pla
                jmp GoNextHole

; - - - - - - - - - - - - - - - - - - -
_1              lda isSwingInProgress   ; swing anim in progress?
                beq _next1              ;   no

_next2          jsr AudioSwingControl
                jsr ProcessAudio
                jsr DemoInput

                lda golferSwingFrame
                cmp #$10                ; =16?
                bne _next2              ;   no

                jsr PowerLocked

_next3          jsr AudioSwingControl
                jsr ProcessAudio
                jsr DrawClock
                jsr DemoInput

                lda swingAnimCounter
                bne _2

                lda golferSwingFrame
                cmp #$13
                bne _next3

                jsr RenderStrokeCount
                jsr InitStroke

_2              jsr Swing_math_326F
                jsr DemoInput
                jsr PositionBallShadow
                ;;jsr CalcBallPixelMask
                jsr AnimateBall_2AC6
                jsr RenderBall

                lda golferSwingFrame
                cmp #$16
                bne _next3

                jsr SnapLocked

                ldx snapValue
                jsr CalcAccuracyPenalty

_next4          jsr AudioSwingControl
                jsr ProcessAudio
                jsr Swing_math_326F
                jsr PositionBallShadow
;                ;;jsr CalcBallPixelMask
                jsr AnimateBall_2AC6
                jsr Swing_3E71
                ;;jsr CalcPixelMask
                jsr RenderBall

_next5          jsr AnimateBall
                jsr SetAudio4Max
                jsr DrawClock

                lda swingAnimCounter
                bne _next4

                lda animBallFrame
                bne _next5

                lda #$40
                bit flags_BallVisible   ; ball(bit-6) is visible?
                bne _3

                jsr PlaySoundHighTone

                lda #$01
                sta flags_9D76

_3              jsr DrivingRange0
                jsr DrivingRange1

                lda flags_9D76
                ora isDrivingRange
                beq _4

                jsr SetTimer0
                jsr ProcessClubSwingAnim    ; render club
                jsr ClearMissiles
                jsr ClearAllPlayers
                jmp MainLoop

;--------------------------------------
_4              jsr SetTimer0
                jsr ProcessClubSwingAnim    ; render club
                jsr ClearMissiles
                jsr ClearAllPlayers

                lda counterDemo         ; demo mode?
                beq _5                  ;   no

                inc counterDemo

                stz joystickOverride    ; no input

_5              lda #$2F
                ;!!sta unused_5573

                jmp ClearAudio

                .endproc


;======================================
;
;====================================== ;[[F]]
DrivingRange1   .proc
                lda isDrivingRange      ; driving range?
                bne _1                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              ldx #<$1800
                lda #>$1800
                stx wordA_course
                sta wordA_course+1

                lda #>$0500
                stx wordB_course
                sta wordB_course+1

;   distance formula
                jsr calcHypotenuseArea  ; dword result
                jsr calcSquareRoot      ; word result
                stx wordB_3CBE
                sty wordB_3CBE+1

                lda #<$0024             ; 36 inches/yard
                sta wordA_3CBC
                lda #>$0024
                sta wordA_3CBC+1

                jsr DivideWordBbyWordA  ; result in wordB+wordC[remainder]

;   save distance to pin value
                lda wordB_3CBE
                sta distanceToPinYards
                lda wordB_3CBE+1
                sta distanceToPinYards+1

                ldx #stagePLAY
                stx nStage

                jmp DrawDistanceToPin

                .endproc


;======================================
;
;====================================== ;[[F]]
DrivingRange0   .proc
                lda isDrivingRange      ; driving range?
                bne _1                  ;   yes

_XIT1           rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              lda flags_BallVisible   ; ball(bit-6) is visible?
                and #$40
                and flagsBall_9D81
                and flagsBall_9D83
                beq _XIT1

                ldx #$06                ; missile-1 (ball)
                jsr CalcMissilePosition ; result [X,Y]

                lda #COLOR_BLACK
                sta pixelColor

                jmp RenderPixel

                .endproc


;======================================
;
;====================================== ;[[V]]
SetTimer0       .proc
_40             lda #40
                .byte $2C               ; consume the following LDA operation
_32             lda #32
                .byte $2C               ; consume
_56             lda #56
                .byte $2C               ; consume
_64             lda #64

                ldx #$00                ; timer 0
                jsr SetTimer

;   wait for timer
_wait1          lda timerIsActive       ; timer 0 active?
                bne _wait1              ;   yes

                rts
                .endproc


;======================================
;
;--------------------------------------
; called from interrupt
;====================================== ;[[F]]
Math_DeferredB  .proc
                lda isSwingAnimCounterActive
                bne _1                  ;   yes

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda wordB_3CBE
                pha
                lda wordB_3CBE+1
                pha

                lda wordC_3CC0
                pha
                lda wordC_3CC0+1
                pha

                lda wordA_3CBC
                pha
                lda wordA_3CBC+1
                pha

                lda wordD_3CC2
                pha
                lda wordD_3CC2+1
                pha

                ldx #$02
_next1          lda temp9D57_puttX_HI,X
                bne _2

                lda temp9D33_puttX_LO,X
                bne _2
                jmp _7

; - - - - - - - - - - - - - - - - - - -
_2              lda temp9D33_puttX_LO,X
                sta wordB_3CBE
                lda temp9D57_puttX_HI,X
                sta wordB_3CBE+1
                stx zpD1

                lda const_60            ; =$3C
                sta wordA_3CBC
                lda #>$003C
                sta wordA_3CBC+1

                jsr DivideWordBbyWordA_ABS  ; result in wordB+wordC[remainder]

                lda wordB_3CBE
                sta strokeCount

                ldx zpD1
                ldy temp9D57_puttX_HI,X
                bpl _3

                eor #$FF
                sec
                adc #$00
                sta strokeCount

                lda wordC_3CC0
                eor #$FF
                sec
                adc #$00
                sta wordC_3CC0

_3              ldx zpD1
                lda arrDeferredSum,X
                clc
                adc wordC_3CC0
                sta arrDeferredSum,X

                sec
                sbc const_60            ; =$3C
                bcc _4

                sta arrDeferredSum,X

                inc strokeCount

_4              lda temp9D57_puttX_HI,X
                bmi _6

                lda polyVertX_LO,X
                clc
                adc strokeCount
                sta polyVertX_LO,X

                lda polyVertX_HI,X
                adc #$00
                sta polyVertX_HI,X

                cmp #$40
                bcc _5

                lda #$00
                sta polyVertX_LO,X

                lda #$40
                sta polyVertX_HI,X

_5              jmp _7

; - - - - - - - - - - - - - - - - - - -
_6              lda polyVertX_LO,X
                sec
                sbc strokeCount
                sta polyVertX_LO,X

                lda polyVertX_HI,X
                sbc #$00
                sta polyVertX_HI,X
                bcs _7

                lda #$00
                sta polyVertX_LO,X
                sta polyVertX_HI,X

_7              dex
                bmi _XIT

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_XIT            pla
                sta wordD_3CC2+1
                pla
                sta wordD_3CC2
                pla
                sta wordA_3CBC+1
                pla
                sta wordA_3CBC
                pla
                sta wordC_3CC0+1
                pla
                sta wordC_3CC0
                pla
                sta wordB_3CBE+1
                pla
                sta wordB_3CBE

                rts
                .endproc
