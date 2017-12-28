;8086微机原理硬件-跑马灯。

;定义数据段
DAT SEGMENT
NUM DB 0EFH	;在内存中分配一个字节单元空间，并初始化为0EFH，其地址用NUM表示
NUM2 DB 0E7H
DAT ENDS 

;定义堆栈段
STA SEGMENT STACK'STACK'
	DB 100 DUP(?)	;为该堆栈分配100个字节，不初始化。
STA ENDS 

;定义代码段
COD SEGMENT
ASSUME CS:COD,DS:DAT,SS:STA	;说明段寄存器与段名之间的关系。

START PROC FAR ;设置段间调用过程START

PUSH DS
MOV AX,0
PUSH AX ;使用第一种返回DOS的方式

MOV AX,DAT
MOV DS,AX
MOV DX,0EE00H	;输出端口设置

LOOP0:	IN AL,DX	;从地址DX指明的端口读一个字节送入AL
		MOV AH,AL	;放到AH里存一下

		TEST AL,01H	;检测AL最低位（01H=00000001b）,若AL最后一位为0,相与结果为0,ZF=1,jz跳转
		JNZ GG 		;为1则程序结束，ZF=0跳转

		TEST AL,02H	;检测AL中间位（为1则跳转到loop0）
		JNZ LOOP0	;若输入端为0则继续等待

		TEST AL,04H	;检测AL最高位（第三位上左下右）
		JNZ RR		;跑马灯向右运动
		
		TEST AL,80H
		JNZ MODEL
		
MODEL	PUSH DX		;改变灯型（两个灯同时作用）
		MOV DL,NUM2
		MOV NUM1,DL
		POP DX
		
		ROL NUM,1	;跑马灯向左运动
		JMP LOOP2	;无条件跳转

RR:		ROR NUM,1	;原数据循环右移，使得跑马灯向右跳转



LOOP2:	AND AH,1FH	;00011111高三位置零，结果送回AH。
		MOV CL,AH	;设置子程序调用的次数，间接控制延迟时间
		MOV CH,0
		MOV AL,NUM
		OUT DX,AL	;将AL中的数值输出到地址为DX的端口。
		INC CX		;CX=CX+1（通过CX控制延时次数）

LOOP1:	CALL DELAY	;调用延时子程序
		LOOP LOOP1
		JMP  LOOP0  ;返回等待输入过程

GG:		RETF

START ENDP


;延时子程序
DELAY 	PROC
		PUSH CX
		MOV CX,008FFH；外循环过程
D1:		PUSH CX
		MOV CX,004FFH；内循环过程
D2:		LOOP D2
		POP CX
		LOOP D1
		POP CX

		RET

DELAY 	ENDP

COD ENDS
END START
