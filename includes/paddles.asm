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
