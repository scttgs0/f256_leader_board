
;======================================
;
;======================================
DoConfig        .proc
                jsr ResetHW
                jsr DrawScoreboard
                jsr DrawCredits

_ENTRY1         jsr DrawDialog
                jsr SetTimer0._32

                jsr BeginConfig
                jsr AskPlayerQty
                jsr AskPlayerNames
                jsr AskGameLength
                jsr AskCourseSelection

_ENTRY2         jmp ClearScore

                .endproc


;======================================
;
;======================================
BeginConfig     .proc
                ldx #stageCONFIG
                stx nStage

                ldx #$00                ; number of players
                jmp AskForConfig

                .endproc


;======================================
;
;======================================
AskPlayerQty    .proc
_next1          jsr StartPokeyTimers

;   clock + 10 seconds (BCD)
                lda clockSecs
                sed
                adc #$10
                cmp #$60                ; <60?
                bcc _1                  ;   yes

                sec                     ;   no, subtract 60
                sbc #$60

_1              cld
                sta zpD4

_next2          lda clockSecs
                cmp zpD4                ; 10 seconds elapsed?
                bne _2                  ;   no

;   /// D - Demo ///
_demo           ldx #$01
                stx counterDemo
                stx tblPlayerAbility    ; skillAMATEUR

                dex                     ; X=0
                stx numPlayers
                stx gameLength
                stx tblCourseIndexes
                stx idxActiveCourse

                pla                     ; discard (DoConfig) return address
                pla
                rts

; - - - - - - - - - - - - - - - - - - -
_2              jsr GetKeycode

                cmp #$74                ; T-key?
                bne _3                  ;   no

;   /// T - Time Counter ///
                jsr SetCurrentTime
                jsr DrawDialog
                jsr BeginConfig
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_3              cmp #$64                ; D-key?
                bne _4                  ;   no
                jmp _demo

; - - - - - - - - - - - - - - - - - - -
_4              cmp #$94                ; SHIFT-RETURN-key?
                bne _5                  ;   no

;   /// SHIFT-ENTER - Load Supplement ///
                jsr LoadSupplement
                jmp _next1

; - - - - - - - - - - - - - - - - - - -
_5              cmp #$70                ; P-key?
                bne _6                  ;   no

;   /// P - Replay ///
                pla                     ; discard (DoConfig) return address
                pla
                jmp DoConfig._ENTRY2

; - - - - - - - - - - - - - - - - - - -
_6              cmp #$72                ; R-key?
                bne _7                  ;   no

;   /// R - Driving Range ///
                lda #$01
                sta isDrivingRange      ; TRUE
                sta tblPlayerAbility    ; skillAMATEUR

                lda #$00
                sta gameLength
                sta idxActiveCourse
                sta numPlayers

                pla                     ; discard (DoConfig) return address
                pla
                rts

; - - - - - - - - - - - - - - - - - - -
_7              tax
                cmp #$31                ; 1-key?
                beq _10                 ;   yes

                cmp #$32                ; 2-key?
                beq _9                  ;   yes

                cmp #$33                ; 3-key?
                beq _8                  ;   yes

                cmp #$34                ; 4-key?
                bne _next2              ;   no, try again

                lda #$03
                .byte $2C               ; consume the following LDA operation
_8              lda #$02
                .byte $2C               ; consume
_9              lda #$01
                .byte $2C               ; consume
_10             lda #$00
                sta numPlayers

                rts
                .endproc


;======================================
;
;======================================
SetCurrentTime  .proc
                jsr DrawDialog
                jsr SetTimer0._32

                ldx #$06                ; time counter
                jsr AskForConfig

;   clear the input buffer
                ldx #$07
                lda #$00                ; space
                sta idxInputBuffer      ; reset the buffer index

_next1          sta inputBuffer,X

                dex
                bpl _next1

                jsr EnableCursor
_flashCursor    jsr DrawCursor

_nextInput      jsr GetKeycode

                cmp #$FF                ; any key pressed?
                beq _nextInput          ;   no

                cmp #$BC                ; RUNSTOP-key?
                bne _1                  ;   no

                jsr DisableCursor

                rts                     ;   yes

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$94                ; ENTER-key?
                beq _2                  ;   yes
                jmp _4                  ;   no

; - - - - - - - - - - - - - - - - - - -
_error          jsr DrawDialog
                jsr SetTimer0._32

                ldx #$07                ; error in time entry
                jsr AskForConfig

                jsr DisableCursor

                rts

; - - - - - - - - - - - - - - - - - - -
;   /// ENTER-key ///
_2              jsr DisableCursor

                lda inputBuffer+2
                cmp #':'                ; colon?
                bne _error              ;   no, invalid

                lda inputBuffer+5
                cmp #':'                ; colon?
                bne _error              ;   no, invalid

;   hour, tens-digit
                lda inputBuffer
                sec
                sbc #'0'                ; convert to decimal

                cmp #$0A                ; >=10?
                bcs _error              ;   yes, invalid

                asl                     ; move to upper-nibble (*16)
                asl
                asl
                asl
                sta inputBuffer

;   hour, ones-digit
                lda inputBuffer+1
                sec
                sbc #'0'                ; convert to decimal

                cmp #$0A                ; >=10?
                bcs _error              ;   yes, invalid

                ora inputBuffer         ; append to lower-nibble
                sta inputBuffer

;   minute, tens-digit
                lda inputBuffer+3
                sec
                sbc #'0'                ; convert to decimal

                cmp #$0A                ; >=10?
                bcs _error              ;   yes, invalid

                asl                     ; move to upper-nibble (*16)
                asl
                asl
                asl
                sta inputBuffer+1

;   minute, ones-digit
                lda inputBuffer+4
                sec
                sbc #'0'                ; convert to decimal

                cmp #$0A                ; >=10?
                bcs _error              ;   yes, invalid

                ora inputBuffer+1       ; append to lower-nibble
                sta inputBuffer+1

;   seconds, tens-digit
                lda inputBuffer+6
                sec
                sbc #'0'                ; convert to decimal

                cmp #$0A                ; >=10?
                bcs _error2             ;   yes, invalid

                asl                     ; move to upper-nibble (*16)
                asl
                asl
                asl
                sta inputBuffer+2

;   seconds, ones-digit
                lda inputBuffer+7
                sec
                sbc #'0'                ; convert to decimal

                cmp #$0A                ; >=10?
                bcs _error2             ;   yes, invalid

                ora inputBuffer+2       ; append to lower-nibble

                sei

                sta clockSecs
                lda inputBuffer+1
                sta clockMins
                lda inputBuffer
                sta clockHour

                cli
                rts

; - - - - - - - - - - - - - - - - - - -
_error2         jmp _error

; - - - - - - - - - - - - - - - - - - -
_4              cmp #$92                ; DELETE-key?
                bne _5                  ;   no

;   /// DELETE-key ///
                lda idxInputBuffer
                beq _nextInput2

                dec idxInputBuffer
                ldx idxInputBuffer
                lda #' '                ; space
                sta inputBuffer,X

                lda idxInputBuffer
                clc
                adc #$10
                tax
                ldy #$09                ; [16+,9]

                lda #>inputBuffer
                sta zpSource+1
                lda idxInputBuffer
                clc
                adc #<inputBuffer
                sta zpSource

                lda #$F0                ; color
                jsr PrintText

                jmp _flashCursor

; - - - - - - - - - - - - - - - - - - -
_5              lda KEYCHAR             ; get ascii
                bpl _6

_nextInput2     jmp _nextInput

; - - - - - - - - - - - - - - - - - - -
_6              cmp #';'                ; convert semicolon -> colon
                bne _7

                lda #':'

_7              sta charToPlot

                lda idxInputBuffer
                cmp #$08                ; end reached?
                beq _nextInput2         ;   yes, ignore input. Loop back as we're expecting an ENTER or DELETE

                lda charToPlot
                ldx idxInputBuffer
                sta inputBuffer,X

                lda idxInputBuffer
                clc
                adc #$10
                tax
                ldy #$09                ; [16+,9]

                lda #>inputBuffer
                sta zpSource+1
                lda idxInputBuffer
                clc
                adc #<inputBuffer
                sta zpSource

                lda #$F0                ; color
                jsr PrintText

                inc idxInputBuffer

                jmp _flashCursor

                .endproc


;======================================
;
;======================================
LoadSupplement  .proc
                jsr ResetHW

                sei

;   restore [$4C0F:4C34] -> [$0200:0225]
;!!                ldx #$25
;!!_next1          lda cacheVDSLST,X
;!!                sta VDSLST,X
;!!
;!!                dex
;!!                bpl _next1

                ;!!jsr ReadPortA           ; on return, A=%1100xxxx
                ;!!and #$70                ; [:=$40]
                ;!!sta NMIEN

                cli

;   read sectors [249:283] -> [$8200:92FF]
                ;!!lda #<$8200
                ;!!sta DBUFLO
                ;!!lda #>$8200
                ;!!sta DBUFHI

                lda #$22                ; sector count
                ldx #$F9                ; sector_LO (sector 249)
                ldy #$00                ; sector_HI
                jsr ReadSectors
                jsr SetInterrupts

                .endproc


;--------------------------------------
;--------------------------------------
;   cache of $0200:0225

cacheVDSLST     .fill 38,$00


;======================================
;
;======================================
StartPokeyTimers .proc
                ;!!sta STIMER

                rts
                .endproc


;======================================
;
;======================================
InitPlayers     .proc
                ldx numPlayers
_next1          lda #$00
                sta nextPlayerHonorRank ; honor=0 goes first
                sta playerInUse,X       ; FALSE
                sta playerStrokeCount,X ; =0
                sta playerIsReady,X     ; FALSE
                sta playerClub,X        ; 1-wood

                lda #unitYARDS
                sta playerDistUnit,X

                dex
                bpl _next1

                rts
                .endproc


;======================================
;
;======================================
ClearGameState  .proc
                ldx #$00
                txa
_next1          sta GameState_BASE,X
                sta GameState_BASE+$100,X

                inx
                bne _next1

;   HACK:
                ; lda #$06
                ; sta idxActiveHole
                ; lda #$00
                ; sta idxActiveCourse
                ; lda #$00
                ; sta tblCourseIndexes
                ; lda #unitYARDS
                ; sta playerDistUnit
                ; lda #skillPRO
                ; sta tblPlayerAbility

                ; putting mode
                ; lda #TRUE
                ; sta isTeeOffDone
                ; lda #unitFEET
                ; sta playerDistUnit
                ; lda #>$0016
                ; sta playerVertY_delta
                ; lda #<$0016
                ; sta playerVertY_delta+1
;   HACK: end

                rts
                .endproc


;--------------------------------------
;
;--------------------------------------
ClearScore      .proc
;   assign initial honor ranks based on player index
                ldx #$03
_next1          txa
                sta playerHonorPrior,X
                sta playerHonorA,X

                dex
                bpl _next1

;   clear strokes, scores, and round history
                ldx #$7F                ; [$499A == playerHonorA-1]
                .byte $2C               ; consume the following LDX operation
; - - - - - - - - - - - - - - - - - - -
;   clear strokes and scores, but leave the round history intact
_preservehistory
                ldx #$57                ; [$4972 == playerScoreRoundA_LO-1]

                lda #$00
_next2          sta playerStrokes,X     ; [$491B + X]

                dex
                bpl _next2

                jmp InitPlayers

                .endproc


;======================================
;
;======================================
ResetHW         .proc
                jsr ClearSprites

                rts
                .endproc


;======================================
;
;======================================
InitScreenHW    .proc
                rts
                .endproc


;======================================
;
;======================================
ProcessESC      .proc
                jsr GetKeycode

                cmp #$BC                ; RUNSTOP-key?
                ;;beq _1                  ;   yes       HACK: avoid issue (see below)

                rts                     ;   no

; - - - - - - - - - - - - - - - - - - -
;   /// RUNSTOP-key ///     ; HACK: this can cause problems because we have hacked the call structure
_1              pla                     ; discard (PuttControl) return address
                pla
                pla                     ; ??
                pla
                pla                     ; ??
                pla

                jsr ClearAllPlayers
                jsr ClearMissiles

                jmp NewGame

                .endproc


;======================================
;
;======================================
MarkPlayerInUse .proc
                ldx activePlayer
                lda #TRUE
                sta playerInUse,X

                lda #$00
                sta playerDistanceToPin_LO,X
                sta playerDistanceToPin_HI,X

                rts
                .endproc


;======================================
;
;======================================
DemoDistanceToPin .proc
                ldx activePlayer
                lda playerInUse,X       ; is player being used?
                bne _XIT                ;   yes

                lda distanceToPinFeet3
                sta playerDistanceToPin_LO,X
                lda distanceToPinFeet3+1
                sta playerDistanceToPin_HI,X

_XIT            rts
                .endproc


;======================================
;
;======================================
CalcHonorRanking .proc
;   clear honorA and honorB
                ldx #$07
                lda #$00
_next1          sta playerHonorA,X

                dex
                bpl _next1

;   assign honor based on strokes this hole
                ldy numPlayers
_next2          ldx numPlayers
_next3          lda playerStrokeCount,Y
                cmp playerStrokeCount,X
                bcs _1

                inc playerHonorB,X

_1              dex
                bpl _next3

                dey
                bpl _next2

;   break ties based on prior honor rank
                ldy numPlayers
_next4          ldx numPlayers
_next5          lda playerHonorB,Y
                cmp playerHonorB,X
                beq _2
                bcs _4
                bcc _3                  ; [unc]

; - - - - - - - - - - - - - - - - - - -
_2              lda playerHonorPrior,Y
                cmp playerHonorPrior,X
                bcs _4

_3              inc playerHonorA,X

_4              dex
                bpl _next5

                dey
                bpl _next4

;   replace prior honor with the new honor rankings
                ldx #$03
_next6          lda playerHonorA,X
                sta playerHonorPrior,X

                lda #$00
                sta playerStrokeCount,X

                dex
                bpl _next6

                rts
                .endproc


;======================================
;
;======================================
SetNextPlayer   .proc
                ldx numPlayers
_next1          lda playerIsReady,X     ; ready?
                bne _1                  ;   yes

                lda playerHonorPrior,X  ; does this player match the honor rank?
                cmp nextPlayerHonorRank
                bne _1                  ;   no

                inc nextPlayerHonorRank ;   yes, update the honor rank needed for the next player

                stx activePlayer        ; we found the player

                rts

; - - - - - - - - - - - - - - - - - - -
_1              dex
                bpl _next1

                ldx numPlayers
_next2          lda playerInUse,X       ; is player being used?
                beq _next3              ;   no, ignore

                dex
                bpl _next2

                pla                     ; discard (PlayNextHole) return address
                pla
                jmp GoNextHole

; - - - - - - - - - - - - - - - - - - -
_next3          ldy numPlayers
_next4          lda playerDistanceToPin_HI,X
                cmp playerDistanceToPin_HI,Y
                beq _2
                bcs _4
                bcc _3                  ; [unc]

; - - - - - - - - - - - - - - - - - - -
_2              lda playerDistanceToPin_LO,X
                cmp playerDistanceToPin_LO,Y
                bcs _4

_3              dex
                jmp _next3

; - - - - - - - - - - - - - - - - - - -
_4              dey
                bpl _next4

                stx activePlayer

                rts
                .endproc


;======================================
;
;--------------------------------------
; on entry:
;   X           index of config [0:7]
;======================================
AskForConfig    .proc
_yCoord         = zpD2
_src            = zpSource
;---

                lda #$06
                sta _yCoord             ; line number

                lda #<_configInstr
                sta _src
                lda #>_configInstr
                sta _src+1

                txa
                beq _next2

;   skip ahead 4 lines until we point to the proper instruction block
_next1          lda _src                ; skip 4 lines
                clc
                adc #<$0044
                sta _src
                lda _src+1
                adc #>$0044
                sta _src+1

                dex
                bne _next1

_next2          ldy _yCoord             ; [12,7+]
                ldx #$0C
                lda #$40                ; color
                jsr PrintText

                lda _src
                clc
                adc #<$0011
                sta _src
                lda _src+1
                adc #>$0011
                sta _src+1

                inc _yCoord
                lda _yCoord
                cmp #$0A                ; displayed 4 lines?
                bcc _next2              ;   no

                rts

;--------------------------------------

_configInstr    .null ' SELECT  NUMBER '    ; [0]
                .null '   OF PLAYERS   '
                .null '                '
                .null '   1 2 3 OR 4   '

                .null '    PLAYER      '    ; [1]
                .null '  TYPE IN NAME  '
                .null '                '
                .null '                '

                .null '    PLAYER      '    ; [2]
                .null ' P-PROFESSIONAL '
                .null ' A-AMATEUR      '
                .null ' N-NOVICE       '

                .null 'SHFT-1 18 HOLES '    ; [3]
                .null 'SHFT-2 36 HOLES '
                .null 'SHFT-3 54 HOLES '
                .null 'SHFT-4 72 HOLES '

                .null '    COURSE      '    ; [4]
                .null '                '
                .null '   1 2 3 OR 4   '
                .null '                '

                .null '                '    ; [5]
                .null '                '
                .null '                '
                .null '                '

                .null ' ENTER  CURRENT '    ; [6]
                .null '      TIME      '
                .null '                '
                .null '                '

                .null '    ERROR IN    '    ; [7]
                .null '                '
                .null '   TIME ENTRY   '
                .null '                '

                .endproc


;======================================
;
;======================================
AskPlayerNames  .proc
_ptrName        = zpF9
;---

                ldx #$00
                stx idxPlayer

_nextPlayer     lda #$00
                sta idxInputBuffer

                jsr DrawDialog
                jsr SetTimer0._32

                ldx #$01                ; player name
                jsr AskForConfig

;   clear the input buffer
                ldx #$07
_next1          lda #$00                ; space
                sta inputBuffer,X

                dex
                bpl _next1

                jsr PromptPlayer

                jsr EnableCursor
_flashCursor    jsr DrawCursor

_nextInput      jsr GetKeycode

                cmp #$FF                ; any key pressed?
                beq _nextInput          ;   no

                cmp #$BC                ; RUNSTOP-key?
                bne _1                  ;   no

;   /// RUNSTOP-key ///
                pla                     ;   yes, discard (DoConfig) return address
                pla

                jsr DisableCursor
                jmp DoConfig._ENTRY1

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$94                ; ENTER-key?
                bne _3                  ;   no

;   /// ENTER-key ///
                jsr DisableCursor

                ldx idxPlayer
                jsr SetNameBufPtr       ; result _ptrName [$F9:FA]

;   copy the input buffer -> playNames
                ldy #$07
_next2          lda inputBuffer,Y
                sta (_ptrName),Y

                dey
                bpl _next2

                jsr AskAbilityLevel

                inc idxPlayer
                lda idxPlayer
                cmp numPlayers
                beq _2
                bcc _2

                rts

; - - - - - - - - - - - - - - - - - - -
_2              jmp _nextPlayer

; - - - - - - - - - - - - - - - - - - -
_3              cmp #$92                ; DELETE-key?
                bne _4                  ;   no

;   /// DELETE-key ///
                lda idxInputBuffer
                beq _nextInput

                dec idxInputBuffer
                ldx idxInputBuffer
                lda #' '                ; space
                sta inputBuffer,X

                lda idxInputBuffer
                clc
                adc #$10
                tax
                ldy #$09                ; [16+,9]

                lda #>inputBuffer
                sta zpSource+1
                lda idxInputBuffer
                clc
                adc #<inputBuffer
                sta zpSource

                lda #$F0                ; color
                jsr PrintText

                jmp _flashCursor

; - - - - - - - - - - - - - - - - - - -
_4              lda KEYCHAR             ; get ascii
                bpl _5

_nextInput2     jmp _nextInput

; - - - - - - - - - - - - - - - - - - -
_5              sta charToPlot

                lda idxInputBuffer
                cmp #$08                ; end reached?
                beq _nextInput2         ;   yes, ignore input. Loop back as we're expecting an ENTER or DELETE

                lda charToPlot
                ldx idxInputBuffer
                sta inputBuffer,X

                lda idxInputBuffer
                clc
                adc #$10
                tax
                ldy #$09                ; [16+,9]

                lda #>inputBuffer
                sta zpSource+1
                lda idxInputBuffer
                clc
                adc #<inputBuffer
                sta zpSource

                lda #$F0                ; color
                jsr PrintText

                inc idxInputBuffer

                jmp _flashCursor

                .endproc


;--------------------------------------
;--------------------------------------

inputBuffer     .fill 9,$00

tblPlayerAbility
                .byte $00,$00,$00,$00

tblRaw2Ascii    .byte $4C,$4A,$3B,$FF,$FF,$4B,$2B,$2A
                .byte $4F,$FF,$50,$55,$FF,$49,$2D,$3D
                .byte $56,$FF,$43,$FF,$FF,$42,$58,$5A
                .byte $34,$FF,$33,$36,$FF,$35,$32,$31
                .byte $2C,$20,$2E,$4E,$FF,$4D,$2F,$FF
                .byte $52,$FF,$45,$59,$FF,$54,$57,$51
                .byte $39,$FF,$30,$37,$FF,$38,$3C,$3E
                .byte $46,$48,$44,$FF,$FF,$47,$53,$41


;======================================
;
;======================================
AskAbilityLevel .proc
                jsr DrawDialog
                jsr SetTimer0._32

                ldx #$02                ; ability level
                jsr AskForConfig
                jsr PromptPlayer

_next1          jsr GetKeycode

                cmp #$70                ; P-key?
                bne _1                  ;   no

;   /// P - Professional ///
                lda #$02
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_1              cmp #$61                ; A-key?
                bne _2                  ;   no

;   /// A - Amateur ///
                lda #$01
                jmp _3

; - - - - - - - - - - - - - - - - - - -
_2              cmp #$6E                ; N-key?
                bne _4                  ;   no

;   /// N - Novice ///
                lda #skillNOVICE
_3              ldx idxPlayer
                sta tblPlayerAbility,X

                rts

; - - - - - - - - - - - - - - - - - - -
_4              cmp #$BC                ; RUNSTOP-key?
                bne _next1              ;   no, try again

;   /// RUNSTOP-key ///
                pla                     ; discard (AskPlayerNames) return address
                pla
                pla                     ; discard (DoConfig) return address
                pla
                jmp DoConfig._ENTRY1

                .endproc


;======================================
;
;======================================
AskGameLength   .proc
                jsr DrawDialog
                jsr SetTimer0._32

                ldx #$03                ; number of holes
                jsr AskForConfig

_next1          jsr GetKeycode

                cmp #$BC                ; RUNSTOP-key?
                bne _1                  ;   no

;   /// RUNSTOP-key ///
                pla                     ; discard (DoConfig) return address
                pla

                jmp DoConfig._ENTRY1

; - - - - - - - - - - - - - - - - - - -
_1              lda KEYCHAR
                cmp #'!'                ; SHIFT-1-key?
                beq _4                  ;   yes

                cmp #'@'                ; SHIFT-2-key?
                beq _3                  ;   yes

                cmp #'#'                ; SHIFT-3-key?
                beq _2                  ;   yes

                cmp #'$'                ; SHIFT-4-key?
                bne _next1              ;   no, try again

                lda #$03                ; 72-holes
                .byte $2C               ; consume the following LDA operation
_2              lda #$02                ; 54-holes
                .byte $2C               ; consume
_3              lda #$01                ; 36-holes
                .byte $2C               ; consume
_4              lda #$00                ; 18-holes
                sta gameLength

                rts
                .endproc


;======================================
;
;======================================
AskCourseSelection .proc
                jsr DrawDialog

                lda #$00
                sta tempC

_next1          jsr DrawDialog
                jsr SetTimer0._32

                ldx #$04                ; course selection
                jsr AskForConfig
                jsr PromptCourse

_next2          jsr GetKeycode

                cmp #$BC                ; RUNSTOP-key?
                bne _1                  ;   no

                pla                     ;   yes, discard (DoConfig) return address
                pla
                jmp DoConfig._ENTRY1

; - - - - - - - - - - - - - - - - - - -
_1              cmp #'1'                ; 1-key?
                beq _4                  ;   yes

                cmp #'2'                ; 2-key?
                beq _3                  ;   yes

                cmp #'3'                ; 3-key?
                beq _2                  ;   yes

                cmp #'4'                ; 4-key?
                bne _next2              ;   no, try again

                lda #$03
                .byte $2C               ; consume the following LDA operation
_2              lda #$02
                .byte $2C               ; consume
_3              lda #$01
                .byte $2C               ; consume
_4              lda #$00
                ldx tempC
                sta tblCourseIndexes,X

                inc tempC
                lda tempC
                cmp gameLength
                beq _next1
                bcc _next1

                rts
                .endproc


;======================================
;
;======================================
PromptPlayer    .proc
                lda idxPlayer
                clc
                adc #'1'
                sta _playerNum

                .frsTextXY $17,$06,$40,PromptPlayer._playerNum

                rts

;--------------------------------------

_playerNum      .null '0'

                .endproc


;======================================
;
;======================================
PromptCourse    .proc
                lda tempC               ; index for course rotation
                clc
                adc #'1'
                sta _courseNum

                .frsTextXY $17,$06,$40,PromptCourse._courseNum

                rts

;--------------------------------------

_courseNum      .null '0'

                .endproc


;--------------------------------------
;--------------------------------------
;   dead code
DoRTS5          rts


;======================================
;
;======================================
EnableCursor    .proc
                .frsCursor TRUE
                rts
                .endproc


;======================================
;
;======================================
DisableCursor   .proc
                .frsCursor FALSE
                rts
                .endproc


;======================================
;
;======================================
DrawCursor      .proc
                lda idxInputBuffer
                clc
                adc #$10

                sta CURSOR_X
                stz CURSOR_X+1
                lda #$09
                sta CURSOR_Y
                stz CURSOR_Y+1

                stz DEBOUNCE

                rts
                .endproc


;======================================
;
;======================================
DrawDialog      .proc
                .frsTextXY 11, 5,$40,DrawDialog._msgDialog0
                .frsTextXY 11, 6,$40,DrawDialog._msgDialog1
                .frsTextXY 11, 7,$40,DrawDialog._msgDialog1
                .frsTextXY 11, 8,$40,DrawDialog._msgDialog1
                .frsTextXY 11, 9,$40,DrawDialog._msgDialog1
                .frsTextXY 11,10,$40,DrawDialog._msgDialog2

                rts

;--------------------------------------

            .enc "dialog-custom"
                .cdef " Z",$20
                .tdef "j",$E5
                .tdef "k",$E6
                .tdef "l",$E7
                .tdef "m",$E8
                .tdef "n",$E9
                .tdef "o",$EA
                .tdef "p",$EB
                .tdef "q",$EC
_msgDialog0     .null 'jkkkkkkkkkkkkkkkkl'
_msgDialog1     .null 'm                n'
_msgDialog2     .null 'oppppppppppppppppq'
            .enc "none"
                .endproc


;======================================
;
;======================================
DrawCredits     .proc
                .frsTextXY 3,11,$30,DrawCredits._msgCredits0
                .frsTextXY 3,12,$30,DrawCredits._msgCredits1
                .frsTextXY 3,13,$30,DrawCredits._msgCredits2
                .frsTextXY 3,14,$30,DrawCredits._msgCredits3
                .frsTextXY 3,15,$30,DrawCredits._msgCredits4
                .frsTextXY 3,16,$30,DrawCredits._msgCredits5
                .frsTextXY 3,17,$30,DrawCredits._msgCredits3
                .frsTextXY 3,18,$30,DrawCredits._msgCredits6
                .frsTextXY 3,19,$30,DrawCredits._msgCredits7

                rts

;--------------------------------------

            .enc "credits-custom"
                .cdef " Z",$20
                .tdef "j",$E0
                .tdef "k",$E1
                .tdef "l",$E2
                .tdef "m",$E3
                .tdef "n",$E4
_msgCredits0    .null 'jkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk'
_msgCredits1    .null 'l         COPYRIGHT 1986        l'
_msgCredits2    .null 'l     ACCESS SOFTWARE, INC.     l'
_msgCredits3    .null 'l                               l'
_msgCredits4    .null 'l           CREATED BY          l'
_msgCredits5    .null 'l     BRUCE AND ROGER CARVER    l'
                .null 'l                               l'
_msgCredits6    .null 'l      F256 ADAPTATION 2025     l'
_msgCredits7    .null 'lkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkm'
            .enc "none"

                .endproc
