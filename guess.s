
#######################
# guess.s
# -------
# This program asks the user to enter a guess. It
# reprompts if the user's entry is either an invalid
# hexadecimal number or a valid hexadecimal number
# that is outside the range specified in the program
# by min and max.
#
	.data
min:        .word   1
max:        .word   10
msgguess:   .asciiz "Make a guess.\n"
msgnewline: .asciiz "\n"
	.text
	.globl main
main:
	# Make space for arguments and saved return address
	subi  $sp,$sp,20
	sw    $ra,16($sp)

	# Get the guess
	la    $a0,msgguess
    	lw    $a1,min
    	lw    $a2,max
    	jal   GetGuess
    
   	 # Print the guess
    	move  $a0,$v0
   	jal   PrintInteger
    
   	 # Print a newline character
    	la    $a0,msgnewline
    	jal   PrintString
    
   	 # Return
    	lw    $ra,16($sp)
    	addiu $sp,$sp,20
    	jr    $ra

################################
# GetGuess
################################

    .data
invalid:    .asciiz "Not a valid hexadecimal number.\n"
badrange:   .asciiz "Guess not in range.\n"
    .text
    .globl  GetGuess
# 
# C code:
#
# int GetGuess(char * question, int min, int max)
# {
#     // Local variables
#     int theguess;      // Store this on the stack

#     int bytes_read;    // You can just keep this one in a register
#     char buffer[16];   // This is 16 contiguous bytes on the stack
#
#     // Loop
#     while (true)
#     {
#         // Print prompt, get string (NOTE: You must pass the
#         // address of the beginning of the character array
#         // buffer as the second argument!)
#         bytes_read = InputConsoleString(question, buffer, 16);
#         if (bytes_read == 0) return -1;
#
#         // Ok, we successfully got a string. Now, give it
#         // to axtoi, which, if successful, will put the
#         // int equivalent in theguess. 
#         //
#         // Here, you must pass the address of theguess as
#         // the first argument, and the address of the
#         // beginning of buffer as the second argument.
#         status = axtoi(&theguess, buffer);
#         if (status != 1)
#         {
#             PrintString(invalid);  // invalid is a global
#             continue;
#         }
#
#         // Now we know we got a valid hexadecimal number, and the
#         // int equivalent is in theguess. Check it against min and
#         // max to make sure it's in the right range.
#         if (theguess < min || theguess > max)
#         {
#             PrintString(badrange); // badrange is a global
#             continue;
#         }
#
#         return theguess;
#     }
# }
#     
#


GetGuess:
    # stack frame must contain $ra (4 bytes)
    # plus room for theguess (int) (4 bytes)
    # plus room for a 16-byte string
    # plus room for arguments (16)
    # total: 40 bytes
    #  16 byte buffer is at 16($sp)
    #  theguess is at 32($sp)
    #
    
    # $a0 = msgguess $a1/$t1 = min  $a2/ $t2= max
        addiu   $sp,$sp, -44
        sw      $ra, 40($sp)
        
        sw      $a1, 8($sp)
        move    $t1, $a1
        sw      $a2, 12($sp)
        move    $t2, $a2
        
        loop:
        la      $a0, msgguess
        li      $a2, 16
        add 	$a1, $sp, 16
        jal     InputConsoleString
        move    $t0, $v0  #$t0 = bytes_read
        bnez    $t0, return
        j       else
        
        return:
        move    $v0, $zero
        addi    $v0, $zero, 1
        
        else:  
        la      $a0, 32($sp)  
        la      $a1, 16($sp)
        jal     axtoi
        move    $a3, $v0   # $a3 = status
        
        li      $t1, 1
        beq     $a3, $t1, if
        lw      $a0, invalid
        jal     PrintString
        
        if:
        lw      $t2, 32($sp)
        lw      $a1, min
        lw      $a2, max
        blt	$t2, $a1, badrangemsg
        bgt	$t2, $a2, badrangemsg
        j       return2
        
        badrangemsg:
        sw      $ra, 36($sp)
        la      $a0, badrange 
        jal     PrintString
        lw      $a3, 36($sp)
        jal 	loop

        return2:
        lw     $v0, 32($sp)
         
        done:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
        lw      $ra, 40($sp)
        addiu   $sp, $sp, 44

        jr      $ra
    
    .include  "./util.s"
