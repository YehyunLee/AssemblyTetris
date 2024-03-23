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
    
    # INIT BASE ADDRESS
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    
    # INIT LOOP COUNTER and PIXEL COLOUR
    li $t3, 0               # Loop COUNTER
    li $t4, 0               # Pixel COLOUR flag; 0 for Dark grey and 1 for Bright grey
paint_loop:
    # Choose colour based on Pixel COLOUR flag
    beq $t4, 0, paint_dark_grey   # If flag is 0, call function for painting dark grey
    sw $t2, 0($t0)          # If not, paint BRIGHT grey
    li $t4, 0               # Next time, paint DARK grey
    b paint_loop_end        # b is used to jump to different branch
                            # Here this continues to the next pixel

    # OLD CODE that I want to keep here:
    # sw $t1, 0($t0)          # paint the first unit (i.e., top-left) red
    # sw $t2, 4($t0)          # paint the second unit on the first row green
    # sw $t1, 8($t0)
    # sw $t2, 12($t0)
paint_dark_grey:
    sw $t1, 0($t0)            # Paint dark grey
    li $t4, 1                 # Set colour FLAG to 1; meaning next time BRIGHT grey
    b paint_loop_end
paint_loop_end:
    addi $t3, $t3, 1        # Increment loop counter: t3 += 1
    addi $t0, $t0, 4        # Move to next pixel
                            # (by offset 4, since each pixel takes 4 bytes)
    
    # Check if painted ALL pixels then exit
    li $t5, 65536             # Load variable of 256 x 256
    bne $t3, $t5, paint_loop
exit:
    li $v0, 10              # terminate the program gracefully
    syscall