; This file assumes "base.asm" is imported somewhere
enable_buttons:
  ; Enable GPIO 24,18,23,25
push {r0-r4,lr}
  mov r0, BASE
  orr r0, GPIO_OFFSET ;r0 now equals 0x3F200000

  ; We want high detection which we can enable by setting GPHEN0 (high detect enable)
  ; We want to set bits 24, 18, 23 and 25
  mov r3, #1
  lsl r3, #24

  mov r4, #1
  lsl r4, #18
  orr r3,r3,r4

  mov r4, #1
  lsl r4, #23
  orr r3,r3,r4

  mov r4, #1
  lsl r4, #25
  orr r3,r3,r4

  str r3, [r0,GPHEN0_OFFSET]

  ; We also want to enable pull-down so GPIO24 defaults to a value of 0.
  ; If we don't do this it's undefined and can "float" between 0 and 1
  ; The process is a bit tricky.
  ; See PG 101 of https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2835/BCM2835-ARM-Peripherals.pdf

  ; Step 1. Write to GPPUD to set whether we want pull-up or pull-down. This is
  ; "global" for all GPIO pins. Here we're doing pull-down.
  mov r1,01                     ; 00 = disable, 01 = pull-down, 10 = pull-up, 11 = reserved
  str r1,[r0,GPPUD_OFFSET]

  ; Step 2. Wait for 150 cycles. Gives the previous step time to do it's thing
  push {lr}
  bl wait_150_cycles
  pop {lr}

  ; Step 3. Set the specific GPIO pin to have it's status updated. It'll go to pull down
  ; because that's what we said in the previous step
  ; This is the same number as before so we can re-use r3
  str r3,[r0,GPPUDCLK0_OFFSET]

  ; Step 4. Wait for 150 cycles again. Gives the clock time to assert it's changes
  push {lr}
  bl wait_150_cycles
  pop {lr}

  ; Step 5. Remove our control signal
  mov r1,00
  str r1,[r0,GPPUD_OFFSET]

  ; Step 6. Remove our clock
  mov r1,#0
  str r1,[r0,GPPUDCLK0_OFFSET]
pop {r0-r4,pc}

; No longer used. Kept because it's a useful utility
poll_for_button_press:
  ; parameters:
  ; r0 = GPIO pin to read
  ;
  ; Poll the GPIO event detect status register to see if the button has
  ; been pushed
  push {r0-r4,lr}
    mov r4,r0
    mov r0, BASE
    orr r0, GPIO_OFFSET ;r0 now equals 0x3F200000

    poll_for_button_press_loop:
      ; ldr r1,[r0,#52]         ; Load GPLEV0 into r1
      ; Load GPEDS0 into r1. Has event detection for GPIO 31-0
      ldr r1,[r0,GPEDS0_OFFSET]

      mov r2,#1
      lsl r2,r4
      teq r1,r2               ; Is bit n set?
    bne poll_for_button_press_loop               ; Loop if bit n isn't set

    ; We need to clear GPEDS0 since we've detected the event. We do that by
    ; writing a 1 to the register
    mov r1,#1
    lsl r1,r4
    str r1,[r0,GPEDS0_OFFSET]
  pop {r0-r4,pc}

poll_for_any_button_press:
; returns the a bitmask in r0 with 1s set if that GPIO button is pushed.
; bits 31-0 = GPIO31-0
push {r1-r4,lr}
  mov r0, BASE
  orr r0, GPIO_OFFSET ;r0 now equals 0x3F200000

  poll_for_any_button_press_loop:
    ; Load GPEDS0 into r1. Has event detection for GPIO 31-0
    ldr r1,[r0,GPEDS0_OFFSET]

    ; Check if any of our GPIO pins are active
    mov r2,#1                   ; r2 holds our bitmask to test against
    lsl r2,#24

    mov r3,#1
    lsl r3,#18
    orr r2,r3

    mov r3,#1
    lsl r3,#25
    orr r2,r3

    mov r3,#1
    lsl r3,#23
    orr r2,r3

    tst r1,r2

    ; tst does a bitwise AND and will return a non-zero
    ; if there is a match. Because of this we need to use
    ; branch-equal as if it's equal there is no match.
  beq poll_for_any_button_press_loop

  ; We need to clear GPEDS0 since we've detected the event. We do that by
  ; writing a 1 to the register. Luckily we know which bits we need since
  ; the GPIO gave them to us
  str r1,[r0,GPEDS0_OFFSET]

  ; Now we just return the GPIO buttons that were pushed
  mov r0,r1
pop {r1-r4,lr}

wait_150_cycles:
  push {r0}
  mov r0,#150
    wait_150_cycles_loop:
      sub r0,r0,#1
      cmp r0,#0
    bgt wait_150_cycles_loop
  pop {r0}
bx lr
