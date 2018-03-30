.data
	.align 2
buf:	.space 100

.text
	la $a0, buf
	li $a1, 100
	li $v0, 8
	syscall
	
	addu $s0, $0, $0
	
beg:	lbu $s1, buf($s0)
	beqz $s1, end
	
	ble $s1, 64, nthg
	ble $s1, 90, change
	ble $s1, 96, nthg
	ble $s1, 122, change

change:	xori $s1, $s1, 32
	sb $s1, buf($s0)

nthg:	addi $s0, $s0, 1
	b beg

end:	la $a0, buf
	li $v0, 4
	syscall
	li $v0, 10
	syscall