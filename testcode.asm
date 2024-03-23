##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000

    .text
	.globl main

main:
init_grid:
    # CONSTANTS; load immediately
    li $t1, 0x808080        # $t1 = darkgrey
    li $t2, 0xC0C0C0        # $t2 = brightgrey
    
    # INIT LOOP COUNTER and PIXEL COLOUR
    li $t3, 0               # Loop COUNTER
    li $t4, 0               # Pixel COLOUR; 0 for Dark grey and 1 for Bright grey

    lw $t0, ADDR_DSPL       # $t0 = base address for display
    sw $t1, 0($t0)          # paint the first unit (i.e., top-left) red
    sw $t2, 4($t0)          # paint the second unit on the first row green
    sw $t1, 8($t0)
    sw $t2, 12($t0)
exit:
    li $v0, 10              # terminate the program gracefully
    syscall