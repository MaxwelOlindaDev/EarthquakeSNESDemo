Earth1:
SEP #$20

;======================
; Controle
;======================

;direita
lda $21 ;Joy1Press 
and #$01
BEQ ++
LDA $30
CMP #$D0
BEQ ++
CMP #$D1
BEQ ++
CMP #$D2
BEQ ++
CMP #$D3
BEQ ++
CMP #$D4
BEQ ++
INC $30
JSR WINDOW1SCROLLRIGHT ; Sombra >
++

;esquerda
lda $21 ;Joy1Press 
and #$02
BEQ +
LDA $30
CMP #$3E
BEQ +
CMP #$3F
BEQ +
CMP #$40
BEQ +
CMP #$41
BEQ +
CMP #$42
BEQ +
DEC $30
JSR WINDOW1SCROLLLEFT ; Sombra <
+

;======================
; ANIMAÇÃO DO SPRITE
;======================

inc $32
LDA $32
CMP #$01
BNE +
LDX #$0000
STX $0800
DEC $31
DEC $30
LDX #earth1
STX $00
LDX #$0050
STX $50

+
LDA $32
CMP #$04
BNE +
LDX #$2000
STX $0800
DEC $31
DEC $30
INC $30
INC $30
INC $30
LDX #earth2
STX $00
LDX #$0050
STX $50

+
LDA $32
CMP #$08
BNE +
LDX #$4000
STX $0800
INC $31
INC $30
INC $30
LDX #earth3
STX $00
LDX #$005C
STX $50

+
LDA $32
CMP #$0C
BNE +
LDX #$6000
STX $0800
DEC $31
LDX #earth4
STX $00
LDX #$005C
STX $50

+
LDA $32
CMP #$10
BNE +
LDX #$8000
STX $0800
dec $30
DEC $30
LDX #earth5
STX $00
LDX #$0060
STX $50

+
LDA $32
CMP #$14
BNE +
LDX #$a000
STX $0800
DEC $30
LDX #earth6
STX $00
LDX #$0058
STX $50
+
LDA $32
CMP #$18
BNE +
LDX #$c000
STX $0800
INC $31
INC $30
DEC $30
LDX #earth7
STX $00
LDX #$0064
STX $50
+
LDA $32
CMP #$1C
BNE +
LDX #$e000
STX $0800
INC $31
LDX #earth8
STX $00
LDX #$0054
STX $50
+
LDA $32
CMP #$20
BNE +
stz $32
+

bra pulaDMArotina

MinaDMArotina:
;======================
; DMA
;======================
LDX $0733
CPX $0800
BEQ +++

REP #$20
LDA #DMAMina
CLC
ADC $0800 ; OFFSET DA ORIGEM
STA $0802 ; LOCAL PARA DMAR 

LDA #$4300   ; Direct page agora são os registros de DMA  
TCD
SEP #$20

LDA #$80            ; \ Increase on $2119 write.
STA $2115           ; /
	
LDA #$01
STA $00    ; ...2 regs write once. (4300)
LDA #$18
STA $01    ; Writing to $2118 AND $2119. (4301)
LDA #$C2
STA $04      ; Bank where our data is. (4304)

LDY #$6000
STY $2116    ; Local da VRAM
LDY $0802
STY $02      ; Adress where our data is. (4302)
LDY #$1C00
STY $05      ; Size of our data. (4305)
LDA #$01
STA $420B    ; Iniciar DMA canal 0

PEA $0000   ; Direct page agora NÃO são os registros de DMA  
PLD

LDX $0800
STX $0733
+++
RTS

pulaDMArotina:

;======================
; OAM MEMES (DOR DE CABEÇA)
;======================
; Config

STZ $06
ldx #$0000
TXY

;----------------
; X - Y
;----------------
REP #$20
-
LDA ($00),y
sep #$20
CLC 
ADC $30
XBA 
CLC 
ADC $31
XBA 
rep #$20
STA $0300,x
INY
INY
INY
INY
INY
INX
INX
INX
INX
CPX $50
BMI -

LDX #$0000
TXY

;----------------
; TILES
;----------------
INY
INY
-
LDA ($00),y
STA $0302,x
INY
INY
INY
INY
INY
INX
INX
INX
INX
CPX $50
BMI -

LDX #$0000
TXY

REP #$20
LDA $50
LSR
LSR
LSR
LSR
INC A
STA $52

;----------------
;2º PAGE
;----------------
SEP #$20
INY
INY
INY
INY
-
LDA ($00),y
STA $06
INY
INY
INY
INY
INY
LDA ($00),y
CLC 
ASL
ASL
EOR $06
STA $06
INY
INY
INY
INY
INY
LDA ($00),y
ASL
ASL
ASL
ASL
EOR $06
STA $06
INY
INY
INY
INY
INY
LDA ($00),y
ASL
ASL
ASL
ASL
ASL
ASL
EOR $06
STA $0500,x
INX
INY
INY
INY
INY
INY
CPX $52
BMI -

RTS

earth1:
;     p X  p Y  Tile Prop Size
.db $C2, $CE, $00, $20, $02
.db $E2, $CE, $04, $20, $02
.db $02, $CE, $08, $20, $02
.db $C2, $EE, $40, $20, $02
.db $E2, $EE, $44, $20, $02
.db $02, $EE, $48, $20, $02
.db $C2, $0E, $80, $20, $02
.db $E2, $0E, $84, $20, $02
.db $02, $0E, $88, $20, $02
.db $CA, $2E, $C1, $20, $00
.db $DA, $2E, $C3, $20, $00
.db $EA, $2E, $C5, $20, $00
.db $FA, $2E, $C7, $20, $00
.db $0A, $2E, $C9, $20, $00
.db $12, $2E, $CA, $20, $00
.db $C2, $3E, $0C, $20, $02
.db $08, $3E, $AC, $20, $02
.db $E2, $3E, $4E, $20, $00
.db $1A, $F6, $5B, $20, $02
.db $22, $0E, $8C, $20, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
earth2:
.db $C2, $CE, $00, $20, $02
.db $E2, $CE, $04, $20, $02
.db $02, $CE, $08, $20, $02
.db $C2, $EE, $40, $20, $02
.db $E2, $EE, $44, $20, $02
.db $02, $EE, $48, $20, $02
.db $C2, $0E, $80, $20, $02
.db $E2, $0E, $84, $20, $02
.db $02, $0E, $88, $20, $02
.db $CA, $2E, $C1, $20, $00
.db $DA, $2E, $C3, $20, $00
.db $EA, $2E, $C5, $20, $00
.db $FA, $2E, $C7, $20, $00
.db $0A, $2E, $C9, $20, $00
.db $12, $2E, $CA, $20, $00
.db $C2, $3E, $0C, $20, $02
.db $05, $3E, $AC, $20, $02
.db $E2, $3E, $4E, $20, $00
.db $1A, $F6, $5B, $20, $02
.db $22, $0E, $8C, $20, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
earth3:
.db $C0, $CB, $00, $20, $02
.db $E0, $CB, $04, $20, $02
.db $00, $CB, $08, $20, $02
.db $C0, $EB, $40, $20, $02
.db $E0, $EB, $44, $20, $02
.db $00, $EB, $48, $20, $02
.db $C0, $0B, $80, $20, $00
.db $D0, $0B, $82, $20, $00
.db $E0, $0B, $84, $20, $00
.db $F0, $0B, $86, $20, $00
.db $00, $0B, $88, $20, $00
.db $10, $0B, $8A, $20, $00
.db $20, $0B, $8C, $20, $00
.db $20, $EB, $4C, $20, $00
.db $20, $FB, $6C, $20, $00
.db $CB, $1B, $A0, $20, $02
.db $EB, $1B, $A4, $20, $02
.db $0B, $1B, $A8, $20, $02
.db $C0, $3B, $6E, $20, $00
.db $D0, $3B, $4E, $20, $00
.db $DF, $3B, $8E, $20, $00
.db $C0, $3D, $0C, $20, $02
.db $02, $3B, $AC, $20, $02
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
earth4:
.db $C1, $CE, $00, $20, $02
.db $E1, $CE, $04, $20, $02
.db $01, $CE, $08, $20, $02
.db $C1, $EE, $40, $20, $02
.db $E1, $EE, $44, $20, $02
.db $01, $EE, $48, $20, $02
.db $C1, $0E, $80, $20, $02
.db $E1, $0E, $84, $20, $02
.db $01, $0E, $88, $20, $02
.db $C9, $2E, $C1, $20, $00
.db $D9, $2E, $C3, $20, $00
.db $E9, $2E, $C5, $20, $00
.db $F9, $2E, $C7, $20, $00
.db $09, $2E, $C9, $20, $00
.db $11, $2E, $CA, $20, $00
.db $21, $EE, $4C, $20, $00
.db $21, $FE, $6C, $20, $00
.db $21, $0E, $8C, $20, $00
.db $1A, $DE, $6E, $20, $00
.db $19, $CE, $4E, $20, $00
.db $C4, $3E, $0C, $20, $02
.db $03, $3E, $AC, $20, $02
.db $10, $C2, $8E, $20, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
earth5:
.db $C3, $CF, $00, $20, $02
.db $E3, $CF, $04, $20, $02
.db $03, $CF, $08, $20, $02
.db $C3, $EF, $40, $20, $02
.db $E3, $EF, $44, $20, $02
.db $03, $EF, $48, $20, $02
.db $C3, $0F, $80, $20, $02
.db $E3, $0F, $84, $20, $02
.db $03, $0F, $88, $20, $02
.db $CB, $2F, $C1, $20, $00
.db $DB, $2F, $C3, $20, $00
.db $EB, $2F, $C5, $20, $00
.db $FB, $2F, $C7, $20, $00
.db $0B, $2F, $C9, $20, $00
.db $13, $2F, $CA, $20, $00
.db $05, $3F, $AC, $20, $02
.db $23, $EF, $4C, $20, $00
.db $23, $FF, $6C, $20, $00
.db $23, $0F, $8C, $20, $00
.db $29, $DF, $8E, $20, $00
.db $2D, $CF, $6E, $20, $00
.db $C3, $3F, $0C, $20, $02
.db $31, $C0, $4E, $20, $00
.db $E3, $3F, $B0, $E0, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
earth6:
.db $C4, $D0, $00, $20, $02
.db $E4, $D0, $04, $20, $02
.db $04, $D0, $08, $20, $02
.db $C4, $F0, $40, $20, $02
.db $E4, $F0, $44, $20, $02
.db $04, $F0, $48, $20, $02
.db $C4, $10, $80, $20, $02
.db $E4, $10, $84, $20, $02
.db $04, $10, $88, $20, $02
.db $CC, $30, $C1, $20, $00
.db $DC, $30, $C3, $20, $00
.db $EC, $30, $C5, $20, $00
.db $FC, $30, $C7, $20, $00
.db $0C, $30, $C9, $20, $00
.db $14, $30, $CA, $20, $00
.db $04, $40, $AC, $20, $02
.db $C6, $40, $0C, $20, $02
.db $24, $F0, $4C, $20, $00
.db $24, $00, $6C, $20, $00
.db $24, $10, $8C, $20, $00
.db $34, $EB, $4E, $20, $00
.db $40, $E0, $8E, $20, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
earth7:
.db $C4, $D0, $00, $20, $02
.db $E4, $D0, $04, $20, $02
.db $C4, $F0, $40, $20, $02
.db $E4, $F0, $44, $20, $02
.db $04, $F0, $48, $20, $02
.db $04, $D0, $08, $20, $00
.db $04, $E0, $28, $20, $00
.db $C4, $10, $80, $20, $02
.db $E4, $10, $84, $20, $02
.db $04, $10, $88, $20, $02
.db $CC, $30, $C1, $20, $00
.db $DC, $30, $C3, $20, $00
.db $EC, $30, $C5, $20, $00
.db $FC, $30, $C7, $20, $00
.db $0C, $30, $C9, $20, $00
.db $14, $30, $CA, $20, $00
.db $24, $F0, $4C, $20, $00
.db $24, $00, $6C, $20, $00
.db $24, $10, $8C, $20, $00
.db $34, $00, $6E, $20, $00
.db $34, $10, $8E, $20, $00
.db $40, $05, $4E, $20, $00
.db $C4, $40, $0C, $20, $02
.db $04, $40, $AC, $20, $02
.db $E4, $40, $0A, $20, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
earth8:
.db $C4, $CE, $00, $20, $02
.db $E4, $CE, $04, $20, $02
.db $04, $CE, $08, $20, $02
.db $C4, $EE, $40, $20, $02
.db $E4, $EE, $44, $20, $02
.db $04, $EE, $48, $20, $02
.db $C4, $0E, $80, $20, $02
.db $E4, $0E, $84, $20, $02
.db $04, $0E, $88, $20, $02
.db $CC, $2E, $C1, $20, $00
.db $DC, $2E, $C3, $20, $00
.db $EC, $2E, $C5, $20, $00
.db $FC, $2E, $C7, $20, $00
.db $0C, $2E, $C9, $20, $00
.db $14, $2E, $CA, $20, $00
.db $C4, $3E, $0C, $20, $02
.db $04, $3E, $AC, $20, $02
.db $24, $EE, $4C, $20, $00
.db $24, $FE, $6C, $20, $00
.db $24, $0E, $8C, $20, $00
.db $24, $1E, $4E, $20, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $E0, $00, $00, $00, $00, $E0, $00, $00, $00, $00
.db $80 ;end of data
;----------------
