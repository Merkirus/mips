.data
	first: .byte 0x1f
	second: .byte 0x4f
	result: .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	len: .byte 0
	carry: .byte 0

.text
	li $t0, 0 # temp_value
	li $t1, 0 # second_temp_value
	
	li $t7, 0 # first_byte_size
	li $t6, 0 # first_half_byte_size
	li $t5, 0 # second_byte_size
	li $t4, 0 # second_half_byte_size
	
	# MIERZENIE DLUGOSCI
	la $a0, first # adres elementu w first
inf_loop_1:
	lbu $t1, 0($a0) # wartosc pod adresem
	li $t2, 0 # lower byte
	li $t3, 0 # upper byte
	andi $t2, $t1, 0x0000000f
	andi $t3, $t1, 0x000000f0
	
	bltu $t3, 0x000000f0, if_else_1
	addi $t7, $t7, 1 # dodawanie do byte sizu
	addi $t6, $t6, 1 # dodawanie do half byte
	j end_inf_loop1
	
if_else_1:

	bne $t2, 0x0000000f, if_else_2
	addi $t7, $t7, 1 # dodawanie do byte sizu
	addi $t6, $t6, 2 # dodawanie do half byte
	j end_inf_loop1
	
if_else_2:
	
	addiu $t7, $t7, 1 # zwiekszenie rozmiaru first byte
	addiu $a0, $a0, 1 # zwiekszenie adresu
	addiu $t6, $t6, 2 # zwiekszenie first half byte
	j inf_loop_1
	
end_inf_loop1:

		
	la $a1, second # adres elementu w second
inf_loop_2:
	lbu $t1, 0($a1)
	li $t2, 0
	li $t3, 0
	andi $t2, $t1, 0x0000000f
	andi $t3, $t1, 0x000000f0
	
	bltu $t3, 0x000000f0, if_else_21
	addi $t5, $t5, 1 # dodawanie do byte sizu
	addi $t4, $t4, 1 # dodawanie do halft byte sizu
	j end_inf_loop2
	
if_else_21:

	bne $t2, 0x0000000f, if_else_22
	addi $t5, $t5, 1 # dodawanie do byte sizu
	addi $t4, $t4, 2 # dodawanie do half byte sizu
	j end_inf_loop2
	
if_else_22:
	
	addiu $t5, $t5, 1 # zwiekszenie rozmiaru first byte
	addiu $a1 $a1, 1 # zwiekszenie adresu
	addiu $t4, $t4, 2 # zwiekszenie second half byte
	j inf_loop_2
	
end_inf_loop2:

	# KONIEC MIERZENIA DLUGOSCI

	#DODAWANIE
	
	li $t0, 0 # max half byte size
	li $t1, 0 # max byte size
	
	bgtu $t6, $t4, if_else_max_1
	addiu $t0, $t4, 0
	j end_if_else_max_1
	
if_else_max_1:
	addiu $t0, $t6, 0
	
end_if_else_max_1:

	bgtu $t7, $t5, if_else_max_2
	addiu $t1, $t5, 0
	j end_if_else_max_2
	
if_else_max_2:
	addiu $t1, $t7, 0
	
end_if_else_max_2:

	move $s0, $t0 # max half byte size for latter
	move $s1, $t1 # max byte size for latter
	
	divu $t2, $0, 2
	mfhi $t3

	# JEZELI NIE PARZYSTE ZMNIEJSZAMY MAX BYTE SIZE
	beq $t3, 0, if_else_half_even
	
	subi $t1, $t1, 1
			
if_else_half_even:

	la $t2, result # adres wyniku
	addu $t2, $t2, $t1 # przejscie na koniec wyniku
	subiu $t0, $t0, 1
	
	li $t7, 0 # dlugosci sie zwolily bo mam adresy
	li $t5, 0 
	li $t1, 0
	# t7 to carry_over
	
add_loop:
	bleu $t0, 0, end_add_loop
	
first_inner_loop:
	bleu $t6, 0, end_first_inner_loop # gdy half byte size 0 koniec liczby
	
	divu $t3, $t6, 2
	mfhi $t3
	beq $t3, 1, not_even_in_inner_inner_loop # sprawdzam parzystosc half byte
	lbu $t3, 0($a0)
	andi $t3, $t3, 0x0000000f # gdy lower half byte
	j after_not_even_in_inner_inner_loop
	
not_even_in_inner_inner_loop:
	lbu $t3, 0($a0)
	andi $t3, $t3, 0x000000f0
	srl $t3, $t3, 4
	subiu $a0, $a0, 1 # gdy nieparzysty koniec byte

after_not_even_in_inner_inner_loop:
	subiu $t6, $t6, 1
	bne $t3, 0x0000000f, end_first_inner_loop # jezeli nie 0x0f pop. wart
	li $t3, 0
	j first_inner_loop
	
end_first_inner_loop:
	
	move $t5, $t3 # pierwsza czesc dodawania
	
second_inner_loop:
	bleu $t4, 0, end_second_inner_loop # gdy half byte size 0 koniec liczby
	
	divu $t3, $t4, 2
	mfhi $t3
	beq $t3, 1, not_even_in_inner_inner_loop_2 # sprawdzam parzystosc half byte
	lbu $t3, 0($a1)
	andi $t3, $t3, 0x0000000f
	j after_not_even_in_inner_inner_loop_2
	
not_even_in_inner_inner_loop_2:
	lbu $t3, 0($a1)
	andi $t3, $t3, 0x000000f0
	srl $t3, $t3, 4
	subiu $a1, $a1, 1 # gdy nieparzysty koniec byte
	
after_not_even_in_inner_inner_loop_2:
	subiu $t4, $t4, 1
	bne $t3, 0x0000000f, end_second_inner_loop # jezeli nie 0x0f pop. wart
	li $t3, 0
	j second_inner_loop
	
end_second_inner_loop:

	addu $t5, $t5, $t3
	addu $t5, $t5, $t7 # suma
	li $t7, 0 # carry_over
	
	bleu $t5, 9, skip_fix # jezeli liczba <= 9 pomin fix
	li $t7, 1 # carry_over = 1
	addiu $t5, $t5, 6 # dodaje 6
	subiu $t5, $t5, 16 # odejmuje 10 (carry_over)
		
skip_fix:

	divu $t3, $t0, 2
	mfhi $t3
	
	bne $t3, 0, max_half_byte_size_not_even # gdy parzysty lower byte
	sb $t5, 0($t2) # zapisanie wyniku
	j max_half_byte_size_not_even_skip
	
max_half_byte_size_not_even:
	sll $t5, $t5, 4
	lbu $t1, 0($t2)
	or $t5, $t5, $t1 # adjust i dodawanie upper byte
	sb $t5, 0($t2) # zapisanie wyniku
	subiu $t2, $t2, 1

max_half_byte_size_not_even_skip:

	subiu $t0, $t0, 1 # odjecie jednego half byte
	j add_loop
	
end_add_loop:

	addiu $t2, $t2, 1 # naprawiam - wskazuje teraz na indeks 0

	li $v0, 1
	lbu $a0, 0($t2)
	syscall
	
	li $v0, 10
	syscall
	

	
	