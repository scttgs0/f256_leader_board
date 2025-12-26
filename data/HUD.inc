
offsetByCourse          .byte $00,$48,$90,$D8   ; =0,72,144,216     (18*4=72)
yCoordinateByHonor      .byte $04,$08,$0C,$10   ; =4,8,12,16

playerStrokes           .fill 18,$00    ; Nora=7,6,3,4,4
                        .fill 18,$00    ; Adam=4,5,3,5,4
                        .fill 18,$00    ; Paul=5,4,3,4,4
                        .fill 18,$00

playerScoreA_LO         .fill 4,$00     ; =$18,$15,$14,0    score LO    [offset:+72]
playerScoreA_HI         .fill 4,$00     ; =0,0,0,0          score HI

playerScoreB_LO         .fill 4,$00     ; =0,0,0,0
playerScoreB_HI         .fill 4,$00     ; =0,0,0,0

;---

playerScoreRoundA_LO    .fill 4,$00     ; =$18,$15,$14,0    score LO
playerScoreRoundA_HI    .fill 4,$00     ; =0,0,0,0          score HI

playerScoreRoundB_LO    .fill 4,$00     ; =0,0,0,0
playerScoreRoundB_HI    .fill 4,$00     ; =0,0,0,0

playerScoreRoundC_LO    .fill 4,$00     ; =0,0,0,0
playerScoreRoundC_HI    .fill 4,$00     ; =0,0,0,0

playerScoreRoundD_LO    .fill 4,$00     ; =0,0,0,0
playerScoreRoundD_HI    .fill 4,$00     ; =0,0,0,0

playerScoreTotal_LO     .fill 4,$00     ; =$18,$15,$14,0    score LO
playerScoreTotal_HI     .fill 4,$00     ; =0,0,0,0          score HI

;---

playerHonorA            .fill 4,$00     ; =2,1,0,0          honor rank
playerHonorB            .fill 4,$00     ; =2,1,0,0          honor rank working copy
playerStrokeCount       .fill 4,$00     ; =4,4,4,0          strokes this hole
playerHonorPrior        .fill 4,$00     ; =1,2,0,0

courseOffset            .word $0000     ; =$0015
idxPlayer               .byte $00       ; =$FF
idxDigit                .byte $00       ; =4
tempB                   .byte $00       ; =3
playerNames             .fill 8,$00     ; =$2E,$2F,$32,$21 (NORA)
                        .fill 8,$00     ; =$21,$24,$21,$2D (ADAM)
                        .fill 8,$00     ; =$30,$21,$35,$2C (PAUL)
                        .fill 8,$00
playerNameMaxLen        .byte $08,$08,$08,$08
arr5Digits              .byte $00,$00,$00,$00,$00
glyphPlusMinus          .byte $00
