; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR

; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0x3F70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

 
; saídas
#define LED0 PORTB,0
#define LED1 PORTB,1
#define LED2 PORTB,2
#define LED3 PORTB,3

; entradas
#define BOTAO1 PORTA,1
#define BOTAO2 PORTA,2
#define BOTAO3 PORTA,3
#define BOTAO4 PORTA,4


RES_VECT CODE 0x0000	    
    BSF	    STATUS,RP0	    
    CLRF    TRISB	    
    BCF	    STATUS,RP0	    

    GOTO LOOP		    


LOOP
    CLRF    PORTB	    
    GOTO    LIGAR0


LIGAR0			    
    BTFSC   BOTAO1	    
    GOTO    LIGAR0	    

    BSF	    LED0	    

    GOTO    LIGAR1	    

LIGAR1
    BTFSC   BOTAO2
    GOTO    LIGAR1

    BSF	    LED1

    GOTO    LIGAR2

LIGAR2
    BTFSC   BOTAO3
    GOTO    LIGAR2

    BSF	    LED2

    GOTO    LIGAR3

LIGAR3
    BTFSC   BOTAO4
    GOTO    LIGAR3

    BSF	    LED3

    GOTO    DESLIGAR0    


DESLIGAR0
    BTFSC   BOTAO1	   
    GOTO    DESLIGAR0   

    BCF	    LED0	    

    GOTO    DESLIGAR1    

DESLIGAR1
    BTFSC   BOTAO2
    GOTO    DESLIGAR1

    BCF	    LED1

    GOTO    DESLIGAR2

DESLIGAR2
    BTFSC   BOTAO3
    GOTO    DESLIGAR2

    BCF	    LED2

    GOTO    DESLIGAR3

DESLIGAR3
    BTFSC   BOTAO4
    GOTO    DESLIGAR3

    BCF	    LED3

    GOTO    LOOP	   


    END
