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

    ; Update the ball position
    CALLR .UpdateBallX
    CALLR .CheckBallXCollision

    ; Render objects
    CALLR .DrawGameOjbects

    RET


.CheckXCollision
    ; BC is the X value to check
    ; DE is the left limit
    ; FG is the right limit
    ; A is 1 if inside, 0 if out
    CP BC, DE
    JP LT, .CheckXCollisionOut      ; X is left of left limit
    CP BC, FG
    JP GT, .CheckXCollisionOut      ; X is right of right limit
    LD A, 0x01                      ; ... else we're within
    RET
.CheckXCollisionOut
    LD A, 0x00                      ; ... or we're out
    RET


.DrawGameOjbects
    ; Clear the game objects
    LD A, 0x05                      ; ClearVideoPage
    LD B, 1                         ; Page 1
    LD C, 0x00                      ; Color
    INT 0x01, A                     ; Video interrupt
    CALLR .DrawPaddles
    CALLR .DrawBall
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

.UpdateBallX
    LD BC, (.BallX)                 ; Load the ball X position
    LD DE, (.BallDX)                ; Load the ball X delta
    LD F, (.BallDXS)                ; Load the ball X delta sign

    CP F, 0x00                      ; Check if the sign is 0 positive, or 1 negative
    CALLR EQ, .UpdateBallX_add      ; Add or sub depending on the sign
    CALLR NE, .UpdateBallX_sub
    LD (.BallX), BC                 ; Store the new X position in memory
    RET

.UpdateBallX_add
    ADD BC, DE
    RET
.UpdateBallX_sub
    SUB BC, DE
    RET

.CheckBallXCollision
    LD BC, (.BallX)                 ; Load the ball X position
    LD DE, 10                       ; Left limit
    LD FG, 465                      ; Right limit
    CALLR .CheckXCollision
    CP A, 0x01
    JR NE, .InvertBallDXS           ; Ball is out of the field, so invert DXS
    RET
.InvertBallDXS
    LD A, (.BallDXS)
    XOR A, 1
    LD (.BallDXS), A
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

.MovePaddleARight
    LD BC, (.PaddleAX)              ; Load the paddle X
    LD DE, (.PaddleASpeed)          ; Load the speed

    ADD BC, DE
    ; TODO: Bounding check

    LD (.PaddleAX), BC              ; Store the new X
    RET
.MovePaddleALeft
    LD BC, (.PaddleAX)              ; Load the paddle X
    LD DE, (.PaddleASpeed)          ; Load the speed

    SUB BC, DE
    ; TODO: Bounding check

    LD (.PaddleAX), BC              ; Store the new X
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

.BallSize
    #DB 005
.BallX
    #DB 00237
.BallDX
    #DB 005
.BallDXS
    #DB 0x00                        ; sign: 0x00 positive, 0x01 negative
.BallY
    #DB 0025
.BallDY
    #DB 005
.BallDYS
    #DB 0x00                        ; sign: 0x00 positive, 0x01 negative

.WallLeft