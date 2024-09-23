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
	FILTRO
	FLAGS
	W_TEMP
	S_TEMP
    ENDC
    
;variaveis
#define	CONTEI		FLAGS,0
#define	TROCA_DISPLAY	FLAGS,1

;entradas
#define	B_UP		PORTB,0
#define	B_RESET		PORTB,1

;saidas
#define	DISPLAY		PORTD
#define	D_UNIDADE	PORTB,4   
#define	D_DEZENA	PORTB,5  
#define	D_CENTENA	PORTB,6
#define	D_MILHAR	PORTB,7
    
;constantes
V_TMR0	    equ		.131
V_FILTRO    equ		.100	
	
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
    MOVLW   V_FILTRO	    
    MOVWF   FILTRO	    
    CLRF    FLAGS	    
    BSF	    INTCON,T0IE	    
    BSF	    INTCON,GIE	    
LACO_PRINCIPAL
    BTFSC   TROCA_DISPLAY	
    CALL    ATUALIZA_DISPLAY	
    BTFSS   B_RESET		
    GOTO    B_RESET_ACIONADO	
    BTFSC   B_UP		
    GOTO    B_UP_NAO_ACIONADO	
    BTFSC   CONTEI		
    GOTO    LACO_PRINCIPAL	
    DECFSZ  FILTRO,F		
    GOTO    LACO_PRINCIPAL	
    BSF	    CONTEI		
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
B_RESET_ACIONADO
    CLRF    UNIDADE		
    CLRF    DEZENA		   
    GOTO    LACO_PRINCIPAL	
B_UP_NAO_ACIONADO
    MOVLW   V_FILTRO		
    MOVWF   FILTRO		
    BCF	    CONTEI		  
    GOTO    LACO_PRINCIPAL
    
ATUALIZA_DISPLAY
    BCF	    TROCA_DISPLAY	
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