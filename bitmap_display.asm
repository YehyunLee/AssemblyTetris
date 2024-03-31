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
    li $t1, 0xff0000        # $t1 = red
    li $t2, 0x00ff00        # $t2 = green
    li $t3, 0x0000ff        # $t3 = blue

    lw $t0, ADDR_DSPL       # $t0 = base address for display

    sw $t2, 8($t0)         # paint the second unit on the first row green
    sw $t2, 12($t0)        # paint the second unit on the first row green
    sw $t3, 16($t0)        # paint the first unit on the second row blue
    sw $t3, 20($t0)        # paint the first unit on the second row blue
    
    sw $t2, 116($t0)          # paint the second unit on the first row green
    sw $t2, 112($t0)          # paint the second unit on the first row green
    sw $t3, 108($t0)        # paint the first unit on the second row blue
    sw $t3, 104($t0)        # paint the first unit on the second row blue
exit:
    li $v0, 10              # terminate the program gracefully
    syscall
