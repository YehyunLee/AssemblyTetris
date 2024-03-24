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

    .text
	.globl main
	# .globl init_grid
    # .globl draw_pixel
    # .globl draw_tetromino_O
    # .globl draw_tetromino_L
    # .globl draw_tetromino_J
    # .globl draw_tetromino_T
    # .globl draw_tetromino_S
    # .globl draw_tetromino_Z
    # .globl draw_tetromino_I

##############################################################################
# Mutable Data
##############################################################################
# OTetrominoX: .word 4  # Sample X coordinate
# OTetrominoY: .word 4   # Sample Y coordinate
BlockColor: .word 0xff0000 #Block Color of tetrominoes for now
# BlockSize: .word 4  # 2 pixels by 2 bytes per pixel
# PIXEL: .word 2 # each pixel heigh and width
# Define an array to store tuples
tupleArray: .space 16       # Each tuple occupies 4 words, so 4 * 4 = 16 bytes
                            # Idea of tupleArray usuage: [(s2, s3, s4, s5), (s2, s3, s4, s5),...] list of tuples.
# Major variables:
    # lw $s0 for paint (sw)
    # li $s1 for paint counter (need this for general use)
    # li $s2 for what TETRO, ex) O, J, T, using int; refer to image.
    # li $s3 for what ANGLE ex) 0 is default, 1 is one 90 roration upto 3.
    # li $s4 OTetrominoX
    # li $s5 OTetrominoY
    # lw $s6, ADDR_DSPL
    # lw $s7, ADDR_KBRD


	# Run the Tetris game.
main:
    # CONSTANTS SAVED
    lw $s6, ADDR_DSPL
    lw $s7, ADDR_KBRD
    # Initialize the game
    jal init_grid
game_loop:
	# 1a. Check if key has been pressed
	li 		$v0, 32         # Load immediate: $v0 = 32 (code for read word from keyboard)
	li 		$a0, 1          # Load immediate: $a0 = 1 (number of words to read)
	syscall                   # Perform system call to read from keyboard
    move $t0, $s7               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load the first word from the keyboard
    beq $t8, 1, keyboard_input      # Branch to keyboard_input if the first word is equal to 1
    b game_loop                          # Branch back to main if the key is not pressed
    
    # 1b. Check which key has been pressed
    # Refer to function named "keyboard_input"
    
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b main


##############################################################################
# Function for Random
##############################################################################
# Pseudo-random number generator function
# ...

##############################################################################
# Function for Keyboard
##############################################################################
keyboard_input:
    lw $a0, 4($t0)                  # Load the second word from the keyboard into $a0
    beq $a0, 0x71, respond_to_Q     # Check if the key corresponding to ASCII code 0x71 (q) was 
    
    li $v0, 1                       # Load immediate: $v0 = 1 (code for print integer)
    syscall                         # Perform system call to print the value in $a0
    
    jal init_grid
    li $s4, 4
    li $s5, 0
    move $t0, $s0        # Load the base address of the display into $t0
    jal draw_tetromino_T_270

    # TODO
    # ...
    # If a0 is A WASD, ...
    b game_loop                          # Branch back to game loop

respond_to_Q:
    li $v0, 10                      # Load immediate: $v0 = 10 (code for exit)
    syscall                         # Perform system call to terminate the program gracefully


##############################################################################
# Function for rotate
##############################################################################
rotate: 
    # Check $s2 = 0
    beq $s2, $zero, draw_tetromino_O
    
    # Check $s2 = 1
    beq $s2, 1, check_s2_equals_1
    
    # Check $s2 = 2
    beq $s2, 2, check_s2_equals_2
    
    # Check $s2 = 3
    beq $s2, 3, check_s2_equals_3
    
    # Check $s2 = 4
    beq $s2, 4, check_s2_equals_4
    
    # Check $s2 = 5
    beq $s2, 5, check_s2_equals_5
    
    # Check $s2 = 6
    beq $s2, 6, check_s2_equals_6
    
    # Add any additional checks here
    j end_rotate # Jump to end if none of the above conditions are met
    
    check_s2_equals_1:
        # Check $s3 values under $s2 = 1
        beq $s3, $zero, draw_tetromino_I_90
        beq $s3, 1, draw_tetromino_I_180
        beq $s3, 2, draw_tetromino_I_270
        beq $s3, 3, draw_tetromino_I
    
    check_s2_equals_2:
        # Check $s3 values under $s2 = 2
        beq $s3, $zero, draw_tetromino_S_90
        beq $s3, 1, draw_tetromino_S_180
        beq $s3, 2, draw_tetromino_S_270
        beq $s3, 3, draw_tetromino_S
        j end_rotate # Jump to end if none of the above conditions are met
    
    check_s2_equals_3:
        # Check $s3 values under $s2 = 3
        beq $s3, $zero, draw_tetromino_Z_90
        beq $s3, 1, draw_tetromino_Z_180
        beq $s3, 2, draw_tetromino_Z_270
        beq $s3, 3, draw_tetromino_Z
        j end_rotate # Jump to end if none of the above conditions are met
    
    check_s2_equals_4:
        # Check $s3 values under $s2 = 4
        beq $s3, $zero, draw_tetromino_L_90
        beq $s3, 1, draw_tetromino_L_180
        beq $s3, 2, draw_tetromino_L_270
        beq $s3, 3, draw_tetromino_L
        j end_rotate # Jump to end if none of the above conditions are met\
    
    check_s2_equals_5:
        # Check $s3 values under $s2 = 5
        beq $s3, $zero, draw_tetromino_J_90
        beq $s3, 1, draw_tetromino_J_180
        beq $s3, 2, draw_tetromino_J_270
        beq $s3, 3, draw_tetromino_J
        j end_rotate # Jump to end if none of the above conditions are met
    
    check_s2_equals_6:
        # Check $s3 values under $s2 = 6
        beq $s3, $zero, draw_tetromino_T_90
        beq $s3, 1, draw_tetromino_T_180
        beq $s3, 2, draw_tetromino_T_270
        beq $s3, 3, draw_tetromino_T
        j end_rotate # Jump to end if none of the above conditions are met
end_rotate:
    jr $ra

##############################################################################
# Function for Init Grid
##############################################################################
init_grid:
    # CONSTANTS; load immediately
    li $t1, 0x808080        # $t1 = darkgrey
    li $t2, 0xC0C0C0        # $t2 = brightgrey
    
    # INIT BASE ADDRESS
    move $s0, $s6           # $s0 = base address for display
    li $s1, 0               # [For use of wall] counter to sub from t9
    
    # INIT LOOP COUNTER and PIXEL COLOUR
    li $t3, 0               # Loop COUNTER
    li $t4, 0               # Pixel COLOUR flag; 0 for Dark grey and 1 for Bright grey
paint_loop:
    # Choose colour based on Pixel COLOUR flag
    beq $t4, 0, paint_dark_grey   # If flag is 0, call function for painting dark grey
    sw $t2, 0($s0)          # If not, paint BRIGHT grey
    addi $t3, $t3, 1        # Increment loop counter: t3 += 1
    addi $s0, $s0, 4        # Move to next pixel
    addi $s1, $s1, 4        # [For later use]
    sw $t2, 0($s0)          # If not, paint BRIGHT grey
    
    li $t4, 0               # Next time, paint DARK grey
    j paint_loop_end        # b or j is used to jump to different branch
                            # Here this continues to the next pixel
paint_dark_grey:
    sw $t1, 0($s0)              # Paint dark grey
    addi $t3, $t3, 1            # Increment loop counter: t3 += 1
    addi $s0, $s0, 4            # Move to next pixel
    addi $s1, $s1, 4            # [For later use]
    sw $t1, 0($s0)              # Paint dark grey
    
    li $t4, 1                 # Set colour FLAG to 1; meaning next time BRIGHT grey
    j paint_loop_end
paint_loop_end:
    addi $t3, $t3, 1        # Increment loop counter: t3 += 1
    addi $s0, $s0, 4        # Move to next pixel
                            # (by offset 4, since each pixel takes 4 bytes)
    addi $s1, $s1, 4        # [For later use]
                            
    li $t5, 65536           # Load variable of 256 x 256
    
    # If $t3 % 64 == 0: set $t4 revert to either 1 or 0
    li $t6, 64          # Load immediate: Set $t6 to 64
    move $t8, $t3        # Save the value of $t3 to $t8 (temporary register)
    div $t8, $t6         # Divide $t8 by 64
    mfhi $t7             # Get the remainder (the result of modulo) from the division
    beqz $t7, is_multiple   # Branch if the remainder is zero (i.e., $t3 is a multiple of 256)
    j toggle_end        # Jump to the end of the toggling process
    is_multiple:
        # If multiple, toggle $t4 (0 to 1, or 1 to 0)
        beq $t4, $zero, set_t4_to_one   # If $t4 is 0, set it to 1
        li $t4, 0                       # If $t4 is 1, set it to 0
        j toggle_end        # Jump to the end of the toggling process
    set_t4_to_one:
        li $t4, 1           # Set $t4 to 1
    toggle_end:
        # Check if painted ALL pixels, if so then exit
        bne $t3, $t5, paint_loop

wall_initL:
    # INIT
    li $t8, 0x000000        # Black
    li $t1, 0               # Col counter
    li $t2, 0               # Row counter
    sub $s0, $s0, $s1       # Subtract to get initial offset
    li $s1, 0
    j left_wall
reset_rowL:
    li $t2, 0
    addi $t1, $t1, 1
    sub $s0, $s0, $s1       # Subtract to get initial offset
    li $s1, 0
    mul $t5, $t1, 4              # 4*col
    add $s0, $s0, $t5
    add $s1, $s1, $t5
left_wall:
    beq $t1, 6, wall_initR          # For loop
    beq $t2, 129, reset_rowL
    sw $t8, 0($s0)
    addi $t2, $t2, 1
    addi $s0, $s0, 128
    addi $s1, $s1, 128
    j left_wall
wall_initR:
    # INIT
    li $t1, 104             # Col counter
    li $t2, 0               # Row counter
    sub $s0, $s0, $s1       # Subtract to get initial offset
    li $s1, 0
    
    add $s0, $s0, $t1
    add $s1, $s1, $t1
    j right_wall
reset_rowR:
    li $t2, 0
    addi $t1, $t1, 4
    sub $s0, $s0, $s1       # Subtract to get initial offset
    li $s1, 0
    
    add $s0, $s0, $t1
    add $s1, $s1, $t1
right_wall:
    beq $t1, 128, wall_initB          # For loop
    beq $t2, 129, reset_rowR
    sw $t8, 0($s0)
    addi $t2, $t2, 1
    addi $s0, $s0, 128
    addi $s1, $s1, 128
    j right_wall

wall_initB:
    # INIT
    li $t1, 832               # Col counter
    li $t2, 0               # Row counter
    sub $s0, $s0, $s1       # Subtract to get initial offset
    li $s1, 0
    j bottom_wall
reset_rowB:
    li $t2, 0
    addi $t1, $t1, 1
    sub $s0, $s0, $s1       # Subtract to get initial offset
    li $s1, 0
    mul $t5, $t1, 4              # 4*col
    add $s0, $s0, $t5
    add $s1, $s1, $t5
bottom_wall:
    beq $t1, 864, exit_init_grid          # For loop
    beq $t2, 6, reset_rowB
    sw $t8, 0($s0)
    addi $t2, $t2, 1
    addi $s0, $s0, 128
    addi $s1, $s1, 128
    j bottom_wall
exit_init_grid:
    sub $s0, $s0, $s1       # Subtract to get initial offset
    li $s1, 0
    jr $ra                  # Return from subroutine

##############################################################################
# Function for Tetromino
##############################################################################
draw_tetromino_O:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopO:
    blt $t8, 4, continue_yO  # If Y loop counter < 8, continue
    j end_y_loopO            # Else, jump to the end of Y loop
continue_yO:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopO:
    blt $t7, 4, continue_xO  # If X loop counter < 2, continue
    j end_x_loopO            # Else, jump to the end of X loop
continue_xO:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopO                # Jump back to the start of the X loop
end_x_loopO:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopO                # Jump back to the start of the Y loop
end_y_loopO:
    jr $ra                  # Return from subroutine



draw_tetromino_I:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopI:
    blt $t8, 8, continue_yI  # If Y loop counter < 8, continue
    j end_y_loopI            # Else, jump to the end of Y loop
continue_yI:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopI:
    blt $t7, 2, continue_xI  # If X loop counter < 2, continue
    j end_x_loopI            # Else, jump to the end of X loop
continue_xI:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopI                # Jump back to the start of the X loop
end_x_loopI:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI                # Jump back to the start of the Y loop
end_y_loopI:
    jr $ra                  # Return from subroutine

draw_tetromino_I_90:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 1               # Label Tetromino_I for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 6
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopI_90:
    blt $t8, 2, continue_y_loopI_90  # If Y loop counter < 2, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_y_loopI_90:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopI_90:
    blt $t7, 8, continue_x_loopI_90  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x_loopI_90:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopI_90                # Jump back to the start of the X loop
end_x_loop:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI_90                # Jump back to the start of the Y loop
end_y_loop:
    jr $ra                  # Return from subroutine

draw_tetromino_I_180:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 1               # Label Tetromino_I for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 6
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopI_180:
    blt $t8, 8, continue_yloopI_180  # If Y loop counter < 2, continue
    j end_y_loop            # Else, jump to the end of Y loop
continue_yloopI_180:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopI_180:
    blt $t7, 2, continue_x_loopI_180  # If X loop counter < 2, continue
    j end_x_loop            # Else, jump to the end of X loop
continue_x_loopI_180:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopI_180                # Jump back to the start of the X loop
end_x_loopI_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI_180                # Jump back to the start of the Y loop
end_y_loopI_180:
    jr $ra                  # Return from subroutine
    
    
    
draw_tetromino_I_270:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 1               # Label Tetromino_I for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 6
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopI_270:
    blt $t8, 2, continue_yloopI_270  # If Y loop counter < 2, continue
    j end_y_loopI_270            # Else, jump to the end of Y loop
continue_yloopI_270:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopI_270:
    bgt $t7, -8, continue_xloopI_270  # If X loop counter < 2, continue
    j end_x_loopI_270            # Else, jump to the end of X loop
continue_xloopI_270:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    subi $t7, $t7, 1        # Increment X loop counter
    j x_loopI_270                # Jump back to the start of the X loop
end_x_loopI_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI_270                # Jump back to the start of the Y loop
end_y_loopI_270:
    jr $ra                  # Return from subroutine    
    

    
draw_tetromino_L:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopL:
    blt $t8, 6, continue_yL  # If Y loop counter < 6, continue
    j end_y_loopL            # Else, jump to the end of Y loop
continue_yL:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopL:
    blt $t7, 2, continue_xL  # If X loop counter < 2, continue
    j end_x_loopL            # Else, jump to the end of X loop
continue_xL:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopL                # Jump back to the start of the X loop
end_x_loopL:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopL                # Jump back to the start of the Y loop
end_y_loopL:
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


draw_tetromino_L_90:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 4               # Label Tetromino_L for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 4
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopL_90:
    blt $t8, 2, continue_y_loopL_90  # If Y loop counter < 6, continue
    j end_y_loopL_90            # Else, jump to the end of Y loop
continue_y_loopL_90:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopL_90:
    blt $t7, 6, continue_x_loopL_90  # If X loop counter < 2, continue
    j end_x_loopL_90            # Else, jump to the end of X loop
continue_x_loopL_90:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopL_90                # Jump back to the start of the X loop
end_x_loopL_90:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopL_90                # Jump back to the start of the Y loop
end_y_loopL_90:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 3                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 0                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    

    jr $ra                  # Return from subroutine

draw_tetromino_L_180:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 4               # Label Tetromino_L for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 4
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopL_180:
    blt $t8, 6, continue_y_loopL_180  # If Y loop counter < 6, continue
    j end_y_loopL_180            # Else, jump to the end of Y loop
continue_y_loopL_180:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopL_180:
    blt $t7, 2, continue_x_loopL_180  # If X loop counter < 2, continue
    j end_x_loopL_180            # Else, jump to the end of X loop
continue_x_loopL_180:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopL_180                # Jump back to the start of the X loop
end_x_loopL_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopL_180                # Jump back to the start of the Y loop
end_y_loopL_180:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 1                # Y offset foot
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


draw_tetromino_L_270:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 4               # Label Tetromino_L for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 1
    addi $t5, $t5, 4
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopL_270:
    blt $t8, 2, continue_y_loopL_270  # If Y loop counter < 2, continue
    j end_y_loopL_270            # Else, jump to the end of Y loop
continue_y_loopL_270:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopL_270:
    bgt $t7, -6, continue_x_loopL_270  # If X loop counter < 2, continue
    j end_x_loopL_270            # Else, jump to the end of X loop
continue_x_loopL_270:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    subi $t7, $t7, 1        # Increment X loop counter
    j x_loopL_270                # Jump back to the start of the X loop
end_x_loopL_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopL_270                # Jump back to the start of the Y loop
end_y_loopL_270:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, -1                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, -1                # X offset foot
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
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopJ:
    blt $t8, 6, continue_yJ  # If Y loop counter < 6, continue
    j end_y_loopJ            # Else, jump to the end of Y loop
continue_yJ:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopJ:
    blt $t7, 2, continue_xJ  # If X loop counter < 2, continue
    j end_x_loopJ            # Else, jump to the end of X loop
continue_xJ:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopJ                # Jump back to the start of the X loop
end_x_loopJ:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopJ                # Jump back to the start of the Y loop
end_y_loopJ:
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

draw_tetromino_J_90:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 5               # Label Tetromino_L for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 6
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopJ_90:
    blt $t8, 2, continue_y_loopJ_90  # If Y loop counter < 6, continue
    j end_y_loopJ_90            # Else, jump to the end of Y loop
continue_y_loopJ_90:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopJ_90:
    blt $t7, 6, continue_x_loopJ_90  # If X loop counter < 2, continue
    j end_x_loopJ_90            # Else, jump to the end of X loop
continue_x_loopJ_90:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopJ_90                # Jump back to the start of the X loop
end_x_loopJ_90:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopJ_90                # Jump back to the start of the Y loop
end_y_loopJ_90:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, -1                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 0                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    

    jr $ra                  # Return from subroutine
    

draw_tetromino_J_180:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 5               # Label Tetromino_L for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -2
    addi $t5, $t5, 4
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopJ_180:
    blt $t8, 6, continue_y_loopJ_180  # If Y loop counter < 6, continue
    j end_y_loopJ_180            # Else, jump to the end of Y loop
continue_y_loopJ_180:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopJ_180:
    blt $t7, 2, continue_x_loopJ_180  # If X loop counter < 2, continue
    j end_x_loopJ_180            # Else, jump to the end of X loop
continue_x_loopJ_180:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopJ_180               # Jump back to the start of the X loop
end_x_loopJ_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopJ_180                # Jump back to the start of the Y loop
end_y_loopJ_180:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 1                # Y offset foot
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


draw_tetromino_J_270:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 5               # Label Tetromino_L for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 1
    addi $t5, $t5, 2
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopJ_270:
    blt $t8, 2, continue_y_loopJ_270  # If Y loop counter < 2, continue
    j end_y_loopJ_270            # Else, jump to the end of Y loop
continue_y_loopJ_270:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopJ_270:
    bgt $t7, -6, continue_x_loopJ_270  # If X loop counter < 2, continue
    j end_x_loopJ_270            # Else, jump to the end of X loop
continue_x_loopJ_270:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    subi $t7, $t7, 1        # Increment X loop counter
    j x_loopJ_270                # Jump back to the start of the X loop
end_x_loopJ_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopJ_270                # Jump back to the start of the Y loop
end_y_loopJ_270:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 3                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, -1                # X offset foot
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
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopT:
    blt $t8, 2, continue_yT  # If Y loop counter < 6, continue
    j end_y_loopT            # Else, jump to the end of Y loop
continue_yT:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopT:
    blt $t7, 6, continue_xT  # If X loop counter < 2, continue
    j end_x_loopT            # Else, jump to the end of X loop
continue_xT:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopT                # Jump back to the start of the X loop
end_x_loopT:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopT                # Jump back to the start of the Y loop
end_y_loopT:
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
    
draw_tetromino_T_90:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 6               # Label Tetromino_L for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 2
    addi $t5, $t5, 0
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopT_90:
    blt $t8, 6, continue_y_loopT_90  # If Y loop counter < 6, continue
    j end_y_loopT_90            # Else, jump to the end of Y loop
continue_y_loopT_90:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopT_90:
    blt $t7, 2, continue_x_loopT_90  # If X loop counter < 2, continue
    j end_x_loopT_90            # Else, jump to the end of X loop
continue_x_loopT_90:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopT_90                # Jump back to the start of the X loop
end_x_loopT_90:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopT_90                # Jump back to the start of the Y loop
end_y_loopT_90:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 3                # Y offset foot
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
    
    

draw_tetromino_T_180:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 6               # Label Tetromino_L for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -4
    addi $t5, $t5, 4
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopT_180:
    blt $t8, 2, continue_y_loopT_180  # If Y loop counter < 6, continue
    j end_y_loopT_180            # Else, jump to the end of Y loop
continue_y_loopT_180:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopT_180:
    blt $t7, 6, continue_x_loopT_180  # If X loop counter < 2, continue
    j end_x_loopT_180           # Else, jump to the end of X loop
continue_x_loopT_180:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopT_180                # Jump back to the start of the X loop
end_x_loopT_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopT_180                # Jump back to the start of the Y loop
end_y_loopT_180:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, -1                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2               # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)

    jr $ra                  # Return from subroutine

draw_tetromino_T_270:
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 6               # Label Tetromino_L for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -2
    addi $t5, $t5, 0
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopT_270:
    blt $t8, 6, continue_y_loopT_270  # If Y loop counter < 6, continue
    j end_y_loopT_270            # Else, jump to the end of Y loop
continue_y_loopT_270:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopT_270:
    blt $t7, 2, continue_x_loopT_270  # If X loop counter < 2, continue
    j end_x_loopT_270            # Else, jump to the end of X loop
continue_x_loopT_270:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopT_270                # Jump back to the start of the X loop
end_x_loopT_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopT_270               # Jump back to the start of the Y loop
end_y_loopT_270:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
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
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopS:
    blt $t8, 2, continue_yS  # If Y loop counter < 8, continue
    j end_y_loopS            # Else, jump to the end of Y loop
continue_yS:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopS:
    blt $t7, 4, continue_xS  # If X loop counter < 2, continue
    j end_x_loopS            # Else, jump to the end of X loop
continue_xS:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopS                # Jump back to the start of the X loop
end_x_loopS:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopS                # Jump back to the start of the Y loop
end_y_loopS:
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

draw_tetromino_S_90: #subroutine to draw square tetromino
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 2               # Label Tetromino_S for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -2
    addi $t5, $t5, 2
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopS_90:
    blt $t8, 4, continue_y_loopS_90  # If Y loop counter < 8, continue
    j end_y_loopS_90            # Else, jump to the end of Y loop
continue_y_loopS_90:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopS_90:
    blt $t7, 2, continue_x_loopS_90  # If X loop counter < 2, continue
    j end_x_loopS_90            # Else, jump to the end of X loop
continue_x_loopS_90:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopS_90                # Jump back to the start of the X loop
end_x_loopS_90:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopS_90                # Jump back to the start of the Y loop
end_y_loopS_90:
    li $t8, 2                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, 256($t8)
    sw $t6, 260($t8)
    sw $t6, 384($t8)
    sw $t6, 388($t8)
    jr $ra                  # Return from subroutine

draw_tetromino_S_180: #subroutine to draw square tetromino
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 2               # Label Tetromino_S for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -6
    addi $t5, $t5, 0
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopS_180:
    blt $t8, 2, continue_y_loopS_180  # If Y loop counter < 8, continue
    j end_y_loopS_180            # Else, jump to the end of Y loop
continue_y_loopS_180:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopS_180:
    blt $t7, 4, continue_x_loopS_180  # If X loop counter < 2, continue
    j end_x_loopS_180            # Else, jump to the end of X loop
continue_x_loopS_180:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopS_180                # Jump back to the start of the X loop
end_x_loopS_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopS_180                # Jump back to the start of the Y loop
end_y_loopS_180:
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


draw_tetromino_S_270: #subroutine to draw square tetromino
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 2               # Label Tetromino_S for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -3
    addi $t5, $t5, 0
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopS_270:
    blt $t8, 4, continue_y_loopS_270  # If Y loop counter < 8, continue
    j end_y_loopS_270            # Else, jump to the end of Y loop
continue_y_loopS_270:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopS_270:
    blt $t7, 2, continue_x_loopS_270  # If X loop counter < 2, continue
    j end_x_loopS_270            # Else, jump to the end of X loop
continue_x_loopS_270:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopS_270                # Jump back to the start of the X loop
end_x_loopS_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopS_270                # Jump back to the start of the Y loop
end_y_loopS_270:
    li $t8, 0                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, -1                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, 0($t8)
    sw $t6, -4($t8)
    sw $t6, 128($t8)
    sw $t6, 124($t8)
    sw $t6, -128($t8)
    sw $t6, -132($t8)
    sw $t6, -256($t8)
    sw $t6, -260($t8)
    
    jr $ra                  # Return from subroutine



draw_tetromino_Z: #subroutine to draw square tetromino
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopZ:
    blt $t8, 2, continue_yZ  # If Y loop counter < 8, continue
    j end_y_loopZ            # Else, jump to the end of Y loop
continue_yZ:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopZ:
    blt $t7, 4, continue_xZ  # If X loop counter < 2, continue
    j end_x_loopZ            # Else, jump to the end of X loop
continue_xZ:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopZ                # Jump back to the start of the X loop
end_x_loopZ:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopZ                # Jump back to the start of the Y loop
end_y_loopZ:
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


draw_tetromino_Z_90: #subroutine to draw square tetromino
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 4
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopZ_90:
    blt $t8, 4, continue_y_loopZ_90  # If Y loop counter < 8, continue
    j end_y_loopZ_90            # Else, jump to the end of Y loop
continue_y_loopZ_90:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopZ_90:
    blt $t7, 2, continue_x_loopZ_90  # If X loop counter < 2, continue
    j end_x_loopZ_90            # Else, jump to the end of X loop
continue_x_loopZ_90:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopZ_90               # Jump back to the start of the X loop
end_x_loopZ_90:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopZ_90                # Jump back to the start of the Y loop
end_y_loopZ_90:
    li $t8, 0                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, ($t8)
    sw $t6, 4($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    sw $t6, -256($t8)
    sw $t6, -252($t8)
    jr $ra                  # Return from subroutine


draw_tetromino_Z_180: #subroutine to draw square tetromino
   move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    

    addi $t4, $t4, -4
    addi $t5, $t5, 2
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopZ_180:
    blt $t8, 2, continue_y_loopZ_180  # If Y loop counter < 8, continue
    j end_y_loopZ_180            # Else, jump to the end of Y loop
continue_y_loopZ_180:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopZ_180:
    blt $t7, 4, continue_x_loopZ_180  # If X loop counter < 2, continue
    j end_x_loopZ_180            # Else, jump to the end of X loop
continue_x_loopZ_180:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopZ_180                # Jump back to the start of the X loop
end_x_loopZ_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopZ_180                # Jump back to the start of the Y loop
end_y_loopZ_180:
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
    
    
draw_tetromino_Z_270: #subroutine to draw square tetromino
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -2
    addi $t5, $t5, -2
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopZ_270:
    blt $t8, 4, continue_y_loopZ_270  # If Y loop counter < 8, continue
    j end_y_loopZ_270            # Else, jump to the end of Y loop
continue_y_loopZ_270:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopZ_270:
    blt $t7, 2, continue_x_loopZ_270  # If X loop counter < 2, continue
    j end_x_loopZ_270            # Else, jump to the end of X loop
continue_x_loopZ_270:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopZ_270                # Jump back to the start of the X loop
end_x_loopZ_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopZ_270                # Jump back to the start of the Y loop
end_y_loopZ_270:
    li $t8, 0                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    sw $t6, ($t8)
    sw $t6, 4($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    sw $t6, -256($t8)
    sw $t6, -252($t8)
    jr $ra                  # Return from subroutine