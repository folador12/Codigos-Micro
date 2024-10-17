; PIC16F877A Configuration Bit Settings

; Assembly source line config statements

#include "p16f877a.inc"

; CONFIG
; __config 0xFF71
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

 
#define	BANK0	BCF STATUS,RP0
#define	BANK1	BSF STATUS,RP0 
 
    CBLOCK  0x20
	UNIDADE
	DEZENA
	CENTENA
	MILHAR
	CONTADOR 
	ADC_H 
	ADC_L  
	X_H
	X_L
	Y_H
	Y_L
	R_H
	R_L
	FLAGS
	W_TEMP
	S_TEMP
    ENDC
    
;variáveis
#define	FIM_250MS	FLAGS,0
#define	TROCA_DISPLAY	FLAGS,1
#define EH_NEGATIVO	FLAGS,2
#define	LENDO_TEMP	FLAGS,3

;entradas
#define B_POT		PORTB,0
#define B_TEMP		PORTB,1
#define	B_ON		PORTB,2
#define	B_OFF		PORTB,3

;saídas
#define	DISPLAY		PORTD
#define	D_UNIDADE	PORTB,4    
#define	D_DEZENA	PORTB,5  
#define	D_CENTENA	PORTB,6  
#define	D_MILHAR	PORTB,7
#define	HEATER		PORTC,2 
    
;constantes
V_TMR0	    equ		.193
	
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
    BSF	    FIM_250MS	    
    MOVLW   .31		    
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
    BCF	    TRISC,2	   
    MOVLW   B'11010010'
    MOVWF   OPTION_REG
    MOVLW   B'11000100'
    MOVWF   ADCON1    
    BANK0
    MOVLW   B'11001001'	
    MOVWF   ADCON0	
    MOVLW   .31
    MOVWF   CONTADOR	    
    CLRF    FLAGS	    
    BSF	    INTCON,T0IE	    
    BSF	    INTCON,GIE	    
    
LACO_PRINCIPAL
    BTFSC   TROCA_DISPLAY	
    CALL    ATUALIZA_DISPLAY	
    BTFSS   FIM_250MS
    GOTO    LACO_PRINCIPAL
    CALL    LER_BOTOES
    BTFSS   B_ON
    BSF	    HEATER
    BTFSS   B_OFF
    BCF	    HEATER
    GOTO    LE_ADC       
    
LER_BOTOES
    BTFSS   B_POT
    CALL    INICIA_LEITURA_POT
    BTFSS   B_TEMP
    CALL    INICIA_LEITURA_TEMP
    RETURN
    
INICIA_LEITURA_POT
    MOVLW   B'11001001'	
    MOVWF   ADCON0	
    RETURN
    
INICIA_LEITURA_TEMP
    MOVLW   B'11000001'	  
    MOVWF   ADCON0	 
    RETURN   
    
LE_ADC
    BCF	    FIM_250MS
    CLRF    UNIDADE
    CLRF    DEZENA
    CLRF    CENTENA
    CLRF    MILHAR
    BSF	    ADCON0,GO_DONE
    BTFSC   ADCON0,GO_DONE
    GOTO    $-1
    MOVF    ADRESH,W	   
    MOVWF   X_H		    
    BANK1		    
    MOVF    ADRESL,W	   
    BANK0
    MOVWF   X_L		   
    GOTO    VERIFICA_MILHAR
    
VERIFICA_MILHAR
    MOVLW   0x03		
    MOVWF   Y_H			
    MOVLW   0xE8
    MOVWF   Y_L			
    CALL    SUB_16BITS
    BTFSC   EH_NEGATIVO		
    GOTO    VERIFICA_CENTENA	
    INCF    MILHAR,F		
    MOVF    R_H,W		
    MOVWF   X_H			
    MOVF    R_L,W		
    MOVWF   X_L			
    GOTO    VERIFICA_MILHAR	
    
VERIFICA_CENTENA
    MOVLW   0x00		
    MOVWF   Y_H			
    MOVLW   0x64
    MOVWF   Y_L			
    CALL    SUB_16BITS
    BTFSC   EH_NEGATIVO		
    GOTO    VERIFICA_DEZENA	
    INCF    CENTENA,F		
    MOVF    R_H,W		
    MOVWF   X_H			
    MOVF    R_L,W		
    MOVWF   X_L			
    GOTO    VERIFICA_CENTENA	
    
VERIFICA_DEZENA
    MOVLW   .10			
    SUBWF   X_L,W		
    BTFSS   STATUS,C		
    GOTO    VERIFICA_UNIDADE	
    INCF    DEZENA,F		
    MOVWF   X_L			
    GOTO    VERIFICA_DEZENA	
    
VERIFICA_UNIDADE
    MOVF    X_L,W		
    MOVWF   UNIDADE		
    GOTO    LACO_PRINCIPAL
    
SUB_16BITS
    BCF	    EH_NEGATIVO
    MOVF    Y_L,W
    SUBWF   X_L,W	
    MOVWF   R_L
    BTFSS   STATUS,C
    BSF	    EH_NEGATIVO
    MOVF    Y_H,W
    SUBWF   X_H,W	
    MOVWF   R_H
    BTFSS   STATUS,C
    GOTO    X_EH_MENOR_Y
    BTFSS   EH_NEGATIVO
    RETURN
    MOVLW   .1
    SUBWF   R_H,F
    BTFSC   STATUS,C
    BCF	    EH_NEGATIVO
    RETURN
    
X_EH_MENOR_Y
    BSF	  EH_NEGATIVO
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
    BTFSS   D_CENTENA
    GOTO    TESTA_MILHAR
    BCF	    D_CENTENA		
    MOVF    MILHAR,W		
    CALL    BUSCA_CODIGO	
    MOVWF   DISPLAY		
    BSF	    D_MILHAR		
    RETURN			
    
TESTA_MILHAR
    BCF	    D_MILHAR		
    MOVF    UNIDADE,W		
    CALL    BUSCA_CODIGO	
    MOVWF   DISPLAY		
    BSF	    D_UNIDADE		
    RETURN			
    
BUSCA_CODIGO
    ADDWF   PCL,F		;PCL = PCL + W
    RETLW   0x3F		;retorna da subrotina com W = 0x3F
    RETLW   0x06		;retorna da subrotina com W = 0x06    
    RETLW   0x5B		;retorna da subrotina com W = 0x5B    
    RETLW   0x4F		;retorna da subrotina com W = 0x4F
    RETLW   0x66		;retorna da subrotina com W = 0x66
    RETLW   0x6D		;retorna da subrotina com W = 0x6D    
    RETLW   0x7D		;retorna da subrotina com W = 0x7D    
    RETLW   0x07		;retorna da subrotina com W = 0x07    
    RETLW   0x7F		;retorna da subrotina com W = 0x7F
    RETLW   0x6F		;retorna da subrotina com W = 0x6F    
    
       
    END