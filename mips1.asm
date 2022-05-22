.text
convert:
	lw	$t7, in_i
        bne     $t7,$zero,not_zero
        
	sw	$t7,0($sp)
        lwc1	$f12,0($sp)
        
	li	$v0, 2
	syscall
	li	$v0, 10
	syscall

not_zero:
        li      $t6,0 # output
        li      $t5,0 # input
        li      $t4,0 # exp
        li      $t3,0 # mantysa
        li	$t2,0 # znak
        bgez    $t7,_if1

        add	$t5, $t5, $t7
        mul	$t5, $t5, -1
        addi	$t2, $t2, 1
        sll	$t2, $t2, 31
        j _not

_if1:
        add    	$t5, $zero, $t7
        addi	$t2, $zero, 0
_not:

	addi	$t1, $t5, 0 # temp
	addi	$t0, $zero, -1 # potega
loop:	
	beq	$t1, 0, done
	srl	$t1, $t1, 1
	addi	$t0, $t0, 1
	j loop
done:
        addi	$t4,$t0,127
        
        sll	$t4,$t4,23
        
        addi	$t1,$zero,1 # poprawka
        
        sllv	$t1,$t1,$t0
        
        sub	$t3,$t5,$t1
        
        subi	$t1,$t0,1
        
        mul	$t1,$t1,-1
        
        addi	$t1,$t1,22 # przesuniecie
        
        blt	$t5,16777216,else
        mul	$t1,$t1,-1
	srlv	$t3,$t3,$t1
	j after_else
else:
	sllv	$t3,$t3,$t1
after_else:
        
        or	$t6,$t4,$t3
        or	$t6,$t6,$t2
        
        sw	$t6,0($sp)
        lwc1	$f12,0($sp)
	
	li	$v0, 2
	syscall
	
	li	$v0, 10
	syscall
.data
in_i: .word -1
out_f: .word 0
