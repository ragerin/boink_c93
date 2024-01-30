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
    LD B, 0                         ; Page 0
    LD C, (.BGColor)                ; Color
    JP .clearPage
.ClearObjects
    LD B, 1                         ; Page 1
    LD C, 0x00                      ; Color
    JP .clearPage
.ClearUI
    LD B, 2                         ; Page 2
    LD C, 0x00                      ; Color
    JP .clearPage

.clearPage
    LD A, 0x05                      ; ClearVideoPage
    INT 0x01, A                     ; Video interrupt
    RET


.Draw
    CALL .ClearObjects
    CALL .ClearUI

    CALL .DrawPaddles
    CALL .DrawBall
    ; Draw the UI
    CALL .DrawStaticStrings
    CALL .DrawScores

    VDL 0b00000111                  ; Manually draw the video frames to the render buffer
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
    LD GH, (.PaddleAWidth)           ; Width
    INT 0x01, A                     ; Video interrupt
    ; B
    LD CD, (.PaddleBX)              ; X position top left
    LD EF, (.PaddleBY)              ; Y position top left
    LD GH, (.PaddleBWidth)           ; Width
    INT 0x01, A                     ; Video interrupt

    RET

.DrawBall
    LD A, 0x06                      ; DrawFilledRectangle
    LD B, 1                         ; Video page
    LD CD, (.BallXPosition)                 ; X position top left
    LD EF, (.BallYPosition)                 ; Y position top left
    LD GH, (.BallSize)              ; Width
    LD IJ, (.BallSize)              ; Height
    LD K, 100                       ; Color
    INT 0x01, A                     ; Video interrupt
    RET
