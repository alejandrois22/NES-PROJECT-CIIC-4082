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
  RTI
.endproc

.import reset_handler

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
  CPX #$04
  BNE load_palettes

  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$D0      ; # Sprites x 4 bytes
  BNE load_sprites

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
.byte $0F, $2A, $1A, $07

sprites:
;Vines (transparent block)
  .byte $70, $02, $00, $60 
  .byte $78, $03, $00, $68
  .byte $78, $12, $00, $60  
  .byte $70, $13, $00, $68  

;Grass block (solid block)
  .byte $70, $04, $00, $70 
  .byte $78, $15, $00, $78
  .byte $78, $14, $00, $70  
  .byte $70, $05, $00, $78 

;Spike up (solid block2)
  .byte $70, $06, $00, $80 
  .byte $78, $17, $00, $88
  .byte $78, $16, $00, $80  
  .byte $70, $07, $00, $88 
;Spike down (solid block3)
  .byte $70, $08, $00, $90 
  .byte $78, $19, $00, $98
  .byte $78, $18, $00, $90  
  .byte $70, $09, $00, $98 

;Stone glyph (transparent block2)
  .byte $80, $0A, $00, $60 
  .byte $88, $1B, $00, $68
  .byte $88, $1A, $00, $60  
  .byte $80, $0B, $00, $68 

;Slug (SPRITE1)
  .byte $80, $22, $00, $70 
  .byte $88, $33, $00, $78
  .byte $88, $32, $00, $70  
  .byte $80, $23, $00, $78 

;Slug (SPRITE2)
  .byte $80, $24, $00, $80 
  .byte $88, $35, $00, $88
  .byte $88, $34, $00, $80  
  .byte $80, $25, $00, $88 

;Slug (SPRITE3)
  .byte $80, $26, $00, $90 
  .byte $88, $37, $00, $98
  .byte $88, $36, $00, $90  
  .byte $80, $27, $00, $98 

;Slug (SPRITE4)
  .byte $90, $28, $00, $60 
  .byte $98, $39, $00, $68
  .byte $98, $38, $00, $60  
  .byte $90, $29, $00, $68 

;Grass up (solid block4)
  .byte $90, $0C, $00, $70 
  .byte $98, $1D, $00, $78
  .byte $98, $1C, $00, $70  
  .byte $90, $0D, $00, $78 

;Grass down (solid block5)
  .byte $90, $0E, $00, $80 
  .byte $98, $1F, $00, $88
  .byte $98, $1E, $00, $80  
  .byte $90, $0F, $00, $88 

;Grass left (solid block6)
  .byte $90, $2C, $00, $90 
  .byte $98, $3D, $00, $98
  .byte $98, $3C, $00, $90  
  .byte $90, $2D, $00, $98 

;Grass right (solid block7)
  .byte $A0, $2E, $00, $60 
  .byte $A8, $3f, $00, $68
  .byte $A8, $3E, $00, $60  
  .byte $A0, $2F, $00, $68 


.segment "CHR"
.incbin "sprites.chr"