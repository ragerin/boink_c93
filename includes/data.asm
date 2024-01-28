.ResetScore
    LD A, 48
    LD B, 0
    LD (.ScoreA), AB
    LD (.ScoreB), AB

    RET

.SetDefaultPositions
    LD AB, 00216
    LD (.PaddleAX), AB
    LD (.PaddleBX), AB
    LD AB, 00237
    LD (.BallX), AB

    RET

.CheckForWinners
    LD AB, (.ScoreA)
    CP A, 50                        ; Reached 2 points
    JP EQ, .PaddleAWins
    LD AB, (.ScoreB)
    CP A, 50                        ; Reached 2 points
    JP EQ, .PaddleBWins

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
