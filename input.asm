
;======================================
;
;====================================== ;[[V]]
GetKeycode      .proc
                jsr ProcessEvents

                lda KEYCODE
                cmp #$FF                ; any key pressed?
                beq _XIT                ;   no

                cmp #$B8                ; left/right-arrow key?
                bcs _1                  ;   yes

                cmp #$06                ; meta-key?
                bcs _2                  ;   no

_1              lda #$FF                ;   yes, reset and exit
                sta KEYCODE

                bra _XIT

_2              pha                     ; preserve keycode

                ;;lda #$FF                ; reset
                ;;sta KEYCODE

                jsr PlaySoundInputAction

                pla                     ; restore keycode

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[F]]
ReadJoystick    .proc
                lda JOYSTICK0           ; on return, A=%xxxB_DDDD
                eor #$1F                ; flip the bits
                and #$1F                ; mask bits

_1              cmp #$00                ; any input?
                beq _2                  ;   no

                ora joystick
                sta joystick

                stz counterDemo         ; disable demo

_2              lda counterDemo         ; demo mode?
                beq _XIT                ;   no

                lda joystickOverride    ; override input
                sta joystick

_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[F]]
WaitForButton   .proc
                stz joystick            ; no input

_next1          jsr vecProcessESC
                jsr ReadJoystick

                lda #joyButton0         ; button pushed?
                bit joystick
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
;====================================== ;[[F]]
vecProcessESC   jmp ProcessESC


;======================================
;
;====================================== ;[[F]]
DemoInput       .proc
                lda counterDemo         ; demo mode?
                bne _1                  ;   yes

_XIT1           rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$01
                bne _3

;   /// keyframe 1 - AIM ///
                lda aimPosition
                cmp #$30                ; >= 48?
                bcs _2                  ;   yes

                lda #joyRIGHT           ; right deflection
                sta joystickOverride

                rts

; - - - - - - - - - - - - - - - - - - -
_2              inc counterDemo

                lda #joyButton0         ; button pushed
                sta joystickOverride

                lda #$25                ; target = 37
                sta _targetVal

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
                cmp _targetVal          ; <target value?
                bcc _XIT1               ;   yes

                lda #joyButton0         ; button pushed
                sta joystickOverride

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

                lda #joyDOWN            ; down deflection
                sta joystickOverride

                rts

; - - - - - - - - - - - - - - - - - - -
_7              inc counterDemo

                lda #$10
                sta joystickOverride    ; button pushed

                lda #$24                ; target = 36
                sta _targetVal

                rts

; - - - - - - - - - - - - - - - - - - -
;   /// keyframe 6 - STROKE2 ///
_8              cmp #$06
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
                cmp #$5C                ; >= 92?
                bcs _10                 ;   yes

                lda #joyRIGHT           ; right deflection
                sta joystickOverride

                rts

; - - - - - - - - - - - - - - - - - - -
_10             inc counterDemo

                lda #joyButton0         ; button pushed
                sta joystickOverride

_XIT            rts

;--------------------------------------

_targetVal      .byte $00

                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           duration
;   X           index [0:15]
;====================================== ;[[V]]
SetTimer        .proc
                sta timerDuration,X
                sta timerRemaining,X

                lda #TRUE
                sta timerIsActive,X

                rts
                .endproc
