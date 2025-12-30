
;======================================
;
;====================================== ;[[F]]
AimTarget       .proc
; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                jsr ClearMissiles

; - - - - - - - - - - - - - - - - - - -
;   view-projection ball position
                lda #<$1800
                sta polyVertX_LO
                lda #>$1800
                sta polyVertX_HI

                lda #<$0018             ; surface (24 inches)
                sta polyVertZ_LO
                lda #>$0018
                sta polyVertZ_HI

                lda #<$0500
                sta polyVertY_LO
                lda #>$0500
                sta polyVertY_HI

                ldx #xformNORMAL
                jsr VertexTransform

;   render the ball
                txa
                clc
                adc xMarginOverscan
                sta xPosBall
                lda #$00
                adc #$00
                sta xPosBall+1

                tya
                clc
                adc yMarginOverscan
                sta yPosBall

                .frsSpriteShow 8
                .frsSpriteSetX xPosBall,8
                .frsSpriteSetY_8bit yPosBall,8

; - - - - - - - - - - - - - - - - - - -
;   place the aim target
                lda #<$1800
                sta aimPosition
                lda #>$1800
                sta aimPosition_HI

                lda #<$0700
                sta const_0x700
                lda #>$0700
                sta const_0x700+1

                lda #$01
                sta timerDuration+9     ; timer 9 = 1 tick
                sta timerRemaining+9

; - - - - - - - - - - - - - - - - - - -
;   clean up the stack
                pla

; - - - - - - - - - - - - - - - - - - -
;   entry point to skip the above ball placement.
_SKIPBALL
; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
;   when swing has begun, skip the aim target.
                lda isSwingInProgress
                ora swingAnimCounter
                beq _1

_XIT1           jmp _XIT

; - - - - - - - - - - - - - - - - - - -
;   reposition the aim target left
_1              lda timerIsActive+9     ; timer 9 active?
                bne _XIT1               ;   yes, exit

                inc timerIsActive+9     ;   no, make active

                jsr ReadJoystick

                lda #joyLEFT            ; left deflection?
                bit joystick
                beq _3                  ;   no

                lda aimPosition
                sec
                sbc #<$0001
                sta aimPosition
                lda aimPosition_HI
                sbc #>$0001
                sta aimPosition_HI

; - - - - - - - - - - - - - - - - - - -
;   check limits
                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS          ; yards?
                bcs _2                  ;   yes

;   feet unit limits (putt)
                lda aimPosition_HI
                cmp #>$18A0
                bcs _3

                lda aimPosition
                cmp #<$18A0
                bcs _3

                lda #<$18A0             ; clamp
                sta aimPosition

                bra _3

; - - - - - - - - - - - - - - - - - - -
;   yards unit limits (driving)
_2              lda aimPosition_HI
                cmp #>$1700
                bcs _5

                lda #>$1700             ; clamp
                sta aimPosition_HI
                lda #<$1700
                sta aimPosition

; - - - - - - - - - - - - - - - - - - -
;   reposition the aim target right
_3              lda #joyRIGHT           ; right deflection?
                bit joystick
                beq _5                  ;   no

                lda aimPosition
                clc
                adc #<$0001
                sta aimPosition
                lda aimPosition_HI
                adc #>$0001
                sta aimPosition_HI

; - - - - - - - - - - - - - - - - - - -
;   check limits
                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS          ; yards?
                bcs _4                  ;   yes

;   feet unit limits (putt)
                lda aimPosition_HI
                cmp #>$1880
                bcc _5

                lda aimPosition
                cmp #<$1880
                bcc _5

                lda #<$187F             ; clamp
                sta aimPosition

                bra _5

; - - - - - - - - - - - - - - - - - - -
;   yards unit limits (driving)
_4              lda aimPosition_HI
                cmp #>$1900
                bcc _5

                lda #<$18FF             ; clamp
                sta aimPosition
                lda #>$18FF
                sta aimPosition_HI

; - - - - - - - - - - - - - - - - - - -
;   view-projection aim target position
_5              ldx #xformAIM_POS
                jsr VertexTransform

; - - - - - - - - - - - - - - - - - - -
;   render the aim target
                txa
                clc
                adc xMarginOverscan
                sta xPosTemp
                lda #$00
                adc #$00
                sta xPosTemp+1

                tya
                clc
                adc yMarginOverscan
                sta yPosBallShadow
                sta yPosTemp

                .frsSpriteShow 10
                .frsSpriteSetX xPosTemp,10
                .frsSpriteSetY_8bit yPosTemp,10

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
_XIT            pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
                rts
                .endproc
