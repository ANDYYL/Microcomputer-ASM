DATA SEGMENT
    ID DB 6 DUP(0)
    ARRAY DB 11100111B,11101011B,11101101B,11101110B
          DB 11010111B,11011011B,11011101B,11011110B
          DB 10110111B,10111011B,10111101B,10111110B
          DB 01110111B,01111011B,01111101B,01111110B
    KEY   DB 0EDH,21H,0F4H,0F1H,39H   ;0~5
          DB 0D9H,0DDH,61H,0FDH,0F9H  ;6~9 
DATA ENDS 
;-----------------------------------------------------
STACK SEGMENT STACK 'STACK'
      DB 100 DUP(0)
STACK ENDS      
;-----------------------------------------------------
CODE SEGMENT
    ASSUME DS:DATA,CS:CODE,SS:STACK 
;-----------------------------------------------------         
MAIN PROC FAR
     MOV AX,DATA
     MOV DS,AX
     MOV ES,AX
     MOV DX,0EE23H
     MOV AL,16H
     OUT DX,AL
CLEAR:XOR DX,DX 		; Record how many digits has been stored
      MOV CX,6
      MOV AL,0
      XOR SI,SI
LOPC: MOV ID[SI],AL 	;Clear all ID value 
      INC SI
      LOOP LOPC
DELETE:
      CMP DX,0		;Do nothing if no digit
      JE  NEXT
      DEC DX		;Digits number decrease one
      MOV AL,0
      MOV SI,DX
      MOV ID[SI],AL	
NEXT:
     CALL DISP     	 ;Display the digits
     CALL READ 		 ;Read key state
     CMP AL,0FFH       ;No Key pressed ?
     JE  NEXT  		 ;No key pressed        
     ;Key pressed!
     CLD               ;Set: DI + 1
     MOV CX,16
     MOV DI,OFFSET ARRAY 
     REPNZ SCASB       ;Search array to find key code
     CMP CX,0
     JE  NFD           ;Usually this is not going to 						 ;happen,except sth wrong  
     MOV BX,OFFSET ARRAY
     SUB DI,BX
     DEC DI
     CMP DI,9          ;Is the key 0~9?
     JBE ISNUM         ;Key A and B not defined,
				 ;reserve for future use.
     CMP DI,12
     JE  CLEAR         ;Key C means clear all input digits
     CMP DI,13         ;Key D means delete one digit
     JE  DELETE
     CMP DI,14
     JE  EXIT          ;Key E means Exit the program.
     JMP NEXT      
ISNUM:NOP
AGN:  CALL READ         ;Key pressed!
      CMP AL,0FFH       ;Has the key been released?
      JNE AGN           ;No:wait until it is 							  ;released;Yes:begin to judge the key.
      MOV AL,KEY[DI]
      MOV SI,DX
      MOV ID[SI],AL     ;Store the input number to memery.
      INC DX
      CALL DISP
      CMP DX,7		 ;All display unit has been occupied
      JE  CLEAR
      JMP NEXT
NFD: NOP           ;Unknown state,just terminate the program.
EXIT:MOV AX,4C00H
     INT 21H
MAIN ENDP 
;-----------------------------------------------------
READ PROC NEAR		 ;Read keyboard state, return key code
     PUSH DX
     MOV DX,0EE03H
     MOV AL,81H
     OUT DX,AL
     MOV AL,00H
     MOV DX,0EE02H
     OUT DX,AL
     IN  AL,DX          ;Read Row info
     MOV BL,AL
     MOV DX,0EE03H
     MOV AL,88H
     OUT DX,AL
     MOV AL,00H
     MOV DX,0EE02H
     OUT DX,AL
     IN  AL,DX          ;Read Colum info
     OR  AL,BL          ;Keep info in AL for SCASB 
     POP DX
     RET    
READ ENDP
;-----------------------------------------------------
DISP PROC NEAR 		  ;Display 6 digits
     PUSH CX
     PUSH DX
     PUSH AX
     MOV BP,000FH
LOPP:XOR SI,SI
     MOV CX,06H
     MOV DX,0EE00H
     MOV AH,00000001B
LOPD:MOV AL,ID[SI]
     OUT DX,AL
     MOV AL,AH     ;Control which char to display
     INC DX
     OUT DX,AL     ;Control which LED on
     DEC DX
     ROL AH,1
     INC SI
     CALL DELAY    ;Every char need to delay
     LOOP LOPD
     DEC BP
     JNZ LOPP
     POP AX
     POP DX
     POP CX
     RET     
DISP ENDP
;-----------------------------------------------------  
DELAY PROC          ;Delay time
      PUSH AX
      PUSH CX
      MOV AX,0003H  ;Outer loop
LOP1: MOV CX,00H    ;Inner loop
      LOOP $
      DEC AX
      JNZ LOP1  
      POP CX
      POP AX 
      RET
DELAY ENDP 
;-----------------------------------------------------         
CODE ENDS
    END MAIN

