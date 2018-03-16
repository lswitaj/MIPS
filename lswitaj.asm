.data
	.align 3
	.space 2
header:	.space 64
namein:	.space 256
name2:	.asciiz "out.bmp"
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
	beq $t1, 0, next	#if it is 0
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
	mult $t0, $v0		#calc how many times you have to rotate
	mflo $t0
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
	li $a2, 64 
	li $v0, 14		#pointer on file[64]
	syscall
	
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
	mult $s5, $t0		
	mflo $t2		#t2 = new width * 3
	li $t0, 4
	div $t2, $t0
	mfhi $t1
	sub $t1, $t0, $t1	#t1 = 4 - t1
	div $t1, $t0
	mfhi $s7		#s7 = t1 % 4
	
	add $t2, $t2, $s7	#width + dopelnienie
	mult $t2, $s6
	mflo $t3		#new size!!!!!!
	####
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
	li $a2, 64
	syscall	
	
	################!!!!!!!!!!!!!!!!!!!!!!!
	
bmp:	########!!!!!!!!!!
	
########################################################################################################################	
	addu $a0, $s2, $0	#close out file
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