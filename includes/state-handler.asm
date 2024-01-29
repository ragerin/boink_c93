.Update
    ; This is the fixed cycle update routine, which is called as uniformly as possible
    ; to maintain a near-fixed update rate
    
    ; Paddle A movement (computer)
    CALL .UpdateCompPaddle

    ; Update keyboard input
    CALL .InputUpdate
    CALL .UpdateUserExitFlag

    ; Paddle B movement
    LD A, 90                        ; Z key
    CALL .InputKeyPressed
    CALL Z, .MovePaddleBLeft
    LD A, 88                        ; X key
    CALL .InputKeyPressed
    CALL Z, .MovePaddleBRight

    ; Update the ball position
    CALL .UpdateBallX
    CALL .UpdateBallY

    RET

; TODO unwind this
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


.ResetScore
    LD A, 48
    LD B, 0
    LD (.ScoreA), AB
    LD (.ScoreB), AB

    RET

.ResetBallServe
    ; Reset the serve
    LD A, 0x00
    LD (.BallDYS), A

    RET

.SetDefaultPaddlePositions
    LD AB, 216
    LD (.PaddleAX), AB
    LD (.PaddleBX), AB
    
    RET

.InitializeBall
    LD AB, 237
    LD (.BallX), AB
    ; Check who has the serve by looking at the Y sign
    LD A, (.BallDYS)
    CP A, 0
    JP EQ, .ResetGame_a_serve       ; 0 is moving down, so A serves
    LD AB, 240                      ; Or we set the ball up for B
    JP .ResetGame_end
.ResetGame_a_serve
    LD AB, 25                       ; Set the ball up for A
.ResetGame_end
    LD (.BallY), AB
    
    RAND A, 2                       ; Randomize X direction
    MUL A, 2
    SUB A, 1
    LD (.BallXDirection), A

    RET

.CheckForWinners
    LD AB, (.ScoreA)
    CP A, 50                        ; Reached 2 points
    JP EQ, .PaddleAWins
    LD AB, (.ScoreB)
    CP A, 50                        ; Reached 2 points
    JP EQ, .PaddleBWins

    RET


.UpdateUserExitFlag
    PUSH A
    LD A, 27                        ; Escape key
    CALL .InputKeyPressed
    JR NZ, .updateUserExitFlagExit
    LD A, 1
    LD (.UserRequestsExit), A
    POP A
.updateUserExitFlagExit
    RET

.IsUserExiting
    PUSH A
    LD A, (.UserRequestsExit)
    CP A, 1
    POP A
    RET