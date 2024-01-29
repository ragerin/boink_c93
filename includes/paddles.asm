.UpdateCompPaddle
    ; Make the computer sometimes wait a frame
    RAND A, 6                       
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

.MovePaddleALeft
    LD A, -1
    CALLR .MovePaddleA
    RET

.MovePaddleARight
    LD A, 1
    CALLR .MovePaddleA
    RET


.MovePaddleBLeft
    LD A, -1
    CALLR .MovePaddleB
    RET

.MovePaddleBRight
    LD A, 1
    CALLR .MovePaddleB
    RET


; A should contain -1 for left and 1 for right
.MovePaddleA
    LD HIJ, .PaddleAX
    LD BC, (HIJ)              ; Load the paddle X
    LD DE, (.PaddleASpeed)          ; Load the speed
    LD FG, (.PaddleASize)
    CALL .MovePaddle
    RET

.MovePaddleB
    LD HIJ, .PaddleBX
    LD BC, (HIJ)              ; Load the paddle X
    LD DE, (.PaddleBSpeed)          ; Load the speed
    LD FG, (.PaddleBSize)
    CALL .MovePaddle
    RET

.MovePaddle
    SMUL DE, A              ; Multiply the speed with the direction (sign)
    ADD BC, DE              

    ; Check right wall collision
    LD DE, (.WallRight)
    SUB DE, FG
    CP BC, DE
    JR GT, .movePaddle_exit

    ; Check left wall collision
    LD DE, (.WallLeft)
    CP BC, DE
    JR LT, .movePaddle_exit

    LD (HIJ), BC                    ; Store the new X
    RET

.movePaddle_exit
    RET
