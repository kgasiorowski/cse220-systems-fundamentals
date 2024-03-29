##############################################################
# Do NOT place any functions in this file!
# This file is NOT part of your homework 2 submission.
#
# Modify this file or create new files to test your functions.
##############################################################

.data
str_input: .asciiz "Input: "
str_result: .asciiz "Result: "
str_return: .asciiz "Return: "

# atoui
atoui_header: .asciiz "\n\n********* atoui *********\n"
atoui_input: .ascii "723go1"
atoui_input1: .ascii "12#34"
atoui_input2: .ascii "15\0"

# uitoa
uitoa_header: .asciiz "\n\n********* uitoa *********\n"
uitoa_orig: .asciiz "Original:"

.align 2
uitoa_value: .word 987654321
uitoa_output: .asciiz "jeA8SAsd9123aslas"
.align 2
uitoa_outputSize: .word 10

.align 2
uitoa_value1: .word 999
uitoa_output1: .asciiz "abcdefgh"
.align 2
uitoa_outputSize1: .word 3

.align 2
uitoa_value2: .word 1234
uitoa_output2: .asciiz "aaaaaaaaaaaaa"
.align 2
uitoa_outputSize2: .word 2

.align 2
uitoa_value3: .word 0
uitoa_output3: .asciiz "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
.align 2
uitoa_outputSize3: .word 20

# decodedLength
decodedLength_header: .asciiz "\n\n********* decodedLength *********\n"
decodedLength_input: .asciiz "sss!j4q!F5"
decodedLength_runFlag: .ascii "!"

decodedLength_input1: .asciiz "sx*j24qyyy*g6"
decodedLength_runFlag1: .ascii "*"

decodedLength_input2: .asciiz "sss!j4q!F5"
decodedLength_runFlag2: .ascii "g"

decodedLength_input3: .asciiz "\0"
decodedLength_runFlag3: .ascii "!"

decodedLength_debug: .asciiz "Current char: "

# decodeRun
decodeRun_header: .asciiz "\n\n********* decodeRun *********\n"
decodeRun_letter: .ascii "G"
.align 2
decodeRun_runLength: .word 6
decodeRun_output: .asciiz "asd9u2j,as,j213se!"

decodeRun_letter1: .ascii "a"
.align 2
decodeRun_runLength1: .word 2
decodeRun_output1: .asciiz "bbbbbbbbbbbbb"

decodeRun_letter2: .ascii "3"
.align 2
decodeRun_runLength2: .word 5
decodeRun_output2: .asciiz "bbbbbbbbbbbbb"

decodeRun_letter3: .ascii "h"
.align 2
decodeRun_runLength3: .word -2
decodeRun_output3: .asciiz "bbbbbbbbbbbbb"

# runLengthDecode
runLengthDecode_header: .asciiz "\n\n********* runLengthDecode *********\n"
runLengthDecode_output: .asciiz "jhjkhasd987(!@q2j312kja214asasHJU!#Kasjd21"

runLengthDecode_input: .asciiz "sss!j4q!F5"
.align 2
runLengthDecode_outputSize: .word 18
runLengthDecode_runFlag: .ascii "!"

runLengthDecode_input1: .asciiz "*A5hhh*U11V"
.align 2
runLengthDecode_outputSize1: .word 8
runLengthDecode_runFlag1: .ascii "*"

runLengthDecode_input2: .asciiz "*A5hhh*U11V"
.align 2
runLengthDecode_outputSize2: .word 21
runLengthDecode_runFlag2: .ascii "*"

runLengthDecode_debug: .asciiz "Debug : "

# encodedLength
encodedLength_header: .asciiz "\n\n********* encodedLength *********\n"

encodedLength_input: .asciiz "xxhhhhhhhhhhhhhhhuuunnnnnnnrere"
encodedLength_input1: .asciiz "AAAAAAAAAAAAAAAAAAAAAA"
encodedLength_input2: .asciiz ""
encodedLength_input3: .asciiz "aaaabb"

# encodeRun
encodeRun_header: .asciiz "\n\n********* encodeRun *********\n"

encodeRun_letter: .ascii "G"
.align 2
encodeRun_runLength: .word 17
encodeRun_output: .asciiz "JASDo823das[23]4[d!!13qdfas21qdqewsf[aes234[faeasdfaaa113"
encodeRun_runFlag: .ascii "!"

encodeRun_letter1: .ascii "R"
.align 2
encodeRun_runLength1: .word 2
encodeRun_output1: .asciiz "????????????????????"
encodeRun_runFlag1: .ascii "#"

# runLengthEncode
runLengthEncode_header: .asciiz "\n\n********* runLengthEncode *********\n"
runLengthEncode_input: .asciiz "aaaaabbbbb"
runLengthEncode_output: .asciiz "f78raewkuiO*A&*(QAWE2qp8947kjdfs244"
.align 2
runLengthEncode_outputSize: .word 15
runLengthEncode_runFlag: .ascii "!"

returnAddr: .asciiz "Return addr: "

# Constants
.eqv QUIT 10
.eqv PRINT_STRING 4
.eqv PRINT_INT 1
.eqv NULL 0x0

.macro print_string(%address)
    li $v0, PRINT_STRING
    la $a0, %address
    syscall
.end_macro

.macro print_string_reg(%reg)
    li $v0, PRINT_STRING
    la $a0, 0(%reg)
    syscall
.end_macro

.macro print_newline
    li $v0, 11
    li $a0, '\n'
    syscall
.end_macro

.macro print_space
    li $v0, 11
    li $a0, ' '
    syscall
.end_macro

.macro print_int(%register)
    li $v0, 1
    add $a0, $zero, %register
    syscall
.end_macro

.macro print_char_addr(%address)
    li $v0, 11
    lb $a0, (%address)
    syscall
.end_macro

.macro print_char_reg(%reg)
    li $v0, 11
    move $a0, %reg
    syscall
.end_macro

.macro print_hex(%reg)
	li $v0, 34
	move $a0, %reg
	syscall
.end_macro

.text
.globl main

main:
    ############################################
    # TEST CASE for atoui
    ############################################
    print_string(atoui_header)
    la $a0, atoui_input
    jal atoui

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline

    la $a0, atoui_input1
    jal atoui

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline

    la $a0, atoui_input2
    jal atoui

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline

    ############################################
    # TEST CASE for uitoa
    ############################################
    print_string(uitoa_header)
    
	lw $a0, uitoa_value
    la $a1, uitoa_output
    lw $a2, uitoa_outputSize
    jal uitoa

    move $t0, $v0
    move $t1, $v1

    print_string(str_return)
    print_string_reg($t0)   # will cause a crash until uitoa is implemented
    print_newline
    print_string(str_return)
    print_int($t1)
    print_newline
	print_string(uitoa_orig)
	print_string(uitoa_output)
	print_newline
	print_newline	

	lw $a0, uitoa_value1
    la $a1, uitoa_output1
    lw $a2, uitoa_outputSize1
    jal uitoa

    move $t0, $v0
    move $t1, $v1

    print_string(str_return)
    print_string_reg($t0)   # will cause a crash until uitoa is implemented
    print_newline
    print_string(str_return)
    print_int($t1)
    print_newline
	print_string(uitoa_orig)
	print_string(uitoa_output1)
	print_newline
	print_newline

	lw $a0, uitoa_value2
    la $a1, uitoa_output2
    lw $a2, uitoa_outputSize2
    jal uitoa

    move $t0, $v0
    move $t1, $v1

    print_string(str_return)
    print_string_reg($t0)   # will cause a crash until uitoa is implemented
    print_newline
    print_string(str_return)
    print_int($t1)
    print_newline
	print_string(uitoa_orig)
	print_string(uitoa_output2)
	print_newline
	print_newline

	lw $a0, uitoa_value3
    la $a1, uitoa_output3
    lw $a2, uitoa_outputSize3
    jal uitoa

    move $t0, $v0
    move $t1, $v1

    print_string(str_return)
    print_string_reg($t0)   # will cause a crash until uitoa is implemented
    print_newline
    print_string(str_return)
    print_int($t1)
    print_newline
	print_string(uitoa_orig)
	print_string(uitoa_output3)
	print_newline
	print_newline

    ############################################
    # TEST CASE for decodedLength
    ############################################
    print_string(decodedLength_header)
    la $a0, decodedLength_input
    la $a1, decodedLength_runFlag
    jal decodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

	la $a0, decodedLength_input1
    la $a1, decodedLength_runFlag1
    jal decodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

	la $a0, decodedLength_input2
    la $a1, decodedLength_runFlag2
    jal decodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

	la $a0, decodedLength_input3
    la $a1, decodedLength_runFlag3
    jal decodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

    ############################################
    # TEST CASE for decodeRun
    ############################################
    print_string(decodeRun_header)
    la $a0, decodeRun_letter
    lw $a1, decodeRun_runLength
    la $a2, decodeRun_output
    move $s0, $a2 # make copy of memory address so we can print the string after function returns
    jal decodeRun

    # since $v0 points to an unprocessed part of output[] there is no sense in printing it
    move $t1, $v1

    print_string(str_return)
    print_int($t1)
    print_newline()

    print_string(str_result)
    print_string_reg($s0)
    print_newline()

	la $a0, decodeRun_letter1
    lw $a1, decodeRun_runLength1
    la $a2, decodeRun_output1
    move $s0, $a2 # make copy of memory address so we can print the string after function returns
    jal decodeRun

    # since $v0 points to an unprocessed part of output[] there is no sense in printing it
    move $t1, $v1

    print_string(str_return)
    print_int($t1)
    print_newline()

    print_string(str_result)
    print_string_reg($s0)
    print_newline()

	la $a0, decodeRun_letter2
    lw $a1, decodeRun_runLength2
    la $a2, decodeRun_output2
    move $s0, $a2 # make copy of memory address so we can print the string after function returns
    jal decodeRun

    # since $v0 points to an unprocessed part of output[] there is no sense in printing it
    move $t1, $v1

    print_string(str_return)
    print_int($t1)
    print_newline()

    print_string(str_result)
    print_string_reg($s0)
    print_newline()

    la $a0, decodeRun_letter3
    lw $a1, decodeRun_runLength3
    la $a2, decodeRun_output3
    move $s0, $a2 # make copy of memory address so we can print the string after function returns
    jal decodeRun

    # since $v0 points to an unprocessed part of output[] there is no sense in printing it
    move $t1, $v1

    print_string(str_return)
    print_int($t1)
    print_newline()

    print_string(str_result)
    print_string_reg($s0)
    print_newline()

    ############################################
    # TEST CASE for runLengthDecode
    ############################################
    print_string(runLengthDecode_header)
    
	print_string(runLengthDecode_debug)
	la $a0, runLengthDecode_output
	li $v0, 4
	syscall
	print_newline()

	la $a0, runLengthDecode_input
    la $a1, runLengthDecode_output
    lw $a2, runLengthDecode_outputSize
    la $a3, runLengthDecode_runFlag
    move $s0, $a1  # make copy of memory address so we can print the string after function returns
    jal runLengthDecode

    move $t0, $v0

	print_string(str_result)
    print_string_reg($s0)
    print_newline()

    print_string(str_return)
    print_int($t0)
    print_newline()
#####
	print_string(runLengthDecode_debug)
	la $a0, runLengthDecode_output
	li $v0, 4
	syscall
	print_newline()

	la $a0, runLengthDecode_input1
    la $a1, runLengthDecode_output
    lw $a2, runLengthDecode_outputSize1
    la $a3, runLengthDecode_runFlag1
    move $s0, $a1  # make copy of memory address so we can print the string after function returns
    jal runLengthDecode

    move $t0, $v0

	print_string(str_result)
    print_string_reg($s0)
    print_newline()

    print_string(str_return)
    print_int($t0)
    print_newline()
#####
	print_string(runLengthDecode_debug)
	la $a0, runLengthDecode_output
	li $v0, 4
	syscall
	print_newline()

	la $a0, runLengthDecode_input2
    la $a1, runLengthDecode_output
    lw $a2, runLengthDecode_outputSize2
    la $a3, runLengthDecode_runFlag2
    move $s0, $a1  # make copy of memory address so we can print the string after function returns
    jal runLengthDecode

    move $t0, $v0

	print_string(str_result)
    print_string_reg($s0)
    print_newline()

    print_string(str_return)
    print_int($t0)
    print_newline()

    ############################################
    # TEST CASE for encodedLength
    ############################################
    print_string(encodedLength_header)
    la $a0, encodedLength_input
    jal encodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

	la $a0, encodedLength_input1
    jal encodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

	la $a0, encodedLength_input2
    jal encodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

	la $a0, encodedLength_input3
    jal encodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

    ############################################
    # TEST CASE for encodeRun
    ############################################
    print_string(encodeRun_header)
    la $a0, encodeRun_letter
    lw $a1, encodeRun_runLength
    la $a2, encodeRun_output
    la $a3, encodeRun_runFlag
    move $s0, $a2  # make copy of memory address so we can print the string after function returns
    jal encodeRun

    move $t1, $v1
	move $t2, $v0
	print_hex($s0)
	print_newline()
    print_string(str_return)
    print_int($t1)
    print_newline()
    print_string(str_result)
    print_string_reg($s0)
    print_newline()
	print_string(returnAddr)
	print_hex($t2)
	print_newline()

	la $a0, encodeRun_letter1
    lw $a1, encodeRun_runLength1
    la $a2, encodeRun_output1
    la $a3, encodeRun_runFlag1
    move $s0, $a2  # make copy of memory address so we can print the string after function returns
    jal encodeRun

    move $t1, $v1
	move $t2, $v0
	print_hex($s0)
	print_newline()
    print_string(str_return)
    print_int($t1)
    print_newline()
    print_string(str_result)
    print_string_reg($s0)
    print_newline()
	print_string(returnAddr)
	print_hex($t2)
	print_newline()

    ############################################
    # TEST CASE for runLengthEncode
    ############################################
    print_string(runLengthEncode_header)
    
    print_newline()
    print_string(runLengthEncode_input)
    print_newline()
    
    la $a0, runLengthEncode_input
    la $a1, runLengthEncode_output
    lw $a2, runLengthEncode_outputSize
    la $a3, runLengthEncode_runFlag
    move $s0, $a1  # make copy of memory address so we can print the string after function returns
    jal runLengthEncode

    move $t1, $v0

    print_string(str_return)
    print_int($t1)
    print_newline()
    print_string(str_result)
    print_string_reg($s0)
    print_newline()
   
    # Exit main
    li $v0, QUIT
    syscall

#################################################################
# Student-defined functions will be included starting here
#################################################################

.include "hw2.asm"
