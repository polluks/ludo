; ====================================================================================
; vdc_core_assembly.s
; Core assembly routines for vdc_core.c
;
; Credits for code and inspiration:
;
; C128 Programmers Reference Guide:
; http://www.zimmers.net/anonftp/pub/cbm/manuals/c128/C128_Programmers_Reference_Guide.pdf
;
; Scott Hutter - VDC Core functions inspiration:
; https://github.com/Commodore64128/vdc_gui/blob/master/src/vdc_core.c
; (used as starting point, but channged to inline assembler for core functions, added VDC wait statements and expanded)
;
; Francesco Sblendorio - Screen Utility:
; https://github.com/xlar54/ultimateii-dos-lib/blob/master/src/samples/screen_utility.c
;
; DevDef: Commodore 128 Assembly - Part 3: The 80-column (8563) chip
; https://devdef.blogspot.com/2018/03/commodore-128-assembly-part-3-80-column.html
;
; 6502.org: Practical Memory Move Routines
; http://6502.org/source/general/memory_move.html
;
; =====================================================================================


    .export		_VDC_ReadRegister_core
	.export		_VDC_WriteRegister_core
	.export		_VDC_Poke_core
	.export		_VDC_Peek_core
	.export		_VDC_MemCopy_core
	.export		_VDC_HChar_core
	.export		_VDC_VChar_core
	.export		_VDC_CopyMemToVDC_core
	.export		_VDC_CopyVDCToMem_core
	.export		_VDC_RedefineCharset_core
	.export		_VDC_FillArea_core
	.export		_SetLoadSaveBank_core
    .export		_VDC_regadd
	.export		_VDC_regval
	.export		_VDC_addrh
	.export		_VDC_addrl
	.export		_VDC_desth
	.export		_VDC_destl
	.export		_VDC_value
	.export		_VDC_tmp1
	.export		_VDC_tmp2
	.export		_VDC_tmp3
	.export		_VDC_tmp4

VDC_ADDRESS_REGISTER    = $D600
VDC_DATA_REGISTER       = $D601

.segment	"BSS"

_VDC_regadd:
	.res	1
_VDC_regval:
	.res	1
_VDC_addrh:
	.res	1
_VDC_addrl:
	.res	1
_VDC_desth:
	.res	1
_VDC_destl:
	.res	1
_VDC_value:
	.res	1
_VDC_tmp1:
	.res	1
_VDC_tmp2:
	.res	1
_VDC_tmp3:
	.res	1
_VDC_tmp4:
	.res	1
ZPtmp1:
	.res	1
ZPtmp2:
	.res	1

.segment	"CODE"

; ------------------------------------------------------------------------------------------
_VDC_ReadRegister_core:
; Function to read a VDC register
; Input:	VDC_regadd = register number
; Output:	VDC_regval = read value
; ------------------------------------------------------------------------------------------

	ldx _VDC_regadd                     ; Load register address in X
	stx VDC_ADDRESS_REGISTER            ; Store X in VDC address register
notyetready:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER            ; Check status bit 7 of VDC address register
	bpl notyetready                     ; Continue loop if status is not ready
	lda VDC_DATA_REGISTER               ; Load data to A from VDC data register
	sta _VDC_regval                     ; Load A to return variable
    rts

; ------------------------------------------------------------------------------------------
_VDC_WriteRegister_core:
; Function to write a VDC register
; Input:	VDC_regadd = register numnber
;			VDC_regval = value to write
; ------------------------------------------------------------------------------------------

    ldx _VDC_regadd                     ; Load register address in X
	lda _VDC_regval				        ; Load register value in A
notyetready2:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER            ; Check status bit 7 of VDC address register
	bpl notyetready2                    ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER               ; Store A to VDC data
    rts

; ------------------------------------------------------------------------------------------
_VDC_Poke_core:
; Function to store a value to a VDC address
; Input:	VDC_addrh = VDC address high byte
;			VDC_addrl = VDC address low byte
;			VDC_value = value to write
; ------------------------------------------------------------------------------------------

    ldx #$12                            ; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_addrh                      ; Load high byte of address in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waithighaddress:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waithighaddress			        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data
	inx		    						; Increase X for register 19 (VDC RAM address low)
	lda _VDC_addrl      				; Load low byte of address in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitlowaddress:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER           	; Check status bit 7 of VDC address register
	bpl waitlowaddress      			; Continue loop if status is not ready
	sta VDC_DATA_REGISTER       		; Store A to VDC data
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X	
	lda _VDC_value       				; Load high byte of address in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitvalue:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvalue       				; Continue loop if status is not ready
	sta VDC_DATA_REGISTER               ; Store A to VDC data
    rts

; ------------------------------------------------------------------------------------------
_VDC_Peek_core:
; Function to read a value from a VDC address
; Input:	VDC_addrh = VDC address high byte
;			VDC_addrl = VDC address low byte
; Output:	VDC_value = read value
; ------------------------------------------------------------------------------------------

    ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_addrh      				; Load high byte of address in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waithighaddress2:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waithighaddress2        		; Continue loop if status is not ready
	sta VDC_DATA_REGISTER       		; Store A to VDC data
	inx					    			; Increase X for register 19 (VDC RAM address low)
	lda _VDC_addrl	    	    		; Load low byte of address in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitlowaddress2:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitlowaddress2			        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X	
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitvalue2:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvalue2			        	; Continue loop if status is not ready
	lda VDC_DATA_REGISTER	        	; Load VDC data to A
	sta _VDC_value			        	; Load A to return variable
    rts

; ------------------------------------------------------------------------------------------
_VDC_MemCopy_core:
; Function to copy memory from one to another position within VDC memory
; Input:	VDC_addrh = high byte of source address
;			VDC_addrl = low byte of source address
;			VDC_desth = high byte of destination address
;			VDC_destl = low byte of destination address
;			VDC_tmp1 = number of 256 byte pages to copy
;			VDC_tmp2 = length in last page to copy
;			VDC_value = Set value for copy bit 7 enabled of register 24
; ------------------------------------------------------------------------------------------

loopmemcpy:
	; Hi-byte of the destination address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_desth      				; Load high byte of dest in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitdesthighaddress:					; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitdesthighaddress     		; Continue loop if status is not ready
	sta VDC_DATA_REGISTER       		; Store A to VDC data

	; Lo-byte of the destination address to register 19
	ldx #$13    						; Load $13 for register 19 (VDC RAM address high) in X	
	lda _VDC_destl       				; Load high byte of dest in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitdestlowaddress:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitdestlowaddress	        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Hi-byte of the source address to block copy source register 32
	ldx #$20					    	; Load $20 for register 32 (block copy source) in X	
	lda _VDC_addrh			        	; Load high byte of source in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitsrchighaddress:				    	; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitsrchighaddress		        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data
	
	; Lo-byte of the source address to block copy source register 33
	ldx #$21					    	; Load $21 for register 33 (block copy source) in X	
	lda _VDC_addrl		        		; Load low byte of source in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitsrclowaddress:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitsrclowaddress		        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data
	
	; Set the copy bit (bit 7) of register 24 (block copy mode)
	ldx #$18    						; Load $18 for register 24 (block copy mode) in X	
	lda _VDC_value		        		; Load prepared value with bit 7 set in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitsetcopybit:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitsetcopybit		        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Number of bytes to copy
	ldx #$1E    						; Load $1E for register 30 (word count) in X
	lda _VDC_tmp1		        		; Load page counter in A
	cmp #$01    						; Check if this is the last page
	bne notyetlastpage			        ; Branch to 'not yet last page' if not equal
	lda _VDC_tmp2		        		; Set length in last page
	jmp lastpage		        		; Goto last page label
notyetlastpage:							; Label for not yet last page
	lda #$ff    						; Set length for 256 bytes
lastpage:								; Label for jmp if last page
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitsetlength:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitsetlength		        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Decrease page counter and loop until last page
	inc _VDC_desth		        		; Increase destination address page counter
	inc _VDC_addrh		        		; Increase source address page counter
	dec _VDC_tmp1		        		; Decrease page counter
	bne loopmemcpy				        ; Repeat loop until page counter is zero
    rts

; ------------------------------------------------------------------------------------------
_VDC_HChar_core:
; Function to draw horizontal line with given character (draws from left to right)
; Input:	VDC_addrh = igh byte of start address
;			VDC_addrl = ow byte of start address
;			VDC_value = Prepae value for copy bit 7 disabled of register 24
;			VDC_tmp1 = character value
;			VDC_tmp2 = length value
;			VDC_tmp3 = attribute value
; ------------------------------------------------------------------------------------------

	; Hi-byte of the destination address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_addrh	        			; Load high byte of start in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitstarthighaddress:					; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitstarthighaddress	        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Lo-byte of the destination address to register 19
	ldx #$13    						; Load $13 for register 19 (VDC RAM address high) in X	
	lda _VDC_addrl		        		; Load high byte of start in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitstartlowaddress:					; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitstartlowaddress		        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Store character to write in data register 31
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X	
	lda _VDC_tmp1			        	; Load character value in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitvalue4:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitvalue4			        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Clear the copy bit (bit 7) of register 24 (block copy mode)
	ldx #$18    						; Load $18 for register 24 (block copy mode) in X	
	lda _VDC_value			        	; Load prepared value with bit 7 set in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitclearcopybit:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitclearcopybit		        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Store lenth in data register 30
	ldx #$1e    						; Load $1f for register 30 (word count) in X	
	lda _VDC_tmp2			        	; Load character value in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitlength:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitlength			        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Continue with copying attribute values
	clc									; Clear carry
	lda _VDC_addrh						; Load high byte of start address again in A
	adc #$08							; Add 8 pages to get charachter attribute address

	; Hi-byte of the destination attribute address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitstarthigatthaddress:				; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitstarthigatthaddress	        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Lo-byte of the destination attribute address to register 19
	ldx #$13    						; Load $13 for register 19 (VDC RAM address high) in X	
	lda _VDC_addrl		        		; Load high byte of start in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitstartlowattaddress:					; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitstartlowattaddress		    ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Store attribute to write in data register 31
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X	
	lda _VDC_tmp3			        	; Load attribute value in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitvalueatt:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitvalueatt			       	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Clear the copy bit (bit 7) of register 24 (block copy mode)
	ldx #$18    						; Load $18 for register 24 (block copy mode) in X	
	lda _VDC_value			        	; Load prepared value with bit 7 set in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitclearcopybitatt:					; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitclearcopybitatt		        ; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Store lenth in data register 30
	ldx #$1e    						; Load $1f for register 30 (word count) in X	
	lda _VDC_tmp2			        	; Load character value in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitlengthatt:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitlengthatt			       	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data
    rts

; ------------------------------------------------------------------------------------------
_VDC_VChar_core:
; Function to draw vertical line with given character (draws from top to bottom)
; Input:	VDC_addrh = high byte of start address
;			VDC_addrl = low byte of start address
;			VDC_tmp1 = character value
;			VDC_tmp2 = length value
;			VDC_tmp3 = attribute value
; ------------------------------------------------------------------------------------------

loopvchar:
	; Hi-byte of the destination address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_addrh		        		; Load high byte of start in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitstarthighaddress1:					; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitstarthighaddress1        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Lo-byte of the destination address to register 19
	ldx #$13    						; Load $13 for register 19 (VDC RAM address high) in X	
	lda _VDC_addrl			        	; Load high byte of start in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitstartlowaddress1:					; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitstartlowaddress1        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Store character to write in data register 31
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X	
	lda _VDC_tmp1			        	; Load character value in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitvalue5:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvalue5			        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER           	; Store A to VDC data

	; Continue with attribute value
	clc									; CLear carry
	lda _VDC_addrh						; Load high byte of start address again in A
	adc #$08							; Add 8 pages to get charachter attribute address

	; Hi-byte of the destination attribute address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitstarthighattaddress1:				; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitstarthighattaddress1       	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER		        ; Store A to VDC data

	; Lo-byte of the destination attribute address to register 19
	ldx #$13    						; Load $13 for register 19 (VDC RAM address high) in X	
	lda _VDC_addrl			        	; Load high byte of start in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitstartlowattaddress1:				; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitstartlowattaddress1        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Store attribute to write in data register 31
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X	
	lda _VDC_tmp3			        	; Load attribute value in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitvalueatt5:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvalueatt5		        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER           	; Store A to VDC data

	; Increase start address with 80 for next line
	clc 								; Clear carry
	lda _VDC_addrl	        			; Load low byte of address to A
	adc #$50    						; Add 80 with carry
	sta _VDC_addrl			        	; Store result back
	lda _VDC_addrh	        			; Load high byte of address to A
	adc #$00    						; Add 0 with carry
	sta _VDC_addrh	        			; Store result back

	; Loop until length reaches zero
	dec _VDC_tmp2		        		; Decrease length counter
	bne loopvchar		        		; Loop if not zero
    rts

; ------------------------------------------------------------------------------------------
_VDC_CopyMemToVDC_core:
; Function to copy memory from VDC memory to standard memory
; Input:	VDC_addrh = high byte of source address
;			VDC_addrl = low byte of source address
;			VDC_desth = high byte of VDC destination address
;			VDC_destl = low byte of VDC destination address
;			VDC_tmp1 = number of 256 byte pages to copy
;			VDC_tmp2 = length in last page to copy
;			VDC_tmp3 = memory bank of source
; ------------------------------------------------------------------------------------------

	; Store $FA and $FB addresses for safety to be restored at exit
	lda $fb								; Obtain present value at $fb
	sta ZPtmp1							; Store to be restored later
	lda $fc								; Obtain present value at $fc
	sta ZPtmp2							; Store to be restored later

	; Set address pointer in zero-page
	lda _VDC_addrl						; Obtain low byte in A
	sta $fb								; Store low byte in pointer
	lda _VDC_addrh						; Obtain high byte in A
	sta $fc								; Store high byte in pointer

	; Hi-byte of the source VDC address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_desth		        		; Load high byte of address in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waithighaddressm2v:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waithighaddressm2v	        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Low-byte of the source VDC address to register 19
	inx 								; Increase X for register 19 (VDC RAM address low)
	lda _VDC_destl      				; Load low byte of address in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitlowaddressm2v:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitlowaddressm2v	        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Start of copy loop
	ldy #$00    						; Set Y as counter on 0
	
	; Read value and store at VDC address
copyloopm2v:							; Start of copy loop
	lda #$fb							; Store address vector in A
	ldx _VDC_tmp3						; Store banknumber in X
	jsr $ff74							; Call INDFET kernal routine to do lda ($fb),y from given bank
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitvaluem2v:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvaluem2v		        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Increase source address (VDC auto increments)
	inc $fb								; Increment low byte of source address
	bne nextm2v1						; If not yet zero, branch to next label
	inc $fc								; Increment high byte of source address
nextm2v1:								; Next label
	dec _VDC_tmp2						; Decrease low byte of length
	lda _VDC_tmp2						; Load low byte of length to A
	cmp #$ff							; Check if below zero
	bne copyloopm2v						; Continue loop if not yet below zero
	dec _VDC_tmp1						; Decrease high byte of length
	lda _VDC_tmp1						; Load high byte of length to A
	cmp #$ff							; Check if below zero
	bne copyloopm2v						; Continue loop if not yet below zero

; Restore $fb and $fc
	lda ZPtmp1							; Obtain stored value of $fb
	sta $fb								; Restore value
	lda ZPtmp2							; Obtain stored value of $fc
	sta $fc								; Restore value
    rts

; ------------------------------------------------------------------------------------------
_VDC_CopyVDCToMem_core:
; Function to copy memory from VDC memory to standard memory
; Input:	VDC_addrh = high byte of VDC source address
;			VDC_addrl = low byte of VDC source address
;			VDC_desth = high byte of destination address
;			VDC_destl = low byte of destination address
;			VDC_tmp1 = number of 256 byte pages to copy
;			VDC_tmp2 = length in last page to copy
;			VDC_tmp3 = memory bank of destination
; ------------------------------------------------------------------------------------------

	; Store $FA and $FB addresses for safety to be restored at exit
	lda $fb								; Obtain present value at $fb
	sta ZPtmp1							; Store to be restored later
	lda $fc								; Obtain present value at $fc
	sta ZPtmp2							; Store to be restored later

	; Set address pointer in zero-page and STAVEC vector
	lda _VDC_destl						; Obtain low byte in A
	sta $fb								; Store low byte in pointer
	lda _VDC_desth						; Obtain high byte in A
	sta $fc								; Store high byte in pointer
	lda #$fb							; Load $fb address value in A
	sta $2b9							; Save in STAVEC vector

	; Start of copy loop
	ldy #$00    						; Set Y as counter on 0

copyloopv2m:							; Start of copy loop

	; Hi-byte of the source VDC address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_addrh		        		; Load high byte of address in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waithighaddressv2m:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waithighaddressv2m	        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Low-byte of the source VDC address to register 19
	inx 								; Increase X for register 19 (VDC RAM address low)
	lda _VDC_addrl      				; Load low byte of address in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitlowaddressv2m:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitlowaddressv2m	        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data
	
	; Read VDC value and store at destination address
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitvaluev2m:							; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvaluev2m		        	; Continue loop if status is not ready
	lda VDC_DATA_REGISTER	        	; Read VDC data to A
	ldx _VDC_tmp3						; Store banknumber in X
	jsr $ff77							; Call INDSTA kernal routine to do sta ($fb),y from given bank

	; Increase VDC source address and target memory address
	inc $fb								; Increment low byte of target address
	bne nextv2m1						; If not yet zero, branch to next label
	inc $fc								; Increment high byte of target address
nextv2m1:								; Next label
	inc _VDC_addrl						; Increment low byte of VDC address
	bne nextv2m2						; If not yet zero, branch to next label
	inc _VDC_addrh						; Increment hight byte of VDC address
nextv2m2:								; Next label
	dec _VDC_tmp2						; Decrease low byte of length
	lda _VDC_tmp2						; Load low byte of length to A
	cmp #$ff							; Check if below zero
	bne copyloopv2m						; Continue loop if not yet below zero
	dec _VDC_tmp1						; Decrease high byte of length
	lda _VDC_tmp1						; Load high byte of length to A
	cmp #$ff							; Check if below zero
	bne copyloopv2m						; Continue loop if not yet below zero

; Restore $fb and $fc
	lda ZPtmp1							; Obtain stored value of $fb
	sta $fb								; Restore value
	lda ZPtmp2							; Obtain stored value of $fc
	sta $fc								; Restore value
    rts

; ------------------------------------------------------------------------------------------
_VDC_RedefineCharset_core:
; Function to copy charset definition from normal memory to VDC
; Input:	VDC_addrh = (source>>8) & 0xff;			// Obtain high byte of destination address
;			VDC_addrl = source & 0xff;				// Obtain low byte of destination address
;			VDC_tmp2 = sourcebank;					// Obtain bank number for source
;			VDC_desth = (dest>>8) & 0xff;			// Obtain high byte of destination address
;			VDC_destl = dest & 0xff;				// Obtain low byte of destination address
;			VDC_tmp1 = lengthinchars;				// Obtain number of characters to copy
; ------------------------------------------------------------------------------------------

	; Store $FA and $FB addresses for safety to be restored at exit
	lda $fb								; Obtain present value at $fb
	sta ZPtmp1							; Store to be restored later
	lda $fc								; Obtain present value at $fc
	sta ZPtmp2							; Store to be restored later

	; Set address pointer in zero-page
	lda _VDC_addrl						; Obtain low byte in A
	sta $fb								; Store low byte in pointer
	lda _VDC_addrh						; Obtain high byte in A
	sta $fc								; Store high byte in pointer

	; Hi-byte of the destination VDC address to register 18
	ldx #$12    						; Load $12 for register 18 (VDC RAM address high) in X	
	lda _VDC_desth		        		; Load high byte of address in A
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waithighaddress4:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waithighaddress4	        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Low-byte of the destination VDC address to register 19
	inx 								; Increase X for register 19 (VDC RAM address low)
	lda _VDC_destl      				; Load low byte of address in A
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitlowaddress4:						; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitlowaddress4		        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Start of copy loop
	ldy #$00    						; Set Y as counter on 0
looprc1:								; Start of outer loop
	
	; Read value from data register
looprc2:								; Start of 8 bytes character copy loop
	lda #$fb							; Store address vector in A
	ldx _VDC_tmp2						; Store banknumber in X
	jsr $ff74							; Call INDFET kernal routine to do lda ($fb),y from given bank
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitvalue6:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvalue6			        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Count 8 bytes per char
	iny 								; Increase Y counter
	cpy #$08    						; Is counter at 8?
	bcc looprc2				        	; If not yet 8, go to start of char copy loop

	; Add 8 bytes of zero padding per char
	lda #$00    						; Set 0 value to use as padding in A
looprc3:								; Start of padding loop
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitvalue7:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitvalue7			        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data
	dey 								; Decrease Y counter
	bne looprc3		        			; Continue padding looop if counter is not yet zero

	; Next character
	clc 								; Clear carry
	lda $fb		       				 	; Load low byte of source address in A
	adc #$08    						; Add 8 to address with carry
	sta $fb		       				 	; Store new address low byte
	lda $fc      						; Load high byte of source address in A
	adc #$00    						; Add zero with carry to A
	sta $fc        						; Store new address high byte
	dec _VDC_tmp1			        	; Decrease character length counter
	bne looprc1				        	; Branch for outer loop if not yet zero

	; Copy one final char
	ldy #$00       						; Set Y as counter on 0
looprc4:								; Start of 8 bytes character copy loop
	lda #$fb							; Store address vector in A
	ldx _VDC_tmp2						; Store banknumber in X
	jsr $ff74							; Call INDFET kernal routine to do lda ($fb),y from given bank
	ldx #$1f    						; Load $1f for register 31 (VDC data) in X
	stx VDC_ADDRESS_REGISTER	        ; Store X in VDC address register
waitvalue8:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER        	; Check status bit 7 of VDC address register
	bpl waitvalue8			        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data

	; Count 8 bytes per char
	iny 								; Increase Y counter
	cpy #$08    						; Is counter at 8?
	bcc looprc4       					; If not yet 8, go to start of char copy loop

; Add 8 bytes of zero padding per char
	lda #$00    						; Set 0 value to use as padding in A
looprc5:								; Start of padding loop
	stx VDC_ADDRESS_REGISTER        	; Store X in VDC address register
waitvalue9:								; Start of wait loop to wait for VDC status ready
	bit VDC_ADDRESS_REGISTER	        ; Check status bit 7 of VDC address register
	bpl waitvalue9			        	; Continue loop if status is not ready
	sta VDC_DATA_REGISTER	        	; Store A to VDC data
	dey 								; Decrease Y counter
	bne looprc5		        			; Continue padding looop if counter is not yet zero

; Restore $fb and $fc
	lda ZPtmp1							; Obtain stored value of $fb
	sta $fb								; Restore value
	lda ZPtmp2							; Obtain stored value of $fc
	sta $fc								; Restore value
    rts

; ------------------------------------------------------------------------------------------
_VDC_FillArea_core:
; Function to draw area with given character (draws from topleft to bottomright)
; Input:	VDC_addrh = high byte of start address
;			VDC_addrl = low byte of start address
;			VDC_value = Prepae value for copy bit 7 disabled of register 24
;			VDC_tmp1 = haracter value
;			VDC_tmp2 = length value
;			VDC_tmp3 = attribute value
;			VDC_tmp4 = number of lines
; ------------------------------------------------------------------------------------------

loopdrawline:
	jsr _VDC_HChar_core					; Draw line

	; Increase start address with 80 for next line
	clc 								; Clear carry
	lda _VDC_addrl	        			; Load low byte of address to A
	adc #$50    						; Add 80 with carry
	sta _VDC_addrl			        	; Store result back
	lda _VDC_addrh	        			; Load high byte of address to A
	adc #$00    						; Add 0 with carry
	sta _VDC_addrh	        			; Store result back

	; Decrease line counter and loop until zero
	dec _VDC_tmp4						; Decrease line counter
	bne loopdrawline					; Continue until counter is zero
	rts

; ------------------------------------------------------------------------------------------
_SetLoadSaveBank_core:
; Function to set bank for I/O operations
; Input:	VDC_tmp1 = bank number
; ------------------------------------------------------------------------------------------
	lda _VDC_tmp1						; Obtain bank number to load/save in
	ldx #0								; Set bank for filename as 0
	jsr $ff68							; Call SETBNK kernal function
	rts