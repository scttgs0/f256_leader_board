
;======================================
;
;--------------------------------------
; on entry:
;   idxPolygon
;====================================== ;[[V]]
RenderPolygon   .proc
_ptrPolyVertY_HI    = zpFE
;---

                lda idxPolygon
                jsr SetCoursePtrs

                lda #$02                ; default separation distance of the mud layers
                sta _separation

;   check for closeness of the polygon (>106 feet)
                ldy #$00
                lda (_ptrPolyVertY_HI),Y
                sec
                sbc #>$0500             ; yOrigin (inches)
                bcc _1

;   polygon is far, so we don't need as many mud layers. recalculate a new separation distance
                lsr                     ; /4
                lsr
                clc
                adc #$02
                sta _separation

;   start with the base layer (height=0)
_1              stz polyVertZ_LO
                stz polyVertZ_HI

                lda #COLOR_RUST         ; MUD
                sta pixelColor

_nextMudLayer   lda polygonOperation    ; FILL mode?
                bne _2                  ;   yes

; - - - - - - - - - - - - - - - - - - -
;   OUTLINE-only code
                jsr RenderMudLayer

; - - - - - - - - - - - - - - - - - - -
;   next layer is a bit higher in elevation
_2              lda polyVertZ_LO
                clc
                adc _separation
                sta polyVertZ_LO

;   repeat until we reach the desired height
                cmp #$16                ; <22?
                bcc _nextMudLayer       ;   yes

                lda polygonOperation    ; OUTLINE mode?
                beq _XIT                ;   yes, we're done

; - - - - - - - - - - - - - - - - - - -
;   FILL-only code
;   process the top layer (sod)
                lda #$18                ; surface layer (24 inches)
                sta polyVertZ_LO

                jsr PopulateClipQueue

                lda idxWork             ; work to perform?
                beq _XIT                ;   no

                jsr PreprocessVoids
                jsr CalcVertX_flags

                jsr RenderPolyTopEdge._BLACK    ; black outline at top edge
                jsr RenderPolyFill              ; fill with sod (GREEN)

                lda #COLOR_GREEN
                sta pixelColor

                jsr RenderPolyTopEdge._COLOR    ; eliminate the black outline

_XIT            rts

;--------------------------------------

_separation     .byte $00

                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   idxPolygon
;====================================== ;[[V]]
RenderMudLayer  .proc
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
                ldy idxPolygonVertex    ; 0-based
                iny                     ; 1-based
                cpy polyVertCount       ; last vertex?
                bcc _1                  ;   no

                ldy #$00                ; join back with the first node
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
                jsr ProcessLinePIXEL    ; render the nodes with PIXEL operation

                ldy idxPolygonVertex
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
ProcessLinePIXEL .proc
                lda #operPIXEL
                sta nodeOperation

                jsr ProcessClipFlags
                beq ProcessLine

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
ProcessLineFILL .proc
                lda #operFILL
                sta nodeOperation

                jmp ProcessLine

                .endproc


;======================================
; Bresenham's Line Algorithm
;--------------------------------------
; on entry:
;   lineNode0_VertX_LO
;   lineNode0_VertZ_LO
;   lineNode1_VertX_LO
;   lineNode1_VertZ_LO
; on exit:
;   accumDistance
;====================================== ;[[V]]
ProcessLine     .proc
; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
; entry point for the wind streamer
_ENTRY_WIND     ldy #$01                ; Y=1 (down/right)
                sty pl_DeltaX_increment
                sty pl_DeltaZ_conditional

                dey                     ; Y=0
                sty pl_DeltaX_conditional
                sty pl_DeltaZ_increment
                sty accum_HI

                dey                     ; Y=-1 (up/left)

;   is xNode1 >= xNode0? (down/right)
                ldx #$01                ; VertZ first, then check VertX
_nextAxis       lda lineNode1_VertX_LO,X
                cmp lineNode0_VertX_LO,X
                bcs _1

; - - - - - - - - - - - - - - - - - - -
;   xNode1 is smaller than xNode0 (up/left)
                sec
                lda lineNode0_VertX_LO,X
                sbc lineNode1_VertX_LO,X
                sta pl_DistanceX,X
                pha

                tya
                sta pl_DeltaX_increment,X   ; increment direction (-1=up/left)
                tay

                pla
                jmp _2

; - - - - - - - - - - - - - - - - - - -
;   xNode1 is larger than xNode0 (down/right)
_1              sbc lineNode0_VertX_LO,X
                sta pl_DistanceX,X

; - - - - - - - - - - - - - - - - - - -
_2              dex
                beq _nextAxis           ; next, check VertX

; - - - - - - - - - - - - - - - - - - -
;   is DistanceX >= DistanceZ?
                cmp pl_DistanceZ
                bcs _3

;   DistanceZ is larger, so transpose the line (swap X and Z)
                ldx pl_DistanceX
                lda pl_DistanceZ
                sta pl_DistanceX
                stx pl_DistanceZ
                iny                     ; Y=0

                lda pl_DeltaX_increment
                sta pl_DeltaX_conditional
                lda pl_DeltaZ_conditional
                sta pl_DeltaZ_increment

                sty pl_DeltaX_increment ; =0
                sty pl_DeltaZ_conditional

; - - - - - - - - - - - - - - - - - - -
_3              ldy #$01                ; Y=1 (down/right)

                lda pl_DistanceX
                lsr
                sta accum_LO            ; initialized to DistanceX/2
                bpl _5

; - - - - - - - - - - - - - - - - - - -
_nextPixel      clc
                lda lineNode0_VertX_LO
                adc pl_DeltaX_increment
                sta lineNode0_VertX_LO

                clc
                lda lineNode0_VertZ_LO
                adc pl_DeltaZ_increment
                sta lineNode0_VertZ_LO

                clc
                lda accum_LO
                adc pl_DistanceZ
                sta accum_LO
                lda accum_HI
                adc #$00
                sta accum_HI

                iny                     ; Y (accumulated distance)=2+

                lda accum_HI            ; threshold crossed?
                bne _4                  ;   yes

                lda accum_LO
                cmp pl_DistanceX        ; accum <= DistanceX?
                bcc _5                  ;   yes
                beq _5                  ;   yes

; - - - - - - - - - - - - - - - - - - -
;   conditional met, apply the conditional delta
_4              sec                     ; reset accum
                lda accum_LO
                sbc pl_DistanceX
                sta accum_LO
                lda accum_HI
                sbc #$00
                sta accum_HI

                clc
                lda lineNode0_VertX_LO
                adc pl_DeltaX_conditional
                sta lineNode0_VertX_LO

                clc
                lda lineNode0_VertZ_LO
                adc pl_DeltaZ_conditional
                sta lineNode0_VertZ_LO

; - - - - - - - - - - - - - - - - - - -
_5              tya
                pha                     ; preserve Y (accumulated distance)

                ldx lineNode0_VertX_LO
_setMaxX        cpx #$F0                ; [smc] xMax (240)
                bcs _6                  ; too big

                ldy lineNode0_VertZ_LO
                cpy #$C8                ; zMax (200)
                bcs _6                  ; too big

                sta accumDistance

                jsr RenderNodes

_6              pla                     ; restore Y (accumulated distance)
                tay
                cpy pl_DistanceX        ; accumDistance <= DistanceX?
                bcc _7                  ;   yes
                beq _7                  ;   yes

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                rts                     ; done

; - - - - - - - - - - - - - - - - - - -
_7              jmp _nextPixel

                .endproc


;--------------------------------------
;--------------------------------------

pl_DeltaX_conditional   .byte $00
pl_DeltaZ_increment     .byte $00

pl_DeltaX_increment     .byte $00
pl_DeltaZ_conditional   .byte $00

accum_HI                .byte $00
accum_LO                .byte $00

lineNode0_VertX_LO      .byte $00
lineNode0_VertZ_LO      .byte $00

lineNode1_VertX_LO      .byte $00
lineNode1_VertZ_LO      .byte $00

pl_DistanceX            .byte $00
pl_DistanceZ            .byte $00

pixelColor              .byte COLOR_BLACK


;======================================
; Render course polygons
;   _OUTLINE    draw mud banks
;   _FILL       draw turf
;====================================== ;[[V]]
RenderCourse    .proc
_OUTLINE        lda holeInfoPolyCount
                sta idxPolygon          ; render back-to-front, start with the far polygon

                stz polygonOperation    ; OUTLINE

; - - - - - - - - - - - - - - - - - - -
_FILL
_next1          dec idxPolygon          ; end reached?
                bmi _XIT                ;   yes

                jsr RenderPolygon

                lda idxPolygon
                cmp offscreenPlane      ; off-screen reached (unused)?
                bcs _next1              ;   no

_XIT            rts
                .endproc


;======================================
; Render polygon fill
;====================================== ;[[V]]
RenderFill      .proc
                lda holeInfoPolyCount
                sta idxPolygon

                lda #$01                ; FILL
                sta polygonOperation

                jmp RenderCourse._FILL

                .endproc


;--------------------------------------
;
;--------------------------------------
; on entry:
;   X           xPos
;   Y           yPos
;   pixelColor
;-------------------------------------- ;[[V]]
RenderPixel     .proc
                jsr GetPixelPtr

                lda pixelColor
_setAddrPixelByte1
                sta $FFFF               ; [smc]

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           new xPos
;   Y           new yPos
; on exit:
;   A           maskedPixelValue
;====================================== ;[[U]]
ShiftPixelMask  .proc
_addrPixel      = zpFD
;---

                ;!!jsr GetPixelPtrMask     ; set zpFD (pixel address) and pixelMask

                lda (_addrPixel),Y      ; fetch the pixel value
                and pixelMask           ; apply the mask
_next1          sta maskedPixelValue    ; save

                lsr pixelMask           ; stop when a mask-bit hits the CARRY (i.e. too far)
                bcs DoRTS2

                lsr pixelMask           ; shift the mask
                lsr                     ; shift the pixel value (x2)
                lsr

                jmp _next1

                .endproc


;--------------------------------------
;
;--------------------------------------
DoRTS2          rts


;======================================
;
;======================================
CalcBallPixelMask .proc
                lda lineNode1_ClipFlags
                beq _1

_XIT1           rts

; - - - - - - - - - - - - - - - - - - -
_1              lda nodeOperation       ; operPIXEL?
                bne _4                  ;   no

                ldx #$07                ; missile-1 (shadow)
                jsr CalcMissilePosition ; result [X,Y]
                sty yPosNewBallShadow
                jsr ShiftPixelMask      ; result in A=maskedPixelValue

                cmp #$03                ; missile-0 white?
                beq _XIT1               ;   yes, exit

                pha
                jsr CalcPixelMask

                pla
                bit flagsBall_9D83
                bpl _2

                cmp #$00
                beq _XIT1
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_2              ldx #$07                ; missile-1 (shadow)
                jsr CalcMissilePosition ; result [X,Y]
                stx zpD4
                sty zpD4+1

                stz zpCD

_next1          ldx zpD4                ; x-coordinate
                ldy zpD4+1              ; y-coordinate
                jsr ShiftPixelMask      ; result in A=maskedPixelValue

                cmp #$03                ; missile-0 white?
                beq _XIT1               ;   yes, exit

                inc zpD4

                inc zpCD
                lda zpCD
                cmp #$0F
                bcc _next1

                ;!!ora PACTL

_3              lda #operFILL
                sta nodeOperation

                stz polyVertZ_delta

                ldx #xformDELTA_Z
                jsr VertexTransform

                tya
                sec
                sbc yPosNewBallShadow
                sta yPosNewBallShadow

                lda #$40                ; ball(bit-6) is visible
                sta flagsBall_9D81

                jmp _XIT1

; - - - - - - - - - - - - - - - - - - -
_4              cmp #$01
                bne _5
                jmp AdjustBallPixelMask

_5              ldx #$07                        ; missile-1 (shadow)
                jsr CalcMissilePositionAndMask  ; result in A=maskedPixelValue, [X,Y]

                cmp #$03                ; missile-0 white?
                beq _ENTRY1             ;   yes

                cmp #$02                ; missile-0 green?
                bne _XIT1               ;   no

; - - - - - - - - - - - - - - - - - - -
_ENTRY1         lda flagsBall_9D83
                cmp #$C0                ; ball(bit-6) and shadow(bit-7) are visible?
                bne _XIT

                lda #operPIXEL
                sta nodeOperation

                lda #$18
                sta polyVertZ_delta

                lda #$C0                ; ball(bit-6) and shadow(bit-7) are visible
                sta flagsBall_9D81

                lda polyVertZ_LO
                sec
                sbc polyVertZ_delta
                lda polyVertZ_HI
                sbc #$00
                bcs _XIT

                lda #$01
                sta flags_9D76

                stz swingAnimCounter
                stz isSwingAnimCounterActive

                lda #$40                ; ball(bit-6) is visible
                sta flagsBall_9D81

_XIT            rts
                .endproc


;======================================
; Render black outline on top layer of
; polygon (a prerequisite for fill)
;====================================== ;[[V]]
RenderPolyTopEdge .proc
_BLACK          lda #COLOR_BLACK
                sta pixelColor

; - - - - - - - - - - - - - - - - - - -
_COLOR          ldy #operPIXEL
                sty nodeOperation

                jsr FetchFromClipQueue  ; result A:vertZ, X:vertX
                stx lineNode0_VertX_LO
                sta lineNode0_VertZ_LO

_next1          iny
                cpy idxWork             ; last node?
                bcc _1                  ;   no

                ldy #$00                ; join with the first node
_1              jsr FetchFromClipQueue  ; result A:vertZ, X:vertX
                stx lineNode1_VertX_LO
                sta lineNode1_VertZ_LO

                sty idxPolygonVertex
                jsr ProcessLine

                ldy idxPolygonVertex
                bne _next1

                rts
                .endproc


;======================================
;
;====================================== ;[[V]]
RenderPolyFill  .proc
                ldy #$00
                lda #COLOR_GREEN
                sta pixelColor

                jsr FetchFromClipQueue  ; result A:vertZ, X:vertX
                stx lineNode0_VertX_LO
                sta lineNode0_VertZ_LO

_next1          iny
                cpy idxWork             ; last node?
                bcc _1                  ;   no

                ldy #$00                ; join with the first node
_1              jsr FetchFromClipQueue  ; result A:vertZ, X:vertX
                stx lineNode1_VertX_LO
                sta lineNode1_VertZ_LO

                sty idxPolygonVertex
                jsr ProcessLineFILL     ; render the nodes with FILL operation

                ldy idxPolygonVertex
                bne _next1

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   pl_DistanceX
;   accumDistance
;   nodeOperation
;   idxPolygonVertex
;   bufCourseWorkFlags
;   lineNode0_VertX_LO
;   lineNode0_VertZ_LO
;====================================== ;[[V]]
RenderNodes     .proc
                stz pixelMask           ; clear the mask

                lda nodeOperation       ; operPIXEL?
                bne _1                  ;   no
                jmp RenderPixel

; - - - - - - - - - - - - - - - - - - -
_1              ldy idxPolygonVertex
                lda bufCourseWorkFlags,Y
                beq _process            ; 0=new node (not clipped)
                bmi _XIT1               ; -1=end point, exit

                cmp #$03                ; 3=wind streamer?
                bne _2

                lda #$01
                cmp accumDistance       ; first pixel?
                bne _3                  ;   no

                bra _XIT1               ;   yes, exit

; - - - - - - - - - - - - - - - - - - -
_2              cmp #$01                ; 1=xMax clipped?
                bne _3                  ;   no

;   xMax clip
                cmp accumDistance
                beq _XIT1
                bra _process

; - - - - - - - - - - - - - - - - - - -
;   xMin clip
_3              lda accumDistance
                cmp pl_DistanceX        ; accumDistance <= DistanceX?
                bcc _process            ;   yes
                beq _process            ;   yes

; - - - - - - - - - - - - - - - - - - -
_XIT1           rts                     ; done

; - - - - - - - - - - - - - - - - - - -
_process        ldx lineNode0_VertX_LO
_nextPixel      inx
                cpx #$F0                ; reached xMax [240]?
                bcs _XIT1               ;   yes, exit

                stx renderLineX         ; screenX
                ldy lineNode0_VertZ_LO  ; screenY

                lda pixelMask           ; is mask cleared?
                bne _4                  ;   no, skip

                jsr GetPixelPtr_zp      ; set zpFD (pixel address) and pixelMask

                lda #$FF
                sta pixelMask

                bra _5

; - - - - - - - - - - - - - - - - - - -
_4              inc zpFD                ; increment screen byte address
                bne _5

                inc zpFD+1

;   determine whether to adjust the MMU
                lda zpFD+1
                cmp #>$A000
                bcc _5

                lda zpFD
                sec
                sbc #<$2000
                sta zpFD
                lda zpFD+1
                sbc #>$2000
                sta zpFD+1

;   set the MMU
                lda zpMMU
                inc A
                sta zpMMU
                sta MMU_Block4
                inc A
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
_5              ldy #$00
                lda (zpFD),Y            ; fetch current pixel value
                bne _6                  ; is it BLACK?
                jmp _XIT1               ;   yes, exit

; - - - - - - - - - - - - - - - - - - -
_6              lda #COLOR_GREEN
                sta (zpFD),Y

                ldx renderLineX

                jmp _nextPixel

                .endproc


;======================================
;
;====================================== ;[[V]]
CalcVertX_flags .proc
                lda bufCourseWorkVertZ  ; zFirst
                ldy idxWork             ; # queue entries
                dey

                ldx #$01
                sec
                sbc bufCourseWorkVertZ,Y    ; zFirst - zLast
                beq _1                  ; equal
                bcs _2                  ; bigger

                dex                     ; (-1) smaller
_1              dex                     ; (0) equal
_2              stx rc3_lineNode0_deltaZ    ; (+1) bigger

                ldy #$00                ; lineNode0
                jsr FetchFromClipQueue  ; result A:vertZ, X:vertX
                stx lineNode0_VertX_LO
                sta lineNode0_VertZ_LO

                iny                     ; lineNode1
_next1          jsr FetchFromClipQueue  ; result A:vertZ, X:vertX
                stx lineNode1_VertX_LO
                ldx #$01
                sta lineNode1_VertZ_LO

                sec
                sbc lineNode0_VertZ_LO  ; zNode1 - zNode0
                beq _3                  ; equal
                bcs _4                  ; bigger

                dex                     ; (-1) smaller
_3              dex                     ; (0) equal
_4              stx rc3_lineNode1_deltaZ    ; (+1) bigger

                iny
                lda bufCourseWorkVertZ,Y ; next lineNode0
                dey

                ldx #$01
                sec
                sbc lineNode1_VertZ_LO  ; zNext - zNode1
                beq _5                  ; equal
                bcs _6                  ; bigger

                dex                     ; (-1) smaller
_5              dex                     ; (0) equal
_6              stx rc3_lineNodeN_deltaZ ; (+1) bigger

; - - - - - - - - - - - - - - - - - - -
                lda lineNode1_VertX_LO
                cmp lineNode0_VertX_LO  ; VertX equal?
                bne _9                  ;   no

                lda rc3_lineNode1_deltaZ ; node1 smaller?
                bpl _next3              ;   no

                ldx #$00
                lda rc3_lineNode0_deltaZ ; node0 also smaller?
                bmi _7                  ;   yes

                inx

_7              lda rc3_lineNodeN_deltaZ ; nodeN also smaller?
                bmi _8                  ;  yes

                inx
                inx

_8              txa
                sta bufCourseWorkFlags,Y

                jmp _16

; - - - - - - - - - - - - - - - - - - -
;   xVert differs
_9              bcs _13                 ; node1 >= node0

;   node1 < node0
                lda rc3_lineNode1_deltaZ
                bmi _11                 ; smaller
                beq _10                 ; equal
                jmp _next3              ; larger

; - - - - - - - - - - - - - - - - - - -
;   rc3_lineNode1_deltaZ = 0
_10             lda rc3_lineNode0_deltaZ
                bpl _next3
                jmp _next2

; - - - - - - - - - - - - - - - - - - -
;   rc3_lineNode1_deltaZ = -1
_11             lda rc3_lineNode0_deltaZ    ; smaller?
                bpl _12                     ;   no

; - - - - - - - - - - - - - - - - - - -
;   rc3_lineNodeN_deltaZ = -1
_next2          lda #$00
                sta bufCourseWorkFlags,Y

                jmp _16

; - - - - - - - - - - - - - - - - - - -
;   rc3_lineNode0_deltaZ >=
_12             lda #$01
                sta bufCourseWorkFlags,Y

                jmp _16

; - - - - - - - - - - - - - - - - - - -
;   node1 >=
;   rc3_lineNodeN_deltaZ >=
_next3          lda #$FF
                sta bufCourseWorkFlags,Y

                jmp _16

; - - - - - - - - - - - - - - - - - - -
;   node1 >= node0
_13             lda rc3_lineNode1_deltaZ
                bmi _15                 ; smaller
                beq _14                 ; equal
                jmp _next3              ; larger

; - - - - - - - - - - - - - - - - - - -
;   rc3_lineNode1_deltaZ = 0
_14             lda rc3_lineNodeN_deltaZ ; smaller?
                bpl _next3               ;   no
                jmp _next2               ;   yes

; - - - - - - - - - - - - - - - - - - -
;   rc3_lineNode1_deltaZ = -1
_15             lda rc3_lineNodeN_deltaZ ; smaller?
                bmi _next2               ;   yes

                lda #$02
                sta bufCourseWorkFlags,Y

; - - - - - - - - - - - - - - - - - - -
_16             cpy #$00                ; end reached?
                beq _XIT                ;   yes

                iny
                cpy idxWork             ; last node?
                bcc _17                 ;   no

                ldy #$00                ; last node becomes first node
_17             lda rc3_lineNode1_deltaZ
                sta rc3_lineNode0_deltaZ

                lda lineNode1_VertZ_LO  ; last node becomes first node
                sta lineNode0_VertZ_LO
                lda lineNode1_VertX_LO
                sta lineNode0_VertX_LO

                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_XIT            rts
                .endproc


;======================================
; Render the cup when on the green,
; otherwise render the pin
;====================================== ;[[F]]
RenderCupOrPin  .proc
                ldx activePlayer
                lda playerDistUnit,X
                cmp #unitYARDS
                bcs _pin

; - - - - - - - - - - - - - - - - - - -
;   on the green, render the cup
_cup            lda xPosCup_LO
                sec
                sbc #<$0003
                sta polyVertX_LO
                lda xPosCup_HI
                sbc #>$0003
                sta polyVertX_HI

                lda holeInfoPuttRadius_LO
                sta polyVertY_LO
                lda holeInfoPuttRadius_HI
                sta polyVertY_HI

                lda #<$0018             ; surface (24 inches)
                sta polyVertZ_LO
                lda #>$0018
                sta polyVertZ_HI

                ldx #xformNORMAL
                jsr VertexTransform
                stx lineNode0_VertX_LO
                sty lineNode0_VertZ_LO

                lda xPosCup_LO
                clc
                adc #<$0005
                sta polyVertX_LO
                lda xPosCup_HI
                adc #>$0005
                sta polyVertX_HI

                ldx #xformNORMAL
                jsr VertexTransform
                stx lineNode1_VertX_LO
                sty lineNode1_VertZ_LO

                lda #COLOR_BLACK
                sta pixelColor

                jmp ProcessLine

; - - - - - - - - - - - - - - - - - - -
;   off the green, render the pin
_pin            ldx xPosCup_LO
                lda xPosCup_HI
                sta polyVertX_HI

                txa
                clc
                adc #<$000C
                sta polyVertX_LO
                lda #>$000C
                adc polyVertX_HI
                sta polyVertX_HI

                ldx holeInfoPuttRadius_LO
                lda holeInfoPuttRadius_HI
                stx polyVertY_LO
                sta polyVertY_HI

                stz polyVertZ_HI

                lda #COLOR_WHITE        ; flag color
                sta pixelColor

                ldx #$5C                ; vertZ lineNode0
                lda #$4E                ; vertZ lineNode1
                jsr _DRAW

                ldx #$60                ; vertZ lineNode0
                lda #$52                ; vertZ lineNode1
                jsr _DRAW

                ldx #$64                ; vertZ lineNode0
                lda #$56                ; vertZ lineNode1
                jsr _DRAW

                ldx #$68                ; vertZ lineNode0
                lda #$5A                ; vertZ lineNode1
                jsr _DRAW

                lda #COLOR_BLACK        ; pin color
                sta pixelColor

                ldx #$6C                ; vertZ lineNode0
                lda #$18                ; vertZ lineNode1

; = = = = = = = = = = = = = = = = = = =
;
; = = = = = = = = = = = = = = = = = = =
_DRAW           pha

                stx polyVertZ_LO

                ldx #xformNORMAL
                jsr VertexTransform
                stx lineNode0_VertX_LO
                sty lineNode0_VertZ_LO
                sty lineNode0_pairDC_DE_2

                pla
                sta polyVertZ_LO

                ldx #xformNORMAL
                jsr VertexTransform
                stx lineNode1_VertX_LO
                txa
                lsr
                sta lineNode1_WorkB_27DC_2
                sty lineNode1_VertZ_LO
                sty lineNode1_pairDC_DE_HI_2

                jsr ProcessLine

                lda polyVertX_LO
                sec
                sbc #<$0003
                sta polyVertX_LO
                lda polyVertX_HI
                sbc #>$0003
                sta polyVertX_HI

                rts
                .endproc


;======================================
; Transform 3D-coordinate by the View
; Projection
;--------------------------------------
; on entry:
;   X           keyframe #
;====================================== ;[[V]]
VertexTransform .proc
                lda polyVertX_LO
                sta polyVertX_LO_2
                lda polyVertX_HI
                sta polyVertX_HI_2

                lda polyVertZ_LO
                sta polyVertZ_LO_2
                lda polyVertZ_HI
                sta polyVertZ_HI_2

                lda polyVertY_LO
                sta polyVertY_LO_2
                lda polyVertY_HI
                sta polyVertY_HI_2

; - - - - - - - - - - - - - - - - - - -
;   operation #0 = normal
                cpx #xformNORMAL
                bne _1
                jmp Project3DVertex

; - - - - - - - - - - - - - - - - - - -
;   operation #2 = aim position
_1              cpx #xformDELTA_Z
                beq _2
                jmp ProjectAimPosition

; - - - - - - - - - - - - - - - - - - -
;   operation #1 = deltaZ
_2              lda polyVertZ_delta
                sta polyVertZ_LO_2
                stz polyVertZ_HI_2      ; hi-byte unused

                jmp Project3DVertex

                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           xPos
;   Y           yPos
; on exit:
;   Y           =0
;====================================== ;[[V]]
GetPixelPtr     .proc
                lda #$10                ; [8000:9FFF]->[2_0000:2_1FFF]
                sta zpMMU               ; [A000:BFFF]->[2_2000:2_3FFF]

;   initialize with the address of the line containing the pixel
                lda startOfLine_LO,Y
                sta _addr
                lda startOfLine_HI,Y
                sta _addr+1

;   calculate the screen byte index (byte offset for X-coordinate)
                txa
                clc
                adc _addr
                sta _addr
                lda _addr+1
                adc #$00
                sta _addr+1

;   determine whether to adjust the MMU
_next1          cmp #>$2000
                bcc _apply

                lda _addr
                sec
                sbc #<$2000
                sta _addr
                lda _addr+1
                sbc #>$2000
                sta _addr+1

                inc zpMMU

                bra _next1

_apply          clc
                lda _addr
                adc #<scrnTop
                sta _addr
                lda _addr+1
                adc #>scrnTop
                sta _addr+1

                lda _addr
                sta RenderPixel._setAddrPixelByte1+1
                lda _addr+1
                sta RenderPixel._setAddrPixelByte1+2

; - - - - - - - - - - - - - - - - - - -
;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

;   set the MMU
                lda zpMMU
                sta MMU_Block4
                inc A
                sta MMU_Block5

; - - - - - - - - - - - - - - - - - - -
;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

; - - - - - - - - - - - - - - - - - - -
;   clear Y
                ldy #$00
                rts

;--------------------------------------

_addr           .word $0000

                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           new xPos
;   Y           new yPos
; on exit:
;   Y           =0
;   zpFD        pixel pointer
;====================================== ;[[V]]
GetPixelPtr_zp  .proc
                jsr GetPixelPtr

                lda GetPixelPtr._addr
                sta zpFD
                lda GetPixelPtr._addr+1
                sta zpFD+1

                rts
                .endproc
