#include includes\keyboard.asm
#include includes\video.asm
#include includes\clock.asm
#include includes\strings.asm
#include includes\ball.asm
#include includes\paddles.asm
#include includes\state-handler.asm
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
    ; Update clock routine for frame delta time
    CALL .HasUpdateTimePassed       ; Updates the clock and also returns whether it passed the target frame time
    JR NZ, .MainGameScreen        ; We loop back until the allowed timeframe is reached
    
    ; This is the fixed cycle update routine, which is called as uniformly as possible
    ; to maintain a near-fixed update rate
    
    ; Update keyboard input
    CALL .InputUpdate
    CALL .UpdateUserExitFlag

    CALL .IsUserExiting
    JR Z, .ExitProgram

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
    CALL .UpdateUserExitFlag        ; Esc to escape

    LD A, 27                        ; Escape key
    CALL .InputKeyPressed
    JP Z, .ResetGame

    LD A, 89                        ; Y for restarting the game
    CALL .InputKeyPressed
    JP Z, .ResetGame

    CALL .DrawGameOverString        ; Draw the game over strings
    
    VDL 0b00000111                  ; Manually draw the video frames to the render buffer

    JP .PaddleWinScreen





.ExitProgram
    RET

