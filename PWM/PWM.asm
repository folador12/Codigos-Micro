; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR


; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

#define BANK0 BCF STATUS, RP0
#define BANK1 BSF STATUS, RP0
    
    CBLOCK 0x20
	FILTRO_UP
	FILTRO_DOWN
	UNIDADE
	FLAGS
	W_TEMP
	S_TEMP
	RAMPA
    ENDC
    
;variaveis
#define JA_LI_UP   FLAGS,0
#define JA_LI_DOWN   FLAGS,1
    
;entradas
#define	B_ZERAR PORTA,3
#define	B_DOWN	PORTA,2
#define	B_UP    PORTA,1
    
;saidas
#define	DISPLAY PORTB
#define	PWM	PORTA,0
    
    ;constantes
V_FILTRO	equ .100
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO CONFIGURE

INT_VECT  CODE    0x0004            ; processor interrupt vector
    MOVWF   W_TEMP		    
    MOVF    STATUS,W		    
    MOVWF   S_TEMP		    
    BTFSS   INTCON,T0IF		    
    GOTO    SAI_INTERRUPCAO	    
    BCF	    INTCON,T0IF		    
    MOVLW   .6			    
    ADDWF   TMR0,F		    
    INCF    RAMPA,F
    MOVLW   .16
    SUBWF   RAMPA,W
    BTFSC   STATUS,C
    CLRF    RAMPA
    MOVF    UNIDADE,W
    SUBWF   RAMPA,W
    BTFSS   STATUS,C
    GOTO    EH_MENOR
    BCF	    PWM
    GOTO    SAI_INTERRUPCAO
    
EH_MENOR
    BSF	    PWM
    
SAI_INTERRUPCAO
    MOVF    S_TEMP,W		    
    MOVWF   STATUS		    
    MOVF    W_TEMP,W		    
    RETFIE  
  
    
CONFIGURE
    BANK1			    
    CLRF    TRISB		    
    BCF	    TRISA,0
    MOVLW   B'11010001'		  				  
    MOVWF   OPTION_REG		    
    BANK0			    
    MOVLW   V_FILTRO		    
    MOVWF   FILTRO_UP		    
    MOVWF   FILTRO_DOWN		    
    BCF	    JA_LI_UP		    
    BCF	    JA_LI_DOWN		    
    CLRF    UNIDADE		    
    CLRF    RAMPA
    BSF	    INTCON,T0IE
    BSF	    INTCON,GIE
    CALL    ATUALIZA_DISPLAY	    
    
LACO_PRINCIPAL
    BTFSS   B_ZERAR		    
    GOTO    B_ZERAR_ACIONADO	    
    BTFSC   B_UP		    
    GOTO    B_UP_NAO_ACIONADO	    
    BTFSC   JA_LI_UP		    
    GOTO    LACO_PRINCIPAL	    
    DECFSZ  FILTRO_UP,F		    
    GOTO    LACO_PRINCIPAL	    
    BSF	    JA_LI_UP		    
    INCF    UNIDADE,F		   
    MOVLW   .16			    
    SUBWF   UNIDADE,W		    
    BTFSC   STATUS,C		   
    CLRF    UNIDADE		    
    CALL    ATUALIZA_DISPLAY	   
    
    GOTO    LACO_PRINCIPAL	   
    
B_ZERAR_ACIONADO
    CLRF    UNIDADE		    
    CALL    ATUALIZA_DISPLAY	    
    GOTO    LACO_PRINCIPAL	    
    
B_UP_NAO_ACIONADO
    MOVLW   V_FILTRO		    
    MOVWF   FILTRO_UP		    
    BCF	    JA_LI_UP		    
    BTFSC   B_DOWN		    
    GOTO    B_DOWN_N_ACIONADO
    BTFSC   JA_LI_DOWN		    
    GOTO    LACO_PRINCIPAL	    
    DECFSZ  FILTRO_DOWN,F	    
    GOTO    LACO_PRINCIPAL	    
    BSF	    JA_LI_DOWN		    
    DECF    UNIDADE,F		    
    MOVLW   .16			    
    SUBWF   UNIDADE,W		    
    BTFSC   STATUS,C		    
    CALL    EH_NEGATIVO		    
    CALL    ATUALIZA_DISPLAY	    
    GOTO    LACO_PRINCIPAL	    
    
EH_NEGATIVO
    MOVLW   .15			  
    MOVWF   UNIDADE		    
    RETURN
    
B_DOWN_N_ACIONADO
    
    MOVLW   V_FILTRO
    MOVWF   FILTRO_DOWN
    BCF	    JA_LI_DOWN
    GOTO    LACO_PRINCIPAL
    
ATUALIZA_DISPLAY
    MOVF    UNIDADE,W		    
    CALL    BUSCA_CODIGO	    
    MOVWF   DISPLAY		    
    
    RETURN			    
    
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
    RETLW   0xBF		    ;retorna a subrotina com w = 0xBF
    RETLW   0XF3		    ;retorna a subrotina com w = 0x73
    RETLW   0xD6		    ;retorna a subrotina com w = 0xD6
    RETLW   0XF9		    ;retorna a subrotina com w = 0xFA
    RETLW   0XD7		    ;retorna a subrotina com w = 0XD7
    RETLW   0X97		    ;retorna a subrotina com w = 0X97
    
    END