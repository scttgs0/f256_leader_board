
;======================================
;
;====================================== ;[[V]]
PopulateClipQueue .proc
                ldy idxPolygon
                lda bufPolyVertCount,Y
                sta polyVertCount

                ldy #$00
                sty idxWork

; - - - - - - - - - - - - - - - - - - -
;   vertex 0
                jsr FetchFromPolygonBuf
                sty idxPolygonVertex    ; polygon vertex index

                ldx #xformNORMAL
                jsr VertexTransform

;   last node becomes the first node
                sta lineNode0_ClipFlags
_next1          stx lineNode0_VertX_LO
                sty lineNode0_VertZ_LO

                lda newVertX_HI
                sta lineNode0_VertX_HI
                lda newVertZ_HI
                sta lineNode0_VertZ_HI

; - - - - - - - - - - - - - - - - - - -
;   vertex 1
;   last node joins with the first node
                ldy idxPolygonVertex
                iny
                cpy polyVertCount
                bcc _1

                ldy #$00
_1              jsr FetchFromPolygonBuf
                sty idxPolygonVertex    ; polygon vertex index

                ldx #xformNORMAL
                jsr VertexTransform
                sta lineNode1_ClipFlags
                stx lineNode1_VertX_LO
                sty lineNode1_VertZ_LO

                lda newVertX_HI
                sta lineNode1_VertX_HI
                lda newVertZ_HI
                sta lineNode1_VertZ_HI

; - - - - - - - - - - - - - - - - - - -
                stz lineNode1_isClipped ; FALSE
                stz lineNode0_isClipped ; FALSE
                stz lineNode1_VertX_flags
                stz lineNode0_VertX_flags
                stz isSwapped           ; FALSE

                jsr ProcessClipFlags
                php                     ; preserve flags

                lda isSwapped           ; requires swap?
                beq _2                  ;   no

                jsr SwapLineNodes       ; swap the two line nodes back to their original positions

_2              plp                     ; restore flags
                beq _4
                jmp _5

; - - - - - - - - - - - - - - - - - - -
_4              jsr QueueClipNode0      ; lineNode0 is clipped, add it to the queue

                inc idxWork

                lda lineNode1_isClipped ; lineNode1 clipped?
                beq _5                  ;   no

                jsr QueueClipNode1      ; lineNode1 is clipped, add it to the queue

                inc idxWork

; - - - - - - - - - - - - - - - - - - -
_5              ldy idxPolygonVertex
                beq _XIT

;   last node becomes the first node
                lda newClip_flags
                sta lineNode0_ClipFlags

                ldx newVertX_LO
                ldy newVertZ_LO

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_XIT            rts
                .endproc


;======================================
;
;====================================== ;[[V]]
QueueClipNode0  .proc
                ldy idxWork
                lda lineNode0_VertX_LO
                sta bufCourseWorkVertX,Y

                lda lineNode0_VertZ_LO
                sta bufCourseWorkVertZ,Y

                lda lineNode0_VertX_flags
                sta bufCourseWorkFlags,Y

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
QueueClipNode1  .proc
                ldy idxWork
                lda lineNode1_VertX_LO
                sta bufCourseWorkVertX,Y

                lda lineNode1_VertZ_LO
                sta bufCourseWorkVertZ,Y

                lda lineNode1_VertX_flags
                sta bufCourseWorkFlags,Y

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   Y           work queue index
; on exit:
;   A           vertZ
;   X           vertX
;====================================== ;[[V]]
FetchFromClipQueue .proc
                lda bufCourseWorkVertX,Y
                tax

                lda bufCourseWorkVertZ,Y
                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
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
;--------------------------------------
;   A           [0|-65]
;====================================== ;[[V]]
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
;====================================== ;[[V]]
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
;====================================== ;[[V]]
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
; calculate $2B5E:word - $2B5C:word
;--------------------------------------
; on exit:
;   Y:X         delta
;====================================== ;[[V]]
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


;======================================
; calculate $2B5F:word - $2B5D:word
;--------------------------------------
; on exit:
;   Y:X         delta
;====================================== ;[[V]]
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
;
;====================================== ;[[V]]
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
;--------------------------------------
; 1st pass: compare all xVert for xMax
;   if xMaxClipped, record highest zVert
;--------------------------------------
; 2nd pass: compare all xVert for xMin
;   if xMinClipped, record highest zVert
;--------------------------------------
; if nMatches is odd, insert a new vertex
;====================================== ;[[V]]
PreprocessVoids .proc
                lda #$01
                sta _clipFlag           ; expecting isMaxClip
                sta _deltaMatchPair

                lda #$F0-1              ; xMax (239)
                sta _vertX

; - - - - - - - - - - - - - - - - - - -
;   look for matching pairs at the extremes (xMax/xMin)
_nextPass       lda #$00
                sta _nMatches

                ldy #$00
                sty _vertZ              ; zMin (0)

_next2          lda bufCourseWorkVertX,Y
                cmp _vertX              ; limit match?
                bne _1                  ;   no

                lda bufCourseWorkFlags,Y
                and _clipFlag           ; isMaxClip/isMinClip?
                beq _1                  ;   no

                inc _nMatches

                lda bufCourseWorkVertZ,Y
                cmp _vertZ              ; higher value?
                bcc _1                  ;   no

                sta _vertZ              ; found higher value

                tya
                clc
                adc _deltaMatchPair
                sta _idxMatchPair

; - - - - - - - - - - - - - - - - - - -
_1              iny
                cpy idxWork             ; end of buffer reached?
                bcc _next2              ;   no

;   expecting an even number of matches
                lda _nMatches
                lsr                     ; even matches?
                bcc _3                  ;   yes

                ldy idxWork
                cpy _idxMatchPair       ; are we at the end?
                beq _insertVertex       ;   yes, no need to insert space

; - - - - - - - - - - - - - - - - - - -
;   make space for the new vertex
_makeSpace      dey
                lda bufCourseWorkVertX,Y
                pha
                lda bufCourseWorkVertZ,Y
                pha
                lda bufCourseWorkFlags,Y

                iny
                sta bufCourseWorkFlags,Y
                pla
                sta bufCourseWorkVertZ,Y
                pla
                sta bufCourseWorkVertX,Y

                dey
                cpy _idxMatchPair
                bne _makeSpace

; - - - - - - - - - - - - - - - - - - -
;   insert new vertex
_insertVertex   lda #$00                ; not clipped (force skip Z)
                sta bufCourseWorkFlags,Y

                lda #$C8-1              ; zMax (199) bottom corner
                sta bufCourseWorkVertZ,Y

                lda _vertX              ; xMin/xMax
                sta bufCourseWorkVertX,Y

                inc idxWork             ; one more vertex in the buffer

; - - - - - - - - - - - - - - - - - - -
_3              lda _vertX              ; already processed xMin?
                beq _XIT                ;   yes

                lda #$00
                sta _vertX              ; xMin (0)
                sta _deltaMatchPair     ; 0=current item is larger

                lda #$02
                sta _clipFlag           ; expecting isMinClip

                jmp _nextPass

; - - - - - - - - - - - - - - - - - - -
_XIT            rts

;--------------------------------------

_clipFlag       .byte $00               ; 1=isMaxClip, 2=isMinClip
_deltaMatchPair .byte $00

_vertZ          .byte $00
_vertX          .byte $00

_idxMatchPair   .byte $00               ; 1=next item is larger, 0=current item is larger
_nMatches       .byte $00               ; expecting this to be an even number

                .endproc


;======================================
;
;====================================== ;[[V]]
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
