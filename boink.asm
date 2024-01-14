#include ..\..\lib\c93-keyboard.asm
#include includes\video.asm
#include includes\clock.asm
#include includes\strings.asm

    #ORG 0x080000

    ; Initialize the video
    CALLR .InitializeVideo

    ; Initialize the clock time
    CALLR .InitializeClock
    
    ; Font and static strings setup
    CALLR .InitializeFonts
    CALLR .DrawStaticStrings
    
    JP .MainLoop


.MainLoop
    ; Keyboard input
    CALLR .InputUpdate 

    ; Exit with escape
    LD A, 27                        ; Escape key
    CALLR .InputKeyPressed
    CP A, 1
    JR Z, .ExitProgram

    ; Update clock routine for frame delta time
    CALLR .UpdateClock
    CP A, 1                         ; Check if we are ready to do fixed frame work
    CALLR EQ, .FixedUpdate          ; We call the FixedUpdate routine
    
    JP .MainLoop


.FixedUpdate
    ; Paddle A movement
    LD A, 188                       ; Comma
    CALLR .InputKeyPressed
    CP A, 1
    CALLR Z, .MovePaddleALeft
    LD A, 190                       ; Period
    CALLR .InputKeyPressed
    CP A, 1
    CALLR Z, .MovePaddleARight

    ; Render objects
    CALL .DrawPaddles

    RET

.DrawPaddles
    ; Clear the game objects
    LD A, 0x05                      ; ClearVideoPage
    LD B, 1                         ; Page 1
    LD C, 0x00                      ; Color
    INT 0x01, A                     ; Video interrupt

    ; Draw the paddles
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

.MovePaddleARight
    LD BC, (.PaddleAX)              ; Load the paddle X
    LD DE, (.PaddleASpeed)          ; Load the speed

    ADD BC, DE
    ; TODO: Bounding check

    LD (.PaddleAX), BC
    RET

.MovePaddleALeft
    LD BC, (.PaddleAX)              ; Load the paddle X
    LD DE, (.PaddleASpeed)          ; Load the speed

    SUB BC, DE
    ; TODO: Bounding check

    LD (.PaddleAX), BC
    RET


.ExitProgram
    RET


; Game memory
.PaddleAX
    #DB 00216
.PaddleBX
    #DB 00216
.PaddleAY
    #DB 00250
.PaddleBY
    #DB 0010
.PaddleASpeed
    #DB 008
.PaddleBSpeed
    #DB 008
.PaddleASize
    #DB 0048
.PaddleBSize
    #DB 0048
.PaddleHeight
    #DB 0010
