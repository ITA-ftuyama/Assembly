;*************************************
;*                                   *
;*    CALCULADORA DE 5 OPERAÇÕES     *
;*                                   *
;*************************************
;     	Grupo:                       *
;*************************************
;    Davi Paulino                    *
;    Felipe Tuyama                   *
;    João Vitor                      * 
;*************************************

ASSUME CS: CODIGO, DS:DADOS, SS:PILHA

;*****************************
;*     SEGMENTO DE DADOS     *
;*****************************
DADOS SEGMENT

	; Variáveis auxiliares
	LINHA DB 0
	COLUNA DB 0
	CONT DB 0
	FLAG DB 0
	OPERADOR DB 0,'$'
	
	; Número 1 em diversos formatos
	SINAL1 DB '+'
	NUM_ASC1 DB 20 DUP(0),'$'
	NUM_BCD1 DB 10 DUP(0)
	NUM_BIN1 DB 8 DUP(0),'$'
	
	; Número 2 em diversos formatos
	SINAL2 DB '+'
	NUM_ASC2 DB 20 DUP(0),'$'
	NUM_BCD2 DB 10 DUP(0)
	NUM_BIN2 DB 8 DUP(0),'$'
	
	; Resultado em diversos formatos
	SINALR DB '+'
	RES_ASC DB 20 DUP(0),'$'
	RES_BCD DB 10 DUP(0)
	RES_BIN DB 8 DUP(0),'$'

	DB '$' ;para evitar a impressão de lixo
	
	; Mensagens gráficas da Calculadora
	MENS1 DB 'CALCULADORA $'
	MENS2 DB 'OPERANDO 1: $'
	MENS3 DB 'OPERANDO 2: $'
	MENS4 DB 'OPERADOR: $'
	MENS5 DB '________________________ $'
	MENS6 DB 'RESULTADO: $'
	MENS7 DB 'DIGITE "S" PARA SAIR. $'
	MENS8 DB 'OVERFLOW DO OPERANDO $'
	MENS9 DB 'OVERFLOW DO RESULTADO $'
	MENS10 DB 'DIVISAO POR ZERO $'	

DADOS ENDS

;*****************************
;*     SEGMENTO DE PILHA     *
;*****************************
PILHA SEGMENT
	DW 100 DUP(?)
	TOPO_PILHA LABEL WORD
PILHA ENDS

;*****************************
;*     SEGMENTO DE CÓDIGO    *
;*****************************
CODIGO SEGMENT 

INICIO: 
	MOV AX, DADOS
	MOV DS, AX
	MOV AX, PILHA
	MOV SS, AX
	MOV SP, OFFSET TOPO_PILHA

;*************************************
;*                                   *
;* 	             MAIN                *
;*                                   *
;*************************************
VOLTA:
	CALL LIMPAR_TELA
	CALL LIMPAR_VETOR
	CALL MOLDURA
	CALL MENSAGEM
	CALL ESC_TITULO
	
	; Leitura da primeira entrada
	CALL ENT_NUM1
	MOV SI, OFFSET NUM_ASC1
	MOV DI, OFFSET NUM_BCD1
	CALL CONV_ASC_BCD
	CALL TESTE11

	MOV SI, OFFSET NUM_BCD1
	CALL CONV_BCD_BIN
	CMP FLAG, 0
	JNE OVER
	CALL TESTE12

	; Leitura da segunda entrada
	CALL ENT_NUM2
	MOV SI, OFFSET NUM_ASC2
	MOV DI, OFFSET NUM_BCD2
	CALL CONV_ASC_BCD
	CALL TESTE21

	MOV SI, OFFSET NUM_BCD2
	CALL CONV_BCD_BIN
	CMP FLAG, 0
	JNE OVER
	CALL TESTE22

	; Realizando operações
	CALL OPERACAO
	CALL CALCULA
	CMP FLAG, 0
	JNE OVER

	CALL TESTE31
	CALL CONV_BIN_BCD

	CALL TESTE32
	CALL CONV_BCD_ASC
	CALL AJUSTA
	CALL MOSTRA
	JMP VERIF_SAIR
OVER: 
	CALL MENS_OVER
VERIF_SAIR: 
	MOV LINHA, 17
	MOV COLUNA, 40
	CALL POS_CURSOR
	MOV DX, OFFSET MENS7
	CALL ESC_MENS
	CALL LER_TECLA
	CMP AL, 'S'
	JE SAIR
	CMP AL, 's'
	JE SAIR
	JMP VOLTA

; Sai da calculadora	
SAIR: 	
	CALL LIMPAR_TELA
	MOV AH, 4CH
	INT 21H

;*************************************
;*                                   *
;*       SUBROTINAS DE TESTE         *
;*                                   *
;*************************************

; Testa conversão Num1 ASC - BCD
TESTE11:
	MOV LINHA, 9
	MOV COLUNA, 10
	
	CALL POS_CURSOR
	MOV DX, OFFSET NUM_BCD1
	CALL ESC_MENS
	RET

; Testa conversão Num1 BCD - BIN
TESTE12:
	MOV LINHA,  9
	MOV COLUNA, 30

	CALL POS_CURSOR
	MOV DX, OFFSET NUM_BIN1
	CALL ESC_MENS
	RET

; Testa conversão Num2 ASC - BCD
TESTE21:
	MOV LINHA, 10
	MOV COLUNA, 10

	CALL POS_CURSOR
	MOV DX, OFFSET NUM_BCD2
	CALL ESC_MENS
	RET

; Testa conversão Num2 BCD - BIN
TESTE22:
	MOV LINHA,  10
	MOV COLUNA, 30

	CALL POS_CURSOR
	MOV DX, OFFSET NUM_BIN2
	CALL ESC_MENS
	RET

; Testa Resultado BIN da operação
TESTE31:
	MOV LINHA, 11
	MOV COLUNA, 30

	CALL POS_CURSOR
	MOV DX, OFFSET RES_BIN
	CALL ESC_MENS
	RET
	
; Testa conversão RES BIN - BCD
TESTE32:
	MOV LINHA, 11
	MOV COLUNA, 10

	CALL POS_CURSOR
	MOV DX, OFFSET RES_BCD
	CALL ESC_MENS
	RET

TESTA_OV1:
	MOV AL, SINAL1
	CMP AL, SINAL2
	JNE FIM_OV1
	MOV AL, SINALR
	CMP AL, SINAL2
	JE FIM_OV1
	MOV FLAG, 2
FIM_OV1:
	RET

TESTA_OV2:
	MOV AL, RES_BIN[0]
	AND AL, 80H
	JZ CONT_OV2
	MOV FLAG, 2
	JMP FIM_OV2
CONT_OV2:
	MOV CX, 10
	MOV BX, 9
LOOP_OV2:
	MOV AL, RES_BCD[BX]
	CMP AL, 0
	JE IS_ZERO
	MOV FLAG, 2
	JMP FIM_OV2
IS_ZERO:
	DEC BX
	LOOP LOOP_OV2
FIM_OV2:
	RET

; Verifica se ocorre divisão por zero
DIV_ZERO:
	CLC
	MOV CX, 8
	MOV BX, 7
LOOP_DIV_ZERO:
	CMP NUM_BIN2[BX], 0
	JNE FIM_DIV_ZERO
	DEC BX
	LOOP LOOP_DIV_ZERO
	STC
	MOV FLAG, 3
FIM_DIV_ZERO:
	RET
	
;*************************************
;*                                   *
;*        CALCULATOR KERNEL          *
;*                                   *
;*************************************
;determina qual operação será feita
OPERACAO:
	MOV LINHA, 11
	MOV COLUNA, 35
	CALL POS_CURSOR
	CALL LER_TECLA
	CMP AL, '+'
	JE FIM_OP
	CMP AL, '-'
	JE FIM_OP
	CMP AL, '*'
	JE FIM_OP
	CMP AL, '\'
	JE FIM_OP
	CMP AL, '/'
	JE FIM_OP
	JMP OPERACAO
FIM_OP:

	MOV OPERADOR, AL
	MOV LINHA, 6
	MOV COLUNA, 40
	CALL POS_CURSOR
	MOV DX, OFFSET OPERADOR
	CALL ESC_MENS
	RET

;Com base no Operador informado,
;  realiza a operação desejada.
CALCULA:
	CMP OPERADOR, '+'
	JNE CALC_SUB
	CALL ADICAO
CALC_SUB:
	CMP OPERADOR, '-'
	JNE CALC_MULT
	CALL SUBTRACAO
CALC_MULT:
	CMP OPERADOR, '*'
	JNE CALC_DIV
	CALL MULTIPLICACAO
CALC_DIV:
	CMP OPERADOR, '/'
	JNE CALC_REST
	CALL DIVISAO
CALC_REST:
	CMP OPERADOR, '\'
	JNE FIM_CALC
	CALL RESTO
FIM_CALC:
	RET

;*****************************
;*    	    ADIÇÃO           *
;*****************************	
ADICAO:
	MOV SI, OFFSET NUM_BIN1
	MOV AL, SINAL1
	CALL COMPLEMENTA
	MOV SI, OFFSET NUM_BIN2
	MOV AL, SINAL2
	CALL COMPLEMENTA
	CLC
	MOV CX, 8
	MOV BX, 7
LOOP_ADD:
	MOV AL, NUM_BIN1[BX]
	ADC AL, NUM_BIN2[BX]
	MOV RES_BIN[BX], AL
	DEC BX
	LOOP LOOP_ADD
	MOV SINALR, '+'
	MOV AL, RES_BIN[0]
	AND AL, 80H 
	JZ FIM_ADD
	MOV SINALR, '-'
	MOV SI, OFFSET RES_BIN
	MOV AL, SINALR
	CALL COMPLEMENTA
FIM_ADD:
	CALL TESTA_OV1
	RET

;*****************************
;*         SUBTRAÇÃO         *
;*****************************	
;A subtração apenas faz o complemento de dois e soma

SUBTRACAO:
	CMP SINAL2, '+'
	JE TROCA_MENOS
	MOV SINAL2, '+'
	JMP FIM_SUB
TROCA_MENOS:
	MOV SINAL2, '-'
FIM_SUB:
	CALL ADICAO
	RET

;*****************************
;*    	 MULTIPLICAÇÃO	     *
;*****************************	
; Método principal da multiplicação
MULTIPLICACAO:
	CALL ZERA_MUL
	MOV CX, 64
MUL1:
	PUSH CX
	CALL SOMA_MUL
	CALL DESL_MUL
	POP CX
	LOOP MUL1
	CALL SINAL_MUL
	CALL TESTA_OV2
	RET

; Zera NUM_BCD1 para o uso na multiplicação
ZERA_MUL:
	MOV CX, 10
	MOV BX, 9
LOOP_ZERA_MUL:
	MOV NUM_BCD1[BX], 0
	DEC BX
	LOOP LOOP_ZERA_MUL
	RET

; Realiza a soma da multiplicação
SOMA_MUL:
	MOV AL, NUM_BIN2[7]
	AND AL, 01H
	JZ FIM_SOMA_MUL
	MOV CX, 18
	MOV BX, 17
	CLC
LOOP_SOMA_MUL:
	MOV AL, NUM_BCD1[BX]
	ADC RES_BCD[BX], AL
	DEC BX
	LOOP LOOP_SOMA_MUL
FIM_SOMA_MUL:
	RET
	
; Realiza o deslocamento da multiplicação
DESL_MUL:
	MOV CX, 18
	MOV BX, 17
	CLC
LOOP_DESL_MUL1:
	RCL NUM_BCD1[BX], 1
	DEC BX
	LOOP LOOP_DESL_MUL1
	MOV CX, 8
	MOV BX, 0
	CLC
LOOP_DESL_MUL2:
	RCR NUM_BIN2[BX], 1
	PUSHF
	INC BX
	POPF
	LOOP LOOP_DESL_MUL2
	RET

; Atribui sinal do resultado da multiplicação
SINAL_MUL:
	MOV SINALR, '+'
	MOV AL, SINAL1
	CMP AL, SINAL2
	JE FIM_SINAL_MUL
	MOV SINALR, '-'
FIM_SINAL_MUL:
	RET

;*****************************
;*          DIVISÃO          *
;*****************************	
; Método principal da divisão
DIVISAO:
	CALL DIV_ZERO
	JC DIV2
	CALL ZERA_MUL
	MOV CX, 64
DIV1:
	PUSH CX
	CALL DESL_DIV
	CALL COMP_DIV
	POP CX
	LOOP DIV1
	CALL SINAL_MUL
	CALL RES_DIV
DIV2:
	RET

; Realiza deslocamento da divisão
DESL_DIV:
	MOV CX, 18
	MOV BX, 17
	CLC
LOOP_DESL_DIV:
	RCL NUM_BCD1[BX], 1
	DEC BX
	LOOP LOOP_DESL_DIV
	RET

; Realiza comparação da divisão
COMP_DIV:
	MOV CX, 8
	MOV BX, 0
LOOP_COMP_DIV:
	MOV AL, NUM_BCD1[BX+2]
	CMP AL, NUM_BIN2[BX]
	JA FIX_COMP_DIV
	JB FIM_COMP_DIV
	INC BX
	LOOP LOOP_COMP_DIV
FIX_COMP_DIV:
	CALL SUB_DIV
	CALL INC_DIV
FIM_COMP_DIV:
	RET

; Atribui o resultado da divisão
;   de NUM_BIN1 a RES_BIN, no final.
RES_DIV:
	MOV CX, 8
	MOV BX, 7
LOOP_RES_DIV:
	MOV AL, NUM_BIN1[BX]
	MOV RES_BIN[BX], AL
	DEC BX
	LOOP LOOP_RES_DIV
	RET

; Realiza subtração da divisão	
SUB_DIV:
	MOV CX, 8
	MOV BX, 7
	CLC
LOOP_SUB_DIV:
	MOV AL, NUM_BCD1[BX+2]
	SBB AL, NUM_BIN2[BX]
	MOV NUM_BCD1[BX+2], AL
	DEC BX
	LOOP LOOP_SUB_DIV
	RET

; Realiza incremento da divisão
INC_DIV:
	MOV CX, 8
	MOV BX, 7
	STC
LOOP_INC_DIV:
	ADC NUM_BIN1[BX], 0
	DEC BX
	LOOP LOOP_INC_DIV
	RET

;*****************************
;*           RESTO		     *
;*****************************	
; Simplesmente chama o método Divisão
RESTO:
	CALL DIVISAO
	CALL RESTO_DIV
	RET

; Transfere o resto da divisão em 
;   NUM_BCD1 para RES_BIN
RESTO_DIV:
	MOV CX, 8
	MOV BX, 7
LOOP_RESTO_DIV:
	MOV AL, NUM_BCD1[BX+2]
	MOV RES_BIN[BX], AL
	DEC BX
	LOOP LOOP_RESTO_DIV
	MOV AL, SINAL1
	MOV SINALR, AL
	RET
	
;*****************************
;*        COMPLEMENTO	     *
;*****************************	
;faz o complemento de 2 do número
COMPLEMENTA:
	CMP AL, '+'
	JE FIM_COMP
	MOV CX, 8
	MOV BX, 7
	STC
LOOP_COMP:
	NOT BYTE PTR [SI][BX]
	ADC BYTE PTR [SI][BX], 0
	DEC BX
	LOOP LOOP_COMP
FIM_COMP: 
	RET
	
;*************************************
;*                                   *
;*     SUBROTINAS DE CONVERSÃO       *
;*                                   *
;*************************************
;*****************************
;*   CONVERTE ASC -> BCD     *
;*****************************
CONV_ASC_BCD:
	MOV BX, 0
LOOP_ASC_BCD:

	MOV AH, [SI][1]
	MOV AL, [SI][0]
	AND AL, 0FH
	SHL AL, 4
	AND AH, 0FH
	OR AL, AH
	
	MOV [DI][BX], AL
	
	INC BX
	INC SI
	INC SI
	CMP BX, 10
	JNE LOOP_ASC_BCD

	RET

;*****************************
;*   CONVERTE BCD -> BIN     *
;*****************************
CONV_BCD_BIN:
	MOV CONT, 64
LOOP_BCD_BIN: 
	CALL SHIFT_R
	CALL AJUSTA_M3
	DEC CONT
	JNZ LOOP_BCD_BIN
	MOV AL, [SI][10]
	CMP AL, 80H
	JB FIM_BCD_BIN
	MOV FLAG, 1
FIM_BCD_BIN:
	RET

SHIFT_R:
	MOV CX, 18
	MOV BX, 0
	CLC
LOOP_SHIFT_R:
	RCR BYTE PTR[SI][BX], 1
	INC BX
	DEC CX
	JNZ LOOP_SHIFT_R
	RET

AJUSTA_M3:
	MOV BX, 0
LOOP_AJUSTA_M3:
	MOV AH, [SI][BX]
	CMP AH, 80H
	JB AJUSTA_M3_PROX
	SUB BYTE PTR[SI][BX], 30H

AJUSTA_M3_PROX:
	MOV AH, [SI][BX]
	AND AH, 0FH
	CMP AH, 08H
	JB FIM_AJUSTA_M3
	SUB BYTE PTR[SI][BX], 03H
FIM_AJUSTA_M3:
	INC BX
	CMP BX, 10
	JNE LOOP_AJUSTA_M3
	RET

;*****************************
;*   CONVERTE BIN -> BCD     *
;*****************************
CONV_BIN_BCD:
	MOV CONT, 64
	MOV SI, OFFSET RES_BCD
LOOP_BIN_BCD:
	CALL SHIFT_L
	CMP CONT, 1
	JE FIM_CONV
	CALL AJUSTA_P3
FIM_CONV:
	DEC CONT
	JNZ LOOP_BIN_BCD
	RET

SHIFT_L:
	MOV BX, 19
	CLC
LOOP_SHIFT_L:
	DEC BX
	RCL BYTE PTR[SI][BX], 1
	JNZ LOOP_SHIFT_L
	RET

AJUSTA_P3:
	MOV BX, 0
LOOP_AJUSTA_P3:
	MOV AH, [SI][BX]
	AND AH, 11110000B
	CMP AH, 40H
	JBE AJUSTA_P3_PROX
	ADD BYTE PTR[SI][BX], 30H

AJUSTA_P3_PROX:
	MOV AH, [SI][BX]
	AND AH, 0FH
	CMP AH, 04H
	JBE FIM_AJUSTA_P3
	ADD BYTE PTR[SI][BX], 03H
FIM_AJUSTA_P3:
	INC BX
	CMP BX, 10
	JNE LOOP_AJUSTA_P3
	RET

;*****************************
;*   CONVERTE BCD -> ASC     *
;*****************************
CONV_BCD_ASC:
	MOV BX, 0
	MOV SI, OFFSET RES_ASC
	MOV DI, OFFSET RES_BCD
LOOP_BCD_ASC:
	MOV AH, [DI][BX]
	MOV AL, [DI][BX]
	
	AND AL, 0FH
	SUB AH, AL
	SHR AH, 4

	ADD AH, 30H
	ADD AL, 30H
	MOV [SI][0], AH
	MOV [SI][1], AL

	INC BX
	INC SI
	INC SI
	CMP BX, 10
	JNE LOOP_BCD_ASC
	RET
	
;*************************************
;*                                   *
;*      SUBROTINAS DE LEITURA        *
;*                                   *
;*************************************
;*****************************
;   	LEITURA DE ENT1      *
;*****************************

ENT_NUM1:
	MOV CONT, 0
	MOV LINHA, 4
	MOV COLUNA, 20
VER:
	CALL POS_CURSOR
	MOV DX, OFFSET SINAL1
	CALL ESC_MENS
	CALL LER_TECLA

VER_ENTER:
	CMP AL, 13  	 
	JE  FIM_ENT

VER_MAIS:
	; Tecla '+'
	CMP AL, 43
	JNE VER_MENOS
	MOV SINAL1, AL
	JMP VER

VER_MENOS:
	; Tecla '-'
	CMP AL, 45
	JNE VER_NUM
	MOV SINAL1, AL
	JMP VER

VER_NUM:
	CMP AL, 30H
	JB  VER
	CMP AL, 39H
	JA  VER
		CALL DESLOCA
		MOV NUM_ASC1[19], AL
		INC CONT
		CALL POS_CURSOR
		MOV DX, OFFSET SINAL1
		CALL ESC_MENS
	CMP CONT, 19
	JE FIM_ENT
	JMP VER

FIM_ENT:
	RET

DESLOCA:
	MOV SI, 1
LOOP_DESLOCA:
	MOV AH, NUM_ASC1[SI] 
	MOV NUM_ASC1[SI-1], AH
	INC SI
	CMP SI, 20
	JNE LOOP_DESLOCA
	RET

;*****************************
;   	LEITURA DE ENT2      *
;*****************************

ENT_NUM2:
	MOV CONT, 0
	MOV LINHA, 5
	MOV COLUNA, 20
VER2:
	CALL POS_CURSOR
	MOV DX, OFFSET SINAL2
	CALL ESC_MENS
	CALL LER_TECLA

VER_ENTER2:
	CMP AL, 13  	 
	JE  FIM_ENT2

VER_MAIS2:
	; Tecla '+'
	CMP AL, 43
	JNE VER_MENOS2
	MOV SINAL2, AL
	JMP VER2

VER_MENOS2:
	; Tecla '-'
	CMP AL, 45
	JNE VER_NUM2
	MOV SINAL2, AL
	JMP VER2

VER_NUM2:
	CMP AL, 30H
	JB  VER2
	CMP AL, 39H
	JA  VER2
		CALL DESLOCA2
		MOV NUM_ASC2[19], AL
		INC CONT
		CALL POS_CURSOR
		MOV DX, OFFSET SINAL2
		CALL ESC_MENS
	CMP CONT, 19
	JE FIM_ENT2
	JMP VER2

FIM_ENT2:
	RET

DESLOCA2:
	MOV SI, 1
LOOP_DESLOCA2:
	MOV AH, NUM_ASC2[SI] 
	MOV NUM_ASC2[SI-1], AH
	INC SI
	CMP SI, 20
	JNE LOOP_DESLOCA2
	RET

;*************************************
;*                                   *
;*      SUBROTINAS DE EXIBIÇÃO       *
;*                                   *
;*************************************
	
; Mostra a resposta na tela
MOSTRA:
	
	;insere o resultado da operação feita
	MOV LINHA, 8
	MOV COLUNA, 20

	CALL POS_CURSOR
	MOV DX, OFFSET SINALR
	CALL ESC_MENS
	RET

; Mostra mensagem de overflow
MENS_OVER:
	MOV LINHA, 16
	MOV COLUNA, 40
	CALL POS_CURSOR
	MOV DX, OFFSET MENS7
	CMP FLAG, 0
	JE ESC_OVER_FIM
	MOV DX, OFFSET MENS8
	CMP FLAG, 1
	JE ESC_OVER_FIM
	MOV DX, OFFSET MENS9
	CMP FLAG, 2
	JE ESC_OVER_FIM
	MOV DX, OFFSET MENS10
ESC_OVER_FIM:
	CALL ESC_MENS
	RET
	
; Imprime a interface
MENSAGEM:
	;insere "operando 1"
	MOV LINHA, 4
	MOV COLUNA, 8
	CALL POS_CURSOR
	MOV DX, OFFSET MENS2
	CALL ESC_MENS

	;insere "operando 2"
	MOV LINHA, 5
	MOV COLUNA, 8
	CALL POS_CURSOR
	MOV DX, OFFSET MENS3
	CALL ESC_MENS

	;insere "operador"
	MOV LINHA, 6
	MOV COLUNA, 8
	CALL POS_CURSOR
	MOV DX, OFFSET MENS4
	CALL ESC_MENS

	;insere a linha que separa resultado de operandos
	MOV LINHA, 7
	MOV COLUNA, 20
	CALL POS_CURSOR
	MOV DX, OFFSET MENS5
	CALL ESC_MENS

	;insere "resultado"
	MOV LINHA, 8
	MOV COLUNA, 8
	CALL POS_CURSOR
	MOV DX, OFFSET MENS6
	CALL ESC_MENS
	
	RET

; Escreve a mensagem na tela
ESC_MENS:	
	MOV AH, 9
	INT 21H
	RET

;Escreve o título jogo na tela
ESC_TITULO:
	MOV LINHA, 1
	MOV COLUNA, 32
	CALL POS_CURSOR
	
	MOV DX, OFFSET MENS1
	CALL ESC_MENS
	MOV LINHA, 5
	MOV COLUNA, 12	
	RET

;*************************************
;*                                   *
;*     SUBROTINAS PARA LIMPEZA       *
;*                                   *
;*************************************
;*****************************
;       LIMPA VETORES        *
;*****************************
; Limpa sinais e flags
LIMPAR_VETOR:
	MOV SINAL1, '+'
	MOV SINAL2, '+'
	MOV SINALR, '+'
	MOV FLAG, 0
	MOV AH, 0
	MOV BX, 0
	
; Limpa os vetores ASCII
LOOP_LIMPAR_ASC:
	MOV NUM_ASC1[BX], AH
	MOV NUM_ASC2[BX], AH
	MOV RES_ASC[BX], AH
	INC BX
	CMP BX, 20
	JNE LOOP_LIMPAR_ASC
	MOV BX, 0
	
; Limpa os vetores BCD
LOOP_LIMPAR_BCD:
	MOV NUM_BCD1[BX], AH
	MOV NUM_BCD2[BX], AH
	MOV RES_BCD[BX], AH
	INC BX
	CMP BX, 10
	JNE LOOP_LIMPAR_BCD
	MOV BX, 0

; Limpa os vetores BIN
LOOP_LIMPAR_BIN:
	MOV NUM_BIN1[BX], AH
	MOV NUM_BIN2[BX], AH
	MOV RES_BIN[BX], AH
	INC BX
	CMP BX, 8
	JNE LOOP_LIMPAR_BIN
	RET

;*****************************
;    LIMPA 0's à esquerda    *
;*****************************
; Substitui '0's à equerda do ASCII 
;   do resultado por espaços ' '.
AJUSTA:
	MOV BX, 0
	MOV SI, OFFSET RES_ASC
LOOP_AJUSTA:
	MOV AH, [SI][BX]
	CMP AH, 30H
	JNE FIM_AJUSTA
	MOV AH, 20H
	MOV [SI][BX], AH
	INC BX
	CMP BX, 19
	JNE LOOP_AJUSTA
FIM_AJUSTA:
	RET
	
;*****************************
;    	LIMPA A TELA         *
;*****************************
LIMPAR_TELA:
	MOV AH, 0
	MOV AL, 3
	INT 10H
	RET
	
;*****************************
;     LEITURA DE TECLA       *
;*****************************
LER_TECLA:     
		MOV AH, 0
		INT 16H
		RET

;*****************************
;      POSICIONA CURSOR      *
;*****************************
; Posiciona cursor em (Linha, Coluna)
POS_CURSOR:	
		MOV AH, 2
		MOV BH, 0
		MOV DH, LINHA
		MOV DL, COLUNA
		INT 10H
		RET
		
;*************************************
;*                                   *
;*      SUBROTINAS DE MOLDURA        *
;*                                   *
;*************************************
; Imprime na tela caractere de moldura,
;   reaproveitando a subrotina de Life
ESC_MOLD:	
		CALL POS_CURSOR
		MOV AL, 35
		MOV AH, 10
		MOV BH, 0
		MOV CX, 1
		INT 10H
		RET
		
; Subrotina para criar a moldura da
;   região do editor com o caractere '#'.
MOLDURA:
		MOV LINHA, 2
		MOV COLUNA, 3

; Loop que cria as molduras verticas		
LOOP1:      
		CMP  LINHA, 24
		JE	 LOOP2
			MOV  COLUNA, 75
			CALL ESC_MOLD
			
			MOV COLUNA, 3
			CALL ESC_MOLD

			INC LINHA
		JMP LOOP1

; Loop que cria as molduras horizontais	
LOOP2:   
		CMP  COLUNA, 75
		JE	  FIM_MOLD
			MOV  LINHA, 2
			CALL ESC_MOLD
			
			MOV  LINHA, 23
			CALL ESC_MOLD
		
			INC COLUNA
		JMP LOOP2
		
FIM_MOLD:
        RET

;***************************
CODIGO ENDS;

END INICIO