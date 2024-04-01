    .data
Random_seed: .word 1 #Random seed to generate tetrominoes
Random_multiplier: .word 4721
savedRA: .word 0 # Used to save return address before getting overwritten


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
BlockColor: .word 0x363959  #Block Color of tetrominoes for now
BorderColor: .word 0xc7d6d8 #Border Color of the game for now
# BlockSize: .word 4  # 2 pixels by 2 bytes per pixel
# PIXEL: .word 2 # each pixel heigh and width
Red_color: .word 0xff0000
NumTetrominos: .word 0xfff000 #Block Color of tetrominoes for now
DarkGrey: .word 0x808080 #Background color
BrightGrey: .word 0xC0C0C0 # Background color





# Major variables:
    # lw $s0 for paint (sw)
    # li $s1 for paint counter (need this for general use)
    # li $s2 for what TETRO, ex) O, J, T, using int; refer to image.
    # li $s3 for what ANGLE ex) 0 is default, 1 is one 90 roration upto 3.
    # li $s4 OTetrominoX
    # li $s5 OTetrominoY
    # lw $s6, ADDR_DSPL
    # lw $s7, ADDR_KBRD
    # a3 for collision

	# Run the Tetris game.
main:
    # CONSTANTS SAVED
    lw $s6, ADDR_DSPL
    lw $s7, ADDR_KBRD
    # Store the value 0 into the memory location represented by NumTetrominos
    li $t0, 0            # Load the value 0 into a temporary register ($t0)
    la $t1, NumTetrominos   # Load the address of NumTetrominos into another register ($t1)
    sw $t0, 0($t1)       # Store the value in $t0 into the memory location pointed to by $t1

    # Initialize the game
    # jal init_grid
    
    # Using stack as if list of tuples:
    # Define an array to store tuples
    # Assuming each tuple (Tetromino) occupies 4 words (4 * 4 bytes = 16 bytes)
                            # Idea of tupleArray usuage: [(s2, s3, s4, s5), (s2, s3, s4, s5),...] list of tuples.
    # Allocate space on the stack to store additional variables
    addi $sp, $sp, -8000      # Adjust stack pointer to allocate 4 words (16 bytes) for additional variables
game_loop:



new_tetromino:
    li $a3, 0  # Reset for collision code
    jal load_savedT
create_tetromino:
    lw $t0, Random_seed
    addi $t0, $t0, 1
    la $t1, Random_seed   # Load the address of Random_seed into another register ($t1)
    sw $t0, 0($t1)       # Store the value

    # Initialize PRNG with a seed
    # li $a1, 12345          # Seed value for PRNG
    lw $a1, Random_seed          # Seed value for PRNG
    li $v0, 40             # Syscall for initializing the PRNG
    syscall

    # Generate a pseudorandom number for $t2
    li $a0, 0              # argument
    li $v0, 41             # Syscall for getting a pseudorandom number
    syscall
    move $t2, $a0          # Move the generated number into $t2
    andi $t2, $t2, 7       # Ensure $t2's range is within 0-7

    # Generate a pseudorandom number for $t3
    li $a0, 0              # ID of the PRNG
    li $v0, 41             # Syscall for getting another pseudorandom number
    syscall
    move $t3, $a0          # Move the generated number into $t3
    andi $t3, $t3, 3       # Ensure $t3's range is within 0-3 (not 0-7 as in your code)

    li $t4, 14                # Value for s4
    li $t5, 0                 # Value for s5
    # Store values onto the stack
    # li $t2, 1  # For testing purpose
    sw $t2, 0($t6) 
    sw $t3, 4($t6)
    sw $t4, 8($t6)         
    sw $t5, 12($t6)    

    lw $t0, NumTetrominos
    addi $t0, $t0, 1
    la $t1, NumTetrominos   # Load the address of NumTetrominos into another register ($t1)
    sw $t0, 0($t1)       # Store the value in $t0 into the memory location pointedskip_int_stack to by $t1

    j load_saved
    returned_create_tetromino:
        beq $a3, 4, new_tetromino
        jal wait_keyboard

    #5. Go back to 1
    b game_loop                          # Branch back to main if the key is not pressed


wait_keyboard:
	# 1a. Check if key has been pressed
	li 		$v0, 32         # Load immediate: $v0 = 32 (code for read word from keyboard)
	li 		$a0, 1          # Load immediate: $a0 = 1 (number of words to read)
	syscall                   # Perform system call to read from keyboard
    move $t0, $s7               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load the first word from the keyboard
    beq $t8, 1, keyboard_input      # Branch to keyboard_input if the first word is equal to 1

    # 1b. Check which key has been pressed
    # Refer to function named "keyboard_input"
    
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    # Speed calc.
    lw $t1, NumTetrominos
    mul $t2 $t1, 5
    li $t1, 1000
    sub $a0, $t1, $t2 # 1000 ms = 1 s
    # Wait x seconds
    li  $v0, 32
    syscall
    
    # Call for change
    li $a0, 115
    j mutation
    # j wait_keyboard


re_pause:
    lw $a0, 4($t0)                  # Load the second word from the keyboard into $a0
    beq $a0, 0x71, respond_to_Q     # Check if the key corresponding to ASCII code 0x71 (q) was typed
    beq $a0, 0x70, wait_keyboard
pause_game:
    # Retrieve values for the current tetromino from the stack
    li $t4, 1
    li $t5, 2

    # Move loaded values to respective registers
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5

    # Call draw_tetromino with $a0 set to 0 to draw the current tetromino
    li $a0, 0                   # Set $a0 to 0 to draw the current shape
    move $t0, $s0        # Load the base address of the display into $t0
    li $v1, 0xFF0000
    sw $v1, BlockColor
    jal draw_tetromino_P
    
    li $t4, 1
    li $t5, 1
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5    
    li $v1, 0xc7d6d8
    sw $v1, BlockColor
    jal draw_tetromino_OP
    
    li $v1, 0xFF0000
    sw $v1, BlockColor
    li $t4, 2
    li $t5, 4
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    li $t4, 1
    li $t5, 3
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    
    li $t4, 2
    li $t5, 8
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    
    li $t4, 2
    li $t5, 6
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    li $t4, 3
    li $t5, 5
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    
    # Retrieve values for the current tetromino from the stack
    li $t4, 4
    li $t5, 6
    # Move loaded values to respective registers
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    # Retrieve values for the current tetromino from the stack
    li $t4, 3
    li $t5, 7
    # Move loaded values to respective registers
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    
    li $t4, 1
    li $t5, 9
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    li $t4, 1
    li $t5, 9
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5
    jal draw_tetromino_OP
    
        
repeat_pause_game:
	# 1a. Check if key has been pressed
	li 		$v0, 32         # Load immediate: $v0 = 32 (code for read word from keyboard)
	li 		$a0, 1          # Load immediate: $a0 = 1 (number of words to read)
	syscall                   # Perform system call to read from keyboard
    move $t0, $s7               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load the first word from the keyboard
    beq $t8, 1, re_pause
    j repeat_pause_game

draw_tetromino_P:
    sw $ra, savedRA  # Save $ra to the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    
    lw $t6, BlockColor      # Load the block color
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopP:
    blt $t8, 8, continue_yP  # If Y loop counter < 8, continue
    j end_y_loopP            # Else, jump to the end of Y loop
continue_yP:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopP:
    blt $t7, 2, continue_xP  # If X loop counter < 2, continue
    j end_x_loopP            # Else, jump to the end of X loop
continue_xP:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    sw $t6, 0($t2)          # Store the block color at the calculated address
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopP                # Jump back to the start of the X loop
end_x_loopP:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopP                # Jump back to the start of the Y loop
end_y_loopP:
    lw $ra, savedRA  # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    
draw_tetromino_OP:
        sw $ra, savedRA  # Save $ra to the global variable
        move $t4, $s4     # Load the X-coordinate
        move $t5, $s5     # Load the Y-coordinate
        lw $t6, BlockColor      # Load the block color
        
        # Calculate the initial offset
        li $t1, 32              # Width of the display in pixels
        mul $t2, $t5, $t1       # Y offset in terms of display width
        add $t9, $t4, $t2       # Combine X and Y offsets
        
        li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
        y_loopOP:
            blt $t8, 2, continue_yOP  # If Y loop counter < 8, continue
            j end_y_loopOP            # Else, jump to the end of Y loop
        continue_yOP:
            li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
        x_loopOP:
            blt $t7, 2, continue_xOP  # If X loop counter < 2, continue
            j end_x_loopOP            # Else, jump to the end of X loop
        continue_xOP:
            # Calculate the offset for each pixel
            mul $t3, $t8, $t1       # Y offset for the current row
            add $t2, $t7, $t9       # Current X offset including base X and Y offsets
            add $t2, $t2, $t3       # Add current Y offset
            li $t3, 4               # Bytes per pixel
            mul $t2, $t2, $t3       # Convert to byte offset
            add $t2, $t0, $t2       # Add to the base address
            lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
            sw $t6, 0($t2)          # Store the block color at the calculated address
            addi $t7, $t7, 1        # Increment X loop counter
            j x_loopOP                # Jump back to the start of the X loop
        end_x_loopOP:
            addi $t8, $t8, 1        # Increment Y loop counter
            j y_loopOP                # Jump back to the start of the Y loop
        end_y_loopOP:
            lw $ra, savedRA  # Restore $ra from the global variable
            jr $ra                  # Return from subroutine
##################################################################################################







# GET NEW INDEX
load_savedT:
    # Iterate through the stack and load tetromino information
    li $a2, 0                   # Initialize index counter to 0
load_loopT:
    # Calculate the offset for the current index
    mul $t6, $a2, 16            # Each tetromino information occupies 4 words (16 bytes)
    add $t6, $t6, $sp           # Calculate the stack address for the current index

    # Retrieve values for the current tetromino from the stack
    lw $t2, 0($t6)              # Load value for s2
    lw $t3, 4($t6)              # Load value for s3
    lw $t4, 8($t6)              # Load value for s4
    lw $t5, 12($t6)             # Load value for s5

    # Move loaded values to respective registers
    move $s2, $t2               # s2 = loaded value for s2
    move $s3, $t3               # s3 = loaded value for s3
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5

    # Check if there are more tetrominos to load
    lw $t1, NumTetrominos
    beq $a2, $t1, exit_load_savedT
    ## I think we should call draw_tetromino here if there's tetromino's to draw
    # Increment the index counter
    addi $a2, $a2, 1            # Increment index counter

    # Continue or exit the program
    b load_loopT                 # Branch back to the game loop
exit_load_savedT:
    jr $ra                      # Return from subroutine

# LOAD CURRENT TETROMINOES
load_saved:
    jal init_grid               # Initialize the grid if needed

    # Iterate through the stack and load tetromino information
    li $a2, 0                   # Initialize index counter to 0
load_loop:
    # Calculate the offset for the current index
    mul $t6, $a2, 16            # Each tetromino information occupies 4 words (16 bytes)
    add $t6, $t6, $sp           # Calculate the stack address for the current index

    # Retrieve values for the current tetromino from the stack
    lw $t2, 0($t6)              # Load value for s2
    lw $t3, 4($t6)              # Load value for s3
    lw $t4, 8($t6)              # Load value for s4
    lw $t5, 12($t6)             # Load value for s5

    # Move loaded values to respective registers
    move $s2, $t2               # s2 = loaded value for s2
    move $s3, $t3               # s3 = loaded value for s3
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5

    # Check if there are more tetrominos to load
    lw $t1, NumTetrominos
    beq $a2, $t1, load_saved_exit

    # Call draw_tetromino with $a0 set to 0 to draw the current tetromino
    li $a0, 0                   # Set $a0 to 0 to draw the current shape
    jal draw_tetromino
    j row_clear
    completed_row_clear:
    
    
    
    
    # Increment the index counter
    addi $a2, $a2, 1            # Increment index counter

    # Continue or exit the program
    b load_loop                 # Branch back to the game loop
load_saved_exit:
    j returned_create_tetromino









# Row Clear
###############################################################
row_clear:
    # TODO: 1) Detect any row clear
    # 2) Clear that row
    # 3) Save, calc., move every pixel down
    move $t0, $s6  # Base address
    li $t1, 24          # row = 25 row 
    li $t2, 24         # start_column = 24
    li $t3, 100       # end_column = 100
    li $t9, 27
    #$t4  start_column each row
    #$t5 end_column each row
    #$t6 for actual pixel number
    #$v0 current pixel color
    #$v1 background color1 or 2
row_loop:
    # blt $t1, $zero, end_loop  # if row <= 0, exit loop

    # Corrected calculation for start and end indices
    mul $t4, $t1, 32  # row * 32
    add $t4, $t4, $t2  # Corrected to add start_column

    mul $t5, $t1, 32  # row * 32
    add $t5, $t5, $t3  # Corrected to add end_column

column_loop:
    beq $t8, 0, update_row_shift
    bge $t4, $t5, update_row_shift  # Shift if not matching backgrounds

    sll $t6, $t4, 2  # Index to byte offset (times 4) 0 - 31 pixel * 4
    add $t6, $t0, $t6  # Calculate memory address
    lw $v0, 0($t6)     # Load current pixel color
    lw $v1, DarkGrey
    beq $v0, $v1, update_row_no_shift  # Check against first background color
    lw $v1, BrightGrey
    beq $v0, $v1, update_row_no_shift  # Check against second background color, skip if not matching
    j increment_index

increment_index:
    addi $t4, $t4, 1  # Increment index
    j column_loop

update_row_no_shift:
    addi $t1, $t1, -2  # Increment row without shifting
    j row_loop

update_row_shift: # so that it will move everything down
    lw $v0, Red_color
    # subi $t6, $t6, 168      # 244
    jal sub_row
    ## sw $t0, 0($t1)       # Store the value in $t0 into the memory location pointedskip_int_stack to by $t1
    # sw $v0, 0($t6)  # Red dot, testing purpose
    addi $t1, $t1, -2  # Increment row and then shift
    jal shift_rows_down
    j row_loop

end_loop:
   j completed_row_clear 

shift_rows_down:
    li $t8, 21
    add $t7, $zero, $t6              # Start with the initial pixel address

shift_loop:
    subi $t8, $t8, 1
    blez $t8, shift_end    # If $t7 has reached or passed $t0, end the loop
    lw $v1, 0($t7)             # Load the current pixel color
    # lw $v0, BrightGrey        # Load first background
    # bne $v1, $v0, check_second_bg_color   # Check against the first background color
    # addi $t7, $t7, 4           # Move to the next pixel address
    # j shift_loop
    
    beq $t9, 0, end_loop

check_second_bg_color:
    # lw $v0, DarkGrey        # Load first background	
    # bne $v1, $s1, move_pixel_down  # Check against the second background color
    # addi $t7, $t7, 4           # Move to the next pixel address
    # j shift_loop

move_pixel_down:
    lw $v0, -256($t7)          # Load pixel from one row above (assuming -128 correctly offsets by one row)
    sw $v0, 0($t7)             # Store it in the current pixel's position
    addi $t7, $t7, -4           # Move to the next pixel address
    j shift_loop

shift_end:
    subi $t9, $t9, 1
    jr $ra                     # Return from the subroutine


sub_row:
    bne $t8, 0, sub_168_init
    beq $t8, 0, sub_128
    return_row:
        jr $ra
sub_168_init:
    subi $t6, $t6, 168      # 244
    j return_row
sub_128:
    subi $t6, $t6, 128      # 244
    j return_row
###############################################################











# This use a3
collision_code:
    # Check for each color. If none match, jump to an error handler or return.
    li $v1, 0xFFFF00  # Yellow
    beq $a0, $v1, color_match
    li $v1, 0x0000FF  # Blue
    beq $a0, $v1, color_match
    li $v1, 0xFF0000  # Red
    beq $a0, $v1, color_match
    li $v1, 0x008000  # Green
    beq $a0, $v1, color_match
    li $v1, 0xFFA500  # Orange
    beq $a0, $v1, color_match
    li $v1, 0xFFC0CB  # Pink
    beq $a0, $v1, color_match
    li $v1, 0x800080  # Purple
    beq $a0, $v1, color_match
    lw $v1, BorderColor # Border Color
    beq $a0, $v1, color_match
    lw $v1, BorderColor # This is for the walls
    beq $a0, $v1, color_match
    move $v0, $a0 #Move to v0 to compare background color
    jr $ra  # If no collision is found return

color_match:
    # Color matched, now decide action based on $a3
    beq $a3, 0, handle_0
    beq $a3, 1, handle_1
    beq $a3, 2, handle_2
    beq $a3, 3, handle_3
    # If $a3 doesn't match expected values, jump to error handling
    beq $a3, 4, new_tetromino
    j game_loop
    # j load_saved
    # j respond_to_Q  # Change this to appropriate handling if no $a3 match

handle_0:
    li $a0, 100
    j mutation

handle_1:
    li $a0, 97
    j mutation

handle_2:
    li $a0, 128
    j mutation

handle_3:
    li $a0, 129
    j mutation


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
    beq $a0, 0x71, respond_to_Q     # Check if the key corresponding to ASCII code 0x71 (q) was typed
    beq $a0, 0x70, pause_game
    
    li $v0, 1                       # Load immediate: $v0 = 1 (code for print integer)
    syscall                         # Perform system call to print the value in $a0
    beq $v0, 1, mutation

respond_to_Q:
    li $v0, 10                      # Load immediate: $v0 = 10 (code for exit)
    syscall                         # Perform system call to terminate the program gracefully

# Function for Mutation and Load Saved
##############################################################################
mutation:
    move $t0, $s7               # $t0 = base address for keyboard

    jal load_savedT


    subi $t6, $t6, 16

    # Retrieve values for the current tetromino from the stack
    lw $t2, 0($t6)              # Load value for s2
    lw $t3, 4($t6)              # Load value for s3
    lw $t4, 8($t6)              # Load value for s4
    lw $t5, 12($t6)             # Load value for s5

    move $a2, $t6

    # Move loaded values to respective registers
    move $s2, $t2               # s2 = loaded value for s2
    move $s3, $t3               # s3 = loaded value for s3
    move $s4, $t4               # s4 = loaded value for s4
    move $s5, $t5               # s5 = loaded value for s5

    # We have now values for latest tetromino in $t2, $t3, $t4, $t5
    #################
    # if A:97, sub t4 with 1
    beq $a0, 97, sub_x_2
    # elif D:100, add t4 with 1
    beq $a0, 100, add_x_2
    # w 119
    beq $a0, 119, handle_rotation
    # S 115
    beq $a0, 115, add_y_2
    beq $a0, 128, sub_y_2  # ADDED FOR COLLISION EXIT
    beq $a0, 129, handle_revert_rotation  # ADDED FOR COLLISION EXIT
    
    j game_loop

# Handle a3: 0:subx2, 1:addx2, 2:addy2, 3:handle_rot
sub_x_2:
    subi $t4, $t4, 2
    li $a3, 0
    j update
add_x_2:
    addi $t4, $t4, 2
    li $a3, 1
    j update
add_y_2:
    addi $t5, $t5, 2
    li $a3, 2
    j update
handle_rotation:
    addi $t3, $t3, 1
    andi $t3, $t3, 0x03  # $t3 = $t3 & 3 which is equivalent to $t3 mod 4
    li $a3, 3
    j update
sub_y_2:  # ADDED FOR COLLISION EXIT
    subi $t5, $t5, 2
    li $a3, 4
    j update
handle_revert_rotation:  # ADDED FOR COLLISION EXIT
    subi $t3, $t3, 1
    andi $t3, $t3, 0x03  # $t3 = $t3 & 3 which is equivalent to $t3 mod 4
    # li $a3, 4
    j update
update:
    # Store values onto the stack
    beq $v0, $v1, continue_playing
    sw $t2, 0($a2)              # Load value for s2
    sw $t3, 4($a2)              # Load value for s3
    sw $t4, 8($a2)              # Load value for s4
    sw $t5, 12($a2)             # Load value for s5
    j load_saved

continue_playing: 
    move $s2, $t2
    move $s3, $t3
    move $s4, $t4
    move $s5, $t5
    j load_saved
##############################################################################
# Function for Init Grid
##############################################################################
init_grid:
    # CONSTANTS; load immediately
    lw $t1, DarkGrey        # $t1 = darkgrey
    lw $t2, BrightGrey        # $t2 = brightgrey
    
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
    # li $t8, 0x000000        # Black
    lw $t8, BorderColor
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
# Function for drawing new tetoromino
##############################################################################
draw_tetromino:
    # This use a0 and a1.

    # To draw, current shape, let a_0 = 0.
    # To draw, next shape, let a_0 = 1.
    # AND handle mutation of sp stack outside this function depending on what we call.

    move $t0, $s0        # Load the base address of the display into $t0

    # Assuming that $a0 gets passed as 1 when "W" is pressed and "0" when not pressed
    # Check if $a0 = 0
    bne $a0, $zero, continue_draw_tetromino  # If $a0 is not 0, skip the decrementing part

    # Decrement $t3 by 1
    addi $t3, $t3, -1

    # Modulo $t3 by 4 to ensure it wraps around from 0 to 3
    andi $t3, $t3, 0x03  # $t3 = $t3 & 3 which is equivalent to $t3 mod 4

continue_draw_tetromino:
    # Check $s2 = 0
    li $v1, 0xffff00
    sw $v1, BlockColor
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
    j end_draw # Jump to end if none of the above conditions are met
    
    check_s2_equals_1:
        # Check $s3 values under $s2 = 1
        li $v1, 0x0000FF
        sw $v1, BlockColor
        beq $s3, $zero, draw_tetromino_I_90
        beq $s3, 1, draw_tetromino_I_180
        beq $s3, 2, draw_tetromino_I_270
        beq $s3, 3, draw_tetromino_I
        j end_draw # Jump to end if none of the above conditions are met
    
    check_s2_equals_2:
        # Check $s3 values under $s2 = 2
        li $v1, 0xFF0000
        sw $v1, BlockColor
        beq $s3, $zero, draw_tetromino_S_90
        beq $s3, 1, draw_tetromino_S_180
        beq $s3, 2, draw_tetromino_S_270
        beq $s3, 3, draw_tetromino_S
        j end_draw # Jump to end if none of the above conditions are met
    
    check_s2_equals_3:
        # Check $s3 values under $s2 = 3
        li $v1, 0x008000
        sw $v1, BlockColor
        beq $s3, $zero, draw_tetromino_Z_90
        beq $s3, 1, draw_tetromino_Z_180
        beq $s3, 2, draw_tetromino_Z_270
        beq $s3, 3, draw_tetromino_Z
        j end_draw # Jump to end if none of the above conditions are met
    
    check_s2_equals_4:
        # Check $s3 values under $s2 = 4
        li $v1, 0xffa500
        sw $v1, BlockColor
        beq $s3, $zero, draw_tetromino_L_90
        beq $s3, 1, draw_tetromino_L_180
        beq $s3, 2, draw_tetromino_L_270
        beq $s3, 3, draw_tetromino_L
        j end_draw # Jump to end if none of the above conditions are met\
    
    check_s2_equals_5:
        # Check $s3 values under $s2 = 5
        li $v1, 0xffc0cb
        sw $v1, BlockColor
        beq $s3, $zero, draw_tetromino_J_90
        beq $s3, 1, draw_tetromino_J_180
        beq $s3, 2, draw_tetromino_J_270
        beq $s3, 3, draw_tetromino_J
        j end_draw # Jump to end if none of the above conditions are met
    
    check_s2_equals_6:
        # Check $s3 values under $s2 = 6
        li $v1, 0x800080
        sw $v1, BlockColor
        beq $s3, $zero, draw_tetromino_T_90
        beq $s3, 1, draw_tetromino_T_180
        beq $s3, 2, draw_tetromino_T_270
        beq $s3, 3, draw_tetromino_T
        j end_draw # Jump to end if none of the above conditions are met
end_draw:
    jr $ra



##############################################################################
# Function for Tetromino
##############################################################################
draw_tetromino_O:
    sw $ra, savedRA  # Save $ra to the global variable
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
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code      # Check if there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopO                # Jump back to the start of the X loop
end_x_loopO:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopO                # Jump back to the start of the Y loop
end_y_loopO:
    lw $ra, savedRA  # Restore $ra from the global variable
    jr $ra                  # Return from subroutine



draw_tetromino_I:
    sw $ra, savedRA  # Save $ra to the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, -2
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
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code      # Check if there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopI                # Jump back to the start of the X loop
end_x_loopI:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI                # Jump back to the start of the Y loop
end_y_loopI:
    lw $ra, savedRA  # Restore $ra from the global variable
    jr $ra                  # Return from subroutine

draw_tetromino_I_90:
    sw $ra, savedRA  # Save $ra to the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    
    # Offset X and Y for rotation
    addi $t4, $t4, -2
    addi $t5, $t5, 0
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopI_90:
    blt $t8, 2, continue_yI_90  # If Y loop counter < 8, continue
    j end_y_loopI_90            # Else, jump to the end of Y loop
continue_yI_90:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopI_90:
    blt $t7, 8, continue_xI_90  # If X loop counter < 2, continue
    j end_x_loopI_90            # Else, jump to the end of X loop
continue_xI_90:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopI_90                # Jump back to the start of the X loop
end_x_loopI_90:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI_90                # Jump back to the start of the Y loop
end_y_loopI_90:
    lw $ra, savedRA  # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_I_180:
    sw $ra, savedRA  # Save $ra to the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 1               # Label Tetromino_I for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, -4
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopI_180:
    blt $t8, 8, continue_yloopI_180  # If Y loop counter < 2, continue
    j end_y_loopI_180            # Else, jump to the end of Y loop
continue_yloopI_180:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopI_180:
    blt $t7, 2, continue_x_loopI_180  # If X loop counter < 2, continue
    j end_x_loopI_180            # Else, jump to the end of X loop
continue_x_loopI_180:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopI_180                # Jump back to the start of the X loop
end_x_loopI_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI_180                # Jump back to the start of the Y loop
end_y_loopI_180:
    lw $ra, savedRA  # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    
    
    
draw_tetromino_I_270:
    sw $ra, savedRA  # Save $ra to the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 1               # Label Tetromino_I for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 3
    addi $t5, $t5, 0
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    subi $t7, $t7, 1        # Increment X loop counter
    j x_loopI_270                # Jump back to the start of the X loop
end_x_loopI_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopI_270                # Jump back to the start of the Y loop
end_y_loopI_270:
    lw $ra, savedRA  # Restore $ra from the global variable
    jr $ra                  # Return from subroutine    
    

    
draw_tetromino_L:
    sw $ra, savedRA  # Save $ra to the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 4               # Label Tetromino_L for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 0
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopL:
    blt $t8, 6, continue_y_loopL  # If Y loop counter < 6, continue
    j end_y_loopL            # Else, jump to the end of Y loop
continue_y_loopL:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopL:
    blt $t7, 2, continue_x_loopL  # If X loop counter < 2, continue
    j end_x_loopL            # Else, jump to the end of X loop
continue_x_loopL:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offsetw
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code
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
   
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_L_90:
    sw $ra, savedRA  # Save $ra to the global variable
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
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine

draw_tetromino_L_180:
    sw $ra, savedRA         # Restore $ra from the global variable
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_L_270:
    sw $ra, savedRA         # Restore $ra from the global variable
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_J:
    sw $ra, savedRA     # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 5               # Label Tetromino_L for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 2
    addi $t5, $t5, 0
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopJ:
    blt $t8, 6, continue_y_loopJ  # If Y loop counter < 6, continue
    j end_y_loopJ            # Else, jump to the end of Y loop
continue_y_loopJ:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopJ:
    blt $t7, 2, continue_x_loopJ  # If X loop counter < 2, continue
    j end_x_loopJ            # Else, jump to the end of X loop
continue_x_loopJ:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopJ                # Jump back to the start of the X loop
end_x_loopJ:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopJ                # Jump back to the start of the Y loop
end_y_loopJ:
    # Draw the foot of the L
    # Set the Y position for the foot; it's one unit below the last row of the main body
    li $t8, 4                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, -1                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, -4($t8)
    sw $t6, 128($t8)
    sw $t6, 124($t8)
    
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine

draw_tetromino_J_90:
    sw $ra, savedRA         # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 5               # Label Tetromino_L for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 4
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    lw $ra, savedRA         # Restore $ra from the global variable
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    

draw_tetromino_J_180:
    sw $ra, savedRA         # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 5               # Label Tetromino_L for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 2
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_J_270:
    sw $ra, savedRA         # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 5               # Label Tetromino_L for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 3
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code      # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine



draw_tetromino_T: #subroutine to draw square tetromino   
    sw $ra, savedRA         # Restore $ra from the global variable
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    
draw_tetromino_T_90:
    lw $ra, savedRA         # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 6               # Label Tetromino_L for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 2
    addi $t5, $t5, 2
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    
    

draw_tetromino_T_180:
    sw $ra, savedRA         # Restore $ra from the global variable
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    

draw_tetromino_T_270:
    sw $ra, savedRA         # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 6               # Label Tetromino_L for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -2
    addi $t5, $t5, -2
    
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
    li $t3, 4               # Bytes per pixelS_9
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    
    
draw_tetromino_S: #subroutine to draw square tetromino
    sw $ra, savedRA         # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 2
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopS:
    blt $t8, 2, continue_y_loopS  # If Y loop counter < 8, continue
    j end_y_loopS            # Else, jump to the end of Y loop
continue_y_loopS:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopS:
    blt $t7, 4, continue_x_loopS  # If X loop counter < 2, continue
    j end_x_loopS            # Else, jump to the end of X loop
continue_x_loopS:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopS               # Jump back to the start of the X loop
end_x_loopS:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopS                # Jump back to the start of the Y loop
end_y_loopS:
    li $t8, -2                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 8($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 12($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 132($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 136($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 140($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 8($t8)
    sw $t6, 12($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, 136($t8)
    sw $t6, 140($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine



draw_tetromino_S_90: #subroutine to draw square tetromino
    sw $ra, savedRA         # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 2               # Label Tetromino_S for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 2
    addi $t5, $t5, 0
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 132($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 256($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 260($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 384($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 388($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, 256($t8)
    sw $t6, 260($t8)
    sw $t6, 384($t8)
    sw $t6, 388($t8)
    lw $ra, savedRA         # Restore $ra from the global variable
    jr $ra                  # Return from subroutine

draw_tetromino_S_180: #subroutine to draw square tetromino
    sw $ra, savedRA     # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 2               # Label Tetromino_S for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 2
    addi $t5, $t5, 2
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
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
    li $t2, -2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 8($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 12($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -120($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -116($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 8($t8)
    sw $t6, 12($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    sw $t6, -120($t8)
    sw $t6, -116($t8)
    lw $ra, savedRA     # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_S_270: #subroutine to draw square tetromino
    sw $ra, savedRA     # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 2               # Label Tetromino_S for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 2
    addi $t5, $t5, 2
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0   
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    lw $a0, -4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -132($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -256($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -260($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, -4($t8)
    sw $t6, 128($t8)
    sw $t6, 124($t8)
    sw $t6, -128($t8)
    sw $t6, -132($t8)
    sw $t6, -256($t8)
    sw $t6, -260($t8)
    lw $ra, savedRA     # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_Z: #subroutine to draw square tetromino
    sw $ra, savedRA     # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, -2
    addi $t5, $t5, -2
    
    # Calculate the initial offset
    li $t1, 32              # Width of the display in pixels
    mul $t2, $t5, $t1       # Y offset in terms of display width
    add $t9, $t4, $t2       # Combine X and Y offsets
    
    li $t8, 0               # Initialize Y loop counter (0 to 7 for the I Tetromino height)
y_loopZ:
    blt $t8, 2, continue_y_loopZ  # If Y loop counter < 8, continue
    j end_y_loopZ            # Else, jump to the end of Y loop
continue_y_loopZ:
    li $t7, 0               # Re-initialize X loop counter (0 to 1 for the I Tetromino width)
x_loopZ:
    blt $t7, 4, continue_x_loopZ  # If X loop counter < 2, continue
    j end_x_loopZ            # Else, jump to the end of X loop
continue_x_loopZ:
    # Calculate the offset for each pixel
    mul $t3, $t8, $t1       # Y offset for the current row
    add $t2, $t7, $t9       # Current X offset including base X and Y offsets
    add $t2, $t2, $t3       # Add current Y offset
    li $t3, 4               # Bytes per pixel
    mul $t2, $t2, $t3       # Convert to byte offset
    add $t2, $t0, $t2       # Add to the base address
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0    
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopZ               # Jump back to the start of the X loop
end_x_loopZ:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopZ                # Jump back to the start of the Y loop
end_y_loopZ:
    li $t8, 2                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 8($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 12($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 132($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 136($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 140($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 8($t8)
    sw $t6, 12($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, 136($t8)
    sw $t6, 140($t8)
    lw $ra, savedRA     # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_Z_90: #subroutine to draw square tetromino
    sw $ra, savedRA     # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 1               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
    addi $t5, $t5, 0
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    
    jal collision_code  # If color matches, there's collision
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
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 132($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -256($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -252($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    
    
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    sw $t6, -256($t8)
    sw $t6, -252($t8)
    lw $ra, savedRA     # Restore $ra from the global variable
    jr $ra                  # Return from subroutine


draw_tetromino_Z_180: #subroutine to draw square tetromino
    sw $ra, savedRA     # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 2               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    

    addi $t4, $t4, -2
    addi $t5, $t5, 0
    
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopZ_180                # Jump back to the start of the X loop
end_x_loopZ_180:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopZ_180                # Jump back to the start of the Y loop
end_y_loopZ_180:
    li $t8, 7                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, 2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 8($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 12($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -120($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -116($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision

    sw $t6, -640($t8)
    sw $t6, -636($t8)
    sw $t6, -632($t8)
    sw $t6, -628($t8)
    sw $t6, -512($t8)
    sw $t6, -508($t8)
    sw $t6, -504($t8)
    sw $t6, -500($t8)
    lw $ra, savedRA     # Restore $ra from the global variable
    jr $ra                  # Return from subroutine
    
    
draw_tetromino_Z_270: #subroutine to draw square tetromino
    sw $ra, savedRA     # Restore $ra from the global variable
    move $t4, $s4     # Load the X-coordinate
    move $t5, $s5     # Load the Y-coordinate
    lw $t6, BlockColor      # Load the block color
    li $s2, 3               # Label Tetromino_S for identification
    li $s3, 3               # Rotation: 0 (default), 1 (90), 2 (180), 3 (270)
    
    # Offset X and Y for rotation
    addi $t4, $t4, 0
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
    
    lw $a0, 0($t2)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t2)          # Store the block color at the calculated address
    
    addi $t7, $t7, 1        # Increment X loop counter
    j x_loopZ_270                # Jump back to the start of the X loop
end_x_loopZ_270:
    addi $t8, $t8, 1        # Increment Y loop counter
    j y_loopZ_270                # Jump back to the start of the Y loop
end_y_loopZ_270:
    li $t8, 4                # Y offset foot
    add $t8, $t5, $t8        # Add from Y = Y + initial position
    mult $t8, $t8, 32        # Get actual Y offset (row = 32)
    li $t2, -2                # X offset foot
    add $t2, $t2, $t4        # Add from X = X + initial position
    add $t8, $t2, $t8        # Actual coordinate = x + y
    mult $t8, $t8, 4         # Convert to byte offset
    add $t8, $t0, $t8        # Add to the base address
    
    lw $a0, 0($t8)          # Load the current color at the calculated address into $a0
    
    jal collision_code  # If color matches, there's collision
    lw $a0, 4($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, 132($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -128($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -124($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -256($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    lw $a0, -252($t8)          # Load the current color at the calculated address into $a0
    jal collision_code  # If color matches, there's collision
    sw $t6, 0($t8)
    sw $t6, 4($t8)
    sw $t6, 128($t8)
    sw $t6, 132($t8)
    sw $t6, -128($t8)
    sw $t6, -124($t8)
    sw $t6, -256($t8)
    sw $t6, -252($t8)
    lw $ra, savedRA     # Restore $ra from the global variable
    jr $ra                  # Return from subroutine