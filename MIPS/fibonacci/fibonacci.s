.text
.globl main

main: 
    # Not done when a3=0
    addi $a3, $zero, 0

    # a0 = number
    # fibonacci(2)
    addi $a0, $zero, 2
    jal fibonacci

    # a0 = number
    # fibonacci(3)
    addi $a0, $zero, 3
    jal fibonacci

    # a0 = number
    # fibonacci(7)
    addi $a0, $zero, 7
    jal fibonacci

    # a0 = number
    # fibonacci(10)
    addi $a0, $zero, 10
    jal fibonacci

    # a0 = number
    # fibonacci(15)
    addi $a0, $zero, 15
    jal fibonacci

stall:
    # Done when a3=1
    addi $a3, $zero, 1
    j stall

fibonacci:
    addi $sp, $sp, -16
    sw $s1, 12($sp)
    sw $s0, 8($sp)
    sw $ra, 4($sp)
    sw $a0, 0($sp)
    addi $s1, $zero, 3
    slt $s0, $a0, $s1
    beq $s0, $zero, fibonacci_gt_two
    addi $v0, $zero, 1
    j fibonacci_exit
fibonacci_gt_two:
    addi $a0, $a0, -1
    jal fibonacci
    addi $s0, $v0, 0
    addi $a0, $a0, -1
    jal fibonacci
    add $v0, $v0, $s0
fibonacci_exit:
    lw $s1, 12($sp)
    lw $s0, 8($sp)
    lw $ra, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 16
    jr $ra
