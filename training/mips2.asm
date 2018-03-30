.data
	.align 2
tab:	.space 128
.text
	addu $t1, $0, $0
zerol:	sb $0, tab($t1)
	addi $t1, $t1, 1
	ble $t1, 127, zerol
	
	li $t1, 32
textr:	li $v0, 12
	syscall
	beqz $v0, bprint
	beq $v0, 10, bprint	#if it is the end of standard input (or user pressed enter) break the loop
	lb $s0, tab($v0)
	addi $s0, $s0, 1
	sb $s0, tab($v0)
	b textr

bprint:	li $s0, 32		#s0 stores actuall char
go:	lb $t3, tab($s0)	#t3 stores times of char
	la $s1, ($s0)
	addi $s0, $s0, 1
	beq $s1, 122, end
	beqz $t3, go
	la $a0, ($s1)		#print char
	li $v0, 11
	syscall
	la $a0, ($t3)		#print how many times it was typed
	li $v0, 1
	syscall
	b go
	
end:	li $v0, 10
	syscall
