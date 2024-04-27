.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00
  STA $2005
  STA $2005
  RTI
.endproc

.proc reset_handler
  JMP main
.endproc


.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$FF
  BNE load_sprites

  ; GRASS UP
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$4E
	STA PPUADDR
	LDX #$0C
	STX PPUDATA

  ; GRASS UP
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$4F
    STA PPUADDR
    LDX #$0D
    STX PPUDATA

  ; GRASS UP
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$6E
    STA PPUADDR
    LDX #$1D
    STX PPUDATA

  ; GRASS UP
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$6F
    STA PPUADDR
    LDX #$1C
    STX PPUDATA

  ; GRASS DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$50
    STA PPUADDR
    LDX #$0E
    STX PPUDATA

  ; GRASS DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$51
    STA PPUADDR
    LDX #$0F
    STX PPUDATA

  ; GRASS DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$70
    STA PPUADDR
    LDX #$1E
    STX PPUDATA
  
  ; GRASS DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$71
    STA PPUADDR
    LDX #$1F
    STX PPUDATA

  ; GRASS RIGHT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$52
    STA PPUADDR
    LDX #$2E
    STX PPUDATA

  ; GRASS RIGHT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$53
    STA PPUADDR
    LDX #$2F
    STX PPUDATA

  ; GRASS RIGHT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$72
    STA PPUADDR
    LDX #$3E
    STX PPUDATA
  
  ; GRASS RIGHT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$73
    STA PPUADDR
    LDX #$3F
    STX PPUDATA

  ; GRASS LEFT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$54
    STA PPUADDR
    LDX #$2C
    STX PPUDATA

  ; GRASS LEFT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$55
    STA PPUADDR
    LDX #$2D
    STX PPUDATA

  ; GRASS LEFT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$74
    STA PPUADDR
    LDX #$3C
    STX PPUDATA
  
  ; GRASS LEFT
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$75
    STA PPUADDR
    LDX #$3D
    STX PPUDATA

  ; VINES
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$0C
    STA PPUADDR
    LDX #$02
    STX PPUDATA

  ; VINES
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$0D
    STA PPUADDR
    LDX #$03
    STX PPUDATA

  ; VINES
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$2C
    STA PPUADDR
    LDX #$12
    STX PPUDATA
  
  ; VINES
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$2D
    STA PPUADDR
    LDX #$13
    STX PPUDATA

  ; GLYPH
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$8C
    STA PPUADDR
    LDX #$0A
    STX PPUDATA

  ; GLYPH
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$8D
    STA PPUADDR
    LDX #$0B
    STX PPUDATA

  ; GLYPH
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$AC
    STA PPUADDR
    LDX #$1A
    STX PPUDATA
  
  ; GLYPH
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$AD
    STA PPUADDR
    LDX #$1B
    STX PPUDATA

  ; SPIKE UP
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$12
    STA PPUADDR
    LDX #$06
    STX PPUDATA

  ; SPIKE UP
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$13
    STA PPUADDR
    LDX #$07
    STX PPUDATA

  ; SPIKE UP
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$32
    STA PPUADDR
    LDX #$16
    STX PPUDATA
  
  ; SPIKE UP
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$33
    STA PPUADDR
    LDX #$17
    STX PPUDATA

  ; SPIKE DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$14
    STA PPUADDR
    LDX #$08
    STX PPUDATA

  ; SPIKE DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$15
    STA PPUADDR
    LDX #$09
    STX PPUDATA

  ; SPIKE DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$34
    STA PPUADDR
    LDX #$18
    STX PPUDATA
  
  ; SPIKE DOWN
  LDA PPUSTATUS
    LDA #$22
    STA PPUADDR
    LDA #$35
    STA PPUADDR
    LDX #$19
    STX PPUDATA

  ; GRASSBUSH
  LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$4E
    STA PPUADDR
    LDX #$04
    STX PPUDATA

  ; GRASSBUSH
  LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$4F
    STA PPUADDR
    LDX #$05
    STX PPUDATA

  ; GRASSBUSH
  LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$6E
    STA PPUADDR
    LDX #$14
    STX PPUDATA
  
  ; GRASSBUSH
  LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$6F
    STA PPUADDR
    LDX #$15
    STX PPUDATA

  ; ATTRIBUTE TABLE 1
    LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$E2
    STA PPUADDR
    LDA #%00000000
    STA PPUDATA

  ; ATTRIBUTE TABLE 2
    ; LDA PPUSTATUS
    ; LDA #$23
    ; STA PPUADDR
    ; LDA #$E3
    ; STA PPUADDR
    ; LDA #%00000111
    ; STA PPUDATA

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK
  
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
  ; BACKGROUND
  .byte $0f, $2A, $1A, $07
  .byte $0f, $2b, $3c, $39
  .byte $0f, $0c, $07, $13
  .byte $0f, $19, $09, $29

  ; SPRITES
  .byte $38, $2d, $10, $15
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29

sprites:
;Slug Right 1
  .byte $80, $22, $00, $70 
  .byte $88, $33, $00, $78
  .byte $88, $32, $00, $70  
  .byte $80, $23, $00, $78 

;Slug Right 2
  .byte $80, $24, $00, $80 
  .byte $88, $35, $00, $88
  .byte $88, $34, $00, $80  
  .byte $80, $25, $00, $88 

;Slug Right 3
  .byte $90, $28, $00, $60 
  .byte $98, $39, $00, $68
  .byte $98, $38, $00, $60  
  .byte $90, $29, $00, $68 

;Slug Down 1
  .byte $A0, $42, $00, $70
  .byte $A8, $53, $00, $78
  .byte $A8, $52, $00, $70  
  .byte $A0, $43, $00, $78 

  ;Slug Down 2
  .byte $A0, $44, $00, $80 
  .byte $A8, $55, $00, $88
  .byte $A8, $54, $00, $80  
  .byte $A0, $45, $00, $88 

  ;Slug Down 3
  .byte $B0, $48, $00, $60 
  .byte $B8, $59, $00, $68
  .byte $B8, $58, $00, $60  
  .byte $B0, $49, $00, $68 

  ;Slug Left 1
  .byte $B0, $62, $00, $70 
  .byte $B8, $73, $00, $78
  .byte $B8, $72, $00, $70  
  .byte $B0, $63, $00, $78 

  ;Slug Left 2
  .byte $B0, $64, $00, $80 
  .byte $B8, $75, $00, $88
  .byte $B8, $74, $00, $80  
  .byte $B0, $65, $00, $88 

  ;Slug Left 3
  .byte $C0, $68, $00, $60 
  .byte $C8, $79, $00, $68
  .byte $C8, $78, $00, $60  
  .byte $C0, $69, $00, $68 

  ;Slug Up 1
  .byte $C0, $82, $00, $70 
  .byte $C8, $93, $00, $78
  .byte $C8, $92, $00, $70  
  .byte $C0, $83, $00, $78 

  ;Slug Up 2
  .byte $C0, $84, $00, $80 
  .byte $C8, $95, $00, $88
  .byte $C8, $94, $00, $80  
  .byte $C0, $85, $00, $88 
  
  ;Slug Up 3
  .byte $D0, $88, $00, $60 
  .byte $D8, $99, $00, $68
  .byte $D8, $98, $00, $60  
  .byte $D0, $89, $00, $68 

.segment "CHR"
.incbin "graphics.chr"