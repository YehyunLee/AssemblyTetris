################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################
OTetrominoX: .word 0  # Sample X coordinate
OTetrominoY: .word 0   # Sample Y coordinate
BlockColor: .word 0xff0000 #Block Color of tetrominoes for now
BlockSize: .word 4  # 2 pixels by 2 bytes per pixel
PIXEL: .word 2 # each pixel heigh and width
##############################################################################
# Code
##############################################################################
	.text
	.globl main
    .globl draw_pixel
    .globl draw_tetromino_O
    .globl draw_tetromino_L
    .globl draw_tetromino_J
    .globl draw_tetromino_T
    .globl draw_tetromino_S
    .globl draw_tetromino_Z
    .globl draw_tetromino_I
    


	# Run the Tetris game.
main:
    li $t1, 0xff0000        # $t1 = red
    li $t2, 0x00ff00        # $t2 = green
    li $t3, 0x0000ff        # $t3 = blue

    lw $t0, ADDR_DSPL       # $t0 = base address for display
	jal draw_tetromino_L

    # End or loop the game
    # For testing, we might not loop
    # b game_loop # Commented out for a single run test
    li $v0, 10 # Exit syscall
    syscall
    
draw_tetromino_O:
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    li $t8, 0                # Initialize Y loop counter (0 to 3)
    y_loop:
        blt $t8, 4, continue_y   # If Y loop counter < 4, continue
        j end_y_loop             # Else, jump to the end of Y loop
    continue_y:
        li $t7, 0                # Initialize X loop counter (0 to 3)
    x_loop:
        blt $t7, 4, continue_x   # If X loop counter < 4, continue
        j end_x_loop             # Else, jump to the end of X loop
    continue_x:
        # Calculate the offset $t7 = 4 * (x + 32 * y)
        li $t1, 32               # Load 32 into $t1 (width of the display in pixels)
        mul $t2, $t8, $t1        # $t2 = y * 32
        add $t2, $t2, $t7        # $t2 = x + y * 32
        li $t3, 4                # Load 4 into $t3 (bytes per pixel)
        mul $t9, $t2, $t3        # $t9 = 4 * (x + 32 * y), the final offset in bytes
        add $t9, $t0, $t9        # Add the base address of the display to $t9 to get the final memory address
        
        # Store the block color at the calculated address
        sw $t6, 0($t9)           # Store the block color at the calculated address
        
        addi $t7, $t7, 1         # Increment X loop counter
        j x_loop                 # Jump back to the start of the X loop
    end_x_loop:
        addi $t8, $t8, 1         # Increment Y loop counter
        j y_loop                 # Jump back to the start of the Y loop
    end_y_loop:
    jr $ra                   # Return from subroutine


    
draw_tetromino_I:
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    li $t8, 0                # Initialize Y loop counter (0 to 8)
    y_loop:
        blt $t8, 8, continue_y   # If Y loop counter < 8, continue
        j end_y_loop             # Else, jump to the end of Y loop
    continue_y:
        li $t7, 0                # Initialize X loop counter (0 to <8)
    x_loop:
        blt $t7, 2, continue_x   # If X loop counter < 2, continue
        j end_x_loop             # Else, jump to the end of X loop
    continue_x:
        # Calculate the offset $t7 = 4 * (x + 32 * y)
        li $t1, 32               # Load 32 into $t1 (width of the display in pixels)
        mul $t2, $t8, $t1        # $t2 = y * 32
        add $t2, $t2, $t7        # $t2 = x + y * 32
        li $t3, 4                # Load 4 into $t3 (bytes per pixel)
        mul $t9, $t2, $t3        # $t9 = 4 * (x + 32 * y), the final offset in bytes
        add $t9, $t0, $t9        # Add the base address of the display to $t9 to get the final memory address
        
        # Store the block color at the calculated address
        sw $t6, 0($t9)           # Store the block color at the calculated address
        
        addi $t7, $t7, 1         # Increment X loop counter
        j x_loop                 # Jump back to the start of the X loop
    end_x_loop:
        addi $t8, $t8, 1         # Increment Y loop counter
        j y_loop                 # Jump back to the start of the Y loop
    end_y_loop:
        jr $ra                   # Return from subroutine
    
    
draw_tetromino_S: #subroutine to draw square tetromino
   lw $t1, ADDR_DSPL

   lw $a0, OTetrominoX # Y-coordinate
   lw $a1, OTetrominoY # X-coordinate

draw_tetromino_Z: #subroutine to draw square tetromino
    lw $t1, ADDR_DSPL

    lw $a0, OTetrominoX # Y-coordinate
    lw $a1, OTetrominoY # X-coordinate
    
    
# Subroutine to draw the "L" Tetromino
draw_tetromino_L:
        lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
        lw $t4, OTetrominoX     # Load the X-coordinate into $t4
        lw $t5, OTetrominoY     # Load the Y-coordinate into $t5
        lw $t6, BlockColor      # Load the block color into $t6
    
        # Draw the main body of the L
        li $t8, 0                # Y loop counter for the main body
    main_body_loop:
        blt $t8, 6, continue_main_body  # If Y loop counter < 7, continue
        j draw_foot              # Else, proceed to draw the foot
    continue_main_body:
        li $t7, 0                # X loop counter for the main body
    x_loop_main_body:
        blt $t7, 2, continue_x_main_body  # If X loop counter < 2, continue
        j end_x_loop_main_body   # Else, end the X loop
    continue_x_main_body:
        # Calculate the offset and draw
        li $t1, 32               # Width of the display in pixels
        mul $t2, $t8, $t1        # y * width
        add $t2, $t2, $t7        # (y * width) + x
        li $t3, 4                # Bytes per pixel
        mul $t2, $t2, $t3        # Offset in bytes
        add $t2, $t0, $t2        # Final address
        sw $t6, 0($t2)           # Store the color
    
        addi $t7, $t7, 1         # Increment X loop counter
        j x_loop_main_body       # Jump back to start of X loop
    end_x_loop_main_body:
        addi $t8, $t8, 1         # Increment Y loop counter
        j main_body_loop         # Jump back to start of main body loop
    
    draw_foot:
        # Starting from row 4, for 2 additional pixels to create the foot of the L
        li $t8, 4                # Y loop counter for the foot, start from row 4
        li $t9, 2                # Two additional iterations for the foot
    foot_loop:
        li $t7, 0                # Start drawing foot from column 2
        add $t7, $t7, $t9        # Calculate end column for foot drawing
        blt $t9, 4, continue_foot  # Continue if within foot drawing range
        j end_foot               # Else, end the foot loop
    continue_foot:
        # Calculate the offset and draw the foot
        li $t1, 32               # Width of the display in pixels
        mul $t2, $t8, $t1        # y * width
        add $t2, $t2, $t7        # (y * width) + x
        li $t3, 4                # Bytes per pixel
        mul $t2, $t2, $t3        # Offset in bytes
        add $t2, $t0, $t2        # Final address for the foot
        sw $t6, 0($t2)           # Store the color for the foot
        sw $t6, 128($t2)           # Store the color for the foot
    
        addi $t9, $t9, 1         # Increment foot drawing counter
        j foot_loop              # Jump back to start of foot loop
    end_foot:
        jr $ra                   # Return from subroutine


draw_tetromino_J:
    



draw_tetromino_T: #subroutine to draw square tetromino    
    lw $t1, ADDR_DSPL

    lw $a0, OTetrominoX # Y-coordinate
    lw $a1, OTetrominoY # X-coordinate
    
    

