; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR

; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0x3F70
    __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF


#define BANK0	BCF STATUS,RP0
#define BANK1	BSF STATUS,RP0

    CBLOCK 0X20
	FILTRO
	UNIDADE
	FLAGS
    ENDC


#define JA_LI	FLAGS,0


#define B_ZERAR	PORTA,1
#define B_UP	PORTA,2
#define B_DOWN	PORTA,3


#define DISPLAY PORTB


V_FILTRO	equ .100


RES_VECT  CODE    0x0000            ; processor reset vector
    
    BANK1			    
    CLRF    TRISB		    
    BANK0			    
    
    MOVLW   V_FILTRO		    
    MOVWF   FILTRO		    
    BCF	    JA_LI		    
    CLRF    UNIDADE		    
    
    CALL    ATUALIZA_DISPLAY	    
    
LOOP
    BTFSS   B_ZERAR		    
    GOTO    B_ZERAR_ACIONADO	    
  
    BTFSS   B_UP		    
    GOTO    B_UP_ACIONADO
    
    BTFSS   B_DOWN
    GOTO    B_DOWN_ACIONADO
    
    GOTO    B_N_ACIONADO
    
B_N_ACIONADO
    MOVLW   V_FILTRO		    
    MOVWF   FILTRO		    
    BCF	    JA_LI		    
    
    GOTO    LOOP
    
B_ZERAR_ACIONADO
    CLRF    UNIDADE		    
    CALL    ATUALIZA_DISPLAY	    
    
    GOTO    LOOP	    
    
B_UP_ACIONADO
    BTFSC   JA_LI		    
    GOTO    LOOP	   
    DECFSZ  FILTRO,F		   
    GOTO    LOOP	    
    BSF	    JA_LI		    
    INCF    UNIDADE,F		    
    MOVLW   .10			   
    SUBWF   UNIDADE,W		    
    BTFSC   STATUS,C		    
    CLRF    UNIDADE		    
 
    CALL    ATUALIZA_DISPLAY	    
    GOTO    LOOP	    

B_DOWN_ACIONADO
    BTFSC   JA_LI		   
    GOTO    LOOP	    
    DECFSZ  FILTRO,F		    
    GOTO    LOOP	    
    BSF     JA_LI		    
    DECF    UNIDADE,F		    
    MOVLW   .10			    
    SUBWF   UNIDADE,W		    
    BTFSC   STATUS,C		    
    CALL    SET_9
    
    CALL    ATUALIZA_DISPLAY	    
    GOTO    LOOP	    
    
  
ATUALIZA_DISPLAY
    MOVF    UNIDADE,W		   
    CALL    BUSCA_CODIGO	    
    MOVWF   DISPLAY		    
    
    RETURN			    
    
    
SET_9
    MOVLW   .9                 
    MOVWF   UNIDADE            
    
    RETURN
    

BUSCA_CODIGO
    ADDWF   PCL,F		    
    
    RETLW   0xFE		   
    RETLW   0x38		    
    RETLW   0xDD		    
    RETLW   0x7D	    	    
    RETLW   0x3B		    
    RETLW   0x77		   
    RETLW   0xF7		    
    RETLW   0x3C		    
    RETLW   0xFF		    
    RETLW   0x7F		    
    
    END
