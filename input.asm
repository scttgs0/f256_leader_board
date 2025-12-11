
;======================================
;
;======================================
GetKeycode      .proc
                jsr ProcessEvents

                lda KEYCODE
                cmp #$FF                ; any key pressed?
                beq _XIT                ;   no

                pha                     ; preserve keycode

                lda #$FF                ; reset
                sta KEYCODE

                jsr PlayInputAction

                pla                     ; restore keycode

_XIT            rts
                .endproc


;======================================
;
;======================================
vecProcessESC   jmp ProcessESC


;======================================
;
;======================================
ReadJoystick    .proc
                ;!!lda TRIG0               ; status flag = button state
                php                     ; preserve button state

                ;!!jsr ReadPortA           ; on return, A=%1100xxxx
                eor #$0F                ; flip the joystick0 bits
                and #$1F                ; mask axis bits

                plp                     ; button pushed?
                bne _1                  ;   no

                ora #$10                ;   yes, set bit-4
_1              cmp #$00                ; any input?
                beq _2                  ;   no

                ora joystick
                sta joystick

                lda #$00
                sta counterDemo         ; disable demo

_2              lda counterDemo         ; demo mode?
                beq _XIT                ;   no

                lda joystickOverride    ; override input
                sta joystick

_XIT            rts
                .endproc


;======================================
;
;======================================
WaitForButton   .proc
                lda #$00
                sta joystick            ; no input

_next1          jsr vecProcessESC
                jsr ReadJoystick

                lda #$10
                bit joystick            ; button down?
                beq _next1              ;   no

                lda #$20                ; duration
                ldx #$00                ; timer 0
                jsr SetTimer

;   wait for timer
_wait1          lda timerIsActive       ; timer 0 active?
                bne _wait1              ;   yes

                rts
                .endproc


;======================================
;
;======================================
DemoInput       .proc
                lda counterDemo         ; demo mode?
                bne _1                  ;   yes

_XIT1           rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$01
                nop                     ; removed: cmp const_1
                bne _3

;   /// keyframe 0 - AIM ///
                lda aimPosition
                cmp #$30
                bcs _2

                lda #$08
                sta joystickOverride    ; right deflection

                rts

; - - - - - - - - - - - - - - - - - - -
_2              inc counterDemo

                lda #$10
                sta joystickOverride    ; button pushed

                lda #$25
                sta _data1

                rts

; - - - - - - - - - - - - - - - - - - -
_3              cmp #$02
                bne _4

;   /// keyframe 2 - STROKE ///
_next1          lda gaugeValue
                cmp #$0F                ; at peak power?
                bne _XIT1               ;   no

                lda #$00
                sta joystickOverride    ; no input

                inc counterDemo

                rts

; - - - - - - - - - - - - - - - - - - -
_4              cmp #$03
                bne _5

;   /// keyframe 3 - SNAP ///
_next2          lda gaugeValue
                cmp _data1              ; <target value?
                bcc _XIT1               ;   yes

                lda #$10
                sta joystickOverride    ; button pushed

                inc counterDemo
                rts

; - - - - - - - - - - - - - - - - - - -
_5              cmp #$04
                bne _6

;   /// keyframe 4 - NOP ///
                rts

; - - - - - - - - - - - - - - - - - - -
_6              cmp #$05
                bne _8

;   /// keyframe 5 - CLUB SELECT ///
                lda activeClub
                cmp #$0C                ; pitching wedge?
                beq _7                  ;   yes

                lda #$02
                sta joystickOverride    ; down deflection

                rts

; - - - - - - - - - - - - - - - - - - -
_7              inc counterDemo

                lda #$10
                sta joystickOverride    ; button pushed

                lda #$24
                sta _data1

                rts

; - - - - - - - - - - - - - - - - - - -
;   /// keyframe 6 - STROKE2 ///
_8              cmp #$06                ; removed: cmp AimTarget._always6+1
                nop
                beq _next1

;   /// keyframe 7 - SNAP2 ///
                cmp #$07
                beq _next2

                cmp #$08
                bne _9

;   /// keyframe 8 - NOP ///
                rts

; - - - - - - - - - - - - - - - - - - -
_9              cmp #$09
                bne _XIT

;   /// keyframe 9 - PUTT AIM ///
                lda aimPosition
                cmp #$5C
                bcs _10

                lda #$08
                sta joystickOverride    ; right deflection

                rts

; - - - - - - - - - - - - - - - - - - -
_10             inc counterDemo

                lda #$10
                sta joystickOverride    ; button pushed

_XIT            rts

;--------------------------------------

_data1          .byte $00

                .endproc
