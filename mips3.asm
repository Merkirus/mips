.eqv STACK_SIZE 2048

.data
sys_stack_addr: .word 0
stack: .space STACK_SIZE
array: .word 1,2,3,4,5,6,7,8,9,10,11

.text

	#inicjalizacja
	sw $sp, sys_stack_addr
	la $sp, stack+STACK_SIZE
	
	subiu $sp, $sp, 4 # wskazuje na ostatni elem. arraya

main:
	subiu $sp, $sp, 4 # rezerwuje miejsce dla s
	
	# parametr wskaznika do arraya
	la $t0, array
	sw $t0, 0($sp)
	subiu $sp, $sp, 4
	
	# parametr rozmiaru arraya
	li $t0, 11
	sw $t0, 0($sp)
	subiu $sp, $sp, 4
	
	jal sum
		
	lw $t0, 0($sp)
	addiu $sp, $sp, 12
	sw $t0, 0($sp)
	
	li $v0, 1
	lw $a0, 0($sp) # wskazuje na s
	syscall
	
	lw $sp, sys_stack_addr
	
	li $v0, 10
	syscall

sum:
	subiu $sp, $sp, 4 # miejsce na return
	
	sw $ra, 0($sp) # adres skoku
	subiu $sp, $sp, 4
	
	subiu $sp, $sp, 8 # miejsce na dwie zmienne
	
	li $t1, 0
	sw $t1, 4($sp)

	lw $t1, 20($sp) # pobieram size
	subiu $t1, $t1, 1 # size - 1
	sw $t1, 8($sp)

while:
	lw $t1, 8($sp)
	blt $t1, $zero, end_while
	
	lw $t1, 4($sp) # pobieram s
	lw $t2, 8($sp) # pobieram i
	la $t3, 24($sp) # pobieram adres arraya
	mul $t2, $t2, 4 # zamieniam indeksy byte na indeksy word
	addu $t3, $t3, $t2 # przesuwam
	lw $t3, 4($t3) # pobieram wartosc z indeksu i w arrayu - bez offsetu nie dziala ?

	addu $t1, $t1, $t3
		
	sw $t1, 4($sp)

	lw $t1, 8($sp)
	subiu $t1, $t1, 1
	sw $t1, 8($sp)

	j while

end_while:
	
	lw $t1, 4($sp)
	sw $t1, 16($sp) # zapisuje wynik
	
	addiu $sp, $sp, 8 # usuwanie zmiennych
	
	addiu $sp, $sp, 4 # wskazuje na ra
	lw $ra, 0($sp)
	addiu $sp, $sp, 4 # wskazuje na wynik
	
	jr $ra
