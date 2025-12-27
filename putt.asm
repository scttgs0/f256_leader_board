
;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[F]]
InitPutt_2521   .proc
                jsr CalcProjectile

                lda #$18
                sta polyVertZ_delta

                stz unused_9D28

                lda #$02
                sta unused_9D66

                lda #$FF
                sta temp9D29

                jsr Divide_2040byWordA

                lda #$0A
                sta timerDuration+7     ; timer 7 = 10 ticks
                sta timerRemaining+7

                lda #$01
                sta isSwingAnimCounterActive
                sta swingAnimCounter

                jmp SetAudio4

                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[F]]
DrawGolferPutt  .proc
;   chose proper animation frame
                ldy golferSwingFrame
                ldx puttAnimIndex,Y

                ldx golferSwingFrame
                cmp #$FF
                beq _XIT

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                sei

                lda _anim1Addr_LO,X
                sta SPR(sprite_t.ADDR, 4)
                sta SPR(sprite_t.ADDR, 5)

                lda _anim1Addr_HI,X
                sta SPR(sprite_t.ADDR+1, 4)
                clc
                adc #$04                ; +$400
                sta SPR(sprite_t.ADDR+1, 5)

                lda _anim1Addr_24,X
                sta SPR(sprite_t.ADDR+2, 4)
                sta SPR(sprite_t.ADDR+2, 5)

                cli

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
_XIT            rts

;--------------------------------------

_anim1Addr_24   .byte `anim1cell00,`anim1cell01,`anim1cell02,`anim1cell03
                .byte `anim1cell04,`anim1cell05,`anim1cell06
_anim1Addr_HI   .byte >anim1cell00,>anim1cell01,>anim1cell02,>anim1cell03
                .byte >anim1cell04,>anim1cell05,>anim1cell06
_anim1Addr_LO   .byte <anim1cell00,<anim1cell01,<anim1cell02,<anim1cell03
                .byte <anim1cell04,<anim1cell05,<anim1cell06

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
InitGolferPutt .proc
                stz golferSwingFrame    ; reset
                stz unused_9D74
                stz isBackSwingAnim     ; =FALSE

                lda puttAnimTimer       ; duration
                ldx #$00                ; timer 0
                jsr SetTimer

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                .frsSpriteShow 4        ; player top
                .frsSpriteShow 5        ; player bottom

                .frsSpriteSetX $7E,4    ; player top
                .frsSpriteSetY $B8,4
                .frsSpriteSetX $7E,5    ; player bottom
                .frsSpriteSetY $D8,5

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                jmp DrawGolferPutt

                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[F]]
PuttControl     .proc
; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                jsr ClearAllPlayers
                jsr SwitchToPutt

                stz flags_9D76

                lda #$14
                sta timerDuration+6     ; timer 6 = 20 ticks

                jsr InitGolferPutt
                jsr AimTarget
                jsr XBPC_DrawDistanceToPin_m1

                stz animSplashFrame
                stz nodeOperation       ; operPIXEL

                lda #$C0                ; ball(bit-6) and shadow(bit-7) are visible
                sta flagsBall_9D81
                sta flagsBall_9D83
                sta flags_BallVisible

_next1          jsr AimTarget._SKIPBALL
                jsr PuttInput
                jsr ProcessESC
                jsr DrawClock
                jsr DemoInput

                lda isBackSwingAnim
                beq _next1              ;   no

                jsr ClearMissiles

;   render the ball
                .frsSpriteShow 8
                .frsSpriteSetX xPosBall,8
                .frsSpriteSetY yPosBall,8

_next2          jsr BackSwingAnim
                jsr Swing_math_326F
                jsr PositionBallShadow
                jsr Swing_3E71
                jsr RenderBall
                jsr PuttSlope_54CF
                jsr PlaySoundInCup
                jsr DrawClock

                lda swingAnimCounter
                ora isBackSwingAnim
                ora tickFREQ3           ; 0=disabled
                bne _next2

                lda #FALSE
                sta isSwingAnimCounterActive

                jsr XBPC_IncrementStrokeCount
                jsr SetTimer0

                lda counterDemo         ; demo mode?
                beq _XIT                ;   no

                lda #$BC                ; stuff RUNSTOP-key in the key queue
                sta KEYCODE

                jsr ProcessESC


; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                jmp ClearMissiles

                .endproc


;--------------------------------------
; render the putt power gauge
;--------------------------------------
; Private Procedure
;-------------------------------------- ;[[U]]
RenderPuttGauge .proc
                .frsTextXY 30,12,$70,RenderPuttGauge._scrnBlank

                .frsTextXY 30,13,$30,RenderPuttGauge._scrnClub

                .frsTextXY 30,14,$30,RenderPuttGauge._scrnFeet
                .frsTextXY 37,14,$90,RenderPuttGauge._scrnDistVal

                .frsTextXY 30,15,$70,RenderPuttGauge._scrnBlank

                .frsTextXY 30,16,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,16,$70,RenderPuttGauge._scrnPowerTop
                .frsTextXY 32,16,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,16,$70,RenderPuttGauge._scrnPowerBlank
                .frsTextXY 30,17,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,17,$70,RenderPuttGauge._scrnPowerMid
                .frsTextXY 32,17,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,17,$80,RenderPuttGauge._scrnPower
                .frsTextXY 30,18,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,18,$70,RenderPuttGauge._scrnPowerMid
                .frsTextXY 32,18,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,18,$70,RenderPuttGauge._scrnPowerBlank
                .frsTextXY 30,19,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,19,$70,RenderPuttGauge._scrnPowerMid
                .frsTextXY 32,19,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,19,$70,RenderPuttGauge._scrnPowerBlank
                .frsTextXY 30,20,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,20,$70,RenderPuttGauge._scrnPowerMid
                .frsTextXY 32,20,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,20,$70,RenderPuttGauge._scrnPowerBlank
                .frsTextXY 30,21,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,21,$70,RenderPuttGauge._scrnPowerMid
                .frsTextXY 32,21,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,21,$70,RenderPuttGauge._scrnPowerBlank
                .frsTextXY 30,22,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,22,$70,RenderPuttGauge._scrnPowerMid
                .frsTextXY 32,22,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,22,$70,RenderPuttGauge._scrnPowerBlank
                .frsTextXY 30,23,$70,RenderPuttGauge._scrnPowerLeft
                .frsTextXY 31,23,$70,RenderPuttGauge._scrnPowerMid
                .frsTextXY 32,23,$70,RenderPuttGauge._scrnPowerRight
                .frsTextXY 33,23,$70,RenderPuttGauge._scrnPowerBlank
                .frsTextXY 31,24,$70,RenderPuttGauge._scrnPowerBot
                .frsTextXY 33,24,$70,RenderPuttGauge._scrnPowerBlank

                rts

;--------------------------------------

_scrnBlank      .null "          "
_scrnClub       .null " PUTTER   "

_scrnFeet       .null " FEET     "
_scrnInches     .null " INCHES   "
_scrnDistVal    .null "61"

_scrnPowerBlank .null "       "
_scrnPowerTop   .null $C6
_scrnPower      .null "POWER  "
_scrnPowerMid   .null $C7
_scrnPowerBot   .null $C8
_scrnPowerLeft  .null $C9
_scrnPowerRight .null $CA

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[U]]
PuttInput       .proc
_DEST           = zpFD
;---

                stz joystick            ; no input

                jsr ReadJoystick

                lda #joyButton0         ; button pushed?
                bit joystick
                bne _1                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              stz powerValue          ; reset power value

                ;!!lda #<scrnPuttPower+1   ; screen bottom [31,120]
                ;!!sta _DEST
                ;!!lda #>scrnPuttPower+1
                ;!!sta _DEST+1

                lda #$3F                ; max power = 63
                sta _setLimit+1

; - - - - - - - - - - - - - - - - - - -
;   12-inch power gauge fill loop
_next1          lda #$02                ; duration
                ldx #$00                ; timer 0
                jsr SetTimer

;   wait for timer
_wait1          lda timerIsActive       ; timer 0 active?
                bne _wait1              ;   yes

                ldy #$00
                lda #$28                ; 2-pixel of color-2
                sta (_DEST),Y

                jsr AdvNextScanline     ; move down one line

                inc powerValue
                lda powerValue
                cmp #$08                ; 12-inch meter full?
                bne _next1              ;   no

                lda #$FF                ; reset to -1
                sta powerValue

; - - - - - - - - - - - - - - - - - - -
;   power gauge fill loop
_next2          lda #$02                ; duration
                ldx #$00                ; timer 0
                jsr SetTimer

_next3          lda timerIsActive       ; timer 0 active?
                beq _2                  ;   no

                jsr DrawClock

                stz joystick            ; no input

                jsr ReadJoystick

                lda #joyButton0         ; button pushed?
                bit joystick
                bne _next3              ;   yes

                ldx powerValue          ; limit = current power + 1
                inx
                stx _setLimit+1         ; force exit since button was released

_2              inc powerValue
                lda powerValue

                ldx counterDemo
                cpx #$0A
                bne _3

                cmp #$30                ; <48 feet?
                bcc _3                  ;   yes

                ldx #$00
                stx joystickOverride    ; no input

                inc counterDemo

_3              tax
                ldy #$00
                lda #$AA                ; 4-pixel of color-2
                sta (_DEST),Y

                jsr AdvNextScanline     ; move down one line

_setLimit       cpx #$3F                ; [smc] at limit?
                beq _4                  ;   yes

                jmp _next2              ;   no, continue filling

; - - - - - - - - - - - - - - - - - - -
_4              lda #TRUE
                sta isBackSwingAnim

                rts
                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[U]]
SwitchToPutt    .proc
                jsr ClearSwingGauge

                rts
;_line           = zpD2
;_src            = zpD4
;;---
;
;                lda #$0B                ; line being rendered
;                sta _line
;
;                lda #<_puttPower        ; SRC
;                sta _src
;                lda #>_puttPower
;                sta _src+1
;
;                jsr XBPC_RenderHUD_ENTRY1  ; redraw top portion of HUD
;                jmp RenderPuttGauge        ; draw bottom portion of HUD
;
;;--------------------------------------
;
;_puttPower      .text '          '
;                .text ' PUTTER   '
;                .text '          '      ; distance to cup goes here
;                .text '          '
;
;                .text '          '      ; 1-foot gauge goes here
;                .text $00,$00,$00,'[POWER '
;                .text $00,$00,$00,'\      '
;                .text $00,$00,$00,'\      '
;                .text $00,$00,$00,'\      '
;                .text $00,$00,$00,'\      '
;                .text $00,$00,$00,'\      '
;                .text $00,$00,$00,'\      '
;                .text $00,$00,$00,']      '

                .endproc


;======================================
;
;--------------------------------------
; X-Bank Procedure
;====================================== ;[[F]]
Swing_3E71      .proc
                lda swingAnimCounter
                cmp #$01
                beq _1

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
_1              lda polyVertZ_HI
                bne _XIT1

                lda polyVertZ_LO
                cmp #$6C
                bcs _XIT1

                lda holeInfoPuttRadius_LO
                sec
                sbc polyVertY_LO
                tax
                stx tempC

                lda holeInfoPuttRadius_HI
                sbc polyVertY_HI
                cmp #$FF
                bne _XIT1

                cpx #$C0
                bcc _XIT1

                ldx #$07                        ; missile-1 (shadow)
                jsr CalcMissilePositionAndMask  ; result in A=maskedPixelValue, [X,Y]

                cmp #$00
                bne _XIT1

                lda xPosCup_LO
                sec
                sbc polyVertX_LO
                tax
                lda xPosCup_HI
                sbc polyVertX_HI
                sta cupPosX_HI_2_3FEB
                beq _2

                cmp #$FF
                bne _XIT1

                txa
                beq _XIT1

                eor #$FF
                clc
                adc #$01
                tax
_2              cpx #$01
                bcs _3

                lda #$6A
                ldy #$00
                jmp _5

; - - - - - - - - - - - - - - - - - - -
_3              cpx #$06
                bcs _4

                lda #$56
                ldy #$1E
                jmp _5

; - - - - - - - - - - - - - - - - - - -
_4              lda #$42
                ldy #$1E
_5              sta puttY_LO_3FE9
                sty puttX_LO_3FEA

                lda temp9D59_puttY_HI
                bne _7

                lda temp9D35_puttY_LO
                cmp puttY_LO_3FE9
                bcs _7

                ldx tempC
                cpx #$F4
                bcc _7

                lda polyVertZ_LO
                cmp polyVertZ_delta
                bne _7

                stz flagsBall_9D81

                jsr ClearMissiles

                stz swingAnimCounter
                stz isSwingAnimCounterActive

                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS
                bcc _6

; - - - - - - - - - - - - - - - - - - -
;   driving
                jsr MarkPlayerInUse
                jmp PlaySoundSwingClub

; - - - - - - - - - - - - - - - - - - -
;   putting
_6              jsr PlaySoundPutt
                jmp MarkPlayerInUse

; - - - - - - - - - - - - - - - - - - -
_7              stz tempA

                inc swingAnimCounter

                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS              ; yards?
                bcs _8                      ;   yes
                jmp EnsurePuttXPositive_FF  ;   no

; - - - - - - - - - - - - - - - - - - -
_8              lda #$C0
                sta puttX_LO_3FEA

                lda temp9D59_puttY_HI
                sta tempA

                lsr tempA
                ror puttX_LO_3FEA
                lsr tempA
                ror puttX_LO_3FEA

                jsr EnsurePuttXPositive

                lda puttX_LO_3FEA
                sta temp9D33_puttX_LO
                sta puttX_LO

                lda tempA
                sta temp9D57_puttX_HI
                sta puttX_HI

                lda #$40
                sta temp9D35_puttY_LO
                sta puttY_LO

                stz temp9D59_puttY_HI
                stz puttY_HI

                jmp PlaySoundSwingClub

                .endproc


;======================================
;
;--------------------------------------
; Private Procedure
;====================================== ;[[F]]
EnsurePuttXPositive .proc
                lda cupPosX_HI_2_3FEB
                bpl _XIT

                lda #$00
                sec
                sbc puttX_LO_3FEA
                sta puttX_LO_3FEA

                lda #$00
                sbc tempA
                sta tempA

_XIT            rts
                .endproc


;--------------------------------------
;
;--------------------------------------
; Private Procedure
;-------------------------------------- ;[[F]]
ResetPuttX      .proc
                lda puttX_LO_3FEA
                sta puttX_LO
                sta temp9D33_puttX_LO

                lda tempA
                sta puttX_HI
                sta temp9D57_puttX_HI

                lda #$60
                sta distanceYards_LO

                lda #$1B
                sta polyVertZ_LO

                lsr temp9D35_puttY_LO

                stz accuracyPenalty

_XIT            rts
                .endproc


;--------------------------------------
;
;--------------------------------------
; Private Procedure
;-------------------------------------- ;[[F]]
EnsurePuttXPositive_FF .proc
                ldx tempC
                cpx #$F4
                bcs _1

                dec swingAnimCounter

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda polyVertZ_LO
                cmp polyVertZ_delta
                bne ResetPuttX._XIT

                lda cupPosX_HI_2_3FEB
                bpl ResetPuttX

                lda #$03
                lsr                     ; /4
                lsr                     ; A=$00
                sbc puttX_LO_3FEA
                sta puttX_LO_3FEA

                lda #$FF
                sta tempA

                jmp ResetPuttX

                .endproc


;--------------------------------------
;--------------------------------------

puttY_LO_3FE9               .byte $00
puttX_LO_3FEA               .byte $00
cupPosX_HI_2_3FEB           .byte $00

lineNode1_WorkB_27DC_2      .byte $00
lineNode1_pairDC_DE_HI_2    .byte $00
maskedPixelValue            .byte $00
