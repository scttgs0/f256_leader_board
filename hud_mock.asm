
;======================================
;
;======================================
RenderHUD       .proc
                jsr RenderHUDPAR        ; draw hole# and PAR
                jsr RenderHUDCourse     ; draw course#
                jsr RenderHUDPlayers    ; draw player summary

                .frsTextXY 31, 1,$70,RenderHUD._scrnCourse
                .frsTextXY 38, 1,$10,RenderHUD._scrnCourseVal

                .frsTextXY 31, 2,$70,RenderHUD._scrnHole
                .frsTextXY 37, 2,$10,RenderHUD._scrnHoleVal

                .frsTextXY 31, 4,$70,RenderHUD._scrnPAR
                .frsTextXY 38, 4,$90,RenderHUD._scrnPARVal

                .frsTextXY 31,13,$70,RenderHUD._scrnWinds

                .frsTextXY 31,17,$30,RenderHUD._scrnClub
                .frsTextXY 37,17,$90,RenderHUD._scrnClubVal

                .frsTextXY 31,18,$30,RenderHUD._scrnYards
                .frsTextXY 37,18,$90,RenderHUD._scrnDistVal

                .frsTextXY 31,20,$70,RenderHUD._scrnPowerTop
                .frsTextXY 31,21,$70,RenderHUD._scrnPowerBot
                .frsTextXY 33,20,$80,RenderHUD._scrnPower
                .frsTextXY 30,22,$70,RenderHUD._scrnSnapLeft
                .frsTextXY 31,22,$70,RenderHUD._scrnSnapTop
                .frsTextXY 32,22,$70,RenderHUD._scrnSnapRight
                .frsTextXY 31,23,$70,RenderHUD._scrnSnapBot
                .frsTextXY 33,22,$30,RenderHUD._scrnSnap

                rts

;--------------------------------------

_scrnHole       .null "HOLE #"
_scrnHoleVal    .null " 2"
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
_scrnPowerTop   .null $C7
_scrnPowerBot   .null $C8

_scrnSnap       .null "SNAP"
_scrnSnapTop    .null $C7
_scrnSnapBot    .null $C8
_scrnSnapLeft   .null $C9
_scrnSnapRight  .null $CA

                .endproc


;======================================
;
;======================================
RenderHUDPlayers .proc
                .frsTextXY 31, 6,$F0,RenderHUDPlayers._scrnName

                .frsTextXY 31, 8,$10,RenderHUDPlayers._scrnP1
                .frsTextXY 34, 8,$10,RenderHUDPlayers._scrnP1Strokes
                .frsTextXY 38, 8,$30,RenderHUDPlayers._scrnP1Delta

                .frsTextXY 30, 9,$F0,RenderHUDPlayers._scrnActive
                .frsTextXY 31, 9,$F0,RenderHUDPlayers._scrnP2
                .frsTextXY 34, 9,$10,RenderHUDPlayers._scrnP2Strokes
                .frsTextXY 38, 9,$80,RenderHUDPlayers._scrnP2Delta

                .frsTextXY 31,10,$10,RenderHUDPlayers._scrnP3
                .frsTextXY 34,10,$10,RenderHUDPlayers._scrnP3Strokes
                .frsTextXY 38,10,$F0,RenderHUDPlayers._scrnP3Delta

                .frsTextXY 31,11,$10,RenderHUDPlayers._scrnP4
                .frsTextXY 34,11,$10,RenderHUDPlayers._scrnP4Strokes
                .frsTextXY 38,11,$10,RenderHUDPlayers._scrnP4Delta

                rts

;--------------------------------------

_scrnName       .null "ADAM"

_scrnP1         .null "1"
_scrnP1Strokes  .null "1"
_scrnP1Delta    .null "-1"

_scrnActive     .null $FA
_scrnP2         .null "2"
_scrnP2Strokes  .null "1"
_scrnP2Delta    .null " E"

_scrnP3         .null "3"
_scrnP3Strokes  .null "1"
_scrnP3Delta    .null "+1"

_scrnP4         .null "4"
_scrnP4Strokes  .null " "
_scrnP4Delta    .null "  "

                .endproc
