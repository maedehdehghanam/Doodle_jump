STACK SEGMENT PARA STACK
	DB 64 DUP(' ')
DATA SEGMENT PARA 'DATA'
;screen variaables
	GAME_SCORE DB 0H

	WINDOW_WIDTH DW 135H 			;320 pixels
	WINDOW_HEIGHT DW 185 			;pixels 180
	
	JUMPER_X DW 00AH 				;X position of the jumper
	JUMPER_Y DW 021H 				;Y position of the jumper 
	JUMPER_Y_PREV DW 00AH 			;the last Y position of the jumper
	
	JUMPER_SIZE DW 08H				;assume that jumper is a squre 
	JUMPER_DIAMETER DW 010H			;assusme that jumper is a ball with radius r
	JUMPER_DIAMETER_POWER_2 DW 100H ;r^2
	JUMPER_X_POWER_2 DW 0 
	JUMPER_Y_POWER_2 DW 0 
	
	
    JUMPER_VX   DW 00H              ;VY of the jumper
	JUMPER_VY   DW 00H				;VX of the jumper
	JUMPER_VY_PREV DW 0H 			;VY of the jumper in the last snapshot
	JUMPER_INITIAL DW 0130			;The Y cordiante which jumper starts jumping from in every snapshot
	JUMPER_BOUNDED DW 06H			;The maximum height jumper can reach
	JUMPER_ACCELERATION DW 1H       ;acceleration
	JUMPER_INITIAL_VY   DW 010H     ;initial VY of the jumper
	
	STICK_X DW 0AH                  ;X cordinate of the stick which the jumper is jumping on
	STICK_Y DW 110                  ;Y cordiante of the stick which the jumper is jumping on 
	STICK_HEIGT DW 06H              
	STICK_WIDTH DW 045H
	IS_STICK_BROKEN DW 0 
	
	NC_STICK_X DW 080H
	NC_STICK_Y DW 100  
	NC_STICK_HEIGT DW 06H
	NC_STICK_WIDTH DW 045H
	IS_NC_STICK_BROKEN DW 0 
	
	STICK_VY DW 01H 
	
	BUG_X DW 05FH 
	BUG_Y DW 1AH  
	BUG_XR DW 1EH
	BUG_YD DW 0
	BUG_HEIGHT DW 08H
	BUG_WIDTH  DW 0FH 
	

	TIME_AUX DB 0   ;variable to check time change

	WELCOME DB 'WELCOME TO DOODLE JUMP!', '$'
	SCORE_TEXT DB '0','$'
	RECORD_TEXT DB 'Record: 0', '$'
	BACK_TO_MENU DB 'Press M to go back to main menu','$'
	LOST_TEXT DB 'YOU LOST!', '$'
	MAIN_MENU_TITLE DB '* MAIN MENU *','$'
	START_TEXT DB ' Lets play :) - S KEY', '$' 
	RESET_RECORD_TEXT DB 'Reset the record - R KEY', '$'
	MAIN_MENU_QUIT DB 'Quit Game - Q KEY','$'
	THE_COMMENCE DB 1 ;start = 1 & over = 0
	CLOSING_GAME DB 0
	SHOW_SCREEN DB 0  ;game screen = 1 & main menu = 0
	j_left db 'K -> left', '$'
	k_right db 'J -> right','$'
	i_jump db 'I -> jump', '$'
	
	
	RANDOM_HELPER DB 78
	
	RANDOM_HELPER2 DB 53
	
	START_JUMP_TIME DW 0
	
	CURRENT_TIME    DW 0 
	
	CALCULATE_SECONDS_RESULT DW 0
DATA ENDS
CODE SEGMENT PARA 'CODE'
	MAIN PROC FAR
	ASSUME CS:CODE,DS:DATA,SS:STACK
	PUSH DS 
	SUB AX, AX 
	SUB AX, AX 
	PUSH AX
	MOV AX, DATA
	MOV DS, AX
	POP AX
	POP AX
		CALL SET_SCREEN1					;this function sets the initial screen 
		CALL DRAW_JUMPER                    ;this functin draws the ball 
		CALL MAIN_MENU_UI
		CHECK_TIME:
			MOV AH, 2CH        			 	;GET SYSTEM TIME
			INT 21H             
			CMP DL, TIME_AUX				;if the time has passed
			JE  CHECK_TIME
			MOV TIME_AUX, DL    			;UPDATE TIME_AUX
			
			CALL SET_SCREEN1
			
			CALL MOVE_JUMPER
			CALL DRAW_JUMPER
			
			CALL DRAW_BUG
			
			CALL MOVE_STICK
			CALL DRAW_STICK
			CALL DRAW_STICK2
			
			CALL UPDATE_SCORE
			CALL DRAW_SCORE
			
											;Checks whether a character is available from the standard input device. Input can be redirected
			MOV AH, 0BH  					;On entry:	AH = 0Bh 
			INT 21H         				;Returns:
											;AL = 0 if no character available
											;AL = 0FFh if character available
			MOV BL, Al
			CMP BL,0ffh
			JE  READ_KEY
			
		    JMP CHECK_TIME
			READ_KEY:
				MOV AH, 1                   ;Reads a character from the standard input device and echoes it to the standard output device.
											;If no character is ready it waits until one is available.
											;I/O can be re-directed, but prevents detection of OEF.
				INT 21H     				;Returns:	AL = 8 bit data input
				MOV BL, AL
				
				CMP BL,74
				JE  GO_LEFT
				
				CMP BL,106
				JE  GO_LEFT
				
				CMP BL,75
				JE GO_RIGHT
				
				CMP BL,107
				JE GO_RIGHT
				
				CMP BL,105
			
				JE GO_UP
				
				CMP BL, 73
				JNE CHECK_TIME
				JMP GO_UP
				
				GO_LEFT:					;if J or j is pressed, decrease Vx of the jumper. 
					MOV AX, JUMPER_X
					CMP AX, JUMPER_SIZE
					JE  CHECK_TIME
				    DEC JUMPER_VX
					JMP CHECK_TIME   
					
				GO_RIGHT: 					;if K or k is pressed, decrease Vx of the jumper.
					MOV AX, JUMPER_X
					CMP AX, WINDOW_WIDTH
					JE  CHECK_TIME
				    INC JUMPER_VX
					JMP CHECK_TIME  
					
				GO_UP:
					CMP JUMPER_VY, 0     	;this label accelerate VY of the jumper in the direction that the ball 
											;is moving, 3 units
					JGE ADD_VY 
					
					DEC JUMPER_VY
					DEC JUMPER_VY
					DEC JUMPER_VY
					JMP CHECK_TIME
					ADD_VY:
						INC JUMPER_VY
						INC JUMPER_VY
						INC JUMPER_VY
					JMP CHECK_TIME 
				
		RET 
		    
	MAIN ENDP
	DRAW_BALL   PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX 
    PUSH DX
    
    MOV AX, JUMPER_SIZE
    MOV CX,JUMPER_X     ;set the x position
    SUB CX, AX
    MOV DX,JUMPER_Y     ;set the y position
    SUB DX, AX
    
    HORITENTAL_DRAW_BALL:
      MOV BX, DX       ;SAVE DX
      
      MOV AX, CX       ;AX = X
      CMP AX, JUMPER_X
      JL  X_LESS_THAN_CENTER
      
      SUB AX,JUMPER_X ; AX= X- CENTER_X
      JMP CALCULATE_X_POWER2
      
      X_LESS_THAN_CENTER:
      MOV DX, JUMPER_X
      SUB DX, AX
      MOV DX, AX
      
      CALCULATE_X_POWER2:
      MUL AX          ; AX =(X-CENTER_X)^2
      MOV JUMPER_X_POWER_2, AX
      
      MOV DX, BX
      
      MOV AX, DX       ;AX= Y
      SUB AX,JUMPER_Y  ;AX = Y - CENTER_Y
      MUL AX           ;AX = (Y-CENTER_Y)^2
      MOV JUMPER_Y_POWER_2,AX
      
      MOV DX, BX
      
      ADD AX, JUMPER_X_POWER_2
      
      CMP AX, JUMPER_DIAMETER_POWER_2
      JG  MOVE_ON2 

      CALL DRAW_PIXEL
      
      MOVE_ON2:
      INC CX
      MOV AX, CX
      SUB AX, JUMPER_X
      CMP AX, JUMPER_DIAMETER
      JNG HORITENTAL_DRAW_BALL
      MOV CX, JUMPER_X ;CX REGISTER GOES BACK TO THE INITIAL COLUMN
      SUB CX, JUMPER_SIZE
      INC DX
      MOV AX,DX
      SUB AX, JUMPER_Y
      CMP AX, JUMPER_DIAMETER
      JNG HORITENTAL_DRAW_BALL
    
    POP DX
    POP CX
    POP BX 
    POP AX
    RET  
  DRAW_BALL ENDP
	
	SET_SCREEN1 PROC NEAR
											;set video mode
		MOV AH,0
		mov AL,0DH
		INT 10H
											;set background 
		mov AH,0BH 
		mov BH,00H
		MOV BL,09H    						;SET BACKGROUND COLOR TO LIGHT BLUE
		INT 10H      						;execution 
		RET
    SET_SCREEN1 ENDP
	
	
	DRAW_JUMPER PROC NEAR 
	
		MOV CX,JUMPER_X     				;set the x position
		MOV DX,JUMPER_Y     				;set the y position
		HORITENTAL_DRAW:					;this label draws one row 
			CALL DRAW_PIXEL
			INC CX
			MOV AX, CX
			SUB AX, JUMPER_X
			CMP AX, JUMPER_SIZE
			JNG HORITENTAL_DRAW
			MOV CX, JUMPER_X 				;CX REGISTER GOES BACK TO THE INITIAL COLUMN
			INC DX
			MOV AX,DX
			SUB AX, JUMPER_Y
			CMP AX, JUMPER_SIZE
			JNG HORITENTAL_DRAW
		RET 
	DRAW_JUMPER ENDP 

	
	DRAW_PIXEL PROC NEAR 
			MOV AH,0CH          			;configuration fpr pixel
			MOV AL,0FH    				    ;choose white as color
			MOV BH,00H    				    ;page number
			INT 10H
			RET
	DRAW_PIXEL ENDP 
	
	DRAW_BUG PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX 
		PUSH DX
		MOV CX,BUG_X    					 ;set the x position
		MOV DX,BUG_Y   					     ;set the y position
		HORITENTAL_DRAW_BUG:
			MOV BX, BUG_Y
			ADD BX, 3
			CMP BX, DX
			JG  CALL_DRAW_PIXEL
			MOV BX, BUG_X
			ADD BX, 5
			CMP BX, CX
			JG  CALL_DRAW_PIXEL
			MOV BX, BUG_X
			ADD BX, 11
			CMP BX, CX
			JG MOVE_ON
			
			CALL_DRAW_PIXEL:
				MOV AH,0CH      		    ;configuration fpr pixel
				MOV AL,0CH    	   		    ;choose white as color
				MOV BH,00H    	   		    ;page number
				INT 10H
			
			MOVE_ON:
			INC CX
			MOV AX, CX
			SUB AX, BUG_X
			CMP AX, BUG_WIDTH
			JNG HORITENTAL_DRAW_BUG
			MOV CX, BUG_X  					;CX REGISTER GOES BACK TO THE INITIAL COLUMN
			INC DX
			MOV AX,DX
			SUB AX, BUG_Y
			CMP AX, BUG_HEIGHT
			JNG HORITENTAL_DRAW_BUG
		POP DX
		POP CX
		POP BX 
		POP AX
		RET
	DRAW_BUG ENDP

	
	
	MOVE_JUMPER PROC NEAR
						
			MOV AX, JUMPER_VX				;load vx
			ADD JUMPER_X, AX				;x(t) = vx+ x(t-1)
			
			
			MOV AX, JUMPER_SIZE
			CMP JUMPER_X, AX     		    ;Hitting the vertical edges of the screen
			JL  NEG_VX				
			
			MOV AX, WINDOW_WIDTH
			SUB AX, JUMPER_SIZE
			CMP JUMPER_X, AX				;Hitting the vertical edges of the screen
			JG  NEG_VX
			
			INC JUMPER_VY          			;CALCULATE VY 
			
			MOV AX, JUMPER_Y
			MOV JUMPER_Y_PREV, AX   		;saving the prev y     
			
			
			
			MOV AX, JUMPER_VY      			;load vy
			ADD JUMPER_Y, AX				;y(t) = vy+ Y(t-1)
			
			
			
			MOV AX, JUMPER_Y				;check if we lost
			CMP AX, WINDOW_HEIGHT			;if we hit the end of the screen then we loose 
			JGE END_THE_GAME
			
			MOV AX, 00H
			MOV AX, JUMPER_INITIAL  		;check if we hit the current stick 
			SUB AX, JUMPER_SIZE     		;Buttom of the ball = JUMPER_Y - JUMPER_SIZE
			CMP JUMPER_Y, AX        
			JGE  NEG_VY          		    ;the ball hit the stick 
			
			CMP JUMPER_Y, 0AH       		    ;if it hit the top of the screen, neg vy 
			JLE BALL_HIT_TOP_OF_THE_SCRREN

			CALL CHECK_FOR_BUG
			
			CMP JUMPER_VY, 0
			JG  CHECK_FOR_CURRENT_STICK
			
	        RET 
		NEG_VY: 
			MOV AX, JUMPER_INITIAL_VY
			NEG AX
			MOV JUMPER_VY, AX
			RET
		NEG_VX:
			NEG JUMPER_VX
			RET
		BALL_HIT_TOP_OF_THE_SCRREN:
			NEG JUMPER_VY 
			RET
		END_THE_GAME:
			CALL END_THE_GAME_SCREEN
			RET 
		CHECK_FOR_CURRENT_STICK:
		
			MOV AX, JUMPER_Y_PREV
			ADD AX, JUMPER_SIZE
			CMP AX, STICK_Y
			JG CHECK_FOR_OTHER_STICK
			MOV AX, JUMPER_Y
			ADD AX, JUMPER_SIZE
			CMP AX, STICK_Y
			JL CHECK_FOR_OTHER_STICK
			
			MOV BX, STICK_X
			CMP JUMPER_X, BX
			JL  CHECK_FOR_OTHER_STICK
			ADD BX, STICK_WIDTH
			CMP JUMPER_X, BX
			JG  CHECK_FOR_OTHER_STICK
			
			MOV AX, STICK_Y
			MOV JUMPER_INITIAL, AX
			SUB AX, 50
			MOV JUMPER_BOUNDED, AX
			CMP IS_STICK_BROKEN, 0 
			JE NEG_VY
			MOV STICK_Y, 0
			MOV STICK_X, 0
			MOV STICK_WIDTH, 0
			MOV STICK_HEIGT, 0
			JMP EXIT
		CHECK_FOR_OTHER_STICK:
		
			MOV AX, JUMPER_Y_PREV
			ADD AX, JUMPER_SIZE
			CMP AX, NC_STICK_Y
			JG NO_STICK
			MOV AX, JUMPER_Y
			ADD AX, JUMPER_SIZE
			CMP AX, NC_STICK_Y
			JL NO_STICK
			
			MOV BX, NC_STICK_X
			CMP JUMPER_X, BX
			JL  NO_STICK
			ADD BX, NC_STICK_WIDTH
			CMP JUMPER_X, BX
			JG  NO_STICK
			MOV JUMPER_INITIAL, AX
			SUB AX, 80
			MOV JUMPER_BOUNDED, AX
			
			CALL CHANE_CURRENT_STICK
			CALL GENERATE_RANDOM_STICK
			CALL GENERATE_RANDOM_BUG
			JMP NEG_VY
			JMP EXIT
		NO_STICK:
			MOV JUMPER_INITIAL, 194
			MOV JUMPER_BOUNDED, 06 
		EXIT:
			RET
	MOVE_JUMPER ENDP
	
	MOVE_STICK PROC NEAR 					;this function, moves sticks downward 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV AX, STICK_VY                    ;Load VY of the sticks
		
		ADD STICK_Y, AX                     ;Y(t) = Y(t-1) + 1
		
		ADD NC_STICK_Y, AX
		
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	MOVE_STICK ENDP 
	
	
	DRAW_STICK PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV CX,STICK_X    					;set the x position
		MOV DX,STICK_Y     					;set the y position
		HORITENTAL_DRAW_STICK:
			MOV AH,0CH         				;configuration fpr pixel
			MOV AL,06H    	    			;choose white as color
			CMP IS_STICK_BROKEN, 0
			JE  CONTINUE1
			MOV AL, 0AH
			CONTINUE1:
			MOV BH,00H    	    			;page number
			INT 10H
			INC CX
			MOV AX, CX
			SUB AX, STICK_X
			CMP AX, STICK_WIDTH
			JNG HORITENTAL_DRAW_STICK
			MOV CX, STICK_X 				;CX REGISTER GOES BACK TO THE INITIAL COLUMN
			INC DX
			MOV AX,DX
			SUB AX, STICK_Y
			CMP AX, STICK_HEIGT
			JNG HORITENTAL_DRAW_STICK
			
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	DRAW_STICK ENDP
	
	DRAW_STICK2 PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV CX,NC_STICK_X     				;set the x position
		MOV DX,NC_STICK_Y     				;set the y position
		HORITENTAL_DRAW_STICK2:
			MOV AH,0CH      			    ;configuration for pixel
			MOV AL,06H    	    			;choose brown as color 
			CMP IS_NC_STICK_BROKEN, 0
			JE  CONTINUE2
			MOV AL, 08H
			CONTINUE2:
			MOV BH,00H    	   				;page number
			INT 10H
			INC CX
			MOV AX, CX
			SUB AX, NC_STICK_X
			CMP AX, NC_STICK_WIDTH
			JNG HORITENTAL_DRAW_STICK2
			MOV CX, NC_STICK_X 				;CX REGISTER GOES BACK TO THE INITIAL COLUMN
			INC DX
			MOV AX,DX
			SUB AX, NC_STICK_Y
			CMP AX, NC_STICK_HEIGT
			JNG HORITENTAL_DRAW_STICK2
			
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	DRAW_STICK2 ENDP
	
	
	CHANE_CURRENT_STICK PROC NEAR             ;this function changes the current stick configuration
		MOV AX, NC_STICK_X
		MOV STICK_X, AX
		
		MOV AX, NC_STICK_WIDTH
		MOV STICK_WIDTH, AX
		
		MOV AX, NC_STICK_Y
		MOV STICK_Y, AX
		
		MOV AX, NC_STICK_HEIGT
		MOV STICK_HEIGT, AX
		
		MOV AX, IS_NC_STICK_BROKEN
		MOV IS_STICK_BROKEN, AX
		
		CMP IS_STICK_BROKEN, 1
		JNE EXIT_CHANGE_CURRENT_STICK         ;if the landing stick is broken we recieve 5 points but if its not we recive 1 point
		ADD GAME_SCORE, 4
		
		EXIT_CHANGE_CURRENT_STICK:
			INC GAME_SCORE
		RET
	CHANE_CURRENT_STICK ENDP
	
												;displaying user score along the game
	DRAW_SCORE PROC NEAR 
	    MOV AH, 02H  							;set cursor
		MOV BH, 00H 							;page number
		MOV DH, 01H	 							;row
		MOV DL, 0C6H 							;column
		INT 10H 
		
		MOV AH, 09H   							;string as standard output
		LEA DX,SCORE_TEXT 
		INT 21H									;print string
		
		RET
	DRAW_SCORE ENDP
	
	UPDATE_SCORE PROC NEAR
		SUB AX, AX
		MOV AL, GAME_SCORE ;
		ADD AL, 30H 
		MOV [SCORE_TEXT],AL 
		RET
	UPDATE_SCORE ENDP
	
	GENERATE_RANDOM_STICK PROC NEAR 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		;getting system time in order to generate semi random numbers
		GET_SYSTEM_TIME:	
			MOV AH, 2CH 		;intrrupt to get system time
			INT 21H  			;DL = 1/100 SEC ,DH = SEC
			MOV AX, 00H
			
								;generate a position for NC_stick_x 
								;where 0AH<NC_STICK_X< 115H
							
		MOV BX, 0
		MOV BL, DL
		MOV AX, BX
		MUL RANDOM_HELPER       ;AX = 1/100 SEC * RANDOM_HELPER
		MOV BX, AX				;SVAE AX
		
		
		xor DX, DX
		MOV CX, 10B				;CX = 115H - 0AH = 10BH
		DIV CX               	;AX/(115H - 0AH )
		ADD DX, 0AH 			;DX = AX%10BH
		MOV NC_STICK_X, DX
		
								;we want to generate a stick which will be located at least 10 units above the currnt stick
		MOV AX, BX				
		MOV CX, STICK_Y			; 15=0FH<NC_STICK_Y< STICK_Y - 10 
		SUB CX, 10 
		SUB CX, 15
								;AX/(STICK_Y - 25 )
		xor DX, DX
		DIV CX                    
		
		ADD DX,15 
		
		CMP DX, 06              ;check if its out of screen
		JLE GET_SYSTEM_TIME
		
		MOV NC_STICK_Y, DX
		
		xor DX, DX
		MOV CX, 2
		DIV CX
		MOV IS_NC_STICK_BROKEN, DX 
		
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	GENERATE_RANDOM_STICK ENDP
	
	CALCULATE_SECONDS PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		MOV AH, 2CH         ;GET SYSTEM TIME
			INT 21H         ;Return: CH = hour CL = minute DH = second DL = 1/100 seconds
		XOR AX,AX
		MOV AL, CL          ;AX = MINUTE
		MOV CX, 60          ;AX = MINUTE * 60
		MUL CX
		XOR CX, CX			;CX = 0
		MOV CL,DH           ;CL = SECOND 
		ADD AX,CX           ;AX = SECONDS 
		MOV CALCULATE_SECONDS_RESULT, AX 
		
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	CALCULATE_SECONDS ENDP
	
	CALCULATE_VY   PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		CALL CALCULATE_SECONDS             ;get current time
		MOV  AX, CALCULATE_SECONDS_RESULT
		SUB  AX, START_JUMP_TIME         ;get time passed since jump started 
		MOV BX, JUMPER_ACCELERATION
		MUL BX								;AX=at
		ADD JUMPER_VY, AX
		
		CALCULATE_VY_EXIT:
			
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	CALCULATE_VY ENDP
	
	CHECK_FOR_BUG PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
			MOV AX, BUG_X
			ADD AX, BUG_WIDTH
			MOV BUG_XR, AX
			MOV AX, BUG_Y
			ADD AX, BUG_HEIGHT
			MOV BUG_YD, AX
			
			MOV CX, JUMPER_X
			MOV DX, JUMPER_Y
			
			CMP CX, BUG_X
			JL  EXIT_CHECCCK_FOR_BUG
			
			CMP CX, BUG_XR
			JG  EXIT_CHECCCK_FOR_BUG
			
			;ADD CX, JUMPER_SIZE
			;CMP CX, BUG_X
			;JL  EXIT_CHECCCK_FOR_BUG
			
			;CMP CX, BUG_XR
			;JG  EXIT_CHECCCK_FOR_BUG
			
			CMP DX, BUG_Y
			JL EXIT_CHECCCK_FOR_BUG
			
			CMP DX, BUG_YD 
			JG EXIT_CHECCCK_FOR_BUG
			
			CALL END_THE_GAME_SCREEN
			
			EXIT_CHECCCK_FOR_BUG:
			
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	CHECK_FOR_BUG ENDP
	
	GENERATE_RANDOM_BUG PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		;getting system time in order to generate semi random numbers
			
			MOV AH, 2CH 		;intrrupt to get system time
			INT 21H  			;DL = 1/100 SEC ,DH = SEC
			MOV AX, 00H
 
								;where 0AH<BUG_X< 115H
							
		MOV BX, 0
		MOV BL, DL
		MOV AX, BX
		MUL RANDOM_HELPER2      ;AX = 1/100 SEC * RANDOM_HELPER
		
		MOV BX, AX				;SVAE AX
		
		xor DX, DX
		MOV CX, 267
		DIV CX               	; AH = AX%267
		ADD DX,10
		MOV BUG_X, DX
		
		MOV AX, BX
		xor DX, DX
		MOV CX, 170
		DIV CX                  ;0FH<BUG_Y< B9H    
		ADD DX,15 
		MOV BUG_Y, DX
		
		MOV AX, 0
		MOV AL, RANDOM_HELPER2
		MOV CX, 2H
		MUL CX 
		MOV RANDOM_HELPER2, AL
		
		
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	GENERATE_RANDOM_BUG ENDP
	
	END_THE_GAME_SCREEN PROC NEAR 
	PUSH AX
	PUSH BX
		CALL GAME_OVER_MENU
		;mov AH,0BH 
		;mov BH,00H
		;MOV BL,03H    		;SET BACKGROUND COLOR TO LIGHT BLUE
		;INT 10H 
		;MOV AH,4CH 
		;INT 21H
	POP AX
	POP BX
	END_THE_GAME_SCREEN ENDP 
	
	
	MAIN_MENU_UI PROC NEAR
		CALL SET_SCREEN1

;   Shows the WELCOME title
		MOV AH,02h                       
		MOV BH,00h                       
		MOV DH,05h                        
		MOV DL,09h						 
		INT 10h							 
		
		MOV AH,09h                       
		LEA DX,WELCOME          
		INT 21h  
		
;   Shows the menu title
		MOV AH,02h                       
		MOV BH,00h                       
		MOV DH,08h                        
		MOV DL,0Eh						 
		INT 10h							 
		
		MOV AH,09h                       
		LEA DX,MAIN_MENU_TITLE           
		INT 21h                          
		
;   Shows the start title 
        MOV AH,02h                       
		MOV BH,00h                       
		MOV DH,0Ah                        
		MOV DL,0Ah						 
		INT 10h							 
		;call game screen
		MOV AH,09h                       
		LEA DX,START_TEXT           
		INT 21h		
		
;   Shows the message to reset the record  
        MOV AH,02h                       
		MOV BH,00h                       
		MOV DH,0Ch                        
		MOV DL,08h						 
		INT 10h							 
		;call reset_record
		MOV AH,09h                       
		LEA DX,RESET_RECORD_TEXT           
		INT 21h		
		
;   Shows the exit message
		MOV AH,02h                       
		MOV BH,00h                        
		MOV DH,0Eh                        
		MOV DL,0Ch						 
		INT 10h							 
		
		MOV AH,09h                      
		LEA DX,MAIN_MENU_QUIT      
		INT 21h                         	
		
	;Shows the instruction
		MOV AH,02h                       
		MOV BH,00h                        
		MOV DH,014h                        
		MOV DL,01h						 
		INT 10h							 
		
		MOV AH,09h                      
		LEA DX,k_right     
		INT 21h  	
		
		MOV AH,02h                       
		MOV BH,00h                        
		MOV DH,016h                        
		MOV DL,01h						 
		INT 10h							 
		
		MOV AH,09h                      
		LEA DX,j_left     
		INT 21h 
		
		MOV AH,02h                       
		MOV BH,00h                        
		MOV DH,18h                        
		MOV DL,01h						 
		INT 10h							 
		
		MOV AH,09h                      
		LEA DX,i_jump     
		INT 21h 
		
	MAIN_MENU_WAIT_FOR_KEY:
			MOV AH,00h
			INT 16h
		
			CMP AL,'S'
			JE START_GAME
			CMP AL,'s'
			JE START_GAME
			
			CMP AL,'Q'
			JE QUIT_GAME
			CMP AL,'q'
			JE QUIT_GAME
			JMP MAIN_MENU_WAIT_FOR_KEY
			
		START_GAME:
			MOV SHOW_SCREEN,01h
			MOV THE_COMMENCE,01h
			CALL RESET_GAME
			RET
		
        RESET_RECORD:
            MOV RECORD_TEXT, 00h
			;UPDATE_RECORD_TEXT
            RET			
			
		QUIT_GAME:
			CALL FINISHING_GAME
			RET
	MAIN_MENU_UI ENDP
	
	RESET_GAME PROC NEAR
		MOV JUMPER_X, 00AH 				;X position of the jumper
		MOV JUMPER_Y,021H 				;Y position of the jumper
		MOV JUMPER_VX, 00H 				;X position of the jumper
		MOV JUMPER_VY,00H 				;Y position of the jumper	
		MOV JUMPER_VY_PREV, 0H 			;VY of the jumper in the last snapshot
		MOV JUMPER_INITIAL, 0130			;The Y cordiante which jumper starts jumping from in every snapshot
		MOV JUMPER_BOUNDED, 06H			;The maximum height jumper can reach
		MOV JUMPER_ACCELERATION, 1H       ;acceleration
		MOV JUMPER_INITIAL_VY, 010H     ;initial VY of the jumper
		
		MOV STICK_X, 0AH                  ;X cordinate of the stick which the jumper is jumping on
		MOV STICK_Y, 110                  ;Y cordiante of the stick which the jumper is jumping on 
		MOV STICK_HEIGT, 06H              
		MOV STICK_WIDTH, 045H
		MOV IS_STICK_BROKEN, 0 
		
		MOV NC_STICK_X, 080H
		MOV NC_STICK_Y, 100  
		MOV NC_STICK_HEIGT, 06H
		MOV NC_STICK_WIDTH, 045H
		MOV IS_NC_STICK_BROKEN,  0 
		MOV GAME_SCORE, 0H
		
		CALL UPDATE_SCORE
		
		RET 
	RESET_GAME ENDP
	
	
	
	FINISHING_GAME PROC NEAR         ;goes back to the text mode
		MOV AH,00h                   ;set the configuration to video mode
		MOV AL,02h                   ;choose the video mode
		INT 10h    					 ;execute the configuration 
		
		MOV AH,4Ch                   ;terminate program
		INT 21h
		RET
	FINISHING_GAME ENDP
	
	GAME_OVER_MENU PROC NEAR
		CALL SET_SCREEN1     

;   Shows the 'you fell!' message
		MOV AH,02h                       
		MOV BH,00h                       
		MOV DH,04h                      
		MOV DL,04h						 
		INT 10h							 
		
		MOV AH,09h                       
		LEA DX,LOST_TEXT                  
		INT 21h                          		
		
;   Shows the player record
		MOV AH,02h                       
		MOV BH,00h                       
		MOV DH,06h                        
		MOV DL,04h						 
		INT 10h							 
		
		;CALL UPDATE_RECORD_TEXT
		
		MOV AH,09h                       
		LEA DX,SCORE_TEXT           
		INT 21h                          

;   Shows the 'press m to..' message
		MOV AH,02h                       
		MOV BH,00h                       
		MOV DH,08h                      
		MOV DL,04h						 
		INT 10h							 
		
		MOV AH,09h                       
		LEA DX,BACK_TO_MENU               
		INT 21h                          
		
		
		MOV AH,00h    ;Waiting for key to press
		INT 16h

		CMP AL,'M'
		JE BACK_TO_MAIN_MENU
		CMP AL,'m'
		JE BACK_TO_MAIN_MENU
		RET
		
		BACK_TO_MAIN_MENU:
			MOV THE_COMMENCE,00h
			MOV SHOW_SCREEN,00h
			RET
	GAME_OVER_MENU ENDP
CODE ENDS
END