; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF
    
#define BANK0		    BCF STATUS,RP0
#define BANK1		    BSF STATUS,RP0
 
    CBLOCK 0x20
	FILTRO_LIGA
	UNIDADE
	FLAGS
	W_TEMP
	S_TEMP
	TIMER_COUNT
    ENDC
 
; 0+1+9+4+9+0+1+3+6+0+0+2+2+0+1+2+2+0+0+3 = 45
; 45 * 150 = 6750ms = 6.75 s
 
;Entradas
#define BOT_LIGA	    PORTA,3
#define BOT_DESLIGA	    PORTA,4

;Saidas
#define CP		    PORTA,0	
#define LE		    PORTA,1	
#define LT		    PORTA,2
#define	DISPLAY		    PORTB
    
;Variaveis
#define JA_LI_LIGA		    FLAGS,0
    
;Constantes
V_FILTRO    equ	.100
TIMER_MAX   equ  .0

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
INT_VEC CODE    0x0004              ; Vetor de interrupção

    MOVWF   W_TEMP                  
    MOVF    STATUS,W                
    MOVWF   S_TEMP                  
    BTFSS   INTCON,T0IF             
    GOTO    SAI_INTERRUPCAO         
    BCF     INTCON,T0IF             
    MOVLW   TIMER_MAX               
    ADDWF   TMR0,F                  

    INCF    TIMER_COUNT,F           
    CALL    LIGA_TRIANGULO          

SAI_INTERRUPCAO
    MOVF    S_TEMP,W                
    MOVWF   STATUS
    MOVF    W_TEMP,W                
    RETFIE
    
START
    BANK1			    
    CLRF    TRISB		    
    BCF	    TRISA,0
    BCF	    TRISA,1
    BCF	    TRISA,2
    MOVLW   B'11010111'		  				  
    MOVWF   OPTION_REG		    
    BANK0			    	    
    CLRF    UNIDADE
    MOVLW   V_FILTRO		    
    MOVWF   FILTRO_LIGA		    
    BCF	    JA_LI_LIGA
    CLRF    TIMER_COUNT 
    CLRF    TIMER_MAX
    BCF	    INTCON,T0IE
    BSF	    INTCON,GIE
    CALL    ATUALIZA_DISPLAY
    
LOOP
    BTFSS	BOT_DESLIGA		    
    GOTO	DESLIGA_MOTOR	    
    BTFSS	BOT_LIGA		    
    GOTO	LIGA_ACIONADO	    
    GOTO	LOOP	 
   
LIGA_ACIONADO
    BTFSC	JA_LI_LIGA		    
    GOTO	LOOP		    
    DECFSZ	FILTRO_LIGA,F		    
    GOTO	LOOP		    
    BSF		JA_LI_LIGA           
    GOTO	LIGA_ESTRELA

LIGA_ESTRELA
    BSF     CP                  
    BSF     LE
    BCF	    LT
    MOVLW   .1                  
    MOVWF   UNIDADE
    CALL    ATUALIZA_DISPLAY
    CLRF    TIMER_COUNT                  
    BSF     INTCON,T0IE             
    GOTO    LOOP

LIGA_TRIANGULO
    MOVLW   .103                    
    SUBWF   TIMER_COUNT,W               
    BTFSS   STATUS,Z                
    RETURN                          
    BCF     INTCON,T0IE            
    BSF	    CP
    BCF     LE                  
    BSF     LT                  
    MOVLW   .2                  
    MOVWF   UNIDADE
    CALL    ATUALIZA_DISPLAY
    GOTO    LOOP

DESLIGA_MOTOR
    BCF     CP                  
    BCF     LE                  
    BCF     LT                  
    MOVLW   .0                  
    MOVWF   UNIDADE
    CALL    ATUALIZA_DISPLAY
    BCF	    JA_LI_LIGA
    CLRF    TIMER_COUNT
    CLRF    TIMER_MAX
    GOTO    LOOP

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
    
    END