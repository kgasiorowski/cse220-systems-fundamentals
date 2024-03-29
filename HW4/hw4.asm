##############################################################
# Homework #4
# name: MY_NAME
# sbuid: MY_SBU_ID
##############################################################
.text

.macro push(%reg)
	addi $sp, $sp, -4
	sw %reg,($sp)	
.end_macro

.macro pop(%reg)
	lw %reg,($sp)
	addi $sp, $sp, 4
.end_macro

.macro inc(%reg)
	addi %reg, %reg, 1
.end_macro

.macro dec(%reg)
	addi %reg, %reg, -1
.end_macro

.macro print_int(%reg)
	push($v0)
	push($a0)
	move $a0, %reg
	li $v0, 1
	syscall
	pop($a0)
	pop($v0)
.end_macro

.macro newline()
	push($v0)
	push($a0)
	li $a0, '\n'
	li $v0, 11
	syscall
	pop($a0)
	pop($v0)
.end_macro

.macro get_node(%base_addr, %arr_indx)
	push($t0)
	sll $t0, %arr_indx, 2
	addu $t0, $t0, %base_addr
	lw $v0, ($t0)
	pop($t0)
.end_macro

.macro set_node(%base_addr, %arr_indx, %value)
	push($t0)
	sll $t0, %arr_indx, 2
	addu $t0, $t0, %base_addr
	sw %value, ($t0)
	pop($t0)
.end_macro

##############################
# PART 1 FUNCTIONS
##############################

preorder:
    # $a0 - address of the current node
    # $a1 - base address of the array of nodes
    # $a2 - file descriptor
    # do not change base array or FD
   	
    push($ra)	
    push($s0)	# $s0 - left index
    push($s1)	# Ss1 - right index
    push($s2)	# $s2 - node value
    
    move $s3, $a0
    move $s4, $a1
    move $s5, $a2
    
    lw $t0, ($a0)
    andi $s2, $t0, 0xFFFF 	# Get the node value
    andi $s0, $t0, 0xFF000000
    srl $s0, $s0, 24		# Get left index
    andi $s1, $t0, 0xFF0000
    srl $s1, $s1, 16		# Get right index
    
    push($a0)
    push($a1)
    push($a2)
    # Code to write it to file here
    move $a0, $s2
    move $a1, $a2
    jal itof
    
    pop($a2)
    pop($a1)
    pop($a0)
    
leftpreorder:
    beq $s0, 255, rightpreorder
    
    sll $t1, $s0, 2				# Mult by 4, since each word is 4 bytes
    addu $a0, $t1, $a1			# Add it to the base memory address
    
    jal preorder
    
rightpreorder:
	beq $s1, 255, preorderexit

	sll $t1, $s1, 2				# Mult by 4, since each word is 4 bytes
	addu $a0, $t1, $a1			# Add it to the base memory address
	
	jal preorder

preorderexit:

	pop($s2)
	pop($s1)
	pop($s0)
    pop($ra)
	jr $ra

itof:
	# $a0 - integer to write to file
	# $a1 - file descriptor
	
	# While the quotient is not zero,
	# 	Get a digit, calc ascii value (char + '0'), push it to the stack
	# 	Count++
	# For every count, 
	#	pop a digit off the stack,
	# 	write it to the output buffer,
	#	syscall write to file with 1 char
	# Write a newline at the end
	
	# $t0 - count
	# $t1 - quotient
	# $t2 - remainder
	# $t3 - 10
	
	li $t3, 10
	li $t0, 0
	li $a2, 1
	
	move $t9, $a1 # Save file descriptor
	
	andi $t8, $a0, 0x8000
	
	beqz $t8, itof0		# If its positive, skip all this
	
	push($t0)
	push($t9)
	push($v0)
	push($a0)
	push($a1)
	push($a2)
	
	li $t0, '-'
	sb $t0, buffer
	
	move $a0, $t9
	la $a1, buffer
	li $a2, 1
	li $v0, 15
	syscall

	li $t0, 0
	sb $t0, buffer

	pop($a2)
	pop($a1)
	pop($a0)
	pop($v0)
	pop($t9)
	pop($t0)
	
	xori $a0, $a0, 0xFFFF
	addi $a0, $a0, 1	# Convert to positive
	
	
itof0:
	
	div $a0, $t3	# Divide by 10
	mflo $a0		# Get the quotient
	mfhi $t2		# Get the remainder
	
	addi $t2, $t2, '0'	# Calculate the ascii value of this digit
	push($t2)			# Push it on to the stack
	inc($t0)			# Increment our counter
	
	bnez $a0, itof0		# If the quotient is zero, no more digits!
	
itof1:

	pop($t1)			# Pop a digit off the stack
	sb $t1, buffer		# Write it to the output buffer
	
	move $a0, $t9		# Write the digit to the file
	la $a1, buffer
	li $v0, 15
	syscall
	
	dec($t0)			# Decrement count
	bnez $t0, itof1		# Loop
	
	li $t0, '\n'
	sb $t0, buffer
	
	move $a0, $t9
	la $a1, buffer
	li $a2, 1
	li $v0, 15
	syscall
	
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

linear_search:

	# Create static masking byte:0x80 ($t0) doesn't change

	# Decrement byte array pointer
	# label1
	# Increment byte array pointer
	# Load that byte
	# reset masking byte
	# label2
	# mask loaded byte with masking byte
	# if its nonzero, return count
	# increment count
	# if count > maxsize, return negative
	# shift mask to the left by 1
	# if masking byte is 256, j label1
	# j label2
	
	# $t1 - masking byte
	# $t2 - byte array pointer
	# $t3 - current (loaded) byte
	# $t4 - mask result
	# $t5 - count
	# $t6 - maxsize

	addi $t2, $a0, -1
	move $t6, $a1
	li $t5, 0
	
LS1:
	inc($t2)		# Increment byte array pointer
	lb $t3, ($t2)	# Load the newest byte
	li $t1, 1		# Reset the mask

LS2:
	and $t4, $t1, $t3		# Mask the byte
	beqz $t4, LSreturn		# If its zero, return with the current index
	inc($t5)				# Otherwise increment the index
	bgt $t5, $t6, LSfail		# If the index is > maxsize, return failure
	sll $t1, $t1, 1			# Shift the mask over one
	beq $t1, 256, LS1		# if the mask is zero, load the next byte and reset the max
	j LS2					# otherwise read the next bit

LSreturn:
	move $v0, $t5
	jr $ra

LSfail:
	li $v0, -1
	jr $ra
    
###################################################
set_flag:
	addi $t0, $a3, -1
	bgt $a1, $t0, SFfail
	
	# $a0 array pointer
	# $a1 index to write [0 -> (maxsize-1)]
	# $a2 setValue
	# $a3 maxsize
	
	andi $t0, $a1, 7	# Remainder div/8
	srl $t1, $a1, 3		# Quotient div/8
	
	add $t2, $a0, $t1	# Offset it by the number of bytes
	lbu $t3, ($t2)		# Load the byte at this location
	# Don't change $t2 from here out
	
	li $t4, 1			# Set it to the rightmost bit
	sllv $t4, $t4, $t0	# Shift it over how ever many times needed
	not $t4, $t4		# Flip it, since we want all the bits except this one
	
	and $t5, $t3, $t4	# Mask for all the bits except the one we want

	andi $t6, $a2, 1	# Mask for only the first bit
	sllv $t6, $t6, $t0	# Offset it to match the thing
	
	or $t5, $t6, $t5
	sb $t5, ($t2)
	
SFreturn:
	li $v0, 1
	jr $ra

SFfail:
    li $v0, 0
    jr $ra
###################################################
find_position:

	# $a0 - nodes array
	# $a1 - index
	# $a2 - newvalue
	
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	
	move $s4, $a1
	sll $s0, $a2, 16	# Erase upper 16 bits
	sra $s0, $s0, 16	# Sign extend lower 16 bits

						# $s0 has newvalue
						# $s1 has node value
						# $s2 has left index
						# $s3 has right index
						# $s4 has the current index
	
	sll $t0, $a1, 2
	add $t1, $a0, $t0	# Calculate correct address
	
	lw $t0, ($t1)
    andi $s1, $t0, 0xFFFF 	# Get the node value
    andi $s2, $t0, 0xFF000000
    srl $s2, $s2, 24		# Get left index
    andi $s3, $t0, 0xFF0000
    srl $s3, $s3, 16		# Get right index

FPleftindex:
	
	bge $s0, $s1, FPrightindex	# if(newvalue < nodes[currIndex].value)
	bne $s2, 255, FPleftelse	# if(leftindex == 255)
	
	move $v0, $a1				# 
	li $v1, 0					# return currIndex, 0
	
	j FPreturn
FPleftelse:
	
	move $a1, $s2				# Set the argument to left node		
	
	jal find_position			
	j FPreturn					# Return find_position
	
FPrightindex:
	
	bne $s3, 255, FPrightelse	# if(rightIndex == 255)
	
	move $v0, $a1
	li $v1, 1
	
	j FPreturn					# Return currIndex, 1
FPrightelse:

	move $a1, $s3				# Set the argument to right node

	jal find_position			
	j FPreturn					# Return find_position

FPreturn:
	# pop everything before returning
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
###################################################
add_node:
    
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    
    # $a0 - nodes array - $s0
    # $a1 - rootIndex - $s1
    # $a2 - newValue - $s2
    # $a3 - newIndex - $s3
    # top stack - maxsize - $s4
    # next on stack - flags array - $s5
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    move $s4, $t0
    move $s5, $t1
    
    andi $s1, $s1, 0xFF
    andi $s3, $s3, 0xFF
    
    bge $s1, $s4, ANreturn0
    bge $s3, $s4, ANreturn0
    
    sll $s2, $s2, 16
    sra $s2, $s2, 16
    
    # boolean validRoot = nodeExists(rootIndex);
    
    move $a0, $s5
    move $a1, $s1
	jal nodeExists # FIX ME
	
	beqz $v0, rootNotExists
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal find_position
	
	# $v0 parent index
	# $v1 left or right, 1 = right 0 = left
	
	sll $t1, $v0, 2
	addu $t0, $s0, $t1
	lw $t2, ($t0)
	
	beq $v1, 1, ANifright
		
		andi $t2, $t2, 0xFFFFFF	# Set the left or something
		sll $t3, $s3, 24
		or $t2, $t2, $t3
		sw $t2, ($t0)
	
	j ANexitIF
ANifright:
	
		andi $t2, $t2, 0xFF00FFFF	# Set the right or something
		sll $t3, $s3, 16
		or $t2, $t2, $t3
		sw $t2, ($t0)
	
	j ANexitIF
rootNotExists:

	move $s3, $s1	# There's no node, so set it or something

ANexitIF:

	# Executed regardless of which statements in the if is executed
	sll $t1, $s3, 2
	addu $t0, $s0, $t1
	li $t2, 0xFFFF0000
	or $t2, $t2, $s2
	
	sw $t2, ($t0)
	
	move $a0, $s5
	move $a1, $s3
	li $a2, 1
	move $a3, $s4
	
	jal set_flag
	j ANreturn
	
ANreturn0:
	li $v0, 0
ANreturn:
    pop($s5)
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
	jr $ra

##############################
# PART 3 FUNCTIONS
##############################
get_parent:
    
    push($ra)
    
    # $a0 - base address of nodes array
    # $a1 - current index
    # $a2 - child value
    # $a3 - child index
    
    # $v0 - 0 if left of parent, 1 if right, x if parent was not found
    
    andi $a3, $a3, 0xFF	# To unsigned byte
    sll $a2, $a2, 16
    sra $a2, $a2, 16	# To signed halfword
    
    get_node($a0, $a1)
    move $t0, $v0
    andi $t1, $t0, 0xFFFF	# Current node value
    
    bge $a2, $t1, GPchildGreater
    
    	andi $t2, $t0, 0xFF00000	
    	srl $t2, $t2, 24	# Left index
    
    	bne $t2, 255, GPLeftNot255
    	
    		# Return -1, x
    		li $v0, -1
    		j GPreturn
    	
    	GPLeftNot255:
    	bne $t2, $a3, GPLeftElse
    		
    		# Return current index, 0
    		move $v0, $a1
    		li $v1, 0
    		j GPreturn
    
    	GPLeftElse:
    	
    		# Otherwise recursive call
    		move $a1, $t2
    		jal get_parent
    		j GPreturn
    
GPchildGreater:
    
    	andi $t2, $t0, 0xFF0000
    	srl $t2, $t2, 16
    	
    	bne $t2, 255, GPRightNot255
    	
    		# Return -1, x
    		li $v0, -1
    		j GPreturn
    		
    	GPRightNot255:
    	bne $t2, $a3, GPRightElse
    	
    		# Return current index, 1
    		move $v0, $a1
    		li $v1, 1
    		j GPreturn
    		
    	GPRightElse:
    		
    		# Otherwise recursive call
    		move $a1, $t2
    		jal get_parent
    		j GPreturn
    
GPreturn:
    pop($ra)
    jr $ra
##############################
find_min:
	push($ra)
	
	sll $t0, $a1, 2				# Multiply offset by 4
	addu $t0, $t0, $a0			# Add the offset to base address
	lw $t0, ($t0)				# Load the byte
	move $t2, $t0				# Save loaded byte for now
	andi $t0, $t0, 0xFF000000	# Mask for the left index
	srl $t0, $t0, 24				# Shift it over

	bne $t0, 0xFF, FMrecursive	# If there is a node there, do a recursive call
							# Otherwise this is the furthest left node
		move $v0, $a1			# Return current index

		andi $t0, $t2, 0xFF0000	# Mask for right index
		srl $t0, $t0, 16			# Shift it over

		bne $t0, 0xFF, FM1		# Branch if it is not a leaf
		li $v1, 1				# Otherwise it's a leaf
		j FM2
FM1:		li $v1, 0				# It's not a leaf
FM2:
							# Return
		pop($ra)
		jr $ra
	
FMrecursive:
		move $a1, $t0			# Load the left index as an arg
		jal find_min			# Recursive call
		pop($ra)				# Return from recursive call
		jr $ra				
#############################################
delete_node:
    
    # $a0 - nodes array -> 	$s0
    # $a1 - rootIndex -> 	$s1
    # $a2 - deleteIndex	->	$s2
    # $a3 - flags array ->	$s3
    # $sp ($t0) - maxSize ->$s4
    # delete node data ->	$s5
    # Child index ->		$s6
    
    lw $t0, ($sp)
    
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    push($s5)
    push($s6)
    push($s7)
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    move $s4, $t0
    
    andi $s1, $s1, 0xFF
    andi $s2, $s2, 0xFF
    
    blt $s1, $s4, DNreturn0
    blt $s2, $s4, DNreturn0
    
    move $a0, $s3
    move $a1, $s1
    jal nodeExists
    beqz $v0, DNreturn0
    
    move $a0, $s3
    move $a1, $s2
    jal nodeExists
    beqz $v0, DNreturn0
    
    get_node($s0, $s2)
    move $a0, $v0
    move $s5, $v0
    jal isLeaf
    
    beq $v0, 0, DNNotLeaf
    
    	move $a0, $s3
    	move $a1, $s2
    	li $a2, 0
    	move $a3, $s4
    	jal set_flag
    	
    	bne $s2, $s1, DN0
			
			li $v0, 1
			j DNreturn0
			
		DN0:

		move $a0, $s0
		move $a1, $s1
		andi $a2, $s5, 0xFFFF
		move $a3, $s2
		jal get_parent
		
		move $t1, $v0					# Parent index
		get_node($s0, $t1)				# Load the parent node
		
		beq $v1, 1, DN1
		
			andi $t0, $v0, 0xFFFFFF		# Delete the left index
			ori $t0, $v0, 0xFF000000	# Set the left index to 255
			set_node($s0, $t1, $t0)
			j DN2
		
		DN1:
		
			andi $t0, $v0, 0xFF00FFFF	# Delete the right index
			ori $t0, $v0, 0xFF0000		# Set the right index to 255
			set_node($s0, $t1, $t0)
		DN2:
			
		li $v0, 1
		j DNreturn

DNNotLeaf:
	
	move $a0, $s5
	jal numChildren
	
	bne $v0, 1, DNNotHasOneChild

		andi $t0, $s5, 0xFF000000
		srl $t0, $t0, 24
		
		beq $t0, 255, DNHasRightChildOnly
		
			move $s6, $t0
			j DNskip0
			
		DNHasRightChildOnly:	
		
			andi $t1, $s5, 0xFF0000
			srl $t1, $t1, 16
			move $s6, $t1
			
		DNskip0:
		
		bne $s2, $s1, DNskip1
		
			get_node($s0, $s6)
			set_node($s0, $s2, $v0)
			
			move $a0, $s3
			move $a1, $s6
			li $a2, 0
			move $a3, $s4
			jal set_flag
			
			li $v0, 1
			j DNreturn
		
		DNskip1:		
		
		move $a0, $s0
		move $a1, $s1
		andi $a2, $s5, 0xFFFF
		move $a3, $s2
		jal get_parent
		
		move $t0, $v0	# Parent index
		
		beq $v1, 1, DN4
		# Left
			get_node($s0, $t0)
			andi $t2, $v0, 0xFFFFFF
			sll $t1, $s6, 24
			or $t2, $t2, $t1
			set_node($s0, $t0, $t2)
		
		j DN5
		DN4:
		# Right
			get_node($s0, $t0)
			andi $t2, $v0, 0xFF00FFFF
			sll $t1, $s6, 16
			or $t2, $t2, $t1
			set_node($s0, $t0, $t2)
		
		DN5:
		
		move $a0, $s0
		move $a1, $s2
		li $a2, 0
		move $a3, $s4
		jal set_flag
		
		li $v0, 1
		j DNreturn
			
DNNotHasOneChild:
	
	move $a0, $s0
	andi $a1, $s5, 0xFF0000
	srl $a1, $a1, 16
	jal find_min
	
	move $s7, $v0		# Min index
	move $t1, $v1		# min is leaf
	
	get_node($s0, $s7)
	move $t2, $v0		# Data stored at min index
	
	move $a0, $s0
	move $a1, $s2
	andi $a2, $t2, 0xFFFF
	move $a3, $s7
	
	push($t0)
	push($t1)
	push($t2)
	jal get_parent
	pop($t2)
	pop($t1)
	pop($t0)
	
	move $t3, $v0		# parent index
	move $t4, $v1		# leftOrRight
	
	bnez $t1, DN6		# If it is a leaf
	
		get_node($s0, $t3)
		
		beq $t4, 1, DN8	# If it is left
			
			ori $v0, $v0, 0xFF000000
			set_node($s0, $t3, $v0)
			
		j DN7
		DN8:			# If it is right
		
			ori $v0, $v0, 0xFF0000
			set_node($s0, $t3, $v0)
		
		j DN7
	DN6:				# If it is not a leaf
	
		get_node($s0, $t3)
		move $t5, $v0	# Parent node
		
		get_node($s0, $s7)
		andi $t6, $v0, 0xFF0000 # Min right already shifted
		
		beq $t4, 1, DN9	# If it is left
	
			sll $t1, $t6, 2
			andi $t5, $t5, 0xFFFFFF	# Erase left reference
			and $t5, $t5, $t1		# Set left reference
			set_node($s0, $t3, $t5)
		
		j DN7
		DN9:			# Else if it is right
	
			andi $t5, $t5, 0xFF00FFFF
			and $t5, $t5, $t6
			set_node($s0, $t3, $t5)
	
	DN7:
	
	get_node($s0, $s2)
	move $t0, $v0		# Delete node
	
	get_node($s0, $s7)
	move $t1, $v0		# Min node
	
	andi $t0, $t0, 0xFFFF0000
	andi $t1, $t1, 0xFFFF
	and $t0, $t0, $t1
	
	set_node($s0, $s2, $t0)
	
	move $a0, $s3
	move $a1, $s7
	li $a2, 0
	move $a3, $s4
	jal set_flag
	
	li $v0, 1
	j DNreturn
	
DNreturn0:
	li $v0, 0
DNreturn:
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
    pop($ra)
    jr $ra
##############################
nodeExists:
	# $a0 - has the pointer to the flag array
	# $a1 - has the index to check
	push($s0)
	push($s1)
	
	andi $s0, $a1, 7	# Remainder div / 8
	srl $s1, $a1, 3		# Quotient div / 8
	
	add $s1, $s1, $a0
	lb $s1, ($s1)
	
	srlv $s1, $s1, $s0
	andi $v0, $s1, 1
	
	pop($s1)
	pop($s0)
	jr $ra
##############################
isLeaf:
	# $a0 - node to check
	# Return true if it is a leaf, false otherwise
	push($s0)
	
	# Check left
	# Branch to check right
	
	andi $s0, $a0, 0xFF00000
	srl $s0, $s0, 24
	bne $s0, 0xFF, isNotLeaf
	
	andi $s0, $a0, 0xFF0000
	srl $s0, $s0, 16
	bne $s0, 0xFF, isNotLeaf
	
	li $v0, 1
	j isLeafReturn
	
isNotLeaf:
	li $v0, 0
isLeafReturn:
	pop($s0)
	jr $ra
##############################
numChildren:
	# $a0 - node to check
	push($s0)
	li $v0, 0
	
	andi $s0, $a0, 0xFF00000
	srl $s0, $s0, 24
	beq $s0, 255, NM0
	inc($v0)
NM0:
	andi $s0, $a0, 0xFF0000
	srl $s0, $s0, 16
	beq $s0, 255, NM1
	inc($v0)
NM1:
	pop($s0)
	jr $ra
##############################
# EXTRA CREDIT FUNCTION
##############################

add_random_nodes:
    #Define your code here
    jr $ra



#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary

buffer: .ascii ""

#place any additional data declarations here

