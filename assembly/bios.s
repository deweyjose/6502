.setcpu "65C02"
.debuginfo
.segment "BIOS"

ACIA_DATA = $5000
ACIA_STATUS = $5001
ACIA_CMD = $5002
ACIA_CTRL = $5003

LOAD:
    rts
SAVE:
    rts
MONRDKEY:
CHRIN:
    lda ACIA_STATUS
    and #$08
    beq @no_keypressed
    lda ACIA_DATA
    jsr CHROUT
    sec
    rts

@no_keypressed:
    clc
    rts

MONCOUT:
CHROUT:
    pha
    sta ACIA_DATA
    lda #$FF
@txdelay:
    dec
    bne @txdelay
    pla
    rts

.include "wozmon/wozmon.s"

.segment "RESETVEC"
    .word   $0F00          ; NMI vector
    .word   RESET          ; RESET vector
    .word   $0000          ; IRQ vector