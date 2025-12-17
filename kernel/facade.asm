
                .include "api.asm"


preserveKernelEvt   .word ?


;======================================
;
;======================================
InitKernel      .proc
                lda kernel.args.events
                sta preserveKernelEvt
                lda kernel.args.events+1
                sta preserveKernelEvt+1

                lda #<kernelEvt
                sta kernel.args.events
                lda #>kernelEvt
                sta kernel.args.events+1

                ;;jsr ScheduleFrameEvent

                rts
                .endproc


;======================================
;
;======================================
RestoreKernel   .proc
                lda preserveKernelEvt
                sta kernel.args.events
                lda preserveKernelEvt+1
                sta kernel.args.events+1

                rts
                .endproc


;======================================
;
;======================================
ScheduleFrameEvent .proc
;   determine the current frame #
                lda #kernel.args.timer.FRAMES|kernel.args.timer.QUERY
                sta kernel.args.timer.units

                jsr kernel.Clock.SetTimer
                bcs _err

;   schedule a notification for the next frame
                adc #$01
                sta kernel.args.timer.absolute

                lda #kernel.args.timer.FRAMES
                sta kernel.args.timer.units

                lda #$55
                sta kernel.args.timer.cookie

                jsr kernel.Clock.SetTimer
                bcs _err

                rts

; - - - - - - - - - - - - - - - - - - -
_err            lda #TRUE
                sta ProcessEvents._outOfTokens

                rts
                .endproc


;======================================
;
;======================================
ProcessEvents   .proc
                lda #$FF
                sta KEYCODE
                sta KEYCHAR

                lda kernel.args.events.pending
                bpl _XIT

_nextEvent      jsr kernel.NextEvent
                bcs _XIT

                lda kernelEvt.type
                cmp #kernel.event.key.PRESSED
                beq _keyDown

                cmp #kernel.event.key.RELEASED
                beq _keyUp

                ;;cmp #kernel.event.timer.EXPIRED
                ;;beq _timer
                bra _nextEvent

; - - - - - - - - - - - - - - - - - - -

_keyDown        lda DEBOUNCE
                bne _cont

                lda kernelEvt.key.raw
                sta KEYCODE

                bit kernelEvt.key.flags ; meta-key?
                bmi _cont               ;   yes, has no ascii code

                lda kernelEvt.key.ascii
                sta KEYCHAR

                lda #TRUE
                sta DEBOUNCE

_cont           bra _nextEvent

; - - - - - - - - - - - - - - - - - - -

_keyUp          bit kernelEvt.key.flags ; meta-key?
                bmi _noDebounce         ;   yes, has no ascii code

                stz DEBOUNCE

_noDebounce     lda #$FF
                sta KEYCODE
                sta KEYCHAR

                bra _nextEvent

; - - - - - - - - - - - - - - - - - - -

;;_timer          jsr ScheduleFrameEvent
;;                jsr DoTimers
;;                bra _nextEvent

; - - - - - - - - - - - - - - - - - - -

;;_XIT1           lda _outOfTokens
;;                beq _XIT
;;
;;                stz _outOfTokens
;;
;;                jsr ScheduleFrameEvent
;;                bra _nextEvent

; - - - - - - - - - - - - - - - - - - -
_XIT            rts

;--------------------------------------

;;_outOfTokens    .byte $00

                .endproc
