
;======================================
;
;--------------------------------------
; on entry:
;   Y:X         word value
;======================================
CalcPolyVertXY_delta .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on exit:
;   Y:X         result
;======================================
GetWordResult   .proc
                rts
                .endproc


;======================================
;
;======================================
InitPutt_2521   .proc
                rts
                .endproc


;======================================
;
;======================================
Divide_2040byWordA .proc
                rts
                .endproc


;======================================
;
;======================================
CalcTravelDistanceFeet .proc
                rts
                .endproc


;======================================
;
;======================================
ProcessClipFlags .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

newClip_flags           .byte $00
;   bit0    newVertX isOffScreenRight flag
;   bit1    newVertX isOffScreenLeft flag
;   bit2    newVertZ isOffScreenTop flag
;   bit3    newVertZ isOffScreenBottom flag

lineNode0_ClipFlags     .byte $00
lineNode1_ClipFlags     .byte $00

newVertX_HI             .byte $00
newVertZ_HI             .byte $00

lineNode0_VertX_HI      .byte $00
lineNode0_VertZ_HI      .byte $00

lineNode1_VertX_HI      .byte $00
lineNode1_VertZ_HI      .byte $00


;======================================
;
;======================================
SwapLineNodes   .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
;   A           [0|-65]
;======================================
ClipZCoordinate .proc
                rts
                .endproc


;======================================
;
;======================================
ClipXCoordinate .proc
                rts
                .endproc


;======================================
;
;======================================
Divide32bitByDeltaX .proc
                rts
                .endproc


;======================================
;
;======================================
Divide32bitByDeltaZ .proc
                rts
                .endproc


;======================================
; calculate $2B5F:word - $2B5D:word
;--------------------------------------
; on exit:
;   Y:X         delta
;======================================
CalcNodesDeltaZ .proc
                rts
                .endproc


;======================================
; calculate $2B5E:word - $2B5C:word
;--------------------------------------
; on exit:
;   Y:X         delta
;======================================
CalcNodesDeltaX .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
;
;--------------------------------------
MultiplyDivide_D_AimPosition .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
; calculate:
;   wordC:wordD = vertZ * $0298
;   = wordD / vertY
;--------------------------------------
Project3DVertex .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
;
;======================================
MultipleWordByPhysicsY .proc
                lda #$00
                sta dwordMath+2
                sta dwordMath+3

                ldy #$10
_next1          lda dwordMath
                lsr
                bcc _1

                clc
                lda dwordMath+2
                adc physicsY
                sta dwordMath+2
                lda dwordMath+3
                adc physicsY+1
                sta dwordMath+3

_1              ror dwordMath+3
                ror dwordMath+2
                ror dwordMath+1
                ror dwordMath

                dey
                bne _next1

                rts
                .endproc


;--------------------------------------
;--------------------------------------

dwordMath               .dword $0000
physicsY                .word $0000
isResultNegative        .byte $00


;======================================
;
;--------------------------------------
; on entry:
;   dwordMath   word value 1
;   physicsY    word value 2
; on exit:
;   dwordMath   dword result
;======================================
MultiplyWordByWord .proc
                lda physicsY+1
                eor dwordMath+1
                sta isResultNegative

                lda dwordMath+1
                bpl _1

;   negative value... convert to positive
                sec
                lda #<$0000
                sbc dwordMath
                sta dwordMath
                lda #>$0000
                sbc dwordMath+1
                sta dwordMath+1

_1              lda physicsY+1
                bpl _2

;   negative value... convert to positive
                sec
                lda #$00
                sbc physicsY
                sta physicsY
                lda #$00
                sbc physicsY+1
                sta physicsY+1

_2              jsr MultipleWordByPhysicsY

                lda isResultNegative
                bpl _XIT

                sec
                lda #<$0000
                sbc dwordMath
                sta dwordMath
                lda #>$0000
                sbc dwordMath+1
                sta dwordMath+1

                lda #<$0000
                sbc dwordMath+2
                sta dwordMath+2
                lda #>$0000
                sbc dwordMath+3
                sta dwordMath+3

_XIT            rts
                .endproc


;======================================
; divide wordB by wordA
;--------------------------------------
; on entry:
;   wordA       divisor
;   wordB       16-bit value
; on exit:
;   wordB       whole value
;   wordC       remainder
;--------------------------------------
; examples:
; wordA     $0024       ,$003C
; wordB     $3148->$015E,$090F->$0026
; wordC            $0010,       $0027
;======================================
DivideWordBbyWordA .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

wordA_3CBC      .word $0000
wordB_3CBE      .word $0000
wordC_3CC0      .word $0000
wordD_3CC2      .word $0000


;======================================
; divide ABS(wordB) by ABS(wordA)
;--------------------------------------
; on entry:
;   wordA       divisor
;   wordB       16-bit value
; on exit:
;   wordB       whole value
;   wordC       remainder
;--------------------------------------
; examples:
;   wordA   $03E8->$02A0,$003C->$003C
;   wordB   $0000->$00A2,$02DA->$000C
;   wordC   $0007->$E220,$0000->$000A
;   wordD        ->$20ED,$0005->$0202
;======================================
DivideWordBbyWordA_ABS .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
;
;======================================
DivideDWordCbySquareWordA .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; preserved:    X,Y
; on entry:
;   A           power based on club
; on exit:
;   A           result_HI (dwordMath+1)
;   dwordMath   result_LO
;======================================
MultiplyByteBy42 .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           multiplier
;   Y:X         value
; on exit:
;   Y:X:A       result:long
;======================================
MultiplyWordByByte .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
;
;======================================
CalcProjectile  .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
;
;======================================
Multiply_DividebySquare .proc
                rts
                .endproc


;======================================
;
;======================================
MultipleBy6     .proc
                stx dwordMath           ; idxActiveHole
                sty physicsY            ; always 6

                stz dwordMath+1         ; hi-byte unused
                stz physicsY+1

                jsr MultipleWordByPhysicsY

                lda dwordMath           ; word result
                ldx dwordMath+1

                rts
                .endproc


;======================================
;
;======================================
ConvertToInches .proc
                stx dwordMath           ; polygon origin X_LO
                sta dwordMath+1         ; polygon origin X_HI

                tya                     ; preserve
                pha

                lda #<$000C
                sta physicsY
                lda #>$000C
                sta physicsY+1

                jsr MultiplyWordByWord

                pla                     ; restore
                tay

                lda dwordMath+1         ; result
                ldx dwordMath

                rts
                .endproc
