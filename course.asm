
;======================================
; load course data.
; convert vertices from relative -> absolute.
; populate vertex buffers.
; calculate cup location.
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

                        .byte $00,$00
                        .byte $00,$00

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
                jsr GetCourseOffset._18 ; 18-byte course data; result in Y:X

                txa                     ; Y:X +tableStart
                clc
                adc #<tblCourseHoleWindDirection
                tax
                tya
                adc #>tblCourseHoleWindDirection
                tay

                rts
                .endproc


;======================================
;
;======================================
GetPtrHoleWindVelocity .proc
                jsr GetCourseOffset._18 ; 18-byte course data; result in Y:X

                txa                     ; Y:X +tableStart
                clc
                adc #<tblCourseHoleWindVelocity
                tax
                tya
                adc #>tblCourseHoleWindVelocity
                tay

                rts
                .endproc


;======================================
;
;======================================
GetPtrHolePAR   .proc
                jsr GetCourseOffset._18  ; 18=byte course data; result in Y:X

                txa                     ; Y:X +tableStart
                clc
                adc #<tblCourseHolePAR
                tax
                tya
                adc #>tblCourseHolePAR
                tay

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
                stz _ptr+1

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
; convert vertices to inches and transform.
; transform the cup location.
;--------------------------------------
; on entry:
;   Y:A         playerWindDirection
;--------------------------------------
ProcessCourse   .proc
_ptrPolyVertX_LO    = zpF8
_ptrPolyVertX_HI    = zpFA
_ptrPolyVertY_LO    = zpFC
_ptrPolyVertY_HI    = zpFE
;---

                jsr PhysicsCosine_m4000
                jsr ClearVertexCache

                lda #$00
                sta idxPolygon

_next1          tay
                jsr SetCoursePtrs

                lda bufPolyVertCount,Y
                tay
                dey

_next2          lda (_ptrPolyVertX_LO),Y
                tax
                lda (_ptrPolyVertX_HI),Y
                jsr ConvertToInches     ; *12; result in A:X
                pha                     ; preserve hi-byte

                txa                     ; lo-byte
                clc
                adc playerVertX_delta
                sta wordA_course
                pla                     ; hi-byte
                adc playerVertX_delta+1
                sec
                sbc #>$1800             ; xCenterline
                sta wordA_course+1

                lda (_ptrPolyVertY_LO),Y
                tax
                lda (_ptrPolyVertY_HI),Y
                jsr ConvertToInches     ; *12; result in A:X
                pha

                txa                     ; lo-byte
                sec
                sbc playerVertY_delta
                sta wordB_course
                pla                     ; hi-byte
                sbc playerVertY_delta+1
                sta wordB_course+1
                sty idxPolygonVertex

                jsr CourseTransformA

                ldy idxPolygonVertex
                lda wordC_course
                sta (_ptrPolyVertX_LO),Y
                lda wordC_course+1
                clc
                adc #>$1800             ; xCenterline
                sta (_ptrPolyVertX_HI),Y

                lda wordD_course+1
                bmi _1
                bne _2

                lda wordD_course
                cmp #$FA
                bcs _2

_1              ldx #$00
                lda #$FA
                bne _3

_2              ldx wordD_course+1
                lda wordD_course
_3              sta (_ptrPolyVertY_LO),Y
                txa
                sta (_ptrPolyVertY_HI),Y

                dey
                bpl _next2

                inc idxPolygon
                lda idxPolygon
                cmp holeInfoPolyCount   ; end reached?
                bcs _4                  ;   yes
                jmp _next1              ;   no

; - - - - - - - - - - - - - - - - - - -
_4              lda xPosCup
                clc
                adc playerVertX_delta
                sta wordA_course
                lda xPosCup+1
                adc playerVertX_delta+1
                sec
                sbc #>$1800             ; xCenterline
                sta wordA_course+1

                lda yPosCup
                sec
                sbc playerVertY_delta
                sta wordB_course
                lda yPosCup+1
                sbc playerVertY_delta+1
                sta wordB_course+1

                jsr CourseTransformA

                lda wordC_course
                sta xPosCup_LO
                lda wordC_course+1
                clc
                adc #>$1800             ; xCenterline
                sta xPosCup_HI

                lda wordD_course
                sta holeInfoPuttRadius_LO
                lda wordD_course+1
                sta holeInfoPuttRadius_HI

                jmp ClearVertXPtrs

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
_ptrPolyVertX_LO    = zpF8
_ptrPolyVertX_HI    = zpFA
_ptrPolyVertY_LO    = zpFC
_ptrPolyVertY_HI    = zpFE
;---

                asl                     ; word index
                tax

                lda ptrPolyVertX_LO,X
                sta _ptrPolyVertX_LO
                lda ptrPolyVertX_LO+1,X
                sta _ptrPolyVertX_LO+1

                lda ptrPolyVertX_HI,X
                sta _ptrPolyVertX_HI
                lda ptrPolyVertX_HI+1,X
                sta _ptrPolyVertX_HI+1

                lda ptrPolyVertY_LO,X
                sta _ptrPolyVertY_LO
                lda ptrPolyVertY_LO+1,X
                sta _ptrPolyVertY_LO+1

                lda ptrPolyVertY_HI,X
                sta _ptrPolyVertY_HI
                lda ptrPolyVertY_HI+1,X
                sta _ptrPolyVertY_HI+1

                rts
                .endproc


;======================================
;
;======================================
ClearVertexCache .proc
                ldx #$03
_next1          lda zpF3,X
                sta data_1D57,X

                dex
                bpl _next1

                rts
                .endproc


;--------------------------------------
;--------------------------------------

data_1D57       .byte $00,$00,$00,$00

;--------------------------------------
;
;--------------------------------------
ClearVertXPtrs  .proc
                ldx #$03
_next1          lda data_1D57,X
                sta zpF8,X

                dex
                bpl _next1

                rts
                .endproc

;======================================
;
;======================================
CalcPlayerPositionDelta .proc
                rts
                .endproc


;======================================
; calculate Sqr(deltaX) + Sqr(deltaY).
;--------------------------------------
; Step One of the Pythagorean formula
;======================================
calcHypotenuseArea .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; Step Two of the Pythagorean formula
;--------------------------------------
; given:
;   SQR($097CA440) = $3148
;--------------------------------------
; example:
;   $2294   $A440                     ->$A440 ...   ->$3148
;   $2296   $097C                     ->$097C       ->$097C
;   $2298   $A440->$7FFF              ->$497C       ->$3148
;   $229A   $097C->$0000              ->$0000       ->$0000
;   wordA          $7FFF       ->$7FFF
;   wordB          $A440->$12F9->$497C
;   wordC          $097C->$3739->$0000
;   wordD
;======================================
calcSquareRoot  .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; CARRY is cleared when NOT EQUAL
;======================================
CompareForEquality .proc
                rts
                .endproc


;======================================
; calculate distance to putting green
;--------------------------------------
; example:
; xPosCup               $1800
; holeInfoCupOffset     $3648
; $1B61                 $00
; $9D88                 $00
; distanceToPinFeet3    $4831
; distanceToPinYards    $5E01
;======================================
CalcDistanceToPuttGreen .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

hole_windDir_HI         .byte $00
distanceToPinFeet3      .word $0000     ; HI-byte=feet; LO-byte=inches
distanceToPinYards      .word $0000


;======================================
;
;--------------------------------------
; on entry:
;   distanceToPinFeet
;       HI      feet (whole)
;       LO      inches (fraction)
; on exit:
;   distanceToPinNatural
;   idxDistanceUnit
;======================================
ConvertDistance .proc
                rts
                .endproc


;======================================
; Convert negative word value by its
; 2-compliment, making it positive
;--------------------------------------
; on entry:
;   Y:X         word value
; on exit:
;   Y:X         converted word value
;======================================
Convert2Positive .proc
                rts
                .endproc
