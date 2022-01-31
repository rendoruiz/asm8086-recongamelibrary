;Snake (Alpha v0.8): Streamlining #2 & Re-structuring
; TODO:
; > Add character detection system
; > Add pre-loaded food/points, system
; > Add pre-loaded obstacle(s), system

data segment
    snakeBodyX db 50 dup (0)   ; column, dl
    snakeBodyY db 50 dup (0)   ; row,    dh
    snakeLength db 2
    snakeHeadDirection db 0
    
    startCoordinatesX db 39
    startCoordinatesY db 13
    
    statusBarContent db "Press 'esc' key to return to main menu.$"
    statusBarRestart db "Restarting. . .$"
    
    gameOverMessage db "Game Over!  Press the 'enter' key to restart, or 'esc' to return to main menu$"
    gameOver db 0
    
    levelTotalPoints db 0
    levelAcquiredPoints db 0
    snakeFoodX db 50 dup (0)
    snakeFoodY db 50 dup (0)
ends

code segment
start:
    mov ax, data
    mov ds, ax

Initialize:
    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0
    int 10h
    
    ; hide mouse pointer
    mov ax, 1
    int 33h
    
    ; hide text cursor (compiled executable)
    mov ch, 32
    mov ah, 1
    int 10h
    
    ; display status bar on top of the window
    call ShowStatusBar
    
    ; generate level (1) obstacle and preliminary food/points 
    call GenerateLevel1
    
    ; initialize defined snake elements
    call InitializeSnakeBody
    
Update:
    ; get keyboard input, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    ; enter key, restart game
    cmp al, 13      ; enter
    je Restart
    
    ; escape key, back main menu/ exit
    cmp al, 27
    je Exit
    
    ; error trap: game must be restarted or closed after the game is over
    cmp gameOver, 1
    je Update
    
    cmp al, 119     ; W
    je MoveUp
    
    cmp al, 115     ; S
    je MoveDown
    
    cmp al, 97      ; A
    je MoveLeft
    
    cmp al, 100     ; D
    je MoveRight
    
    ; automatically move the snake even without keyboard input
    jmp AutomatedMovement
    
    jmp Update
    
Exit:
    mov ax, 4c00h
    int 21h
    
ends


MoveUp:
    mov snakeHeadDirection, 1
    jmp AutomatedMovement

MoveDown:
    mov snakeHeadDirection, 2
    jmp AutomatedMovement
    
MoveLeft:
    mov snakeHeadDirection, 3
    jmp AutomatedMovement
    
MoveRight:
    mov snakeHeadDirection, 4
    jmp AutomatedMovement


AutomatedMovement:

    ; if no default direction is set, stand by
    cmp snakeHeadDirection, 0
    je Update
    
               
    ; adjust the values of snakeBody X&Y indexes
    call AdjustSnakeBody    

    
    ; decrease Y coordinate if direction is upward
    dec snakeBodyY[0]
    cmp snakeHeadDirection, 1
    je VerifySnakePosition
    
    ; increase Y coordinate if direction is downward
    add snakeBodyY[0], 2
    cmp snakeHeadDirection, 2
    je VerifySnakePosition
             
    ; decrease X coordinate if direction is left-sideward         
    dec snakeBodyY[0]
    dec snakeBodyX[0]
    cmp snakeHeadDirection, 3
    je VerifySnakePosition                 
             
    ; increase X coordinate if direction is right-sideward         
    add snakeBodyX[0], 2
    cmp snakeHeadDirection, 4
    je VerifySnakePosition


VerifySnakePosition:
    ; error trap: borders
    cmp snakeBodyX[0], 0
    jl GameOverPass
    
    cmp snakeBodyX[0], 79
    jg GameOverPass
    
    cmp snakeBodyY[0], 2
    jl GameOverPass
    
    cmp snakeBodyY[0], 24
    jg GameOverPass
    
    ; compare if obstacle
    ; jg GameOverPass
    ; compare if snakeBody and snakeFood coordinates are equal
    ; last check: Y coordinate, if yes, call IncreaseSnakeLength
    
    jmp Draw    

                      
proc AdjustSnakeBody
    ; adjust the values of X & Y indexes starting from the last index up to the first index (0) / head
    xor cx, cx
    mov cl, snakeLength
    mov si, cx
    
    AdjustXYValues:
        mov cl, snakeBodyY[si-1]
        mov snakeBodyY[si], cl
        
        mov cl, snakeBodyX[si-1]
        mov snakeBodyX[si], cl
        
        dec si
        cmp si, 0
        jne AdjustXYValues
    
    ret
endp AdjustSnakeBody                      

                  
                  
proc IncreaseSnakeLength
    ; inc snakeLength
    ; if eaten, generate next food
    ; call GenerateLevel1Food
    ret
endp IncreaseSnakeLength


proc GenerateLevel1Food
    ; use levelAcquiredPoints as index
    ; if levelAcquiredPoints == levelTotalPoints
    ; then generate Level1Door (win/end)
    
    ret
endp GenerateLevel1Food

        
        
Draw:
    ; display the body of snake starting from the first index / head
    xor cx, cx
    mov cl, snakeLength
    mov di, cx
    mov si, 0
    
    DrawSnakeBody:
        mov dh, snakeBodyY[si]
        mov dl, snakeBodyX[si]
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 42
        mov bh, 0
        mov bl, 1010b
        mov cx, 1
        mov ah, 09h
        int 10h
        
        inc si
        cmp si, di
        jne DrawSnakeBody
              
    ; remove the displayed tail / last index          
    xor cx, cx
    mov cl, snakeLength
    mov si, cx
    
    mov dh, snakeBodyY[si]
    mov dl, snakeBodyX[si]
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 000
    mov bh, 0
    mov bl, 7h
    mov cx, 1
    mov ah, 09h
    int 10h
    
    jmp Update 
 
 
proc InitializeSnakeBody
    ; display the body of the snake on the start of the game based on the default arguments
    xor cx, cx
    
    mov cl, startCoordinatesX
    mov snakeBodyX[0], cl
    
    mov cl, startCoordinatesY
    mov snakeBodyY[0], cl
    
    mov cl, snakeLength
    mov di, cx
    
    mov si, 0
    
    DrawSnakeInitialization:
        mov dh, snakeBodyY[si]
        mov dl, snakeBodyX[si]
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov snakeBodyY[si+1], dh
        mov snakeBodyX[si+1], dl
        dec snakeBodyX[si+1]
        
        mov al, 42
        mov bh, 0
        mov bl, 1010b
        mov cx, 1
        mov ah, 09h
        int 10h
        
        inc si
        cmp snakeLength, 2
        jl Update
        
        cmp si, di
        jl DrawSnakeInitialization
    
    ret
endp InitializeSnakeBody 
               
               
proc ShowStatusBar
    ; displays horizontal bar   
    mov dh, 1
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 205
    mov bh, 0
    mov bl, 0111b
    mov cx, 80
    mov ah, 09h
    int 10h     
    
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, statusBarContent
    mov ah, 9
    int 21h
    
    ret
endp ShowStatusBar
             

GameOverPass:
    mov gameOver, 1
    
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, gameOverMessage
    mov ah, 9
    int 21h

    jmp Update


Restart:
    cmp gameOver, 1
    jne Update
    
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 000
    mov bh, 0
    mov cx, 79
    mov ah, 0ah
    int 10h
    
    lea dx, statusBarRestart
    mov ah, 9
    int 21h
    
    ; clear the whole field
    mov dh, 2
    ClearField:
        ; set position
        mov dl, 0
        mov bh, 0
        mov ah, 2
        int 10h
        
        ; clear row
        mov al, 000
        mov bh, 0
        mov bl, 0111b
        mov cx, 79
        mov ah, 09h
        int 10h     
        
        inc dh
        cmp dh, 24
        jle ClearField
    
    ; reset components
    mov gameOver, 0
    mov snakeHeadDirection, 0
    
    ; re-initialize components
    call ShowStatusBar    
    call GenerateLevel1
    call InitializeSnakeBody
    
    jmp Update
     


proc GenerateLevel1
    ; interrupt 10h components
    mov bh, 0
    mov cx, 1
    
    ;left-side corners
    mov al, 201     ; upper left ascii
    mov dh, 9
    mov dl, 25
    GenerateLeftCorners:
        mov ah, 2   ; points mouse position
        int 10h
        
        mov ah, 0ah ; prints ascii
        int 10h
        
        mov dh, 17  ; adjust row value
        dec al      ; lower left ascii
        
        cmp al, 200
        je GenerateLeftCorners
    
    ; right side corners
    mov al, 188     ; lower right ascii
    mov dl, 54
    GenerateRightCorners:
        mov ah, 2   ; points mouse position
        int 10h
        
        mov ah, 0ah ; prints ascii
        int 10h
        
        mov dh, 9   ; adjust row value
        dec al      ; upper right ascii
        
        cmp al, 187
        je GenerateRightCorners 
    
    ; horizontal line
    mov dh, 9
    GenerateHorizontalLine:
        mov dl, 26
        mov ah, 2
        int 10h
        
        mov al, 205
        mov cx, 28
        mov ah, 0ah
        int 10h
        
        add dh, 8
        cmp dh, 17
        je GenerateHorizontalLine
        
        
    ; Level 1 food generation components
    mov levelTotalPoints, 8
        
    ret
endp GenerateLevel1


end start 