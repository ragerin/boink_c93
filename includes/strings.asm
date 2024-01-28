.InitializeFonts
    ; Load the font
    LD A, 0x07                      ; LoadFile
    LD BCD, .FontFile               ; Font file to be loaded
    LD EFG, .FontData               ; Deposit data at .FontData
    INT 0x04, A                     ; FS interrupt
    RET

.DrawStaticStrings
    ; Draw all the static strings
    LD EFG, .StringControls
    LD HI, 190
    LD JK, 261
    LD L, (.StringColor)
    CALL .DrawString
    
    LD EFG, .StringTitle            ; The address of the null terminated string
    LD HI, 1                        ; X coordinate
    LD JK, 1                        ; Y coordinate
    LD L, (.StringColor)            ; Color
    CALL .DrawString
    RET

.DrawScores
    LD EFG, .ScoreA
    LD HI, 10
    LD JK, 50
    LD L, (.StringColor)
    CALL .DrawString

    LD EFG, .ScoreB
    LD HI, 455
    LD JK, 255
    LD L, (.StringColor)
    CALL .DrawString
    RET

.DrawGameOverString
    LD EFG, (.StringWinPointer)     ; Loads the 3 byte address stored in memory
    LD HI, 200
    LD JK, 50
    LD L, (.StringColor)
    CALL .DrawString
    CALL .DrawPlayAgainString

    ; Manually draw the video frames to the render buffer
    VDL 0b00000111
    
    RET

.DrawPlayAgainString
    LD EFG, .StringPlayAgain
    LD HI, 130
    LD JK, 80
    LD L, (.StringColor)
    CALL .DrawString
    RET

; Routine to draw text
; EFG are the address of a null terminated string
; HI and JK are X and Y coordinates
; L is the color
.DrawString
    LD A, 0x12                      ; DrawString
    LD BCD, .FontData               ; The address of the font to use
    LD M, 2                         ; Video page
    INT 0x01, A                     ; Video interrupt
    RET
