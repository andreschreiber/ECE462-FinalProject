.data

asize1:  .word    6,  6,  2, 2    #i, j, k, l
frame1:  .word    0,  0,  0,  0, 0, 0,
         .word    0,  2,  2,  0, 0, 0,
		 .word    0,  2,  2,  0, 0, 0,
         .word    0,  0,  0,  0, 0, 0,
         .word    0,  0,  0,  0, 0, 0,
		 .word    0,  0,  0,  0, 0, 0
window1: .word    2, 2,
         .word    2, 2

asize2:  .word    6,  6,  2, 2    #i, j, k, l
frame2:  .word    0,  0,  0,  0, 0, 0,
         .word    0,  0,  0,  0, 0, 0,
		 .word    0,  0,  2,  2, 0, 0,
         .word    0,  0,  2,  2, 0, 0,
         .word    0,  0,  0,  0, 2, 2,
		 .word    0,  0,  0,  0, 2, 2
window2: .word    2, 2, 
         .word    2, 2
	
asize3:  .word    6,  6,  2, 2    #i, j, k, l
frame3:  .word    0,  0,  0,  0, 0, 0,
         .word    0,  0,  0,  0, 0, 0,
		 .word    0,  0,  0,  0, 0, 0,
         .word    0,  0,  0,  2, 2, 0,
         .word    0,  0,  0,  2, 2, 0,
		 .word    0,  0,  0,  0, 0, 0
window3: .word    2,  2, 
         .word    2,  2
		 
asize4:  .word    16, 16, 4, 4    #i, j, k, l
frame4:  .word    9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 7, 
         .word    9, 7, 7, 7, 7, 5, 6, 7, 8, 9, 10, 11, 6, 7, 7, 7, 
         .word    9, 7, 7, 7, 7, 3, 12, 14, 16, 18, 20, 6, 6, 7, 7, 7, 
         .word    9, 7, 7, 7, 7, 4, 18, 21, 24, 27, 30, 33, 6, 7, 7, 7, 
         .word    0, 7, 7, 7, 7, 5, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 
         .word    0, 5, 3, 4, 5, 6, 30, 35, 40, 45, 50, 55, 60, 65, 70,  75, 
         .word    0, 6, 12, 18, 24, 30, 36, 42, 48, 54, 60, 66, 72, 78, 84, 90, 
         .word    0, 4, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77, 84, 91, 98, 105, 
         .word    0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120, 
         .word    0, 9, 18, 27, 36, 45, 54, 63, 72, 81, 90, 99, 108, 117, 126, 135, 
         .word    0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 
         .word    0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 110, 121, 132, 143, 154, 165, 
         .word    9, 9, 9, 9, 48, 60, 72, 84, 96, 108, 120, 132, 0, 1, 2, 3, 
         .word    9, 9, 9, 9, 52, 65, 78, 91, 104, 114, 130, 143, 1, 2, 3, 4, 
         .word    9, 9, 9, 9, 56, 70, 84, 98, 112, 126, 140, 154, 2, 3, 4, 5, 
         .word    9, 9, 9, 9, 60, 75, 90, 105, 120, 135, 150, 165, 3, 4, 5, 6 
window4: .word    7, 7, 7, 7, 
         .word    7, 7, 7, 7, 
         .word    7, 7, 7, 7, 
         .word    7, 7, 7, 7 

########################################################################################################################
### main
########################################################################################################################

.text

.globl main

main:
	addi $a3, $zero, 0
    addi    $sp, $sp, -4    # Make space on stack
    sw      $ra, 0($sp)     # Save return address
		 
    # Start test 1
    ############################################################
    la      $a0, asize1     # 1st parameter: address of asize
    la      $a1, frame1     # 2nd parameter: address of frame
    la      $a2, window1    # 3rd parameter: address of window
    jal     vbsme           # call function
    ############################################################
    # End of test

	# Start test 2
    ############################################################
    la      $a0, asize2     # 1st parameter: address of asize
    la      $a1, frame2     # 2nd parameter: address of frame
    la      $a2, window2    # 3rd parameter: address of window
    jal     vbsme           # call function
    ############################################################
    # End of test

	# Start test 3
    ############################################################
    la      $a0, asize3     # 1st parameter: address of asize
    la      $a1, frame3     # 2nd parameter: address of frame
    la      $a2, window3    # 3rd parameter: address of window
    jal     vbsme           # call function
    ############################################################
    # End of test

	# Start test 4
    ############################################################
    la      $a0, asize4     # 1st parameter: address of asize
    la      $a1, frame4     # 2nd parameter: address of frame
    la      $a2, window4    # 3rd parameter: address of window
    jal     vbsme           # call function
    ############################################################
    # End of test

    lw      $ra, 0($sp)         # Restore return address
    addi    $sp, $sp, 4         # Restore stack pointer
main_loop:
	addi $a3, $zero, 1
    j      main_loop                 # Return

.text
.globl  vbsme

vbsme:  
    li      $v0, 0              # reset $v0 and $V1
    li      $v1, 0

    # insert your code here
   	
	
	# Save registers
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	
	# $s0 = frame rows, $s1 frame columns
	lw $s0, 0($a0)
	lw $s1, 4($a0)
	
	# $s2 window rows, $s3 window columns
	lw $s2, 8($a0)
	lw $s3, 12($a0)
	
	# Make $s0 and $s1 number of effective frame rows and cols (rows and columns of frame when taking window size into account)
	# effective rows = frame rows - window rows + 1, and effective cols = frame cols - window cols + 1
	sub $s0, $s0, $s2
	sub $s1, $s1, $s3
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	
	# $s4 = current row, $s5 = current column
	add $s4, $zero, $zero
	add $s5, $zero, $zero
	
	# $s6 = minimum SAD value, $s7 = going up (1 if true)
	addi $s6, $zero, -1 # Maximum possible SAD initially
	add $s7, $zero, $zero # Set to 0
	
vbsme_loop:
	slt $t0, $s4, $s0 # $t0 = current row < effective rows
	slt $t1, $s5, $s1 # $t1 = current column < effective columns
	and $t2, $t0, $t1 # $t2 = current row < effective_frame_rows && current col < effective_frame_cols
	beq $t2, $zero, vbsme_exit # stop if !(current row < effective rows && current column < effective cols)
	
	# Can now reuse $t0, $t1, and $t2
	# Calculate SAD for current window
	add $t0, $zero, $zero # t0 is current SAD
	add $t1, $zero, $zero # t1 is i for outer loop
vbsmeSAD_loop_outer:
	slt $t3, $t1, $s2 # $t3 = i < window_rows
	beq $t3, $zero, vbsmeSAD_loop_outer_end # If i >= window rows, end outer loop
	add $t2, $zero, $zero # t2 is k for inner loop
vbsmeSAD_loop_inner:
	slt $t4, $t2, $s3 # k < window_cols
	beq $t4, $zero, vbsmeSAD_loop_inner_end # If k >= window cols, end inner loop
	
	# Loop body
	# $t5 is window index, $t6 is frame index
	# $t5 = i * window cols + k
	mul $t5, $t1, $s3
	add $t5, $t5, $t2
	
	# $t6 = (i + current row) * frame cols + (k + current col)
	add $t6, $t1, $s4
	add $t8, $s1, $s3 # t8 is frame cols
	addi $t8, $t8, -1
	mul $t6, $t6, $t8
	add $t6, $t6, $t2
	add $t6, $t6, $s5
	
	# $t7 = window[window index], $t8 = frame[frame index]
	sll $t5, $t5, 2
	sll $t6, $t6, 2
	add $t7, $a2, $t5
	add $t8, $a1, $t6
	
	lw $t7, 0($t7)
	lw $t8, 0($t8)
	# $t7 is window[window index] - frame[frame index]
	sub $t7, $t7, $t8
	slt $t8, $t7, $zero # $t8 is 1 if $t7 is less than zero (if the subtraction resulted in negative)
	beq $t8, $zero, vbsmeSAD_loop_inner_gt_zero # If non-negative, no need to negate to make non-negative
	# Invert $t7 to make non-negative
	nor $t7, $t7 $zero
	addi $t7, $t7, 1
vbsmeSAD_loop_inner_gt_zero:
	add $t0, $t0, $t7 # Add the current iteration absolute difference to SAD
	addi $t2, $t2, 1 # k++
	j vbsmeSAD_loop_inner
vbsmeSAD_loop_inner_end:
	addi $t1, $t1, 1 # i++
	j vbsmeSAD_loop_outer
vbsmeSAD_loop_outer_end:

	# Now we can use all temps except $t0
	# If SAD <= min_SAD
	sltu $t1, $s6, $t0 # $t1 = (min SAD < SAD)
	bne $t1, $zero, vbsme_after_SAD_update # If SAD > minimum SAD, do not update minimum SAD indices
	# Update minimum SAD and the row and column it represents
	add $v0, $s4, $zero
	add $v1, $s5, $zero
	add $s6, $t0, $zero
	
vbsme_after_SAD_update:
	add $t1, $zero, $zero # $t1 is next row
	add $t2, $zero, $zero # $t2 is next col
	or $t3, $s4, $s5 # Will be zero only if both $s4 (current row) and $s5 (current column) are zero
	bne $t3, $zero, vbsme_no_origin # Jump to vbsme_no_origin if not at position (0, 0)
	slti $t9, $s1, 2 # $t9 is 1 if only one column
	bne $t9, $zero, vbsme_origin_one_col # If only one column, jump to vbsme_origin_one_col
	add $t1, $zero, $zero # Next row from (0,0) is 0
	addi $t2, $zero, 1 # Next column from (0,0) is 1
	add $s7, $zero, $zero # Set going up to 0
	j vbsme_loop_last_statements
vbsme_origin_one_col:
	add $t2, $zero, $zero # Next column from (0,0) is 0
	addi $t1, $zero, 1 # Next row from (0,0) is 1
	add $s7, $zero, $zero # Set going up to 0
	j vbsme_loop_last_statements
vbsme_no_origin:
	# $s4 and $s5 are current row and column, $s7 is going_up

	# If we should be going up, then jump to vbsme_going_up
	bne $s7, $zero, vbsme_going_up
	
	# We are going down
	addi $t3, $s0, -1 # $t3 = (effective rows - 1)
	slt $t4, $s4, $t3 # $t4 = current row < (effective rows - 1)
	
# current col == 0 && current row >= (effective rows - 1)
	bne $s5, $zero, vbsme_down_cur_row_big # current column != 0, so go to case current row >= (effective rows - 1)
	bne $t4, $zero, vbsme_down_cur_col_zero # current column == 0, but current row < (effective rows - 1), so go to case current column == 0
	addi $t2, $zero, 1 # Next column is 1
	add $t1, $s4, $zero # Next row is current row
	addi $s7, $zero, 1 # Go up next iteration
	j vbsme_loop_last_statements # Go to loop end
# elif current col == 0
vbsme_down_cur_col_zero:
	add $t2, $zero, $zero # Next column is zero
	addi $t1, $s4, 1 # Next row is current row + 1
	addi $s7, $zero, 1 # Go up next iteration
	j vbsme_loop_last_statements # Go to loop end
# elif current row >= (effective rows - 1)
vbsme_down_cur_row_big:
	bne $t4, $zero, vbsme_down_else # Go to case neither current row >= (effective rows - 1) nor current column == 0
	addi $t2, $s5, 1 # Next column is current column + 1
	add $t1, $s4, $zero # Next row is current row
	addi $s7, $zero, 1 # Go up next iteration
	j vbsme_loop_last_statements # Go to loop end
# else (not at boundary where we need to switch from going down to going up)
vbsme_down_else:
	addi $t1, $s4, 1 # Next row is current row + 1
	addi $t2, $s5, -1 # Next column is current column - 1
	add $s7, $zero, $zero # Continue going down next iteration
	j vbsme_loop_last_statements # Go to loop end
# GOING UP
vbsme_going_up:

	# We are going up
	addi $t3, $s1, -1 # $t3 = (effective cols - 1)
	slt $t4, $s5, $t3 # $t4 = current col < (effective cols - 1)
	
# current row == 0 && current col >= (effective cols - 1)
	bne $s4, $zero, vbsme_up_cur_col_big # current row != 0, so go to case current col >= (effective cols - 1)
	bne $t4, $zero, vbsme_up_cur_row_zero # current row == 0, but current col >= (effective cols - 1), so go to case current row == 0
	addi $t1, $zero, 1 # Next row is 1
	add $t2, $s5, $zero # Next column is current column
	add $s7, $zero, $zero # Go down next iteration
	j vbsme_loop_last_statements
# elif current row == 0
vbsme_up_cur_row_zero:
	add $t1, $zero, $zero # Next row is 0
	addi $t2, $s5, 1 # Next column is current column + 1
	add $s7, $zero, $zero # Go down next iteration
	j vbsme_loop_last_statements
# elif current col >= (effective cols - 1)
vbsme_up_cur_col_big:
	bne $t4, $zero, vbsme_up_else # Go to case neither current row == 0 nor current col >= (effective cols - 1)
	addi $t1, $s4, 1 # Next row is current row + 1
	add $t2, $s5, $zero # Next column is current column
	add $s7, $zero, $zero # Go down next iteration
	j vbsme_loop_last_statements
# else (not at boundary where we need to switch from going up to going down)
vbsme_up_else:
	addi $t1, $s4, -1 # Next row is current row - 1
	addi $t2, $s5, 1 # Next column is current column + 1
	addi $s7, $zero, 1 # Keep going up next iteration
vbsme_loop_last_statements:
	add $s4, $t1, $zero # Set current row to next row
	add $s5, $t2, $zero # Set current column to next column
	j vbsme_loop
vbsme_exit:
	# Restore registers $s0 through $s7 to how they were before function call
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp, 32
	jr $ra
