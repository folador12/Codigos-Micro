; PIC16F877A Configuration Bit Settings

#include "p16f877a.inc"

; CONFIG
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
 
#define	BANK0	BCF STATUS,RP0
#define	BANK1	BSF STATUS,RP0 
 
    CBLOCK  0x20
	UNIDADE
	DEZENA
	CENTENA
	CONTADOR
	FLAGS
	VALOR_ADC_H   ; Parte alta do valor ADC (os 2 bits mais significativos)
	VALOR_ADC_L   ; Parte baixa do valor ADC (os 8 bits menos significativos)
	W_TEMP
	S_TEMP
    ENDC
    
; Variáveis
#define	FIM_100MS	FLAGS,0
#define	TROCA_DISPLAY	FLAGS,1

; Saídas
#define	DISPLAY		PORTD
#define	D_UNIDADE	PORTB,4   
#define	D_DEZENA	PORTB,5  
#define	D_CENTENA	PORTB,6
#define	D_MILHAR	PORTB,7
    
; Constantes
V_TMR0	    equ		.131	
	
RES_VECT  CODE    0x0000   
    GOTO    START           

INT_VECT  CODE    0x0004   
    MOVWF   W_TEMP	    
    MOVF    STATUS,W	    
    MOVWF   S_TEMP	    
    BTFSS   INTCON,T0IF	    
    GOTO    SAI_INTERRUPCAO 
    BCF	    INTCON,T0IF	    
    MOVLW   V_TMR0	    
    ADDWF   TMR0,F	    
    BSF	    TROCA_DISPLAY   
    DECFSZ  CONTADOR,F
    GOTO    SAI_INTERRUPCAO
    BSF	    FIM_100MS
    MOVLW   .25
    MOVWF   CONTADOR
    
SAI_INTERRUPCAO
    MOVF    S_TEMP,W	    
    MOVWF   STATUS	    
    MOVF    W_TEMP,W	    
    RETFIE

START
    BANK1
    CLRF    TRISD	
    MOVLW   B'00001111'
    MOVWF   TRISB
    MOVLW   B'11010100'	   			  
    MOVWF   OPTION_REG
    MOVLW   B'01000100'	
    MOVWF   ADCON1
    BANK0
    MOVLW   B'11001001'	
    MOVWF   ADCON0	    	    
    CLRF    FLAGS	
    MOVLW   .25
    MOVWF   CONTADOR
    BSF	    INTCON,T0IE	    
    BSF	    INTCON,GIE	    
LACO_PRINCIPAL
    BTFSC   TROCA_DISPLAY	
    CALL    ATUALIZA_DISPLAY
    BTFSS   FIM_100MS
    GOTO    LACO_PRINCIPAL
    BSF	    ADCON0,GO_DONE
    BTFSC   ADCON0,GO_DONE
    GOTO    $-1

    ; Combinar os dois registradores para formar um valor de 10 bits
    MOVF    ADRESH,W
    MOVWF   VALOR_ADC_H   ; Armazenar parte alta (os 2 bits mais significativos)
    MOVF    ADRESL,W
    MOVWF   VALOR_ADC_L   ; Armazenar parte baixa (os 8 bits menos significativos)

    CLRF    UNIDADE
    CLRF    DEZENA
    CLRF    CENTENA

    ; Agora que o valor está dividido em VALOR_ADC_H e VALOR_ADC_L, devemos tratá-lo como um número de 10 bits.

VERIFICA_CENTENA
    ; Comparar com 100 * 10 (ou seja, 1000 em decimal, o que corresponde a um valor de 10 bits)
    MOVLW   .100
    CALL    SUBTRAIR_ADC
    BTFSS   STATUS,C
    GOTO    VERIFICA_DEZENA
    INCF    CENTENA,F
    GOTO    VERIFICA_CENTENA
    
VERIFICA_DEZENA
    ; Comparar com 10
    MOVLW   .10
    CALL    SUBTRAIR_ADC
    BTFSS   STATUS,C
    GOTO    VERIFICA_UNIDADE
    INCF    DEZENA,F
    GOTO    VERIFICA_DEZENA
    
VERIFICA_UNIDADE
    ; Unidade é o valor restante do ADC
    MOVF    VALOR_ADC_L,W
    MOVWF   UNIDADE
    GOTO    LACO_PRINCIPAL

; Subtrair o valor de W de VALOR_ADC (10 bits)
SUBTRAIR_ADC
    MOVF    VALOR_ADC_L,W
    SUBWF   W,F    ; Subtrai o valor do ADC menos o valor de W
    RETURN

ATUALIZA_DISPLAY
    BCF	    TROCA_DISPLAY	
    BTFSS   D_UNIDADE	
    GOTO    TESTA_DEZENA
    BCF	    D_UNIDADE
    MOVF    DEZENA,W		
    CALL    BUSCA_CODIGO
    MOVWF   DISPLAY
    BSF	    D_DEZENA
    RETURN	
    
TESTA_DEZENA
    BTFSS   D_DEZENA	
    GOTO    TESTA_CENTENA
    BCF	    D_DEZENA
    MOVF    CENTENA,W		
    CALL    BUSCA_CODIGO	
    MOVWF   DISPLAY
    BSF	    D_CENTENA
    RETURN
    
TESTA_CENTENA
    BCF	    D_CENTENA	
    MOVF    UNIDADE,W		
    CALL    BUSCA_CODIGO	
    MOVWF   DISPLAY
    BSF	    D_UNIDADE
    RETURN
    
BUSCA_CODIGO
    ADDWF   PCL,F
    RETLW   0x3F
    RETLW   0x06
    RETLW   0x5B
    RETLW   0x4F
    RETLW   0x66
    RETLW   0x6D
    RETLW   0x7D
    RETLW   0x07
    RETLW   0x7F
    RETLW   0x6F
    
    END
