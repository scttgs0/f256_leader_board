
;======================================
;
;--------------------------------------
; called from interrupt
;======================================
ProcessClubSwingAnim .proc
                rts
                .endproc


;======================================
; Preserve an area of the screen, that
; is overwritten by the club animation,
; to facilitate erasure of the keyframe
;--------------------------------------
; build table of byte values from the
; screen locations specified in table
; tblClubKeyframes
;======================================
PreserveScreenPatch .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------
;   used during interrupt
clubAnimPtr     .word $0000             ; keyframe table pointer (loaded into $D7)
tblClubPatch    .byte $00,$00,$00       ; screen values being preserved (largest block is 21-bytes)
                .byte $00,$00,$00
                .byte $00,$00,$00
                .byte $00,$00,$00
                .byte $00,$00,$00
                .byte $00,$00,$00
                .byte $00,$00,$00
