#include includes\keyboard.asm
#include includes\video.asm
#include includes\clock.asm
#include includes\strings.asm
#include includes\ball.asm
#include includes\paddles.asm
#include includes\state-handler.asm
#include includes\data.asm


    #ORG 0x080000
    
    CALL .InitializeVideo           ; Initialize the video
    CALL .InitializeClock           ; Initialize the clock time
    CALL .InitializeFonts           ; Font and static strings setup
    
; Setup game variables
.ResetGame                          ; Called when we want to fully reset
    CALL .ResetScore
    CALL .ResetBallServe
    
    CALL .PrepareNewGame

; Primary Game loop screen
.MainGameScreen 
    ; Update clock routine for frame delta time
    CALL .HasUpdateTimePassed       ; Updates the clock and also returns whether it passed the target frame time
    JR NZ, .MainGameScreen          ; We loop back until the allowed timeframe is reached

    CALL .Update                    ; Figure out the state
    CALL .Draw                      ; Render objects from state

    CALL .IsUserExiting
    JR Z, .ExitProgram

    JP .MainGameScreen

.ExitProgram
    RET


.PrepareNewGame                       ; Called between rounds to reset only some variables
    ; Check scores to see if we have a winner
    CALL .CheckForWinners
    CALL .SetDefaultPaddlePositions
    CALL .InitializeBall

    RET