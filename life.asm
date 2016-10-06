;*****************************
;                *
;  LIFE - MY FIRST SOFTWARE  *
;                            *
;*****************************
;    Grupo:              *
;*****************************
;    Davi Paulino                                *
;    Felipe Tuyama                             *
;    João Vitor                                    *
;*****************************

ASSUME CS: CODIGO, DS:DADOS, SS:PILHA

;***************************
DADOS SEGMENT

    MENSAGEM DB "!WELCOME TO LIFE!$"
    LINHA DB 5
    COLUNA DB 12
    LINHA2 DB 5
    COLUNA2 DB 12
    FLAG DB 0
    MAT1 DB 289 DUP(0)
    MAT2 DB 289 DUP(0)
    PONT DW 18
    NVIZ DB 0

DADOS ENDS
;***************************
PILHA SEGMENT
    DW 100 DUP(?)
    TOPO_PILHA LABEL WORD
PILHA ENDS
;***************************

CODIGO SEGMENT 

; Inicialização de DS, SS, SP
;  configuração de vídeo
;  escrita do título na tela
;  desenho da moldura do editor
INICIO: 
    MOV AX, DADOS
    MOV DS, AX
    MOV AX, PILHA
    MOV SS, AX
    MOV SP, OFFSET TOPO_PILHA

    CALL VIDEO_40
    CALL ESC_TITULO
    CALL MOLDURA
    
; Loop que permite editar/evoluir o sistema,
;   mostrando cada geração na tela.
NOVO:   
    CALL EDITOR
    CMP FLAG,1
    JE FIM
    CALL AUTOMATO
    CALL MOSTRAR
    JMP NOVO

; Retorna configuração de vídeo original
;   e sai do programa.
FIM:    
    CALL VIDEO_80
    MOV AH, 4CH
    INT 21H

;************************
;       TITULO          *
;************************
; Escreve o título do jogo na tela
ESC_TITULO:
    MOV LINHA, 2
    MOV COLUNA, 11
    
    CALL POS_CURSOR
    CALL ESC_MENS
    
    MOV LINHA, 5
    MOV COLUNA, 12
    RET

;************************
;        EDITOR         *
;************************
; Edita a configuração atual do jogo Life,
;   - Teclas direcionais movimentam cursor na tela
;   - Tecla C imprime cara feliz na tela
;   - Tecla Esp apaga cara feliz na tela
;   - Tecla E evolui o sistema, na subrotina AUTOMATO
;   - Tecla Esc sai do programa Life
EDITOR:  
    CALL POS_CURSOR
    CALL LER_TECLA
    JMP VER_CIM

VER_CIM:
     CMP AH,72        ; Checa se a tecla foi pressionada
     JNE VER_BAI
        CMP LINHA,5  ; Checa colisão com moldura
        JE  EDITOR
            DEC LINHA
            SUB PONT, 17
     JMP EDITOR

VER_BAI: 
     CMP AH,80        ; Checa se a tecla foi pressionada
     JNE VER_ESQ
        CMP LINHA,19  ; Checa colisão com moldura
        JE  EDITOR
            INC LINHA
            ADD PONT, 17
     JMP EDITOR

VER_ESQ: 
     CMP AH,75        ; Checa se a tecla foi pressionada
     JNE VER_DIR
        CMP COLUNA,12  ; Checa colisão com moldura
        JE  EDITOR
            DEC COLUNA
            DEC PONT
     JMP EDITOR

VER_DIR: 
     CMP AH,77        ; Checa se a tecla foi pressionada
     JNE VER_c
        CMP COLUNA,26  ; Checa colisão com moldura
        JE  EDITOR
            INC COLUNA
            INC PONT
     JMP EDITOR

VER_C:   
     CMP AL,99        ; Checa se a tecla foi pressionada
     JNE VER_EVO
         MOV SI,PONT
         MOV MAT1[SI], 1
         MOV AL,1
         CALL ESC_CARAC
     JMP EDITOR

VER_EVO: 
     CMP AL,101       ; Checa se a tecla foi pressionada
     JNE VER_ESP
     JMP SAIR_ED

VER_ESP: 
     CMP AL,32        ; Checa se a tecla foi pressionada
     JNE VER_ESc
         MOV SI,PONT
         MOV MAT1[SI], 0
         MOV AL,0
         CALL ESC_CARAC
     JMP EDITOR

VER_ESC: 
     CMP AH,1     ; Checa se a tecla foi pressionada
     JE SAIR_ED1
     JMP EDITOR

; Sai do programa
SAIR_ED1: MOV FLAG,1

; Sai do editor e evolui sistema
SAIR_ED: RET

;************************
;     TESTE         *
;************************
; Funções para testar o correto
;   preenchimento da matriz na memória
AUTO_TESTE:
    MOV SI, 1
AUTO:
    MOV AL, MAT1[SI]
    MOV MAT2[SI-1], AL
    INC SI
    CMP SI, 289
    JNE AUTO
    RET

;************************
;       MOSTRAR       *
;************************   
; Sobrescreve a matriz de próxima geração
;   sobre a de geração atual, exibindo o 
;   resultado na tela.
MOSTRAR:
    CALL COPIAR_MAT
    MOV SI, 18
    MOV LINHA2, 5

MOST2:
    MOV COLUNA2, 12

MOST1:
    CALL POS_CURSOR2
    MOV AL, MAT1[SI]
    CALL ESC_CARAC
    INC SI
    INC COLUNA2
    CMP COLUNA2, 27
    JNE MOST1
    ADD SI, 2
    INC LINHA2
    CMP LINHA2, 20
    JNE MOST2
    RET

;************************
;      AUTOMATO         *
;************************
; Processa a próxima geração do jogo
;   life com base na configuração 
;   informada pelo editor
AUTOMATO:
    MOV SI, 18
    MOV LINHA2, 5
AUTO2:
    MOV COLUNA2, 12
AUTO1:
    CALL NUMVIZ
    CALL VER_POS
    INC SI
    INC COLUNA2
    CMP COLUNA2, 27
    JNE AUTO1
    ADD SI, 2
    INC LINHA2
    CMP LINHA2, 20
    JNE AUTO2
    RET

; Calcula o número de vizinhos de 
;    uma dada posição da matriz
NUMVIZ:
    MOV AL, 0
    ADD AL, MAT1[SI-18]
    ADD AL, MAT1[SI-17]
    ADD AL, MAT1[SI-16]
    ADD AL, MAT1[SI-1]
    ADD AL, MAT1[SI+1]
    ADD AL, MAT1[SI+16]
    ADD AL, MAT1[SI+17]
    ADD AL, MAT1[SI+18]
    MOV NVIZ, AL
    RET

; Toma a decisão de vida/morte
;   com base no número de vizinhos
VER_POS:
    CMP NVIZ, 2
    JE  IGUAL
    CMP NVIZ, 3
    JE  NASCE
MORTE:  
    MOV MAT2[SI], 0
    RET
NASCE:  
    MOV MAT2[SI], 1
    RET
IGUAL:  
    MOV AL, MAT1[SI]
    MOV MAT2[SI], AL
    RET

;************************
;      SUBROTINAS       *
;************************

; Imprime na tela caractere ascii 0 (cara feliz)
ESC_CARAC:  
        MOV AH, 10
        MOV BH, 0
        MOV CX, 1
        INT 10H
        RET

; Imprime na tela caractere de moldura
ESC_MOLD:   
        CALL POS_CURSOR
        MOV AL, 35
        MOV AH, 10
        MOV BH, 0
        MOV CX, 1
        INT 10H
        RET

; Lê uma tecla dada pelo usuário
LER_TECLA:     
        MOV AH, 0
        INT 16H
        RET

; Muda a configuração de vídeo
VIDEO_40:   
        MOV AH, 0
        MOV AL, 1
        INT 10H
        RET

VIDEO_80:   
        MOV AH, 0
        MOV AL, 3
        INT 10H
        RET

; Posiciona cursor em (Linha, Coluna)
POS_CURSOR: 
        MOV AH, 2
        MOV BH, 0
        MOV DH, LINHA
        MOV DL, COLUNA
        INT 10H
        RET
        
; Posiciona cursor em (Linha2, Coluna2)
POS_CURSOR2:    
        MOV AH, 2
        MOV BH, 0
        MOV DH, LINHA2
        MOV DL, COLUNA2
        INT 10H
        RET

; Escreve a mensagem na tela
ESC_MENS:   
        MOV AH,9
        MOV DX, OFFSET MENSAGEM
        INT 21H
        RET

; Copia MAT2 para MAT1
COPIAR_MAT: 
        MOV SI, 1
COPIA:      
        MOV AL, MAT2[SI]
        MOV MAT1[SI], AL
        INC SI
        CMP SI, 289
        JNE COPIA
        RET

;************************
;        MOLDURA        *
;************************

; Subrotina para criar a moldura da
;   região do editor.
MOLDURA:
        MOV LINHA, 4
        MOV COLUNA, 11

; Loop que cria as molduras verticas        
LOOP1:      
        CMP  LINHA, 21
        JE   LOOP2
            MOV  COLUNA, 27
            CALL ESC_MOLD
            
            MOV COLUNA, 11
            CALL ESC_MOLD

            INC LINHA
        JMP LOOP1

; Loop que cria as molduras horizontais 
LOOP2:   
        CMP  COLUNA, 28
        JE    FIM_MOLD
            MOV  LINHA, 4
            CALL ESC_MOLD
            
            MOV  LINHA, 20
            CALL ESC_MOLD
        
            INC COLUNA
        JMP LOOP2

; Fim da moldura. Linha e Coluna voltam ao original.
FIM_MOLD:   
        MOV LINHA, 5
        MOV COLUNA, 12
        RET

;**************************************
CODIGO ENDS;

END INICIO
;***************************