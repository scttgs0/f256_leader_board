
;======================================
;
;--------------------------------------
; on entry:
;   idxActiveHole
;======================================
PrepareCourse   .proc
_srcInfo        = zpFB
_srcOrigin      = zpFB
_srcPolygon     = zpFB
_srcPolyVertPtr = zpFD
_vertex_HI      = tempA
;---

; - - - - - - - - - - - - - - - - - - -
;   retrieve Hole INFO
                jsr GetPtrHoleInfo      ; result in Y:A
                stx _srcInfo
                sty _srcInfo+1

                lda idxActiveHole
                asl                     ; *2 -> 2-byte index
                tay

;   retrieve hole info parameters
                lda (_srcInfo),Y
                sta holeInfoPolyCount
                iny
                lda (_srcInfo),Y
                sta holeInfoPuttRadius_LO

                ;;lda #$00
                stz idxPolygon

; - - - - - - - - - - - - - - - - - - -
;   retrieve Polygon ORIGIN
_nextPolygon    jsr GetPtrPolygonOrigin ; result in zpFB:word

                ldy #$00                ; fetch xOrigin:word
                lda (_srcOrigin),Y
                sta polygonOriginXa
                iny
                lda (_srcOrigin),Y
                sta polygonOriginXa+1
                iny

                lda (_srcOrigin),Y      ; fetch yOrigin:word
                sta polygonOriginYa
                iny
                lda (_srcOrigin),Y
                sta polygonOriginYa+1

; - - - - - - - - - - - - - - - - - - -
;   retrieve Polygon Vertex pointers
                jsr GetPtrPolygon       ; result in zpFD:word

                ldy #$00
                lda (_srcPolyVertPtr),Y
                sta _srcPolygon
                iny
                lda (_srcPolyVertPtr),Y
                sta _srcPolygon+1

                ldy #$00
                lda (_srcPolygon),Y
                sta polyVertexCount

                ldx idxPolygon
                sta bufPolyVertCount,X
                sty idxPolyVertPtr

                jsr ClonePolygonOrigin

                lda idxPolygon
                asl                     ; -> word index
                tax

; - - - - - - - - - - - - - - - - - - -
;   set destination pointers
                lda ptrPolyVertX_LO,X
                sta _vertX_LO+1
                lda ptrPolyVertX_LO+1,X
                sta _vertX_LO+2

                lda ptrPolyVertX_HI,X
                sta _vertX_HI+1
                lda ptrPolyVertX_HI+1,X
                sta _vertX_HI+2

                lda ptrPolyVertY_LO,X
                sta _vertY_LO+1
                lda ptrPolyVertY_LO+1,X
                sta _vertY_LO+2

                lda ptrPolyVertY_HI,X
                sta _vertY_HI+1
                lda ptrPolyVertY_HI+1,X
                sta _vertY_HI+2

; - - - - - - - - - - - - - - - - - - -
;   retrieve polygon vertices (xDelta)
                ldy idxPolyVertPtr
                iny

                ldx #$00
_nextVertex     stz _vertex_HI

                lda (_srcPolygon),Y     ; fetch xDelta
                bpl _1

                dec _vertex_HI

_1              clc
                adc polygonOriginXb     ; vertex values are delta values from the prior value
                sta polygonOriginXb     ; running total

_vertX_LO       sta $FFFF,X             ; [smc]

                lda _vertex_HI
                adc polygonOriginXb+1
                sta polygonOriginXb+1

_vertX_HI       sta $FFFF,X             ; [smc]

                stz _vertex_HI

; - - - - - - - - - - - - - - - - - - -
;   retrieve polygon vertices (yDelta)
                iny
                lda (_srcPolygon),Y     ; fetch yDelta
                bpl _2

                dec _vertex_HI

_2              clc
                adc polygonOriginYb     ; vertex values are delta values from the prior value
                sta polygonOriginYb     ; running total

_vertY_LO       sta $FFFF,X             ; [smc]

                lda _vertex_HI
                adc polygonOriginYb+1
                sta polygonOriginYb+1

_vertY_HI       sta $FFFF,X             ; [smc]

; - - - - - - - - - - - - - - - - - - -
                iny
                inx
                cpx polyVertexCount     ; more vertices?
                bcc _nextVertex         ;   yes

                ldx idxPolygon
                txa

                inx
                stx idxPolygon

                asl                     ; -> word index
                tay

                cpx holeInfoPolyCount   ; more polygons?
                bcs _3                  ;   no
                jmp _nextPolygon        ;   yes

; - - - - - - - - - - - - - - - - - - -
;   last polygon contains the cup location
_3              ldx polygonOriginXa
                lda polygonOriginXa+1
                jsr ConvertToInches     ; *12; result in A:X
                stx xPosCup
                sta xPosCup+1

                lda polygonOriginYa
                sec
                sbc holeInfoPuttRadius_LO
                tax                     ; X=yPosCup_LO
                sta yPosCup
                lda polygonOriginYa+1
                sbc #$00                ; A:X=yPosCup
                jsr ConvertToInches     ; *12; result in A:X
                stx yPosCup
                sta yPosCup+1

                ldx activePlayer
                lda playerWindDirection_HI,X
                tay
                lda playerWindDirection_LO,X
                jmp ProcessCourse

                .endproc


;--------------------------------------
;--------------------------------------

playerVertX_delta       .word $0000
playerVertY_delta       .word $0000

holeInfoPolyCount       .byte $00
idxPolygon              .byte $00

                        .byte $00

polygonOriginXa         .word $0000
polygonOriginYa         .word $0000

                        .byte $00,$00,$00,$00

idxPolyVertPtr          .byte $00
polyVertexCount         .byte $00

polygonOriginXb         .word $0000
polygonOriginYb         .word $0000

tempA                   .byte $00
windDirThisHole_HI      .byte $00


;======================================
;
;======================================
ClonePolygonOrigin .proc
                lda polygonOriginXa
                sta polygonOriginXb
                lda polygonOriginXa+1
                sta polygonOriginXb+1

                lda polygonOriginYa
                sta polygonOriginYb
                lda polygonOriginYa+1
                sta polygonOriginYb+1

                rts
                .endproc


;======================================
;
;======================================
GetPtrHoleInfo  .proc
                jsr GetCourseOffset._36  ; 36-byte course data; result in Y:X

                txa                     ; Y:X +tableStart
                clc
                adc #<tblCourseHoleInfo
                tax
                tya
                adc #>tblCourseHoleInfo
                tay

                rts
                .endproc


;======================================
;
;======================================
GetPtrHoleWindDirection .proc
                rts
                .endproc


;======================================
;
;======================================
GetPtrHoleWindVelocity .proc
                rts
                .endproc


;======================================
;
;======================================
GetPtrHolePAR   .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           polygon index
;======================================
GetPtrPolygonOrigin .proc
_ptr            = zpFB
;---

                jsr GetPolygonOffset    ; result in _ptr

                asl _ptr                ; *4 (16-bit)
                rol _ptr+1
                asl _ptr
                rol _ptr+1

                jsr GetCourseOffset._432 ; 432-byte course data; result in Y:X

                txa                     ; Y:X +offset (16-bit)
                clc
                adc _ptr
                tax
                tya
                adc _ptr+1
                tay

                txa                     ; Y:X +tableStart
                clc
                adc #<tblPolygonOrigins
                sta _ptr
                tya
                adc #>tblPolygonOrigins
                sta _ptr+1

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           polygon index
;======================================
GetPtrPolygon   .proc
_tmpptr         = zpFB
_ptr            = zpFD
;---

                jsr GetPolygonOffset    ; result in _tmpptr

                asl _tmpptr             ; *2 (16-bit)
                rol _tmpptr+1

                jsr GetCourseOffset._216 ; 216-byte course data; result in Y:X

                txa                     ; Y:X +offset (16-bit)
                clc
                adc _tmpptr
                tax
                tya
                adc _tmpptr+1
                tay

                txa                     ; Y:X +tableStart
                clc
                adc #<tblCoursePolygons
                sta _ptr
                tya
                adc #>tblCoursePolygons
                sta _ptr+1

                rts
                .endproc


;======================================
;
;======================================
GetPolygonOffset .proc
_ptr            = zpFB
;---

                ldx idxActiveHole
                ldy #$06

                jsr MultipleBy6         ; 6 polygons per hole; result in X:A; X is ignored

                clc
                adc idxPolygon
                sta _ptr
                lda #$00
                sta _ptr+1

                rts
                .endproc


;======================================
; calculate the array offset for the
; start of the specified course
;======================================
GetCourseOffset .proc
_18             lda #18                 ; 18 bytes per course
                .byte $2C               ; consume the following LDA operation
_36             lda #36                 ; 36 bytes per course
                .byte $2C               ; consume
_216            lda #216                ; 216 bytes per course
                ldx #$00                ; zero HI byte
                jmp _process

; - - - - - - - - - - - - - - - - - - -
_432            lda #<432               ; 432 bytes per course
                ldx #>432

_process        sta _set_LO+1
                stx _set_HI+1

                ldx idxActiveCourse
                lda tblCourseIndexes,X
                tax                     ; X=course #

                lda #$00
                pha                     ; HI-byte on the STACK

_next1          dex                     ; done?
                bmi _1                  ;   yes

                clc
_set_LO         adc #$00                ; [smc]
                tay                     ; Y=courseStartIndex_LO

                pla
_set_HI         adc #$00                ; [smc]
                pha                     ; HI-byte on the STACK

                tya                     ; A=courseStartIndex_LO
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_1              tax                     ; X=courseStartIndex_LO
                pla
                tay                     ; Y=courseStartIndex_HI
                rts
                .endproc


;--------------------------------------
; convert vertices to inches.
; calculate the tee location.
;--------------------------------------
; on entry:
;   Y:A         playerWindDirection
;--------------------------------------
ProcessCourse   .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

wordA_course    .word $0000
wordB_course    .word $0000
wordC_course    .word $0000
wordD_course    .word $0000


;======================================
;
;--------------------------------------
; on entry:
;   A           idxPolygon
;======================================
SetCoursePtrs   .proc
                rts
                .endproc


;======================================
;
;======================================
ClearVertexCache .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
ClearVertXPtrs  .proc
                rts
                .endproc


;======================================
;
;======================================
RenderCourse4   .proc
                rts
                .endproc


;======================================
;
;======================================
RenderCourse3   .proc
                rts
                .endproc
