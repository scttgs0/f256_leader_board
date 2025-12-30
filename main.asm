
;--------------------------------------
;
;-------------------------------------- ;[[V]]
NewGame         .proc
                jsr ResetGame
                jsr ResetGauge
                jsr DoConfig
                jsr ClearScreen

                stz activePlayer                ; =first player
                stz isSwingDisabled             ; =FALSE
                stz isSwingInProgress           ; =FALSE
                stz swingAnimCounter            ; =0
                stz arrDeferredSum              ; =0
                stz arrDeferredSum+1            ; =0
                stz arrDeferredSum+2            ; =0
                stz isSwingAnimCounterActive    ; =FALSE

                lda #$3C
                sta const_60            ; obsolete

                stz idxActiveHole       ; first hole

                lda #unitYARDS
                sta idxDistanceUnit

                jmp PlayNextHole

                .endproc


;======================================
;
;====================================== ;[[V]]
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
                adc #<$0140             ; +320
                sta _ptr
                lda _ptr+1
                adc #>$0140
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

                stz tickFREQ3           ; disable

                jsr ProcessStroke
                jmp _next1

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[F]]
GoNextHole      .proc
                jsr ClearScreen
                jsr XBPC_DoScoreboard
                jsr WaitForButton
                jsr ClearScreen

                inc idxActiveHole
                lda idxActiveHole
                cmp #18                 ; finished?
                bne PlayNextHole        ;   no

                jsr ClearScore._preservehistory

                stz idxActiveHole       ; first hole

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
; - - - - - - - - - - - - - - - - - - -
;   for stability control
                sei                     ; disable interrupts

                lda IOPAGE_CTRL
                beq _s0

                stz IOPAGE_CTRL         ; switch to the Primary I/O page

_s0             lda MMU_CTRL
                cmp #mmuPage3|mmuEditPage3|mmuEditMode
                beq _s1

                lda #mmuPage3|mmuEditPage3|mmuEditMode
                sta MMU_CTRL            ; ensure Page3 w/Edit

_s1             lda MMU_Block3
                cmp #CONFIG_CHUNK
                beq _s2

                lda #CONFIG_CHUNK       ; default to the gameconfig chunk
                sta MMU_Block3

_s2             cli                     ; enable interrupts

; - - - - - - - - - - - - - - - - - - -
                jsr ResetSwingGauge
                jsr ShowSwingGauge

                stz flags_9D76          ; reset
                stz tickFREQ3           ; disable
                stz gaugeValue          ; reset

                ldx activePlayer
                lda playerClub,X
                sta activeClub

                ;!!jsr DoWindStreamer
                jsr SpriteInit
                jsr AimTarget
                jsr InitBall

                stz animSplashFrame     ; disable splash animation
                stz nodeOperation       ; operPIXEL

                jsr DrawClub

                lda isDrivingRange      ; driving range?
                bne _next1              ;   yes

                jsr XBPC_DrawDistanceToPin_m1

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

;   HACK: developer mode to cycle through the animation cells
                lda KEYCODE
                cmp #$FF
                beq _h1

                cmp #','                ; '<'-key
                bne _h0

                lda _h_frame
                cmp #$00                ; prevent underflow
                beq _h1

                dec _h_frame
                lda _h_frame
                sta golferSwingFrame

                jsr DrawGolfer
                bra _next1

_h0             cmp #$2F                ; '?/'-key
                bne _h1

                lda _h_frame
                cmp #$1F                ; prevent overflow
                beq _h1

                inc _h_frame
                lda _h_frame
                sta golferSwingFrame

                jsr DrawGolfer
                bra _next1

_h_frame        .byte $00

_h1
; end HACK:: developer mode to cycle through the animation cells

                lda KEYCODE
                cmp #$83                ; <F3> pressed?
                bne _1                  ;   no

;   /// OPTION ///
                jsr PlaySoundInputAction

                pla                     ; discard (ProcessStroke) return address
                pla
                pla                     ; discard (MainLoop) return address
                pla
                jmp GoNextHole

; - - - - - - - - - - - - - - - - - - -
_1              lda isSwingInProgress   ; swing anim in progress?
                beq _next1              ;   no

_next2          jsr SwingAnimControl
                jsr ProcessAudio
                jsr DemoInput

                lda golferSwingFrame
                cmp #$10                ; =16?
                bne _next2              ;   no

                jsr PowerLocked

_next3          jsr SwingAnimControl
                jsr ProcessAudio
                jsr DrawClock
                jsr DemoInput

                lda swingAnimCounter
                bne _2

                lda golferSwingFrame
                cmp #$13
                bne _next3

                jsr XBPC_IncrementStrokeCount
                jsr InitStroke

_2              jsr Swing_math_326F
                jsr DemoInput
                jsr PositionBallShadow
                jsr CalcBallPixelMask
                jsr SetBallFlags
                jsr RenderBall

                lda golferSwingFrame
                cmp #$16                ; frame 22?
                bne _next3              ;   no

                jsr SnapLocked

                ldx snapValue
                jsr CalcAccuracyPenalty

_next4          jsr SwingAnimControl
                jsr ProcessAudio
                jsr Swing_math_326F
                jsr PositionBallShadow
                jsr CalcBallPixelMask
                jsr SetBallFlags
                jsr XBPC_Swing_3E71
                jsr CalcPixelMask
                jsr RenderBall

_next5          jsr AnimateSplash
                jsr SetAudio4Max
                jsr DrawClock

                lda swingAnimCounter
                bne _next4

                lda animSplashFrame     ; splash active?
                bne _next5              ;   yes

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

                jmp XBPC_DrawDistanceToPin

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

                lda #<$003C
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
                sbc #$3C
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


;======================================
;
;--------------------------------------
; called from interrupt
;====================================== ;[[V]]
DrawGolfer      .proc
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                .frsSpriteShow 1        ; player top
                .frsSpriteShow 2        ; player bottom

                .frsSpriteSetX_imm $70,1    ; player top
                .frsSpriteSetY_imm $B6,1
                .frsSpriteSetX_imm $70,2    ; player bottom
                .frsSpriteSetY_imm $D6,2

                ldx golferSwingFrame
                cmp #$FF
                beq _XIT

                sei
                lda _anim0Addr_LO,X
                sta SPR(sprite_t.ADDR, 1)
                sta SPR(sprite_t.ADDR, 2)

                lda _anim0Addr_HI,X
                sta SPR(sprite_t.ADDR+1, 1)
                clc
                adc #$04                ; +$400
                sta SPR(sprite_t.ADDR+1, 2)

                lda _anim0Addr_24,X
                sta SPR(sprite_t.ADDR+2, 1)
                sta SPR(sprite_t.ADDR+2, 2)
                cli

; - - - - - - - - - - - - - - - - - - -
                .frsSpriteShow 0        ; club

                sei
                lda _anim2Addr_LO,X
                sta SPR(sprite_t.ADDR, 0)

                lda _anim2Addr_HI,X
                sta SPR(sprite_t.ADDR+1, 0)

                lda _anim2Addr_24,X
                sta SPR(sprite_t.ADDR+2, 0)

                cli
                phx
                lda _anim2PosX,X
                ldx #$00
                .frsSpriteSetX_ix
                plx

                phx
                lda _anim2PosY,X
                ldx #$00
                .frsSpriteSetY_ix
                plx

_XIT
; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                rts

;--------------------------------------

_anim0Addr_24   .byte `anim0cell00,`anim0cell01,`anim0cell02,`anim0cell03
                .byte `anim0cell04,`anim0cell05,`anim0cell06,`anim0cell07
                .byte `anim0cell08,`anim0cell09,`anim0cell0A,`anim0cell0B
                .byte `anim0cell0C,`anim0cell0D,`anim0cell0E,`anim0cell0F
                .byte `anim0cell10,`anim0cell11,`anim0cell12,`anim0cell13
                .byte `anim0cell14,`anim0cell15,`anim0cell16,`anim0cell17
                .byte `anim0cell18,`anim0cell19,`anim0cell1A,`anim0cell1B
                .byte `anim0cell1C,`anim0cell1D,`anim0cell1E,`anim0cell1F
_anim0Addr_HI   .byte >anim0cell00,>anim0cell01,>anim0cell02,>anim0cell03
                .byte >anim0cell04,>anim0cell05,>anim0cell06,>anim0cell07
                .byte >anim0cell08,>anim0cell09,>anim0cell0A,>anim0cell0B
                .byte >anim0cell0C,>anim0cell0D,>anim0cell0E,>anim0cell0F
                .byte >anim0cell10,>anim0cell11,>anim0cell12,>anim0cell13
                .byte >anim0cell14,>anim0cell15,>anim0cell16,>anim0cell17
                .byte >anim0cell18,>anim0cell19,>anim0cell1A,>anim0cell1B
                .byte >anim0cell1C,>anim0cell1D,>anim0cell1E,>anim0cell1F
_anim0Addr_LO   .byte <anim0cell00,<anim0cell01,<anim0cell02,<anim0cell03
                .byte <anim0cell04,<anim0cell05,<anim0cell06,<anim0cell07
                .byte <anim0cell08,<anim0cell09,<anim0cell0A,<anim0cell0B
                .byte <anim0cell0C,<anim0cell0D,<anim0cell0E,<anim0cell0F
                .byte <anim0cell10,<anim0cell11,<anim0cell12,<anim0cell13
                .byte <anim0cell14,<anim0cell15,<anim0cell16,<anim0cell17
                .byte <anim0cell18,<anim0cell19,<anim0cell1A,<anim0cell1B
                .byte <anim0cell1C,<anim0cell1D,<anim0cell1E,<anim0cell1F

_anim2Addr_24   .byte `anim2cell00,`anim2cell01,`anim2cell02,`anim2cell03
                .byte `anim2cell04,`anim2cell05,`anim2cell06,`anim2cell07
                .byte `anim2cell08,`anim2cell09,`anim2cell0A,`anim2cell0B
                .byte `anim2cell0C,`anim2cell0D,`anim2cell0E,`anim2cell0F
                .byte `anim2cell10,`anim2cell11,`anim2cell12,`anim2cell13
                .byte `anim2cell14,`anim2cell15,`anim2cell16,`anim2cell17
                .byte `anim2cell18,`anim2cell19,`anim2cell1A,`anim2cell1B
                .byte `anim2cell1C,`anim2cell1D,`anim2cell1E,`anim2cell1F
_anim2Addr_HI   .byte >anim2cell00,>anim2cell01,>anim2cell02,>anim2cell03
                .byte >anim2cell04,>anim2cell05,>anim2cell06,>anim2cell07
                .byte >anim2cell08,>anim2cell09,>anim2cell0A,>anim2cell0B
                .byte >anim2cell0C,>anim2cell0D,>anim2cell0E,>anim2cell0F
                .byte >anim2cell10,>anim2cell11,>anim2cell12,>anim2cell13
                .byte >anim2cell14,>anim2cell15,>anim2cell16,>anim2cell17
                .byte >anim2cell18,>anim2cell19,>anim2cell1A,>anim2cell1B
                .byte >anim2cell1C,>anim2cell1D,>anim2cell1E,>anim2cell1F
_anim2Addr_LO   .byte <anim2cell00,<anim2cell01,<anim2cell02,<anim2cell03
                .byte <anim2cell04,<anim2cell05,<anim2cell06,<anim2cell07
                .byte <anim2cell08,<anim2cell09,<anim2cell0A,<anim2cell0B
                .byte <anim2cell0C,<anim2cell0D,<anim2cell0E,<anim2cell0F
                .byte <anim2cell10,<anim2cell11,<anim2cell12,<anim2cell13
                .byte <anim2cell14,<anim2cell15,<anim2cell16,<anim2cell17
                .byte <anim2cell18,<anim2cell19,<anim2cell1A,<anim2cell1B
                .byte <anim2cell1C,<anim2cell1D,<anim2cell1E,<anim2cell1F

_anim2PosX      .byte $86,$7E,$7E,$76
                .byte $66,$5E,$5E,$5E
                .byte $66,$66,$66,$66
                .byte $76,$6E,$6E,$66
                .byte $76,$7E,$86,$86
                .byte $86,$86,$6E,$6E
                .byte $66,$6E,$76,$76
                .byte $7E,$7E,$7E,$7E
_anim2PosY      .byte $D2,$D2,$D1,$CA
                .byte $C2,$BA,$B0,$B1
                .byte $B2,$B2,$B2,$B2
                .byte $BB,$B6,$B3,$B2
                .byte $C4,$C8,$D0,$D0
                .byte $CE,$C8,$BA,$B5
                .byte $B0,$B4,$B9,$B8
                .byte $B9,$B9,$B9,$B9

                .endproc
