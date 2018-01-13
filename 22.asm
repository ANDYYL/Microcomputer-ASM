DATA SEGMENT
MESG DB 0,0,0,0,0,0,3DH,0DCH,8CH,8CH,0EDH,0 
DATA ENDS 

STACK SEGMENT STACK 'STACK'
      DB 100 DUP(0)
STACK ENDS      

CODE SEGMENT
     ASSUME DS:DATA,CS:CODE,SS:STACK 
       
MAIN PROC FAR
     MOV AX,DATA
     MOV DS,AX
     MOV ES,AX
     MOV AL,80H
     MOV DX,0EE03H      
     OUT DX,AL  
LOP6:MOV BX,OFFSET MESG
     MOV CX,07H         
LOP5:MOV DX,0EEE0H      
     IN  AL,DX
     INC AL
     AND AL,07H
     XOR AH,AH
     MOV DX,AX          
LOPZ:CALL DISP          
     DEC DX
     JNZ LOPZ           
     INC BX             
     LOOP LOP5          
     JMP LOP6           
MAIN ENDP


DISP PROC NEAR 
     PUSH CX 
     PUSH DX
     PUSH AX
     MOV BP,0034H       

LOPX:XOR SI,SI
     MOV CX,06H         
     MOV DX,0EE00H      
     MOV AH,00000001B   
LOP2:MOV AL,MESG[BX+SI]
     OUT DX,AL
     MOV AL,AH          
     INC DX
     OUT DX,AL          
     DEC DX
     ROL AH,1           
     INC SI
     CALL DELAY         
     CALL KEY          
     LOOP LOP2        
     DEC BP
     JNZ LOPX          
     POP AX
     POP DX
     POP CX
     RET     
DISP ENDP


KEY PROC NEAR          
    PUSH AX
    MOV AH,0BH
    INT 21H
    OR  AL,AL
    JZ  GOON            
    MOV DX,0EE00h
    MOV AL,0
    OUT DX,AL
    MOV AH,4CH          
    INT 21H
GOON:POP AX
     RET
KEY ENDP 


DELAY PROC             
      PUSH AX
      PUSH CX
      MOV AX,0002H     
LOPD: MOV CX,0H
      LOOP $           
      DEC AX
      JNZ LOPD   
      POP CX
      POP AX 
      RET
DELAY ENDP 
   
CODE ENDS
    END MAIN
