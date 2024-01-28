#include includes\keyboard.asm
#include includes\video.asm
#include includes\clock.asm
#include includes\strings.asm
#include includes\ball.asm
#include includes\paddles.asm
#include includes\state-handler.asm
#include includes\data.asm


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
    CALL .ResetScore
    CALL .ResetBallServe
    
.StartNewGame                       ; Called between rounds to reset only some variables
    ; Check scores to see if we have a winner
    CALL .CheckForWinners
    CALL .SetDefaultPaddlePositions
    CALL .InitializeBall

    JP .MainGameScreen


; Primary Game loop screen
.MainGameScreen 
    ; Update clock routine for frame delta time
    CALL .HasUpdateTimePassed       ; Updates the clock and also returns whether it passed the target frame time
    JR NZ, .MainGameScreen        ; We loop back until the allowed timeframe is reached
    
    ; Figure out the state
    CALL .Update

    ; Render objects from state
    CALL .Draw

    JP .MainGameScreen

.ExitProgram
    RET

