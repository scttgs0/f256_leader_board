
;======================================
;
;======================================
ApplyWindAffect .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

polyVertX_delta         .word $0000
polyVertY_delta         .word $0000

distanceToPinFeet       .word $0000     ; HI-byte=feet; LO-byte=inches
distanceToPinNatural    .word $0000     ; unit specified in idxDistanceUnit

distanceToPinFeet2      .word $0000     ; HI-byte=feet; LO-byte=inches
distanceToPinNatural2   .word $0000     ; unit specified in idxDistanceUnit


;======================================
;
;======================================
ProcessStroke   .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

playerVertX_LO          .fill 4,$00
playerVertX_HI          .fill 4,$00

playerVertY_LO          .fill 4,$00
playerVertY_HI          .fill 4,$00

playerWindDirection_HI  .fill 4,$00
playerIsReady           .fill 4,$00

xPosCup                 .word $0000
yPosCup                 .word $0000


;======================================
;
;======================================
RenderHUDCourse .proc
                rts
                .endproc


;======================================
;
;======================================
DrawMarkers     .proc
                rts
                .endproc


;======================================
;
;======================================
CalcTeeoff      .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

windDirThisHole_HI_2424 .byte $00
distanceAdjusted        .word $0000


;======================================
;
;======================================
AdjustForWind   .proc
                rts
                .endproc
