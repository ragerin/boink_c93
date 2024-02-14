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
.PaddleAWidth
    #DB 0048
.PaddleBWidth
    #DB 0048
.PaddleHeight
    #DB 0010

.BallSize
    #DB 005
.BallXPosition
    #DB 00237
.BallXSpeed
    #DB 001
.BallXDirection
    #DB 0xFF                        ; 0xFF: -1 (left), 0x01: 1 (right)
.BallYPosition
    #DB 0030
.BallYSpeed
    #DB 002         
.BallYDirection
    #DB 0xFF                        ; 0xFF: -1 (up), 0x01: 1 (down)

.LeftMargin
    #DB 0010
.RightMargin
    #DB 00470
.TopMargin
    #DB 0010                         ; 5 from the top of the screen
.BottomMargin
    #DB 00260                       ; 5 from the bottom of the screen

.ScoreA
    #DB 48, 0                       ; Using 48 as 0 to easily display as text
.ScoreB
    #DB 48, 0

.GameOver                           ; 0 is false, 1 is true
    #DB 0


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
