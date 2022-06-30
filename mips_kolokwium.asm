.text
main:

	# zapisuje poczatkowa warosc stosu
	# aby znac stosunek pop/push
	la $t7, ($sp)

main_loop:

	la $a0, pytanie_stack # wybor operacji
	li $v0, 4
	syscall
	
	li $v0, 5 # input
	syscall
	
	beq $v0, 0, end_main_loop # jezeli 0 to koniec
	
	bgt $v0, 1, if_pop
	
	#jezeli 1 to push
	
	jal push_on_stack
	
	j main_loop
	
if_pop:
	bgt $v0, 2, main_loop # wprowadzone zle operacje - wracamy do poczatku
	
	# jezeli 2 to pop
	
	# jezeli t7 wskazuje na poczatek stosu to nie mozna pop
	beq $t7, $sp, warn_user
	
	jal display
	
	j main_loop
	
warn_user:
	la $a0, warning
	li $v0, 4
	syscall

	# po warningu wracamy na poczatek
	j main_loop

end_main_loop:

	li $v0, 10
	syscall
	

push_on_stack:
	la $a0, pytanie 
	li $v0, 4
	syscall
	
	li $v0, 6
	syscall
	
	subiu $sp, $sp, 4 # przesuwamy wskaznik stosu
	
	mfc1 $v0, $f0 # wynik jest w f0, przenosimy do v0
	
	sw $v0, 0($sp) # zapisujemy na stosie

	jr $ra


display:
	lwc1 $f12, 0($sp) # laduje do f12 wartosc ze stosu
	addiu $sp, $sp, 4 # zmniejszamy stos
	
	li $v0, 2
	syscall
	
	jr $ra
	
.data
pytanie: .asciiz "\nPodaj floata\n"
pytanie_stack: .asciiz "\nOperacje: 0 - koniec, 1 - push, 2 - pop\n"
warning: .asciiz "\nWiecej op. pop niz push\n"