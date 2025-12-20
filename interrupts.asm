
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Main IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqMain         .proc
                pha
                phx
                phy

; - - - - - - - - - - - - - - - - - - -
;   switch to system map
                lda IOPAGE_CTRL
                pha                     ; preserve
                stz IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                lda INT_PENDING_REG0
                sta irq_pending
                ;;sta INT_PENDING_REG0  ; will be reset by the kernel

                ; lda INT_PENDING_REG1
                ; bit #INT01_VIA1
                ; beq _chkSOF

                ; lda INT_PENDING_REG1
                ; sta INT_PENDING_REG1

                ; jsr KeyboardHandler

_chkSOF         lda irq_pending
                bit #INT00_SOF
                beq _chkSOL

                jsr irqVBIHandler

_chkSOL         ;!!lda irq_pending
                ;!!bit #INT00_SOL
                ;!!beq _XIT

                ;!!jsr irqDLIHandler

; - - - - - - - - - - - - - - - - - - -
_XIT            pla                     ; restore
                sta IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                ply
                plx
                pla

irqMain_END     jmp (priorIRQ_BRK)
                ;;rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Vertical Blank Interrupt (SOF)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqVBIHandler   .proc
                pha
                phx
                phy

                inc JIFFYCLOCK          ; increment the jiffy clock each VBI

                jsr DoTimers
                jsr DoSwingGauge

                ;;lda #TRUE
                ;;sta gameGate

;   when already in joystick mode, bypass the override logic
                lda InputType
                cmp #itJoystick
                beq _joyModeP1

                lda JOYSTICK0           ; read joystick0
                and #$1F
                cmp #$1F
                beq _chkJoy2            ; when no activity, keyboard is alternative

                sta InputFlags          ; joystick activity -- override keyboard input
                lda #itJoystick
                sta InputType

                bra _chkJoy2

_joyModeP1      lda JOYSTICK0           ; read joystick0
                sta InputFlags

_chkJoy2        lda InputType+1
                cmp #itJoystick
                beq _joyModeP2

                lda JOYSTICK1           ; read joystick1
                and #$1F
                cmp #$1F
                beq _XIT                ; when no activity, keyboard is alternative

                sta InputFlags+1        ; joystick activity -- override keyboard input
                lda #itJoystick
                sta InputType+1

                bra _XIT

_joyModeP2      lda JOYSTICK1           ; read joystick0
                sta InputFlags+1

                ; jsr AnimateSprites
                ; jsr EventController.Process

_XIT            ply
                plx
                pla
                rts
                .endproc


;======================================
;
;--------------------------------------
; called from interrupt
;======================================
DoTimers        .proc
                ldx #$0F                ; timer index
_nextTimer      lda timerIsActive,X     ; timer X active?
                beq _1                  ;   no

                dec timerRemaining,X    ; tick..., expired?
                bne _2                  ;   no

                lda #$00                ; make inactive
                sta timerIsActive,X

                lda timerDuration,X     ; reset ticks
                sta timerRemaining,X

_1              ;!!cpx audioF2Chaos
                ;!!bne _2

                ;!!inc unused_9C0E
                ;!!dec unused_9C0F
                ;!!inc timerIsActive,X     ; make active

_2              dex
                bpl _nextTimer

; - - - - - - - - - - - - - - - - - - -
;   timer loop finished

;   executed each jiffy cycle

                lda windFactor          ; [-$40:-$28]
                beq _3

                dec windFactor

_3              inx                     ; X=$00

                inc _jiffyCount
                lda _jiffyCount
                cmp #70                 ; 70 jiffies = 1 sec
                bcc _XIT

; - - - - - - - - - - - - - - - - - - -
;   executed once per second

                stz _jiffyCount         ; reset jiffy counter

                lda clockControl
                ora #$80
                sta clockControl

;   adjust clock by one second
                sed                     ; clock uses BCD

                clc
                lda clockSecs           ; second++
                adc #$01
                sta clockSecs

                cmp #$60                ; <60?
                bcc _4                  ;   yes

                stz clockSecs           ;   no, reset seconds

                lda clockMins           ; mins++
                adc #$00
                sta clockMins

                cmp #$60                ; <60?
                bcc _4                  ;   yes

                stz clockMins           ;   no, reset minutes

                lda clockHour           ; hour++
                adc #$00
                sta clockHour

                cmp #$24                ; <24?
                bcc _4                  ;   yes

                stz clockHour           ;   no, reset hour

_4              cld
_XIT            rts

;--------------------------------------

_jiffyCount     .byte $00

                .endproc
