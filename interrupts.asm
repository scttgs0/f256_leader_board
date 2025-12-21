
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Main IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;[[V]]
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
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;[[U]]
irqVBIHandler   .proc
                pha
                phx
                phy

                inc JIFFYCLOCK          ; increment the jiffy clock each VBI

                jsr DoSwingGauge

                jsr DoTimers
                jsr SwingAnim_DeferredA
                ;!!jsr Math_DeferredB

                ply
                plx
                pla
                rts
                .endproc


;======================================
;
;--------------------------------------
; called from interrupt
;====================================== ;[[V]]
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

_1              cpx _audioF2Chaos
                bne _2

                inc unused_9C0E
                dec unused_9C0F
                inc timerIsActive,X     ; make active

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

_audioF2Chaos   .byte $12,$00

                .endproc


;======================================
;
;--------------------------------------
; called from interrupt
;====================================== ;[[F]]
SwingAnim_DeferredA .proc
                lda isSwingDisabled
                beq _1

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda isSwingInProgress   ; swing anim in progress?
                bne _2                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_2              lda golferSwingFrame
                cmp #$20                ; <32? (max)
                bcc _3                  ;   yes

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
_3              cmp golferSwingFrameMax
                bne _4

                rts

; - - - - - - - - - - - - - - - - - - -
_4              sta golferSwingFrameMax

                jsr DrawGolfer
                ;!!jmp ProcessClubSwingAnim    ; render club

                rts     ; HACK:
                .endproc
