.InitializeVideo
    LD A, 0x02                          ; SetVideoPagesCount
    LD B, 0x03                          ; Pages count
                                        ; 0 = bg, 1 = objects, 2 = ui
    INT 0x01, A                         ; Video interrupt

    CALL .ClearBG
    CALL .ClearObjects
    CALL .ClearUI
    RET


.ClearBG
    LD A, 0x05                          ; ClearVideoPage
    LD B, 0                             ; Page 0
    LD C, (.BGColor)                    ; Color
    INT 0x01, A                         ; Video interrupt
    RET

.ClearObjects
    LD A, 0x05                          ; ClearVideoPage
    LD B, 1                             ; Page 1
    LD C, 0x00                          ; Color
    INT 0x01, A                         ; Video interrupt
    RET

.ClearUI
    LD A, 0x05                          ; ClearVideoPage
    LD B, 2                             ; Page 2
    LD C, 0x00                          ; Color
    INT 0x01, A                         ; Video interrupt
    RET

; Colors
.BGColor
    #DB 0245

