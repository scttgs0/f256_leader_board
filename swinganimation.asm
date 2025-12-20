
;======================================
;
;--------------------------------------
; called from interrupt
;====================================== ;[[U]]
ProcessClubSwingAnim .proc
_screen         = zpC3
_mask           = zpC5
_keyframe       = zpD7
;---

                ldy #$00                ; active keyframe for club animation [$00:1F]
                lda clubAnimPtr
                sta _keyframe
                lda clubAnimPtr+1
                sta _keyframe+1

;   restore preserved patch back to screen (erase club)
                ldx #$00
_next1          lda (_keyframe),Y       ; screen memory DEST (by keyframe index)
                sta _screen
                iny
                lda (_keyframe),Y
                sta _screen+1

                php                     ; preserve flags
                iny
                plp                     ; restore flags
                beq _1                  ; when end-marker is reached

                tya                     ; preserve keyframe index
                pha

;   write to screen memory from cache
                ldy #$00
                lda tblClubPatch,X
                sta (_screen),Y

                inx
                pla                     ; restore keyframe index
                tay
                iny                     ; +1 keyframe index
                bne _next1              ; [unc]

; - - - - - - - - - - - - - - - - - - -
_1              lda golferSwingFrame    ; frame 0?
                beq _2                  ;   yes

;   advance clubAnimPtr
                tya
                clc
                adc clubAnimPtr
                sta clubAnimPtr
                sta _keyframe

                lda clubAnimPtr+1
                adc #$00
                sta clubAnimPtr+1
                sta _keyframe+1

                jmp _3

; - - - - - - - - - - - - - - - - - - -
;   reset clubAnimPtr
_2              lda #<tblClubKeyframes  ; reset to table beginning
                sta clubAnimPtr
                sta _keyframe
                lda #>tblClubKeyframes
                sta clubAnimPtr+1
                sta _keyframe+1

; - - - - - - - - - - - - - - - - - - -
;   render club
_3              ldx #$00
                ldy #$00
_next2          lda (_keyframe),Y       ; screen memory DEST (by keyframe index)
                sta _screen
                iny
                lda (_keyframe),Y
                sta _screen+1

                php                     ; preserve flags
                iny
                plp                     ; restore flags
                beq _XIT                ; when end-marker is reached

                lda (_keyframe),Y       ; grab the screen byte value
                sta _mask

                tya                     ; preserve keyframe index
                pha

                ldy #$00                ; preserve existing screen patch
                lda (_screen),Y
                sta tblClubPatch,X

                inx
                and _mask               ; render club to screen
                sta (_screen),Y

                pla                     ; restore keyframe index
                tay
                iny                     ; +1 to keyframe index
                bne _next2              ; [unc]

; - - - - - - - - - - - - - - - - - - -
_XIT            rts
                .endproc


;======================================
; Preserve an area of the screen, that
; is overwritten by the club animation,
; to facilitate erasure of the keyframe
;--------------------------------------
; build table of byte values from the
; screen locations specified in table
; tblClubKeyframes
;====================================== ;[[U]]
PreserveScreenPatch .proc
_screen         = zpC3
;---

                ldx #$00
                ldy #$00
_next1          lda tblClubKeyframes,Y  ; set pointer
                sta _screen
                iny
                lda tblClubKeyframes,Y
                sta _screen+1

                php                     ; preserve flags
                iny
                plp                     ; restore flags
                beq _1                  ; <-- end marker when high-byte = $00

                tya                     ; preserve Y
                pha

;   capture screen memory
                ldy #$00
                lda (_screen),Y
                sta tblClubPatch,X
                inx

                pla                     ; restore Y
                tay
                iny                     ; skip 3rd-byte
                bne _next1              ; [unc]

; - - - - - - - - - - - - - - - - - - -
; reset to table beginning
_1              lda #<tblClubKeyframes
                sta clubAnimPtr
                lda #>tblClubKeyframes
                sta clubAnimPtr+1

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
