#include ..\..\lib\c93-keyboard.asm
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
    ; Reset the scores
    LD A, 48
    LD B, 0
    LD (.ScoreA), AB
    LD (.ScoreB), AB
    ; Reset the serve
    LD A, 0x00
    LD (.BallDYS), A
.ContinueGame                       ; Called between rounds to reset only some variables
    ; Check scores to see if we have a winner
    LD AB, (.ScoreA)
    CP A, 58                        ; Reached 10 points
    JP EQ, .PaddleAWins
    LD AB, (.ScoreB)
    CP A, 58                        ; Reached 10 points
    JP EQ, .PaddleBWins

    ; Reset positions
    LD AB, 00216
    LD (.PaddleAX), AB
    LD (.PaddleBX), AB
    LD AB, 00237
    LD (.BallX), AB

    ; Check who has the serve by looking at the Y sign
    LD A, (.BallDYS)
    CP A, 0
    JP EQ, .ResetGame_a_serve       ; 0 is moving down, so A serves
    LD AB, 00240                    ; Or we set the ball up for B
    JP .ResetGame_end
.ResetGame_a_serve
    LD AB, 0025                     ; Set the ball up for A
.ResetGame_end
    LD (.BallY), AB
    
    RAND A, 2                       ; Randomize X direction
    LD (.BallDXS), A

    JP .MainGameScreen


; Primary Game loop screen
.MainGameScreen
    ; Keyboard input
    CALL .InputUpdate 

    ; Exit with escape
    LD A, 27                        ; Escape key
    CALL .InputKeyPressed
    
    CP A, 1
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
    CP A, 1
    JR Z, .ExitProgram

    LD A, 89                        ; Y for restarting the game
    CALL .InputKeyPressed
    CP A, 1
    JP EQ, .ResetGame

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
    CP A, 1
    CALL Z, .MovePaddleBLeft
    LD A, 88                        ; X
    CALL .InputKeyPressed
    CP A, 1
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

