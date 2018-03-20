.data
	.align 2
tab:	.space 32

.text
input:	
	la $a0, tab
	addiu $a1, $0, 31
	li $v0, 8
	syscall

	addu $t0, $0, $0
output_and_change:
	lb $s0, tab($t0)
	beq $s0, 0, end
	beq $s0, 10, end
	
	ble $s0, 57, int_to_char	#changing
	bge $s0, 97, char_to_int	

after_change:
	addi $t0, $t0, 1	
	ble $t0, 30, output_and_change
		
end:	
	la $a0, tab
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall


char_to_int:
	addiu $s0, $s0, -49
	sb $s0, tab($t0)
	j after_change

int_to_char:
	addiu $s0, $s0, 49
	sb $s0, tab($t0)
	j after_change