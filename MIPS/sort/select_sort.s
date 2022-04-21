.data

datalist1: .word 17, 78, 77, 83, 87, 86, 67, 83
datasize1: .word 8
datalist2: .word 36, 37, 69, 91, 22, 15, 88, 15, 18, 41, 73, 62, 8, 57, 96, 48, 21, 20, 38, 21, 83, 20, 54, 66, 73
datasize2: .word 25

.text
.globl main

main:
    # Not done when a3=0
    addi $a3, $zero, 0

    # a0 = list, a1 = size
    la $a0, datalist1
    la $t0, datasize1
    lw $a1, 0($t0)
    jal sort

    # a0 = list, a1 = size
    la $a0, datalist2
    la $t0, datasize2
    lw $a1, 0($t0)
    jal sort

stall:
    # Done when a3=1
    addi $a3, $zero, 1
    j stall

sort:
    addi $sp, $sp, -24
    sw $s5, 20($sp)
    sw $s4, 16($sp)
    sw $s3, 12($sp)
    sw $s2, 8($sp)
    sw $s1, 4($sp)
    sw $s0, 0($sp)

    beq $a1, $zero, sort_end # Exit if list length = 0

    addi $s5, $zero, 4
    addi $t0, $zero, 0 # t0 = outer loop index
    addi $t1, $a1, -1 # t1 = outer loop max
outer_loop:
    slt $t2, $t0, $t1 # t2=1 if t0<t1 (i.e. outer index < max)
    beq $t2, $zero, sort_end
    addi $t3, $t0, 0 # t3 = min index
    addi $t4, $t0, 1 # t4 = inner loop index
inner_loop:
    slt $t5, $t4, $a1 # t5=1 if t4<a1 (i.e. inner index < sz)
    beq $t5, $zero, outer_loop_end
    mul $s0, $t4, $s5
    add $s0, $a0, $s0 # addr data[inner loop index]
    mul $s1, $t3, $s5
    add $s1, $a0, $s1 # addr data[min index]
    lw $s2, 0($s0) # data[inner loop index]
    lw $s3, 0($s1) # data[min index]
    slt $s4, $s2, $s3 # s4=1 if s2<s3 (data[inner loop index] < data[min index])
    beq $s4, $zero, inner_loop_end
    add $t3, $t4, $zero
inner_loop_end:
    addi $t4, $t4, 1
    j inner_loop
outer_loop_end:
    mul $t4, $t0, $s5
    add $t4, $a0, $t4 # t4 = addr data[outer loop index]
    lw $t5, 0($t4) # t5 = data[outer loop index]
    mul $s1, $t3, $s5
    add $s1, $a0, $s1
    lw $s3, 0($s1)
    sw $s3, 0($t4) # data[outer loop index] = data[min index]
    sw $t5, 0($s1) # data[min index] = t5
    addi $t0, $t0, 1
    j outer_loop
sort_end:
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 24
    jr $ra
