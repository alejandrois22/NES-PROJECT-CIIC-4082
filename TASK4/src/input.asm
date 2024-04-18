.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
pad1: .res 1
frameCount: .res 1
animationCount: .res 1
.exportzp player_x, player_y, pad1, frameCount, animationCount

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00
  	; read controller
	JSR read_controller1

  ; update tiles *after* DMA transfer
	; and after reading controller state
	JSR update_player
  
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

.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount
  LDA animationCount
  AND #$03           
  BNE trampoline
  LDA frameCount
  AND #$0F           
  CMP #$05           
  BCC frameRight1    
  CMP #$0A          
 
  BCC frameRight2   
  JMP frameRight3  
trampoline:
  JMP skipAnimation

frameRight3:

  LDA #$22
  STA $0201
  LDA #$23
  STA $0205
  LDA #$32
  STA $0209
  LDA #$33
  STA $020d
  JMP tileSet

frameRight2:

  LDA #$24
  STA $0201
  LDA #$25
  STA $0205
  LDA #$34
  STA $0209
  LDA #$35
  STA $020d
  JMP tileSet

frameRight1:

  LDA #$28
  STA $0201
  LDA #$29
  STA $0205
  LDA #$38
  STA $0209
  LDA #$39
  STA $020d
  JMP tileSet

tileSet:

  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  INC frameCount

skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc draw_player2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount
  LDA animationCount
  AND #$03
  BNE trampoline
  LDA frameCount
  AND #$0F         
  CMP #$05         
  BCC frameLeft1  
  CMP #$0A        
  BCC frameLeft2 
  JMP frameLeft3 

trampoline:
  JMP skipAnimation

frameLeft3:

  LDA #$62 
  STA $0201
  LDA #$63
  STA $0205
  LDA #$72
  STA $0209
  LDA #$73
  STA $020d
  JMP tileSet

frameLeft2:

  LDA #$64 
  STA $0201
  LDA #$65
  STA $0205
  LDA #$74
  STA $0209
  LDA #$75
  STA $020d
  JMP tileSet

frameLeft1:

  LDA #$68 
  STA $0201
  LDA #$69
  STA $0205
  LDA #$78
  STA $0209
  LDA #$79
  STA $020d
  JMP tileSet


tileSet:

  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  INC frameCount

skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player3
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount
  LDA animationCount
  AND #$03           
  BNE trampoline
  LDA frameCount
  AND #$0F           
  CMP #$05           
  BCC frameUp1       
  CMP #$0A          
  BCC frameUp2      
  JMP frameUp3      

trampoline:
  JMP skipAnimation

frameUp3:

  LDA #$42 
  STA $0201
  LDA #$43
  STA $0205
  LDA #$52
  STA $0209
  LDA #$53
  STA $020d
  JMP tileSet

frameUp2:

  LDA #$44 
  STA $0201
  LDA #$45
  STA $0205
  LDA #$54
  STA $0209
  LDA #$55
  STA $020d
  JMP tileSet

frameUp1:

  LDA #$48 
  STA $0201
  LDA #$49
  STA $0205
  LDA #$58
  STA $0209
  LDA #$59
  STA $020d
  JMP tileSet


tileSet:

  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  INC frameCount

skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player4
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Initialize player position
  INC animationCount
  LDA animationCount
  AND #$03          
  BNE trampoline
  LDA frameCount
  AND #$0F          
  CMP #$05          
  BCC frameDown1    
  CMP #$0A         
  BCC frameDown2   
  JMP frameDown3   

trampoline:
  JMP skipAnimation

frameDown3:

  LDA #$82 
  STA $0201
  LDA #$83
  STA $0205
  LDA #$92
  STA $0209
  LDA #$93
  STA $020d
  JMP tileSet

frameDown2:

  LDA #$84 
  STA $0201
  LDA #$85
  STA $0205
  LDA #$94
  STA $0209
  LDA #$95
  STA $020d
  JMP tileSet

frameDown1:
  LDA #$88 
  STA $0201
  LDA #$89
  STA $0205
  LDA #$98
  STA $0209
  LDA #$99
  STA $020d
  JMP tileSet

tileSet:

  LDA #$00
  STA $0232
  STA $0236
  STA $023a
  STA $023e

  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  INC frameCount

skipAnimation:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc update_player
  PHP  ; Start by saving registers,
  PHA  ; as usual.
  TXA
  PHA
  TYA
  PHA

  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  JSR draw_player2
  DEC player_x  ; If the branch is not taken, move player left
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  JSR draw_player
  INC player_x
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  JSR draw_player4
  DEC player_y
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  JSR draw_player3
  INC player_y
done_checking:
  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
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
.byte $0f, $12, $1A, $27
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $2d, $10, $15
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

sprites:

  .byte $A0, $10, $00, $80 
  .byte $A8, $20, $00, $80  
  .byte $A0, $11, $00, $88  
  .byte $A8, $21, $00, $88  

.segment "CHR"
.incbin "sprites.chr"