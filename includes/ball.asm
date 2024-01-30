.UpdateBallY2
    ; Base ball movement
    LD BC, (.BallYPosition)             ; Load the Y position
    LD DE, (.BallYSpeed)                ; Load the Y delta
    LD F, (.BallYDirection)             ; Load the Y sign (going up or down)

    RET




.UpdateBallY
    ; Base ball movement
    LD BC, (.BallYPosition)                 ; Load the Y position
    LD DE, (.BallYSpeed)                ; Load the Y delta
    LD F, (.BallYDirection)                ; Load the Y sign (going up or down)
    CP F, 0x00                      ; Check if the ball is moving up or down, 0 is down
    CALL EQ, .UpdateBallY_down      ; Move the ball either up or down
    CALL NE, .UpdateBallY_up

    ; Handle Out Of Bounds
    LD DE, (.TopMargin)             ; Load the top margin for Out-of-bounds
    CP BC, DE
    JR LTE, .UpdateBallY_oob_top    ; If the ball's top is touching the OOB

    LD FG, (.BottomMargin)
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
    LD (.BallYPosition), BC                 ; Write the new Y position
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
    LD BC, (.BallXPosition)                 ; Ball left edge
    LD DE, (.BallXPosition)                 ; Ball right edge
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
    LD BC, (.BallXPosition)                 ; Ball left edge
    LD DE, (.BallXPosition)                 ; Ball right edge
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
    LD A, (.BallYDirection)                ; Loads the ball delta Y sign
    XOR A, 1                        ; Invert the bit
    LD (.BallYDirection), A                ; Store the inverted sign
.UpdateBallY_ret
    RET


.UpdateBallX
    LD BC, (.BallXSpeed)                ; Load the ball X delta
    LD DE, (.LeftMargin)              ; Load the left limit
    LD FG, (.RightMargin)             ; Load the right limit
    LD HIJ, .BallXPosition          ; Address to the X position
    LD KLM, .BallXDirection         ; Address to the X direction
    
    ; Handle left-right wall collisions
    CALL .SetUpdatedDirection

    RET

; Evaluate ball direction on X or Y
; BC - speed for given axis
; DE - (-1) screen limit
; FG - (1) screen limit
; HIJ - axis coordinate address reference
; KLM - axis direction address reference
.SetUpdatedDirection
    PUSH A, M
    LD A, (KLM)                     ; Load the ball X or Y direction

    SMUL BC, A                      ; Multiply speed with direction
    ADD16 (HIJ), BC                 ; Add effective direction*speed to current X position
    LD BC, (HIJ)                    ; Get X coordinate

    CP BC, DE
    LDF D, 0b01000000               ; Get the GT flag
    CP BC, FG
    LDF E, 0b10000000               ; Get the LT flag
    OR D, E                         ; Mix the flags
    CP D, 0b11000000                ; Check the GT (min), LT (max) flags. If both set, it means...
    JR Z, .noDirectionChange        ; ... the direction is unchanged

    DEC A                           ; Turns FF (-1) into 1...
    INV A                           ; ... or 1 into -1 (FF)
    LD (KLM), A                     ; Update the new direction

.noDirectionChange
    POP A, M
    RET
