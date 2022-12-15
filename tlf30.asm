// import standard library definitions
#import "standardLibrary.asm"			

// link to packer / depacker module
.plugin "se.booze.kickass.CruncherPlugins"


// koala bitmap pointers

.var textFlash  = $d800 + (40*12)
.var screen_data = $3f40
.var colour_data = $4328
.var back_colour = $4710

// load music and define pointer
.var music = LoadSid("sids\Jam.sid")
.pc = music.location "Music"
.fill music.size, music.getData(i)
//----------------------------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------------------------
BasicUpstart2(start)
//----------------------------------------------------------------------------------------------------------------------------------------

*= $080d "Main Code"			// main code starts below
.memblock "main code"

start:		
						lda #$35
						sta $01

						SetBoth(BLACK)
								
						// reset color flash to zero
					
						lda #00
						sta PackedImage
						sta $d41f			// reset volume to 0


						lda #$00
						tax
						tay
						jsr music.init

						// setup the interupt
					
						sei
						lda #$7f
						sta $dc0d
						sta $dd0d
						lda $dc0d
						lda $dd0d
						lda #$81
						sta irqenable   
						lda #$1b
						sta screenmode
						lda #$34
						sta raster
						lda #$81
						sta irqenable
						lda #24
						sta charset
					
						lda #$ff
						sta irqflag

						// 1st IRQ pointers
						lda #<titleIrq
						sta $fffe
						lda #>titleIrq
						sta $ffff

						cli

						jmp *

/*keyscan:				lda $dc01
						cmp #$ef
						bne keyscan

						jmp keyscan2 */
//----------------------------------------------------------------------------------------------------------------------------------------
depack_tune:
						lda #$0b
						sta screenoff

						ldx Packed_tune				// tune number counter
                        ldy Packed_Lo,x				// lo byte
                        lda Packed_Hi,x 			// hi byte
                        tax
						jsr Decruncher


						lda #$3b
						sta screenoff
						rts
//----------------------------------------------------------------------------------------------------------------------------------------
nmi:					rti
//----------------------------------------------------------------------------------------------------------------------------------------
titleIrq:	  			
						pha
						txa
						pha
						tya
						pha

						jsr music.play

						inc	irqflag

						pla
						tay
						pla
						tax
						pla
						rti
//----------------------------------------------------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------------------------------------------------
.memblock "Decrunch Tables"
screenoff:				.byte $00				// control $d011 screen mode

Packed_tune:			.byte $00				// which tune to depack ?
						.byte $ff

Packed_Hi:				.byte >packed_tune01, >packed_tune02
						.byte $ff

Packed_Lo:				.byte <packed_tune01, <packed_tune02
						.byte $ff
//----------------------------------------------------------------------------------------------------------------------------------------

Decruncher:				
#import "B2_Decruncher.asm"

//----------------------------------------------------------------------------------------------------------------------------------------
// packed tunes data for sinlge file version
//----------------------------------------------------------------------------------------------------------------------------------------
packed_tune01:                                        
						.pc = $6000 "sids\Clubbit.sid"
						.modify B2() {
							.var tune01 = LoadBinary ("sids\Clubbit.sid" )
							.fill music.size, music.getData(i)
						}

packed_tune02:                                        
						.pc = $7000 "sids\D-mix_techno.sid"
						.modify B2() {
							.var tune02 = LoadBinary ("sids\D-mix_techno.sid" )
							.fill music.size, music.getData(i)
						}
