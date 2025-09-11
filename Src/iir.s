/*
 * iir.s
 *
 *  Created on: 29/7/2025
 *      Author: Ni Qingqing
 */
   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global iir

@ Start of executable code
.section .text

@ CG2028 Assignment 1, Sem 1, AY 2025/26
@ (c) ECE NUS, 2025

@ Write Student 1’s Name here: Su Menghang, Vincent
@ Write Student 2’s Name here: Chan Xu Ming Ethan

@ You could create a look-up table of registers here:

@ R0 N, y_n
@ R1 b[]
@ R2 a[]
@ R3 x[i]

@ R11 current i
@ R13 SP
@ R14 LR
@ R15 PC


@ write your program from here:

.lcomm x_array, 4*12 @ Stores up to 12 integers in x_array and y_array
.lcomm y_array, 4*12

.lcomm i, 4

iir:
 	PUSH {R14}

	BL SUBROUTINE

 	POP {R14}

	BX LR

SUBROUTINE:
	PUSH {R4-R12} @Save registers 4 to 12
	LDR R4, [R1] @Loads b[0] into R4
	LDR R5, [R2] @Loads a[0] into R5

	MUL R6, R3, R4 @R6 = x_n * b[0]
	SDIV R12, R6, R5 @R6 = x_n * b[0] / a[0]

	SUB R7, R0, #1 @Loop counter where j = n-1
	LDR R5, =i @R5 stores address of i
	LDR R4, [R5] @R4 stores value of i

	LDR R10, =1 @j counter starts at 1

LOOP:

	CMP R7, #0 @Compare loop counter with 0
	BLT EXIT @Exits loop if less than or equals 0

	SUB R11, R4, #1 @Exits loop if index less than 0 to avoid illegal memory access
	CMP R11, #0 @R11 stores i-1
	BLT EXIT

	LDR R5, =x_array @R5 stores address of x_array
	LDR R9, =y_array @R9 stores address of y_array

	LDR R6, [R5, R11, LSL #2] @Loads x_array[i] into R6
	LDR R8, [R1, R10, LSL #2] @Loads b[j] into R8, counter starts at 1 and counts to 4
	MUL R6, R6, R8 @Get b and x term

	LDR R9, [R9, R11, LSL #2] @Loads y_array[i] into R9
	LDR R8, [R2, R10, LSL #2] @Loads a[j] into R8, counter starts at 1 and counts to 4
	MUL R9, R9, R8 @Get a and y term

	SUB R6, R6, R9
	LDR R11, [R2] @Loads a[0] into R11
	SDIV R6, R6, R11
	ADD R12, R12, R6

	SUB R7, R7, #1
	SUB R4, #1 @Decrement i counter
	ADD R10, #1 @Increment j counter
	B LOOP @Go back to loop
EXIT:

	LDR R7, =x_array
	LDR R8, =y_array
	LDR R5, =i @R5 stores address of i
	LDR R4, [R5] @R4 stores value of i
	MOV R0, R12 @move result from R12 to R0
	MOV R1, #100 @ scaling factor

	STR R3, [R7, R4, LSL #2] @Stores x_n into x_array
	STR R0, [R8, R4, LSL #2] @Stores y_n into y_array

	ADD R4, #1 @Increments i by 1
	STR R4, [R5] @Stores result of i+1 into memory address of i

	SDIV R0, R0, R1 @R0 = R0 / 100
	POP {R4-R12} @Restores registers used
	BX LR
