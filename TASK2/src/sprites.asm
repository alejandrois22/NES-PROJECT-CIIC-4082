.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
frameCount1: .res 1
animationCount1: .res 1
frameCount2: .res 1
animationCount2: .res 1
frameCount3: .res 1
animationCount3: .res 1
frameCount4: .res 1
animationCount4: .res 1

.exportzp frameCount1, animationCount1
.exportzp frameCount2, animationCount2
.exportzp frameCount3, animationCount3
.exportzp frameCount4, animationCount4

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc reset_handler
  JMP main
.endproc
.export reset_handler


.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00

  JSR draw_player
  JSR draw_player2
  JSR draw_player3
  JSR draw_player4

  STA $2005
  STA $2005
  RTI
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
  CPX #$D0       ; # Sprites x 4 bytes
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

; Facing Right
.proc draw_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount1
  LDA animationCount1
  AND #$04
  BNE trampoline
  LDA frameCount1
  AND #$0F      
  CMP #$05      
  BCC frame1   
  CMP #$0A      
  BCC frame2   
  JMP frame3   

trampoline:
  JMP skipAnimation

frame3:
  ; Third frame of animation
  LDA #$22
  STA $0201
  LDA #$32
  STA $0205
  LDA #$23
  STA $0209
  LDA #$33
  STA $020d
  JMP tileSet

frame2:
  ; Second frame of animation
  LDA #$24
  STA $0201
  LDA #$34
  STA $0205
  LDA #$25
  STA $0209
  LDA #$35
  STA $020d
  JMP tileSet

frame1:
  ; First frame of animation
  LDA #$28
  STA $0201
  LDA #$38
  STA $0205
  LDA #$29
  STA $0209
  LDA #$39
  STA $020d
  JMP tileSet

tileSet:
  ; Use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  INC frameCount1

  ; Restoring register and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Facing Left
.proc draw_player2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount2
  LDA animationCount2
  AND #$04      
  BNE trampoline
  LDA frameCount2
  AND #$0F      
  CMP #$05      
  BCC frame1   
  CMP #$0A      
  BCC frame2   
  JMP frame3   

trampoline:
  JMP skipAnimation

frame3:
  ; Third frame of animation
  LDA #$42 
  STA $0211
  LDA #$52
  STA $0215
  LDA #$43
  STA $0219
  LDA #$53
  STA $021d
  JMP tileSet

frame2:
  ; Second frame of animation
  LDA #$44 
  STA $0211
  LDA #$54
  STA $0215
  LDA #$45
  STA $0219
  LDA #$55
  STA $021d
  JMP tileSet

frame1:
  ; First frame of animation
  LDA #$48 
  STA $0211
  LDA #$58
  STA $0215
  LDA #$49
  STA $0219
  LDA #$59
  STA $021d
  JMP tileSet

tileSet:

  ; Use palette 0
  LDA #$00
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  INC frameCount2

  ; Restoring register and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Facing Up
.proc draw_player3
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount3
  LDA animationCount3
  AND #$04      
  BNE trampoline
  LDA frameCount3
  AND #$0F      
  CMP #$05      
  BCC frame1   
  CMP #$0A      
  BCC frame2   
  JMP frame3   

trampoline:
  JMP skipAnimation

frame3:
  ; Third frame of animation
  LDA #$62 
  STA $0221
  LDA #$72
  STA $0225
  LDA #$63
  STA $0229
  LDA #$73
  STA $022d
  JMP tileSet

frame2:
  ; Second frame of animation
  LDA #$64 
  STA $0221
  LDA #$74
  STA $0225
  LDA #$65
  STA $0229
  LDA #$75
  STA $022d
  JMP tileSet

frame1:
  ; First frame of animation
  LDA #$68 
  STA $0221
  LDA #$78
  STA $0225
  LDA #$69
  STA $0229
  LDA #$79
  STA $022d
  JMP tileSet

tileSet:

  ; Use palette 0
  LDA #$00
  STA $0222
  STA $0226
  STA $022a
  STA $022e

  INC frameCount3

  ; Restoring register and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

; Facing Down
.proc draw_player4
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount4
  LDA animationCount4
  AND #$04      
  BNE trampoline
  LDA frameCount4
  AND #$0F      
  CMP #$05      
  BCC frame1   
  CMP #$0A      
  BCC frame2   
  JMP frame3   

trampoline:
  JMP skipAnimation

frame3:
  ; Third frame of animation
  LDA #$82 
  STA $0231
  LDA #$92
  STA $0235
  LDA #$83
  STA $0239
  LDA #$93
  STA $023d
  JMP tileSet

frame2:
  ; Second frame of animation
  LDA #$84 
  STA $0231
  LDA #$94
  STA $0235
  LDA #$85
  STA $0239
  LDA #$95
  STA $023d
  JMP tileSet

frame1:
  ; First frame of animation
  LDA #$88 
  STA $0231
  LDA #$98
  STA $0235
  LDA #$89
  STA $0239
  LDA #$99
  STA $023d
  JMP tileSet

tileSet:

  ; Use palette 0
  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e

  INC frameCount4

  ; Restoring register and return
skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"

palettes:
.byte $0f, $2A, $1A, $07
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $2d, $10, $15
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

sprites:
  .byte $80, $10, $00, $70 
  .byte $88, $20, $00, $70  
  .byte $80, $11, $00, $78  
  .byte $88, $21, $00, $78 

  .byte $80, $13, $00, $80
  .byte $88, $23, $00, $80  
  .byte $80, $14, $00, $88
  .byte $88, $24, $00, $88  

  .byte $80, $16, $00, $90  
  .byte $88, $26, $00, $90  
  .byte $80, $17, $00, $98   
  .byte $88, $27, $00, $98  

  .byte $80, $40, $00, $a0  
  .byte $88, $50, $00, $a0   
  .byte $80, $41, $00, $a8   
  .byte $88, $51, $00, $a8  

.segment "CHR"
.incbin "sprites.chr"