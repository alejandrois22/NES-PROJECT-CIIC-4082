.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
temp: 						.res 1
levelChange:				.res 1
scrollOffset:				.res 1
stageTileOffset:		.res 1
stageOffsetLow:		.res 1
stageOffsetUp:		.res 1
player_x: .res 1
player_y: .res 1
player_dir: .res 1
pad1: .res 1
frameCount: .res 1
animationCount: .res 1
.exportzp player_x, player_y, pad1, frameCount, animationCount

.segment "STARTUP"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler       
  LDA #$00           
  STA $2003           
  LDA #$02          
  STA $4014                   
  LDA #$00            
  STA $2005           
  STA $2005           
	JSR update
  JSR update_player
	JSR read_controller1
	LDA scrollOffset
	STA $2005
	LDA #$00
	STA $2005
	LDX #$00
	LDA levelChange
	CMP #$01
	BNE continue
	JSR drawBackground
	continue:
  RTI           
.endproc

.proc reset_handler
  SEI                
  CLD              
  LDX #$40    
  STX $4017
  LDX #$FF
  TXS
  INX               
  STX $2000         
  STX $2001         
  STX $4010         
	vblankwait:            
		BIT $2002
		BPL vblankwait
	vblankwait2:
    BIT $2002
    BPL vblankwait2

	LDX #$00
	STX temp
	STX scrollOffset
	STX levelChange
	STX stageOffsetLow
	STX stageTileOffset
	LDX #$20
	STX stageOffsetUp

    JMP main
.endproc

.proc update
	PHP	
	PHA
	TXA
	PHA
	PHA
  ; Read controller 1
  LDA $4016   
  STA temp    
  LDA #$01
  STA $4016 
  LDA #$00
  STA $4016  
  LDY #$08
  LDA #$00 

read_buttons:
  LDA $4016      
  LSR             
  ROL temp        
  DEY
  BNE read_buttons

LDA temp
AND #%00000001  
BEQ arrow_left 
LDA scrollOffset
CMP #$FF
BEQ continue
CLC
ADC #$01
STA scrollOffset
JMP continue

arrow_left:
  LDA temp
  AND #%00000010  
  BEQ button_start   
  LDA scrollOffset
  CMP #$00
  BEQ continue
  DEC scrollOffset
  JMP continue

button_start:
  LDA temp
  AND #%00010000
  BEQ continue
  LDA levelChange
  EOR #%01
  STA levelChange
  
	continue:
	PLA				
	TAY					
	PLA					
	TAX				
	PLA					
	PLP					
	RTS						
.endproc

.proc drawBackground
  ;Save register states to the stack
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
	STX stageTileOffset
  ; Stage 1 Up
	LDA levelChange
	CMP #$01
	BNE bg
  ; wait for another vblank before continuing
	vblankwait_off:        
    BIT $2002       
    BPL vblankwait_off
		LDA #%00000000 
		STA $2000      
		LDA #%00000000  
		STA $2001       
		LDA #$20
		STA stageOffsetUp
		LDA #$00
		STA stageOffsetLow
	bg:
	LDX #$00
	STX stageTileOffset
	background1:
		LDA stageOffsetUp
		STA $2006
		LDA stageOffsetLow
		STA $2006							

		LDX stageTileOffset
		load_background1Upper:           
			; UP LEFT
			LDA levelChange
			CMP #$01
			BNE screen1_up
			LDA stage2LeftScreen, X 
			JMP screen1_con
			screen1_up:
			LDA stage1LeftScreen, X 
			screen1_con:
			STA $2007           		
			; UP RIGHT
			CLC
			ADC #$01
			STA $2007					
			INX
			CPX #$10            			
			BNE load_background1Upper
    ; Stage1 low
		LDA stageOffsetLow
		CLC
		ADC #$20
		STA stageOffsetLow
		LDA stageOffsetUp
		STA $2006
		LDA stageOffsetLow
		STA $2006

		LDX stageTileOffset
		load_background1_lower:           	
    ; LOW LEFT
    LDA levelChange
    CMP #$01
    BNE screen1_low
    LDA stage2LeftScreen, X 
    JMP screen1_con_low
    screen1_low:
    LDA stage1LeftScreen, X 
    screen1_con_low:
    CLC
    ADC #$00
    STA $2007
    ; LOW RIGHT
    CLC
    ADC #$01						
    STA $2007
    INX
    CPX #$10
    BNE load_background1_lower
		LDA stageTileOffset
		CLC
		ADC #$10
		STA stageTileOffset
		LDA stageOffsetLow
		CMP #$E0
		BEQ increase_up
		JMP continue
		increase_up:
    LDA stageOffsetUp
    CLC
    ADC #$01
    STA stageOffsetUp
    LDA #$00
    STA stageOffsetLow
    JMP background1
		continue:
		LDA stageOffsetLow
		CLC
		ADC #$20
		STA stageOffsetLow
		LDA stageOffsetUp
		CMP #$24
		BEQ exit1
		JMP background1

	exit1:

  ;Stage 2
	LDX #$00
	STX stageTileOffset
	STX stageOffsetLow
	LDX #$24
	STX stageOffsetUp

	background2:
		LDA stageOffsetUp
		STA $2006
		LDA stageOffsetLow
		STA $2006

		LDX stageTileOffset
		load_background2Upper:
    ; UP LEFT
    LDA levelChange
    CMP #$01
    BNE screen2_up
    LDA stage2LeftScreen, X 
    JMP screen2_con
    screen2_up:
    LDA stage1RightScreen, X 
    screen2_con:
    STA $2007
    ; UP RIGHT
    CLC
    ADC #$01
    STA $2007	
    INX
    CPX #$10  
    BNE load_background2Upper
    ; Low
		LDA stageOffsetLow
		CLC
		ADC #$20
		STA stageOffsetLow
		LDA stageOffsetUp
		STA $2006
		LDA stageOffsetLow
		STA $2006
		LDX stageTileOffset
		load_background2_lower:
    ; LOW LEFT
    LDA levelChange
    CMP #$01
    BNE screen2_low
    LDA stage2RightScreen, X 
    JMP screen2_con_low
    screen2_low:
    LDA stage1RightScreen, X 
    screen2_con_low:
    CLC
    ADC #$10			
    STA $2007 
    ; LOW RIGHT
    CLC
    ADC #$01						
    STA $2007	
    INX
    CPX #$10            	
    BNE load_background2_lower
		LDA stageTileOffset
		CLC
		ADC #$10
		STA stageTileOffset
		LDA stageOffsetLow
		CMP #$E0
		BEQ increase_up2
		JMP continue2
		increase_up2:
    LDA stageOffsetUp
    CLC
    ADC #$01
    STA stageOffsetUp
    LDA #$00
    STA stageOffsetLow
    JMP background2
		continue2:
		LDA stageOffsetLow
		CLC
		ADC #$20
		STA stageOffsetLow
		LDA stageOffsetUp
		CMP #$27
		BEQ check_exit
		JMP background2
		check_exit:
    LDA stageOffsetLow
    CMP #$C0
    BEQ exit2
    JMP background2
	exit2:

	LDA $2002
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006

	LDX #$00
	load_attribute: 
		LDA levelChange
		CMP #$01
		BNE attribute1
		LDA attributeScreen3, X 
		JMP attribute1_con
		attribute1:
		LDA attributeScreen1, X       			
		attribute1_con:
		STA $2007         				
    INX           
    CPX #$40
    BNE load_attribute

	LDA $2002
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006

	LDX #$00
	load_attribute2:     
		LDA levelChange
		CMP #$01
		BNE attribute2
		LDA attributeScreen4, X 
		JMP attribute2_con
		attribute2:
		LDA attributeScreen2, X       			
		attribute2_con:
    STA $2007       
    INX               
    CPX #$40         
    BNE load_attribute2

    vblankwait:       
    BIT $2002    
    BPL vblankwait
		LDA #%10010000  ; turn on NMIs, sprites use first pattern table
		STA $2000       ; Store A in PPU Control
		LDA #%00011110  ; turn on screen
		STA $2001       ; Store A in PPU Mask
	LDA #$00
	STA levelChange

PLA
TAY
PLA
TAX
PLA
PLP
RTS
.endproc

.export main
.proc main ; -------------------------------------------------------------------------+
    LDX $2002           ; Load PPU Status into X

    LDX #$3f            ; Load 3f into X
    STX $2006           ; Store 3f in PPU Address
    LDX #$00            ; Load 00 into X
    STX $2006           ; Store 00 in PPU Address, such that we have 3f00 (the first color of the first palette) in PPU Address

    ; WRITE PALETTES -----------------------------------------------------------------+
    load_palettes:
        LDA palettes, X     ; Load palettes into X
        STA $2007           ; Store X into PPU data
        INX                 ; Increase X
        CPX #$18            
        BNE load_palettes   ; 

	JSR drawBackground
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
  ; BACKGROUND
  .byte $0f, $2A, $1A, $07
  .byte $0f, $2A, $1A, $07
  .byte $0f, $2A, $1A, $07
  .byte $0f, $2A, $1A, $07
  ; SPRITES
  .byte $38, $2d, $10, $15
  .byte $38, $2d, $10, $15  
  .byte $38, $2d, $10, $15  
  .byte $38, $2d, $10, $15

sprites:
  .byte $A0, $10, $2C, $80 
  .byte $A8, $20, $2C, $80  
  .byte $A0, $11, $2C, $88  
  .byte $A8, $21, $2C, $88  

stage1LeftScreen:
.byte $2E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $2C, $2E, $08, $08, $1D, $00, $02, $02, $02, $02, $02, $02, $00, $08, $2D, $00, $0A, $2E, $02, $00, $00, $00, $0C, $0C, $0C, $00, $0C, $00, $0C, $0C, $1D, $02, $3C, $2E, $12, $2C, $0C, $0C, $08, $00, $3C, $00, $2C, $00, $02, $2C, $00, $00, $3C, $2E, $02, $2C, $00, $00, $02, $00, $3C, $00, $2C, $3E, $02, $2C, $00, $2C, $3C, $2E, $02, $2C, $04, $04, $0C, $00, $3C, $0C, $2C, $00, $02, $2C, $00, $02, $3C, $2E, $02, $2C, $0C, $0C, $3C, $00, $00, $00, $02, $00, $2C, $2C, $0E, $02, $3C, $2E, $02, $2C, $08, $08, $3C, $0C, $0C, $0C, $02, $00, $00, $00, $2E, $02, $3C, $2E, $02, $00, $00, $00, $00, $00, $00, $3C, $02, $0C, $0C, $00, $2E, $02, $3C, $2E, $00, $0C, $0C, $0C, $02, $0C, $00, $3C, $02, $2C, $3D, $00, $2E, $02, $3C, $2E, $00, $2C, $02, $00, $00, $3C, $02, $3C, $12, $2C, $00, $00, $02, $00, $3C, $2E, $12, $2C, $02, $3C, $0D, $1D, $12, $3C, $00, $2C, $00, $0C, $0C, $00, $3C, $2E, $12, $2C, $02, $08, $08, $3C, $12, $3C, $0C, $0C, $02, $2C, $08, $00, $3C, $2E, $12, $2C, $00, $00, $00, $3C, $3C, $3C, $02, $06, $02, $2C, $06, $06, $3C, $1D, $0D, $2D, $0C, $04, $04, $3E, $3E, $1D, $0C, $0C, $0C, $2D, $0C, $0C, $1D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
attributeScreen1:
  .byte $BE,$3E,$3E,$3E,$3E,$3E,$3E,$3C
  .byte $B8,$3D,$02,$0A,$0A,$08,$2D,$0A
  .byte $BA,$00,$0C,$3C,$0C,$0C,$3D,$3C
  .byte $BA,$BC,$38,$3C,$2C,$02,$B0,$3C
  .byte $BA,$B0,$02,$3C,$2C,$FA,$B0,$BC
  .byte $BA,$B4,$1C,$3C,$3C,$02,$B0,$3C
  .byte $BA,$BC,$3C,$00,$02,$2C,$BE,$3C
  .byte $BA,$B8,$3C,$3C,$32,$00,$2E,$3C
  .byte $BA,$00,$00,$00,$F2,$3C,$2E,$3C
  .byte $B8,$3C,$32,$30,$F2,$BD,$2E,$3C
  .byte $B8,$B2,$00,$F2,$F2,$B0,$02,$3C
  .byte $BA,$B2,$FD,$76,$F0,$B0,$3C,$3C
  .byte $BA,$B2,$28,$F2,$FC,$32,$B8,$3C
  .byte $BA,$B0,$00,$FC,$F2,$1A,$B6,$3C
  .byte $7D,$BC,$14,$FE,$7C,$3C,$BC,$3D
stage1RightScreen:
.byte $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $00, $00, $02, $00, $00, $00, $00, $00, $02, $02, $02, $02, $02, $00, $00, $2C, $1D, $02, $0C, $0C, $0C, $0C, $02, $0C, $02, $0C, $0C, $0C, $02, $0C, $02, $3E, $1D, $00, $3C, $08, $00, $02, $00, $2C, $00, $00, $00, $2C, $00, $2C, $00, $2C, $1D, $00, $3C, $1D, $0C, $0C, $00, $2C, $0C, $0C, $00, $2C, $02, $2C, $00, $2C, $1D, $02, $2C, $00, $00, $02, $00, $2C, $02, $00, $00, $2C, $02, $2C, $00, $2C, $1D, $12, $2C, $06, $06, $0D, $02, $2C, $02, $0C, $0C, $3E, $02, $2C, $06, $2C, $1D, $12, $3C, $0C, $2E, $00, $02, $2C, $02, $04, $2C, $00, $00, $2C, $0C, $3E, $1D, $12, $02, $00, $00, $00, $02, $02, $0D, $3E, $3E, $00, $0C, $02, $00, $0A, $1D, $12, $0C, $00, $0C, $02, $0C, $00, $00, $04, $2C, $00, $2C, $00, $0C, $3E, $1D, $00, $2C, $04, $2C, $00, $3E, $0C, $0C, $3E, $00, $00, $2C, $02, $00, $2C, $1D, $00, $2C, $3E, $2E, $00, $00, $04, $3E, $04, $00, $0C, $00, $0C, $00, $2C, $1D, $00, $00, $02, $2C, $3E, $0C, $0C, $3E, $0C, $00, $2C, $02, $2C, $02, $2C, $1D, $06, $06, $00, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00, $02, $2C, $3E, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $1D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
attributeScreen2:
  .byte $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D
  .byte $00,$08,$00,$00,$0A,$0A,$08,$2C
  .byte $76,$3C,$3C,$0C,$0C,$3C,$0C,$3E
  .byte $74,$F8,$02,$2C,$00,$2C,$2C,$2C
  .byte $74,$FD,$3C,$2C,$3C,$2C,$2C,$2C
  .byte $76,$B0,$02,$2C,$08,$2C,$2C,$2C
  .byte $76,$B6,$1D,$2C,$0C,$3E,$2C,$3C
  .byte $76,$FC,$B8,$2C,$0C,$B0,$2C,$3E
  .byte $76,$08,$00,$0A,$3E,$F8,$32,$0A
  .byte $76,$30,$32,$30,$04,$B0,$B0,$3E
  .byte $74,$B4,$B0,$FC,$3E,$00,$B2,$2C
  .byte $74,$BE,$B8,$04,$FC,$0C,$0C,$2C
  .byte $74,$02,$BE,$3C,$FC,$2C,$2C,$2C
  .byte $76,$18,$0A,$0A,$0A,$08,$00,$2C
  .byte $FD,$3D,$3D,$3D,$3D,$3D,$3D,$3D
stage2LeftScreen:
.byte $2E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $2E, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $2C, $2E, $00, $0C, $0D, $02, $0D, $0D, $0D, $02, $0D, $0D, $0D, $0D, $0D, $02, $3C, $2E, $00, $2C, $00, $02, $2E, $00, $00, $02, $2C, $00, $00, $08, $3C, $02, $0A, $2E, $00, $2C, $06, $2E, $08, $00, $2E, $02, $02, $02, $02, $04, $02, $02, $3C, $2E, $00, $2C, $0E, $0E, $0E, $00, $0E, $0E, $0E, $0E, $06, $0E, $12, $3D, $3C, $2E, $00, $02, $02, $02, $03, $00, $0E, $02, $0E, $00, $2D, $02, $03, $00, $3C, $2E, $00, $0E, $0E, $0E, $0E, $0E, $0E, $00, $0E, $00, $0E, $0E, $0E, $00, $3C, $00, $02, $03, $03, $03, $2D, $08, $2D, $00, $2D, $00, $00, $00, $00, $00, $3C, $2E, $00, $2E, $2E, $00, $2E, $00, $00, $00, $2E, $04, $0E, $0E, $0E, $00, $3C, $2E, $00, $2E, $08, $04, $00, $00, $2E, $02, $00, $00, $00, $02, $03, $02, $3C, $2E, $00, $2E, $02, $00, $00, $00, $2E, $12, $0E, $0E, $0E, $0E, $0E, $00, $3C, $2E, $00, $2E, $02, $0E, $2D, $0E, $2E, $12, $2D, $02, $00, $00, $0E, $00, $3C, $2E, $00, $00, $02, $08, $2D, $08, $02, $12, $2D, $06, $0E, $02, $03, $02, $3C, $0C, $04, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $2D, $2D, $2D, $0C, $0C, $04, $0C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
attributeScreen3:
  .byte $BE,$FE,$FE,$FE
  .byte $B8,$00,$00,$00
  .byte $B8,$3D,$0D,$3D
  .byte $B8,$B0,$2E,$00
  .byte $B8,$B6,$B8,$2E
  .byte $B8,$BE,$3E,$0E
  .byte $B8,$0A,$0B,$0E
  .byte $B8,$3E,$3E,$3E
  .byte $02,$0F,$2D,$2D
  .byte $B8,$BE,$2E,$00
  .byte $B8,$B8,$10,$2E
  .byte $B8,$BA,$00,$2E
  .byte $B8,$BA,$3D,$3E
  .byte $B8,$02,$2D,$22
  .byte $34,$3C,$3C,$3C
stage2RightScreen:
.byte $0E, $0E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $02, $02, $02, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3E, $2C, $12, $2C, $00, $3E, $3E, $3E, $3E, $3E, $3E, $3E, $02, $3E, $3E, $3E, $02, $3C, $12, $3C, $00, $3E, $00, $00, $00, $3E, $00, $00, $02, $00, $3E, $02, $02, $0A, $02, $3C, $06, $3E, $06, $3E, $00, $02, $02, $3E, $02, $3E, $3E, $02, $3E, $3E, $02, $3C, $3E, $3E, $3E, $3E, $3E, $3E, $06, $3E, $02, $00, $3E, $02, $02, $3C, $02, $3C, $00, $00, $00, $3E, $00, $06, $3E, $3E, $3E, $00, $3E, $3E, $02, $3C, $02, $00, $00, $3E, $02, $3E, $02, $3E, $3E, $02, $00, $00, $3E, $00, $02, $3C, $02, $3C, $06, $3E, $02, $3E, $02, $00, $00, $02, $3E, $3E, $02, $3E, $00, $3C, $12, $3C, $3E, $3E, $02, $3E, $3E, $00, $3E, $06, $3E, $00, $12, $3E, $00, $3C, $12, $02, $02, $3E, $02, $00, $00, $00, $3E, $3E, $00, $3E, $12, $00, $00, $3C, $00, $3C, $00, $3E, $02, $00, $3E, $00, $02, $3E, $02, $00, $12, $3E, $00, $3C, $00, $3C, $00, $3E, $06, $3E, $3E, $3E, $02, $3E, $02, $3E, $12, $3E, $00, $3C, $02, $3C, $06, $3E, $3E, $06, $00, $00, $00, $00, $00, $3E, $12, $3E, $06, $3C, $04, $0C, $0C, $0C, $0C, $0C, $0C, $04, $04, $0C, $04, $0C, $0C, $0C, $0C, $0C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
attributeScreen4:
    .byte $3E,$FE,$FE,$FE,$FE,$FE,$FE,$FE
    .byte $0A,$0B,$00,$00,$00,$00,$00,$FC
    .byte $6C,$3E,$FE,$FE,$FE,$3E,$FE,$3C
    .byte $7C,$3E,$00,$3E,$00,$08,$FA,$0A
    .byte $3C,$3E,$3E,$02,$3E,$3E,$FA,$FE
    .byte $3C,$FE,$FE,$FE,$3E,$08,$FA,$3C
    .byte $3C,$00,$3E,$06,$FE,$F8,$FE,$3C
    .byte $08,$3E,$3E,$3E,$FA,$00,$F8,$3C
    .byte $3C,$3E,$3E,$08,$02,$FE,$3E,$3C
    .byte $7C,$FE,$3E,$F8,$FE,$F8,$7E,$3C
    .byte $4A,$3E,$08,$00,$FE,$3E,$48,$3C
    .byte $3C,$3E,$08,$F8,$3E,$08,$7E,$3C
    .byte $3C,$3E,$3E,$FE,$3E,$3E,$7E,$3C
    .byte $3C,$3E,$FE,$00,$00,$3E,$7E,$3C
    .byte $1C,$3C,$3C,$34,$1C,$1C,$3C,$3C

.segment "CHR"
.incbin "graphics.chr"