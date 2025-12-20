
;--------------------------------------
;
;-------------------------------------- ;[[U]]
AdjustBallPixelMask .proc
                ldx #$07                        ; missile-1 (shadow)
                jsr CalcMissilePositionAndMask  ; result in A=maskedPixelValue, [X,Y]

                cmp #$03                ; missile-0 white?
                beq _1                  ;   yes

                lda #operSHADOW_BALL
                sta nodeOperation

                lda #$C0                ; ball(bit-6) and shadow(bit-7) are visible
                sta flagsBall_9D81

                rts

; - - - - - - - - - - - - - - - - - - -
_1              ldx #$07                ; missile-1 (shadow)
                jsr CalcMissilePosition ; result [X,Y]

                tya
                sec
                sbc yPosNewBallShadow
                tay

                jsr ShiftPixelMask      ; result in A=maskedPixelValue

                cmp #$03
                ;;beq CalcBallPixelMask._ENTRY1

                rts
                .endproc


;======================================
;
;====================================== ;[[F]]
InitBall        .proc
                lda #$00
                sta flagsBall_9D81
                sta nodeOperation       ; operPIXEL
                sta flagsBall_9D83
                sta flagsBall_9DAF
                sta unused_9D82

                lda polyVertZ_LO
                sta polyVertZ_delta

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
MoveBall        .proc
_HPOSM1_BallR   = $0061 ;HPOSM1
_HPOSM3_BallL   = $0063 ;HPOSM3
;---

                lda #$00
                sta isSwingAnimCounterActive    ; FALSE
                sta swingAnimCounter

                ;!!jsr ReadPortA           ; on return, A=%1100xxxx
                and #$B0                ; [A:=$80]
                sta flags_9D76
                sta animBallFrame       ; set bit-7; ball is visible

_next1          ldx #$06                        ; missile-1 (ball)
                jsr CalcMissilePositionAndMask  ; result in A=maskedPixelValue, [X,Y]

                cmp #$03                ; missile-1?
                bne _1                  ;   no

                dec newMissileY1        ;   yes
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_1              lda newMissileY1
                sta yPosBall

                lda newMissileX
                clc
                adc #$01
                sta _HPOSM1_BallR

                sbc #$01
                sta _HPOSM3_BallL

                jsr ClearMissiles

                lda #$0C                ; duration
                ldx #$06                ; timer 6
                jsr SetTimer

                lda #$05
                ;!!sta AUDF3

                lda flagsBall_9D83      ; ignore bits[7:6]
                eor #$C0                ; 192 (zMax)
                ora lineNode0_ClipFlags
                sta ballController

                jmp AnimateBall._ENTRY1

                .endproc


;--------------------------------------
;--------------------------------------

xPosDeltaBall   .byte $2F
yPosDeltaBall   .byte $1F


;======================================
;
;====================================== ;[[U]]
PositionBallShadow .proc
                ldx #xformNORMAL
                jsr VertexTransform
                stx xTransform
                sty yTransform
                sta lineNode0_ClipFlags

                ldx #xformDELTA_Z
                jsr VertexTransform
                sta lineNode1_ClipFlags
                sty zTransform

                ;!!jsr ReadPortA           ; on return, A=%1100xxxx
                and #$30                ; [A:=0]

                ldx lineNode0_ClipFlags
                bne _1

                ora #$40                ; ball(bit-6) is visible
_1              ldx lineNode1_ClipFlags
                bne _2

                ora #$80                ; shadow(bit-7) is visible
_2              sta flags_BallVisible

                lda yTransform
                clc
                adc yPosDeltaBall
                sta yTransform
                lda xTransform
                lsr
                adc xPosDeltaBall
                tax

                lda distanceYards_HI
                ora distanceYards_LO
                bne _3

                lda polyVertZ_HI
                bne _3

                lda polyVertZ_LO
                cmp #$18                ; surface layer (24 inches)?
                bne _3

                lda yTransform
                ;!!bit PACTL
                jmp _4

; - - - - - - - - - - - - - - - - - - -
_3              lda zTransform
                clc
                adc yPosDeltaBall
_4              sta newMissileY0
                stx newMissileX

                lda yTransform
                sta newMissileY1

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           =[6:7]
;       :=6     ball (missileY1)
;       :=7     shadow (missileY0)
; on exit:
;   A           maskedPixelValue
;   X,Y         [X,Y]
;====================================== ;[[U]]
CalcMissilePositionAndMask .proc
                jsr CalcMissilePosition ; result [X,Y]
                ;!!jmp ShiftPixelMask      ; result in A=maskedPixelValue

                rts		; HACK:
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           =[6:7]
;       :=6     missileY1
;       :=7     missileY0
; on exit:
;   X           new xPos
;   Y           new yPos
;====================================== ;[[F]]
CalcMissilePosition .proc
                cpx #$06
                beq _1                  ; when [X:=6] ball

                lda newMissileY0        ; when [X:=7] shadow
                ldx newMissileX
                jmp _2

; - - - - - - - - - - - - - - - - - - -
_1              lda newMissileY1
                ldx newMissileX

_2              sec
                sbc yPosDeltaBall
                tay

                txa
                sec
                sbc xPosDeltaBall
                tax

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
AnimateBall     .proc
                bit animBallFrame       ; ball is visible?
                bmi _1                  ;   yes

                ;!!lsr PORTA               ;   no

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
_1              lda timerIsActive+6     ; timer 6 active?
                bne _XIT1               ;   yes

                inc timerIsActive+6     ;   no, make active
                inc animBallFrame

; - - - - - - - - - - - - - - - - - - -
_ENTRY1         lda polyVertY_HI
                cmp #10
                bcc _XIT4

                cmp #15
                bcc _XIT3

                cmp #20
                bcc _XIT2

                jmp _2

; - - - - - - - - - - - - - - - - - - -
_XIT2           jmp RenderMissile1B

; - - - - - - - - - - - - - - - - - - -
_XIT3           jmp RenderMissile1C

; - - - - - - - - - - - - - - - - - - -
_XIT4           jmp RenderMissile1D

; - - - - - - - - - - - - - - - - - - -
_2              lda animBallFrame
                cmp #$84
                ;;bcc RenderMissile1A

; - - - - - - - - - - - - - - - - - - -
_ENTRY2         lda #$00
                ;!!sta AUDC3
                ;!!sta AUDF3
                sta animBallFrame

                jmp ClearMissiles

                .endproc


;======================================
;
;====================================== ;[[U]]
AnimateBall_2AC6 .proc
                lda animBallFrame
                beq _1

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda polyVertZ_HI
                bne _2

                lda polyVertZ_LO
                beq _3

                cmp #$18                ; surface layer (24 inches)?
                bcs _2

                lda nodeOperation
                cmp #operFILL
                bne _2

                lda #$80                ; shadow(bit-7) is visible
                .byte $2C               ; consume the following LDA operation
_2              lda #$C0                ; ball(bit-6) and shadow(bit-7) are visible
                sta flagsBall_9DAF

                rts

; - - - - - - - - - - - - - - - - - - -
_3              lda polyVertZ_delta
                bne _XIT

                jsr MoveBall

                lda #$01
                sta flags_9D76

                lda #$00
                sta flagsBall_9D81

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[F]]
RenderBall      .proc
_HPOSM0_Shadow  = $0063 ; HPOSM0
_HPOSM1_Ball    = $0061 ; HPOSM1
BALL_BASE       = $0060 ; MISL_BASE
SHADOW_BASE     = $0060 ; MISL_BASE
;---

                bit animBallFrame
                bpl _1

                rts

; - - - - - - - - - - - - - - - - - - -
_1              ldy yPosBallShadow      ; capture the current shadow position
                lda newMissileY0        ; capture the new shadow position
                sta yPosBallShadow      ; update the shadow position for the future

                lda SHADOW_BASE,Y       ; erase at the current position
                and #$FC                ; clear missile-0 (shadow)
                sta SHADOW_BASE,Y

                ldx newMissileX         ; move missile-0 and missile-1
                stx _HPOSM0_Shadow
                stx _HPOSM1_Ball
                stx xPosBallShadow      ; update the variables
                stx xPosBall

                lda newMissileY1        ; capture the new ball position
                ldy yPosBall            ; capture the current ball position
                sta yPosBall            ; update the ball position for the future

                lda BALL_BASE,Y         ; erase at the current position (two scanlines)
                and #$F3                ; clear missile-1 (ball)
                sta BALL_BASE,Y
                lda BALL_BASE-1,Y
                and #$F3                ; clear missile-1 (ball)
                sta BALL_BASE-1,Y

; - - - - - - - - - - - - - - - - - - -
;   render the ball shadow
                lda flags_BallVisible   ; shadow(bit-7) is visible?
                and #$80
                and flagsBall_9D81
                and flagsBall_9D83
                and flagsBall_9DAF
                beq _2                  ; skip when no bits

                ldy yPosBallShadow      ; draw at the new position
                lda SHADOW_BASE,Y
                ora #$01                ; set missile-0 (shadow)
                sta SHADOW_BASE,Y

; - - - - - - - - - - - - - - - - - - -
;   render the ball
_2              lda flags_BallVisible   ; ball(bit-6) is visible?
                and #$40
                and flagsBall_9D81
                and flagsBall_9D83
                and flagsBall_9DAF
                beq _XIT                ; skip when no bits

                ldy yPosBall            ; draw at the new position (two scanlines)
                lda BALL_BASE,Y
                ora #$04                ; set missile-1 (ball)
                sta BALL_BASE,Y
                lda BALL_BASE-1,Y
                ora #$04                ; set missile-1 (ball)
                sta BALL_BASE-1,Y

_XIT            rts
                .endproc



;--------------------------------------
;
;-------------------------------------- ;[[F]]
SetFlagsBall_C0 .proc
                lda #$C0                ; ball(bit-6) and shadow(bit-7) are visible
                sta flagsBall_9D83

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
CalcPixelMask   .proc
                ldx #$07                ; missile-1 (shadow)
                jsr CalcMissilePosition ; result [X,Y]

                txa
                sec
                sbc lineNode1_WorkB_27DC_2
                bcs _1

                eor #$FF                ; 2-complement
                adc #$01
_1              cmp #$05
                bcs SetFlagsBall_C0

                cpy lineNode1_pairDC_DE_HI_2
                bcs SetFlagsBall_C0

                cpy lineNode0_pairDC_DE_2
                bcc SetFlagsBall_C0

                ldx #$07                        ; missile-1 (shadow)
                jsr CalcMissilePositionAndMask  ; result in A=maskedPixelValue, [X,Y]

                cmp #$00                ; no missile date?
                beq _2                  ;   none

                cmp #$02                ; missile-0?
                beq _2                  ;   yes

                ;!!jsr ReadPortA           ; on return, A=%1100xxxx
                and #$B0                ; [A:=$80]
                ora flagsBall_9D83
                sta flagsBall_9D83

                jmp _3

; - - - - - - - - - - - - - - - - - - -
_2              lda flagsBall_9D83
                and #$7F
                sta flagsBall_9D83

_3              ldx #$06                ; missile-1 (ball)
                jsr CalcMissilePosition ; result [X,Y]

                cpy lineNode0_pairDC_DE_2
                bcs _4

_next1          lda flagsBall_9D83
                ora #$40                ; ball(bit-6) is visible
                sta flagsBall_9D83

                rts

; - - - - - - - - - - - - - - - - - - -
_4              ;!!jsr ShiftPixelMask      ; result in A=maskedPixelValue

                cmp #$00
                beq _5

                cmp #$02
                bne _next1

_5              lda flagsBall_9D83
                and #$BF
                sta flagsBall_9D83

                rts
                .endproc



;--------------------------------------
;
;-------------------------------------- ;[[U]]
RenderMissile1A .proc
                and #$0F
                tax

                lda #$00
                cpx #$00
                beq _1

_next1          clc
                adc #$03

                dex
                bne _next1

_1              tax

                lda ballController
                bne _2

                ldy yPosBall
                lda _data2,X
                sta MISL_BASE,Y
                lda _data2+1,X
                sta MISL_BASE-1,Y
                lda _data2+2,X
                sta MISL_BASE-2,Y

_2              lda animBallFrame
                and #$7F

                tax
                lda _data1,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ..  ..  gg  ..
; ..  .R  ..  ..
; .R  .R  .R  gg

_data1          .byte $81,$82,$82,$81               ; audio control
_data2          ;.byte $08,$00,$00
                .byte %00001000         ; . . R .   ; missile-1
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                ;.byte $08,$08,$00
                .byte %00001000         ; . . R .   ; missile-1
                .byte %00001000         ; . . R .
                .byte %00000000         ; . . . .

                ;.byte $08,$00,$44
                .byte %00001000         ; . . R .   ; missile-1 and 3
                .byte %00000000         ; . . . .
                .byte %01000100         ; g . g .

                ;.byte $44,$00,$00
                .byte %01000100         ; g . g .   ; missile-1 and 3
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
RenderMissile1B .proc
MISL_BASE       = $0060
;---

                lda animBallFrame
                cmp #$85
                bcc _next1

                jmp AnimateBall._ENTRY2

; - - - - - - - - - - - - - - - - - - -
_next1          and #$0F
                tax

                lda #$00
                cpx #$00
                beq _1

_next2          clc
                adc #$05

                dex
                bne _next2

_1              tax
                lda ballController
                bne _2

                ldy yPosBall
                lda _data2,X
                sta MISL_BASE,Y
                lda _data2+1,X
                sta MISL_BASE-1,Y
                lda _data2+2,X
                sta MISL_BASE-2,Y
                lda _data2+3,X
                sta MISL_BASE-3,Y
                lda _data2+4,X
                sta MISL_BASE-4,Y

_2              lda animBallFrame
                and #$7F
                tax

                lda _data1,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ..  .R  ..  ..  ..
; ..  .g  ..  ..  ..
; ..  ..  .R  ..  ..
; ..  gR  .g  .R  ..
; ..  .R  g.  .g  ..
; .R  .R  .R  gR  gg

_data1          .byte $81,$82,$82,$81,$81           ; audio control
_data2          ;.byte $08,$00,$00,$00,$00
                .byte %00001000         ; . . R .   ; missile-1
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                ;.byte $08,$08,$48,$04,$08
                .byte %00001000         ; . . R .   ; missile-1 and 3
                .byte %00001000         ; . . R .
                .byte %01001000         ; g . R .
                .byte %00000100         ; . . g .
                .byte %00001000         ; . . R .

                ;.byte $08,$40,$04,$08,$00
                .byte %00001000         ; . . R .   ; missile-1 and 3
                .byte %01000000         ; g . . .
                .byte %00000100         ; . . g .
                .byte %00001000         ; . . R .
                .byte %00000000         ; . . . .

                ;.byte $48,$04,$08,$00,$00
                .byte %01001000         ; g . R .   ; missile-1 and 3
                .byte %00000100         ; . . g .
                .byte %00001000         ; . . R .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                ;.byte $44,$00,$00,$00,$00
                .byte %01000100         ; g . g .   ; missile-1 and 3
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
RenderMissile1C .proc
MISL_BASE       = $0060
;---

                lda animBallFrame
                cmp #$85
                bcc _1

                jmp AnimateBall._ENTRY2

; - - - - - - - - - - - - - - - - - - -
_1              and #$0F
                tax
                lda #$00
                cpx #$00
                beq _2

_next1          clc
                adc #$07

                dex
                bne _next1

_2              tax
                ldy yPosBall
                lda ballController
                bne _3

                lda _data2,X
                sta MISL_BASE,Y
                lda _data2+1,X
                sta MISL_BASE-1,Y
                lda _data2+2,X
                sta MISL_BASE-2,Y
                lda _data2+3,X
                sta MISL_BASE-3,Y
                lda _data2+4,X
                sta MISL_BASE-4,Y
                lda _data2+5,X
                sta MISL_BASE-5,Y
                lda _data2+6,X
                sta MISL_BASE-6,Y

_3              lda animBallFrame
                and #$7F
                tax

                lda _data1,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ..  .g  ..  ..  ..
; ..  .R  g.  ..  ..
; ..  gg  .g  ..  ..
; ..  .R  gR  g.  ..
; ..  gR  gR  .R  ..
; ..  .R  gR  gR  ..
; .R  .R  .R  gR  gg

_data1          .byte $81,$82,$83,$82,$81           ; audio control
_data2          ;.byte $08,$00,$00,$00,$00,$00,$00
                .byte %00001000         ; . . R .   ; missile-1
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                ;.byte $08,$08,$4A,$08,$44,$08,$04
                .byte %00001000         ; . . R .   ; missile-0, 1, and 3
                .byte %00001000         ; . . R .
                .byte %01001010         ; g . R R
                .byte %00001000         ; . . R .
                .byte %01000100         ; g . g .
                .byte %00001000         ; . . R .
                .byte %00000100         ; . . g .

                ;.byte $08,$48,$48,$4A,$08,$44,$00
                .byte %00001000         ; . . R .   ; missile-0, 1, and 3
                .byte %01001000         ; g . R .
                .byte %01001000         ; g . R .
                .byte %01001010         ; g . R R
                .byte %00001000         ; . . R .
                .byte %01000100         ; g . g .
                .byte %00000000         ; . . . .

                ;.byte $48,$4A,$08,$40,$00,$00,$00
                .byte %01001000         ; g . R .   ; missile-0, 1, and 3
                .byte %01001010         ; g . R R
                .byte %00001000         ; . . R .
                .byte %01000000         ; g . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                ;.byte $44,$00,$00,$00,$00,$00,$00
                .byte %01000100         ; g . g .   ; missile-1 and 3
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
RenderMissile1D .proc
MISL_BASE       = $0060
;---

                lda animBallFrame
                cmp #$86
                bcc _1

                jmp AnimateBall._ENTRY2

; - - - - - - - - - - - - - - - - - - -
_1              and #$0F
                tax

                lda #$00
                cpx #$00
                beq _2

_next1          clc
                adc #$09

                dex
                bne _next1

_2              tax
                lda ballController
                bne _3

                ldy yPosBall
                lda _data2,X
                sta MISL_BASE,Y
                lda _data2+1,X
                sta MISL_BASE-1,Y
                lda _data2+2,X
                sta MISL_BASE-2,Y
                lda _data2+3,X
                sta MISL_BASE-3,Y
                lda _data2+4,X
                sta MISL_BASE-4,Y
                lda _data2+5,X
                sta MISL_BASE-5,Y
                lda _data2+6,X
                sta MISL_BASE-6,Y

_3              lda animBallFrame
                and #$7F
                tax

                lda _data1,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ..  gg  gR  .R  ..  ..  ..
; ..  gR  .R  ..  .R  ..  ..
; ..  gR  .R  .R  ..  ..  ..
; ..  gR  .R  .g  .g  .R  .R
; ..  .R  .g  g.  g.  ..  ..
; ..  ..  g.  .R  .R  gg  ..
; .R  ..  .R  gR  gR  ..  ..

_data1          .byte $81,$82,$83,$84,$83,$82       ; audio control
_data2          ;.byte $08,$00,$00,$00,$00,$00,$00
                .byte %00001000         ; . . R .   ; missile-1
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                ;.byte $00,$00,$08,$4A,$4A,$4A,$44
                .byte %00000000         ; . . . .   ; missile-0, 1, and 3
                .byte %00000000         ; . . . .
                .byte %00001000         ; . . R .
                .byte %01001010         ; g . R R
                .byte %01001010         ; g . R R
                .byte %01001010         ; g . R R
                .byte %01000100         ; g . g .

                ;.byte $08,$40,$04,$08,$08,$08,$4A
                .byte %00001000         ; . . R .   ; missile-0, 1, and 3
                .byte %01000000         ; g . . .
                .byte %00000100         ; . . g .
                .byte %00001000         ; . . R .
                .byte %00001000         ; . . R .
                .byte %00001000         ; . . R .
                .byte %01001010         ; g . R R

                ;.byte $4A,$08,$40,$04,$08,$00,$08
                .byte %01001010         ; g . R R   ; missile-0, 1, and 3
                .byte %00001000         ; . . R .
                .byte %01000000         ; g . . .
                .byte %00000100         ; . . g .
                .byte %00001000         ; . . R .
                .byte %00000000         ; . . . .
                .byte %00001000         ; . . R .

                ;.byte $4A,$0A,$40,$04,$00,$08,$00
                .byte %01001010         ; g . R R   ; missile-0, 1, and 3
                .byte %00001010         ; . . R R
                .byte %01000000         ; g . . .
                .byte %00000100         ; . . g .
                .byte %00000000         ; . . . .
                .byte %00001000         ; . . R .
                .byte %00000000         ; . . . .

                ;.byte $00,$44,$00,$08,$00,$00,$00
                .byte %00000000         ; . . . .   ; missile-1 and 3
                .byte %01000100         ; g . g .
                .byte %00000000         ; . . . .
                .byte %00001000         ; . . R .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .

                ;.byte $00,$00,$00,$08,$00,$00,$00
                .byte %00000000         ; . . . .   ; missile-1
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00001000         ; . . R .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .
                .byte %00000000         ; . . . .


                .byte $00,$00,$00,$00,$00

                .endproc
