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
OTetrominoX: .word 1  # Sample X coordinate
OTetrominoY: .word 2   # Sample Y coordinate
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
	jal draw_tetromino_O

    # End or loop the game
    # For testing, we might not loop
    # b game_loop # Commented out for a single run test
    li $v0, 10 # Exit syscall
    syscall
    
draw_tetromino_O:
    lw $a2, ADDR_DSPL        # Load the base address of the display into $a2
    lw $t4, OTetrominoX      # Load the X-coordinate
    lw $t5, OTetrominoY      # Load the Y-coordinate

    # Draw the first pixel at the top-left corner
    li $a0, 1                # X offset from $t4
    li $a1, 0                # Y offset from $t5
    add $a0, $a0, $t4        # Calculate actual X-coordinate
    add $a1, $a1, $t5        # Calculate actual Y-coordinate
    jal draw_pixel           # Draw the pixel

    # Draw the second pixel to the right of the first one
    li $a0, 3                # X offset from $t4 for the second pixel
    li $a1, 0                # Y offset from $t5 remains the same
    add $a0, $a0, $t4        # Calculate actual X-coordinate for the second pixel
    add $a1, $a1, $t5        # Calculate actual Y-coordinate remains the same
    jal draw_pixel           # Draw the second pixel
    
    # Ensure to add more calls to draw_pixel here for the rest of the "O" Tetromino pixels
    
    jr $ra                   # Return from subroutine

    
    


    
draw_tetromino_I:
    lw $a2, ADDR_DSPL        # Load the base address of the display into $a2

    # Load the top-left corner X and Y coordinates
    lw $t4, OTetrominoX      # Load the X-coordinate into $t4
    lw $t5, OTetrominoY      # Load the Y-coordinate into $t5

    # Initialize Y-coordinate (row)
    move $t1, $t5            # Start with the top-most row

    # Loop for each of the 8 rows (height)
    li $t2, 8                # Counter for rows
    row_loop_I:
        bgez $t2, end_row_loop_I   # Break the loop if counter is less than 0
    
        # Initialize X-coordinate (column)
        move $t0, $t4            # Start with the left-most column
    
        # Loop for each of the 2 columns (width)
        li $t3, 2                # Counter for columns
    column_loop_I:
        bgez $t3, end_column_loop_I   # Break the loop if counter is less than 0
    
        # Set the coordinates for draw_pixel
        move $a0, $t0            # Set X-coordinate
        move $a1, $t1            # Set Y-coordinate
    
        jal draw_pixel           # Call subroutine to draw the pixel at (x, y)
    
        addi $t0, $t0, 1         # Move to the next column
        addi $t3, $t3, -1        # Decrement column counter
        j column_loop_I            # Repeat the loop for the next column
    
    end_column_loop_I:
        addi $t1, $t1, 1         # Move to the next row
        addi $t2, $t2, -1        # Decrement row counter
        j row_loop_I               # Repeat the loop for the next row
    
    end_row_loop_I:
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
    lw $t1, ADDR_DSPL        # Load the base address of the display into $t1

    # Load the top-left corner X and Y coordinates
    lw $t4, OTetrominoX      # Load the X-coordinate into $t4
    lw $t5, OTetrominoY      # Load the Y-coordinate into $t5

    # Initialize Y-coordinate (row)
    move $t1, $t5            # Start with the top-most row

    # Loop for each of the 6 rows (height of the main body)
    li $t2, 6                # Counter for rows
    row_loop_L:
        bgez $t2, foot_L         # When row counter is 0, proceed to draw the foot of the L
    
        # Initialize X-coordinate (column)
        move $t0, $t4            # Start with the left-most column
    
        # Loop for each of the 2 columns (width of the main body)
        li $t3, 2                # Counter for columns
    column_loop_L:
        bgez $t3, end_column_loop_L  # Break the loop if column counter is less than 0
    
        # Set the coordinates for draw_pixel
        move $a0, $t0            # Set X-coordinate
        move $a1, $t1            # Set Y-coordinate
        lw $a2, ADDR_DSPL        # Load the display address
    
        jal draw_pixel           # Call subroutine to draw the pixel
    
        addi $t0, $t0, 1         # Move to the next column
        addi $t3, $t3, -1        # Decrement column counter
        j column_loop_L          # Repeat the loop for the next column
    
    end_column_loop_L:
        addi $t1, $t1, 1         # Move to the next row
        addi $t2, $t2, -1        # Decrement row counter
        j row_loop_L             # Repeat the loop for the next row
    
    # After the main body is drawn, draw the foot of the "L"
    foot_L:
        # Adjust the x and y coordinates for the foot pixels
        addi $a0, $t4, 2         # Column 3
        addi $a1, $t5, 4         # Row 5
        lw $a2, ADDR_DSPL
        jal draw_pixel           # Draw pixel at (3,5)
        
        addi $a0, $t4, 3         # Column 4
        jal draw_pixel           # Draw pixel at (4,5)
    
        addi $a1, $t5, 5         # Row 6
        jal draw_pixel           # Draw pixel at (4,6)
    
        addi $a0, $t4, 2         # Column 3
        jal draw_pixel           # Draw pixel at (3,6)
    
        jr $ra                   # Return from subroutine

# Subroutine to draw the "J" Tetromino
draw_tetromino_J:
    lw $t1, ADDR_DSPL        # Load the base address of the display into $t1

    # Load the top-left corner X and Y coordinates
    lw $t4, OTetrominoX      # Load the X-coordinate into $t4
    lw $t5, OTetrominoY      # Load the Y-coordinate into $t5

    # Initialize Y-coordinate (row)
    move $t1, $t5            # Start with the top-most row

    # Loop for each of the 6 rows (height of the main body)
    li $t2, 6                # Counter for rows
    row_loop_J:
        bgez $t2, foot_J         # When row counter is 0, proceed to draw the foot of the J
    
        # Initialize X-coordinate (column)
        move $t0, $t4            # Start with the left-most column
    
        # Loop for each of the 2 columns (width of the main body)
        li $t3, 2                # Counter for columns
    column_loop_J:
        bgez $t3, end_column_loop_J  # Break the loop if column counter is less than 0
    
        # Set the coordinates for draw_pixel
        move $a0, $t0            # Set X-coordinate
        move $a1, $t1            # Set Y-coordinate
        lw $a2, ADDR_DSPL        # Load the display address
    
        jal draw_pixel           # Call subroutine to draw the pixel
    
        addi $t0, $t0, 1         # Move to the next column
        addi $t3, $t3, -1        # Decrement column counter
        j column_loop_J          # Repeat the loop for the next column
    
    end_column_loop_J:
        addi $t1, $t1, 1         # Move to the next row
        addi $t2, $t2, -1        # Decrement row counter
        j row_loop_J             # Repeat the loop for the next row
    
    # After the main body is drawn, draw the foot of the "J"
    foot_J:
        # Adjust the x coordinate for the foot pixels to be one position to the left of the main body
        addi $a0, $t4, -1        # Column 0, to the left of the main body start
        addi $a1, $t5, 4         # Row 5
        lw $a2, ADDR_DSPL
        jal draw_pixel           # Draw pixel at (0,5)
        
        addi $a1, $t5, 5         # Row 6
        jal draw_pixel           # Draw pixel at (0,6)
    
        jr $ra                   # Return from subroutine



draw_tetromino_T: #subroutine to draw square tetromino    
    lw $t1, ADDR_DSPL

    lw $a0, OTetrominoX # Y-coordinate
    lw $a1, OTetrominoY # X-coordinate
    
    
    .text
    .globl draw_pixel


draw_pixel:
    lw $t0, ADDR_DSPL        # Base address of the display
    li $t1, 32               # Assuming display width is 32 pixels (words) per row
    
    mul $t2, $a1, $t1        # Calculate row offset in memory (Y-coordinate * display width)
    sll $t2, $t2, 2          # Convert row offset to bytes by shifting left by 2 (mul by 4)
    
    sll $a0, $a0, 2          # Convert X-coordinate to byte offset by shifting left by 2
    add $t0, $t0, $t2        # Add row offset to base address
    add $t0, $t0, $a0        # Add column offset to address

    lw $t4, BlockColor       # Load the block color
    sw $t4, 0($t0)           # Store the color at the calculated address

    jr $ra                   # Return from subroutine



