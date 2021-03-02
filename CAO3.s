		.text
		j	main			# Jump to main-routine

		.data
str1:		.asciiz "Insert the array size \n"
str2:		.asciiz "Insert the array elements,one per line  \n"
str3:		.asciiz "The sorted array is : \n"
str5:		.asciiz "\n"

		.text
		.globl	main
main: 
		la	$a0, str1		# Print of str1
		li	$v0, 4			#
		syscall				#

		li	$v0, 5			# Get the array size(n) and
		syscall				# and put it in $v0
		move	$s2, $v0		# $s2=n
		sll	$s0, $v0, 2		# $s0=n*4
		sub	$sp, $sp, $s0		# This instruction creates a stack
						# frame large enough to contain
						# the array
		la	$a0, str2		#
		li	$v0, 4			# Print of str2
		syscall				#
            
		move	$s1, $zero		# i=0
for_get:	bge	$s1, $s2, exit_get	# if i>=n go to exit_for_get
		sll	$t0, $s1, 2		# $t0=i*4
		add	$t1, $t0, $sp		# $t1=$sp+i*4
		li	$v0, 5			# Get one element of the array
		syscall				#
		sw	$v0, 0($t1)		# The element is stored
						# at the address $t1
		la	$a0, str5
		li	$v0, 4
		syscall
		addi	$s1, $s1, 1		# i=i+1
		j	for_get
exit_get:	move	$a0, $sp		# $a0=base address af the array
		move	$a1, $s2		# $a1=size of the array
		jal	isort			# isort(a,n)
						# In this moment the array has been 
						# sorted and is in the stack frame 
		la	$a0, str3		# Print of str3
		li	$v0, 4
		syscall

		move	$s1, $zero		# i=0
for_print:	bge	$s1, $s2, exit_print	# if i>=n go to exit_print
		sll	$t0, $s1, 2		# $t0=i*4
		add	$t1, $sp, $t0		# $t1=address of a[i]
		lw	$a0, 0($t1)		#
		li	$v0, 1			# print of the element a[i]
		syscall				#

		la	$a0, str5
		li	$v0, 4
		syscall
		addi	$s1, $s1, 1		# i=i+1
		j	for_print
exit_print:	add	$sp, $sp, $s0		# elimination of the stack frame 
              	
		li	$v0, 10			# EXIT
		syscall				#


isort:		move	$t0, $zero		# i = 0
		sll	$t1, $a1, 2		# $t0=n*4
		sub 	$t1, $a0, $t1		# $t1=$sp-n*4	$t1 is the location of b[i]
		# other setup
isort_for:	beq	$t0, $a1, copy_array	# Loop for $a1 (array size) times
		### BEGIN FOR LOOP ###
		
			# int position = binarySearch (b, i, a[i]);
			# insert (b, i, a[i], position);
		
		### END FOR LOOP ##
		addi 	$t0, $t0, 1		# i=i+1
		j	isort_for		# Jump back to loop top

		
# Copys array b[] to a[]		
copy_array:	move	$t0, $zero		# i = 0
		addi 	$t2, $a0, 0		#$t2 = a[i]; $t1 = b[i]
	
copy_for:	beq	$t0, $a1, exit_sorti	# Loop for $a1 (array size) times
		### BEGIN FOR LOOP ###
		
		
		lw	$t3, 0($t1)		# $t3 = b[i]
		sw	$t3, 0($t2)		# a[i] = $t3
		
		addi 	$t1, $t1, 4		#b[i+1]
		addi 	$t2, $t2, 4		#a[i+1]
		
		### END FOR LOOP ##
		addi 	$t0, $t0, 1		# i=i+1
		j	copy_for		# Jump back to loop top

exit_sorti:	jr 	$ra			# Retrun to main Program
		
