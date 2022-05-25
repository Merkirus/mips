.data
	first: .byte 0x00, 0x4f
	second: .byte 0x15, 0xf0, 0xf0
	result: .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

.text	
	# USUWANIE NIEZNACZACYCH ZER

	la $a0, first # adres elementu w first
	la $a1, second # adres elementu w second

	li $t0, 0 # parzystosc
	li $t1, 0 # temp
	
inf_pre_loop_1:
	bne $t0, 0, end_inf_pre_loop_1
	
	lbu $t1, 0($a0)

	li $t2, 0 # lower byte
	li $t3, 0 # upper byte
	andi $t2, $t1, 0x0000000f
	andi $t3, $t1, 0x000000f0

	# jezeli upper to liczba to koniec
	beq $t3, 0, inf_pre_else_upper_1

	j end_inf_pre_loop_1

inf_pre_else_upper_1:

	# jezeli jest liczba to trzeba shift left
	beq $t2, 0, inf_pre_else_lower_1

	li $t0, 1

	j end_inf_pre_loop_1

inf_pre_else_lower_1:

	addiu $a0, $a0, 1

	j inf_pre_loop_1

end_inf_pre_loop_1:

	li $t7, 0 # zmienna tymczasowa
	lbu $t7, 0($a0)
	andi $t7, $t7, 0x0000000f
	li $t6, 0 # licznik przesuniec adresu

half_byte_shifting_loop_1:
	beq $t0, 0, end_half_byte_shifting_loop_1

	addiu $a0, $a0, 1 # bierzemy nastepny bajt

	lbu $t1, 0($a0)
	li $t2, 0 # lower byte
	li $t3, 0 # upper byte
	andi $t2, $t1, 0x0000000f
	andi $t3, $t1, 0x000000f0

	srl $t3, $t3, 4

	subiu $a0, $a0, 1 # cofamy sie aby przelozyc cyfry

	sll $t7, $t7, 4 # przesuwamy przenoszona cyfre na upper

	or $t7, $t7, $t3 # suma przenoszonej cyfry i upperbytu pop.

	sb $t7, 0($a0)

	# jezeli upper jest f to koniec liczby
if_upper_byte_is_f_1:
	beq $t3, 0x0000000f, end_half_byte_shifting_loop_1

	move $t7, $t2 # zachowuje lower byte na pozniej

	addiu $a0, $a0, 1

	addiu $t6, $t6, 1

	# jezeli lower jest f, to upper next byte bedzie f
if_lower_byte_is_f_1:
	bne $t7, 0x0000000f, skip_if_lower_byte_1

	li $t7, 0x000000f0
	sb $t7, 0($a0)

	j end_half_byte_shifting_loop_1

skip_if_lower_byte_1:

	j half_byte_shifting_loop_1

end_half_byte_shifting_loop_1:

	subu $a0, $a0, $t6 # powrot na poczatek arraya


	li $t0, 0 # parzystosc
	li $t1, 0 # temp

inf_pre_loop_2:
	bne $t0, 0, end_inf_pre_loop_2
	
	lbu $t1, 0($a1)

	li $t2, 0 # lower byte
	li $t3, 0 # upper byte
	andi $t2, $t1, 0x0000000f
	andi $t3, $t1, 0x000000f0

	beq $t3, 0, inf_pre_else_upper_2

	j end_inf_pre_loop_2

inf_pre_else_upper_2:

	beq $t2, 0, inf_pre_else_lower_2

	li $t0, 1

	j end_inf_pre_loop_2

inf_pre_else_lower_2:

	addiu $a1, $a1, 1

	j inf_pre_loop_2

end_inf_pre_loop_2:

	li $t7, 0 # zmienna tymczasowa
	lbu $t7, 0($a1)
	andi $t7, $t7, 0x0000000f
	li $t6, 0 # licznik przesuniec adresu

half_byte_shifting_loop_2:
	beq $t0, 0, end_half_byte_shifting_loop_2

	addiu $a1, $a1, 1 # bierzemy nastepny bajt

	lbu $t1, 0($a1)
	li $t2, 0 # lower byte
	li $t3, 0 # upper byte
	andi $t2, $t1, 0x0000000f
	andi $t3, $t1, 0x000000f0

	srl $t3, $t3, 4

	subiu $a1, $a1, 1

	sll $t7, $t7, 4

	or $t7, $t7, $t3

	sb $t7, 0($a1)

if_upper_byte_is_f_2:
	beq $t3, 0x0000000f, end_half_byte_shifting_loop_2

	move $t7, $t2

	addiu $a1, $a1, 1
	addiu $t6, $t6, 1

if_lower_byte_is_f_2:
	bne $t7, 0x0000000f, skip_if_lower_byte_2

	li $t7, 0x000000f0
	sb $t7, 0($a1)

	j end_half_byte_shifting_loop_2

skip_if_lower_byte_2:

	j half_byte_shifting_loop_2

end_half_byte_shifting_loop_2:

	subu $a1, $a1, $t6 # powrot na poczatek arraya
	
	# KONIEC USUWANIA NIEZNACZACYCH ZER

	# MIERZENIE DLUGOSCI
	li $t0, 0 # temp_value
	li $t1, 0 # second_temp_value
	
	li $t7, 0 # first_byte_size
	li $t6, 0 # first_half_byte_size
	li $t5, 0 # second_byte_size
	li $t4, 0 # second_half_byte_size

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

	# JEZELI NIEPARZYSTE ZMNIEJSZAMY MAX BYTE SIZE
	beq $t3, 0, if_else_half_even
	
	subiu $t1, $t1, 1
			
if_else_half_even:

	subiu $t1, $t1, 1 # zamiana sizu na indeks

	la $a2, result # adres wyniku
	addu $a2, $a2, $t1 # przejscie na koniec wyniku
	subiu $t0, $t0, 1 # miejsce na koniec liczby
	
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
	beq $t3, 1, not_even_in_inner_inner_loop # sprawdzam parzystosc half
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
	bne $t3, 0x0000000f, end_first_inner_loop # jezeli nie 0x0f pop. wart.
	li $t3, 0
	j first_inner_loop
	
end_first_inner_loop:
	
	move $t5, $t3 # pierwsza czesc dodawania
	
	li $t3, 0
second_inner_loop:
	bleu $t4, 0, end_second_inner_loop # gdy half byte size 0 koniec liczby
	
	divu $t3, $t4, 2
	mfhi $t3
	beq $t3, 1, not_even_in_inner_inner_loop_2 # sprawdzam parzystosc half
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
	bne $t3, 0x0000000f, end_second_inner_loop # jezeli nie 0x0f pop. wart.
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
	sb $t5, 0($a2) # zapisanie wyniku
	j max_half_byte_size_not_even_skip
	
max_half_byte_size_not_even:
	sll $t5, $t5, 4
	lbu $a3, 0($a2)
	or $t5, $t5, $a3 # adjust i dodawanie upper byte
	sb $t5, 0($a2) # zapisanie wyniku
	subiu $a2, $a2, 1

max_half_byte_size_not_even_skip:

	subiu $t0, $t0, 1 # odjecie jednego max half byte
	j add_loop
	
end_add_loop:

	addiu $a2, $a2, 1 # naprawiam - wskazuje teraz na indeks 0
	
	# Wolne rejestry
	# t7 ma carry_over
	li $t5, 0
	li $t3, 0
	li $t1, 0
	li $t0, 0

	# SHIFTING
	
	move $t0, $s0 # max half byte size
	move $t1, $s1 # max byte size
	addu $t5, $zero, $t0
	addu $t3, $zero, $t1
	move $s0, $t5
	move $s1, $t3
	li $t5, 0
	li $t3, 0

shifting:
	beq $t7, 0, end_shifting # jezeli nie ma nic do przeniesienia, nie ma shiftu
	
	move $s7, $t7 # zachowuje carry_over na pozniej
	li $t7, 0
	addu $t7, $t7, $t1 # na wszelki wypadek do poprawki indesku po nieparzystym przesuwaniu
	
	divu $t0, $t0, 2
	mfhi $t0
	bne $t0, 0, not_even_shifting
	
	addiu $t1, $t1, 1 # jezeli liczba parzysta zwiekszamy wielkosc o jeden
	li $t5, 0
	addu $t5, $zero, $t1
	move $s1, $t5 # poprawka do wielkosci
	li $t5, 0
	
	li $t3, 0 # tu przechowujemy zmienna tymczasowa
	subiu $t1, $t1, 1 # do iteracji zamieniamy size na indeks
	addu $a2, $a2, $t1 # ostatnia pozycja w tablicy
	
even_shifting_loop:
	bleu $t1, 0, end_even_shifting_loop
	
	subiu $a2, $a2, 1
	lbu $t0, 0($a2) # lower byte
	lbu $t5, 0($a2) # upper byte
	addiu $a2, $a2, 1
	
	andi $t0, $t0, 0x0000000f
	andi $t5, $t5, 0x000000f0
	srl $t5, $t5, 4
	sll $t0, $t0, 4
	or $t0, $t0, $t3
	sb $t0, 0($a2)
	move $t3, $t5
	
	subiu $a2, $a2, 1
	subiu $t1, $t1, 1

	j even_shifting_loop
	
end_even_shifting_loop:
	# wychodzimy z petli z indeksem 0
	or $t3, $t3, 0x00000010
	sb $t3, 0($a2)

	j end_shifting
	
not_even_shifting:

	li $t3, 0x00000010 # tu przechowujemy zmienna tymczasowa
not_even_shifting_loop:
	bleu $t1, 0, end_not_even_shifting_loop
	
	lbu $t0, 0($a2) # lower byte
	lbu $t5, 0($a2) # upper byte
	
	andi $t0, $t0, 0x0000000f
	andi $t5, $t5, 0x000000f0
	
	srl $t5, $t5, 4
	or $t5, $t5, $t3
	sb $t5, 0($a2)
	move $t3, $t0
	
	subiu $t1, $t1, 1
	addiu $a2, $a2, 1
	
	j not_even_shifting_loop
	
end_not_even_shifting_loop:

	# poprawka do indeksu tablicy
	subu $a2, $a2, $t7

end_shifting:

	# KONIEC SHIFTINGU

	# FIX - DODANIE f NA KONCU
	
	move $t0, $s0 # max half byte size
	move $t1, $s1 # max byte size
	move $t7, $s7 # carry_over
	
	subiu $t1, $t1, 1 # zamiana sizu na indeks
	addu $a2, $a2, $t1 # wskazuje na koniec wyniku
	
	divu $t0, $t0, 2
	mfhi $t0
	
	beq $t0, 0, even_fix_f # jezeli jest parzysty dodajemy f na koniec
	beq $t7, 1, carry_over_uneven_fix_f


carry_over_even_fix_f:
	li $t0, 0x000000f0 # jezeli nie, na poczatek
	sb $t0, 0($a2)
	j end_even_fix_f
	
carry_over_uneven_fix_f:
	li $t7, 0
even_fix_f:
	beq $t7, 1, carry_over_even_fix_f
	li $t7, 0
	li $t0, 0
	lbu $t0, 0($a2)
	ori $t0, $t0, 0x0000000f
	sb $t0, 0($a2)

end_even_fix_f:

	subu $a2, $a2, $t1 # poczatek arraya

	# KONIEC FIXA
	
	# METODA DO WYSWIETLANIA BCD
	
	addiu $t1, $t1, 1 # znowu size zamiast indeksu

print_loop:
	bleu $t1, 0, print_loop_end
	
	li $t0, 0
inner_print_loop:
	bgeu $t0, 8, inner_print_loop_end
	lbu $t3, 0($a2) # wczytuje bajt wyniku
	li $t5, 0
	subu $t5, $t0, 7
	mul $t5, $t5, -1
	srlv $t3, $t3, $t5 # shift zeby zostal jeden bit
	andi $t3, $t3, 0x00000001 # wybiera bit
	addiu $t0, $t0, 1
	
	li $v0, 1
	move $a0, $t3
	syscall
	
	j inner_print_loop

inner_print_loop_end:

	addiu $a2, $a2, 1 # przejscie do kolejnego bajtu
	subiu $t1, $t1, 1
	
	j print_loop
	
print_loop_end:

	# KONIEC METODY

	li $v0, 10
	syscall
	

	
	
