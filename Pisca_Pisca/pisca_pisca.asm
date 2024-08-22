; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF
 
 
#define	    BANK0	BCF STATUS,RP0
#define	    BANK1	BSF STATUS,RP0
#define	    LAMPADA	PORTA,0

    CBLOCK 0X20
	TEMPO1
	TEMPO2
    ENDC
    

    
V_TEMPO1    equ		 .250
V_TEMPO2    equ		 .250

RES_VECT  CODE    0x0000            ; processor reset vector
    BANK1
    BCF	    TRISA,0
    BANK0

LOOP
    BSF	    LAMPADA
    CALL    ESPERAR
    BCF	    LAMPADA
    CALL    ESPERAR
    GOTO    LOOP
    
ESPERAR
    MOVLW   V_TEMPO1
    MOVWF   TEMPO1  
INICIALIZA_TEMPO2
    MOVLW   V_TEMPO2
    MOVWF   TEMPO2 
DEC_TEMPO2
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ  TEMPO2,F
    GOTO    DEC_TEMPO2
DEC_TEMPO1
    DECFSZ  TEMPO1,F
    GOTO    INICIALIZA_TEMPO2
    RETURN
    
    END