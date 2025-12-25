
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
                stz flagsBall_9D81      ; reset
                stz nodeOperation       ; =operPIXEL
                stz flagsBall_9D83      ; reset
                stz flagsBall_9DAF      ; reset
                stz unused_9D82         ; reset

                lda polyVertZ_LO
                sta polyVertZ_delta

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
MoveBall        .proc
;!!_HPOSM1_BallR   = $0061 ;HPOSM1
;!!_HPOSM3_BallL   = $0063 ;HPOSM3
;---

                stz isSwingAnimCounterActive    ; =FALSE
                stz swingAnimCounter            ; =0

                lda #$80
                sta flags_9D76
                sta animSplashFrame       ; set bit-7; ball is visible

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
                ;!!clc
                ;!!adc #$01
                ;!!sta _HPOSM1_BallR

                sbc #$01
                ;!!sta _HPOSM3_BallL

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

                jmp AnimateSplash._FINISH

                .endproc


;--------------------------------------
;--------------------------------------

xPosDeltaBall   .byte $2F
yPosDeltaBall   .byte $1F


;======================================
;
;====================================== ;[[F]]
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

                lda #$00
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
AnimateSplash   .proc
                bit animSplashFrame     ; ball is visible?
                bmi _1                  ;   yes

                ;!!lsr PORTA               ;   no

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
_1              lda timerIsActive+6     ; timer 6 active?
                bne _XIT1               ;   yes

                inc timerIsActive+6     ;   no, make active
                inc animSplashFrame

; - - - - - - - - - - - - - - - - - - -
_ENTRY1         lda polyVertY_HI
                cmp #10
                bcc _XIT_D              ; very close

                cmp #15
                bcc _XIT_C

                cmp #20
                bcc _XIT_B
                jmp _XIT_A              ; very far

; - - - - - - - - - - - - - - - - - - -
_XIT_B          jmp AnimSplash_B

; - - - - - - - - - - - - - - - - - - -
_XIT_C          jmp AnimSplash_C

; - - - - - - - - - - - - - - - - - - -
_XIT_D          jmp AnimSplash_D

; - - - - - - - - - - - - - - - - - - -
_XIT_A          lda animSplashFrame
                cmp #$84                ; hi-bit & frame 4
                bcs _FINISH
                jmp AnimSplash_A

; - - - - - - - - - - - - - - - - - - -
_FINISH         lda #$00
                ;!!sta AUDC3
                ;!!sta AUDF3
                sta animSplashFrame     ; reset

                jmp ClearMissiles

                .endproc


;======================================
;
;====================================== ;[[F]]
AnimateSplash_2AC6 .proc
                lda animSplashFrame
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
                bit animSplashFrame
                bpl _1

                rts

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
_1              lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda newMissileY0        ; update the new shadow vertical position
                sta yPosBallShadow

                ldx newMissileX         ; move ball and shadow horizontally
                stx xPosBallShadow
                stx xPosBall

                lda newMissileY1        ; update the new ball vertical position
                sta yPosBall

; - - - - - - - - - - - - - - - - - - -
;   render the ball shadow
                lda flags_BallVisible   ; shadow(bit-7) is visible?
                and #$80
                and flagsBall_9D81
                and flagsBall_9D83
                and flagsBall_9DAF
                beq _2                  ; skip when no bits

                .frsSpriteShow 9        ; draw at the new position
                .frsSpriteSetX xPosBallShadow,9
                .frsSpriteSetY yPosBallShadow,9

; - - - - - - - - - - - - - - - - - - -
;   render the ball
_2              lda flags_BallVisible   ; ball(bit-6) is visible?
                and #$40
                and flagsBall_9D81
                and flagsBall_9D83
                and flagsBall_9DAF
                beq _XIT                ; skip when no bits

                .frsSpriteShow 8        ; draw at the new position
                .frsSpriteSetX xPosBall,8
                .frsSpriteSetY yPosBall,8

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                rts
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

                lda #$80
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
;--------------------------------------
; on entry:
;   A           animSplashFrame [0:3]
;-------------------------------------- ;[[U]]
AnimSplash_A    .proc
                and #$0F                ; strip the hi-bit
                tax

                lda #$00
                cpx #$00
                beq _1

_next1          clc                     ; calculate X*3
                adc #$03

                dex
                bne _next1

_1              tax

                lda ballController
                bne _2

                ldy yPosBall
                lda _frame+0,X
                ;!!sta MISL_BASE,Y
                lda _frame+1,X
                ;!!sta MISL_BASE-1,Y
                lda _frame+2,X
                ;!!sta MISL_BASE-2,Y

_2              lda animSplashFrame
                and #$7F                ; strip the hi-bit

                tax
                lda _audioControl,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ......  ......  .#.#..  ......
; ......  ..#...  ......  ......
; ..#...  ..#...  ..#...  .#.#..

_audioControl   .byte $81,$82,$82,$81

_frame          ;.byte $08,$00,$00
                .byte %00001000         ; ..#...   ; ball-R
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $08,$08,$00
                .byte %00001000         ; ..#...   ; ball-R
                .byte %00001000         ; ..#...
                .byte %00000000         ; ......

                ;.byte $08,$00,$44
                .byte %00001000         ; ..#...   ; ball-R and ball-L
                .byte %00000000         ; ......
                .byte %01000100         ; .#.#..

                ;.byte $44,$00,$00
                .byte %01000100         ; .#.#..   ; ball-R and ball-L
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
AnimSplash_B .proc
                lda animSplashFrame     ; [0:4]
                cmp #$85                ; max frame? (hi-bit + 5)
                bcc _next1              ;   no

                jmp AnimateSplash._FINISH

; - - - - - - - - - - - - - - - - - - -
_next1          and #$0F                ; strip the hi-bit
                tax

                lda #$00
                cpx #$00
                beq _1

_next2          clc                     ; calculate X*5
                adc #$05

                dex
                bne _next2

_1              tax
                lda ballController
                bne _2

                ldy yPosBall
                lda _frame+0,X
                ;!!sta MISL_BASE,Y
                lda _frame+1,X
                ;!!sta MISL_BASE-1,Y
                lda _frame+2,X
                ;!!sta MISL_BASE-2,Y
                lda _frame+3,X
                ;!!sta MISL_BASE-3,Y
                lda _frame+4,X
                ;!!sta MISL_BASE-4,Y

_2              lda animSplashFrame
                and #$7F                ; strip the hi-bit
                tax

                lda _audioControl,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ......  ..#...  ......  ......  ......
; ......  ...#..  ..#...  ......  ......
; ......  .##...  ...#..  ..#...  ......
; ......  ..#...  .#....  ...#..  ......
; ..#...  ..#...  ..#...  .##...  .#.#..

_audioControl   .byte $81,$82,$82,$81,$81

_frame          ;.byte $08,$00,$00,$00,$00
                .byte %00001000         ; ..#...   ; ball-R
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $08,$08,$48,$04,$08
                .byte %00001000         ; ..#...   ; ball-R and ball-L
                .byte %00001000         ; ..#...
                .byte %01001000         ; .##...
                .byte %00000100         ; ...#..
                .byte %00001000         ; ..#...

                ;.byte $08,$40,$04,$08,$00
                .byte %00001000         ; ..#...   ; ball-R and ball-L
                .byte %01000000         ; .#....
                .byte %00000100         ; ...#..
                .byte %00001000         ; ..#...
                .byte %00000000         ; ......

                ;.byte $48,$04,$08,$00,$00
                .byte %01001000         ; .##...   ; ball-R and ball-L
                .byte %00000100         ; ...#..
                .byte %00001000         ; ..#...
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $44,$00,$00,$00,$00
                .byte %01000100         ; .#.#..   ; ball-R and ball-L
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
AnimSplash_C .proc
;!!MISL_BASE       = $0060
;---

                lda animSplashFrame     ; [0:4]
                cmp #$85                ; max frame? (hi_bit + 5)
                bcc _1                  ;   no

                jmp AnimateSplash._FINISH

; - - - - - - - - - - - - - - - - - - -
_1              and #$0F                ; strip the hi-bit
                tax

                lda #$00
                cpx #$00
                beq _2

_next1          clc                     ; calculate X*7
                adc #$07

                dex
                bne _next1

_2              tax
                ldy yPosBall
                lda ballController
                bne _3

                lda _frame+0,X
                ;!!sta MISL_BASE,Y
                lda _frame+1,X
                ;!!sta MISL_BASE-1,Y
                lda _frame+2,X
                ;!!sta MISL_BASE-2,Y
                lda _frame+3,X
                ;!!sta MISL_BASE-3,Y
                lda _frame+4,X
                ;!!sta MISL_BASE-4,Y
                lda _frame+5,X
                ;!!sta MISL_BASE-5,Y
                lda _frame+6,X
                ;!!sta MISL_BASE-6,Y

_3              lda animSplashFrame
                and #$7F                ; strip the hi-bit
                tax

                lda _audioControl,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ......  ...#..  ......  ......  ......
; ......  ..#...  .#.#..  ......  ......
; ......  .#.#..  ..#...  ......  ......
; ......  ..#...  .##.#.  .#....  ......
; ......  .##.#.  .##...  ..#...  ......
; ......  ..#...  .##...  .##.#.  ......
; ..#...  ..#...  ..#...  .##...  .#.#..

_audioControl   .byte $81,$82,$83,$82,$81

_frame          ;.byte $08,$00,$00,$00,$00,$00,$00
                .byte %00001000         ; ..#...   ; ball-R
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $08,$08,$4A,$08,$44,$08,$04
                .byte %00001000         ; ..#...   ; shadow, ball-R, and ball-L
                .byte %00001000         ; ..#...
                .byte %01001010         ; .##.#.
                .byte %00001000         ; ..#...
                .byte %01000100         ; .#.#..
                .byte %00001000         ; ..#...
                .byte %00000100         ; ...#..

                ;.byte $08,$48,$48,$4A,$08,$44,$00
                .byte %00001000         ; ..#...   ; shadow, ball-R, and ball-L
                .byte %01001000         ; .##...
                .byte %01001000         ; .##...
                .byte %01001010         ; .##.#.
                .byte %00001000         ; ..#...
                .byte %01000100         ; .#.#..
                .byte %00000000         ; ......

                ;.byte $48,$4A,$08,$40,$00,$00,$00
                .byte %01001000         ; .##...    ; shadow, ball-R, and ball-L
                .byte %01001010         ; .##.#.
                .byte %00001000         ; ..#...
                .byte %01000000         ; .#....
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $44,$00,$00,$00,$00,$00,$00
                .byte %01000100         ; .#.#..   ; ball-R and ball-L
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
AnimSplash_D .proc
                lda animSplashFrame     ; [0:5]
                cmp #$86                ; max frame? (hi-bit + 6)
                bcc _1                  ;   no

                jmp AnimateSplash._FINISH

; - - - - - - - - - - - - - - - - - - -
_1              and #$0F                ; strip the hi-bit
                tax

                lda #$00
                cpx #$00
                beq _2

_next1          clc                     ; calculate X*9
                adc #$09

                dex
                bne _next1

_2              tax
                lda ballController
                bne _3

                ldy yPosBall
                lda _frame+0,X
                ;!!sta MISL_BASE,Y
                lda _frame+1,X
                ;!!sta MISL_BASE-1,Y
                lda _frame+2,X
                ;!!sta MISL_BASE-2,Y
                lda _frame+3,X
                ;!!sta MISL_BASE-3,Y
                lda _frame+4,X
                ;!!sta MISL_BASE-4,Y
                lda _frame+5,X
                ;!!sta MISL_BASE-5,Y
                lda _frame+6,X
                ;!!sta MISL_BASE-6,Y

_3              lda animSplashFrame
                and #$7F                ; strip the hi-bit
                tax

                lda _audioControl,X
                ;!!sta AUDC3

                rts

;--------------------------------------

; ......  ..#...  ......  ......  ......  ......
; ......  ...#..  ..#...  ......  ......  ......
; ......  .#....  ...#..  ..#...  ......  ......
; ......  ..#...  .#....  ......  ......  ......
; ......  .#.#..  ..#...  ...#..  ......  ......
; ......  .##.#.  .##.#.  .#....  ......  ......
; ......  .##.#.  .##.#.  ..#.#.  ..#...  ......
; ......  .##.#.  ..#...  .##.#.  ......  ......
; ..#...  ..#...  ..#...  ..#...  .#.#..  ..#...

_audioControl   .byte $81,$82,$83,$84,$83,$82

_frame          ;.byte $08,$00,$00,$00,$00,$00,$00,$00,$00
                .byte %00001000         ; ..#...   ; ball-R
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $08,$4A,$4A,$4A,$44,$08,$40,$04,$08
                .byte %00001000         ; ..#...   ; shadow, ball-R, and ball-L
                .byte %01001010         ; .##.#.
                .byte %01001010         ; .##.#.
                .byte %01001010         ; .##.#.
                .byte %01000100         ; .#.#..
                .byte %00001000         ; ..#...
                .byte %01000000         ; .#....
                .byte %00000100         ; ...#..
                .byte %00001000         ; ..#...

                ;.byte $08,$08,$4A,$4A,$08,$40,$04,$08,$00
                .byte %00001000         ; ..#...   ; shadow, ball-R, and ball-L
                .byte %00001000         ; ..#...
                .byte %01001010         ; .##.#.
                .byte %01001010         ; .##.#.
                .byte %00001000         ; ..#...
                .byte %01000000         ; .#....
                .byte %00000100         ; ...#..
                .byte %00001000         ; ..#...
                .byte %00000000         ; ......

                ;.byte $08,$4A,$0A,$40,$04,$00,$08,$00,$00
                .byte %00001000         ; ..#...   ; shadow, ball-R, and ball-L
                .byte %01001010         ; .##.#.
                .byte %00001010         ; ..#.#.
                .byte %01000000         ; .#....
                .byte %00000100         ; ...#..
                .byte %00000000         ; ......
                .byte %00001000         ; ..#...
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $44,$00,$08,$00,$00,$00,$00,$00,$00
                .byte %01000100         ; .#.#..   ;ball-R and ball-L
                .byte %00000000         ; ......
                .byte %00001000         ; ..#...
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                ;.byte $08,$00,$00,$00,$00,$00,$00,$00,$00
                .byte %00001000         ; ..#...   ; ball-R
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......
                .byte %00000000         ; ......

                .endproc
