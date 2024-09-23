; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0xFF70
    __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF


#define	BANK0	BCF STATUS,RP0
#define	BANK1	BSF STATUS,RP0
    
    CBLOCK 0X20
	UNIDADE
	DEZENA
	FLAGS
	W_TEMP
	S_TEMP
	CONTADOR
    ENDC
    
;variáveis
#define	    CONTEI	    FLAGS,0
#define	    TROCA_DISPLAY   FLAGS,1
#define     DIRECAO	    FLAGS,2
#define     CONTANDO	    FLAGS,3

    
;entradas
#define	    B_UP	    PORTA,1
#define	    B_DOWN	    PORTA,2
#define	    B_STOP	    PORTA,3
#define	    B_ZERO	    PORTA,4
    
;saídas
#define	    DISPLAY	    PORTB
#define	    QUAL_DISPLAY    PORTB,4
    
;constantes
V_TMR0	    equ		    .131
    
RES_VECT    CODE    0x0000			; processor reset vector

    GOTO    START				;pula a área de armazenamento de iterrupção
    
INT_VEC	    CODE    0X0004			;vetor de iterrupção
    
    MOVWF   W_TEMP				;salvar w em W_TEMP
    MOVF    STATUS,W				;w = STATUS
    MOVWF   S_TEMP				;salvar SATATUS em S_TEMP
    BTFSS   INTCON,T0IF				;testa se a iterrupção foi por TIMER0
    GOTO    SAI_ITERRUPCAO			;se não foi, pula para SAI_ITERRUPCAO
    BCF	    INTCON,T0IF				;limpa o bit de indicação de iterrupção por TIMER0
    MOVLW   V_TMR0				;W = V_TMR0 -> W = 131
    ADDWF   TMR0,F				;TMR0 = TMR0 + V_TMR0 -> TMR0 = TMR0 + 131
    BSF	    TROCA_DISPLAY			;TROCA_DISPLAY = 1
    INCF    CONTADOR
    
SAI_ITERRUPCAO
    
    MOVF    S_TEMP,W				;W = S_TEMP
    MOVWF   STATUS				;restaura STATUS
    MOVF    W_TEMP,W				;restaura W
    RETFIE
    
START
    
    BANK1
    CLRF    TRISB				;configura todo o PORTB como saída
    MOVLW   B'11010100'				;palavra de configuração do TIMER0
						;bit7: ativa resistores PULL_UP do PORTB
						;bit6: define o tipo de borda para RB0
						;bit5: define origem do clock do TIMER0
						;bit4: define borda do clock do TIMER0
						;bit3: quem usa o PRESCALER - TMR0 ou WDT
						;bit2..0: define PRESCALER - 100 - 1:32
    MOVWF   OPTION_REG				;carrega a configuração do TIMER0
    BANK0
    CLRF    UNIDADE				;UNIDADE = 0
    CLRF    DEZENA				;DEZENA = 0
    CLRF    FLAGS				;FLAGS = 0
    BCF	    CONTANDO
    BCF	    DIRECAO
    CLRF    CONTADOR
    BSF	    INTCON,T0IE				;habilita o atendimento de iterrupção por TIMER0
    BSF	    INTCON,GIE				;habilita o atenddimento de iterrupções
 
LACO_PRINCIPAL
    
    MOVLW   .250
    SUBWF   CONTADOR, W
    BTFSC   STATUS,Z
    GOTO    V_CONTANDO
    
    BTFSC   TROCA_DISPLAY			
    CALL    ATUALIZA_DISPLAY			
    BTFSS   B_ZERO				
    GOTO    ZERAR	
    
    BTFSS   B_STOP
    GOTO    PARAR
    
    BTFSS   B_UP
    GOTO    INCREMENTA_ACIONADO
    BTFSS   B_DOWN
    GOTO    DECREMENTA_ACIONADO
    GOTO    LACO_PRINCIPAL			
    
V_CONTANDO
    
    CLRF    CONTADOR
    BTFSS   CONTANDO
    GOTO    LACO_PRINCIPAL
    BTFSC   DIRECAO
    GOTO    INCREMENTAR
    GOTO    DECREMENTAR
    
    
PARAR
    
    BCF	    CONTANDO
    BCF	    DIRECAO
    GOTO    LACO_PRINCIPAL

ZERAR

    BTFSC   CONTANDO
    GOTO    LACO_PRINCIPAL
    
    CLRF    UNIDADE				
    CLRF    DEZENA				
    GOTO    LACO_PRINCIPAL
    
INCREMENTA_ACIONADO
    
    BTFSC   CONTANDO
    GOTO    LACO_PRINCIPAL
    
    BSF	    CONTANDO
    BSF	    DIRECAO
    GOTO    LACO_PRINCIPAL
    
    
DECREMENTA_ACIONADO
    
    BTFSC   CONTANDO
    GOTO    LACO_PRINCIPAL
    
    BSF	    CONTANDO
    BCF	    DIRECAO
    GOTO    LACO_PRINCIPAL
    
    
INCREMENTAR
    
    INCF    UNIDADE,F				
    MOVLW   .10					
    SUBWF   UNIDADE,W				
    BTFSS   STATUS,C				
    GOTO    LACO_PRINCIPAL			
    CLRF    UNIDADE				
    INCF    DEZENA,F				
    MOVLW   .10					
    SUBWF   DEZENA,W				
    BTFSC   STATUS,C				
    CLRF    DEZENA				
    GOTO    LACO_PRINCIPAL			    

DECREMENTAR
    
    MOVLW   .0
    XORWF   UNIDADE,W
    BTFSC   STATUS,Z
    GOTO    CARR_9
    DECF    UNIDADE,F				
    GOTO    LACO_PRINCIPAL
 
CARR_9
    
    MOVLW   .9					
    MOVWF   UNIDADE
    MOVLW   .0
    XORWF   DEZENA,W
    BTFSC   STATUS,Z
    GOTO    CARREGA_9   
    DECF    DEZENA,F				
    GOTO    LACO_PRINCIPAL
    
CARREGA_9
    
    MOVLW   .9					;W = 10
    MOVWF   DEZENA
    GOTO    LACO_PRINCIPAL			;pula para LACO_PRINCIPAL  
    
ATUALIZA_DISPLAY
    
    BCF	    TROCA_DISPLAY			;TROCA_DISPLAY = 0
    BTFSS   QUAL_DISPLAY			;testa se a UNIDADE está acesa
    GOTO    ACENDE_UNIDADE			;se QUAL_DISPLAY = 0, pula para ACENEDE_UNIADE
    MOVF    DEZENA,W				;W = DEZENA
    CALL    BUSCA_CODIGO			;chama a subrotina para obter o código de 7 segmentos
    ANDLW   B'11101111'				;W = W & B'11101111'
    
ESCREVA_DISPLAY
    
    MOVWF   DISPLAY				;DISPLAY = W -> PORTB = W
    RETURN					;volta para o programa principal
    
ACENDE_UNIDADE
    
    MOVF    UNIDADE,W				;W = UNIDADE
    CALL    BUSCA_CODIGO			;chama a subrotina para obter o código de 7 segmentos
    GOTO    ESCREVA_DISPLAY			

BUSCA_CODIGO
    ADDWF   PCL,F		    ;PCL = PCL + W
    RETLW   0XFE		    ;retorna a subrotina com w = 0xFE
    RETLW   0X38		    ;retorna a subrotina com w = 0x38
    RETLW   0XDD		    ;retorna a subrotina com w = 0xDD
    RETLW   0X7D		    ;retorna a subrotina com w = 0x7D
    RETLW   0X3B		    ;retorna a subrotina com w = 0x3B
    RETLW   0X77		    ;retorna a subrotina com w = 0x77
    RETLW   0XF7		    ;retorna a subrotina com w = 0xF7
    RETLW   0X3C		    ;retorna a subrotina com w = 0x3C
    RETLW   0XFF		    ;retorna a subrotina com w = 0xFF
    RETLW   0X7F		    ;retorna a subrotina com w = 0X7F
    
    END