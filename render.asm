
;======================================
;
;--------------------------------------
; on entry:
;   idxPolygon
;======================================
RenderPolygon   .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   idxPolygon
;======================================
RenderMudLayer  .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   Y           polygon vertex index
; on exit:
;   polyVertX_LO/HI
;   polyVertY_LO/HI
;======================================
FetchFromPolygonBuf .proc
                rts
                .endproc


;======================================
;
;======================================
SetLINE_ProcessLine .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   lineNode0_VertX_LO
;   lineNode0_VertZ_LO
;   lineNode1_VertX_LO
;   lineNode1_VertZ_LO
; on exit:
;   processLineResult
;======================================
ProcessLine     .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

processLineDelta        .word $0000

arrProcessLine_delta    .byte $00,$00

accum_HI                .byte $00
accum_LO                .byte $00

lineNode0_VertX_LO      .byte $00
lineNode0_VertZ_LO      .byte $00

lineNode1_VertX_LO      .byte $00
lineNode1_VertZ_LO      .byte $00

arrProcessLine          .byte $00,$00

pixelColor              .byte COLOR_BLACK


;======================================
; Render course polygons
;   _OUTLINE    draw mud banks
;   _FILL       draw turf
;======================================
RenderCourse    .proc
_OUTLINE
                rts
                .endproc


;======================================
; Render polygon fill
;======================================
RenderFill      .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
; on entry:
;   X           xPos
;   Y           yPos
;--------------------------------------
RenderPixel     .proc
                rts
                .endproc


;======================================
;
;======================================
PopulateWorkQueue .proc
                rts
                .endproc


;======================================
;
;======================================
QueueWorkNode0  .proc
                rts
                .endproc


;======================================
;
;======================================
QueueWorkNode1  .proc
                rts
                .endproc


;======================================
; Render black outline on top layer of
; polygon (a prerequisite for fill)
;======================================
RenderPolyTopEdge .proc
_BLACK
_COLOR          rts
                .endproc


;======================================
;
;======================================
RenderPolyFill  .proc
                rts
                .endproc


;======================================
;
;======================================
FetchFromWorkQueue .proc
                rts
                .endproc


;======================================
;
;======================================
SetSHADOW_ProcessLine .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   arrProcessLine[0]
;   processLineResult
;   nodeOperation
;   idxPolygonVertex
;   bufCourseWorkVertY
;   lineNode0_VertX_LO
;   lineNode0_VertZ_LO
;======================================
RenderNodes     .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           new xPos
;   Y           new yPos
; on exit:
;   zpFD        pixel pointer
;   pixelMask   new value
;======================================
GetPixelPtrMask .proc
                rts
                .endproc


;======================================
; Transform 3D-coordinate by the View
; Projection
;--------------------------------------
; on entry:
;   X           keyframe #
;======================================
VertexTransform .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           xPos
;   Y           yPos
; on exit:
;   Y           =0
;   pixelMask   new value
;======================================
GetPixelPtrInvMask .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

arrPixelMask    .byte $3F,$CF,$F3,$FC,$00
idxPixel_0to3   .byte $00
pixelValue      .byte $00
