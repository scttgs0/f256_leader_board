
;======================================
;
;======================================
AimTarget       .proc
AIM_BASE        = $0060 ; MISL_BASE
_HPOSM1_Ball    = $0061 ; HPOSM1
_HPOSM2_TargetL = $0062 ; HPOSM2
_HPOSM0_TargetR = $0063 ; HPOSM0
;---

                jsr ClearMissiles

; - - - - - - - - - - - - - - - - - - -
;   place the ball
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

                txa
                ror
                adc xPosDeltaMissile0
                sta _HPOSM1_Ball
                sta xPosBall

                tya
                clc
                adc yPosDeltaMissile0
                tay
                sta yPosBall

; - - - - - - - - - - - - - - - - - - -
;   place the aim target
                lda #$04
                sta AIM_BASE,Y          ; two scanlines
                sta AIM_BASE-1,Y

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
_ENTRY1         lda isSwingInProgress
                ora swingAnimCounter
                beq _1

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
;   reposition the aim target left
_1              lda timerIsActive+9     ; timer 9 active?
                bne _XIT1               ;   yes

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
                cmp #unitYARDS
                bcs _2

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
                cmp #unitYARDS
                bcs _4

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

                lda #<$18FF
                sta aimPosition
                lda #>$18FF
                sta aimPosition_HI

; - - - - - - - - - - - - - - - - - - -
;   view-projection aim target position
_5              ldx #xformAIM_POS
                jsr VertexTransform

                txa
                lsr
                adc xPosDeltaMissile0
                adc #$01
                sta _HPOSM0_TargetR     ; position missile-0 (right-side of aim target)
                sta xPosBallShadow

                sbc #$01
                sta _HPOSM2_TargetL     ; position missile-2 (left-side of aim target)
                sta xPosAimTarget

                tya
                clc
                adc yPosDeltaMissile0
                sta yPosBallShadow

; - - - - - - - - - - - - - - - - - - -
;   render aim point
                tay
                lda #$02                ; missile-0 only
                sta AIM_BASE-2,Y        ; two scanlines at the top
                sta AIM_BASE-1,Y
                sta AIM_BASE+1,Y        ; two scanlines at the bottom
                sta AIM_BASE+2,Y

                lda #$11                ; missile-2 and missile-0 only
                sta AIM_BASE,Y          ; one scanline at the middle

                rts
                .endproc
