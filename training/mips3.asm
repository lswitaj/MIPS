.data
	.align 2
tab:	.space 128
wyraz:	.space 256
.text
	la $t1, ($0)
zerol:	sb $0, tab($t1)
	addi $t1, $t1, 1
	ble $t1, 127, zerol
	
textr:	la $a0, wyraz		#read string
	li $a1, 256
	li $v0, 8
	syscall
	
	la $t0, ($0)		#t0 is an iterator
textit:	lb $t1, wyraz($t0)	#t1 is temporary char
	lb $t2, tab($t1)	#t2 is temporary counter
	ble $t1, 96, end	#if it is char outside our set end the programm
	bge $t1, 123, end
	addi $t2, $t2, 1
	sb $t2, tab($t1)	
	
	la $a0, ($t1)		#print char
	li $v0, 11
	syscall
	la $a0, ($t2)		#print how many times it was typed
	li $v0, 1
	syscall

	addi $t0, $t0, 1

	j textit
	
end:	li $v0, 10
	syscall
