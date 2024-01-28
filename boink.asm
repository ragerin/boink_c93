#include includes\keyboard.asm
#include includes\video.asm
#include includes\clock.asm
#include includes\strings.asm
#include includes\ball.asm
#include includes\paddles.asm
#include includes\data.asm


    #ORG 0x080000
    
    ; Initialize the video
    CALL .InitializeVideo

    ; Initialize the clock time
    CALL .InitializeClock
    
    ; Font and static strings setup
    CALL .InitializeFonts
    
    ; Setup game variables
    JP .ResetGame

.ResetGame                          ; Called when we want to fully reset
    CALL .ResetScore
    CALL .ResetBallServe
    
.StartNewGame                       ; Called between rounds to reset only some variables
    ; Check scores to see if we have a winner
    CALL .CheckForWinners
    CALL .SetDefaultPaddlePositions
    CALL .InitializeBall

    JP .MainGameScreen


; Primary Game loop screen
.MainGameScreen
    ; Update keyboard input
    CALL .InputUpdate 

    ; Exit with escape
    LD A, 27                        ; Escape key
    CALL .InputKeyPressed
    JR Z, .ExitProgram
    
    ; Update clock routine for frame delta time
    CALL .UpdateClock
    CP A, 1                         ; Check if we are ready to do fixed frame work
    CALL EQ, .FixedUpdate           ; We call the FixedUpdate routine
    
    JP .MainGameScreen


; Game over screen
.PaddleAWins
    LD PQR, .StringAWin             ; Load the string address
    LD (.StringWinPointer), PQR     ; Store the value in the pointer value
    JP .PaddleWinScreen
.PaddleBWins
    LD PQR, .StringBWin             ; Load the string address
    LD (.StringWinPointer), PQR     ; Store the value in the pointer value
    JP .PaddleWinScreen
.PaddleWinScreen
    ; Keyboard input
    CALL .InputUpdate 

    ; Exit with escape
    LD A, 27                        ; Escape key
    CALL .InputKeyPressed
    JR Z, .ExitProgram

    LD A, 89                        ; Y for restarting the game
    CALL .InputKeyPressed
    JP Z, .ResetGame

    CALL .DrawGameOverString        ; Draw the game over strings
    
    VDL 0b00000111                  ; Manually draw the video frames to the render buffer

    JP .PaddleWinScreen


; This is the fixed cycle update routine, which is called as uniformly as possible
; to maintain a near-fixed update rate
.FixedUpdate
    ; Paddle A movement (computer)
    CALL .UpdateCompPaddle

    ; Paddle B movement
    LD A, 90                        ; Z
    CALL .InputKeyPressed
    CALL Z, .MovePaddleBLeft
    LD A, 88                        ; X
    CALL .InputKeyPressed
    CALL Z, .MovePaddleBRight

    ; Update the ball position
    CALL .UpdateBallX
    CALL .UpdateBallY

    ; Render objects
    CALL .RenderGameObjects

    ; Render UI
    CALL .DrawUI

    VDL 0b00000111                  ; Manually draw the video frames to the render buffer

    RET


.ExitProgram
    RET

