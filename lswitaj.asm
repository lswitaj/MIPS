.data
	.align 3
	.space 2
header:	.space 54
namein:	.space 256
name2:	.asciiz "/home/lswitaj/Pulpit/ARKO/out.bmp"
n1:	.asciiz "Podaj nazwe pliku: "
n2:	.asciiz "Podaj kierunek ( -1 - w lewo, 1 - w prawo ): "
n3:	.asciiz "Podaj ilosc obrotow: "
n4:	.asciiz "Nie udalo sie otworzyc pliku"

#s0 = rotation times
#s1 = in file descriptor
#s2 = out file descriptor
#s3 = old width
#s4 = old height
#s5 = new width
#s6 = new height
#s7 = new dopelnie
#t9 = adress of buf of old bmp
#t8 = adress of buf of new bmp
#t3 = size new buf
.text
main:	la $a0, n1
	li $v0, 4
	syscall
	
	la $a0, namein		#read string
	li $a1, 256	
	li $v0, 8
	syscall
	li $t0, -1		#for loop - find end of string (enter)
rloop:	addi $t0, $t0, 1
	lb $t1, namein($t0)
	beqz $t1, next	#if it is 0
	bne $t1, 10, rloop	#if it is enter replace this byte by 0
	sb $0, namein($t0)

next:	la $a0, n2		#chose direction
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	addu $t0, $v0, $0	#t0 = direction
	la $a0, n3		#chose how many times
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	mul $t0, $t0, $v0	#calc how many times you have to rotate
	li $t1, 4		#t0%4
	div $t0, $t1
	mfhi $t0
	addi $t0, $t0, 4	
	div $t0, $t1		#high = remainer of divide
	mfhi $s0		#s0 = rotation times
	
	addu $a0, $s0, $0
	li $v0, 1
	syscall
	
open1:	la $a0, namein		#open file
	li $a1, 0
	li $v0, 13
	syscall
	bltz $v0, error1
	addu $s1, $v0, $0
	
open2:	la $a0, name2		#open file to save
	li $a1, 1
	li $v0, 13
	syscall
	bltz $v0, error2
	addu $s2, $v0, $0
	
######################################################################################################################
head:	addu $a0, $s1, $0	#read header
	la $a1, header
	li $a2, 54 
	li $v0, 14		#pointer on file[64]
	syscall
	lw $t6, header+34	# t6 = old size
	lw $s3, header + 18
	lw $s4, header + 22
	
	li $t0, 2
	div $s0, $t0
	mfhi $t1
	beqz $t1, same
	addu $s5, $s4, $0	#1 or 3 rotations
	addu $s6, $s3, $0
	b after
same:	addu $s5, $s3, $0	#0 or 2
	addu $s6, $s4, $0

after:	li $t0, 3		
	mul $t2, $s5, $t0	#t2 = new width * 3		
	
	li $t0, 4
	div $s5, $t0
	mfhi $s7		#s7 = t1 % 4
	
	add $t2, $t2, $s7	#width + dopelnienie
	mul $t3, $t2, $s6		#t3 = new size!!!!!		

	li $t0, 2
	div $s0, $t0
	mfhi $t1
	beqz $t1, hedOUT
	
	sw $s5, header+18	#new width and height
	sw $s6, header+22
	sw $t3, header+34	#new size
	lw $t4, header+38	#swap resolutions
	lw $t5, header+42
	sw $t5, header+38
	sw $t4, header+42
	
hedOUT:	li $v0, 15
	addu $a0, $s2, $0
	la $a1, header
	li $a2, 54
	syscall	
	
alloc:	li $v0, 9
	addu $a0, $t6, $0
	syscall
	addu $t9, $v0, $0	#t9 is address of allocated memory
	
		
bmpbuf:	li $v0, 14
	addu $a0, $s1, $0
	addu $a1, $t9, $0
	addu $a2, $t6, $0
	syscall			#old bmp is in buf which starts at t9
	
	beqz $s0, case0

alloc2:	li $v0, 9
	addu $a0, $t3, $0
	syscall
	addu $t8, $v0, $0	#t8 is address of allocated memory
	
	addu $t0, $0, $0
	beq $s0, 2, case2 
	beq $s0, 3, case3
case1:	
	addi $t1, $s3, -1
pet11:	
	addu $t2, $0, $0			#actual byte = t1*width + t0
pet12:	
	jal in13

	addi $t2, $t2, 1
	blt $t2, $s4, pet12

	jal dopD
		
	addi $t1, $t1, -1
	bgez $t1, pet11
	
	j endP
case3:	
	addi $t1, $0, 0
pet31:	
	addi $t2, $s4, -1			#actual byte = t1*width + t0
pet32:	
	jal in13

	addi $t2, $t2, -1
	bgez $t2, pet32

	jal dopD	
		
	addi $t1, $t1, 1
	blt $t1, $s3, pet31
	
	j endP
case2:	
	addi $t1, $s4, -1
pet1:	
	mul $t2, $s3, 3			#actual byte = t1*width + t0
	addi $t2, $t2, -3	#t2 = width - 3, because all pixels has 3 bytes
pet2:	
	mul $t6, $s3, 3
	add $t6, $t6, $s7
	mul $t6, $t6, $t1		
	add $t6, $t6, $t2	#t6 = ((t1*width)++) + t2
	add $t6, $t6, $t9  	#t6 = input buffer address + t6
	
	jal sl

	addi $t2, $t2, -3
	bgez $t2, pet2

	jal dopD
		
	addi $t1, $t1, -1
	bgez $t1, pet1
########################################################################################################################	
endP:	
	li $v0, 15
	addu $a0, $s2, $0
	addu $a1, $t8, $0
	addu $a2, $t3, $0
	syscall	
	
endP0:	addu $a0, $s2, $0	#close out file
	li $v0, 16	
	syscall
	
clsIN:	addu $a0, $s1, $0	#close file
	li $v0, 16
	syscall
	
end:	li $v0, 10
	syscall
	
error1:	la $a0, n4
	li $v0, 4
	syscall
	j end
	
error2:	la $a0, n4
	li $v0, 4
	syscall
	j clsIN
case0:	li $v0, 15
	addu $a0, $s2, $0
	addu $a1, $t9, $0
	addu $a2, $t6, $0
	syscall	
	j endP0

##function
dopD:	beqz $s7, dopE
	addu $t2, $0, $s7
dop:	add $t7, $t8, $t0
	sb $0, ($t7)
	addi $t0, $t0, 1
	addi $t2, $t2, -1
	bgtz $t2 dop
dopE:	
	jr $ra
##function2	
in13:	mul $t6, $s3, 3
	
	li $t7, 4
	div  $s3, $t7
	mfhi $t7		# old dopelnienie
	add $t6, $t6, $t7	# szerokosc stara w BAJTACH
	
	mul $t6, $t6, $t2
	
	mul $t7, $t1, 3	
	add $t6, $t6, $t7	###   #t6 = ((t1*width)++) + t2
	add $t6, $t6, $t9
	
	###
	addi $sp, $sp, -4
	sw $ra, ($sp) 		# ra in stack
	
	jal sl
	
	lw $ra, ($sp)		# ra out stack
	addi $sp, $sp, 4
	###
	jr $ra
	
sl:	add $t7, $t8, $t0	#t7 = output buffer adress + t0 (loop iterator)
	
	lbu $t4, ($t6)		#read and save to buffer 3 pixels
	sb $t4, ($t7)
	lbu $t4, 1($t6)
	sb $t4, 1($t7)
	lbu $t4, 2($t6)
	sb $t4, 2($t7)
	
	addi $t0, $t0, 3
	
	jr $ra
