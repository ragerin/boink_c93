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
    LD AB, 00216
    LD (.PaddleAX), AB
    LD (.PaddleBX), AB
    
    RET

.InitializeBall
    LD AB, 00237
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
    LD (.BallDXS), A

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


; Game memory
.PaddleAX
    #DB 0x0000
.PaddleBX
    #DB 0x0000
.PaddleAY
    #DB 0010
.PaddleBY
    #DB 00250
.PaddleASpeed
    #DB 004
.PaddleBSpeed
    #DB 004
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
    #DB 001
.BallDXS
    #DB 0x00                        ; sign: 0x00 positive, 0x01 negative
.BallY
    #DB 0030
.BallDY
    #DB 002
.BallDYS
    #DB 0x00                        ; sign: 0x00 positive, 0x01 negative

.WallLeft
    #DB 0010
.WallRight
    #DB 00470
.OOBTop
    #DB 005                         ; 5 from the top of the screen
.OOBBottom
    #DB 00265                       ; 5 from the bottom of the screen

.ScoreA
    #DB 48, 0                       ; Using 48 as 0 to easily display as text
.ScoreB
    #DB 48, 0


; Fonts and strings
.FontFile
    #DB "fonts\DoctorJack.font", 0
.FontData
    #DB [1142] 0                     ; Reserve bytes for the font data

.StringTitle
    #DB "BOINK v0.1", 0
.StringControls
    #DB "Z = left   X = right", 0
.StringWinPointer
    #DB 0x000000
.StringAWin
    #DB "Computer wins!", 0
.StringBWin
    #DB "Player wins!", 0
.StringPlayAgain
    #DB "Press Y to play again, ESC to exit!", 0


; Colors
.BGColor
    #DB 0245

.StringColor
    #DB 19

.UserRequestsExit
    #DB 0
