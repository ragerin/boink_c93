#include ..\..\lib\c93-keyboard.asm
#include includes\video.asm

    #ORG 0x080000

    ; Font setup
    LD A, 0x07						; LoadFile
    LD BCD, .FontFile 				; Font file to be loaded
    LD EFG, .FontData 				; Deposit data at .FontData
    INT 0x04, A						; FS interrupt
    
    ; Initial video setup
    LD A, 0x02						; SetVideoPagesCount
    LD B, 0x03						; Pages count
                                    ; 0 = bg, 1 = objects, 2 = ui
    INT 0x01, A						; Video interrupt
    LD A, 0x05						; ClearVideoPage
    LD B, 0							; Page 0
    LD C, (.BGColor)				; Color
    INT 0x01, A						; Video interrupt
    INC B							; Page 1
    LD C, 0x00						; Color
    INT 0x01, A						; Video interrupt
    INC B							; Page 3
    INT 0x01, A						; Video interrupt

    ; Initial clock time
    LD N, 0x03						; ReadClock
    LD O, 0x00						; Milliseconds
    LD PQR, .ClockTimeMsPrevious	; Destination address
    INT 0x00, N						; Machine interrupt

    LD EFG, .StringControls
    LD HI, 190
    LD JK, 262
    LD L, 15
    CALLR .DrawString

    JP .MainLoop


.MainLoop
    ; Keyboard input
    CALLR .InputUpdate 

    ; Exit with escape
    LD A, 27						; Escape key
    CALLR .InputKeyPressed
    CP A, 1
    JR Z, .ExitProgram

    ; Update clock routine for frame delta time
    CALLR .UpdateClock
    CP A, 1							; Check if we are ready to do fixed frame work
    CALLR EQ, .FixedUpdate			; We call the FixedUpdate routine

    ; Draw debug text
    LD A, 0x12						; DrawString
    LD BCD, .FontData				; The address of the font to use
    LD EFG, .StringTitle			; The address of the null terminated string
    LD HI, 1						; X coordinate
    LD JK, 1						; Y coordinate
    LD L, 200						; Color
    LD M, 2							; Video page
    INT 0x01, A						; Video interrupt
    
    JP .MainLoop

; Routine to draw text
; EFG are the address of a null terminated string
; HI and JK are X and Y coordinates
; L is the color
.DrawString
    LD A, 0x12						; DrawString
    LD BCD, .FontData				; The address of the font to use
    LD M, 2							; Video page
    INT 0x01, A						; Video interrupt
    RET

.FixedUpdate
    ; Paddle A movement
    LD A, 188						; Comma
    CALLR .InputKeyPressed
    CP A, 1
    CALLR Z, .MovePaddleALeft
    LD A, 190						; Period
    CALLR .InputKeyPressed
    CP A, 1
    CALLR Z, .MovePaddleARight

    ; Render objects
    CALL .DrawPaddles

    RET

.DrawPaddles
    ; Clear the game objects
    LD A, 0x05						; ClearVideoPage
    LD B, 1							; Page 1
    LD C, 0x00						; Color
    INT 0x01, A						; Video interrupt

    ; Draw the paddles
    ; Shared
    LD A, 0x06						; DrawFilledRectangle
    LD B, 1							; Video page
    LD IJ, (.PaddleHeight)			; Height
    LD K, 100							; Color
    ; A
    LD CD, (.PaddleAX)				; X position top left
    LD EF, (.PaddleAY)				; Y position top left
    LD GH, (.PaddleASize)			; Width
    INT 0x01, A						; Video interrupt
    ; B
    LD CD, (.PaddleBX)				; X position top left
    LD EF, (.PaddleBY)				; Y position top left
    LD GH, (.PaddleBSize)			; Width
    INT 0x01, A						; Video interrupt

    RET

.MovePaddleARight
    LD BC, (.PaddleAX)			; Load the paddle X
    LD DE, (.PaddleASpeed)		; Load the speed

    ADD BC, DE
    ; TODO: Bounding check

    LD (.PaddleAX), BC
    RET

.MovePaddleALeft
    LD BC, (.PaddleAX)			; Load the paddle X
    LD DE, (.PaddleASpeed)		; Load the speed

    SUB BC, DE
    ; TODO: Bounding check

    LD (.PaddleAX), BC
    RET


; This routine calculates the delta time between cycles
; Sets the A register to 1 if the desired frame rate has been reached
.UpdateClock
    LD N, 0x03							; ReadClock
    LD O, 0x00							; Milliseconds
    LD PQR, .ClockTimeMs				; Set the destination address to .ClockTimeMs
    INT 0x00, N							; Machine interrupt
    LD FGHI, (.ClockTimeMsPrevious)		; Load the previous clock time
    LD JKLM, (.ClockTimeMs)				; Load the new clock time

    SUB JKLM, FGHI						; Calculate the delta between the current and previous clock ms
    LD OPQR, (.TargetFrameTime)			; Get the value of the target frame rate
    CP JKLM, OPQR						; Compare the delta with the target frame time
    JR GT, .UpdateClockTick				; If the  delta is GTE than the target, we jump

    LD A, 0								; The frame rate has not been reached, so return with 0
    RET
.UpdateClockTick
    ; The frame rate has been reached
    LD JKLM, (.ClockTimeMs)				; Load the new clock time again
    LD (.ClockTimeMsPrevious), JKLM		; Store the new time as the previous for next iteration
    LD A, 1								; We return with 1 in A
    RET


.ExitProgram
    RET


; Game memory
.PaddleAX
    #DB 00216
.PaddleBX
    #DB 00216
.PaddleAY
    #DB 00250
.PaddleBY
    #DB 0010
.PaddleASpeed
    #DB 008
.PaddleBSpeed
    #DB 008
.PaddleASize
    #DB 0048
.PaddleBSize
    #DB 0048
.PaddleHeight
    #DB 0010

; Frame rate related memory
.TargetFrameTime
    ; We prepend 3 extra bytes of zeroes, since we need to compare to an 4 byte register
    #DB 0, 0, 0, 33			; 33 ms between updates per frame should give approx. 30 FPS
.ClockTimeMs
    #DB 0x00000000			; 32 bits for clock ms
.ClockTimeMsPrevious
    #DB 0x00000000			; 32 bits for clock ms

; Colors
.BGColor
    #DB 0245

; Fonts and strings
.FontFile
    #DB "fonts\CleanCut.font", 0
.FontData
    #DB [952] 0				; Reserve 952 bytes for the font data

.StringTitle
    #DB "BOINK v1", 0
.StringControls
    #DB ", = left   . = right", 0


