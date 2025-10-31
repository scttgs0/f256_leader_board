
;======================================
;
;======================================
RenderHUD       .proc
                jsr RenderHUDPAR        ; draw hole# and PAR
                jsr RenderHUDCourse     ; draw course#
                jsr RenderHUDPlayers    ; draw player summary

                .frsTextXY 31, 0,$70,RenderHUD._scrnCourse
                .frsTextXY 39, 0,$10,RenderHUD._scrnCourseVal

                .frsTextXY 31, 2,$70,RenderHUD._scrnHole
                .frsTextXY 38, 2,$10,RenderHUD._scrnHoleVal

                .frsTextXY 31, 4,$70,RenderHUD._scrnPAR
                .frsTextXY 39, 4,$90,RenderHUD._scrnPARVal

                .frsTextXY 31,13,$70,RenderHUD._scrnWinds

                .frsTextXY 31,17,$30,RenderHUD._scrnClub
                .frsTextXY 37,17,$90,RenderHUD._scrnClubVal

                .frsTextXY 31,18,$30,RenderHUD._scrnYards
                .frsTextXY 37,18,$90,RenderHUD._scrnDistVal

                .frsTextXY 33,20,$80,RenderHUD._scrnPower
                .frsTextXY 33,22,$30,RenderHUD._scrnSnap

                rts

;--------------------------------------

_scrnHole       .null "HOLE #"
_scrnHoleVal    .null " 1"
_scrnPAR        .null "PAR"
_scrnPARVal     .null "4"
_scrnCourse     .null "COURSE"
_scrnCourseVal  .null "1"

_scrnWinds      .null "WINDS"

_scrnClub       .null "CLUB"
_scrnClubVal    .null "1W"

_scrnYards      .null "YARDS"
_scrnFeet       .null "FEET"
_scrnInches     .null "INCHES"
_scrnDistVal    .null "134"

_scrnPower      .null "POWER"
_scrnSnap       .null "SNAP"

                .endproc


;======================================
;
;======================================
RenderHUDPAR    .proc
                rts
                .endproc


;======================================
;
;======================================
RenderHUDCourse .proc
                rts
                .endproc


;======================================
;
;======================================
RenderHUDPlayers .proc
                rts
                .endproc
