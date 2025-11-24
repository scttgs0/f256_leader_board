
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
                asl dwordMath+1         ; load CARRY

                bit dwordMath+3         ; are we decrementing?
                bmi _1                  ;   yes

; - - - - - - - - - - - - - - - - - - -
                lda dwordMath+2         ; increment
                adc #<$0000
                tax
                lda dwordMath+3
                adc #>$0000
                tay

                rts

; - - - - - - - - - - - - - - - - - - -
_1              lda dwordMath+2         ; decrement
                sbc #<$0000
                tax
                lda dwordMath+3
                sbc #>$0000
                tay

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
_next1          lda lineNode0_ClipFlags
                and lineNode1_ClipFlags
                beq _1

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
_1              lda lineNode1_ClipFlags ; any Node1 flags?
                bne _process            ;   yes

                lda lineNode0_ClipFlags ;   no, are the Node0 flags also off?
                beq _XIT1               ;       yes, no clipping required

;   lineNode1 is the only node that we clipped, so swap the nodes to allow for clipping
                jsr SwapLineNodes

; - - - - - - - - - - - - - - - - - - -
_process        lda #$01                ; newVertX isOffScreenRight flag
                sta lineNode1_isClipped ; TRUE
                and lineNode1_ClipFlags
                bne _xMax

                lda #$02                ; newVertX isOffScreenLeft flag
                and lineNode1_ClipFlags
                bne _xMin

                lda #$04                ; newVertZ isOffScreenTop flag
                and lineNode1_ClipFlags
                bne _zMin

; - - - - - - - - - - - - - - - - - - -
_zMax           lda #$C8-1              ; 199
                jsr ClipZCoordinate
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_zMin           lda #$00
                jsr ClipZCoordinate
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_xMax           lda #$F0-1              ; 239
                jsr ClipXCoordinate

                ldx #$01                ; xMax clipped
                stx lineNode1_VertX_flags

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_xMin           lda #$00
                jsr ClipXCoordinate

                ldx #$02                ; xMin clipped
                stx lineNode1_VertX_flags

                jmp _next1

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
                ldx lineNode0_VertX_LO  ; swap
                ldy lineNode1_VertX_LO
                stx lineNode1_VertX_LO
                sty lineNode0_VertX_LO

                ldx lineNode0_VertX_HI  ; swap
                ldy lineNode1_VertX_HI
                stx lineNode1_VertX_HI
                sty lineNode0_VertX_HI

                ldx lineNode0_VertZ_LO  ; swap
                ldy lineNode1_VertZ_LO
                stx lineNode1_VertZ_LO
                sty lineNode0_VertZ_LO

                ldx lineNode0_VertZ_HI  ; swap
                ldy lineNode1_VertZ_HI
                stx lineNode1_VertZ_HI
                sty lineNode0_VertZ_HI

                ldx lineNode0_ClipFlags ; swap
                ldy lineNode1_ClipFlags
                stx lineNode1_ClipFlags
                sty lineNode0_ClipFlags

                ldx lineNode0_VertX_flags  ; swap
                ldy lineNode1_VertX_flags
                stx lineNode1_VertX_flags
                sty lineNode0_VertX_flags

                ldx lineNode0_isClipped ; swap
                ldy lineNode1_isClipped
                stx lineNode1_isClipped
                sty lineNode0_isClipped

                ldx #TRUE
                stx isSwapped

                rts
                .endproc


;======================================
;
;--------------------------------------
;   A           [0|-65]
;======================================
ClipZCoordinate .proc
                pha

;   deltaX
                jsr CalcNodesDeltaX
                stx dwordMath
                sty dwordMath+1

                pla
                pha

                sec
                sbc lineNode0_VertZ_LO
                sta physicsY
                lda #$00
                sta lineNode1_ClipFlags
                sbc lineNode0_VertZ_HI
                sta physicsY+1

                jsr MultiplyWordByWord_ABS
                jsr Divide32bitByDeltaZ ; result in wordB+wordC[remainder]

                pla
                sta lineNode1_VertZ_LO
                ;lda #$00
                stz lineNode1_VertZ_HI

                lda wordB_3CBE
                clc
                adc lineNode0_VertX_LO
                sta lineNode1_VertX_LO
                lda wordB_3CBE+1
                adc lineNode0_VertX_HI
                sta lineNode1_VertX_HI
                bpl _1

                lda #$02                ; newVertX isOffScreenLeft flag
                sta lineNode1_ClipFlags

                rts

; - - - - - - - - - - - - - - - - - - -
_1              bne _2

                lda lineNode1_VertX_LO
                cmp #$F0                ; xMax (240)
                bcc _XIT

_2              lda #$01                ; newVertX isOffScreenRight flag
                sta lineNode1_ClipFlags

_XIT            rts
                .endproc


;======================================
;
;======================================
ClipXCoordinate .proc
                pha

;   zDelta
                jsr CalcNodesDeltaZ
                stx dwordMath
                sty dwordMath+1

                pla
                pha

                sec
                sbc lineNode0_VertX_LO
                sta physicsY
                lda #$00
                sta lineNode1_ClipFlags
                sbc lineNode0_VertX_HI
                sta physicsY+1

                jsr MultiplyWordByWord_ABS
                jsr Divide32bitByDeltaX ; result in wordB+wordC[remainder]

                pla
                sta lineNode1_VertX_LO
                ;lda #$00
                stz lineNode1_VertX_HI

                lda wordB_3CBE
                clc
                adc lineNode0_VertZ_LO
                sta lineNode1_VertZ_LO
                lda wordB_3CBE+1
                adc lineNode0_VertZ_HI
                sta lineNode1_VertZ_HI
                bpl _1

                lda #$04                ; newVertZ isOffScreenTop flag
                sta lineNode1_ClipFlags

                rts

; - - - - - - - - - - - - - - - - - - -
_1              bne _2

                lda lineNode1_VertZ_LO
                cmp #$C8                ; zMax (200)
                bcc _XIT

_2              lda #$08                ; newVertZ isOffScreenBottom flag
                sta lineNode1_ClipFlags

_XIT            rts
                .endproc


;======================================
;
;======================================
Divide32bitByDeltaX .proc
                ldx dwordMath
                ldy dwordMath+1
                stx wordB_3CBE
                sty wordB_3CBE+1
                ldx dwordMath+2
                ldy dwordMath+3
                stx wordC_3CC0
                sty wordC_3CC0+1

                jsr CalcNodesDeltaX     ; result in Y:X
                stx wordA_3CBC
                sty wordA_3CBC+1

                jmp DivideDWordCbySquareWordA

                .endproc


;======================================
;
;======================================
Divide32bitByDeltaZ .proc
                ldx dwordMath
                ldy dwordMath+1
                stx wordB_3CBE
                sty wordB_3CBE+1
                ldx dwordMath+2
                ldy dwordMath+3
                stx wordC_3CC0
                sty wordC_3CC0+1

                jsr CalcNodesDeltaZ     ; result in Y:X
                stx wordA_3CBC
                sty wordA_3CBC+1

                jmp DivideDWordCbySquareWordA

                .endproc


;======================================
; calculate $2B5F:word - $2B5D:word
;--------------------------------------
; on exit:
;   Y:X         delta
;======================================
CalcNodesDeltaZ .proc
                lda lineNode1_VertZ_LO
                sec
                sbc lineNode0_VertZ_LO
                tax

                lda lineNode1_VertZ_HI
                sbc lineNode0_VertZ_HI
                tay

                rts
                .endproc


;======================================
; calculate $2B5E:word - $2B5C:word
;--------------------------------------
; on exit:
;   Y:X         delta
;======================================
CalcNodesDeltaX .proc
                lda lineNode1_VertX_LO
                sec
                sbc lineNode0_VertX_LO
                tax

                lda lineNode1_VertX_HI
                sbc lineNode0_VertX_HI
                tay

                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
;
;--------------------------------------
ProjectAimPosition .proc
                lda aimPosition
                sta polyVertX_LO_2
                lda aimPosition_HI
                sta polyVertX_HI_2

                lda #<$0018             ; surface (24 inches)
                sta polyVertZ_LO_2
                lda #>$0018
                sta polyVertZ_HI_2

                lda const_0x700
                sta polyVertY_LO_2
                lda const_0x700+1
                sta polyVertY_HI_2

                .endproc

                ;[fall-through]


;--------------------------------------
;
;--------------------------------------
; calculate:
;   wordC:wordD = vertZ * $0298
;   = wordD / vertY
;--------------------------------------
Project3DVertex .proc
;   wordC:wordB = (zCoord-zCenterline)*664
                lda polyVertZ_LO_2
                sec
                sbc #<$0150             ; 336 (zCoord centerline)
                sta dwordMath
                lda polyVertZ_HI_2
                sbc #>$0150
                sta dwordMath+1

                lda #<$0298             ; *664
                sta physicsY
                lda #>$0298
                sta physicsY+1

                jsr MultiplyWordByWord_ABS  ; result in dwordMath

                lda dwordMath           ; save result
                sta wordB_3CBE
                lda dwordMath+1
                sta wordB_3CBE+1
                lda dwordMath+2
                sta wordC_3CC0
                lda dwordMath+3
                sta wordC_3CC0+1

; - - - - - - - - - - - - - - - - - - -
;   wordB = wordC:wordB/yCoord^2... remainder wordC (ignored)
                lda polyVertY_LO_2
                sta wordA_3CBC
                lda polyVertY_HI_2
                sta wordA_3CBC+1

                jsr DivideDWordCbySquareWordA   ; result in wordB+wordC[remainder]

; - - - - - - - - - - - - - - - - - - -
                ;lda #$00
                stz newClip_flags       ; clear clipping flags

; - - - - - - - - - - - - - - - - - - -
;   newVertZ = 20 - wordB
                lda #<$0014
                sec
                sbc wordB_3CBE
                sta newVertZ_LO
                lda #>$0014
                sbc wordB_3CBE+1
                sta newVertZ_HI
                bpl _1

                lda #$04                ; set bit-2 (newVertZ isOffScreenTop)
                ora newClip_flags
                sta newClip_flags

                jmp _3

; - - - - - - - - - - - - - - - - - - -
_1              bne _2

                lda newVertZ_LO
                cmp #$C8                ; off-screen?
                bcs _2                  ;   yes
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_2              lda #$08                ; set bit-3 (newVertZ isOffScreenBottom)
                ora newClip_flags
                sta newClip_flags

; - - - - - - - - - - - - - - - - - - -
;   wordC:wordB = (xCoord-xCenterline)*857
_3              lda polyVertX_LO_2
                sta dwordMath
                lda polyVertX_HI_2
                sec
                sbc #>$1800             ; course centerline (512 feet)
                sta dwordMath+1

                lda #<$0359             ; *857
                sta physicsY
                lda #>$0359
                sta physicsY+1

                jsr MultiplyWordByWord_ABS  ; result in dwordMath

                lda dwordMath           ; save result
                sta wordB_3CBE
                lda dwordMath+1
                sta wordB_3CBE+1
                lda dwordMath+2
                sta wordC_3CC0
                lda dwordMath+3
                sta wordC_3CC0+1

; - - - - - - - - - - - - - - - - - - -
;   wordB = wordC:wordB/yCoord^2... remainder wordC (ignored)
                lda polyVertY_LO_2
                sta wordA_3CBC
                lda polyVertY_HI_2
                sta wordA_3CBC+1

                jsr DivideDWordCbySquareWordA   ; result in wordB+wordC[remainder]

; - - - - - - - - - - - - - - - - - - -
;   newVertX = 120 + wordB
                lda #<$0078             ; 120, half of the screen width [240]
                clc
                adc wordB_3CBE
                sta newVertX_LO
                lda #>$0078
                adc wordB_3CBE+1
                sta newVertX_HI
                bpl _4

                lda #$02                ; set bit-1 (newVertX isOffScreenLeft)
                ora newClip_flags
                sta newClip_flags

                jmp _6

; - - - - - - - - - - - - - - - - - - -
_4              bne _5

                lda newVertX_LO
                cmp #$F0                ; off-screen?
                bcs _5                  ;   yes
                jmp _6

; - - - - - - - - - - - - - - - - - - -
_5              lda newClip_flags
                ora #$01                ; set bit-0 (newVertX isOffScreenRight)
                sta newClip_flags

; - - - - - - - - - - - - - - - - - - -
_6              ldx newVertX_LO
                ldy newVertZ_LO
                lda newClip_flags

                rts
                .endproc


;======================================
;
;--------------------------------------
;
;======================================
MultipleWordByPhysicsY .proc
                stz dwordMath+2
                stz dwordMath+3

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
MultiplyWordByWord_ABS .proc
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
                lda #<$0000
                sbc physicsY
                sta physicsY
                lda #>$0000
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
                ;lda #$00
                stz wordC_3CC0
                stz wordC_3CC0+1

; - - - - - - - - - - - - - - - - - - -
_ENTRY1         lda wordA_3CBC
                ora wordA_3CBC+1        ; wordA=0?
                bne _1                  ;   no

                sec                     ;   yes
                rts

; - - - - - - - - - - - - - - - - - - -
_1              ldx #$10
_next1          rol wordB_3CBE          ; 32-bit ROL
                rol wordB_3CBE+1
                rol wordC_3CC0
                rol wordC_3CC0+1

                sec
                lda wordC_3CC0
                sbc wordA_3CBC
                tay
                lda wordC_3CC0+1
                sbc wordA_3CBC+1
                bcc _2

                sty wordC_3CC0
                sta wordC_3CC0+1

_2              dex
                bne _next1

                rol wordB_3CBE          ; 16-bit ROL
                rol wordB_3CBE+1

                clc
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
                lda wordB_3CBE+1
                eor wordA_3CBC+1
                sta wordD_3CC2

                lda wordB_3CBE+1
                sta wordD_3CC2+1

                lda wordA_3CBC+1
                bpl _1

;   negative, make positive
                lda #<$0000
                sec
                sbc wordA_3CBC
                sta wordA_3CBC
                lda #>$0000
                sbc wordA_3CBC+1
                sta wordA_3CBC+1

_1              lda wordB_3CBE+1
                bpl _2

;   negative, make positive
                lda #<$0000
                sbc wordB_3CBE
                sta wordB_3CBE
                lda #>$0000
                sbc wordB_3CBE+1
                sta wordB_3CBE+1

_2              jsr DivideWordBbyWordA  ; result in wordB+wordC[remainder]
_ENTRY1         bcs _4

                lda wordD_3CC2
                bpl _3

;   negative
                lda #<$0000
                sec
                sbc wordB_3CBE
                sta wordB_3CBE
                lda #>$0000
                sbc wordB_3CBE+1
                sta wordB_3CBE+1

_3              lda wordD_3CC2+1
                bpl _XIT

;   negative
                lda #<$0000
                sec
                sbc wordC_3CC0
                sta wordC_3CC0
                lda #>$0000
                sbc wordC_3CC0+1
                sta wordC_3CC0+1

                jmp _XIT

; - - - - - - - - - - - - - - - - - - -
_4              ;lda #$00
                stz wordB_3CBE
                stz wordB_3CBE+1
                stz wordC_3CC0
                stz wordC_3CC0+1

                sec
                rts

; - - - - - - - - - - - - - - - - - - -
_XIT            clc
                rts
                .endproc


;======================================
;
;--------------------------------------
;
;======================================
DivideDWordCbySquareWordA .proc
                lda wordC_3CC0+1
                eor wordA_3CBC+1
                sta wordD_3CC2

                lda wordC_3CC0+1
                sta wordD_3CC2+1

                lda wordA_3CBC+1
                bpl _1

;   negative value... convert to positive
                lda #<$0000
                sec
                sbc wordA_3CBC
                sta wordA_3CBC
                lda #>$0000
                sbc wordA_3CBC+1
                sta wordA_3CBC+1

_1              lda wordC_3CC0+1
                bpl _2

;   negative value... convert to positive
                lda #<$0000
                sec
                sbc wordB_3CBE
                sta wordB_3CBE
                lda #>$0000
                sbc wordB_3CBE+1
                sta wordB_3CBE+1

                lda #<$0000
                sbc wordC_3CC0
                sta wordC_3CC0
                lda #>$0000
                sbc wordC_3CC0+1
                sta wordC_3CC0+1

;   calculate wordB / wordA^2
_2              jsr DivideWordBbyWordA._ENTRY1      ; result in wordB+wordC[remainder]
                jmp DivideWordBbyWordA_ABS._ENTRY1  ; result in wordB+wordC[remainder]

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

                jsr MultiplyWordByWord_ABS

                pla                     ; restore
                tay

                lda dwordMath+1         ; result
                ldx dwordMath

                rts
                .endproc
