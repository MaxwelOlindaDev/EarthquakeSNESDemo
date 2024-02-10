;------------------------------------------------------------------------
;-  Escrito por Maxwel Olinda, aproveitando exemplos do Neviksti.
;------------------------------------------------------------------------

;==============================================================================
; Aqui é incluído arquivos de fora, isso inclui o "show.inc" que possui informações
; da header.
; O "InitSNES.asm" prepara registros e zera todas as RAMs, pois o SNES inicia com valores
; aleatórios.
;==============================================================================

;=== Include MemoryMap, VectorTable, HeaderInfo ===
.INCLUDE "show.inc"
.INCLUDE "defines.asm"
;=== Include Library Routines & Macros ===
.INCLUDE "InitSNES.asm"
.INCLUDE "2input.asm"

;=== Espelhos para a RAM ===
.ENUM $40                  ; Isso vai usar da RAM $D0 em sequencia para inserir essas variáveis. Uma função legal desse debugger. :)
Ativaomedidor   db
DesativaFastROM db

.ENDE

;==============================================================================
; É aqui que o código de verdade começa... mas a parte legal eu deixei para depois do primeiro NMI.
; O que tem aqui é só um loop que dura até chegar na scanline 225, daí repete o que está em "VBlank" e volta pro loop.
;==============================================================================

.BANK 0 SLOT 0
.ORG HEADER_OFF
.SECTION "ShowCode" SEMIFREE

Main:
JML Faster
.BASE $C0        ; Pular para banco rápido
.INCLUDE "SR/Sombras.asm"
.INCLUDE "Sprite/Earth1.asm"
.INCLUDE "Sprite/Earth2.asm"
Faster:
	InitializeSNES
JSR IniciarSprites
	
lda #$01
sta $420d ;FastROM

lda #$ff
sta $E2   ;começa pixelado	
stz $E3   ;começa com tela escura	

INC $36   ;Counter 1 frame a frente

; IRQ CONFIG
  LDX #$00C8
  STX $4207       ; IRQ H
  LDX #$00DB
  STX $4209       ; IRQ V
  
    JSR RodaUMAvez ;Seu código vai rodar nessa sub-rotina apenas uma vez.
    JSR JoyInit		;ativa os controles e interrupt

;==============
;BG config
	lda #$09		;Set video mode 1, 8x8 tiles
      sta $2105         

	lda #$01		;Set BG1's Tile Map VRAM offset
      sta $2107		;   and the Tile Map size to 32 tiles x 32 tiles

	lda #$01		;Set BG2's Tile Map VRAM offset
      sta $2108		;   and the Tile Map size to 32 tiles x 32 tiles

	lda #$0C		;Set BG3's Tile Map VRAM offset
      sta $2109		;   and the Tile Map size to 32 tiles x 32 tiles

	lda #$22		;Set BG1's Character VRAM offset (word address)
      sta $210B		;Set BG2's Character VRAM offset (word address)
	lda #$01		;Set BG3's Character VRAM offset (word address)
      sta $210C		;Set BG4's Character VRAM offset (word address)

	lda #%00010011		;Turn on BG1
      sta $212C
	  
	lda #$00		;Turn on BG2
      sta $212d
	  
	lda #%01100011		;Sprite VRAM = Sprites 16x16/32x32 e VRAM 6000
      sta $2101

    LDA #%00100000
    STA ColorMath1

    LDA #$01
    STA BG1Vlow
    LDA #$00
    STA BG2Vlow

loop:
LDA Ativaomedidor
BEQ +
lda #$08  ; Medidor de CPU 
sta $2100 ;
+
wai
bra loop
   
;======================
;Iniciar Sprites
;======================
IniciarSprites:
    php             ; preserve P reg

    rep #$30        ; 16bit A/X/Y

    ldx #$0180
    lda #$0181        ; Prepare Loop 1
offscreen:
    sta $0180, X
    inx
    inx
    inx
    inx
    cpx #$0500
    bne offscreen
;------------------
    lda #$5555
xmsb:
    sta $0000, X
    inx
    inx
    cpx #$0520
    bne xmsb
;------------------

    rep #$10        ; 16bit A/X/Y
    sep #$20        ; 16bit A/X/Y

lda #$01
sta SP1DMAframe

LDA #$c0
STA $03C0

LDX #$7CC8
STX $34         ;POSIÇÃO DO PERSONAGEM NA TELA EARTH2

LDX #$7048
STX $30         ;POSIÇÃO DO PERSONAGEM NA TELA EARTH1

;=============================
; HDMA para a HUD ficar mais colorida

LDX #$0001
SEP #$30
  LDA #$00
  STA $4360
  LDA #$21
  STA $4361   ;Registro
  LDA #$C0
  STA $4364  ;Source banco
REP #$30
  LDA #Corslot  ;Source
  STA $4362
  SEP #$30
  
  LDA #$02
  STA $4370
  LDA #$22
  STA $4371   ;Registro
  LDA #$C0
  STA $4374  ;Source banco
REP #$30
  LDA #Corhdma  ;Source
  STA $4372
  LDA #%11000000
  TSB $0D9F
SEP #$20

;=============================
; Checa se foi resetado
;=============================
LDA $7FFFF0
CMP #$69
BNE +
LDA #$01
STA $FF
BRA ++
+
LDA #$69
STA $7FFFF0
++
    plp
RTS

Corslot:
;primeiro byte: line counter, segundo e terceiro byte: contagem de quantos valores ir adicionando 
.db $06, $80, $81
.db $0E
.db $05, $80, $98
.db $0E, $0E, $0E, $0E, $0E, $0E, $06, $0E, $06
.db $0E, $06, $0E, $06, $0E, $0E, $0E, $0E, $0E
.db $0A, $0A, $0A, $0A, $0A, $0A

.db $06, $80, $88
.db $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A

.db $04, $80, $81
.db $0A
.db $00


Corhdma:   ;16 bits
;primeiro e segundo byte: line counter, terceiro e quarto byte: contagem de quantos valores ir adicionando 80 à 8F 
.db $06, $00, $00, $81 ;Setup ;Setup
.db $DF, $02
.db $05, $00, $00, $98 ;Setup ;Setup
.db $BF, $02, $BF, $02, $5F, $02, $5F, $02, $BF, $01, $BF, $01, $FF, $03, $FF, $00, $7F, $03
.db $1D, $00, $1F, $03, $1A, $00, $BF, $02, $18, $00, $18, $00, $17, $00, $17, $00, $14, $00
.db $1D, $00, $1D, $00, $1A, $00, $15, $00, $0D, $00, $1D, $00

.db $06, $00, $00, $88 ;Setup ;Setup
.db $1D, $00, $1C, $00, $1A, $00, $18, $00, $15, $00, $13, $00, $0D, $00, $09, $00

.db $04, $00, $00, $81 ;Setup ;Setup
.db $18, $00

.db $00

;==========================================================================================
; Quando o IRQ for ativado, tudo será interrompido para rodar isso:
;==========================================================================================

IRQ:
JML FasterIRQ
.BASE $C0        ; Pular para banco rápido
FasterIRQ:

  SEI
  REP #$38
  PHA
  PHX
  PHY
  PHD
  PHB
  LDA #$0000
  TCD
  SEP #$30
  PHA
  PLB
  LDA $4211       ;TIMEUP
  
REP #$30
SEP #$20

LDA #$8F
STA $2100
;=================;
; DMA sprite data ;
;=================;
    PEA $4300
    PLD
    ldx #$6000
    stx $2102
    ldy #$0400          ; Writes #$00 to $4300, #$04 to $4301
    sty $00           ; CPU -> PPU, auto inc, $2104 (OAM write)
    ldx #$0300
    stx $02
    lda #$7E
    sta $04           ; CPU address 7E:0000 - Work RAM
    ldy #$0120
    sty $05           ; #$220 bytes to transfer
    lda #%0000001
    sta $420B
;2ª tabela
  LDX #$0400
  STX $00
  LDX #$0500
  STX $02
  LDA #$7E
  STA $04
  LDX #$0020
  STX $05
  LDX #$0100
  STX $2102
  LDA #$01
  STA $420B
  
    PEA $0000
    PLD
	
JSR SetupVideo ;DMA primeiro

JSR GetInput   ;rotina dos controles

JSR RotinadeSprites

JSR Action     ;Seu código vai rodar nessa sub-rotina em todos os frames.

  REP #$30
  PLB
  PLD
  PLY
  PLX
  PLA
  CLI
  RTI
;=======================================================

VBlank:
;NMI sem uso, estou usando apenas IRQ
      rti      ; Retorna do interrupt

SetupVideo:
	rep #$10		;A/mem = 8bit, X/Y=16bit
	sep #$20
;====================;
; Dynamic DMA sprite ;
;====================;
LDA #$8F
STA $2100 

JSR MinaDMArotina
JSR MinaDMArotina2

;====================================;
; Sem DMA? Aguardar até a linha 224  ;
;====================================;
-
  LDA $2137
  LDA $213F
  LDA $213D  ;Vertical
  CMP #$E0
  BMI -
-
  LDA $2137
  LDA $213F
  LDA $213C  ;Horizontal
  CMP #$40
  BCC -

;================;
; Config de tela ;
;================;

INC Counter ; Counter Global	

LDA #$00 ; limpar high byte 
XBA 
;HDMA registro
    LDA $0D9F
    STA $420C   
;Mosaic
    LDA Mosaico          ;E2
    STA $2106
;Espelho da Layer 1 H
	LDA BG1Hlow        ;1A
	STA $210D
	LDA BG1Hhigh       ;1B
	STA $210D
;Espelho da Layer 1 V	
	LDA BG1Vlow       ;$1C
	STA $210E
	LDA BG1Vhigh      ;$1D
	STA $210E
;Espelho da Layer 2 H
	LDA BG2Hlow        ;$10
	STA $210F
	LDA BG2Hhigh       ;$11
	STA $210F
;Espelho da Layer 2 V	
	LDA BG2Vlow        ;$17
	STA $2110
	LDA BG2Vhigh       ;$18
	STA $2110
;Espelho da Layer 3 H
	 LDA BG3Hlow      ;$1E
	 STA $2111
	 LDA BG3Hhigh     ;$1F
	 STA $2111 
;Espelho da Layer 3 V
	 LDA BG3Vlow      ;$28
	 STA $2112
	 LDA BG3Vhigh     ;$29
	 STA $2112
;Espelho de Color Math
	 LDA ColorMath0    ;$15
	 STA $2130
	 LDA ColorMath1    ;$16
	 STA $2131

; Layer 2 rola a 1/4 da velocidade da Layer 1
REP #$20       
LDA BG1Hlow
LSR A
LSR A
STA BG2Hlow
SEP #$20


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sombras HDMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   LDA #%00010111    ;\  BG1, BG3, OBJ on main screen (TM)
   STA $212C   ; | 
   LDA #$01    ; | BG1, BG3, OBJ on main screen should use windowing. (TMW)
   STA $212E   ;/  
   LDA #%00010111    ;\  BG2 on sub screen (TS)
   STA $212D   ; | 
   LDA #$01    ; | BG2 on sub screen should use windowing. (TSW)
   STA $212F   ;/  
   LDA #%01100011    ; Backdrop for color math
   STA ColorMath1     ; mirror of $2131
   LDA #$10    ;\  Clip to black: Never, Prevent colot math: Outside
   STA ColorMath0     ;/  Add subscreen instead of fixed color: True
   LDA #$00    ;\  values for enabling/inverting BG1/BG2 on window 1/2
   STA $2123
   STA $2124
   LDA #$A0    ; | values for enabling/inverting OBJ/Color on window 1/2
   STA $2125
   LDA #$00
   STA $2132
   REP #$20                         ;\  Get into 16 bit mode
   LDA #$2604                       ; | Register $2126 using mode 4
   STA $4330                        ; | 4330 = transfer mode, 4331 = register
   LDA #$0A00                ; | High byte and low byte of table addresse.
   STA $4332                        ; | 4332 = low byte, 4333 = high byte
   SEP #$20                         ; | Back to 8 bit mode
   LDA #$7e          ; | Bank byte of table addresse.
   STA $4334                        ;/  = bank byte
   LDA #$08                         ;\  
   TSB $0D9F                        ;/  enable HDMA channel 3

	 
;---------------------
;Manter F-Blank mesmo sem DMA
;---------------------
LDA #$00
STA $2100         ; Corrigir bug do INIDISP
-
  LDA $2137
  LDA $213F
  LDA $213D  ;Vertical
  CMP #$06
  BMI -
-
  LDA $2137
  LDA $213F
  LDA $213C  ;Horizontal
  CMP #$E0
  BCC -
;Gastando alguns ciclos para sincronia
NOP
NOP
NOP
;Screen Brightness
    LDA Brilho           ;E3
    STA $2100 

   	RTS                       ;/  
	
;;;;;;;;;;;;;;;;;;
;Sprites sem uso vão para fora da tela 
;;;;;;;;;;;;;;;;;;

RotinadeSprites:
php

PHD 
PEA $0300
PLD
  LDA #$E0
  STA $01
  STA $05
  STA $09
  STA $0D
  STA $11
  STA $15
  STA $19
  STA $1D
  STA $21
  STA $25
  STA $29
  STA $2D
  STA $31
  STA $35
  STA $39
  STA $3D
  STA $41
  STA $45
  STA $49
  STA $4D
  STA $51
  STA $55
  STA $59
  STA $5D
  STA $61
  STA $65
  STA $69
  STA $6D
  STA $71
  STA $75
  STA $79
  STA $7D
  STA $81
  STA $85
  STA $89
  STA $8D
  STA $91
  STA $95
  STA $99
  STA $9D
  STA $A1
  STA $A5
  STA $A9
  STA $AD
  STA $B1
  STA $B5
  STA $B9
  STA $BD
  STA $C1
  STA $C5
  STA $C9
  STA $CD
  STA $D1
  STA $D5
  STA $D9
  STA $DD
  STA $E1
  STA $E5
  STA $E9
  STA $ED
  STA $F1
  STA $F5
  STA $F9
  STA $FD
PEA $0400
PLD
  LDA #$E0
  STA $01
  STA $05
  STA $09
  STA $0D
  STA $11
  STA $15
  STA $19
  STA $1D
  STA $21
  STA $25
  STA $29
  STA $2D
  STA $31
  STA $35
  STA $39
  STA $3D
  STA $41
  STA $45
  STA $49
  STA $4D
  STA $51
  STA $55
  STA $59
  STA $5D
  STA $61
  STA $65
  STA $69
  STA $6D
  STA $71
  STA $75
  STA $79
  STA $7D
  STA $81
  STA $85
  STA $89
  STA $8D
  STA $91
  STA $95
  STA $99
  STA $9D
  STA $A1
  STA $A5
  STA $A9
  STA $AD
  STA $B1
  STA $B5
  STA $B9
  STA $BD
  STA $C1
  STA $C5
  STA $C9
  STA $CD
  STA $D1
  STA $D5
  STA $D9
  STA $DD
  STA $E1
  STA $E5
  STA $E9
  STA $ED
  STA $F1
  STA $F5
  STA $F9
  STA $FD
PEA $0500
PLD
LDX #$5555
STX $00
STX $02
STX $04
STX $06
STX $08
STX $0A
STX $0C
STX $0E
STX $10
STX $12
STX $14
STX $16
STX $18
STX $1A
STX $1C
STX $1E
PLD 

;==============================
;Lógica dos sprites
;==============================

JSR Earth1
JSR Earth2

plp
rts

;============================================================================
; Funções extras
;----------------------------------------------------------------------------
Action:
PHP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;transição mosaico com brilho
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lda Counter
and #$03  ;dividir frames
beq +
ldx $E3
lda $E2
cmp #$0f
beq +
sec
sbc #$10
sta $E2
inx
stx $E3
+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Medidor de CPU
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lda $21
bit #%00100000
beq +
LDA #$01
STA Ativaomedidor
+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Créditos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LDA $FD
BNE ++
lda $21
bit #$10
beq +
LDA #$01
STA $FE
+
LDA $FE
BEQ ++
-
  LDA $2137
  LDA $213F
  LDA $213D  ;Vertical
  CMP #$DB
  BNE -
-
  LDA $2137
  LDA $213F
  LDA $213C  ;Horizontal
  CMP #$E0
  BCC -
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
lda #$80
sta $2100
	LDA #$80            ; \ Increase on $2119 write.
	STA $2115           ; /
	LDX #$0C20			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $4300           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $4301           ;/ Writing to $2118 AND $2119.
	LDX #L3easter+64       ;\  Adress where our data is.
	STX $4302          				 ; | 
	LDA #$C1   ; | Bank where our data is.
	STA $4304          				 ;/
	LDX #$0040          ;\ Size of our data.
	STX $4305           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA $420B	   ;/
INC $FD
++
	PLP
RTS                  ;/  

windowTable:                       ; 
.db $80, $FF, $00, $FF, $00   ; 
.db $3B, $FF, $00, $FF, $00   ; 
.db $01, $2F, $48, $B9, $D2   ; 
.db $01, $25, $51, $AF, $DB   ; 
.db $01, $1F, $57, $A9, $E1   ; 
.db $01, $1B, $5B, $A5, $E5   ; 
.db $01, $18, $5E, $A2, $E8   ; 
.db $01, $15, $61, $9F, $EB   ; 
.db $01, $13, $63, $9D, $ED   ; 
.db $01, $12, $64, $9C, $EE   ; 
.db $01, $11, $65, $9B, $EF   ; 
.db $01, $11, $66, $9B, $F0   ; 
.db $04, $10, $66, $9A, $F0   ; 
.db $01, $11, $65, $9B, $EF   ; 
.db $01, $12, $64, $9C, $EE   ; 
.db $01, $13, $63, $9D, $ED   ; 
.db $01, $15, $61, $9F, $EB   ; 
.db $01, $18, $5E, $A2, $E8   ; 
.db $01, $1B, $5B, $A5, $E5   ; 
.db $01, $1F, $57, $A9, $E1   ; 
.db $01, $24, $52, $AE, $DC   ; 
.db $01, $2E, $48, $B8, $D2   ; 
.db $11, $FF, $00, $FF, $00   ; 
.db $00                           ; 
	PLP
RTS                  ;/  


RodaUMAvez:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sombras setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
REP #A_8BIT
PHB                ; Preservar data bank
LDA #$0073         ;Counter (-1)
LDX #windowTable           ;Source
LDY #$0A00           ;Destino
MVN $c0, $7e       ;Banco da Source/Banco do Destino
PLB                ; Recuperar data bank
SEP #A_8BIT

JSL lanooutrobanco    ; Vamos mudar de banco e adicionar nossos arquivos grandes lá.
RTS                   ; Em HI-ROM cada banco tem 64 KB.

.ENDS

.BANK 1 SLOT 0
.ORG 0
.SECTION "BancodosGraficos" SEMIFREE
lanooutrobanco:

;===========================
; Vou botar meus DMA e HDMA aqui hihi
; -------------------------------------
;----------------------------
PHD
REP #$20
LDA #$4300 ; DP é 4200
TCD 
SEP #$20

;DMA DE CORES PARA A CGRAM
lda #$00
sta $2121	;start at XX color
stz $420B	;Clear the DMA control register
ldx #grafico7CORES
stx $02	;Store the data offset into DMA source offset
ldx #$00E0
stx $05   ;Store the size of the data block
lda #$C1
sta $04	;Store the data bank holding the tile data
lda #$00	;Set the DMA mode (byte, normal increment)
sta $00       
lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
sta $01      
lda #$01    ;Initiate the DMA transfer
sta $420B


;---
;sprite
lda #$80
sta $2121	;start at XX color
stz $420B	;Clear the DMA control register
ldx #dmaCORESsprites
stx $02	;Store the data offset into DMA source offset
ldx #$0020
stx $05   ;Store the size of the data block
lda #$C1
sta $04	;Store the data bank holding the tile data
lda #$00	;Set the DMA mode (byte, normal increment)
sta $00       
lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
sta $01      
lda #$01    ;Initiate the DMA transfer
sta $420B

;sprite2
lda #$90
sta $2121	;start at XX color
stz $420B	;Clear the DMA control register
ldx #earthGG2pal
stx $02	;Store the data offset into DMA source offset
ldx #$0080
stx $05   ;Store the size of the data block
lda #$C1
sta $04	;Store the data bank holding the tile data
lda #$00	;Set the DMA mode (byte, normal increment)
sta $00       
lda #$22    ;Set the destination register ( $2122: CG-RAM Write )
sta $01      
lda #$01    ;Initiate the DMA transfer
sta $420B


;----------------------------
;DMA DE GRÁFICOS PARA A VRAM
;BG1
	LDA #$80            ; \ Increase on $2119 write.
	STA $2115           ; /
	LDX #$0000			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #graficos7       ;\  Adress where our data is.
	STX $02          				 ; | 
	LDA #$C1   ; | Bank where our data is.
	STA $04          				 ;/
	LDX #$B000          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA $420B	   ;/

LDA $0123
LDA $7E00FF
CMP #$01
BNE +

	LDA #$80            ; \ Increase on $2119 write.
	STA $2115           ; /
	LDX #$0C20			; \ Set where to write in VRAM...
	STX $2116			; /
	LDA #$01            ;\ Set mode to...
	STA $00           ;/ ...2 regs write once.
	LDA #$18            ;\ 
	STA $01           ;/ Writing to $2118 AND $2119.
	LDX #L3easter       ;\  Adress where our data is.
	STX $02          				 ; | 
	LDA #$C1   ; | Bank where our data is.
	STA $04          				 ;/
	LDX #$0040          ;\ Size of our data.
	STX $05           ;/
	LDA #$01	   ;\ Start DMA transfer on channel 0.
	STA $420B	   ;/
+
PLD
RTL                ; Retorna da sub-rotina para o banco anterior



;Background 1
graficos7:
.incbin "GFX/SamuraiShodownSnesVideoRam.bin"

grafico7CORES:
.incbin "GFX/SamuraishowpalBG.bin"

L3easter:
.incbin "GFX/L3Maptest.bin"

earthGG2pal:
.incbin "GFX/earthGG2pal.mw3"

;Sprite1 PAL
dmaCORESsprites:
.incbin "GFX/earthGG.mw3"
.ENDS

;Muito grande esse aqui meo, precisa de um banco pra ele

.BANK 2 SLOT 0
.ORG 0
.SECTION "BancodosGraficos2" SEMIFREE

DMAMina:
.incbin "GFX/earthGG.bin"

.ENDS

.BANK 3 SLOT 0
.ORG 0
.SECTION "BancodosGraficos3" SEMIFREE

DMAMina2:
.incbin "GFX/earthGG2.bin"

.ENDS
