;*************************************
;*                                   *
;*      AVALIADOR DE EXPRESSÕES      *
;*                                   *
;*************************************
;       Grupo:                       *
;*************************************
;    Davi Paulino                    *
;    Felipe Tuyama                   *
;    João Vitor                      *
;*************************************

JUMPS    ;para evitar jumps out of ranges
ASSUME CS: CODIGO, DS:DADOS, SS:PILHA

;*****************************
;*     SEGMENTO DE DADOS       *
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
    MENS1 DB 'REX $'
    MENS4 DB 'FORMA BINARIA INFIXA.$'
    MENS5 DB 'FORMA BINARIA POSFIXA.$'
    MENS6 DB 'RESULTADO: $'
    MENS7 DB 'DIGITE "S" PARA SAIR. $'
    MENS8 DB 'OVERFLOW DO OPERANDO $'
    MENS9 DB 'OVERFLOW DO RESULTADO $'
    MENS10 DB 'DIVISAO POR ZERO $'

    ; Variaveis REX
    MENSAGEM1 DB ' EXPRESSAO VALIDA! $'
    MENSAGEM2 DB ' EXPRESSAO INVALIDA! $'
    EXPRESSAO1 DB 200 DUP(0)
    EXPRESSAO2 DB 200 DUP(0)
    EXPRESSAO3 DB 200 DUP(0)
    PILHAPOS DB 100 DUP(0)
    PONT1 DW 0

DADOS ENDS

;*****************************
;*     SEGMENTO DE PILHA          *
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
    MOV PILHAPOS[0], '$'

;*************************************
;*                                   *
;*           MAIN                    *
;*                                   *
;*************************************
MAIN_LOOP:
    CALL LIMPAR_VETOR
    CALL LIMPAR_TELA
    CALL MOLDURA
    CALL ESC_TITULO

    CALL ENT_EX ;admitir expressão
    CALL REC_EX ;validar expressão
    CALL ESC_RES
    CMP FLAG, 0
    JNE SAIR_CALC
    CALL AJ_REC_REX
    CMP FLAG, 0
    JNE OVER_CALC
    CALL TESTE_REX
    CALL POSFIXA
    CALL TESTE_POS
    CALL AVALIA
    CMP FLAG, 0
    JNE OVER_CALC
    CALL AMOSTRA
    JMP SAIR_CALC
OVER_CALC:
    CALL MENS_OVER
SAIR_CALC:
    CALL MENS_EXIT
    CALL LER_TECLA
    CMP AL, 's'
    JNE MAIN_LOOP
    CALL LIMPAR_TELA
    MOV AH, 4CH
    INT 21H ;término do programa

;*************************************
;*                                   *
;*      AVALIAÇÃO DE EXPRESSÕES      *
;*                                   *
;*************************************
AVALIA:

;*****************************
;        AVALIA NÚMERO      *
;*****************************
    MOV  SI, PONT1

    CMP BYTE PTR EXPRESSAO3[SI], '$'
    JE  FIM_LOOP_AVALIA

    CMP BYTE PTR EXPRESSAO3[SI], 'b'
    JNE AVALIA_NOT_NUMBER

    CMP BYTE PTR EXPRESSAO3[SI+9], '>'
    JE  INICIO_CROP
    CMP BYTE PTR EXPRESSAO3[SI+9], '<'
    JNE FIM_AVALIA_CROP


; Faz o complemento do número se o sinal é negativo
;*****************************************
    MOV SI, OFFSET EXPRESSAO3
    ADD SI, PONT1
    INC SI
    MOV AL, '-'
    CALL COMPLEMENTA
    MOV  SI, PONT1

; Remove o operador unário do número em binário
;*****************************************
INICIO_CROP:
    MOV BX, PONT1
    ADD BX, 9
AVALIA_CROP:
    CMP BYTE PTR EXPRESSAO3[BX], '$'
    JE FIM_AVALIA_CROP
    MOV AL, EXPRESSAO3[BX+1]
    MOV EXPRESSAO3[BX], AL
    INC BX
    JMP AVALIA_CROP
FIM_AVALIA_CROP:

    MOV AX, PONT1
    ADD AX, 9
    MOV PONT1, AX
    JMP AVALIA

;*****************************
;       AVALIA OPERAÇÃO      *
;*****************************
AVALIA_NOT_NUMBER:

    MOV BX, PONT1
    SUB BX, 18

; Transfere primeiro operando para NUM_BIN1
;*****************************************
    MOV SINAL1, '+'
    MOV AL, EXPRESSAO3[BX+1]
    AND AL, 80H
    JZ  LOOP_AVALIA_NUM1A

    MOV SINAL1, '-'

    MOV SI, OFFSET EXPRESSAO3
    ADD SI, BX
    INC SI
    MOV AL, '-'
    CALL COMPLEMENTA

LOOP_AVALIA_NUM1A:
    MOV SI, PONT1
    SUB SI, 18
    MOV BX, 0
    MOV CX, 8
LOOP_AVALIA_NUM1:
    INC SI
    MOV AL, EXPRESSAO3[SI]
    MOV NUM_BIN1[BX], AL
    INC BX
    LOOP LOOP_AVALIA_NUM1

; Transfere segundo operando para NUM_BIN2
;*****************************************

    MOV BX, PONT1
    SUB BX, 9

    MOV SINAL2, '+'
    MOV AL, EXPRESSAO3[BX+1]
    AND AL, 80H
    JZ  LOOP_AVALIA_NUM2A

    MOV SINAL2, '-'

    MOV SI, OFFSET EXPRESSAO3
    ADD SI, BX
    INC SI
    MOV AL, '-'
    CALL COMPLEMENTA

LOOP_AVALIA_NUM2A:
    MOV SI, PONT1
    SUB SI, 9
    MOV BX, 0
    MOV CX, 8
LOOP_AVALIA_NUM2:
    INC SI
    MOV AL, EXPRESSAO3[SI]
    MOV NUM_BIN2[BX], AL
    INC BX
    LOOP LOOP_AVALIA_NUM2

; Faz a operação desejada
;*****************************************
    MOV BX, PONT1
    MOV AL, BYTE PTR EXPRESSAO3[BX]
    MOV OPERADOR, AL
    CALL CALCULA
    CMP FLAG, 0
    JNE FIM_AVALIA

; Complementa o resultado, se necessário
;*****************************************
    CMP SINALR, '-'
    JNE COPIA_RESULTADO

    MOV SI, OFFSET RES_BIN
    MOV AL, '-'
    CALL COMPLEMENTA

; Copia o resultado para o operando1
;*****************************************

COPIA_RESULTADO:
    MOV SI, PONT1
    SUB SI, 18
    MOV BX, 0
    MOV CX, 8
LOOP_OVERRIDE_OPERANDO1:
    INC SI
    MOV AL, RES_BIN[BX]
    MOV EXPRESSAO3[SI], AL
    INC BX
    LOOP LOOP_OVERRIDE_OPERANDO1

; Retira o operando2 da expressão3
;*****************************************
INICIO_CROP2:
    MOV BX, PONT1
    SUB BX, 9
    MOV SI, PONT1
AVALIA_CROP2:
    INC SI
    MOV AL, EXPRESSAO3[SI]
    MOV EXPRESSAO3[BX], AL
    CMP BYTE PTR EXPRESSAO3[BX], '$'
    JE FIM_AVALIA_CROP2
    INC BX
    JMP AVALIA_CROP2
FIM_AVALIA_CROP2:

    MOV BX, PONT1
    SUB BX, 9
    MOV PONT1, BX

    CALL LIMPAR_VETOR
    JMP AVALIA

;*****************************
;       AVALIA CIFRÃO        *
;*****************************
FIM_LOOP_AVALIA:

    MOV SINALR, '+'
    MOV AL, EXPRESSAO3[1]
    AND AL, 80H
    JZ  FIM_AVALIA

    MOV SINALR, '-'

    MOV SI, OFFSET EXPRESSAO3
    INC SI
    MOV AL, '-'
    CALL COMPLEMENTA

FIM_AVALIA:
    RET

;*************************************
;*                                   *
;*            MOSTRA                 *
;*                                   *
;*************************************
AMOSTRA:

    MOV BX, 8
LOOP_RESPOSTA:
    MOV AL, EXPRESSAO3[BX]
    MOV RES_BIN[BX-1], AL
    DEC BX
    JNZ  LOOP_RESPOSTA

    CALL CONV_BIN_BCD
    CALL CONV_BCD_ASC
    CALL AJUSTA
    CALL MOSTRA
    RET
;*************************************
;*                                                                      *
;*            POSFIXA                             *
;*                                                                      *
;*************************************
POSFIXA:
    MOV SI, 0
    MOV DI, 0
    MOV BX, 0

LOOP_POSFIXA:

    ;Verifica  se o caracter é um número
    CMP EXPRESSAO2[SI], 'b'
    JNE NOT_NUM
    MOV CX, 9
    CALL COPY_NUM
    JMP LOOP_POSFIXA


NOT_NUM:
    CMP EXPRESSAO2[SI], '('
    JE  IS_P_FIVE
    CMP EXPRESSAO2[SI], '<'
    JE  IS_P_FIVE
    CMP EXPRESSAO2[SI], '>'
    JNE NOT_P_FIVE
IS_P_FIVE:
    MOV AH, EXPRESSAO2[SI]
    INC SI
    INC BX
    MOV PILHAPOS[BX], AH
    JMP LOOP_POSFIXA



NOT_P_FIVE:
    CMP EXPRESSAO2[SI], '*'
    JE  IS_P_THREE
    CMP EXPRESSAO2[SI], '\'
    JE  IS_P_THREE
    CMP EXPRESSAO2[SI], '/'
    JNE NOT_P_THREE

IS_P_THREE:
    CMP PILHAPOS[BX], '<'
    JE  DES_P_FOUR
    CMP PILHAPOS[BX], '>'
    JE  DES_P_FOUR
    CMP PILHAPOS[BX], '*'
    JE  DES_P_FOUR
    CMP PILHAPOS[BX], '/'
    JE  DES_P_FOUR
    CMP PILHAPOS[BX], '\'
    JE  DES_P_FOUR
    MOV AH, EXPRESSAO2[SI]
    INC SI
    INC BX
    MOV PILHAPOS[BX], AH
    JMP LOOP_POSFIXA
DES_P_FOUR:
    MOV AL, PILHAPOS[BX]
    MOV EXPRESSAO3[DI], AL
    DEC BX
    INC DI
    JMP IS_P_THREE



NOT_P_THREE:
    CMP EXPRESSAO2[SI], '+'
    JE  IS_P_TWO
    CMP EXPRESSAO2[SI], '-'
    JNE NOT_P_TWO
IS_P_TWO:
    CMP PILHAPOS[BX], '('
    JE  EMP_P_TWO
    CMP PILHAPOS[BX], '$'
    JE  EMP_P_TWO
    MOV AL, PILHAPOS[BX]
    MOV EXPRESSAO3[DI], AL
    DEC BX
    INC DI
    JMP IS_P_TWO
EMP_P_TWO:
    MOV AH, EXPRESSAO2[SI]
    INC SI
    INC BX
    MOV PILHAPOS[BX], AH
    JMP LOOP_POSFIXA



NOT_P_TWO:
    CMP EXPRESSAO2[SI], ')'
    JNE NOT_CLOSED

PROCURA_OPEN:
    CMP PILHAPOS[BX], '('
    JE ENCONTROU_OPEN
    MOV AL, PILHAPOS[BX]
    MOV EXPRESSAO3[DI], AL
    DEC BX
    INC DI
    JMP PROCURA_OPEN
ENCONTROU_OPEN:
    INC SI
    DEC BX
    JMP LOOP_POSFIXA

NOT_CLOSED:
    CMP PILHAPOS[BX], '$'
    JE  FIM_POSFIXA
    MOV AL, PILHAPOS[BX]
    MOV EXPRESSAO3[DI], AL
    DEC BX
    INC DI
    JMP NOT_CLOSED

FIM_POSFIXA:
    MOV EXPRESSAO3[DI], '$'
    RET


; Copia número de EXPRESSAO2 para EXPRESSAO3
COPY_NUM:
    MOV AL, EXPRESSAO2[SI]
    MOV EXPRESSAO3[DI], AL
    INC SI
    INC DI
    LOOP COPY_NUM
    RET

;*************************************
;*                                                                      *
;*            TESTE_POS                             *
;*                                                                      *
;*************************************
TESTE_POS:
    MOV LINHA, 10
    MOV COLUNA, 16
    CALL POS_CURSOR
    MOV DX, OFFSET MENS5
    CALL ESC_MENS

    MOV LINHA, 11
    MOV COLUNA, 20
    CALL POS_CURSOR
    MOV DX, OFFSET EXPRESSAO3
    CALL ESC_MENS
    RET

;*************************************
;*                                                                      *
;*            TESTE_REX                             *
;*                                                                      *
;*************************************
TESTE_REX:
    MOV LINHA, 8
    MOV COLUNA, 16
    CALL POS_CURSOR
    MOV DX, OFFSET MENS4
    CALL ESC_MENS

    MOV LINHA, 9
    MOV COLUNA, 20
    CALL POS_CURSOR
    MOV DX, OFFSET EXPRESSAO2
    CALL ESC_MENS
    RET


;*************************************
;*                                                                      *
;*            AJ_REC_REX                         *
;*                                                                      *
;*************************************
;Verifica se é uma expressão válida, se for, faz a conversão dos números para forma binária
AJ_REC_REX:
    MOV SI, OFFSET EXPRESSAO1
    MOV DI, OFFSET EXPRESSAO2

LOOP_COPY:
    CMP BYTE PTR[SI][0], '$' ;expressão vazia
    JE  FIM_LOOP_COPY

    ;Verifica  se o caracter é um número
    CMP BYTE PTR[SI][0], 30H
    JB  LOOP_NAO_NUM
    CMP BYTE PTR[SI][0], 39H
    JA  LOOP_NAO_NUM
    MOV BX, 0

    ;Se for número, armazena-o em um vetor
    LOOP_NUM:
        CMP BYTE PTR[SI][0], 30H
        JB  END_LOOP_NUM
        CMP BYTE PTR[SI][0], 39H
        JA  END_LOOP_NUM

        MOV AL, [SI][0]
        MOV NUM_ASC1[BX], AL
        INC BX
        INC SI
        JMP LOOP_NUM
    END_LOOP_NUM:

        CMP BX, 20
        JB  CONVERT_NUMBER
        MOV FLAG, 1
        JMP FIM_LOOP_COPY

    ;Faz a conversão dos números para a forma binária
    CONVERT_NUMBER:
        MOV CX, 20
        SUB CX, BX
    SHIFT_NUMBER:
        DEC BX
        MOV AL, NUM_ASC1[BX]
        PUSH BX
        ADD BX, CX
        MOV NUM_ASC1[BX], AL
        POP BX
        CMP BX, 0
        JNE SHIFT_NUMBER

        MOV BX, CX
    SHIFT_NUMBER2:
        DEC BX
        MOV NUM_ASC1[BX], 00H
        CMP BX, 0
        JNE SHIFT_NUMBER2

    END_SHIFT_NUMBER:

        PUSH SI
        PUSH DI
        MOV  SI, OFFSET NUM_ASC1
        MOV  DI, OFFSET NUM_BCD1
        ;Como o código do calculadora foi aproveitado, primeiro transforma o número para BCD, depois transforma em binário
        CALL CONV_ASC_BCD
        CMP  FLAG, 1
        JE   FIM_LOOP_COPY
        MOV  SI, OFFSET NUM_BCD1
        CALL CONV_BCD_BIN
        CMP  FLAG, 1
        JE   FIM_LOOP_COPY
        POP  DI
        POP  SI

        MOV BX, 0
        ;Antes de representar qualquer número, é colocado o caracter 'b' para indicar que é binário
        MOV BYTE PTR[DI][0], 'b'
        INC DI
    LOOP_COPY_BIN:
        CMP BX, 8
        JE  LOOP_COPY
        MOV AL, NUM_BIN1[BX]
        MOV [DI][0], AL
        INC BX
        INC DI
        JMP LOOP_COPY_BIN


LOOP_NAO_NUM:
    MOV AL, [SI][0]
    MOV [DI][0], AL
    INC SI
    INC DI
    JMP LOOP_COPY

FIM_LOOP_COPY:
    MOV AL, [SI][0]
    MOV [DI][0], AL
    INC SI
    INC DI
    RET

;*****************************************
;*                                       *
;*           ESC_REX                     *
;*                                       *
;*****************************************
;Responsável pelas rotinas de exibição da REX
ESC_RES:
    MOV LINHA, 6
    MOV COLUNA, 20
    CALL POS_CURSOR
    MOV DX, OFFSET MENSAGEM1
    CMP FLAG, 0
    JE  ESC_MSG
    MOV DX, OFFSET MENSAGEM2
ESC_MSG:
    CALL ESC_MENS
    RET

;*****************************************
;*                                       *
;*           REC_REX                     *
;*                                       *
;*****************************************
REC_EX:
    MOV CONT, 0
    MOV BX, 0
    JMP CHECK_INICIO

;*****************************************
;*                                       *
;*           ESTADO - INICIO             *
;*                                       *
;*****************************************

INICIO_EX:
    INC BX
CHECK_INICIO:
    CMP EXPRESSAO1[BX], '('
    JNE INICIO_EX2
    INC CONT
    JMP INICIO_EX
INICIO_EX2:
    CMP EXPRESSAO1[BX], '+'
    JE  SINAL_P_EX
    CMP EXPRESSAO1[BX], '-'
    JE  SINAL_N_EX

    CMP EXPRESSAO1[BX], 30H
    JB  REJEITA
    CMP EXPRESSAO1[BX], 39H
    JA  REJEITA
    JMP NUM_EX

;*****************************************
;*                                       *
;*              ESTADO - SINAL_N         *
;*                                       *
;*****************************************

SINAL_N_EX:
    MOV EXPRESSAO1[BX], '<'
    INC BX
    CMP EXPRESSAO1[BX], '('
    JNE SINAL_N_EX2
    INC CONT
    JMP INICIO_EX
SINAL_N_EX2:
    CMP EXPRESSAO1[BX], 30H
    JB  REJEITA
    CMP EXPRESSAO1[BX], 39H
    JA  REJEITA
    JMP NUM_EX

;*****************************************
;*                                       *
;*         ESTADO - SINAL_P              *
;*                                       *
;*****************************************

SINAL_P_EX:
    MOV EXPRESSAO1[BX], '>'
    INC BX
    CMP EXPRESSAO1[BX], '('
    JNE SINAL_P_EX2
    INC CONT
    JMP INICIO_EX
SINAL_P_EX2:
    CMP EXPRESSAO1[BX], 30H
    JB  REJEITA
    CMP EXPRESSAO1[BX], 39H
    JA  REJEITA
    JMP NUM_EX

;*****************************************
;*                                       *
;*          ESTADO - NUM                 *
;*                                       *
;*****************************************

NUM_EX:
    INC BX
    CMP EXPRESSAO1[BX], '+'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '-'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '*'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '\'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '/'
    JE  OPERADOR_EX

    CMP EXPRESSAO1[BX], ')'
    JE  NUM_EX_FECHA

    CMP EXPRESSAO1[BX], '$'
    JE  EX_FINALIZA

    CMP EXPRESSAO1[BX], 30H
    JB  REJEITA
    CMP EXPRESSAO1[BX], 39H
    JA  REJEITA
    JMP NUM_EX

NUM_EX_FECHA:
    CMP CONT, 0
    JE  REJEITA
    DEC CONT
    JMP FPAR_EX

;*****************************************
;*                                       *
;*         ESTADO - OPERADOR             *
;*                                       *
;*****************************************

OPERADOR_EX:
    INC BX
    CMP EXPRESSAO1[BX], '('
    JNE OPERADOR_EX2
    INC CONT
    JMP INICIO_EX
OPERADOR_EX2:
    CMP EXPRESSAO1[BX], 30H
    JB  REJEITA
    CMP EXPRESSAO1[BX], 39H
    JA  REJEITA
    JMP NUM_EX

;*****************************************
;*                                       *
;*         ESTADO - FPAR                 *
;*                                       *
;*****************************************

FPAR_EX:
    INC BX
    CMP EXPRESSAO1[BX], '+'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '-'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '*'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '\'
    JE  OPERADOR_EX
    CMP EXPRESSAO1[BX], '/'
    JE  OPERADOR_EX

    CMP EXPRESSAO1[BX], ')'
    JE  FPAR_FECHA

    CMP EXPRESSAO1[BX], '$'
    JE  EX_FINALIZA

    JMP REJEITA

FPAR_FECHA:
    CMP CONT, 0
    JE  REJEITA
    DEC CONT
    JMP FPAR_EX

;*****************************************
;*                                       *
;*      ESTADO - ACEITA/REJEITA          *
;*                                       *
;*****************************************
EX_FINALIZA:
    MOV FLAG, 0
    CMP CONT, 0
    JE  FIM_REC_EX
REJEITA:
    MOV FLAG, 1
FIM_REC_EX:
    RET
;*************************************
;*                                   *
;*            ENT_REX                *
;*                                   *
;*************************************
;Responsável pelas subrotinas de leitura

ENT_EX:
    MOV CONT, 0
    MOV LINHA, 5
    MOV COLUNA, 20
    MOV BX, 0
    MOV EXPRESSAO1[BX], '$'
VER_EX:
    CALL POS_CURSOR
    MOV DX, OFFSET EXPRESSAO1
    CALL ESC_MENS
    CALL LER_TECLA

VER_ENTER_EX:
    CMP AL, 13
    JE  FIM_ENT_EX

VER_MAIS_EX:
    CMP AL, '+'
    JE ADD_TO_EXPRESSAO
    CMP AL, '-'
    JE ADD_TO_EXPRESSAO
    CMP AL, '*'
    JE ADD_TO_EXPRESSAO
    CMP AL, '\'
    JE ADD_TO_EXPRESSAO
    CMP AL, '/'
    JE ADD_TO_EXPRESSAO
    CMP AL, '('
    JE ADD_TO_EXPRESSAO
    CMP AL, ')'
    JE ADD_TO_EXPRESSAO

VER_NUM_EX:
    CMP AL, 30H
    JB  VER_EX
    CMP AL, 39H
    JA  VER_EX

ADD_TO_EXPRESSAO:
    MOV EXPRESSAO1[BX], AL
    INC BX
    MOV EXPRESSAO1[BX], '$'
    JMP VER_EX

FIM_ENT_EX:
    RET

;*************************************
;*                                   *
;*       SUBROTINAS DE TESTE         *
;*                                   *
;*************************************

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
;Determina qual operação será feita
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
;*        ADIÇÃO             *
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
;*              SUBTRAÇÃO                *
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
;*       MULTIPLICAÇÃO     *
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
;*        DIVISÃO            *
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
;*         RESTO             *
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
;*            COMPLEMENTO      *
;*****************************
;Faz o complemento de 2 do número
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
;*      SUBROTINAS DE EXIBIÇÃO       *
;*                                   *
;*************************************
; Mostra a resposta na tela
MOSTRA:
    ;insere o resultado da operação feita
    MOV LINHA, 13
    MOV COLUNA, 5

    CALL POS_CURSOR
    MOV DX, OFFSET MENS6
    CALL ESC_MENS

    ;insere o resultado da operação feita
    MOV LINHA, 13
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
    RET

;Escreve o título jogo na tela
MENS_EXIT:
    MOV LINHA, 18
    MOV COLUNA, 32
    CALL POS_CURSOR

    MOV DX, OFFSET MENS7
    CALL ESC_MENS
    RET
;*************************************
;*                                   *
;*     SUBROTINAS PARA LIMPEZA       *
;*                                   *
;*************************************
;*****************************
;      LIMPA VETORES         *
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
;     LIMPA 0's à esquerda   *
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
;       LIMPA A TELA         *
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
;         POSICIONA CURSOR         *
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
    JE   LOOP2
    MOV  COLUNA, 75
    CALL ESC_MOLD

    MOV COLUNA, 3
    CALL ESC_MOLD

        INC LINHA
    JMP LOOP1

; Loop que cria as molduras horizontais
LOOP2:
    CMP  COLUNA, 75
    JE    FIM_MOLD
    MOV  LINHA, 2
    CALL ESC_MOLD

    MOV  LINHA, 23
    CALL ESC_MOLD

        INC COLUNA
    JMP LOOP2

FIM_MOLD:
    RET

;***************************************
CODIGO ENDS;

END INICIO