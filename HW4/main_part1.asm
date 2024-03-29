#################################################################
# HW#4 Part 1: Testing Main for preorder
#################################################################
.text
.globl main

main:
	# open file
	li $v0, 13
	la $a0, file1
	li $a1, 1        # Open for writing (flags are 0: read, 1: write)
	li $a2, 0        # mode is ignored
	syscall          # open a file (file descriptor returned in $v0)
	move $s0, $v0    # save the file descriptor

	# Call preorder traversal of the tree starting at nodes2
	la $a0, nodes7
	move $a1, $a0
	move $a2, $s0
	jal preorder

	#print newline to file
	li $v0, 15
	move $a0, $s0
	la $a1, endl
	li $a2, 1
	syscall

	# close file
	li $v0, 16         # system call for close file
	move $a0, $s0      # file descriptor to close
	syscall            # close file

done:
	li $v0, 10
	syscall

.data
file1: .asciiz "preorder.trav"
endl: .asciiz "\n"

#################################################################
# PART 1 Testing Trees
#################################################################
.align 2

nodes2: .word 0x01060008 0x02030003 0xFFFF0001 0x04050006 0xFFFF0004 0xFFFF0007 0xFF07000A 0x08FF000E 0xFFFF000D #root 0, sample tree

# Additional testing cases
nodes1: .word 0xFFFF0001 # root node with 0 children - root 0
nodes3: .word 0x01FF0001 0xFFFF0002 # root node with 1 left child - root 0
nodes4: .word 0xFF010001 0xFFFF0003 # root node with 1 right child - root 0
nodes5: .word 0xFF030001 0xFFFF000F 0xFF010007 0xFF020003 # completely unbalanced tree - linked list to right (with nodes mixed up) - root 0
nodes6: .word 0x02FF0001 0x03FF0004 0x01FF0002 0xFFFF0008 # completely unbalanced tree - linked list to left (with nodes mixed up) - root 0
nodes7: .word 0x01060008 0x0203FFFD 0xFFFF0001 0x0405FFFA 0xFFFF0004 0xFFFFFFF9 0xFF07000A 0x08FFFFF2 0xFFFF000D # sample tree w/ negative nodes - root 0
nodes8: .word 0xFFFF0004 0x02030003 0xFFFF0001 0x00050006 0x01060008 0xFFFF0007 0xFF07000A 0x08FF000E 0xFFFF000D # sample tree - root 4

#################################################################
# Student defined functions will be included starting here
#################################################################

.include "hw4.asm"
