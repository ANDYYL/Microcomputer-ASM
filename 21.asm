DATA    SEGMENT 

SHOW    DB  0EDH,21H,0F4H,0F1H,039H,0D9H ;012345的ASCII码值
COUNT   EQU $-SHOW 		;COUNT的值6 means 6个数字

SL      DB  ?                                
DATA    ENDS

STACK   SEGMENT STACK'STACK'
		DB 100H DUP(?) ;为该堆栈分配100个字节，不初始化。
STACK   ENDS   
          
CODE    SEGMENT 
		ASSUME CS:CODE, DS:DATA, SS:STACK

START : MOV AX,DATA
		MOV DS,AX 

NEXT:   MOV CX,COUNT     	;字母个数
		LEA BX,SHOW
		MOV SL,01H
	
AGAIN:  MOV AL,80H          ;1000-0000                 
		MOV DX,0EE03H    	;写入控制字，使得PA,PB处于基本输入输出的工作模式0
		OUT DX,AL           ;设置输出端口
		MOV AL,SL			
		MOV DX,0EE01H       ;确定位选输出                
		OUT DX,AL
		MOV AL,[BX]
		
		MOV DX,0EE00H                        
		OUT DX,AL           ;数码管显示已经保存在数据段的数字                          
		
		MOV AL,00H 
		MOV DX,0EE00H
		OUT DX,AL           ;清除原有字符                       
		
		INC BX              ;增加BX数值，显示下一个数字
		
		SHL SL,1            ;逻辑Sl左移依次向左选通数码管                               
		
		LOOP AGAIN          ;循环此过程
		
		MOV AH,0BH          ;检验键盘状态                
		INT 21H
		
		OR AL,AL			;若无键盘输入，则跳转NEXT
		JZ NEXT

OK:     MOV AH,4CH			;结束码
		INT 21H

CODE    ENDS

END     START
