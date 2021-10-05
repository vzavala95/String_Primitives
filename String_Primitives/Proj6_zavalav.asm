TITLE Project 6     (Proj6_zavalav.asm)

; Author: Victoria Zavala
; Last Modified: 03/12/2021
; OSU email address: zavalav@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:   6              Due Date: 03/14/2021
; Description: This program implements two macro's for processing strings. The user is prompted to enter 10 signed integers, 
;				then, the array is printed along with the sum and average of the numbers. 
INCLUDE Irvine32.inc

;***********************************************************************************************
;
;	NAME: mGetString
;	DESCRIPTION: Displays a prompt and stores the user's keyboard input into a specific memory location.
;	PRECONDITIONS: N/A
;   POSTCONDITIONS: EDX and ECX changed
;	RECEIVES: Array memory addrress and array length
;	RETURNS: ASCII String
;
;*************************************************************************************************

mGetString	MACRO	usr_prompt, usr_input, buffer
	
	PUSH	ECX
	PUSH	EDX						; Saves registers before manipulating values

	MOV		EDX, usr_prompt			; Receive keyboard input from user
	CALL	WriteString

	MOV		ECX, 40					; Size of user input
	MOV		EDX, usr_input
	CALL	ReadString				; Receive string from user
	MOV		buffer, EAX	

	POP		ECX
	POP		EDX							; Restore registers after value manipulation
	
ENDM

;**********************************************************************************************
;
;	NAME: mDisplayString
;	DEFINITION: Prints a string stored in a specific memory location
;	PRECONDITIONS: N/A
;	POSTCONDITIONS: EDX changed
;	RECEIVES:	Memory address of inputted string
;	RETURNS: N/A
;
;***********************************************************************************************

mDisplayString	MACRO	usr_string
	
	PUSH	EDX						; Saves registers before manipulating values

	MOV		EDX, usr_string
	CALL	WriteString				; Displays the string

	POP		EDX						; Restore registers after value manipulation

ENDM


.data

; Constants Defined

	MAX_INT = 10						; Stores the max number of integers that are input by the user

; Variable definitions

	title1			BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13,10,0
	author1			BYTE		"Programmed by: Victoria Zavala", 13,10,0

	instruct_usr	BYTE		"Please provide 10 signed decimal integers.", 13,10
					BYTE		"Each number needs to be small enough to fit inside a 32 bit register. After", 10
					BYTE		"you have finished inputting the raw numbers, I will display a list of integers,", 10
					BYTE		"their sum, and their average value.", 13,10,0

	usr_prompt		BYTE		"Please enter a signed number: ", 0
	error_msg		BYTE		"ERROR: You did not enter a signed number or your number was too big.", 13,10,0
	display_num		BYTE		"You entered the following numbers: ", 13,10,0
	comma			BYTE		", ", 0
	sum_num			BYTE		"The sum of these numbers is: ", 0
	avg_num			BYTE		"The rounded average is: ", 0

	usr_input	 	BYTE		40 DUP(?)			; Holds user input up to 40 
	str_display		BYTE		40 DUP(?)			; Same size as usr_input, displays ascii characters based on keyboard input
	len_str		    DWORD		?					; Length of usr_input string
	sign_check		SDWORD		0					; Check is entered number is negative
	num_count		SDWORD		0					; Counts the number of input integers 
	num_valid		SDWORD		?					; Initializes the check to make sure input is valid
	total			SDWORD		?
	average			SDWORD		?
	integerArray	SDWORD		MAX_INT DUP(?)		; Array of valid integers
	

.code


;*********************************************************************************
;
;	NAME: introduction
;	DESCRIPTION: Introduces program title, program author, and displays instructions to the user (by way of mDisplayString)
;	PRECONDITIONS: title, author, and instruction variables must be referenced
;	POSTCONDITIONS: N/A and no registers changed
;	RECEIVES: Addresses of program title, program author, and instruction variables =)
;	RETURNS: N/A
;
;***********************************************************************************

introduction PROC
	

	PUSH		EBP
	MOV		EBP, ESP					; Sets up activation record/stack frame
	PUSHAD
	

	mDisplayString	[EBP+8]				; Print author of program...me! =)
	mDisplayString	[EBP+12]			; Print title of program
	CALL			CRLF
	mDisplayString 	[EBP+16]			; Print instructions on how to use the program to the user
	CALL			CRLF

	POPAD

	POP		EBP							; Restore activation record/stack frame
	RET		16      

introduction ENDP

;************************************************************************
;	NAME: ReadVal
;	DESCRIPTION: Receives user input in ASCII digits. Then, using mGetString, 
;	converts ASCII digits to integers if valid input.
;	PRECONDITIONS: N/A
;	POSTCONDITIONS: EBP, ECX, ESI, EDI, EAX, AL registers changed
;	RECEIVES: Reference and Value variables entered 
;	RETURNS: Validated numbers for array
;
;*************************************************************************

ReadVal PROC
	
	PUSH		EBP
	MOV		EBP, ESP						; Set up Activation Record/Stack Frame
	PUSHAD									; Preserves registers 

	_receive_input:

	mGetString [EBP+16], [EBP+12], [EBP+8]

		
		CLD									; Clear direction flag in order for string op to increment ESI and EDI
		MOV		ECX, [EBP+8]				; Counts user input 
		MOV		ESI, [EBP+12]				; User input moved to ESI register
		MOV		EDI, [EBP+20]				; Validated integer, output by reference
		CLD									; Clear direction flag again

	
	_array_check:
	
		LODSB

		CMP		AL, 0					; Checks to make sure that the string has ended
		CMP		ECX, 11					; Compares 11 to val in ECX to check if error message is displayed
		JGE		_invoke_error				; Displays error message and resets count to include next valid number
		MOV		EBX, [EBP+8]			; Moves user input to EBX to prep for a sign check
		CMP		EBX, ECX				; Count in ECX is compared to val in EBX to prep for sign validation
		JNZ		_validate_nums			; Check if num < 0 or num > 9		
		CMP		AL, 43					; If character is positive
		JZ		_continue_array			; If character is positive, jump if result is 0
		CMP		AL, 45					; If character is negative
		JE		_check_neg			
		JMP		_validate_nums			; Once neg and positive have been checked, we have to check for num < 0 and num > 9


	_check_neg:

		MOV		EBX, 1					; Check first character in the array for the sign
		MOV		[EBP+32], EBX			; Move negative proc to EBX to check if first char is negative
		LOOP	_array_check				; Loops through array to get back to first num
		MOV		EBX, 1					; Checks first character in the array for the sign
		CMP		[EBP+32], EBX			;  Move negative proc to EBX to check if first char is negative
		JNE		_if_positive			; If character is positive, store valid num
		IMUL	EAX, -1					; Multiply char in EAX by -1 to replace val with two's complement 

	_validate_nums:

		CMP		AL, 48					; If character is less than 0 (in ASCII chart 48==0)....ERROR!
		JB		_invoke_error			; User has to try again
		CMP		AL, 57					; If character is greater than 0 (in ASCII chart 57==9)...ERROR!
		JA		_invoke_error			; User has to try again

		SUB		AL, 48					; 48 == 0 in ASCII chart so subtract 48 from val in AL to convert char to int 
		MOVSX	EAX, AL					; Sign extend to proper operand of the instruction
		PUSH	EAX						; Push EAX to top of the stack 

		MOV		EAX, [EBP+24]			; Counts the num of integers for conversion from char to int
		MOV		EBX, 10					; Move 10 into EAX to multiply by current total 
		IMUL	EBX						; Multiply by current total to convert string to int

		POP		EBX						; Restores val into EBX
		ADD		EAX, EBX				; Add val in EBX to current running total
		MOV		[EBP+24], EAX			; Move counter into EAX

	_continue_array:
		LOOP		_array_check		; Iterate through array to check subsequent characters
		MOV		EBX, 1					; Checks for sign
		CMP		[EBP+32], EBX			; Check if char is negative
		JNE		_if_positive			; Jump to proc that makes sure number is validated
		IMUL	EAX, -1					; Multiply char in EAX by -1 to replace val with two's complement 

	_if_positive:
		JMP		_store_valid				; Special procedure if number is positive, then validate humber

	_invoke_error:						
		mDisplayString [EBP+28]			; Invokes mDisplayString to display error message to user if num is too large or non valid input 
		XOR		EBX,EBX					; Set EBX to 0		
		MOV		[EBP+24], EBX			; Reset count if user input invalid number
		MOV		[EBP+32], EBX			; Resets negative check if user input invalid num 
		JMP		_receive_input			; Ask user again for valid num

	_store_valid:
		MOV		[EDI], EAX				; If user input is valid, stored for use later 

		POPAD							; Restore activation record/stack frame
		POP		EBP
		RET		36

ReadVal	ENDP

;***************************************************************************
; 
;	NAME: WriteVal
;	DESCRIPTION: Converts SDWORD input to ASCII string, then displays the ASCII representation of the value 
;	PRECONDITIONS: SDWORD input value, user input BYTE
;	POSTCONDITIONS: ESI, EDI, EBP, EAX, EDX registers changed
;	RECEIVES: memory address of user input, and num that converts to ASCII characters 
;	RETURNS: Displayed verified numbers
; 
;****************************************************************************

WriteVal PROC
	
	PUSH		EBP
	MOV		EBP, ESP				; Set up activation/record
	PUSHAD							; Preserve registers 

	MOV		ESI, [EBP+8]			; Integer moved to ESI register that will be converted to ASCII
	MOV		EDI, [EBP+12]			; ASCII string moved to EDI that will be summed and averaged
	

	MOV		EAX, ESI				; Move integer in ESI to EAX to be verified
	MOV		ECX, 0					; Counts numbers in input
	CMP		EAX, 0					; Makes sure that num is signed
	JGE		_calc_string				; If num is signed, move on to conversion

	PUSH	EAX						; Moves val into EAX
	MOV	AL, 45						; ASCII char 45 = "-"
	
	STOSB

	POP		EAX			
	IMUL	EAX, -1					; Multiply char in EAX by -1 to replace val with two's complement

_calc_string:
	MOV		EBX, 10					; Move 10 to EBX in order to divide string by 10 to convert
	CDQ								; Sign-Extend for signed integers
	IDIV	EBX						; Divide string by 10 

	ADD		EDX, 48					; Add 48 to remainder
	PUSH	EDX						; If there is remainder, save it 
	INC		ECX						; Add 1 to counter

	CMP		EAX, 0					; Check if conversion of strings is done				
	JE		_convert_string			; If conversion is done, handle remainders
	JMP		_calc_string			; Handle the rest of the numbers in the array in order to print and display array, sum, and average
	

_convert_string:
	POP		EAX						; Restore the stored remainders
	STOSB							; Stores the string from AL and puts it into mem address
	LOOP		_convert_string		; Continue for each remainder in the string

	XOR AL, AL						; Clears to 0
	STOSB							; Stores completed string


	mDisplayString [EBP+12]			; Displays string by invoking mDisplayString macro proc

	POPAD							; Restore stack frame/activation record
	POP		EBP
	RET		8

WriteVal ENDP

main PROC


	PUSH		OFFSET instruct_usr			; Displays instructions
	PUSH		OFFSET title1				; Displays program title 
	PUSH		OFFSET author1				; Displays program author...me =)
	CALL		introduction				; Finally, calls introduction procedure
	CALL		CRLF
	
											
	_count_check: 
		MOV		EDI, OFFSET integerArray			; If user input is valid, stores the integers in this array
		MOV		ECX, MAX_INT						; Counts the integers the user inputs
	

	_check_input:

		PUSH		OFFSET str_display				; Displays ASCII characters the same size as user input 	
		PUSH		sign_check						; Makes sure num is signed
		PUSH		OFFSET error_msg				; Displays error message
		PUSH		num_count						; Counts user input
		PUSH		OFFSET num_valid				; Checks validity of input
		PUSH		OFFSET usr_prompt				; Prompts user for input
		PUSH		OFFSET usr_input				; Displays user input
		PUSH		len_str							; Counts length of user input string
		
		CALL		ReadVal							; Read the user's inputs
		MOV			EAX, num_valid					; Moves valid input into EAX
		STOSD										; Store the valid integers in an array
		
		LOOP		_check_input
		CALL		CRLF
		MOV			ESI, OFFSET integerArray		; Array of integers to be displayed
		MOV			ECX, MAX_INT					; Makes sure that integers do not exceed the constant value 10


													
	_print_nums:

		PUSH		OFFSET str_display				; One integer at a time for displaying sequence of numbers
		PUSH		[ESI]							; Preserve val in ESI
		CALL		WriteVal						
	
		mDisplayString 	OFFSET comma				; Values separated by a comma when displaying sequence of numbers
		ADD			ESI, TYPE integerArray			; Add integerArray variable to ESI because for preparation
		LOOP		_print_nums						; Loop until all values are displayed up to 10 
		CALL		CRLF

													; Iterates through array to calulate sum of the numbers in the array
		MOV		ESI, OFFSET integerArray			; Gives address of integerArray for loop prep
		MOV		ECX, MAX_INT						; Cannot have more than 10 numbers in the array
		XOR		EAX,EAX								; Set EAX to 0

	_calc_nums:
		ADD		EAX, [ESI]							; Add to EAX contents of memory pointed to by ESI
		ADD		ESI, TYPE integerArray				; Add integerArray variable to ESI because for preparation for loop	
		LOOP		_calc_nums						; Iterate though each num in the array to calculate sum of all the numbers 
		MOV		total, EAX							; Calculates the total of the numbers nd stores in EAX
													; To print the sum of the numbers in the array, have to call WriteVal
		mDisplayString OFFSET sum_num				; Invoke mDisplayString macro to call WriteVal 
		PUSH		OFFSET str_display				; Displays ascii characters based on user keyboard input
		PUSH		total							; Stores calculates total of numbers in array
		CALL		WriteVal						; Converts array to string YAY
		CALL		CRLF

													; To calculate the average, we need to divide by val in EBX 
		MOV		EAX, total							; Store total variable in EAX for use in calculation
		MOV		EBX, MAX_INT						; 10 numbers in array
		CDQ											; Doubles the size of operand in EAX by sign extension
		IDIV	EBX									; Divide by values in the array to get the average num of the array
		MOV		average, EAX						; Stores average in EAX register to be displayed

													; To display the average, we need to call WriteVal
		mDisplayString OFFSET avg_num				; Invoke mDisplayString value to call WriteVal
		PUSH		OFFSET str_display				; Displays ascii characters based on user keyboard input
		PUSH		average							; Storage for average 
		CALL		WriteVal						; Finally, displays the average of the nums in the array YAY!
		CALL		CRLF


	Invoke ExitProcess,0	; exit to operating system

main ENDP


END main