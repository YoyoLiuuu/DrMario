######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       2
# - Unit height in pixels:      2
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
# The colour of the bottle
BOTTLE_COLOUR: 
    .word 0x808080


##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    li $a0, 21
    li $a1, 2000
    li $a2, 3
    li $a3, 100
    li $v0, 31 
    syscall 
    add $s2, $zero, $sp         # $s2 stores the initial location of the stack pointer 
    add $s4, $zero, $zero       # $s4 is the counter - in charge of each drop in gravity 
    add $s6, $zero, $zero       # $s6 is the time counter 
    addi $s7, $zero, 40         # 50 drops to increase play speed (gravity) 

paint_background: 
    add $t0, $zero, 0x0
    lw $t2, ADDR_DSPL
    add $t1, $t2, 16384
    jal draw_line

select_level: 
    # easy 
    add $t0, $zero, 0xffffff
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 1040
    addi $t1, $t2, 20
    jal draw_line
    addi $t2, $t2, 364
    addi $t1, $t2, 20
    jal draw_line
    addi $t2, $t2, 364
    addi $t1, $t2, 20
    jal draw_line
    
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 912
    addi $t1, $t2, 896
    jal draw_down
    
    # medium 
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 1072
    addi $t1, $t2, 12
    jal draw_line
    addi $t1, $t2, 768
    jal draw_down
    addi $t2, $t2, -908
    addi $t1, $t2, 896
    jal draw_down
    addi $t2, $t2, -756
    addi $t1, $t2, 12
    jal draw_line
    addi $t1, $t2, 768
    jal draw_down
    
    # hard 
    addi $t2, $t2, -896 
    addi $t2, $t2, 12
    addi $t1, $t2, 896
    jal draw_down
    addi $t2, $t2, -896 
    addi $t2, $t2, 24
    addi $t1, $t2, 896
    jal draw_down
    addi $t2, $t2, -384
    addi $t2, $t2, -24
    addi $t1, $t2, 24 
    jal draw_line


level_select:    
    lw $t0, ADDR_KBRD           # load keyboard address 
    lw $t3, 4($t0)              # load content of keyboard 
    beq $t3, 0x71, quit         # go to line to quit the program 
    beq $t3, 101, easy 
    beq $t3, 109, medium 
    beq $t3, 104, hard 
    j level_select

easy: 
    li $a0, 73
    li $a1, 2000
    li $a2, 99
    li $a3, 100
    li $v0, 31 
    syscall 
    li $s5, 5000000             # initial gravity rate 
    addi $t7, $zero, 4          # number of viruses 
    j draw_neck

medium: 
    li $a0, 21
    li $a1, 2000
    li $a2, 121
    li $a3, 100
    li $v0, 31 
    syscall 
    li $s5, 3000000             # initial gravity rate 
    addi $t7, $zero, 8
    j draw_neck
    
hard: 
    li $a0, 66
    li $a1, 2000
    li $a2, 88
    li $a3, 100
    li $v0, 31 
    syscall 
    li $s5, 1000000             # initial gravity rate 
    addi $t7, $zero, 12 
    j draw_neck

# this is for drawing the bottle 
draw_neck: 
    add $t0, $zero, 0x0
    lw $t2, ADDR_DSPL
    add $t1, $t2, 16384
    jal draw_line
    lw $t0, BOTTLE_COLOUR       # initialize the colour of the bottle 
    lw $t2, ADDR_DSPL           # load coordinate (0,0) 
    addi $t2, $t2, 40           # x coordinate move amount
    li $t3, 128                 # y coordinate offset amount 
    sll $t3, $t3, 2             # y 4 rows down -> shift by 2
    add $t2, $t2, $t3           # new starting location for bottleneck 
    sw $t0, 0($t2)              # draw gray check 
    sw $t0, 128($t2)            # draw gray check just below it 
    addi $t2, $t2, 16           # x coord of other side of neck
    sw $t0, 0($t2)              # draw gray 
    sw $t0, 128($t2)            # draw gray check just below it 
    # above -> necks of bottle 
    
top_left: 
    lw $t2, ADDR_DSPL           # coord (0,0) 
    addi $t2, $t2, 8            # coord (2, 0) 
    addi $t2, $t2, 768          # coord (2, 6)
    add $t4, $t2, $zero         # store for left down line 
    addi $t1, $t2, 32           # end of line for left top 
    sw $t0, 0($t2)              # draw gray 
    jal draw_line

top_right: 
    add $t2, $t2, 16            # start of top right 
    addi $t1, $t2, 32           # end of line for right top 
    sw $t0, 0($t2)              # draw gray 
    jal draw_line

right_down:
    addi $t1, $t1, 3072         # right bottom corner of bottle 
    add $t5, $t1, $zero         # store right bottom corner of bottle for drawing bottom line 
    jal draw_down

left_down: 
    add $t2, $t4, $zero         # start with top left again 
    addi $t1, $t2, 3072         # left bottom corner of bottle
    jal draw_down

bottom_line: 
    add $t1, $t5, $zero         # make t1 back the bottom right corner of bottle 
    jal draw_line
    
    j draw_viruses
    
# section below is helper for drawing the bottle 
draw_line: 
    bne $t2, $t1, draw_pixel    # draw next pixel if not end of the line 
    jr $ra

draw_pixel: 
    addi $t2, $t2, 4            # move to next location 
    sw $t0, 0($t2)              # draw colour 
    j draw_line

draw_down:
    bne $t2, $t1, draw_pixel_down # draw next pixel if not end of the line 
    jr $ra

draw_pixel_down: 
    add $t2, $t2, 128           # go 1 down in y
    sw $t0, 0($t2)              # draw gray 
    j draw_down

# $t2 stores the top left of where the virus can be 
# $t3 stores the bottom right of where virus can be 
# $t4 stores how many viruses are left to draw 
draw_viruses: 
    lw $t2, ADDR_DSPL           # display address 
    addi $t4, $t7, 0            # load # of viruses 
    addi $t2, $t2, 12           
    addi $t2, $t2, 1024         # top left of where the virus can be 
    addi $t3, $t2, 2760         # bottom right of where virus can be (128 x 21 + 72) 
    j draw_a_virus 
    
    draw_a_virus: 
    beq $t4, $zero, draw_capsule
    jal random_location         # now location is stored in $t5 
    jal random_number           # now $t1 stores red, blue or green of virus 
    li $t6, 0xf3            
    beq $t1, $t6, change_blue 
    li $t6, 0xff02
    beq $t1, $t6, change_green 
    li $t6, 0xff0001
    beq $t1, $t6, change_red    # change colour slightly -> for future block dropping process 
    
    continue_draw_virus: 
    sw $t1, 0($t5)              # draw the virus 
    addi, $t4, $t4, -1          # decrease # of viruses needed to draw by 1 
    j draw_a_virus
    
    change_blue: 
    li $t1, 0x300000073 
    j continue_draw_virus
    change_green: 
    li $t1, 0x200007002 
    j continue_draw_virus
    change_red: 
    li $t1, 0x100700001
    j continue_draw_virus
    
    random_location:            # generate a random viruses location 
    li $a0, 0
    li $a1, 18                  # generate a random number between 0 and 18 -> x 4 = offset location x coord  
    li $v0, 42
    syscall
    move $t5, $a0               # move generated location to $t5 
    sll $t5, $t5, 2             # multiply by 4 = shift left by 2 -> 4 bytes per unit 
    add $t5, $t2, $t5           # $t5 stores the x-shifted location on memory of where there will be a virus 
    li $a0, 0
    li $a1, 21                  # generate a random number between 0 and 21 -> x 128 = offset location y coord  
    li $v0, 42
    syscall
    move $t6, $a0               # move generated location offset to $t6
    sll $t6, $t6, 7             # multiply by 128 = shift left by 7 
    add $t5, $t5, $t6           # $t5 now stores the location of virus 
    lw $t6, 0($t5)              # load colour of the block 
    bne $t6, $zero, random_location # if the location is not black, generate a new location 
    jr $ra                      # jump back to continue drawing the virus 


# initial capsule 
draw_capsule: 
    lw $t2, ADDR_DSPL           # coord (0,0) 
    addi $t2, $t2, 48           # coord (0, 12) 
    addi $t2, $t2, 512          # coord (4, 12) 
    jal random_number
    li $a0, 0
    sw $t1, 0($t2)              # $t2: location of first half capsule 
    jal random_number
    add $t3, $t2, 128           # $t3: location of second half capsule 
    sw $t1, 0($t3)
    li $s0, 0                   # $s0 = 0 indicates the capsule is vertical 
    j more_capsule

random_number:
    li $a0, 0
    li $a1, 3
    li $v0, 42                  # random number generate
    syscall 
    move $t1, $a0               # store generated random number in t1     
    beq $t1, 0, red             # jump to set t1 to appropriate colour depending on random number generated 
    beq $t1, 1, blue            
    beq $t1, 2, green
red: 
    li $t1, 0x100ff0001         # the 1, 2, 3 right before the colour bit stoes the identification 
    jr $ra                      # 1 - red, 2 - green, 3 - blue 
blue: 
    li $t1, 0x3000000f3
    jr $ra
green: 
    li $t1, 0x20000ff02
    jr $ra                      # finish drawing capsule 

more_capsule: 
    # 1
    lw $t5, ADDR_DSPL           # coord (0,0) 
    addi $t5, $t5, 108          # coord 
    addi $t5, $t5, 768          # coord 
    jal random_number
    li $a0, 0
    sw $t1, 0($t5)              # $t5: location of first half capsule 
    jal random_number
    add $t6, $t5, 128           # $t6: location of second half capsule 
    sw $t1, 0($t6)
    
    # 2
    addi $t5, $t5, 384          # coord 
    jal random_number
    li $a0, 0
    sw $t1, 0($t5)              # $t5: location of first half capsule 
    jal random_number
    add $t6, $t5, 128           # $t6: location of second half capsule 
    sw $t1, 0($t6)
    
    # 3
    addi $t5, $t5, 384          # coord 
    jal random_number
    li $a0, 0
    sw $t1, 0($t5)              # $t5: location of first half capsule 
    jal random_number
    add $t6, $t5, 128           # $t6: location of second half capsule 
    sw $t1, 0($t6)
    
    # 4 
    addi $t5, $t5, 384          # coord 
    jal random_number
    li $a0, 0
    sw $t1, 0($t5)              # $t5: location of first half capsule 
    jal random_number
    add $t6, $t5, 128           # $t6: location of second half capsule 
    sw $t1, 0($t6)
    j game_loop
    
capsule_continue: 
    li $s0, 0                   # $s0 = 0 indicates the capsule is vertical 
    lw $t2, ADDR_DSPL           # coord (0,0) 
    addi $t2, $t2, 108          
    addi $t2, $t2, 768          
    addi $t3, $t2, 384          # $t3 store the start position of 2nd in line 
    lw $t5, 0($t2) 
    lw $t6, 128($t2) 
    
    lw $t2, ADDR_DSPL           # coord (0,0) 
    addi $t2, $t2, 48           # coord (0, 12) 
    addi $t2, $t2, 512          # coord (4, 12) 
    sw $t5, 0($t2)  
    sw $t6, 128($t2)            # move 1st in upcoming to drop location 
    
    addi $t2, $t3, 0            # 2nd capsule 
    addi $t3, $t3, 384 
    lw $t5, 0($t2) 
    lw $t6, 128($t2) 
    addi $t2, $t2, -384 
    sw $t5, 0($t2)  
    sw $t6, 128($t2)            # move 2nd in upcoming to 1st in upcoming  
    
    addi $t2, $t3, 0            # 3rd capsule 
    addi $t3, $t3, 384 
    lw $t5, 0($t2) 
    lw $t6, 128($t2) 
    addi $t2, $t2, -384 
    sw $t5, 0($t2)  
    sw $t6, 128($t2)            # move 3rd in upcoming to 2nd in upcoming  
    
    addi $t2, $t3, 0            # 4th capsule 
    addi $t3, $t3, 384 
    lw $t5, 0($t2) 
    lw $t6, 128($t2) 
    addi $t2, $t2, -384 
    sw $t5, 0($t2)  
    sw $t6, 128($t2)            # move 4th in upcoming to 3rd in upcoming  
    
    addi $t2, $t3, -384            # 4th capsule generate 
    jal random_number
    li $a0, 0
    sw $t1, 0($t2)              # $t2: location of first half capsule 
    jal random_number
    sw $t1, 128($t2)
    
    lw $t2, ADDR_DSPL           # coord (0,0) 
    addi $t2, $t2, 48           # coord (0, 12) 
    addi $t2, $t2, 512          # coord (4, 12) 
    addi $t3, $t2, 128          # get the $t2 and $t3 to right location for capsule 
    j game_loop

# $t0 stores the keyboard address 
# $t1 stores whether there is the keyboard input 
# $t2 stores the location of capsule first half 
# $t3 stores the location of capsule second half 
# $t4 stores the content of the keybpard input 

# $s0 stores 0 if capsule is vertical and 1 if horizontal 

game_loop:
    lw $t0, ADDR_KBRD           # load keyboard address 
    lw $t1, 0($t0)              # load keyboard input S
    beq $t1, 1, keyboard_input  # if key is pressed 
    # 1a. Check if key has been pressed
    addi $s4, $s4, 1            # counter add 1
    j after_keyboard

keyboard_input:    
    lw $t4, 4($t0)              # load content of keyboard 
    add $a0, $t4, $zero 
    beq $t4, 0x71, quit         # go to line to quit the program 
    beq $t4, 97, move_left      # respond to A key 
    beq $t4, 100, move_right    # respond to D key
    beq $t4, 119, rotate        # respond to W key, rotate clockwise 90 degrees
    beq $t4, 115, move_down     # respond to S key, move down one line at a time 
    add $t9, $t2, $zero         # a copy of $t2 to be used 
    beq $t4, 112, pause          # go to pause mode 
    # 1b. Check which key has been pressed

pause: 
    li $a0, 1
    addi $v0, $zero, 1
    syscall 
    add $t0, $zero, 0xffffff    # draw pause sign 
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 2816 
    addi $t2, $t2, 100
    addi $t1, $t2, 12
    jal draw_line
    addi $t1, $t1, 256
    jal draw_down
    addi $t2, $t1, -12
    jal draw_line
    addi $t1, $t1, -12
    addi $t1, $t1, 384
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 2816 
    addi $t2, $t2, -28
    jal draw_down 
    lw $t7, ADDR_KBRD           # load keyboard address 
    lw $t8, 0($t7)              # load keyboard input S
    beq $t8, 1, pressed         # if key is pressed 
    j pause 

pressed: 
    add $t0, $zero, 0           # undraw pause sign 
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 2816 
    addi $t2, $t2, 100
    addi $t1, $t2, 12
    jal draw_line
    addi $t1, $t1, 256
    jal draw_down
    addi $t2, $t1, -12
    jal draw_line
    addi $t1, $t1, -12
    addi $t1, $t1, 384
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 2816 
    addi $t2, $t2, -28
    jal draw_down 
    lw $t4, 4($t7)              # load content of keyboard 
    add $a0, $t4, $zero 
    add $t2, $t9, $zero 
    beq $t4, 112, game_loop 
    j pause
    
move_left: 
    bne $s0, $zero, left_hor    # go to left_hor if capsule is horizontally displayed 
    lw $t5, -4($t2)             # $t5 stores colour of the first half after move 
    lw $t6, -4($t3)             # $t6 stores ^ for second half 
    jal check_allow 
    j l_continue 
    
    left_hor: 
    lw $t5, -4($t2)             # $t5 stores colour of first half after move 
    li $t6, 0x0                 # $t6 initialize to black -> it will be second half to first half location 
    jal check_allow
    
    l_continue: 
    bne $s1, $zero, after_keyboard # if movement is not allowed, don't execute next lines 
    lw $t5, 0($t2)              # $t5 now stores colour of first capsule 
    lw $t6, 0($t3)              # $t6 for second capsule colour 
    add $t2, $t2, -4            # change where capsule is 
    add $t3, $t3, -4 
    sw $t5, 0($t2)              # update capsule colour 
    sw $t6, 0($t3) 
    li $t7, 0x0
    sw $t7, 4($t3) 
    bne $s0, $zero, after_keyboard  # if it's a horizontal capsule 
    sw $t7, 4($t2)              # change
    j after_keyboard

move_right: 
    bne $s0, $zero, right_hor    # go to right_hor if capsule is horizontally displayed 
    lw $t5, 4($t2)               # $t5 stores colour of the first half after move 
    lw $t6, 4($t3)               # $t6 stores ^ for second half 
    jal check_allow 
    j r_continue
    
    right_hor: 
    lw $t5, 4($t3)              # $t5 stores colour of second half after move 
    li $t6, 0x0                 # $t6 initialize to black -> it will be second half to first half location 
    jal check_allow
    
    r_continue: 
    bne $s1, $zero, after_keyboard # if movement is not allowed, don't execute next lines 
    lw $t5, 0($t2)              # $t5 now stores colour of first capsule 
    lw $t6, 0($t3)              # $t6 for second capsule colour 
    add $t2, $t2, 4            # change where capsule is 
    add $t3, $t3, 4 
    sw $t5, 0($t2)              # update capsule colour 
    sw $t6, 0($t3) 
    li $t7, 0x0
    sw $t7, -4($t2) 
    bne $s0, $zero, after_keyboard  # if it's a horizontal capsule 
    sw $t7, -4($t3)              # change
    j after_keyboard

rotate: 
# the logic: 
    # vertical to horizontal -> second half doesn't move, first half +4, +128 (one to right, one down) -> first half becomes second half (swap type) 
    # horizontal to vertical -> first half doesn't move, second half -4, + 128 (one to left, one down) -> no type swap 
    
    bne $s0, $zero, hor         # go to hor if capsule is horizontally displayed 
    lw $t5, 132($t2)            # $t5 stores colour of the first half after move 
    li $t6, 0                   # $t6 stores 0 (black) because it's default permitted 
    jal check_allow 
    bne $s1, $zero, after_keyboard
    lw $t5, 0($t2)              # load colours for 1st and 2nd halves of capsule 
    lw $t6, 0($t3) 
    addi $t2, $t2, 128          # first half location swapped, now colour should be $t6
    sw $t6, 0($t2) 
    addi $t3, $t3, 4            # second half location move to next, colour $t5
    sw $t5, 0($t3) 
    addi $t7, $zero, 0          # set colour black 
    sw $t7, -128($t2)           # original location to black 
    li $s0, 1
    j after_keyboard
    
    hor: 
    lw $t5, 124($t3)            # $t5 stores colour of second half after move 
    li $t6, 0x0                 # $t6 initialize to black -> it will be first half stay at original position  
    jal check_allow
    bne $s1, $zero, after_keyboard
    lw $t5, 0($t3)              # $t5 for second capsule colour 
    add $t3, $t3, 124           # down 1 left 1 => +124 
    sw $t5, 0($t3)              # update new location colour 
    sw $t6, -124($t3)           # update original location colour to black 
    li $s0, 0
    j after_keyboard

move_down: 
    beq $s0, $zero, down_vert   # go to down_vert if capsule is vertically displayed 
    lw $t5, 128($t2)            # $t5 stores colour of the first half after move 
    lw $t6, 128($t3)            # $t6 stores ^ for second half 
    jal check_allow 
    j d_continue
    
    down_vert: 
    li $t5, 0                   # $t5 initialize to black -> it will be first half to second half location 
    lw $t6, 128($t3)            # $t6 stores the second half colour (new location) 
    jal check_allow
    
    d_continue: 
    bne $s1, $zero, after_keyboard # if movement is not allowed, don't execute next lines 
    lw $t5, 0($t2)              # $t5 now stores colour of first capsule 
    lw $t6, 0($t3)              # $t6 for second capsule colour 
    add $t2, $t2, 128            # change where capsule is 
    add $t3, $t3, 128 
    sw $t5, 0($t2)              # update capsule colour 
    sw $t6, 0($t3) 
    li $t7, 0x0
    sw $t7, -128($t2) 
    beq $s0, $zero, after_keyboard  # if it's a vertical capsule 
    sw $t7, -128($t3)              # change
    j after_keyboard

# check whether movements are allowed 
check_allow: 
# $t7 -> store null for $t5 and $t6 
li $t7, 0
bne $t7, $t5, not_allow  
bne $t7, $t6, not_allow 
li $s1, 0 
li $a0, 55 
li $a1, 2000
li $a2, 100
li $a3, 100
li $v0, 31 
syscall 
jr $ra 
    
not_allow:
li $s1, 1                           # if movement is not allowed, $s1 stores 1
jr $ra 


after_keyboard: 
# $t2 stores the location of capsule first half 
# $t3 stores the location of capsule second half 
# $s0 stores 0 if capsule is vertical and 1 if horizontal 

beq $s4, $s5, gravity 
j detect_collision

gravity: 
    addi $s6, $s6, 1                # overall time depends on the # of drops in gravity 
    beq $s6, $s7, gravity_increase 
    li $s4, 0 
    lw $t5, 0($t2) 
    lw $t6, 0($t3)                  # load colours of capsule 
    sw $zero, 0($t2)
    sw $zero, 0($t3)                # change colour to black 
    addi $t2, $t2, 128 
    addi $t3, $t3, 128              # drop 1 down 
    sw $t5, 0($t2)
    sw $t6, 0($t3)                  # change next block colour
    j detect_collision

gravity_increase: 
    addi $s5, $s5, 100000
    j gravity 

detect_collision: 
    beq $s0, $zero, ver_collision   # go check if vertical collision happened
    li $t7, 0                       # load black 
    
    hor_collision: 
    lw $t5, 128($t2)                # if the pixel under $t2 is not black 
    bne $t5, 0, detect_cancel       # continue to detect whether t3 is colliding 
    
    ver_collision: 
    lw $t6, 128($t3) 
    bne $t6, 0, detect_cancel       # t3 block collided 
    
    j game_loop
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

# systematic 4-in-a-row detection 
detect_cancel: 
    lw $t5, ADDR_DSPL           # coord (0,0) 
    addi $t5, $t5, 48           # coord (0, 12) 
    addi $t5, $t5, 512          # coord (4, 12) 
    beq $t2, $t5, quit          # if top is blocked, game over 
    
    addi $t5, $t5, 384 
    addi $t5, $t5, -36          # starting row 1 column 1 of bottle 
    add $t9, $zero, 0           # $t9 stores the colour of current stack, initialized to black 
    
    hor_cancel: 
    lw $t6, 0($t5)              # $t6 store colour of the current pixel 
    beq $t6, $zero, next_hor_pix # if current pixel is black 
    lw $t7, BOTTLE_COLOUR       # if reach bottle right side 
    beq $t6, $t7, next_hor_line # move to next line 
    bne $sp, $s2, continue_stack 
    sll $t9, $t6, 30             # if the stack is empty, stack colour is initialized to this colour's identification 
    sw $t5, 0($sp)              # save the location on stack pointer 
    addi $sp, $sp, -4           # move stack pointer up 
    j next_hor_pix
    
    continue_stack: 
    sll $t6, $t6, 30             # shift right by 8 bits, get colour identification 
    beq $t6, $t9, add_to_stack  # if colour match current colour in stack ($t6 store colour of the current block)
    
    # clear stack 
    add $sp, $zero, $s2         # move stack pointer to initial position 
    li $t9, 0                   # $t9 that stores the colour set to black 
    addi $t5, $t5, 4            # move to the next pixel (can't be end of the line, don't need +52)
    j hor_cancel
    
    add_to_stack: 
    sw $t5, 0($sp)              # save the new location in stack 
    addi $sp, $sp, -4           # move stack pointer up 
    addi $t8, $s2, -16          # $t8 store the location of $sp if four in a row already 
    bne $t8, $sp, next_hor_pix  # if not 4 in a row yet 
    addi $sp, $sp, 4
    # li $a0, 86 
    # li $a1, 2000
    # li $a2, 72
    # li $a3, 100
    # li $v0, 31 
    # syscall 
    lw $a2, 0($sp)              # load value location of last pixel in $a2
    j drop_pixel
    
    drop_pixel: 
    lw $a3, -128($a2)           # load the pixel above it 
    beq $a3, $zero, to_black    # check if pixel colour is black  
    li $t9, 0x100000071         # load virus colour 1
    beq $a3, $t9, to_black
    li $t9, 0x200007002         # load virus colour 2
    beq $a3, $t9, to_black
    li $t9, 0x100700003
    beq $a3, $t9, to_black
    sw $a3, 0($a2)              # change colour to pixel above it
    addi $a2, $a2, -128         # look at the pixel above
    j drop_pixel
    
    to_black: 
    sw $zero, 0($a2)            # change colour of this pixel to black 
    beq $sp, $s2, cancel_con    # if $sp is done, go to continue detecting 4-in-a-row 
    addi $sp, $sp, 4            # change stack pointer 
    lw $a2, 0($sp)              # load stack pointer a2 value 
    j drop_pixel 
    # drop the pixels down 
    
    cancel_con: 
    addi $t5, $t5, -16          # move 4 pixel left 
    j hor_cancel

    next_hor_pix: 
    addi $t5, $t5, 4            # move to examine the next pixel 
    j hor_cancel
    
    next_hor_line: 
    lw $s3, 124($t5)            # look at the colour of the pixel next line left position 
    beq $s3, $t7, ver_cancel    # horizontal check reached end check vertical cancel 
    addi $t5, $t5, 52           # move to examine the next line 
    add $sp, $zero, $s2         # move stack pointer to initial position 
    li $t9, 0                   # $t9 that stores the colour set to black => clear stack 
    j hor_cancel
    

    ver_cancel: 
    lw $t5, ADDR_DSPL           # coord (0,0) 
    addi $t5, $t5, 48           # coord (0, 12) 
    addi $t5, $t5, 512          # coord (4, 12) 
    beq $t2, $t5, quit          # if top is blocked, game over 
    
    addi $t5, $t5, 384 
    addi $t5, $t5, -36          # starting row 1 column 1 of bottle 
    add $t9, $zero, 0           # $t9 stores the colour of current stack, initialized to black 
    sw $t9, 0($t5) 
    
    ver_cancel_continue: 
    lw $t6, 0($t5)              # $t6 store colour of the current pixel 
    beq $t6, $zero, next_ver_pix # if current pixel is black 
    lw $t7, BOTTLE_COLOUR       # if reach bottle right side 
    beq $t6, $t7, next_ver_line # move to next line 
    sll $t6, $t6, 30             # $t6 stores the colour id of the current pixel 
    lw $t9, 128($t5)            # $t9 stores the colour of pixel below 
    sll $t9, $t9, 30            # colour id of pixel below 
    bne $t6, $t9, next_ver_pix  # if second pixel not right colour, go to examine next pixel horizontally 
    lw $t9, 256($t5)            # $t9 stores the colour of pixel below 
    sll $t9, $t9, 30            # colour id of pixel below 
    bne $t6, $t9, next_ver_pix
    lw $t9, 384($t5)            # $t9 stores the colour of pixel below 
    sll $t9, $t9, 30            # colour id of pixel below 
    bne $t6, $t9, next_ver_pix
    add $a2, $t5, 384
    jal drop_pixel_ver                # drop pixel 
    add $a2, $t5, 384
    jal drop_pixel_ver                # drop pixel 
    add $a2, $t5, 384
    jal drop_pixel_ver                # drop pixel 
    add $a2, $t5, 384
    jal drop_pixel_ver                # drop pixel 
    j next_ver_pix
    
    
    drop_pixel_ver: 
    lw $a3, -128($a2)           # load the pixel above it 
    beq $a3, $zero, to_black_ver    # check if pixel colour is black  
    li $t9, 0x300000073         # load virus colour 1
    beq $a3, $t9, to_black_ver
    li $t9, 0x200007002         # load virus colour 2
    beq $a3, $t9, to_black_ver
    li $t9, 0x100700001
    beq $a3, $t9, to_black_ver
    sw $a3, 0($a2)              # change colour to pixel above it
    addi $a2, $a2, -128         # look at the pixel above
    j drop_pixel_ver
    
    to_black_ver: 
    sw $zero, 0($a2)            # change colour of this pixel to black 
    jr $ra 
    
    next_ver_pix: 
    addi $t5, $t5, 4            # next pixel horizontally 
    j ver_cancel_continue
    
    next_ver_line: 
    lw $s3, 124($t5)            # look at the colour of the pixel next line same position 
    beq $s3, $t7, virus_gone  # vertical check end, draw capsule 
    addi $t5, $t5, 52           # move to examine the next line 
    j ver_cancel_continue 
    
    virus_gone: 
    lw $t5, ADDR_DSPL           # coord (0,0) 
    addi $t5, $t5, 48           # coord (0, 12) 
    addi $t5, $t5, 512          # coord (4, 12) 
    beq $t2, $t5, quit          # if top is blocked, game over 
    
    addi $t5, $t5, 384 
    addi $t5, $t5, -36          # starting row 1 column 1 of bottle 
    
    examine_pix: 
    lw $t6, 0($t5)              # $t6 store colour of the current pixel 
    li $t9, 0x300000073         # load virus colour 3 
    beq $t6, $t9, next_pix
    li $t9, 0x200007002         # load virus colour 2
    beq $t6, $t9, next_pix
    li $t9, 0x100700001
    beq $t6, $t9, next_pix      # if virus, don't do anything 
    beq $t6, $zero, next_pix    # if current pixel is black 
    lw $t7, BOTTLE_COLOUR       # if reach bottle right side 
    beq $t6, $t7, next_line     # move to next line 
    lw $t8, 128($t5)            # load colour of pixel under it in $t8 
    bne $t8, $zero, next_pix    # if pixel not floating (colour not black) 
    lw $t8, -4($t5)             # load colour to the left 
    bne $t8, $zero, next_pix    # if pixel has left support 
    lw $t8,4($t5)               # load colour to the right
    bne $t8, $zero, next_pix    # if pixel has right support 
    
    drop: 
    addi $a2, $t5, 0            # $a2 store the location of pixel to be moved down 
    continue_drop: 
    sw $t6, 128($a2)            # store current colour at pixel below 
    addi $a2, $a2, -128         # pointer move 1 pixel up 
    lw $t6, 0($a2)              # load colour above 
    beq $t6, $zero, to_black_vir    # if all pixel in this column dropped, examine next pixel 
    j continue_drop
    
    to_black_vir: 
    sw $zero, 128($a2)          # change colour to black 
    j next_pix 
    
    next_pix: 
    addi $t5, $t5, 4            # next pixel horizontally 
    j examine_pix
    
    next_line: 
    lw $s3, 124($t5)            # look at the colour of the pixel next line left position 
    beq $s3, $t7, capsule_continue  # virus disappear check reached end, draw new capsule  
    addi $t5, $t5, 52           # move to examine the next line 
    add $sp, $zero, $s2         # move stack pointer to initial position 
    li $t9, 0                   # $t9 that stores the colour set to black => clear stack 
    j examine_pix
    

quit: 
    li $a0, 86 
    li $a1, 2000
    li $a2, 72
    li $a3, 100
    li $v0, 31 
    syscall 
    add $t0, $zero, 0x0
    lw $t2, ADDR_DSPL
    add $t1, $t2, 16384
    jal draw_line               # black background draw 
    add $t0, $zero, 0xffffff
    lw $t2, ADDR_DSPL
    # G 
    addi $t2, $t2, 1040
    addi $t2, $t2, 12
    addi $t1, $t2, 24
    jal draw_line
    lw $t2, ADDR_DSPL
    addi $t2, $t2, 1040
    addi $t2, $t2, 12
    addi $t1, $t2, 768
    jal draw_down
    addi $t1, $t2, 24
    jal draw_line
    addi $t2, $t2, -512
    jal draw_down
    addi $t1, $t1, -512 
    addi $t2, $t1, -16
    jal draw_line
    
    # O 
    addi $t2, $t2, -256, 
    addi $t2, $t2, 20 
    addi $t1, $t2, 24
    jal draw_line
    addi $t1, $t1, 768
    jal draw_down 
    addi $t2, $t2, -24
    jal draw_line
    addi $t2, $t2, -24
    addi $t2, $t2, -768 
    addi $t1, $t2, 768 
    jal draw_down 
    
    # . 
    addi $t2, $t2, -12
    sw $t0, 0($t2) 
    
    r_or_not: 
    lw $t0, ADDR_KBRD           # load keyboard address 
    lw $t3, 4($t0)              # load content of keyboard 
    addi $t4, $zero, 114        # restart game 
    beq $t3, $t4, main 
    addi $t4, $zero, 121        # confirm end with Y
    beq $t3, $t4, end 
    j r_or_not 
    

end: 
	li $v0, 10                  # quit gracefully
	syscall