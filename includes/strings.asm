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
    LD JK, 262
    LD L, 15
    CALLR .DrawString
    
    LD EFG, .StringTitle            ; The address of the null terminated string
    LD HI, 1                        ; X coordinate
    LD JK, 1                        ; Y coordinate
    LD L, 200                       ; Color
    CALLR .DrawString

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


; Fonts and strings
.FontFile
    #DB "fonts\CleanCut.font", 0
.FontData
    #DB [952] 0                     ; Reserve 952 bytes for the font data

.StringTitle
    #DB "BOINK v1", 0
.StringControls
    #DB ", = left   . = right", 0