
;======================================
;
;--------------------------------------
; on entry:
;   idxActiveHole
;======================================
PrepareCourse   .proc
                rts
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
                rts
                .endproc


;======================================
;
;======================================
GetPtrHoleInfo  .proc
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
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   A           polygon index
;======================================
GetPtrPolygon   .proc
                rts
                .endproc


;======================================
;
;======================================
GetPolygonOffset .proc
                rts
                .endproc


;======================================
; calculate the array offset for the
; start of the specified course
;======================================
GetCourseOffset .proc
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
