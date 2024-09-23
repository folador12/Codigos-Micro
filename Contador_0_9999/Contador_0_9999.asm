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
	FLAGS
	W_TEMP
	S_TEMP
	CONTADOR
    ENDC
    
;variaveis
#define	TROCA_DISPLAY	FLAGS,1
#define	CONTANDO	FLAGS,0

;entradas
#define	B_UP		PORTB,0
#define	B_RESET		PORTB,2
#define	B_STOP		PORTB,1

;saidas
#define	DISPLAY		PORTD
#define	D_UNIDADE	PORTB,4   
#define	D_DEZENA	PORTB,5  
#define	D_CENTENA	PORTB,6
#define	D_MILHAR	PORTB,7
    
;constantes
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
    INCF    CONTADOR

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
    BANK0
    CLRF    UNIDADE	   
    CLRF    DEZENA
    CLRF    CENTENA
    CLRF    MILHAR
    CLRF    FLAGS
    CLRF    CONTADOR
    BSF	    INTCON,T0IE	    
    BSF	    INTCON,GIE	
 
LACO_PRINCIPAL
    MOVLW   .25
    SUBWF   CONTADOR, W
    BTFSC   STATUS,Z
    GOTO    V_CONTANDO
    
    BTFSC   TROCA_DISPLAY			
    CALL    ATUALIZA_DISPLAY
    
    BTFSS   B_UP
    GOTO    CONTAR
    
    BTFSS   B_STOP
    GOTO    PARAR
    
    BTFSS   B_RESET				
    GOTO    ZERAR	

    
    GOTO    LACO_PRINCIPAL
    
    
CONTAR
    BSF	    CONTANDO
    GOTO    LACO_PRINCIPAL
    
V_CONTANDO
    CLRF    CONTADOR
    BTFSS   CONTANDO
    GOTO    LACO_PRINCIPAL
    GOTO    INCREMENTAR
    
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
    BTFSS   STATUS,C
    GOTO    LACO_PRINCIPAL  
    CLRF    DEZENA
    INCF    CENTENA,F
    MOVLW   .10
    SUBWF   CENTENA,W
    BTFSS   STATUS,C
    GOTO    LACO_PRINCIPAL  
    CLRF    CENTENA
    INCF    MILHAR,F
    MOVLW   .10
    SUBWF   MILHAR,W
    BTFSC   STATUS,C
    CLRF    MILHAR
    GOTO    LACO_PRINCIPAL
    
ZERAR
    BTFSC   CONTANDO
    GOTO    LACO_PRINCIPAL
    CLRF    UNIDADE				
    CLRF    DEZENA
    CLRF    CENTENA				
    CLRF    MILHAR
    GOTO    LACO_PRINCIPAL

PARAR
    BCF	    CONTANDO
    GOTO    LACO_PRINCIPAL
    
ATUALIZA_DISPLAY
    BCF	    TROCA_DISPLAY			
    BTFSS   D_CENTENA				
    GOTO    ACENDE_CENTENA			
    BCF	    D_CENTENA
    BCF	    D_DEZENA
    BCF	    D_UNIDADE
    MOVF    MILHAR,W				
    CALL    BUSCA_CODIGO			
    MOVWF   DISPLAY				
    BSF	    D_MILHAR
    
    RETURN					
    
ACENDE_CENTENA
    BCF	    D_MILHAR
    BTFSS   D_DEZENA
    GOTO    ACENDE_DEZENA
    BCF	    D_DEZENA
    BCF	    D_UNIDADE
    MOVF    CENTENA,W				
    CALL    BUSCA_CODIGO			
    MOVWF   DISPLAY
    BSF	    D_CENTENA
    RETURN
    
ACENDE_DEZENA
    BCF	    D_CENTENA
    BTFSS   D_UNIDADE
    GOTO    ACENDE_UNIDADE
    BCF	    D_UNIDADE
    MOVF    DEZENA,W				
    CALL    BUSCA_CODIGO			
    MOVWF   DISPLAY
    BSF	    D_DEZENA
    RETURN
    
ACENDE_UNIDADE
    BCF	    D_DEZENA
    MOVF    UNIDADE,W				
    CALL    BUSCA_CODIGO			
    MOVWF   DISPLAY
    BSF	    D_UNIDADE
    RETURN
    
    
BUSCA_CODIGO
    ADDWF   PCL,F		;PCL = PCL + W
    RETLW   0x3F		;retorna da subrotina com W = 0xFE
    RETLW   0x06		;retorna da subrotina com W = 0x38    
    RETLW   0x5B		;retorna da subrotina com W = 0xDD    
    RETLW   0x4F		;retorna da subrotina com W = 0x7D
    RETLW   0x66		;retorna da subrotina com W = 0x3B
    RETLW   0x6D		;retorna da subrotina com W = 0x77    
    RETLW   0x7D		;retorna da subrotina com W = 0xF7    
    RETLW   0x07		;retorna da subrotina com W = 0x3C    
    RETLW   0x7F		;retorna da subrotina com W = 0xFF
    RETLW   0x6F		;retorna da subrotina com W = 0x7F    
    
    END