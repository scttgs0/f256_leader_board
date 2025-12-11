
;======================================
;
;======================================
RenderHUDPlayers .proc
                .frsTextXY 31, 5,$F0,RenderHUDPlayers._scrnName

                .frsTextXY 31, 6,$10,RenderHUDPlayers._scrnP1
                .frsTextXY 34, 6,$10,RenderHUDPlayers._scrnP1Strokes
                .frsTextXY 38, 6,$30,RenderHUDPlayers._scrnP1Delta

                .frsTextXY 30, 7,$F0,RenderHUDPlayers._scrnActive
                .frsTextXY 31, 7,$F0,RenderHUDPlayers._scrnP2
                .frsTextXY 34, 7,$10,RenderHUDPlayers._scrnP2Strokes
                .frsTextXY 38, 7,$80,RenderHUDPlayers._scrnP2Delta

                .frsTextXY 31,8,$10,RenderHUDPlayers._scrnP3
                .frsTextXY 34,8,$10,RenderHUDPlayers._scrnP3Strokes
                .frsTextXY 38,8,$F0,RenderHUDPlayers._scrnP3Delta

                .frsTextXY 31,9,$10,RenderHUDPlayers._scrnP4
                .frsTextXY 34,9,$10,RenderHUDPlayers._scrnP4Strokes
                .frsTextXY 38,9,$10,RenderHUDPlayers._scrnP4Delta

                rts

;--------------------------------------

_scrnName       .null "ADAM    "

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
