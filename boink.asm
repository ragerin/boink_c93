#include ..\..\lib\c93-keyboard.asm
#include includes\video.asm
#include includes\clock.asm
#include includes\strings.asm

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

    JP .MainLoop


; Primary Game loop screen
.MainLoop
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
    
    JP .MainLoop


; Game over screen
.PaddleAWins
    LD PQR, .StringAWin             ; Load the string address
    LD (.StringWinPointer), PQR     ; Store the value in the pointer value
    JP .PaddleWin
.PaddleBWins
    LD PQR, .StringBWin             ; Load the string address
    LD (.StringWinPointer), PQR     ; Store the value in the pointer value
    JP .PaddleWin
.PaddleWin
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

    JP .PaddleWin


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

    ; Manually draw the video frames to the render buffer
    VDL 0b00000111

    RET


.UpdateCompPaddle
    ; Make the computer sometimes wait a cycle
    RAND A, 16                       
    CP A, 2
    JP LTE, .UpdateCompPaddle_ret

    LD BC, (.BallX)                 ; Load the ball x
    LD DE, (.PaddleAX)              ; Load the paddle left edge
    ADD DE, 5                       ; Shrink it a bit
    LD FG, (.PaddleAX)              ; Load the paddle right edge
    ADD16 FG, (.PaddleASize)
    ADD FG, 5                       ; Shrink it a bit

    CP BC, DE
    JP LT, .UpdateCompPaddle_left   ; Move the paddle left

    CP BC, FG
    JP GT, .UpdateCompPaddle_right  ; Move the paddle right

    JP .UpdateCompPaddle_ret

.UpdateCompPaddle_left
    CALL .MovePaddleALeft
    JP .UpdateCompPaddle_ret
.UpdateCompPaddle_right
    CALL .MovePaddleARight
.UpdateCompPaddle_ret
    RET


.RenderGameObjects
    CALL .ClearObjects
    CALL .DrawPaddles
    CALL .DrawBall
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

.DrawUI
    ; Clear the UI page
    CALL .ClearUI
    CALL .DrawStaticStrings
    CALL .DrawScores
    RET


.UpdateBallY
    ; Base ball movement
    LD BC, (.BallY)                 ; Load the Y position
    LD DE, (.BallDY)                ; Load the Y delta
    LD F, (.BallDYS)                ; Load the Y sign (going up or down)
    CP F, 0x00                      ; Check if the ball is moving up or down, 0 is down
    CALL EQ, .UpdateBallY_down      ; Move the ball either up or down
    CALL NE, .UpdateBallY_up

    ; Handle Out Of Bounds
    LD DE, (.OOBTop)                ; Load the top margin for Out-of-bounds
    CP BC, DE
    JR LTE, .UpdateBallY_oob_top    ; If the ball's top is touching the OOB

    LD FG, (.OOBBottom)
    SUB16 FG, (.BallSize)           ; Subtract the ball size, to check from its bottom
    CP BC, FG
    JR GTE, .UpdateBallY_oob_bottom ; If the ball's bottom is touching the OOB

    ; Handle paddle collision
    ; A
    LD DE, (.PaddleAY)
    ADD16 DE, (.PaddleHeight)
    CP BC, DE
    CALL LTE, .UpdateBallY_paddleAhit
    ; B
    LD DE, (.PaddleBY)
    SUB16 DE, (.BallSize)
    CP BC, DE
    CALL GTE, .UpdateBallY_paddleBhit

    ; Else, we just keep moving the ball
    LD (.BallY), BC                 ; Write the new Y position
    RET
.UpdateBallY_down
    ADD BC, DE
    RET
.UpdateBallY_up
    SUB BC, DE
    RET
.UpdateBallY_oob_top
    LD AB, (.ScoreB)
    INC A
    LD (.ScoreB), AB
    JP .ContinueGame
.UpdateBallY_oob_bottom
    LD AB, (.ScoreA)
    INC A
    LD (.ScoreA), AB
    JP .ContinueGame

.UpdateBallY_paddleAhit
    PUSH BC                         ; Store the Y value
    LD BC, (.BallX)                 ; Ball left edge
    LD DE, (.BallX)                 ; Ball right edge
    ADD16 DE, (.BallSize)
    LD FG, (.PaddleAX)              ; Paddle left edge
    LD HI, (.PaddleAX)              ; Paddle right edge
    ADD16 HI, (.PaddleASize)
    ; ADD16 HI, (.BallSize)           ; Increase PRE to allow right edge hits
    SUB HI, 1
    CALL .UpdateBallY_paddle_collision
    POP BC
    RET
.UpdateBallY_paddleBhit
    PUSH BC                         ; Store the Y value
    LD BC, (.BallX)                 ; Ball left edge
    LD DE, (.BallX)                 ; Ball right edge
    ADD16 DE, (.BallSize)
    LD FG, (.PaddleBX)              ; Paddle left edge
    LD HI, (.PaddleBX)              ; Paddle right edge
    ADD16 HI, (.PaddleBSize)
    ADD16 HI, (.BallSize)           ; Increase PRE to allow right edge hits
    SUB HI, 1
    CALL .UpdateBallY_paddle_collision
    POP BC
    RET
.UpdateBallY_paddle_collision
    LD Z, 0                         ; Set up flag counter for AND-ing the left-right checks

    ; Check ball's left edge is within paddle right edge
    LD LM, HI                       ; Copy PRE for math
    SUB LM, BC                      ; PRE - BLE
    CALL SP, .UpdateBallY_flag_inc  ; Increase the flag if positive

    ; Check ball's right edge is within paddle left edge
    LD JK, DE                       ; Copy BRE for math
    SUB JK, FG                      ; BRE - PLE
    CALL SP, .UpdateBallY_flag_inc  ; Increase the flag if positive
    
    CP Z, 2                         ; Compare the flag counter
    JP GTE, .UpdateBallY_bounce
    
    JP .UpdateBallY_ret
.UpdateBallY_flag_inc
    INC Z
    RET
.UpdateBallY_bounce
    LD A, (.BallDYS)                ; Loads the ball delta Y sign
    XOR A, 1                        ; Invert the bit
    LD (.BallDYS), A                ; Store the inverted sign
.UpdateBallY_ret
    RET


.UpdateBallX
    LD BC, (.BallX)                 ; Load the ball X position
    LD DE, (.BallDX)                ; Load the ball X delta
    LD F, (.BallDXS)                ; Load the ball X delta sign

    CP F, 0x00                      ; Check if the sign is 0 positive, or 1 negative
    CALL EQ, .UpdateBallX_right     ; Add or sub depending on the sign
    CALL NE, .UpdateBallX_left

    ; Handle wall collisions
    LD DE, (.WallLeft)              ; Load the left limit
    LD FG, (.WallRight)             ; Load the right limit
    SUB16 FG, (.BallSize)           ; Sub the ball size
    CP BC, DE                       ; Compare new X with left limit
    JR LTE, .UpdateBallX_bounce     ; Bounce off the wall
    CP BC, FG                       ; Compare new X with right limit
    JR GTE, .UpdateBallX_bounce     ; Bounce off the wall

    LD (.BallX), BC                 ; Store the new X position in memory
    RET
.UpdateBallX_right
    ADD BC, DE
    RET
.UpdateBallX_left
    SUB BC, DE
    RET
.UpdateBallX_bounce
    LD A, (.BallDXS)                ; Loads the ball delta x sign
    XOR A, 1                        ; Invert the bit
    LD (.BallDXS), A                ; Store the inverted sign
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

; TODO: DRY these routines
.MovePaddleARight
    LD BC, (.PaddleAX)              ; Load the paddle X
    LD DE, (.PaddleASpeed)          ; Load the speed
    LD FG, (.PaddleASize)
    LD HIJ, .PaddleAX
    CALL .MovePaddleRight
    RET
.MovePaddleALeft
    LD BC, (.PaddleAX)              ; Load the paddle X
    LD DE, (.PaddleASpeed)          ; Load the speed
    LD FG, (.PaddleASize)
    LD HIJ, .PaddleAX
    CALL .MovePaddleLeft
    RET
.MovePaddleBRight
    LD BC, (.PaddleBX)              ; Load the paddle X
    LD DE, (.PaddleBSpeed)          ; Load the speed
    LD FG, (.PaddleBSize)
    LD HIJ, .PaddleBX
    CALL .MovePaddleRight
    RET
.MovePaddleBLeft
    LD BC, (.PaddleBX)              ; Load the paddle X
    LD DE, (.PaddleBSpeed)          ; Load the speed
    LD FG, (.PaddleBSize)
    LD HIJ, .PaddleBX
    CALL .MovePaddleLeft
    RET


; Moves the paddles
; BC is the current X
; DE is the movement speed
; FG is the paddle size
; HIJ is the memory address for the paddle X position
.MovePaddleRight
    ADD BC, DE

    ; Check right wall collision
    LD DE, (.WallRight)
    SUB DE, FG
    CP BC, DE
    JR GT, .MovePaddle_ret

    LD (HIJ), BC                    ; Store the new X
    RET
.MovePaddleLeft
    SUB BC, DE
    
    ; Check left wall collision
    LD DE, (.WallLeft)
    CP BC, DE
    JR LT, .MovePaddle_ret

    LD (HIJ), BC                    ; Store the new X
    RET
.MovePaddle_ret
    RET


.ExitProgram
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
