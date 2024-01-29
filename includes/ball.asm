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
    JP .StartNewGame
.UpdateBallY_oob_bottom
    LD AB, (.ScoreA)
    INC A
    LD (.ScoreA), AB
    JP .StartNewGame

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
    LD F, (.BallXDirection)         ; Load the ball X direction
    
    SMUL DE, F                      ; Multiply speed with direction
    ADD BC, DE                      ; Add effective direction*speed to current X

    ; Handle wall collisions
    LD DE, (.WallLeft)              ; Load the left limit
    LD FG, (.WallRight)             ; Load the right limit

    CP BC, DE
    LDF D, 0b01000000               ; Get the GT flag
    CP BC, FG
    LDF E, 0b10000000               ; Get the LT flag
    OR D, E                         ; Mix the flags
    INV D                           ; Invert so we get the LTE and GTE flags instead of GT and LT
    SR D, 6                         ; shift the flags so we can only get 10 or 01 (1 or 2)
    CP D, 0
    JR Z, .NoDirectionChange

    INV D                           ; Invert bits, so 00000010 becomes 11111101 and 00000001 becomes 11111110
    ADD D, 3                        ; Add 3 so 11111101 becomes 0 and 11111110 becomes 1
    MUL D, 2                        ; transform that to 0 and 2
    DEC D                           ; and again it can get to -1 and 1

    LD (.BallXDirection), D

.NoDirectionChange
    LD (.BallX), BC                 ; Store the new X position in memory
    RET
