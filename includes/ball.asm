; Checks whether any paddles get in contact
; with the ball and inverts the direction if so
.CheckPaddleCollision
    ; Check for player A
    LD AB, (.PaddleAX)
    LD EF, (.PaddleAWidth)
    
    CALL .CheckPaddleXCollision
    JR NZ, .noPaddleACollision

    LD CD, (.PaddleAY)
    ADD16 CD, (.PaddleHeight)
    INC CD
    CALL .CheckPaddleYCollision

    JR GTE, .noPaddleACollision

    CALL .InvertBallDirection

.noPaddleACollision
    ; Check for player B
    LD AB, (.PaddleBX)
    LD EF, (.PaddleBWidth)

    CALL .CheckPaddleXCollision
    JR NZ, .noPaddleBCollision

    LD CD, (.PaddleBY)
    SUB16 CD, (.BallSize)
    CALL .CheckPaddleYCollision

    JR LTE, .noPaddleBCollision

    CALL .InvertBallDirection
.noPaddleBCollision
    RET


; Z set if X between paddle x limits
.CheckPaddleXCollision
    ADD EF, AB
    INC EF                  ; Calculated maximum X

    SUB16 AB, (.BallSize)
    INC AB                  ; Calculated minimum X
    
    LD GH, (.BallXPosition)

    CP GH, AB
    LDF K, 0b01000000               ; Get the GT flag
    CP GH, EF
    LDF L, 0b10000000               ; Get the LT flag
    OR K, L
    SR K, 6
    CP K, 3

    RET


.CheckPaddleYCollision
    LD IJ, (.BallYPosition)                   ; Calculated minimum Y
    CP IJ, CD

    RET


.UpdateBallY
    LD BC, (.BallYSpeed)            ; Load the ball Y delta
    LD DE, (.TopMargin)             ; Load the top limit
    LD FG, (.BottomMargin)          ; Load the bottom limit
    LD HIJ, .BallYPosition          ; Address to the Y position
    LD KLM, .BallYDirection         ; Address to the Y direction
    
    LD N, (KLM)                     ; Previous direction
    ; Handle top-bottom
    CALL .SetUpdatedDirection
    CP A, N
    JR Z, .updateYExit
    CALL Z, .PlayerAWins
    CALL NZ, .PlayerBWins
.updateYExit

    RET


.UpdateBallX
    LD BC, (.BallXSpeed)            ; Load the ball X delta
    LD DE, (.LeftMargin)            ; Load the left limit
    LD FG, (.RightMargin)           ; Load the right limit
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
    RET


.PlayerBWins
    INC (.ScoreB)
    CALL .InvertBallDirection
    CALL .PrepareNewGame
    RET

.PlayerAWins
    INC (.ScoreA)
    CALL .PrepareNewGame
    RET


.InvertBallDirection
    LD A, (.BallYDirection)         ; Update the new direction
    DEC A                           ; Turns FF (-1) into 1...
    INV A                           ; ... or 1 into -1 (FF)
    LD (.BallYDirection), A         ; Update the new direction

    RET
