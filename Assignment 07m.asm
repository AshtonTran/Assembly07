;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F690. This file contains the basic code               *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F690.INC                                      *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f690		; list directive to define processor
	#include	<P16F690.inc>		; processor specific variable definitions
	
	__CONFIG    _CP_OFF & _CPD_OFF & _BOR_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT & _MCLRE_ON & _FCMEN_OFF & _IESO_OFF


; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.






;***** VARIABLE DEFINITIONS
w_temp		EQU	0x7D			; variable used for context saving
status_temp	EQU	0x7E			; variable used for context saving
pclath_temp	EQU	0x7F			; variable used for context saving

COUNT1		EQU	0x20
setinel		EQU	0x21
COUNT2		EQU 0x22
portc		EQU 0x23



;**********************************************************************

  	
	ORG			0x004			; interrupt vector location
	movwf		w_temp			; save off current W register contents
	movf		STATUS,w		; move status register into W register
	movwf		status_temp		; save off contents of STATUS register
	movf		PCLATH,w		; move pclath register into W register
	movwf		pclath_temp		; save off contents of PCLATH register
	goto		main			; go to beginning of program

; isr code can go here or be located as a call subroutine elsewhere

	nop

	incf		COUNT1
	movlw		.18
	subwf		COUNT1
	btfss		STATUS,0
	goto		skip
	clrf		COUNT1
	bsf			setinel,0


main

banksel		TRISC
clrf		TRISC
movlw		0xC0
movwf		TRISB

banksel		OPTION_REG	;option reg for timer
movlw		0x07	
movwf		OPTION_REG
banksel		INTCON
movlw		0x10
movwf		INTCON

banksel		ANSEL
CLRF		ANSEL
CLRF		ANSELH
banksel		PORTC
clrf		PORTC
bcf			PORTC,0

movlw		0x01
movwf		PORTC

again
btfss	setinel,1
goto	again
bcf		setinel,0
call	delay
rlf		PORTC
btfss	STATUS,0
goto	again
bsf		PORTC,0
bcf		STATUS,0
goto	again

delay:
LOOP1   DECFSZ  COUNT1, 1       ;subtract 1 from 255 store new count in COUNT	
		goto	LOOP1			;if COUNT is zero, skip this instruction
		DECFSZ	COUNT2, 1 		;Subtract 1 from 255 	
		goto 	LOOP1			;go back to start of our loop 
								;this delay counts down from 255, 255 times, total 65,025
LOOP2	DECFSZ	COUNT1, 1		;subtract 1 from 255 store new count in COUNT
		goto	LOOP2			;if COUNT is zero, skip this instruction
		DECFSZ	COUNT2, 1 		;Subtract 1 from 255 	
		goto 	LOOP2			;go back to start of our loop
		return
		goto	delay			;GO BACK TO START AND TURN LED ON AGAIN

goto 	again	

skip
movlw	0x01
movwf	PORTC
bcf		STATUS,0
goto	again



	ORG	0x2100				; data EEPROM location
	DE	1,2,3,4				; define first four EEPROM locations as 1, 2, 3, and 4




	END                       ; directive 'end of program'