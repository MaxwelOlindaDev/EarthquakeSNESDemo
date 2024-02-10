Earth2:
SEP #$20

;======================
; Controle
;======================
;Y
lda $20 ;Joy1Press 
and #$80
BEQ +
LDA $34
CMP #$D0
BEQ +
CMP #$CF
BEQ +
CMP #$CE
BEQ +
INC $34
JSR WINDOW2SCROLLRIGHT ; Sombra >
+

;A
lda $21 ;Joy1Press 
and #$40
BEQ +
LDA $34
CMP #$40
BEQ +
CMP #$41
BEQ +
CMP #$42
BEQ +
DEC $34
JSR WINDOW2SCROLLLEFT ; Sombra <
+
;======================
; ANIMAÇÃO DO SPRITE MEU NOBRE
;======================

inc $36
LDA $36
CMP #$01
BNE +
LDX #$0000
STX $0810

LDX #earthsegundo1
STX $02
LDX #$005C
STX $54

+
LDA $36
CMP #$04
BNE +
LDX #$2000
STX $0810
DEC $35
DEC $35
INC $34
LDX #earthsegundo2
STX $02
LDX #$0060
STX $54

+
LDA $36
CMP #$08
BNE +
LDX #$4000
STX $0810
INC $35
INC $35
DEC $34
LDX #earthsegundo3
STX $02
LDX #$005C
STX $54

+
LDA $36
CMP #$0c
BNE +
LDX #$6000
STX $0810
INC $35
INC $35
DEC $34
LDX #earthsegundo4
STX $02
LDX #$005C
STX $54
+
LDA $36
CMP #$10
BNE +
LDX #$0000
STX $0810
DEC $35
DEC $35
INC $34
LDX #earthsegundo1
STX $02
LDX #$005C
STX $54
stz $36
+

bra pulaDMArotina2

MinaDMArotina2:
;======================
; DMA
;======================
  
LDX $0736
CPX $0810
BEQ +++

REP #$20
LDA #DMAMina2
CLC
ADC $0810 ; OFFSET DA ORIGEM
STA $0812 ; LOCAL PARA DMAR 

LDA #$4300   ; Direct page agora são os registros de DMA  
TCD
SEP #$20

LDA #$80            ; \ Increase on $2119 write.
STA $2115           ; /
	
LDA #$01
STA $00    ; ...2 regs write once. (4300)
LDA #$18
STA $01    ; Writing to $2118 AND $2119. (4301)
LDA #$C3
STA $04      ; Bank where our data is. (4304)

LDY #$7000
STY $2116    ; Local da VRAM
LDY $0812
STY $02      ; Adress where our data is. (4302)
LDY #$1C00
STY $05      ; Size of our data. (4305)
LDA #$01
STA $420B    ; Iniciar DMA canal 0

REP #$20
LDA #$0000   ; Direct page agora NÃO são os registros de DMA  
TCD
SEP #$20

LDX $0810
STX $0736
+++
RTS

pulaDMArotina2:

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
LDA ($02),y
sep #$20
CLC 
ADC $34
XBA 
CLC 
ADC $35
XBA 
rep #$20
STA $0370,x
INY
INY
INY
INY
INY
INX
INX
INX
INX
CPX $54
BMI -

LDX #$0000
TXY

;----------------
; TILES
;----------------
INY
INY
-
LDA ($02),y
STA $0372,x
INY
INY
INY
INY
INY
INX
INX
INX
INX
CPX $54
BMI -

LDX #$0000
TXY

REP #$20
LDA $54
LSR
LSR
LSR
LSR
INC A
STA $56

;----------------
;2º PAGE
;----------------
SEP #$20
INY
INY
INY
INY
-
LDA ($02),y
STA $06
INY
INY
INY
INY
INY
LDA ($02),y
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
LDA ($02),y
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
LDA ($02),y
ASL
ASL
ASL
ASL
ASL
ASL
EOR $06
STA $0507,x
INX
INY
INY
INY
INY
INY
CPX $56
BMI -

RTS

earthsegundo1:
;     p X  p Y  Tile Prop Size
.db $E0, $C0, $06, $23, $02
.db $00, $C0, $0A, $23, $02
.db $E0, $E0, $46, $23, $02
.db $D0, $E0, $44, $23, $00
.db $00, $E0, $4A, $23, $02
.db $E0, $00, $86, $23, $00
.db $F0, $00, $88, $23, $00
.db $00, $00, $8A, $23, $00
.db $10, $00, $8C, $23, $00
.db $20, $C0, $0E, $23, $00
.db $20, $D0, $2E, $23, $00
.db $20, $E0, $4E, $23, $00
.db $20, $F0, $6E, $23, $00
.db $20, $00, $8E, $23, $00
.db $C6, $10, $A4, $23, $02
.db $E6, $10, $A8, $23, $02
.db $06, $10, $AC, $23, $02
.db $D0, $30, $A0, $23, $02
.db $10, $30, $00, $23, $02
.db $F0, $30, $04, $23, $00
.db $F0, $40, $24, $23, $00
.db $00, $40, $60, $23, $00
.db $C0, $F0, $62, $23, $02
.db $80 ;end of data
;----------------
earthsegundo2:
.db $E0, $C0, $06, $23, $02
.db $00, $C0, $0A, $23, $02
.db $E0, $E0, $46, $23, $02
.db $00, $E0, $4A, $23, $02
.db $D0, $E0, $44, $23, $00
.db $20, $D0, $2E, $23, $00
.db $20, $E0, $4E, $23, $00
.db $20, $F0, $6E, $23, $00
.db $20, $00, $8E, $23, $00
.db $E0, $00, $86, $23, $00
.db $F0, $00, $88, $23, $00
.db $00, $00, $8A, $23, $00
.db $10, $00, $8C, $23, $00
.db $C5, $10, $A4, $23, $02
.db $E5, $10, $A8, $23, $02
.db $05, $10, $AC, $23, $02
.db $10, $32, $00, $23, $02
.db $10, $30, $40, $23, $00
.db $13, $30, $40, $23, $00
.db $D0, $30, $A0, $23, $02
.db $F0, $30, $04, $23, $00
.db $F0, $40, $24, $23, $00
.db $00, $40, $60, $23, $00
.db $C0, $F0, $62, $23, $02
.db $80 ;end of data
;----------------
earthsegundo3:
.db $E0, $C0, $06, $23, $02
.db $00, $C0, $0A, $23, $02
.db $E0, $E0, $46, $23, $02
.db $00, $E0, $4A, $23, $02
.db $20, $C0, $0E, $23, $00
.db $20, $D0, $2E, $23, $00
.db $20, $E0, $4E, $23, $00
.db $20, $F0, $6E, $23, $00
.db $20, $00, $8E, $23, $00
.db $C0, $F0, $62, $23, $02
.db $D0, $E0, $44, $23, $00
.db $E0, $00, $86, $23, $00
.db $F0, $00, $88, $23, $00
.db $00, $00, $8A, $23, $00
.db $10, $00, $8C, $23, $00
.db $C6, $10, $A4, $23, $02
.db $E6, $10, $A8, $23, $02
.db $06, $10, $AC, $23, $02
.db $D0, $30, $A0, $23, $02
.db $10, $30, $00, $23, $02
.db $F0, $30, $04, $23, $00
.db $F0, $40, $24, $23, $00
.db $00, $40, $60, $23, $00
.db $80 ;end of data
;----------------
earthsegundo4:
.db $E0, $C0, $06, $23, $02
.db $00, $C0, $0A, $23, $02
.db $E0, $E0, $46, $23, $02
.db $00, $E0, $4A, $23, $02
.db $20, $C0, $0E, $23, $00
.db $20, $D0, $2E, $23, $00
.db $20, $E0, $4E, $23, $00
.db $10, $F0, $6C, $23, $02
.db $00, $00, $8A, $23, $00
.db $F0, $00, $88, $23, $00
.db $E0, $00, $86, $23, $00
.db $D0, $E0, $44, $23, $00
.db $C0, $F0, $62, $23, $02
.db $C6, $10, $A4, $23, $02
.db $E6, $10, $A8, $23, $02
.db $06, $10, $AC, $23, $02
.db $15, $30, $00, $23, $02
.db $D5, $30, $A0, $23, $02
.db $F5, $30, $04, $23, $00
.db $F5, $40, $24, $23, $00
.db $05, $30, $40, $23, $00
.db $05, $40, $60, $23, $00
.db $C5, $40, $80, $23, $00
.db $80 ;end of data
;----------------
