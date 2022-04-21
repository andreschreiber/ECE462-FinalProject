.text
.globl main

main: 
    # Not done when a3=0
    addi $a3, $zero, 0

    # a0 = base, a1 = power
    # power(2, 2)
    addi $a0, $zero, 2
    addi $a1, $zero, 2
    jal power

    # a0 = base, a1 = power
    # power(3, 3)
    addi $a0, $zero, 3
    addi $a1, $zero, 3
    jal power

    # a0 = base, a1 = power
    # power(4, 4)
    addi $a0, $zero, 4
    addi $a1, $zero, 4
    jal power

    # a0 = base, a1 = power
    # power(5, 5)
    addi $a0, $zero, 5
    addi $a1, $zero, 5
    jal power

    # a0 = base, a1 = power
    # power(6, 6)
    addi $a0, $zero, 6
    addi $a1, $zero, 6
    jal power

    # a0 = base, a1 = power
    # power(7, 7)
    addi $a0, $zero, 7
    addi $a1, $zero, 7
    jal power

stall:
    # Done when a3=1
    addi $a3, $zero, 1
    j stall

power:
    bne $a1, $zero, power_calc
    addi $v0, $zero, 0 # return 0 if wanted a0^0
    jr $ra
power_calc:
    addi $s0, $zero, 1 # s0=Result
    addi $s1, $zero, 0 # s1=Loop counter
power_loop:
    mul $s0, $s0, $a0 # Multiply
    addi $s1, $s1, 1 # Update loop counter
    bne $s1, $a1, power_loop # Fall through on final iteration
power_return:
    addi $v0, $s0, 0
    jr $ra
