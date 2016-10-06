;**********************************************************************
;**********************************************************************

;               PROGRAMA PARA RECEBER DADOS DA PLATAFORMA MÓVEL

;**********************************************************************
;**********************************************************************


DADO            SEGMENT

CONT1           DB      0
CONT2           DB      0
LINHA_10        DB      3
COLUNA_10       DB      39
LINHA_30        DB      10
COLUNA_30       DB      37
LINHA_50        DB      15
COLUNA_50       DB      32
LINHA_70        DB      18
COLUNA_70       DB      26
LINHA_90        DB      20
COLUNA_90       DB      20
LINHA_110       DB      18
COLUNA_110      DB      14
LINHA_130       DB      15
COLUNA_130      DB      8
LINHA_150       DB      10
COLUNA_150      DB      3
LINHA_170       DB      3
COLUNA_170      DB      1
DIST3           DB      100
DIST4           DB      100
DIST5           DB      100
DIST6           DB      100
DIST7           DB      100
DIST8           DB      100
DIST9           DB      100
DIST10          DB      100
DIST12          DB      100

DADO            ENDS


PILHA           SEGMENT

                DW      100 DUP(?)
TOPO            LABEL   WORD

PILHA           ENDS


                
CODIGO          SEGMENT

ASSUME          CS:CODIGO,DS:DADO,SS:PILHA

INICIO:         MOV     AX, DADO
                MOV     DS, AX
                MOV     AX, PILHA
                MOV     SS, AX
                MOV     SP, OFFSET TOPO

                MOV     CONT1, 0
                MOV     CONT2, 0

                MOV     AH, 0                   ;Video modo 40x25
                MOV     AL, 1
                INT     10H

                MOV     AH, 2
                MOV     BH, 0
                MOV     DH, 21
                MOV     DL, 20
                INT     10H
                MOV     AL, 2
                CALL    ESC_CAR

                MOV     AL, 11000011B           ;Programar serial
                MOV     AH, 0
                MOV     DX, 0
                INT     14H


VOLTA:          MOV     AH, 1
                INT     16H
                JZ      VER_SER
                MOV     AH, 0
                INT     16H
                CMP     AH, 1
                JNE     VER_SER

FIM:            MOV     AH, 0
                MOV     AL, 3
                INT     10H
                MOV     AH, 4CH
                INT     21H

VER_SER:        MOV     AH, 3
                INT     14H
                AND     AH, 1
                JNZ     VER_SER1
                JMP     MOSTRAR
VER_SER1:       MOV     AH, 2
                INT     14H
                CMP     AL, 0
                JNZ     RECEBE0
                MOV     CONT1, 0
                JMP     VOLTA
RECEBE0:        CMP     CONT1, 0
                JNZ     RECEBE1
                MOV     DIST3, AL
                INC     CONT1
                JMP     VOLTA
RECEBE1:        CMP     CONT1, 1
                JNZ     RECEBE2
                MOV     DIST4, AL
                INC     CONT1
                JMP     VOLTA
RECEBE2:        CMP     CONT1, 2
                JNZ     RECEBE3
                MOV     DIST5, AL
                INC     CONT1
                JMP     VOLTA
RECEBE3:        CMP     CONT1, 3
                JNZ     RECEBE4
                MOV     DIST6, AL
                INC     CONT1
                JMP     VOLTA
RECEBE4:        CMP     CONT1, 4
                JNZ     RECEBE5
                MOV     DIST7, AL
                INC     CONT1
                JMP     VOLTA
RECEBE5:        CMP     CONT1, 5
                JNZ     RECEBE6
                MOV     DIST8, AL
                INC     CONT1
                JMP     VOLTA
RECEBE6:        CMP     CONT1, 6
                JNZ     RECEBE7
                MOV     DIST9, AL
                INC     CONT1
                JMP     VOLTA
RECEBE7:        CMP     CONT1, 7
                JNZ     RECEBE8
                MOV     DIST10, AL
                INC     CONT1
                JMP     VOLTA
RECEBE8:        CMP     CONT1, 8
                JNZ     RECEBE9
                MOV     DIST12, AL
RECEBE9:        MOV     CONT1, 0
                JMP     VOLTA



MOSTRAR:
                CMP     CONT2, 0
                JNZ     MOSTRAR1
                CALL    CALC_10
                INC     CONT2
                JMP     VOLTA
MOSTRAR1:       CMP     CONT2, 1
                JNZ     MOSTRAR2
                CALL    CALC_30
                INC     CONT2
                JMP     VOLTA
MOSTRAR2:       CMP     CONT2, 2
                JNZ     MOSTRAR3
                CALL    CALC_50
                INC     CONT2
                JMP     VOLTA
MOSTRAR3:       CMP     CONT2, 3
                JNZ     MOSTRAR4
                CALL    CALC_70
                INC     CONT2
                JMP     VOLTA
MOSTRAR4:       CMP     CONT2, 4
                JNZ     MOSTRAR5
                CALL    CALC_90
                INC     CONT2
                JMP     VOLTA
MOSTRAR5:       CMP     CONT2, 5
                JNZ     MOSTRAR6
                CALL    CALC_110
                INC     CONT2
                JMP     VOLTA
MOSTRAR6:       CMP     CONT2, 6
                JNZ     MOSTRAR7
                CALL    CALC_130
                INC     CONT2
                JMP     VOLTA
MOSTRAR7:       CMP     CONT2, 7
                JNZ     MOSTRAR8
                CALL    CALC_150
                INC     CONT2
                JMP     VOLTA
MOSTRAR8:       CMP     CONT2, 8
                JNZ     MOSTRAR9
                CALL    CALC_170
MOSTRAR9:       MOV     CONT2, 0
                JMP     VOLTA



;------------------------------------------------------------

;               SUB-ROTINAS

;------------------------------------------------------------



ESC_CAR:        MOV     AH, 10
                MOV     BH, 0
                MOV     CX, 1
                INT     10H
                RET


POS_CUR_10:     MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_10
                MOV     DL, COLUNA_10
                INT     10H
                RET


POS_CUR_30:     MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_30
                MOV     DL, COLUNA_30
                INT     10H
                RET


POS_CUR_50:     MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_50
                MOV     DL, COLUNA_50
                INT     10H
                RET


POS_CUR_70:     MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_70
                MOV     DL, COLUNA_70
                INT     10H
                RET


POS_CUR_90:     MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_90
                MOV     DL, COLUNA_90
                INT     10H
                RET


POS_CUR_110:    MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_110
                MOV     DL, COLUNA_110
                INT     10H
                RET


POS_CUR_130:    MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_130
                MOV     DL, COLUNA_130
                INT     10H
                RET


POS_CUR_150:    MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_150
                MOV     DL, COLUNA_150
                INT     10H
                RET


POS_CUR_170:    MOV     AH, 2
                MOV     BH, 0
                MOV     DH, LINHA_170
                MOV     DL, COLUNA_170
                INT     10H
                RET


CALC_10:        CALL    POS_CUR_10
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST3, 100
                JC      CALC_10A
                MOV     DIST3, 100
CALC_10A:       MOV     AL, DIST3
                MOV     BL, 35
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_10, BL
                MOV     AL, DIST3
                MOV     BL, 197
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                ADD     AL, 20
                MOV     COLUNA_10, AL
                CALL    POS_CUR_10
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_30:        CALL    POS_CUR_30
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST4, 100
                JC      CALC_30A
                MOV     DIST4, 100
CALC_30A:       MOV     AL, DIST4
                MOV     BL, 100
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_30, BL
                MOV     AL, DIST4
                MOV     BL, 173
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                ADD     AL, 20
                MOV     COLUNA_30, AL


                CALL    POS_CUR_30
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_50:        CALL    POS_CUR_50
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST5, 100
                JC      CALC_50A
                MOV     DIST5, 100
CALC_50A:       MOV     AL, DIST5
                MOV     BL, 153
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_50, BL
                MOV     AL, DIST5
                MOV     BL, 128
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                ADD     AL, 20
                MOV     COLUNA_50, AL
                CALL    POS_CUR_50
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_70:        CALL    POS_CUR_70
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST6, 100
                JC      CALC_70A
                MOV     DIST6, 100
CALC_70A:       MOV     AL, DIST6
                MOV     BL, 188
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_70, BL
                MOV     AL, DIST6
                MOV     BL, 68
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                ADD     AL, 20
                MOV     COLUNA_70, AL
                CALL    POS_CUR_70
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_90:        CALL    POS_CUR_90
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST7, 100
                JC      CALC_90A
                MOV     DIST7, 100
CALC_90A:       MOV     AL, DIST7
                MOV     BL, 200
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_90, BL
                MOV     AL, DIST7
                MOV     BL, 0
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                ADD     AL, 20
                MOV     COLUNA_90, AL
                CALL    POS_CUR_90
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_110:       CALL    POS_CUR_110
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST8, 100
                JC      CALC_110A
                MOV     DIST8, 100
CALC_110A:      MOV     AL, DIST8
                MOV     BL, 188
                MUL     BL


                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_110, BL
                MOV     AL, DIST8
                MOV     BL, 68
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     COLUNA_110, BL
                CALL    POS_CUR_110
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_130:       CALL    POS_CUR_130
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST9, 100
                JC      CALC_130A
                MOV     DIST9, 100
CALC_130A:      MOV     AL, DIST9
                MOV     BL, 153
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_130, BL
                MOV     AL, DIST9
                MOV     BL, 128
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     COLUNA_130, BL
                CALL    POS_CUR_130
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_150:       CALL    POS_CUR_150
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST10, 100
                JC      CALC_150A
                MOV     DIST10, 100
CALC_150A:      MOV     AL, DIST10
                MOV     BL, 100
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_150, BL
                MOV     AL, DIST10
                MOV     BL, 173
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     COLUNA_150, BL
                CALL    POS_CUR_150
                MOV     AL, 1
                CALL    ESC_CAR
                RET


CALC_170:       CALL    POS_CUR_170
                MOV     AL, 0
                CALL    ESC_CAR
                CMP     DIST12, 100
                JC      CALC_170A
                MOV     DIST12, 100
CALC_170A:      MOV     AL, DIST12
                MOV     BL, 35
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     LINHA_170, BL
                MOV     AL, DIST12
                MOV     BL, 197
                MUL     BL
                MOV     DX, 0
                MOV     BX, 1000
                DIV     BX
                MOV     BL, 20
                SUB     BL, AL
                MOV     COLUNA_170, BL
                CALL    POS_CUR_170
                MOV     AL, 1
                CALL    ESC_CAR
                RET



CODIGO		ENDS

END             INICIO
