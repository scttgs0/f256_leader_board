
;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

;--------------------------------------
;   Game State

GameState_BASE          .byte $00

isSwingDisabled         .byte FALSE
counterDemo             .byte $00
numPlayers              .fill 4,$00

joystick                .word $0000
joystickOverride        .word $0000

dirty_9C0B              .fill 3,$00
unused_9C0E             .byte $00
unused_9C0F             .byte $00

;   16 timers; timer 11+ used for audio
timerIsActive           .fill 16,$00
timerRemaining          .fill 16,$00
timerDuration           .fill 16,$00

unused_9C40             .fill 40,$00

golferSwingFrame        .byte $00
golferSwingFrameMax     .byte $00

gaugeValue              .byte $00       ; swing gauge: [0:15] power incr, [16:31] power decr/timing, [32:48] snap
gaugeStage              .byte $00       ; swing gauge: 0=inactive, 1=ascending, 2=descending, 3=snap
cacheGaugeValue         .fill 3,$00     ; swing gauge: 0=ascending, 1=descending, 2=snap
cacheTimer16bit_HI      .fill 3,$00     ; swing gauge: 0=ascending, 1=descending, 2=snap
cacheTimer16bit_LO      .fill 3,$00     ; swing gauge: 0=ascending, 1=descending, 2=snap

activePlayer            .byte $00
tempC                   .byte $00       ; idxCourse_honor_scale_temp
pixelMask               .byte $00
strokeCount             .byte $00
holeOnesDigit           .byte $00

unused_9C7A             .fill 134,$00

isSwingInProgress       .byte FALSE
swingAnimCounter        .byte $00

isSnapLocked            .byte FALSE
isPowerLocked           .byte FALSE
idxActiveHole           .byte $00
snapValue               .byte $00       ; snap value [0:14]
activeClub              .byte $00
powerValue              .byte $00       ; power value [-1,[0:15]]

windVelocity            .byte $00       ; [$00:07]
windDirection           .byte $00       ; [$00:FF]

idxActiveCourse         .byte $00
gameLength              .byte $00
nextPlayerHonorRank     .byte $00

playerInUse             .fill 4,$00     ; =1,1,1,0
playerDistUnit          .fill 4,$00     ; =0,0,0,0

playerDistanceToPin_LO  .fill 4,$00     ; =0,0,0,0
playerDistanceToPin_HI  .fill 5,$00     ; =0,0,0,0

alwaysZero              .byte $00       ; =0
playerClub              .fill 4,$00     ; =0,0,0,0
xPosCup_LO              .byte $00       ; =0
holeInfoPuttRadius_LO   .byte $00       ; =0

                        .fill 2,$00     ; =0,0

aimPosition             .byte $00
unused_9D28             .byte $00
temp9D29                .byte $00,$00
temp9D29_delta          .byte $00
isSwingAnimCounterActive
                        .byte FALSE
accuracyPenalty         .byte $00

                        .byte $00

polyVertX_LO            .byte $00       ;
polyVertZ_LO            .byte $00       ; triplet
polyVertY_LO            .byte $00       ;

polyVertZ_delta         .byte $00
temp9D33_puttX_LO       .byte $00
distanceYards_LO        .byte $00
temp9D35_puttY_LO       .byte $00
arrDeferredSum          .fill 3,$00

puttX_LO                .byte $00
puttY_LO                .byte $00

xTransform              .byte $00       ;
yTransform              .byte $00       ; triplet
zTransform              .byte $00       ;

flags_BallVisible       .byte $00

                        .byte $00

const_60                .byte $00

animSplashFrame         .fill 6,$00

polyVertCount           .byte $00

                        .fill 4,$00

newVertZ_LO             .byte $00

                        .fill 2,$00

newVertX_LO             .byte $00

                        .byte $00

polyVertX_HI            .byte $00       ;
polyVertZ_HI            .byte $00       ; triplet
polyVertY_HI            .byte $00       ;

aimPosition_HI          .byte $00
xPosCup_HI              .byte $00

                        .byte $00

temp9D57_puttX_HI       .byte $00
distanceYards_HI        .byte $00
temp9D59_puttY_HI       .byte $00

nStage                  .byte $00

polyVertX_LO_2          .byte $00       ;
polyVertZ_LO_2          .byte $00       ; triplet
polyVertY_LO_2          .byte $00       ;

polyVertX_HI_2          .byte $00       ;
polyVertZ_HI_2          .byte $00       ; triplet
polyVertY_HI_2          .byte $00       ;

holeInfoPuttRadius_HI   .byte $00
idxDistanceUnit         .byte $00
unused_9D63             .byte $00
puttX_HI                .byte $00
puttY_HI                .byte $00
unused_9D66             .byte $00
isBackSwingAnim         .fill 3,$00
offscreenPlane          .byte $00

idxPlayerName
idxPolygonVertex        .byte $00

physics_delta           .word $0000
idxWork                 .byte $00

                        .fill 2,$00

isTeeOffDone            .byte FALSE
unused_9D72             .word $0000
unused_9D74             .byte $00
unused_9D75             .byte $00
flags_9D76              .byte $00
nodeOperation           .byte $00       ; 0=operPIXEL, 1=operFILL, 2=operSHADOW_BALL
isSwapped               .byte FALSE

lineNode0_VertX_flags   .byte $00       ; 1=xMax, 2=xMin
lineNode1_VertX_flags   .byte $00       ; 1=xMax, 2=xMin

rc3_lineNode0_deltaZ    .byte $00
rc3_lineNode1_deltaZ    .byte $00
rc3_lineNodeN_deltaZ    .byte $00

accumDistance           .byte $00
renderLineX             .byte $00
lineNode1_isClipped     .byte FALSE
flagsBall_9D81          .byte $00
unused_9D82             .byte $00
flagsBall_9D83          .byte $00
const_0x700             .word $0000
lineNode0_isClipped     .byte FALSE
polygonOperation        .byte $00       ; 0=OUTLINE, 1=FILL

windDirThisHole_LO      .byte $00
windDirThisHole_LO_9D89 .byte $00
hole_windDir_LO         .byte $00
playerWindDirection_LO  .fill 4,$00

                        .fill 16,$00

isDrivingRange          .byte FALSE
lineNode0_pairDC_DE_2   .byte $00
yPosNewBallShadow       .byte $00

deltaWind_m40_p80       .byte $00
deltaWind_p00_p50       .byte $00
windVelThisHole         .byte $00

cursorFlash             .byte $00
idxInputBuffer          .byte $00
charToPlot              .byte $00

tblCourseIndexes        .fill 4,$00

newMissileY0            .byte $00       ;
newMissileY1            .byte $00       ; triplet
newMissileX             .byte $00       ;

flagsBall_9DAF          .byte $00
ballController          .byte $00

;--------------------------------------
                .fill 79,$00
;--------------------------------------
