;-----------------------------------------------------------------------		
;
; MiniTurbo
; (c) 2023 GienekP
;
;-----------------------------------------------------------------------

RAMPROC = $0100

;-----------------------------------------------------------------------

TMP     = $A0

;-----------------------------------------------------------------------

DMACTLS = $022F
GINTLK  = $03FA
TRIG3   = $D013
IRQEN   = $D20E
IRQST   = $D20E
PORTB   = $D301
DMACTL  = $D400
VCOUNT  = $D40B
NMIEN   = $D40E

;-----------------------------------------------------------------------		
; CODE FOR CARTRIDGE BANK

		OPT h-f+
		
		ORG $BE00

;-----------------------------------------------------------------------		
; UPGRADE TABLE: ADDRES OLD NEW

UPGDATA	dta a($FB0A),$94,$B4	; background green
		dta a($C4F9),$FF,$FE	; anty soft RESET
		dta a($C50B),$FF,$FE	; anty soft RESET
		dta a($C4A5),$FD,$FC	; anty soft RESET
		dta a($C4ED),$9D,$8D	; $D305 protect
		
		dta a($FD3A),$02,$03	; 3x horn for save
		
		dta a($EBA8),$05,$04	; speed $05CC(600) -> $0443(807)
		dta a($EBA3),$CC,$43	; speed $05CC(600) -> $0443(807)
		dta a($FD46),$05,$04	; speed $05CC(600) -> $0443(807)
		dta a($FD41),$CC,$43	; speed $05CC(600) -> $0443(807)

		
		dta a($FE8E),$03,$00	; pilot save PAL 2 sec
		dta a($FE90),$C0,$64	; pilot save PAL 2 sec

		dta a($FE8D),$04,$00	; pilot save NTSC 2 sec
		dta a($FE8F),$80,$78	; pilot save NTSC 2 sec


		dta a($FE92),$01,$00	; pilot load PAL 1 sec
		dta a($FE94),$E0,$32	; pilot load PAL 1 sec

		dta a($FE91),$02,$00	; pilot load NTSC 1 sec
		dta a($FE93),$40,$3C	; pilot load NTSC 1 sec


		dta a($EE14),$64,$04	; short save PAL
		dta a($EE13),$78,$06	; short save NTSC

		dta a($EE18),$08,$02	; short load PAL
		dta a($EE17),$0A,$03	; short load NTSC

		dta a($EE12),$96,$08	; long save PAL
		dta a($EE11),$B4,$0A	; long save NTSC

		dta a($EE16),$0D,$02	; long load PAL
		dta a($EE15),$0F,$03	; long load NTSC


ENDDATA
	
;-----------------------------------------------------------------------		

		ORG $BF20

;-----------------------------------------------------------------------		
; UPGRADE

UPGRADE	ldy #$00
		ldx #$00
UPLOOP	lda UPGDATA,X
		sta TMP
		inx
		lda UPGDATA,X
		sta TMP+1
		inx
		lda UPGDATA,X
		sta TMP+2
		inx
		lda UPGDATA,X
		sta TMP+3
		inx
		lda (TMP),Y
		cmp TMP+2
		bne dif
		lda TMP+3
		sta (TMP),Y	
dif		cpx #ENDDATA-UPGDATA
		bne UPLOOP
		rts

;-----------------------------------------------------------------------		
; IRQ ENABLE

IRQENB	lda #$40
		sta NMIEN
		lda #$F7
		sta IRQST
		lda DMACTLS
		sta DMACTL
		cli
		rts

;-----------------------------------------------------------------------		
; IRQ DISABLE

IRQDIS	sei	
		lda #$00
		sta DMACTL
		sta NMIEN
		sta IRQEN
		sta IRQST
		rts

;-----------------------------------------------------------------------		
; COPY ROM TO RAM

ROM2RAM	lda PORTB
		pha
		lda #$C0
		sta TMP+1
		ldy #$00
		sty TMP
		ldx #$FF			
CPOS	stx PORTB
		lda (TMP),Y
		dex
		stx PORTB
		sta (TMP),Y
		inx
		iny
		bne CPOS
		inc TMP+1
		lda TMP+1
		cmp #$D0
		bne OSOK
		lda #$D8
		sta TMP+1
OSOK	cmp #$00
		bne CPOS
		pla
		and #$FE
		sta PORTB
		rts
		
;-----------------------------------------------------------------------		
; PREPARE TURNOF PROC

PREP	lda #<TURNOFF
		sta TMP
		lda #>TURNOFF
		sta TMP+1
		lda #<RAMPROC
		sta TMP+2
		lda #>RAMPROC
		sta TMP+3		
		ldy #TURNEND-TURNOFF-1
PREPCPY	lda (TMP),Y
		sta (TMP+2),Y
		dey
		bne PREPCPY
		lda (TMP),Y
		sta (TMP+2),Y
		rts
	
;-----------------------------------------------------------------------		
; LEAVE CART SPACE

BYEBYE	lda #$00
		sta TMP
		sta TMP+1
		sta TMP+2
		sta TMP+3
		jmp RAMPROC

;-----------------------------------------------------------------------		
; INIT ROUTINE

INIT	jsr IRQDIS
		jsr ROM2RAM
		jsr UPGRADE
		jsr IRQENB
		jsr PREP
		jmp BYEBYE

;-----------------------------------------------------------------------		

		ORG $BFE4

;-----------------------------------------------------------------------		
; RELOC CODE FOR RAMPROC

TURNOFF	lda #$70
LICNT	cmp VCOUNT
		bne LICNT		
		lda #$FF
		sta $D580
		lda TRIG3
		sta GINTLK
		rts		
TURNEND

;-----------------------------------------------------------------------		

		ORG $BFF7

;-----------------------------------------------------------------------		
; CARTRUN ROUTINE

BEGIN	jmp BEGIN

;-----------------------------------------------------------------------		

		ORG $BFFA
		dta <BEGIN, >BEGIN, $00, $04, <INIT, >INIT

;-----------------------------------------------------------------------		
