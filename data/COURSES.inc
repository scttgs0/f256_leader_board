
;   Standard Courses

;   support for 6 polygons per hole
;              16 vertices per polygon

ptrPolyVertX_LO .addr bufPolyA_VertX_LO
                .addr bufPolyB_VertX_LO
                .addr bufPolyC_VertX_LO
                .addr bufPolyD_VertX_LO
                .addr bufPolyE_VertX_LO
                .addr bufPolyF_VertX_LO

ptrPolyVertX_HI .addr bufPolyA_VertX_HI
                .addr bufPolyB_VertX_HI
                .addr bufPolyC_VertX_HI
                .addr bufPolyD_VertX_HI
                .addr bufPolyE_VertX_HI
                .addr bufPolyF_VertX_HI

ptrPolyVertY_LO .addr bufPolyA_VertY_LO
                .addr bufPolyB_VertY_LO
                .addr bufPolyC_VertY_LO
                .addr bufPolyD_VertY_LO
                .addr bufPolyE_VertY_LO
                .addr bufPolyF_VertY_LO

ptrPolyVertY_HI .addr bufPolyA_VertY_HI
                .addr bufPolyB_VertY_HI
                .addr bufPolyC_VertY_HI
                .addr bufPolyD_VertY_HI
                .addr bufPolyE_VertY_HI
                .addr bufPolyF_VertY_HI

;--------------------------------------

bufPolyVertCount    .fill 6,$00

;--------------------------------------

;   polygon vertices buffers
bufPolyA_VertX_LO   .fill 16,$00
bufPolyA_VertX_HI   .fill 16,$00
bufPolyA_VertY_LO   .fill 16,$00
bufPolyA_VertY_HI   .fill 16,$00

bufPolyB_VertX_LO   .fill 16,$00
bufPolyB_VertX_HI   .fill 16,$00
bufPolyB_VertY_LO   .fill 16,$00
bufPolyB_VertY_HI   .fill 16,$00

bufPolyC_VertX_LO   .fill 16,$00
bufPolyC_VertX_HI   .fill 16,$00
bufPolyC_VertY_LO   .fill 16,$00
bufPolyC_VertY_HI   .fill 16,$00

bufPolyD_VertX_LO   .fill 16,$00
bufPolyD_VertX_HI   .fill 16,$00
bufPolyD_VertY_LO   .fill 16,$00
bufPolyD_VertY_HI   .fill 16,$00

bufPolyE_VertX_LO   .fill 16,$00
bufPolyE_VertX_HI   .fill 16,$00
bufPolyE_VertY_LO   .fill 16,$00
bufPolyE_VertY_HI   .fill 16,$00

bufPolyF_VertX_LO   .fill 16,$00
bufPolyF_VertX_HI   .fill 16,$00
bufPolyF_VertY_LO   .fill 16,$00
bufPolyF_VertY_HI   .fill 16,$00

;--------------------------------------

bufCourseWorkVertX  .fill 32,$00
bufCourseWorkVertZ  .fill 32,$00
bufCourseWorkFlags  .fill 32,$00

;--------------------------------------

holesPerCourse  .byte 18

;--------------------------------------

;   first values holeInfoPolyCount (# of polygons)
;   $03
;   $04
;   $05
;   $06
;   second values holeInfoPuttRadius_LO (delta from polygon origin to the cup location)
;   $4B = 75
;   $64 = 100
;   $7D = 125
;   $96 = 150
;   $AF = 175
;   $C8 = 200

tblCourseHoleInfo
                .byte $06,$64,$06,$4B,$03,$4B,$04,$4B,$06   ;[1]    18 holes, course 1
                .byte $4B,$03,$4B,$03,$4B,$04,$4B,$05,$4B
                .byte $05,$4B,$03,$7D,$03,$64,$06,$4B,$05
                .byte $4B,$06,$4B,$04,$4B,$05,$4B,$05,$4B
                .byte $06,$64,$05,$AF,$05,$4B,$04,$64,$04   ;[2]    18 holes, course 2
                .byte $4B,$04,$AF,$06,$4B,$03,$4B,$06,$64
                .byte $05,$64,$05,$64,$04,$4B,$03,$4B,$06
                .byte $64,$05,$64,$05,$4B,$05,$C8,$05,$4B
                .byte $05,$64,$04,$64,$05,$4B,$05,$4B,$05   ;[3]    18 holes, course 3
                .byte $57,$03,$4B,$04,$4B,$05,$7D,$06,$4B
                .byte $05,$4B,$05,$4B,$04,$7D,$06,$4B,$06
                .byte $4B,$04,$4B,$06,$4B,$06,$64,$06,$4B
                .byte $05,$4B,$04,$64,$04,$4B,$06,$4B,$05   ;[4]    18 holes, course 4
                .byte $4B,$05,$4B,$06,$4B,$05,$4B,$04,$4B
                .byte $06,$64,$06,$4B,$04,$4B,$05,$4B,$06
                .byte $4B,$04,$4B,$04,$64,$06,$4B,$05,$64

tblCourseHoleWindDirection
                .byte $00,$8C,$C0,$70,$64,$80,$60,$A0,$80   ;[1]
                .byte $62,$40,$40,$87,$C0,$64,$80,$80,$90
                .byte $80,$8C,$C0,$70,$64,$80,$60,$A0,$80   ;[2]
                .byte $66,$40,$40,$87,$C0,$64,$80,$80,$90
                .byte $80,$8C,$C0,$70,$64,$80,$62,$A0,$80   ;[3]
                .byte $64,$40,$40,$87,$C0,$64,$80,$80,$90
                .byte $80,$8C,$C0,$70,$64,$80,$62,$A0,$80   ;[4]
                .byte $62,$40,$40,$8C,$C0,$64,$80,$80,$A0

tblCourseHoleWindVelocity
                .byte $09,$07,$08,$06,$05,$07,$08,$06,$08   ;[1]
                .byte $07,$09,$07,$07,$07,$06,$08,$09,$06
                .byte $09,$07,$08,$06,$05,$07,$08,$06,$08   ;[2]
                .byte $07,$09,$07,$07,$07,$06,$08,$09,$06
                .byte $09,$07,$08,$06,$05,$07,$08,$06,$08   ;[3]
                .byte $07,$09,$07,$07,$07,$06,$08,$09,$06
                .byte $09,$07,$08,$06,$05,$07,$08,$06,$08   ;[4]
                .byte $07,$09,$07,$07,$07,$06,$08,$09,$06

tblCourseHolePAR
                .byte $04,$05,$03,$04,$05,$03,$03,$04,$05   ;[1]
                .byte $04,$03,$04,$04,$04,$05,$03,$05,$04
                .byte $04,$03,$05,$04,$04,$03,$04,$05,$04   ;[2]
                .byte $04,$03,$04,$03,$04,$05,$04,$04,$05
                .byte $03,$04,$05,$04,$04,$03,$04,$04,$05   ;[3]
                .byte $04,$04,$03,$05,$04,$03,$04,$05,$04
                .byte $05,$03,$04,$04,$04,$05,$04,$04,$03   ;[4]
                .byte $04,$05,$03,$04,$04,$03,$04,$04,$05

;--------------------------------------
; 432-byte array per course
; 2-byte vertex * 2 vertex * 6 polygons * 18 holes

tblPolygonOrigins
;   course 1
                .word $0200,$02AB, $01E7,$03A5, $016A,$0409, $0296,$0409, $01E7,$043B, $0200,$04EA
                .word $024B,$00E9, $0200,$0134, $0200,$035A, $01E7,$04B8, $01E7,$0599, $01E7,$0616
                .word $0200,$0102, $0219,$017F, $0200,$022E, $0000,$0000, $0000,$0000, $0000,$0000
                .word $0219,$02AB, $0200,$030F, $0264,$0422, $019C,$0567, $0000,$0000, $0000,$0000
                .word $0200,$0215, $0219,$038C, $027D,$04EA, $0232,$0535, $0200,$0599, $0200,$0616
                .word $01E7,$0102, $0200,$017F, $0200,$02C4, $0000,$0000, $0000,$0000, $0000,$0000
                .word $0200,$00D0, $01CE,$017F, $0200,$02DD, $0000,$0000, $0000,$0000, $0000,$0000
                .word $01E7,$0166, $01E7,$0247, $0200,$049F, $0232,$05B2, $0000,$0000, $0000,$0000
                .word $0200,$00B7, $0200,$02C4, $027D,$043B, $0200,$051C, $0200,$0599, $0000,$0000
                .word $01B5,$0134, $0200,$0215, $0200,$0341, $0200,$03F0, $01CE,$049F, $0000,$0000
                .word $0200,$00B7, $0200,$0134, $0200,$0247, $0000,$0000, $0000,$0000, $0000,$0000
                .word $01E7,$014D, $0200,$03A5, $01E7,$04D1, $0000,$0000, $0000,$0000, $0000,$0000
                .word $01CE,$0134, $01CE,$0215, $0200,$030F, $01CE,$0422, $01CE,$04D1, $0219,$054E
                .word $01E7,$0166, $01E7,$0215, $0200,$0292, $0200,$0422, $0200,$0486, $0000,$0000
                .word $01E7,$0134, $01E7,$03D7, $024B,$049F, $016A,$049F, $0232,$0580, $01E7,$05CB
                .word $0200,$00B7, $01E7,$017F, $0200,$01FC, $0200,$0279, $0000,$0000, $0000,$0000
                .word $0200,$02C4, $0200,$03F0, $0200,$0486, $0200,$0599, $0200,$05FD, $0000,$0000
                .word $01B5,$017F, $024B,$030F, $016A,$03F0, $0200,$04EA, $01CE,$0567, $0000,$0000

;   course 2
                .word $01CE,$0198, $01CE,$030F, $0219,$03BE, $01B5,$0409, $0183,$040E, $01B5,$051C
                .word $01E7,$0102, $0106,$0198, $01B5,$02AB, $02C8,$02DD, $0200,$02C4, $0000,$0000
                .word $01E7,$0085, $01B5,$035A, $0232,$0486, $016A,$05B2, $0264,$05FD, $0000,$0000
                .word $0200,$0279, $01B5,$038C, $0219,$038C, $0200,$043B, $0000,$0000, $0000,$0000
                .word $024B,$01CA, $0219,$0328, $01CE,$0486, $0264,$05B2, $0000,$0000, $0000,$0000
                .word $0200,$01CA, $01CE,$030F, $0232,$030F, $0200,$0373, $0000,$0000, $0000,$0000
                .word $0219,$0102, $0219,$038C, $01B5,$0422, $0200,$046D, $024B,$04EA, $024B,$0567
                .word $0200,$02AB, $0200,$0503, $0200,$0648, $0000,$0000, $0000,$0000, $0000,$0000
                .word $01E7,$0085, $024B,$02F6, $01CE,$0454, $01CE,$04D1, $019C,$0503, $01CE,$05E4
                .word $0200,$00D0, $0200,$02F6, $0183,$0341, $024B,$0341, $0200,$0454, $0000,$0000
                .word $0200,$00E9, $02E1,$01CA, $0106,$022E, $02AF,$030F, $0200,$0215, $0000,$0000
                .word $0200,$009E, $01E7,$0215, $0219,$0328, $0200,$0599, $0000,$0000, $0000,$0000
                .word $0219,$00D0, $01E7,$0279, $0232,$0373, $0000,$0000, $0000,$0000, $0000,$0000
                .word $01CE,$01CA, $0219,$0341, $0219,$035A, $0200,$0373, $0200,$04B8, $024B,$0567
                .word $01E7,$0085, $01E7,$01B1, $0200,$0373, $0200,$05B2, $01B5,$0661, $0000,$0000
                .word $01E7,$0085, $01B5,$01FC, $01E7,$0328, $024B,$03F0, $0200,$0535, $0000,$0000
                .word $0200,$011B, $0219,$02AB, $01CE,$03A5, $0200,$04B8, $0219,$051C, $0000,$0000
                .word $0219,$0102, $0200,$02C4, $0264,$0328, $0183,$04EA, $024B,$062F, $0000,$0000

;   course 3
                .word $0200,$0134, $011F,$0184, $0200,$038C, $02E1,$0422, $0200,$038C, $0000,$0000
                .word $0200,$017F, $01E7,$02DD, $0232,$043B, $01CE,$0503, $0000,$0000, $0000,$0000
                .word $0200,$0198, $0200,$0292, $0200,$0454, $01CE,$0503, $0264,$05FD, $0000,$0000
                .word $0200,$01FC, $0200,$03A5, $0151,$0648, $032C,$0648, $0200,$05E4, $0000,$0000
                .word $0200,$01FC, $01E7,$02DD, $01CE,$043B, $0219,$043B, $0200,$0422, $0000,$0000
                .word $0200,$0085, $0296,$01CA, $0200,$017F, $0000,$0000, $0000,$0000, $0000,$0000
                .word $01E7,$00E9, $01E7,$02F6, $027D,$03F0, $01E7,$046D, $0000,$0000, $0000,$0000
                .word $024B,$0215, $0200,$0373, $00D4,$0503, $02FA,$0567, $01CE,$049F, $0000,$0000
                .word $0200,$0102, $0200,$0341, $0183,$04D1, $027D,$04D1, $0200,$054E, $0200,$0661
                .word $01E7,$014D, $01E7,$030F, $0296,$043B, $0200,$044F, $01E7,$04D1, $0000,$0000
                .word $0219,$0102, $019C,$02DD, $0183,$0454, $027D,$0486, $024B,$0599, $0000,$0000
                .word $01E7,$0134, $024B,$030F, $011F,$0341, $01E7,$0279, $0000,$0000, $0000,$0000
                .word $01E7,$0085, $0219,$0341, $01E7,$0454, $01E7,$054E, $0200,$05B2, $0200,$062F
                .word $01E7,$0085, $0200,$030F, $0200,$0409, $0183,$0567, $027D,$0567, $0200,$054E
                .word $01B5,$01E3, $011F,$02DD, $0296,$0341, $0219,$02F6, $0000,$0000, $0000,$0000
                .word $0200,$0181, $01E7,$030F, $0232,$03BE, $019C,$04B8, $01E7,$0503, $01E7,$0580
                .word $01E7,$0085, $01CE,$0260, $01CE,$02DD, $01CE,$035A, $0200,$046D, $01B5,$05FD
                .word $0200,$0085, $01E7,$02C4, $0232,$035A, $0232,$03D7, $0200,$046D, $01B5,$05CB

;   course 3
                .word $0219,$0102, $01CE,$03BE, $0264,$049F, $019C,$051C, $0219,$0616, $0000,$0000
                .word $0200,$017F, $01CE,$0341, $0200,$0341, $0200,$0341, $0000,$0000, $0000,$0000
                .word $01B5,$0102, $0296,$03A5, $01CE,$043B, $01CE,$04B8, $0000,$0000, $0000,$0000
                .word $0219,$009E, $024B,$02AB, $01B5,$030F, $0200,$038C, $01CE,$0422, $0232,$051C
                .word $024B,$0215, $01CE,$02DD, $032C,$0409, $0183,$0422, $024B,$03F0, $0000,$0000
                .word $01B5,$0215, $0183,$03BE, $0200,$03A5, $0200,$0567, $019C,$0648, $0000,$0000
                .word $01E7,$0085, $0200,$0292, $019C,$04D1, $0264,$04D1, $0200,$0580, $0200,$05E4
                .word $01B5,$0102, $0219,$02F6, $01CE,$038C, $019C,$0422, $0232,$043B, $0000,$0000
                .word $0200,$01FC, $011F,$02C4, $024B,$0373, $0200,$02AB, $0000,$0000, $0000,$0000
                .word $0200,$01E3, $019C,$030F, $024B,$035A, $01CE,$03BE, $01CE,$043B, $0200,$04EA
                .word $01E7,$009E, $0200,$02C4, $01E7,$03A5, $0200,$0454, $0200,$062F, $0200,$062F
                .word $0200,$014D, $01CE,$02DD, $024B,$03F0, $0219,$0328, $0000,$0000, $0000,$0000
                .word $0200,$00D0, $0232,$0279, $01CE,$046D, $0232,$046D, $01CE,$051C, $0000,$0000
                .word $0200,$01CA, $01E7,$02AB, $01E7,$035A, $01E7,$03F0, $024B,$0486, $0200,$04D1
                .word $0200,$0198, $0200,$0341, $011F,$0409, $01CE,$035A, $0000,$0000, $0000,$0000
                .word $01CE,$01CA, $019C,$035A, $0264,$03F0, $0200,$046D, $0000,$0000, $0000,$0000
                .word $0200,$017F, $0200,$02C4, $0219,$035A, $024B,$03F0, $0200,$043B, $01CE,$04B8
                .word $01CE,$014D, $0183,$03F0, $0232,$0409, $0219,$0567, $0264,$0616, $0000,$0000

;--------------------------------------
; 216-byte array per course
; 2-byte polygon * 6 polygons * 18 holes

tblCoursePolygons
;   course 1
                .word poly13Vertices,poly12Vertices,poly00Vertices,poly00Vertices,poly11Vertices,poly10Vertices     ; {6 polygons}  [00]
                .word poly15Vertices,poly08Vertices,poly09Vertices,poly03Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}
                .word poly14Vertices,poly07Vertices,poly00Vertices,$0000,$0000,$0000                                ; {3 polygons}
                .word poly13Vertices,poly05Vertices,poly17Vertices,poly16Vertices,$0000,$0000                       ; {4 polygons}
                .word poly09Vertices,poly04Vertices,poly15Vertices,poly08Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}  [04]
                .word poly14Vertices,poly07Vertices,poly01Vertices,$0000,$0000,$0000                                ; {3 polygons}
                .word poly02Vertices,poly00Vertices,poly16Vertices,$0000,$0000,$0000                                ; {3 polygons}
                .word poly12Vertices,poly11Vertices,poly13Vertices,poly16Vertices,$0000,$0000                       ; {4 polygons}
                .word poly00Vertices,poly09Vertices,poly04Vertices,poly02Vertices,poly00Vertices,$0000              ; {5 polygons}  [08]
                .word poly16Vertices,poly16Vertices,poly18Vertices,poly11Vertices,poly03Vertices,$0000              ; {5 polygons}
                .word poly02Vertices,poly00Vertices,poly01Vertices,$0000,$0000,$0000                                ; {3 polygons}
                .word poly19Vertices,poly13Vertices,poly18Vertices,$0000,$0000,$0000                                ; {3 polygons}
                .word poly12Vertices,poly11Vertices,poly05Vertices,poly06Vertices,poly14Vertices,poly10Vertices     ; {6 polygons}  [0C]
                .word poly12Vertices,poly11Vertices,poly10Vertices,poly09Vertices,poly00Vertices,$0000              ; {5 polygons}
                .word poly18Vertices,poly13Vertices,poly05Vertices,poly06Vertices,poly15Vertices,poly08Vertices     ; {6 polygons}
                .word poly00Vertices,poly14Vertices,poly07Vertices,poly00Vertices,$0000,$0000                       ; {4 polygons}
                .word poly13Vertices,poly09Vertices,poly10Vertices,poly14Vertices,poly00Vertices,$0000              ; {5 polygons}  [10]
                .word poly16Vertices,poly09Vertices,poly13Vertices,poly16Vertices,poly00Vertices,$0000              ; {5 polygons}

;   course 2
                .word poly27Vertices,poly27Vertices,poly10Vertices,poly28Vertices,poly34Vertices,poly01Vertices     ; {6 polygons}  [00]
                .word poly19Vertices,poly32Vertices,poly24Vertices,poly29Vertices,poly24Vertices,poly00Vertices     ; {6 polygons}
                .word poly32Vertices,poly18Vertices,poly15Vertices,poly16Vertices,poly00Vertices,$0000              ; {5 polygons}
                .word poly13Vertices,poly22Vertices,poly23Vertices,poly10Vertices,$0000,$0000                       ; {4 polygons}
                .word poly25Vertices,poly27Vertices,poly16Vertices,poly30Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}  [04]
                .word poly26Vertices,poly28Vertices,poly28Vertices,poly29Vertices,$0000,$0000                       ; {4 polygons}
                .word poly22Vertices,poly01Vertices,poly14Vertices,poly07Vertices,poly08Vertices,poly00Vertices     ; {6 polygons}
                .word poly13Vertices,poly13Vertices,poly00Vertices,poly16Vertices,$0000,$0000                       ; {4 polygons}
                .word poly32Vertices,poly25Vertices,poly16Vertices,poly28Vertices,poly34Vertices,poly01Vertices     ; {6 polygons}  [08]
                .word poly28Vertices,poly29Vertices,poly23Vertices,poly22Vertices,poly01Vertices,$0000              ; {5 polygons}
                .word poly28Vertices,poly28Vertices,poly32Vertices,poly29Vertices,poly10Vertices,$0000              ; {5 polygons}
                .word poly28Vertices,poly11Vertices,poly05Vertices,poly13Vertices,$0000,$0000                       ; {4 polygons}
                .word poly22Vertices,poly27Vertices,poly30Vertices,poly06Vertices,poly14Vertices,poly10Vertices     ; {6 polygons}  [0C]
                .word poly27Vertices,poly27Vertices,poly28Vertices,poly25Vertices,poly27Vertices,poly10Vertices     ; {6 polygons}
                .word poly32Vertices,poly33Vertices,poly29Vertices,poly13Vertices,poly10Vertices,poly08Vertices     ; {6 polygons}
                .word poly32Vertices,poly03Vertices,poly24Vertices,poly04Vertices,poly16Vertices,$0000              ; {5 polygons}
                .word poly26Vertices,poly26Vertices,poly06Vertices,poly05Vertices,poly06Vertices,$0000              ; {5 polygons}  [10]
                .word poly22Vertices,poly09Vertices,poly10Vertices,poly31Vertices,poly30Vertices,$0000              ; {5 polygons}

;   course 3
                .word poly29Vertices,poly32Vertices,poly25Vertices,poly28Vertices,poly24Vertices,poly10Vertices     ; {6 polygons}  [00]
                .word poly29Vertices,poly29Vertices,poly29Vertices,poly10Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}
                .word poly26Vertices,poly05Vertices,poly05Vertices,poly23Vertices,poly04Vertices,$0000              ; {5 polygons}
                .word poly26Vertices,poly09Vertices,poly32Vertices,poly29Vertices,poly13Vertices,$0000              ; {5 polygons}
                .word poly26Vertices,poly11Vertices,poly20Vertices,poly21Vertices,poly28Vertices,poly00Vertices     ; {6 polygons}  [04]
                .word poly28Vertices,poly29Vertices,poly00Vertices,$0000,$0000,$0000                                ; {3 polygons}
                .word poly14Vertices,poly00Vertices,poly25Vertices,poly00Vertices,$0000,$0000                       ; {4 polygons}
                .word poly25Vertices,poly27Vertices,poly32Vertices,poly29Vertices,poly18Vertices,$0000              ; {5 polygons}
                .word poly28Vertices,poly09Vertices,poly24Vertices,poly25Vertices,poly00Vertices,poly00Vertices     ; {6 polygons}  [08]
                .word poly19Vertices,poly20Vertices,poly25Vertices,poly21Vertices,poly00Vertices,$0000              ; {5 polygons}
                .word poly22Vertices,poly31Vertices,poly31Vertices,poly25Vertices,poly30Vertices,$0000              ; {5 polygons}
                .word poly19Vertices,poly32Vertices,poly28Vertices,poly18Vertices,$0000,$0000                       ; {4 polygons}
                .word poly32Vertices,poly18Vertices,poly06Vertices,poly19Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}  [0C]
                .word poly32Vertices,poly09Vertices,poly00Vertices,poly24Vertices,poly25Vertices,poly00Vertices     ; {6 polygons}
                .word poly24Vertices,poly32Vertices,poly32Vertices,poly30Vertices,poly15Vertices,poly08Vertices     ; {6 polygons}
                .word poly26Vertices,poly20Vertices,poly02Vertices,poly24Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}
                .word poly32Vertices,poly23Vertices,poly23Vertices,poly23Vertices,poly05Vertices,poly10Vertices     ; {6 polygons}  [10]
                .word poly28Vertices,poly27Vertices,poly22Vertices,poly00Vertices,poly23Vertices,poly16Vertices     ; {6 polygons}

;   course 4
                .word poly22Vertices,poly09Vertices,poly00Vertices,poly00Vertices,poly00Vertices,poly10Vertices     ; {6 polygons}  [00]
                .word poly26Vertices,poly22Vertices,poly23Vertices,poly29Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}
                .word poly23Vertices,poly13Vertices,poly02Vertices,poly00Vertices,$0000,$0000                       ; {4 polygons}
                .word poly02Vertices,poly15Vertices,poly14Vertices,poly08Vertices,poly07Vertices,poly01Vertices     ; {6 polygons}
                .word poly25Vertices,poly00Vertices,poly28Vertices,poly32Vertices,poly00Vertices,poly00Vertices     ; {6 polygons}  [04]
                .word poly24Vertices,poly24Vertices,poly00Vertices,poly25Vertices,poly10Vertices,$0000              ; {5 polygons}
                .word poly32Vertices,poly29Vertices,poly24Vertices,poly25Vertices,poly02Vertices,poly00Vertices     ; {6 polygons}
                .word poly23Vertices,poly26Vertices,poly14Vertices,poly07Vertices,poly00Vertices,$0000              ; {5 polygons}
                .word poly26Vertices,poly28Vertices,poly32Vertices,poly10Vertices,poly00Vertices,$0000              ; {5 polygons}  [08]
                .word poly09Vertices,poly23Vertices,poly00Vertices,poly22Vertices,poly33Vertices,poly10Vertices     ; {6 polygons}
                .word poly33Vertices,poly00Vertices,poly11Vertices,poly10Vertices,poly30Vertices,poly16Vertices     ; {6 polygons}
                .word poly26Vertices,poly24Vertices,poly32Vertices,poly00Vertices,$0000,$0000                       ; {4 polygons}
                .word poly28Vertices,poly00Vertices,poly21Vertices,poly20Vertices,poly10Vertices,poly10Vertices     ; {6 polygons}  [0C]
                .word poly26Vertices,poly12Vertices,poly14Vertices,poly07Vertices,poly15Vertices,poly00Vertices     ; {6 polygons}
                .word poly26Vertices,poly21Vertices,poly29Vertices,poly00Vertices,poly15Vertices,poly08Vertices     ; {6 polygons}
                .word poly27Vertices,poly24Vertices,poly02Vertices,poly10Vertices,$0000,$0000                       ; {4 polygons}
                .word poly29Vertices,poly08Vertices,poly28Vertices,poly15Vertices,poly08Vertices,poly00Vertices     ; {6 polygons}  [10]
                .word poly21Vertices,poly24Vertices,poly00Vertices,poly27Vertices,poly10Vertices,$0000              ; {5 polygons}

;--------------------------------------

poly00Vertices  .byte $08
                .byte $00,$00
                .byte $32,$E7
                .byte $19,$CE
                .byte $E7,$CE
                .byte $CE,$E7
                .byte $CE,$19
                .byte $E7,$32
                .byte $19,$32
poly01Vertices  .byte $09
                .byte $00,$00
                .byte $32,$E7
                .byte $19,$CE
                .byte $00,$9C
                .byte $E7,$CE
                .byte $9C,$00
                .byte $E7,$32
                .byte $00,$64
                .byte $19,$32
poly02Vertices  .byte $06
                .byte $00,$00
                .byte $32,$CE
                .byte $00,$CE
                .byte $CE,$E7
                .byte $CE,$19
                .byte $00,$32
poly03Vertices  .byte $0A
                .byte $00,$00
                .byte $4B,$00
                .byte $7D,$83
                .byte $00,$B5
                .byte $E7,$CE
                .byte $CE,$E7
                .byte $CE,$19
                .byte $83,$7D
                .byte $E7,$32
                .byte $19,$32
poly04Vertices  .byte $0A
                .byte $00,$00
                .byte $32,$E7
                .byte $19,$CE
                .byte $E7,$CE
                .byte $83,$83
                .byte $CE,$E7
                .byte $CE,$19
                .byte $E7,$32
                .byte $00,$4B
                .byte $7D,$7D
poly05Vertices  .byte $0A
                .byte $00,$00
                .byte $32,$00
                .byte $19,$B5
                .byte $00,$CE
                .byte $CE,$9C
                .byte $E7,$CE
                .byte $CE,$00
                .byte $E7,$4B
                .byte $00,$32
                .byte $19,$32
poly06Vertices  .byte $0A
                .byte $00,$00
                .byte $32,$00
                .byte $32,$9C
                .byte $19,$CE
                .byte $00,$CE
                .byte $E7,$B5
                .byte $CE,$00
                .byte $E7,$32
                .byte $CE,$64
                .byte $00,$32
poly07Vertices  .byte $06
                .byte $00,$00
                .byte $19,$E7
                .byte $19,$83
                .byte $E7,$E7
                .byte $B5,$4B
                .byte $19,$4B
poly08Vertices  .byte $07
                .byte $00,$00
                .byte $4B,$00
                .byte $19,$CE
                .byte $E7,$E7
                .byte $83,$B5
                .byte $E7,$19
                .byte $19,$64
poly09Vertices  .byte $0A
                .byte $00,$00
                .byte $23,$CE
                .byte $0F,$83
                .byte $00,$9C
                .byte $F1,$83
                .byte $DD,$CE
                .byte $DD,$32
                .byte $F1,$7D
                .byte $00,$64
                .byte $0F,$7D
poly10Vertices  .byte $08
                .byte $00,$00
                .byte $4B,$E7
                .byte $19,$B5
                .byte $E7,$B5
                .byte $B5,$E7
                .byte $B5,$19
                .byte $E7,$4B
                .byte $19,$4B
poly11Vertices  .byte $06
                .byte $00,$00
                .byte $32,$00
                .byte $00,$83
                .byte $00,$83
                .byte $CE,$00
                .byte $00,$7D
poly12Vertices  .byte $07
                .byte $00,$00
                .byte $32,$00
                .byte $32,$83
                .byte $00,$83
                .byte $B5,$E7
                .byte $B5,$19
                .byte $00,$7D
poly13Vertices  .byte $0D
                .byte $00,$00
                .byte $4B,$00
                .byte $4B,$83
                .byte $00,$83
                .byte $00,$83
                .byte $CE,$83
                .byte $B5,$83
                .byte $CE,$00
                .byte $B5,$7D
                .byte $CE,$7D
                .byte $00,$7D
                .byte $00,$7D
                .byte $4B,$7D
poly14Vertices  .byte $07
                .byte $00,$00
                .byte $4B,$B5
                .byte $19,$B5
                .byte $CE,$E7
                .byte $CE,$00
                .byte $CE,$19
                .byte $19,$7D
poly15Vertices  .byte $07
                .byte $00,$00
                .byte $19,$E7
                .byte $CE,$83
                .byte $CE,$E7
                .byte $CE,$19
                .byte $E7,$32
                .byte $19,$19
poly16Vertices  .byte $0A
                .byte $00,$00
                .byte $32,$E7
                .byte $32,$9C
                .byte $32,$9C
                .byte $32,$9C
                .byte $83,$CE
                .byte $CE,$64
                .byte $CE,$64
                .byte $CE,$64
                .byte $19,$32
poly17Vertices  .byte $08
                .byte $00,$00
                .byte $19,$83
                .byte $00,$83
                .byte $00,$83
                .byte $9C,$E7
                .byte $E7,$7D
                .byte $00,$7D
                .byte $00,$7D
poly18Vertices  .byte $08
                .byte $00,$00
                .byte $32,$00
                .byte $4B,$9C
                .byte $00,$83
                .byte $B5,$9C
                .byte $CE,$00
                .byte $B5,$64
                .byte $00,$7D
poly19Vertices  .byte $06
                .byte $00,$00
                .byte $32,$00
                .byte $F1,$83
                .byte $00,$83
                .byte $EC,$00
                .byte $00,$7D
poly20Vertices  .byte $0A
                .byte $00,$00
                .byte $19,$00
                .byte $00,$9C
                .byte $00,$83
                .byte $00,$83
                .byte $00,$9C
                .byte $E7,$00
                .byte $E7,$64
                .byte $E7,$7D
                .byte $19,$7D
poly21Vertices  .byte $0A
                .byte $00,$00
                .byte $19,$00
                .byte $19,$9C
                .byte $19,$83
                .byte $E7,$83
                .byte $E7,$9C
                .byte $E7,$00
                .byte $00,$64
                .byte $00,$7D
                .byte $00,$7D
poly22Vertices  .byte $06
                .byte $00,$00
                .byte $32,$00
                .byte $00,$CE
                .byte $CE,$83
                .byte $CE,$00
                .byte $00,$32
poly23Vertices  .byte $06
                .byte $00,$00
                .byte $32,$00
                .byte $32,$83
                .byte $00,$CE
                .byte $CE,$00
                .byte $CE,$7D
poly24Vertices  .byte $0A
                .byte $00,$00
                .byte $32,$E7
                .byte $19,$83
                .byte $19,$83
                .byte $19,$83
                .byte $E7,$CE
                .byte $CE,$19
                .byte $E7,$7D
                .byte $E7,$7D
                .byte $E7,$7D
poly25Vertices  .byte $0A
                .byte $00,$00
                .byte $19,$CE
                .byte $E7,$83
                .byte $E7,$83
                .byte $E7,$83
                .byte $CE,$E7
                .byte $E7,$32
                .byte $19,$7D
                .byte $19,$7D
                .byte $19,$7D
poly26Vertices  .byte $0A
                .byte $00,$00
                .byte $19,$E7
                .byte $00,$83
                .byte $00,$83
                .byte $00,$83
                .byte $E7,$E7
                .byte $E7,$19
                .byte $00,$7D
                .byte $00,$7D
                .byte $00,$7D
poly27Vertices  .byte $08
                .byte $00,$00
                .byte $4B,$00
                .byte $00,$83
                .byte $00,$83
                .byte $00,$83
                .byte $B5,$00
                .byte $00,$7D
                .byte $00,$7D
poly28Vertices  .byte $06
                .byte $00,$00
                .byte $19,$E7
                .byte $00,$83
                .byte $E7,$E7
                .byte $E7,$19
                .byte $00,$7D
poly29Vertices  .byte $08
                .byte $00,$00
                .byte $19,$CE
                .byte $19,$9C
                .byte $E7,$9C
                .byte $E7,$CE
                .byte $E7,$32
                .byte $E7,$64
                .byte $19,$64
poly30Vertices  .byte $0A
                .byte $00,$00
                .byte $32,$E7
                .byte $19,$CE
                .byte $CE,$83
                .byte $CE,$83
                .byte $CE,$83
                .byte $83,$32
                .byte $32,$7D
                .byte $32,$7D
                .byte $32,$7D
poly31Vertices  .byte $08
                .byte $00,$00
                .byte $64,$E7
                .byte $00,$83
                .byte $00,$83
                .byte $E7,$83
                .byte $9C,$19
                .byte $00,$7D
                .byte $00,$7D
poly32Vertices  .byte $04
                .byte $00,$00
                .byte $32,$00
                .byte $00,$CE
                .byte $CE,$00
poly33Vertices  .byte $04
                .byte $00,$00
                .byte $32,$00
                .byte $00,$83
                .byte $CE,$00
poly34Vertices  .byte $06
                .byte $00,$00
                .byte $64,$00
                .byte $00,$E7
                .byte $E7,$CE
                .byte $CE,$00
                .byte $E7,$32
poly35Vertices  .byte $07               ; unused
                .byte $00,$00
                .byte $32,$00
                .byte $32,$9C
                .byte $00,$E7
                .byte $B5,$00
                .byte $B5,$00
                .byte $00,$19

;--------------------------------------
                .fill 245,$00
;--------------------------------------
