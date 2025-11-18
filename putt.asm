
;======================================
;
;======================================
PuttControl     .proc
                rts
                .endproc


;--------------------------------------
; render the putt power gauge
;--------------------------------------
RenderPuttGauge .proc
                rts
                .endproc


;======================================
;
;======================================
PuttInput       .proc
                rts
                .endproc


;======================================
;
;======================================
SwitchToPutt    .proc
                rts
                .endproc


;======================================
;
;======================================
Swing_3E71      .proc
                rts
                .endproc


;======================================
;
;======================================
EnsurePuttXPositive .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
ResetPuttX      .proc
                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
EnsurePuttXPositive_FF .proc
                rts
                .endproc


;--------------------------------------
;--------------------------------------

puttY_LO_3FE9               .byte $00
puttX_LO_3FEA               .byte $00
cupPosX_HI_2_3FEB           .byte $00

lineNode1_WorkB_27DC_2      .byte $00
lineNode1_pairDC_DE_HI_2    .byte $00
maskedPixelValue            .byte $00
