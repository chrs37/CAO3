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

# Register Usage
# $s0 location of a[0] on the stack
# $s1 location of b[0] on the stack
# $s2 size n
# $s3 counter for the array (i)
# $s4 return address
isort:		sub 	$sp, $sp, 20
		sw 	$s0, 0($sp) 	# Save s0 to the stack
		sw 	$s1, 4($sp) 	# Save s1 to the stack
		sw 	$s2, 8($sp) 	# Save s2 to the stack
		sw 	$s3, 12($sp) 	# Save s3 to the stack
		sw 	$s4, 16($sp) 	# Save s4 to the stack

		move 	$s0, $a0	# Store a[0] in $s0
		move 	$s2, $a1	# Store n in $s2
		move	$s3, $zero	# i = 0
				
		sll	$t0, $s2, 2	# $t0=n*4
		sub	$sp, $sp, $t0	# Decrease the stack pointer by n*4
		move 	$s1, $sp	# $s1=$sp, thus $s1 is b[0]	
		move 	$s4, $ra
		### END OF SETUP ###

		# TEST CODE #
		move 	$t6, $s1		# $t1 = b[0] 

isort_for:	beq	$s3, $s2, isort_for_end 	# Loop for n ($s2) times
		### BEGIN FOR LOOP ###
		
		# TEST CODE #		
		sw	$s3, 0($t6)		# b[i] = $s3
		addi 	$t6, $t6, 4		# b[i+1]	
		
		jal    	bin_search
			# int position = binarySearch (b, i, a[i]);
			# insert (b, i, a[i], position);
		
		### END FOR LOOP ##
		addi 	$s3, $s3, 1		# i=i+1
		j	isort_for		# Jump back to loop top

isort_for_end: j copy_array	
		
### The routine copy_array copies the content of array b[] (in $s1) to a[] (in $s0) ###	
copy_array:	move	$s3, $zero		# i = 0
		move 	$t1, $s1		# $t1 = b[0]
		move 	$t2, $s0		# $t2 = a[0]
	
copy_for:	beq	$s3, $s2, exit_sorti	# Loop for $a1 (array size) times
		### BEGIN FOR LOOP ###
		
		lw	$t3, 0($t1)		# $t3 = b[i]
		sw	$t3, 0($t2)		# a[i] = $t3
		
		addi 	$t1, $t1, 4		#b[i+1]
		addi 	$t2, $t2, 4		#a[i+1]
		
		### END FOR LOOP ##
		addi 	$s3, $s3, 1		# i=i+1
		j	copy_for		# Jump back to loop top

exit_sorti:	move 	$ra, $s4		# Restore $RA
		sll	$t1, $a1, 2		# $t1=n*4
		add	$sp, $sp, $t1		# Remove b[] from the stack
		lw	$s0, 0($sp)		# restore s0
		lw	$s1, 4($sp)		# restore s1
		lw	$s2, 8($sp)		# restore s2
		lw	$s3, 12($sp)		# restore s3
		lw	$s4, 16($sp)		# restore s4
		add 	$sp, $sp, 20		
		jr 	$ra			# Retrun to main Program
		

### Binary Search ###
# $a0 contains a[]
# $a1 contains 'lenght'
# $a2 contains 'elem'

# $t0 is low
# $t1 is high
# $t2 is mid
bin_search:	addi $t0, $t0, -1	# low = -1
		move $t1, $a1		# high = lenght
		move $t2, $zero

bin_while: 	sub $t4, $t1, 1 	# $t4 = high -1
		bge $t0, $t4, bin_return
		
		add $t2, $t0, $t1
		sra $t2, $t2, 1
		
		j bin_while
	
bin_return: 	jr $ra	