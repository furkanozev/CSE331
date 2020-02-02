#	Furkan OZEV	161044036	# 

.data
mes: .asciiz "\nEnter the set amount (max 10) : " 
mes2: .asciiz "\nEnter the size of set (max 20) : "
mes3: .asciiz "\n Enter element : " 
mesuni: .asciiz "\n Enter size of union set : "
mesres: .asciiz "\n Result Sets : "
Set: .word 600
.text

###		MAIN		##
main:

jal read		# Read Sets.

jal readuni		# Read Union Set.

la $a0, mesres
li $v0, 4
syscall

move $t9, $zero
	loopmain:
	jal checkempty	# Check Union Set is free.
	beq $a0, 0, exitloopmain
	jal clear		# Clear memory where intersection amounts are kept.
	jal intersection	# Calculate new intersection amounts
	jal max			# The set with the highest amount of intersection is determined.
	move $s7, $a0
	addi $a0, $a0, 1
	move $a1, $t9
	jal addI		# This set is added to the result list.
	addi $t9, $t9, 1
	jal removelem		# The elements of this set are deleted from the union set.
	j loopmain

exitloopmain:
# Ends the program
	li $v0, 10
	syscall
###########################################

###		REMOVE		##	
# Used to delete elements from a union set. #
removelem:
la $s1, Set
add $s2, $s1, 800
move $t1, $s7			# number of set to delete from union set
li $s3, '-'
li $s4, '*'

# Find the location of the set in memory to be deleted from the union set. #
move $t0, $zero
	loopremove:
	beq $t0, $t1, removec
	add $s1, $s1, 80
	addi $t0, $t0, 1
	j loopremove

# After finding location, remove process will continue	
removec:
move $t0, $zero
	# The function checks whether each element of the set to be deleted is in the union set. 
	# If the element exists in the union set, that element is deleted from the union set.
	loopremset:
	beq $t0, 20, exit
		add $t2, $s2, 0
		loopremuni:
		lw $t6, ($t2)
		beq $t6, $s4, cremset
		lw $t8, ($s1)
		beq $t6, $t8, removeitem
		cremuni:
		add $t2, $t2, 4
		j loopremuni
	
	cremset:
	add $s1, $s1, 4
	addi $t0, $t0, 1
	j loopremset

# Remove item from union set.
removeitem:
sw $s3, 0($t2)
j cremuni
###########################################

###		ADD RESULT SET NUMBER		##
# The found set is printed on the screen and stored in memory.
addI:
li $s3, ','
la $s1, Set
add $s1, $s1, 2000
move $t0, $a0

li $v0, 1
syscall
	
move $a0, $s3
li $v0, 11
syscall

move $t1, $a1
sll $t2, $t1, 2
add $t2, $s1, $t2
sw $t0, 0($t2)
jr $ra
###########################################

###		MAX INTERSECTION SET NUMBER		##
# This function is called after the intersection function calculates the amount of intersection of each set with the union set.
# These amounts are stored in memory, and this function helps to determine the highest one.
max:
la $s1, Set
add $s1, $s1, 1600
move $a0, $zero
lw $t0, 0($s1)
move $t1, $zero
	loopmax:
	beq $t1, 10 , exit
	lw $t2, 0($s1)
	slt $t3, $t0, $t2
	beq $t3, 1, swapmax
	maxc:
	addi $t1, $t1, 1
	add $s1, $s1, 4
	j loopmax

# It changes the value of a result element
swapmax:
lw $t0, 0($s1)
move $a0, $t1
j maxc
###########################################

###		CLEAR INTERSECTION AMOUNT SET		##
# This function clears the memory that holds the intersection amounts for reuse.
clear:
la $s1, Set
add $s1, $s1, 1600

move $t0, $zero
move $t1, $zero
	# Assigns a value of 0 to each address in memory.
	loopclear:
	beq $t1, 10 , exit
	sw $t0, ($s1)
	addi $t1, $t1, 1
	add $s1, $s1, 4
	j loopclear
###########################################	

###		INTERSECTION		##
# This function calculates the intersection amounts of each set with the union set.
# It then stores these values ??in memory.
intersection:
addi $sp,$sp, -4
sw $ra, 0($sp) 
jal lenx
move $t5, $a0
lw $ra,0($sp)
addi $sp,$sp, 4

la $s1, Set		# Sets
add $s3, $s1, 800	# Union Set	
add $s2, $s1, 1600	# For store intersection amount	

move $t0, $zero
	# This loop is repeated for each set.
	loopset:
	beq $t0, 10 , exit
	add $s4, $s3, 0

	
	move $t1, $zero
		# This loop is repeated for each element of union set.
		loopx:
				
		beq $t1, $t5 , cinter2
	
		add $s5, $s1, 0
		
		move $t2, $zero
			# This loop is repeated for each element of current set.
			loops:
			beq $t2, 20, cinter
			addi $t2, $t2, 1
			lw $t6, ($s4)	# Current union element.
			lw $t7, ($s5)	# Current element of current set
			# Union checks whether each element of the set is in the current set.
			# If present, the amount of intersection is increased by 1.
			beq $t6, $t7, incre
			add $s5, $s5, 4		# Next element of current set.
			j loops
		# Continue loopx
		cinter:
		addi $t1, $t1, 1
		add $s4, $s4, 4		# Next union element.
		j loopx
	cinter2:
	add $s2, $s2, 4			# Next intersection memory for next set
	add $s1, $s1, 80		# Next set
	add $t0, $t0, 1

	j loopset

# It ýncrement intersection amount in memory for current set.	
incre:
lw $t7, 0($s2)
addi $t7, $t7, 1
sw $t7, 0($s2)
j cinter
###########################################

###		COUNT UNION ELEMENT		##
checkempty:
# Determines the number of elements available in the union set.
la $s0, Set
li $s1, '-'	# Determines the remove element of the union set.
li $s2, '*'	# Determines the end of the union set.
li $a0, 0
add $s3, $s0, 800

# If there are no elements in the set, it returns 0.
# This means that the set is empty.
	emptyx:
	lw $s4, 0($s3)
	add $s3, $s3, 4
	beq $s4, $s2, exit
	beq $s4, $s1, emptyx
	addi $a0, $a0,1
	j emptyx
jr $ra
###########################################

###		CALCULATE LENGTH UNION SET		##
lenx:
# Calculates the size of eunion set.
la $s0, Set
li $s2, '*'	# Determines the end of the union set.
li $a0, 0
add $s3, $s0, 800

	looplenx:
	lw $s4, 0($s3)
	add $s3, $s3, 4
	beq $s4, $s2, exit
	addi $a0, $a0,1
	j looplenx
jr $ra
###########################################

###		READ UNION SET		##
readuni:
# Prompts the user to enter the union set.
la $s0, Set

la $a0, mesuni
li $v0, 4
syscall

# It asks how many elements union set will have. The loop turns by this amount.
li $v0, 5
syscall 
move $t5, $v0

move $t1, $zero
add $t2, $s0, 800

la $a0, mes3
loopuni:
	beq $t1, $t5, exit2
	
	li $v0, 4
	syscall
	# In this loop, it asks the user for the elements of the union set.
	li $v0, 5
	syscall
	sw $v0, 0($t2)
	add $t2, $t2, 4
	addi $t1, $t1, 1
	j loopuni

exit2:
	li $v0, '*'
	sw $v0, 0($t2)
	jr $ra
###########################################

###		READ SETS		##
read:
# Prompts the user to enter the sets.
la $s0, Set

la $a0, mes
li $v0, 4
syscall

li $v0, 5
syscall 
move $t5, $v0

move $t0, $zero
loop1:
# It first asks the user how many sets there will be, then turns the first loop by this amount.
beq $t0, $t5, exit

la $a0, mes2
li $v0, 4
syscall

li $v0, 5
syscall 
move $t6, $v0

move $t1, $zero
add $t2, $s0, 0
	loop2:
	# It asks how many elements each set will have. The second loop turns by this amount.
	beq $t1, $t6, loop1c
	la $a0, mes3
	li $v0, 4
	syscall
	# In this loop, it asks the user for the elements of the set.
	li $v0, 5
	syscall
	sw $v0, 0($t2)
	add $t2, $t2, 4
	addi $t1, $t1, 1
	j loop2
loop1c:
add $s0, $s0, 80
addi $t0, $t0, 1
j loop1
###########################################

###		EXIT		##
exit:
jr $ra
###########################################

#	Furkan OZEV	161044036	# 
