
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
                bne _XIT
                ;!!jmp CalcBallPixelMask._ENTRY1

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[V]]
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
                stz isSwingAnimCounterActive    ; =FALSE
                stz swingAnimCounter            ; =0

                lda #$80
                sta flags_9D76
                sta animSplashFrame       ; set bit-7; splash is active (frame 0)

_next1          ldx #$06                        ; missile-1 (ball)
                jsr CalcMissilePositionAndMask  ; result in A=maskedPixelValue, [X,Y]

                cmp #$03                ; missile-1?
                bne _1                  ;   no

                dec newBallPosY         ;   yes
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
_1              lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda newBallPosY
                sta yPosBall

                .frsSpriteSetX_8bit newBallPosX,8
                .frsSpriteSetY_8bit newBallPosY,8

                jsr ClearMissiles

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
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

xMarginOverscan .byte $20
yMarginOverscan .byte $27

xPosTemp        .word $0000
yPosTemp        .word $0000


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
                adc yMarginOverscan
                sta yTransform

                lda xTransform
                ;!!lsr                     ; necessary??
                clc
                adc xMarginOverscan
                tax
                stx newBallPosX
                lda #$00
                adc #$00
                sta newBallPosX+1

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
                adc yMarginOverscan
_4              sta newBallShadowPosY

                lda yTransform
                sta newBallPosY

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
                jmp ShiftPixelMask      ; result in A=maskedPixelValue

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

                lda newBallShadowPosY   ; when [X:=7] shadow
                ldx newBallPosX
                jmp _2

; - - - - - - - - - - - - - - - - - - -
_1              lda newBallPosY
                ldx newBallPosX

_2              sec
                sbc yMarginOverscan
                tay

                txa
                sec
                sbc xMarginOverscan
                tax
                ; TODO: hi-byte

                rts
                .endproc


;======================================
;
;====================================== ;[[U]]
AnimateSplash   .proc
                bit animSplashFrame     ; splash is active?
                bmi _1                  ;   yes, initiate splash animation

_XIT1           rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              lda timerIsActive+6     ; timer 6 active?
                bne _XIT1               ;   yes

                inc timerIsActive+6     ;   no, make active
                inc animSplashFrame     ;   no, =$81+

; - - - - - - - - - - - - - - - - - - -
_ENTRY1         lda polyVertY_HI
                cmp #>$0A00
                bcc _XIT_D              ; very close

                cmp #>$0F00
                bcc _XIT_C

                cmp #>$1400
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
                cmp #$84                ; hi-bit (active) & frame 4
                bcs _FINISH
                jmp AnimSplash_A

; - - - - - - - - - - - - - - - - - - -
_FINISH         lda #$00                ; clear audio
                ;!!sta AUDC3
                ;!!sta AUDF3
                stz animSplashFrame     ; disable splash

                jmp ClearMissiles

                .endproc


;======================================
;
;====================================== ;[[F]]
SetBallFlags    .proc
                lda animSplashFrame     ; splash is active?
                beq _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              lda polyVertZ_HI
                bne _2

                lda polyVertZ_LO
                beq _3

                cmp #$18                ; surface layer (24 inches)?
                bcs _2

                lda nodeOperation
                cmp #operFILL           ; fill mode?
                bne _2                  ;   no

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

                stz flagsBall_9D81

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[V]]
RenderBall      .proc
                bit animSplashFrame     ; splash is active?
                bpl _1                  ;   no

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
_1              lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda newBallShadowPosY   ; update the new shadow vertical position
                sta yPosBallShadow

                ldx newBallPosX+1       ; move ball and shadow horizontally
                stx xPosBallShadow+1
                stx xPosBall+1
                ldx newBallPosX
                stx xPosBallShadow
                stx xPosBall

                lda newBallPosY         ; update the ball's new vertical position
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
                .frsSpriteSetY_8bit yPosBallShadow,9

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
                .frsSpriteSetY_8bit yPosBall,8

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
_4              jsr ShiftPixelMask      ; result in A=maskedPixelValue

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

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda ballController
                bne _2

                .frsSpriteShow 12        ; draw at the new position
                .frsSpriteSetX xPosBall,12
                .frsSpriteSetY_8bit yPosBall,12

                cpx #$00
                bne _1A

                sei
                lda #<anim3cell00
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell00
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell00
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _2

; - - - - - - - - - - - - - - - - - - -
_1A             cpx #$01
                bne _1B

                sei
                lda #<anim3cell01
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell01
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell01
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _2

; - - - - - - - - - - - - - - - - - - -
_1B             cpx #$02
                bne _1C

                sei
                lda #<anim3cell02
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell02
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell02
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _2

; - - - - - - - - - - - - - - - - - - -
_1C             sei
                lda #<anim3cell03
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell03
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell03
                sta SPR(sprite_t.ADDR+2, 12)

                cli

; - - - - - - - - - - - - - - - - - - -
_2              lda animSplashFrame
                and #$7F                ; strip the hi-bit

                tax
                lda _audioControl,X
                ;!!sta AUDC3

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                rts

;--------------------------------------
;   frames

; ......  ......  .#.#..  ......
; ......  ..#...  ......  ......
; ..#...  ..#...  ..#...  .#.#..

_audioControl   .byte $81,$82,$82,$81

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
AnimSplash_B    .proc
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

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda ballController
                beq _proceed
                jmp _2

; - - - - - - - - - - - - - - - - - - -
_proceed        .frsSpriteShow 12        ; draw at the new position
                .frsSpriteSetX xPosBall,12
                .frsSpriteSetY_8bit yPosBall,12

                cpx #$00
                bne _1A

                sei
                lda #<anim3cell04
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell04
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell04
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _2

; - - - - - - - - - - - - - - - - - - -
_1A             cpx #$01
                bne _1B

                sei
                lda #<anim3cell05
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell05
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell05
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _2

; - - - - - - - - - - - - - - - - - - -
_1B             cpx #$02
                bne _1C

                sei
                lda #<anim3cell06
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell06
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell06
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _2

; - - - - - - - - - - - - - - - - - - -
_1C             cpx #$03
                bne _1D

                sei
                lda #<anim3cell07
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell07
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell07
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _2

; - - - - - - - - - - - - - - - - - - -
_1D             sei
                lda #<anim3cell08
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell08
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell08
                sta SPR(sprite_t.ADDR+2, 12)

                cli

; - - - - - - - - - - - - - - - - - - -
_2              lda animSplashFrame
                and #$7F                ; strip the hi-bit
                tax

                lda _audioControl,X
                ;!!sta AUDC3

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                rts

;--------------------------------------
;   frames

; ......  ..#...  ......  ......  ......
; ......  ...#..  ..#...  ......  ......
; ......  .##...  ...#..  ..#...  ......
; ......  ..#...  .#....  ...#..  ......
; ..#...  ..#...  ..#...  .##...  .#.#..

_audioControl   .byte $81,$82,$82,$81,$81

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
AnimSplash_C    .proc
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

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda ballController
                beq _proceed
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_proceed        .frsSpriteShow 12        ; draw at the new position
                .frsSpriteSetX xPosBall,12
                .frsSpriteSetY_8bit yPosBall,12

                cpx #$00
                bne _2A

                sei
                lda #<anim3cell09
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell09
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell09
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2A             cpx #$01
                bne _2B

                sei
                lda #<anim3cell10
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell10
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell10
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2B             cpx #$02
                bne _2C

                sei
                lda #<anim3cell11
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell11
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell11
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2C             cpx #$03
                bne _2D

                sei
                lda #<anim3cell12
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell12
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell12
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2D             sei
                lda #<anim3cell13
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell13
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell13
                sta SPR(sprite_t.ADDR+2, 12)

                cli

; - - - - - - - - - - - - - - - - - - -
_3              lda animSplashFrame
                and #$7F                ; strip the hi-bit
                tax

                lda _audioControl,X
                ;!!sta AUDC3

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                rts

;--------------------------------------
;   frames

; ......  ...#..  ......  ......  ......
; ......  ..#...  .#.#..  ......  ......
; ......  .#.#..  ..#...  ......  ......
; ......  ..#...  .##.#.  .#....  ......
; ......  .##.#.  .##...  ..#...  ......
; ......  ..#...  .##...  .##.#.  ......
; ..#...  ..#...  ..#...  .##...  .#.#..

_audioControl   .byte $81,$82,$83,$82,$81

                .endproc


;--------------------------------------
;
;-------------------------------------- ;[[U]]
AnimSplash_D    .proc
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

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                lda ballController
                beq _proceed
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_proceed        .frsSpriteShow 12        ; draw at the new position
                .frsSpriteSetX xPosBall,12
                .frsSpriteSetY_8bit yPosBall,12

                cpx #$00
                bne _2A

                sei
                lda #<anim3cell14
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell14
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell14
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2A             cpx #$01
                bne _2B

                sei
                lda #<anim3cell15
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell15
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell15
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2B             cpx #$02
                bne _2C

                sei
                lda #<anim3cell16
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell16
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell16
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2C             cpx #$03
                bne _2D

                sei
                lda #<anim3cell17
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell17
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell17
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2D             cpx #$04
                bne _2E

                sei
                lda #<anim3cell18
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell18
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell18
                sta SPR(sprite_t.ADDR+2, 12)

                cli
                bra _3

; - - - - - - - - - - - - - - - - - - -
_2E             sei
                lda #<anim3cell19
                sta SPR(sprite_t.ADDR, 12)
                lda #>anim3cell19
                sta SPR(sprite_t.ADDR+1, 12)
                lda #`anim3cell19
                sta SPR(sprite_t.ADDR+2, 12)

                cli

; - - - - - - - - - - - - - - - - - - -
_3              lda animSplashFrame
                and #$7F                ; strip the hi-bit
                tax

                lda _audioControl,X
                ;!!sta AUDC3

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                rts

;--------------------------------------
;   frames

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

                .endproc
