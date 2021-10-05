# String_Primitives
This is MASM program that performs the following tasks:

Implement and test two macros for string processing. 
Implement and test two procedures for signed integers which use string primitive instructions

Invoke the mGetString macro  to get user input in the form of a string of digits. <br>
Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc). <br>
Store this value in a memory variable. <br>

Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits <br>
Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output. <br>

Test program (in main) which uses the ReadVal and WriteVal procedures above to: <br>
Get 10 valid integers from the user. <br>
Stores these numeric values in an array. <br>
Display the integers, their sum, and their average. <br>
