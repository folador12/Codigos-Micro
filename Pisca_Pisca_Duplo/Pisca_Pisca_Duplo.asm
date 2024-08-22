; PIC16F628A Configuration Bit Settings

; Assembly source line config statements

#include "p16f628a.inc"

; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF
 
 
#define BANK0		BCF STATUS, RP0
#define BANK1		BSF STATUS, RP0
 
#define LAMPADA		PORTA,0
 
#define BOT1		PORTA,1
#define BOT2		PORTA,2
#define BOT3		PORTA,3
 
    CBLOCK 0x20
	TEMPO1
	TEMPO2
	FLAG_PISCA
	FREQUENCIA
    ENDC
    
    
V_TEMPO1_2HZ		equ .250    ; Tempo para 2Hz (HIGH)
V_TEMPO2_2HZ		equ .250    ; Tempo para 2Hz (LOW)
V_TEMPO1_5HZ		equ .100    ; Tempo para 5Hz (HIGH)
V_TEMPO2_5HZ		equ .100    ; Tempo para 5Hz (LOW)

RES_VECT  CODE    0x0000            ; processor reset vector
    BANK1
    BCF	    TRISA,0
    BANK0
    CLRF PORTA            ; Inicia RA0 (LAMPADA) apagado
    CLRF FLAG_PISCA       ; Inicializa flag de pisca desligado
    CLRF FREQUENCIA       ; Inicializa a frequência como 0

LOOP
    BTFSC	    BOT1       ; Verifica se o botão RA1 foi pressionado (2Hz)
    CALL	    PISCA_2HZ
    BTFSC	    BOT2       ; Verifica se o botão RA2 foi pressionado (5Hz)
    CALL	    PISCA_5HZ
    BTFSC	    BOT3      ; Verifica se o botão RA3 foi pressionado (desligar)
    CALL	    DESLIGAR
    GOTO	    LOOP
    
    
PISCA_2HZ
    MOVF FLAG_PISCA, W
    BTFSS STATUS, Z       ; Se já estiver piscando, sai
    RETURN
    MOVLW 0x01            ; Configura 2Hz como frequência atual
    MOVWF FREQUENCIA
    BSF FLAG_PISCA        ; Habilita o pisca
    GOTO INICIAR_PISCA

PISCA_5HZ
    MOVF FLAG_PISCA, W
    BTFSS STATUS, Z       ; Se já estiver piscando, sai
    RETURN
    MOVLW 0x02            ; Configura 5Hz como frequência atual
    MOVWF FREQUENCIA
    BSF FLAG_PISCA        ; Habilita o pisca
    GOTO INICIAR_PISCA

INICIAR_PISCA
    BTFSS FLAG_PISCA, 0   ; Verifica se o pisca está habilitado
    RETURN
    BSF LAMPADA           ; Liga a lâmpada
    CALL ESPERAR
    BCF LAMPADA           ; Desliga a lâmpada
    CALL ESPERAR
    GOTO INICIAR_PISCA

ESPERAR
    MOVF FREQUENCIA, W
    BTFSC STATUS, Z
    RETURN
    MOVLW V_TEMPO1_2HZ
    MOVWF TEMPO1
    MOVLW V_TEMPO2_2HZ
    MOVWF TEMPO2
    MOVLW V_TEMPO1_5HZ
    MOVWF TEMPO1
    MOVLW V_TEMPO2_5HZ
    MOVWF TEMPO2
    CALL DELAY
    RETURN

DESLIGAR
    BCF FLAG_PISCA        ; Desabilita o pisca
    CLRF PORTA            ; Apaga a lâmpada
    RETURN

DELAY
    DECFSZ TEMPO1, F
    GOTO $-1
    DECFSZ TEMPO2, F
    GOTO $-2
    RETURN

    END