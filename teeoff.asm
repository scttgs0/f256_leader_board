
;======================================
;
;======================================
SetStage2_TeeOff .proc
                rts
                .endproc


;======================================
;
;======================================
InitStroke      .proc
                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           snapValue
;======================================
CalcAccuracyPenalty .proc
                rts
                .endproc


;======================================
;
;======================================
SetTimer6       .proc
                rts
                .endproc


;======================================
;
;======================================
CalcTravelDistanceYards .proc
                rts
                .endproc


;======================================
;
;======================================
Swing_math_326F .proc
                rts
                .endproc


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
                jsr PlayNextHole

                jsr PrepareCourse
                jsr RenderHUD
                jsr RenderPlayfield         ; refresh the course background

                ;jsr MainLoop         ; HACK:

                jsr RenderCourse._OUTLINE   ; draw polygon outlines
                jsr RenderSodPatch          ; sod patch under the golfer
                jsr RenderFill              ; draw polygon fills

                jsr RenderCupOrPin
                jsr DrawMarkers

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
DrawMarkers     .proc
                lda isTeeOffDone        ; at the tee box?
                beq _1                  ;   yes

                rts                     ;   no, don't draw the tee box markers

; - - - - - - - - - - - - - - - - - - -
_1              ldx #stageTEEOFF
                stx nStage

                ldy #$17                ; left marker [6,23]
                ldx #$06
                jsr CalcPixelAddr

                lda #$00                ; blue marker
                jsr PlotChar

                ldx #$17                ; right marker [23,23]
                ldy #$17
                jsr CalcPixelAddr

                lda #$00                ; blue marker
                jmp PlotChar

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
