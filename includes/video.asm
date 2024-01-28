.InitializeVideo
    CALL .InitRenderer
    CALL .ClearBG
    CALL .ClearObjects
    CALL .ClearUI
    RET

.InitRenderer
    LD A, 0x02                          ; SetVideoPagesCount
    LD B, 0x03                          ; Pages count (0 = background, 1 = objects, 2 = UI)
    INT 0x01, A                         ; Video interrupt

    ; Sets the video buffer control mode to manual so we can update the video buffers 
    ; only when the scene is complete (with a VDL - video draw layers instruction)
    LD A, 0x33
    LD B, 0b00000000                    ; All layers to manual (0)
    INT 0x01, A                         ; Video interrupt

    RET

.ClearBG
    LD A, 0x05                      ; ClearVideoPage
    LD B, 0                         ; Page 0
    LD C, (.BGColor)                ; Color
    INT 0x01, A                     ; Video interrupt
    RET
.ClearObjects
    LD A, 0x05                      ; ClearVideoPage
    LD B, 1                         ; Page 1
    LD C, 0x00                      ; Color
    INT 0x01, A                     ; Video interrupt
    RET
.ClearUI
    LD A, 0x05                      ; ClearVideoPage
    LD B, 2                         ; Page 2
    LD C, 0x00                      ; Color
    INT 0x01, A                     ; Video interrupt
    RET


.RenderGameObjects
    CALL .ClearObjects
    CALL .DrawPaddles
    CALL .DrawBall
    RET

.DrawPaddles
    ; Shared
    LD A, 0x06                      ; DrawFilledRectangle
    LD B, 1                         ; Video page
    LD IJ, (.PaddleHeight)          ; Height
    LD K, 100                       ; Color
    ; A
    LD CD, (.PaddleAX)              ; X position top left
    LD EF, (.PaddleAY)              ; Y position top left
    LD GH, (.PaddleASize)           ; Width
    INT 0x01, A                     ; Video interrupt
    ; B
    LD CD, (.PaddleBX)              ; X position top left
    LD EF, (.PaddleBY)              ; Y position top left
    LD GH, (.PaddleBSize)           ; Width
    INT 0x01, A                     ; Video interrupt

    RET

.DrawBall
    LD A, 0x06                      ; DrawFilledRectangle
    LD B, 1                         ; Video page
    LD CD, (.BallX)                 ; X position top left
    LD EF, (.BallY)                 ; Y position top left
    LD GH, (.BallSize)              ; Width
    LD IJ, (.BallSize)              ; Height
    LD K, 100                       ; Color
    INT 0x01, A                     ; Video interrupt
    RET

.DrawUI
    ; Clear the UI page
    CALL .ClearUI
    CALL .DrawStaticStrings
    CALL .DrawScores
    RET
