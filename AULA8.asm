;**************************************************************************
;		Programa com todas as implementações
;			8º acréscimo – Transmissão Serial
;		Arquivo AULA8.ASM
;**************************************************************************

CONST1		EQU	15
CONST2		EQU	30
REG0		EQU	20H
REG1		EQU	21H
MILHAR		EQU	22H
CENTENA		EQU	23H
DEZENA		EQU	24H
UNIDADE		EQU	25H
NUMERO		EQU	26H
CONT		EQU	27H
V_D		EQU	28H
V_E		EQU	29H
ANGULO		EQU	2AH
DISTH		EQU	2BH
DISTL		EQU	2CH
DIST		EQU	2DH
DIST3		EQU	2EH
DIST4		EQU	2FH
DIST5		EQU	30H
DIST6		EQU	31H
DIST7		EQU	32H
DIST8		EQU	33H
DIST9		EQU	34H
DIST10		EQU	35H
DIST12		EQU	36H
DIST_D		EQU	37H
DIST_F		EQU	38H
DIST_E		EQU	39H
FLAG		EQU	3AH
T2CON		EQU	0C8H
RCAP2L		EQU	0CAH
RCAP2H		EQU	0CBH
TL2		EQU	0CCH
TH2		EQU	0CDH

ORG		0000H
		JMP	INI

ORG		000BH
		JMP	ROT_T0			;rotina de interrupção do Timer 0

ORG		0023H
		JMP	ROT_SER			;rotina de interrupção da Serial

ORG		100H

INI:		MOV	SP, #6FH
		CALL	INICIAL			;inicialização do display
		CALL	ESC_MENS_1		;escreve a Mensagem 1
		CALL	ESC_MENS_2		;escreve a Mensagem 2
		MOV	MILHAR, #20H
		MOV	P2, #0FFH


		MOV	CONT, #0
		MOV	V_D, #0
		MOV	V_E, #0
		MOV	ANGULO, #0

		MOV	TMOD, #02H		;Timer 0 no Modo 2
		MOV	TCON, #0
		MOV	TL0, #56		;tempo de 200us
		MOV	TH0, #56
		MOV	IE, #10000010B		;interrupção Timer 0
		SETB	TCON.4			;liga o Timer 0

		MOV	CENTENA, #20H
		MOV	DEZENA, #20H
		MOV	UNIDADE, #20H

		ORL	TMOD, #10H		;Timer 1 no Modo 1
		CLR	TCON.6
		CLR	TCON.7

		MOV	T2CON, #00010000B	;programação do Timer 2
		MOV	TH2,#255
		MOV	TL2,#178
		MOV	RCAP2H,#255
		MOV	RCAP2L,#178
		SETB	T2CON.2

		MOV	SCON, #01000000B	;programação da Interface Serial
		ORL	IE, #10010000B
		MOV	IP, #00010000B
		MOV	SBUF, #0
		MOV	FLAG, #0


;-------------------------------------------------------------------------
;		Programa Principal para Controle da Plataforma com Radar

		MOV	ANGULO, #3
		CALL	DELAY2s
VOLTA:		CALL	LER_RADAR_A
		CALL	MEDIA
		MOV	NUMERO, DIST_D
		CALL	CONVERTE
		CALL	ESC_VALOR_1
		MOV	NUMERO, DIST_E
		CALL	CONVERTE
		CALL	ESC_VALOR_2
		CALL	PROCESSAR
		CALL	LER_RADAR_H
		CALL	MEDIA
		MOV	NUMERO, DIST_D
		CALL	CONVERTE
		CALL	ESC_VALOR_1
		MOV	NUMERO, DIST_E
		CALL	CONVERTE
		CALL	ESC_VALOR_2
		CALL	PROCESSAR
		JMP	VOLTA

;-------------------------------------------------------------------------


;*************************************************************************
;			SUB-ROTINAS
;*************************************************************************


ESC_DADO:	MOV	P1, A			;Escreve Dado
		SETB	P3.7
		CLR	P3.6
		SETB	P3.5
		CLR	P3.5
		CALL	DELAY50u
		RET

ESC_COM: 	MOV	P1, A			;Escreve Comando
		CLR	P3.7
		CLR	P3.6
		SETB	P3.5
		CLR	P3.5
		CALL	DELAY50u
		RET

INICIAL: 	CALL	DELAY5m			;espera 15 milissegundos
		CALL	DELAY5m
		CALL	DELAY5m
		MOV	A, #38H			;Function Set
		CALL	ESC_COM			;(8 bits, 2 linhas, 5x7 pontos)
		CALL	DELAY5m
		MOV	A, #38H			;Function set novamente
		CALL	ESC_COM
		CALL	DELAY5m			;espera 5 milissegundos
		MOV	A, #06H			;Entry Mode Set
		CALL	ESC_COM			;(incrementa, shift cursor)
		MOV	A, #0EH			;Display Control
		CALL	ESC_COM			;(display on, cursor on)
		MOV	A, #01H			;Clear Display
		CALL	ESC_COM
		CALL	DELAY5m			;espera 5 milissegundos
		RET


CONVERTE:	MOV	A, NUMERO		;obtém códigos ASCII da Centena,
		MOV	B, #100			;Dezena e Unidade do NUMERO
		DIV	AB
		ADD	A, #30H
		MOV	CENTENA, A
		MOV	A, B
		MOV	B, #10
		DIV	AB
		ADD	A, #30H
		MOV	DEZENA, A
		MOV	A, B
		ADD	A, #30H
		MOV	UNIDADE, A
		RET

MOSTRA_NUM:	MOV	A, MILHAR		;Mostra Milhar, Centena,
		CALL	ESC_DADO		;Dezena e Unidade
		MOV	A, CENTENA
		CALL	ESC_DADO
		MOV	A, DEZENA
		CALL	ESC_DADO
		MOV	A, UNIDADE
		CALL	ESC_DADO
		RET

MOSTRA_MENS:	CLR	A			;mostra Mensagem apontada por DPTR
		MOVC	A, @A+DPTR		;caracter nulo terminador da mensagem
		JZ	MOSTRA_FIM
		CALL	ESC_DADO
		INC	DPTR
		JMP	MOSTRA_MENS
MOSTRA_FIM:	RET

ESC_MENS_1:	MOV	A, #80H			;1ª posição da 1ª linha do display
		CALL	ESC_COM
		MOV	DPTR, #MENS_1		;aponta para a 1ª mensagem fixa
		CALL	MOSTRA_MENS
		RET

ESC_MENS_2:	MOV	A, #0C0H		;1ª posição da 2ª linha do display
		CALL	ESC_COM
		MOV	DPTR, #MENS_2		;aponta para a 2ª mensagem fixa
		CALL	MOSTRA_MENS
		RET

ESC_VALOR_1:	MOV	A, #8CH			;13ª posição da 1ª linha do display
		CALL	ESC_COM
		CALL	MOSTRA_NUM		;mostra VALOR 1
		RET

ESC_VALOR_2:	MOV	A, #0CCH		;13ª posição da 2ª linha do display
		CALL	ESC_COM
		CALL	MOSTRA_NUM		;mostra VALOR 2
		RET

DELAY5u:	NOP				;atraso de 5 microssegundos
		RET


DELAY50u:	MOV	REG0, #22		;atraso de 50 microssegundos
DELAY50u1:	DJNZ	REG0, DELAY50u1
		RET

DELAY1m:	MOV	REG0, #248		;atraso de 1 milissegundo
DELAY1m1:	NOP
		NOP
		DJNZ	REG0, DELAY1m1
		NOP
		NOP
		RET

DELAY5m:	MOV	REG1, #96		;atraso de 5 milissegundos
DELAY5m1:	CALL	DELAY50u
		DJNZ	REG1, DELAY5m1
		NOP
		NOP
		RET

DELAY100m:	MOV	REG1, #95		;atraso de 100 milissegundos
DELAY100m1:	CALL	DELAY1m
		CALL	DELAY50u
		DJNZ	REG1, DELAY100m1
		CALL	DELAY50u
		NOP
		NOP
		NOP
		NOP
		RET

DELAY05s:	MOV	REG1, #249		;atraso de 0,5 segundo
DELAY05s1:	CALL	DELAY1m
		CALL	DELAY1m
		CALL	DELAY5u
		NOP
		DJNZ	REG1, DELAY05s1
		NOP
		NOP
		RET

DELAY1s:	CALL	DELAY05s		;atraso de 1 segundo
		CALL	DELAY05s
		RET

DELAY2s:	CALL	DELAY1s			;atraso de 2 segundos
		CALL	DELAY1s
		RET

DES_D:		SETB	P2.1			;desliga motor direita
		SETB	P2.2
		RET

DES_E:		SETB	P2.3			;desliga motor esquerda
		SETB	P2.4
		RET

LIG_D_F:	SETB	P2.1			;liga motor direita p/ frente
		CLR	P2.2
		RET


LIG_D_T:	CLR	P2.1			;liga motor direita p/ trás
		SETB	P2.2
		RET

LIG_E_F:	CLR	P2.3			;liga motor esquerda p/ frente
		SETB	P2.4
		RET

LIG_E_T:	SETB	P2.3			;liga motor esquerda p/ trás
		CLR	P2.4
		RET

ROT_T0:		PUSH	PSW			;rotina de interrução do Timer 0
		PUSH	ACC			;gera 3 ondas PWM em P2.0, P2.5 e P2.6
		MOV	A, CONT			;as larguras das ondas dependem de
		CLR	C			;V_D, V_E e ANGULO
		SUBB	A, V_D			;para V_D e V_E, cada incremento
		JC	ROT_T0A			;aumenta 1% na largura da onda PWM
		CLR	P2.0			;para ANGULO, cada incremento
		JMP	ROT_T0B			;(somente entre os valores 3 e 12)
ROT_T0A:	SETB	P2.0			;representa aumento de 20º de rotação
ROT_T0B:	MOV	A, CONT			;no eixo do servomotor
		CLR	C			;o período de cada onda PWM é 20ms
		SUBB	A, V_E			;o que significa frequência de 50Hz
		JC	ROT_T0C
		CLR	P2.5
		JMP	ROT_T0D
ROT_T0C: 	SETB	P2.5
ROT_T0D: 	MOV	A, CONT
		CLR	C
		SUBB	A, ANGULO
		JC	ROT_T0E
		CLR	P2.6
		JMP	ROT_T0F
ROT_T0E: 	SETB	P2.6
ROT_T0F: 	INC	CONT
		MOV	A, CONT
		CJNE	A, #100, ROT_T0G
		MOV	CONT, #0
ROT_T0G:	POP	ACC
		POP	PSW
		RETI

CALC_DIST:	MOV	TH1, #0			;Calcula a Distância
		MOV	TL1, #0
		SETB	P2.7			;pulso de Trigger
		CALL	DELAY5u
		CALL	DELAY5u
		CALL	DELAY5u
		CLR	P2.7
CALC1:		JNB	P0.2, CALC1		;espera ECHO ir para alto
		SETB	TCON.6 			;liga o Timer 1
CALC2:		JB	P0.2, CALC2		;espera ECHO voltar para baixo
		CLR	TCON.6			;desliga o Timer 1
		CLR	TCON.7
		MOV	DISTH, TH1
		MOV	DISTL, TL1
		MOV	A, TL1
		RLC	A
		MOV	R2, A
		MOV	A, TH1
		RLC	A
		MOV	R1, A
		MOV	A, R2
		RLC	A
		MOV	A, R1
		RLC	A
		MOV	R1, A
		MOV	B, #11
		DIV	AB
		ADD	A, R1
		MOV	DIST, A
		RET

LER_RADAR_A:	MOV	ANGULO, #3
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST3, DIST
		MOV	ANGULO, #4
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST4, DIST
		MOV	ANGULO, #5
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST5, DIST
		MOV	ANGULO, #6
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST6, DIST
		MOV	ANGULO, #7
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST7, DIST
		MOV	ANGULO, #8
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST8, DIST
		MOV	ANGULO, #9
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST9, DIST
		MOV	ANGULO, #10
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST10, DIST
		MOV	ANGULO, #12
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST12, DIST
		RET

LER_RADAR_H:	MOV	ANGULO, #12
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST12, DIST
		MOV	ANGULO, #10
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST10, DIST
		MOV	ANGULO, #9
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST9, DIST
		MOV	ANGULO, #8
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST8, DIST
		MOV	ANGULO, #7
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST7, DIST
		MOV	ANGULO, #6
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST6, DIST
		MOV	ANGULO, #5
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST5, DIST
		MOV	ANGULO, #4
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST4, DIST
		MOV	ANGULO, #3
		CALL	DELAY100m
		CALL	CALC_DIST
		MOV	DIST3, DIST
		RET

MEDIA:		MOV	A, DIST6
		ADD	A, DIST8
		RRC	A
		ADD	A, DIST7
		RRC	A
		MOV	DIST_F, A
		MOV	A, DIST3
		ADD	A, DIST5
		RRC	A
		ADD	A, DIST4
		RRC	A
		MOV	DIST_D, A
		MOV	A, DIST9
		ADD	A, DIST12
		RRC	A
		ADD	A, DIST10
		RRC	A
		MOV	DIST_E, A
		RET

PROCESSAR:	MOV	A, DIST_E
		CLR	C
		SUBB	A, #CONST1
		JC	Eme
Ema:		MOV	A, DIST_F
		CLR	C
		SUBB	A, #CONST1
		JC	EmaFme
EmaFma:		MOV	A, DIST_D
		CLR	C
		SUBB	A, #CONST1
		JC	EmaFmaDme
EmaFmaDma:	CALL	FRENTE
		JMP	FIM_PROC
EmaFmaDme:	CALL	GIRAR_AH45
		JMP	FIM_PROC
EmaFme:		MOV	A, DIST_D
		CLR	C
		SUBB	A, #CONST1
		JC	EmaFmeDme
EmaFmeDma:	MOV	A, DIST_E
		CLR	C
		SUBB	A, DIST_D
		JC	EmaFmeDma1
		CALL	GIRAR_AH90
		JMP	FIM_PROC
EmaFmeDma1:	CALL	GIRAR_H90
		JMP	FIM_PROC
EmaFmeDme:	CALL	GIRAR_AH90
		JMP	FIM_PROC
Eme:		MOV	A, DIST_F
		CLR	C
		SUBB	A, #CONST1
		JC	EmeFme
EmeFma:		MOV	A, DIST_D
		CLR	C
		SUBB	A, #CONST1
		JC	EmeFmaDme
EmeFmaDma:	CALL	GIRAR_H45
		JMP	FIM_PROC
EmeFmaDme:	CALL	PARAR
		JMP	FIM_PROC
EmeFme:		MOV	A, DIST_D
		CLR	C
		SUBB	A, #CONST1
		JC	EmeFmeDme
EmeFmeDma:	CALL	GIRAR_H90
		JMP	FIM_PROC
EmeFmeDme:	CALL	PARAR
FIM_PROC:	RET

PARAR:		CALL	DES_D
		CALL	DES_E
		RET

FRENTE:		MOV	V_D, #100
		MOV	V_E, #100
		CALL	LIG_D_F
		CALL	LIG_E_F
		MOV	A, DIST_F
		CLR	C
		SUBB	A, #CONST2
		JC	FRENTE1
		CALL	DELAY100m
FRENTE1:	CALL	DELAY100m
		CALL	PARAR
		RET



GIRAR_H45:	MOV	V_D, #100
		MOV	V_E, #100
		CALL	LIG_D_T
		CALL	LIG_E_F
		CALL	DELAY100m
		CALL	PARAR
		RET

GIRAR_H90:	MOV	V_D, #100
		MOV	V_E, #100
		CALL	LIG_D_T
		CALL	LIG_E_F
		CALL	DELAY100m
		CALL	DELAY100m
		CALL	PARAR
		RET

GIRAR_AH45:	MOV	V_D, #100
		MOV	V_E, #100
		CALL	LIG_D_F
		CALL	LIG_E_T
		CALL	DELAY100m
		CALL	PARAR
		RET

GIRAR_AH90:	MOV	V_D, #100
		MOV	V_E, #100
		CALL	LIG_D_F
		CALL	LIG_E_T
		CALL	DELAY100m
		CALL	DELAY100m
		CALL	PARAR
		RET


ROT_SER:
		PUSH	PSW
		PUSH	ACC
		CLR	SCON.1
		MOV	A, FLAG
		CJNE	A, #0, ROT_SER1
		MOV	SBUF, #0
		INC	FLAG
		MOV	R0, #DIST3
		JMP	FIM_ROT_SER
ROT_SER1:	MOV	A, @R0
		MOV	SBUF, A
		INC	FLAG
		INC	R0
		MOV	A, FLAG
		CJNE	A, #10, FIM_ROT_SER
		MOV	FLAG, #0
FIM_ROT_SER:
		POP	ACC
		POP	PSW
		RETI



MENS_1:		DB	"VALOR DIR:", 0
MENS_2:		DB	"VALOR ESQ:", 0

END
