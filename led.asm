; This file assumes "base.asm" and "delay.asm" are imported somewhere

; Enables GPIO output on GPIO27
; This doesn't conflict with enable_buttons because we're using GPFSEL instead of
; GPHEN
enable_led:
push {r0-r1,lr}
  mov r0, BASE
  orr r0, GPIO_OFFSET ;r0 now equals 0x3F200000

  ; Set bit 21 of GPFSEL2 to enable output on GPIO27 (see broadcom datasheet)
  mov r1,#1
  lsl r1,#21
  str r1,[r0,GPFSEL2_OFFSET]
pop {r0-r1,pc}


; Blinks the LED enabled on GPIO27
blink_led:
push {r0-r1,lr}
  mov r0, BASE
  orr r0, GPIO_OFFSET ;r0 now equals 0x3F200000

  ; Turn the light on
  mov r1,#1
  lsl r1,#27
  str r1,[r0,GPSET0_OFFSET]

  ; Wait for a few milliseconds so we can see the blink
  push {r0}
  mov r0,#500
  bl delay
  pop {r0}

  ; Turn the light off
  mov r1,#1
  lsl r1,#27
  str r1,[r0,GPCLR0_OFFSET]

  ; Wait for a few milliseconds so we can see that it's off
  push {r0}
  mov r0,#500
  bl delay
  pop {r0}
pop {r0-r1,pc}
