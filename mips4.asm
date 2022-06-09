.data
str1: .space 32
str2: .space 32
str3: .space 32
str4: .space 32
frag: .space 32

helper0: .asciiz "\n\nWybierz operacje\n\n"
# 0 - koniec
# 1 - wczytaj
# 2 - wyswietl
# 3 - strlen
# 4 - strcmp
# 5 - strcat
# 6 - strfind
helper1: .asciiz "\n\nWybierz napis\n\n"
helper1_2: .asciiz "\n\nTresc napisu\n\n"
helper1_3: .asciiz "\n\nWybierz napis dla fragmentu\n\n"
helper2: .asciiz "\n\nWyswietl napis\n\n"

.text
main:

main_loop:

	la $a0, helper0
	li $v0, 4
	syscall

	li $v0, 5
	syscall

	# WYBIERANIE OPERACJI

	beq $v0, 0, end_main_loop # 0 to exit

	bgt $v0, 1, if_main_1

	la $a0, helper1
	li $v0, 4
	syscall

	li $v0, 5 # wczytuje indeks
	syscall

	move $a0, $v0 # parametr

	jal insert_str
	j end_main_if

if_main_1:
	bgt $v0, 2, if_main_2

	la $a0, helper2
	li $v0, 4
	syscall

	li $v0, 5 # wczytuje indeks
	syscall

	move $a0, $v0 # parametr

	jal display_str
	j end_main_if

if_main_2:
	bgt $v0, 3, if_main_3  
	
	la $a0, helper1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $a0, $v0

	jal strlen
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	j end_main_if

if_main_3:
	bgt $v0, 4, if_main_4
	
	la $a0, helper1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $t0, $v0
	
	la $a0, helper1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $a0, $t0
	move $a1, $v0
	
	jal strcmp
	
	move $a0, $v0
	li $v0, 1
	syscall
	
	j end_main_if

if_main_4:
	bgt $v0, 5, if_main_5
	
	la $a0, helper1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $t0, $v0
	
	la $a0, helper1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $a1, $v0
	
	la $a0, helper1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $a2, $v0
	
	move $a0, $t0

	jal strcat
	j end_main_if

if_main_5:
	la $a0, helper1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $t4, $v0 # numer str
	
	la $a0, helper1_3
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	move $t5, $v0 # numer str tworzonego
	
	move $a0, $t5
	jal insert_str
	
	move $a0, $t4 # numer str
	move $a1, $t5 # numer frag
	
	jal strfind
	
	move $a0, $v0
	
	li $v0, 1
	syscall
	
	j end_main_if


end_main_if:

	# KONIEC WYBORU OPERACJI
	
	j main_loop


end_main_loop:

	li $v0, 10
	syscall

insert_str:
	move $t7, $ra
	move $t0, $a0
	
	la $a0, helper1_2
	li $v0, 4
	syscall
	
	move $a0, $t0

	jal choose_str
	
	move $a0, $v0

	li $v0, 8 # input string
	li $a1, 32 # alloc 32 byte
	syscall

	jal zero_at_end

	move $ra, $t7
	jr $ra

display_str:
	move $t7, $ra
	
	jal choose_str
	
	move $a0, $v0

	li $v0, 4
	syscall

	move $ra, $t7
	jr $ra

zero_at_end:
	move $t0, $a0 # pointer
loop_1:
	lbu $t2, 0($t0)
	addu $t1, $zero, $t2 # wartosc
	bne $t1, 0x0a, j_loop_1

	li $t1, 0x00
	sb $t1, 0($t0)
	j end_loop_1

j_loop_1:
	addiu $t0, $t0, 1
	j loop_1

end_loop_1:

	jr $ra
	
choose_str:
	# WYBIERANIE STRINGA

	bgt $a0, 1, if_choose_1

	la $a0, str1 # jezeli 1 wczytujemy str1
	j end_choose_if

if_choose_1:
	bgt $a0, 2, if_choose_2

	la $a0, str2 # jezeli 2 wczytujemy str2
	j end_choose_if

if_choose_2:
	bgt $a0, 3, if_choose_3  

	la $a0, str3 # jezeli 3 wczytujemy str3
	j end_choose_if

if_choose_3:
	la $a0, str4 # jezeli 4 wczytujemy str4


end_choose_if:

	# KONIEC WYBORU STRINGA
	
	move $v0, $a0

	jr $ra

strlen:
	move $t7, $ra
	
	jal choose_str
	
	move $t0, $v0
	
	li $t2, 0 # wynik
	
count_loop:
	lbu $t1, 0($t0)
	beq $t1, 0x00, end_count_loop
	
	addiu $t2, $t2, 1
	addiu $t0, $t0, 1
	
	j count_loop
	
end_count_loop:
	
	move $ra, $t7
	move $v0, $t2 # result
	jr $ra

strcmp:
	move $t7, $ra
		
	jal choose_str
	
	move $t0, $v0
	
	move $a0, $a1
	
	jal choose_str
	
	move $t1, $v0
	
	li $v0, 0
	
cmp_loop:
	lbu $t2, 0($t0)
	lbu $t3, 0($t1)
	addiu $t0, $t0, 1
	addiu $t1, $t1, 1
	
	beq $t2, 0x00, s1_0
	beq $t3, 0x00, s2_0
	
	j after_0s
	
s1_0:
	beq $t3, 0x00, s1_s2_0
	
	li $v0, -1 # kiedy s1 koniec a s2 nie
	
	j end_cmp_loop
	
s1_s2_0:
	j end_cmp_loop # kiedy oba rowne

s2_0:
	li $v0, 1 # kiedy s2 koniec a s1 nie
	
	j end_cmp_loop
	
after_0s:
	
	beq $t2, $t3, cmp_loop
	blt $t2, $t3, less
	
	li $v0, 1
	j end_cmp_loop
less:
	li $v0, -1
	j end_cmp_loop

end_cmp_loop:	
	
	move $ra, $t7

	jr $ra

strcat:
	move $t7, $ra
	
	jal choose_str
	
	move $t0, $v0
	
	move $a0, $a1
	
	jal choose_str
	
	move $t1, $v0
	
	move $a0, $a2
	
	jal choose_str
	
	move $t2, $v0
	
first_while:
	lbu $t3, 0($t1)
	beq $t3, 0x00, second_while
	
	sb $t3, 0($t0)
	
	addiu $t1, $t1, 1
	addiu $t0, $t0, 1

	j first_while

second_while:
	lbu $t3, 0($t2)
	beq $t3, 0x00, end_second_while

	sb $t3, 0($t0)
	
	addiu $t2, $t2, 1
	addiu $t0, $t0, 1
	
	j second_while

end_second_while:

	li $t3, 0x00
	sb $t3, 0($t0)
	
	move $ra, $t7

	jr $ra

strfind:
	move $t7, $ra
	
	jal choose_str
	
	move $t0, $v0
	
	move $a0, $a1
	
	jal choose_str
	
	move $a1, $v0
	
	move $a0, $t0
	
	move $t1, $a1 # adres poczatku fragmentu
	
	li $v0, 0 # indeks
	li $t2, 0 # counter
	
while_find:
	lbu $t4, 0($a0)
	lbu $t5, 0($a1)
	beq $t5, 0x00, end_end_while_find # jezeli koniec frag to koniec wyszukiwania
	beq $t4, 0x00, end_while_find # jezeli koniec stringa i nie ma wyniku -> -1
	bne $t5, $t4, not_equal # jezeli rowne to nastepny fragment w arrayach
	
	addiu $t2, $t2, 1
	
	addiu $a0, $a0, 1
	addiu $a1, $a1, 1
	
	j while_find
	
not_equal: # jezeli nie sa rowne to indeks rowna sie counter
	move $v0, $t2
	beq $a1, $t1, second_option
first_option: # jezeli to nie byl poczatek fragmentu zaczynamy w tym samymm miesjcu a0
	move $a1, $t1
	
	j while_find

second_option: # jezeli to byl pocztek fragmentu zaczynamy w kolejnym bajcie
	move $a1, $t1
	addiu $t2, $t2, 1
	move $v0, $t2
	addiu $a0, $a0, 1
	
	j while_find

end_while_find:

	li $v0, -1

end_end_while_find:
	
	move $ra, $t7

	jr $ra
