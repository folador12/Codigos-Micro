;Luiz Antonio Folador Filho
;01949013600-2
    
    
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
	CONTADOR
	FLAGS
	VALOR_ADC
	VALOR_ADC_POT
	VALOR_ADC_HEATER
	PROCESS_VAR
	W_TEMP
	S_TEMP
    ENDC

;entradas
#define	B_ON		PORTB,0
#define	B_OFF		PORTB,1
#define B_POT		PORTB,2
#define B_HEATER	PORTB,3
    
;variaveis
#define	FIM_250MS	FLAGS,0
#define	TROCA_DISPLAY	FLAGS,1
#define MODO_MANUAL	FLAGS,2
#define MODO_HEATER	FLAGS,3
    
;saidas
#define	DISPLAY		PORTD
#define	D_UNIDADE	PORTB,4   
#define	D_DEZENA	PORTB,5  
#define	D_CENTENA	PORTB,6
#define	D_MILHAR	PORTB,7
#define	HEATER		PORTC,2 
    
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
    DECFSZ  CONTADOR,F
    GOTO    SAI_INTERRUPCAO
    BSF	    FIM_250MS
    MOVLW   .62
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
    MOVLW   B'01000100'	
    MOVWF   ADCON1
    BANK0
    MOVLW   B'11001001'	
    MOVWF   ADCON0	    	    
    CLRF    FLAGS	
    MOVLW   .62
    MOVWF   CONTADOR
    BSF	    MODO_MANUAL
    BCF	    MODO_HEATER
    BSF	    INTCON,T0IE	    
    BSF	    INTCON,GIE	
    
LACO_PRINCIPAL
    BTFSC   TROCA_DISPLAY         
    CALL    ATUALIZA_DISPLAY
    BTFSS   FIM_250MS     
    GOTO    LACO_PRINCIPAL
    
    CALL    LEITURA_POT
    CALL    LEITURA_HEATHER
    CALL    LER_BOTOES     
    
    BTFSS   B_ON
    BSF	    MODO_HEATER
    
    BTFSS   B_OFF
    BCF	    MODO_HEATER
    
    BTFSC   MODO_HEATER
    CALL    VERIFICAR_VALORES
    
    BTFSS   MODO_HEATER
    BCF	    HEATER
    
    BTFSC   MODO_MANUAL           
    GOTO    MOSTRAR_POT           
    GOTO    MOSTRAR_HEATER
    
    
VERIFICAR_VALORES  
    MOVF    VALOR_ADC_POT,W
    MOVWF   PROCESS_VAR
    
    MOVF    VALOR_ADC_HEATER, W               
    SUBWF   PROCESS_VAR, W              
    BTFSC   STATUS, C                  
    BSF     HEATER                      
    BTFSS   STATUS, C                   
    BCF     HEATER  
    RETURN
    
LER_BOTOES
    BTFSS   B_POT                
    BSF     MODO_MANUAL          
    BTFSS   B_HEATER            
    BCF     MODO_MANUAL          
    RETURN
    
MOSTRAR_POT
    MOVF    VALOR_ADC_POT,W
    MOVWF   VALOR_ADC
    CLRF    UNIDADE
    CLRF    DEZENA
    CLRF    CENTENA
    GOTO    VERIFICA_CENTENA
    
MOSTRAR_HEATER
    MOVF    VALOR_ADC_HEATER,W
    MOVWF   VALOR_ADC
    CLRF    UNIDADE
    CLRF    DEZENA
    CLRF    CENTENA
    GOTO    VERIFICA_CENTENA
    
LEITURA_POT
    MOVLW   B'11001001'	
    MOVWF   ADCON0	
    BSF	    ADCON0,GO_DONE
    BTFSC   ADCON0,GO_DONE
    GOTO    $-1
    MOVF    ADRESH,W
    MOVWF   VALOR_ADC_POT
    RETURN
    
LEITURA_HEATHER
    MOVLW   B'11000001'	  
    MOVWF   ADCON0
    BSF	    ADCON0,GO_DONE
    BTFSC   ADCON0,GO_DONE
    GOTO    $-1
    MOVF    ADRESH,W
    MOVWF   VALOR_ADC_HEATER
    RETURN
   

VERIFICA_CENTENA
    MOVLW   .100
    SUBWF   VALOR_ADC,W
    BTFSS   STATUS,C
    GOTO    VERIFICA_DEZENA
    INCF    CENTENA,F
    MOVWF   VALOR_ADC
    GOTO    VERIFICA_CENTENA
    
VERIFICA_DEZENA
    MOVLW   .10
    SUBWF   VALOR_ADC,W
    BTFSS   STATUS,C
    GOTO    VERIFICA_UNIDADE
    INCF    DEZENA,F
    MOVWF   VALOR_ADC
    GOTO    VERIFICA_DEZENA
    
VERIFICA_UNIDADE
    MOVF    VALOR_ADC,W
    MOVWF   UNIDADE
    GOTO    LACO_PRINCIPAL
    
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