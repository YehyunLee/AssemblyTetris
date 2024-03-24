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
OTetrominoX: .word 3  # Sample X coordinate
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

    lw $t0, ADDR_DSPL        # Load the base address of the display into $t0
    jal draw_tetromino_Z
    
    # Exit syscall
    li $v0, 10
    syscall
    
draw_tetromino_O:
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loop:
    blt $t8, 4, continue_y  # If Y loop counter < 8, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loop:
    blt $t7, 4, continue_x  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loop                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loop                # Jump back to the start of the Y loop
end_y_loop:
    jr $ra                  # Return from subroutine



    
draw_tetromino_I:
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loop:
    blt $t8, 8, continue_y  # If Y loop counter < 8, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loop:
    blt $t7, 2, continue_x  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loop                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loop                # Jump back to the start of the Y loop
end_y_loop:
    jr $ra                  # Return from subroutine


    
    
  
    
draw_tetromino_L:
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loop:
    blt $t8, 6, continue_y  # If Y loop counter < 6, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loop:
    blt $t7, 2, continue_x  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loop                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loop                # Jump back to the start of the Y loop
end_y_loop:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 5                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    

    jr $ra                  # Return from subroutine



draw_tetromino_J:
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loop:
    blt $t8, 6, continue_y  # If Y loop counter < 6, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loop:
    blt $t7, 2, continue_x  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loop                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loop                # Jump back to the start of the Y loop
end_y_loop:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 5                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, -2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    

    jr $ra                  # Return from subroutine

    



draw_tetromino_T: #subroutine to draw square tetromino    
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loop:
    blt $t8, 2, continue_y  # If Y loop counter < 6, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loop:
    blt $t7, 6, continue_x  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loop                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loop                # Jump back to the start of the Y loop
end_y_loop:
    li $t8, 3                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    

    jr $ra                  # Return from subroutine
    

draw_tetromino_S: #subroutine to draw square tetromino
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loop:
    blt $t8, 2, continue_y  # If Y loop counter < 8, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loop:
    blt $t7, 4, continue_x  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loop                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loop                # Jump back to the start of the Y loop
end_y_loop:
    li $t8, 3                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 8($t8)
    sw $t6, 12($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    sw $t6, -120($t8)
    sw $t6, -116($t8)
    jr $ra                  # Return from subroutine

draw_tetromino_Z: #subroutine to draw square tetromino
    lw $t0, ADDR_DSPL       # Load the base address of the display into $t0
    lw $t4, OTetrominoX     # Load the X-coordinate
    lw $t5, OTetrominoY     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loop:
    blt $t8, 2, continue_y  # If Y loop counter < 8, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loop:
    blt $t7, 4, continue_x  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loop                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loop                # Jump back to the start of the Y loop
end_y_loop:
    li $t8, 3                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, -4($t8)
    sw $t6, -8($t8)
    sw $t6, -12($t8)
    sw $t6, -16($t8)
    sw $t6, -132($t8)
    sw $t6, -136($t8)
    sw $t6, -140($t8)
    sw $t6, -144($t8)
    jr $ra                  # Return from subroutine

