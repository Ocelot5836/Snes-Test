
.INCLUDE "header.inc"
.INCLUDE "InitSNES.asm"
.INCLUDE "utils.inc"

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

;== Global Variables ==
.EQU PalNum $0000

;==========================================
; Main Code
;==========================================

Start:
    InitSNES

    rep #$10
    sep #$20

    stz PalNum

    LoadPalette BG_Palette, 0, 8
    LoadBlockToVRAM Tiles, $0000, $0040        ; 4 tiles, 2bpp = 64 bytes or 0x40 hex

    jmp SpriteInit

    ; Init Sprite 0
    lda #(256 / 2 - 16)
    sta $0000        ; Sprite X

    lda #(224 / 2 - 16)
    sta $0001        ; Sprite Y

    stz $0002        ; Starting Tile
    stz $0003        ; vhoopppc

    lda #$80         ; Set up write
    sta $2115

    ldx #$0400       ; The location of (0, 0) in BG1
    stx $2116
    lda #$01
    sta $2118

    ldx #$0420       ; The location of (0, 1) in BG1
    stx $2116
    ldx #$0402
    stx $2118

    jsr SetupVideo

    lda #$80
    sta $4200        ; Enable NMI
loop:
    .REPT 7
        WAI
    .ENDR

    lda PalNum
    clc
    adc #$04
    and #$1C
    sta PalNum

    jmp loop

VBlank:
    rep #$10
    sep #$20

    stz $2115
    ldx #$0400
    stx $2116
    lda PalNum
    sta $2119

    lda $4210

    RTI

SpriteInit:
    php             ; preserve P register

    rep #$30        ; 16bit A/X/Y
    lda #$01        ; Prepare Loop 1
_offscreen:
    sta $0000, X
    inx
    inx
    inx
    inx
    cpx #$0200
    bne _offscreen
;===================
    lda #$5555
_xmsb:
    sta $0000, X
    inx
    inx
    cpx #$0220
    bne _xmsb
;===================

    plp
    rts

;============================================================================
; SetupVideo -- Sets up the video mode and tile-related registers
;----------------------------------------------------------------------------
; In: None
;----------------------------------------------------------------------------
; Out: None
;----------------------------------------------------------------------------
SetupVideo:
    php

    lda #$00
    sta $2105           ; Set Video mode 0, 8x8 tiles, 4 color BG1/BG2/BG3/BG4

    lda #$04            ; Set BG1's Tile Map offset to $0400 (Word address)
    sta $2107           ; And the Tile Map size to 32x32

    stz $210B           ; Set BG1's Character VRAM offset to $0000 (word address)

    lda #%00000001            ; Enable BG1
    sta $212C

    lda #$FF
    sta $210E
    sta $210E

    lda #$0F
    sta $2100           ; Turn on screen, full Brightness

    plp
    rts
;============================================================================

.ENDS

.BANK 1 .SLOT 0
.ORG 0
.SECTION "CharacterData"

    .INCLUDE "tiles.inc"
;MarioImage:
;    .INCBIN "mario.pic"
;MarioPalette:
;    .INCBIN "mario.clr"

.ENDS
