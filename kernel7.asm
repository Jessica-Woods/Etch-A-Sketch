; Rasberry Pi 3. 'Bare Metal' 8-Bit etch-a-sketch
;
; 1. Setup frame buffer and get a pointer to it at r0
; 2. Setup GPIO input/output
; 3. Blink the light to show we're ready
; 4. Start Loop. Read input from buttons and move
;    the pixel around.
;
;    Multi-button input is supported so diagonal lines work.
;
;    Drawings are actually a 2px square instead of a single pixel.

;r0 = pointer + x * BITS_PER_PIXEL/8 + y * SCREEN_X * BITS_PER_PIXEL/8
format binary as 'img'

; Set up our memory and stack
org $0000
mov sp,$1000

; This makes us single-threaded which prevents all sorts of weird
; drawing and logic bugs
; Return CPU ID (0..3) Of The CPU Executed On
mrc p15,0,r0,c0,c0,5 ; R0 = Multiprocessor Affinity Register (MPIDR)
ands r0,3 ; R0 = CPU ID (Bits 0..1)
bne CoreLoop ; IF (CPU ID != 0) Branch To Infinite Loop (Core ID 1..3)

; Initialize the framebuffer so we can draw
mov r0,BASE
bl FB_Init
;r0 now contains address of screen
;SCREEN_X and BITS_PER_PIXEL are global constants populated by FB_Init

and r0,$3FFFFFFF ; Convert Mail Box Frame Buffer Pointer From BUS Address To Physical Address ($CXXXXXXX -> $3XXXXXXX)
str r0,[FB_POINTER] ; Store Frame Buffer Pointer Physical Address

mov r7,r0 ;back-up a copy of the screen address + channel number

;set colour to white
mov r9,BITS_PER_PIXEL
mov r6,#1

; Enable our GPIO inputs/outputs
push {lr}
bl enable_buttons
bl enable_led
pop {lr}

; Before we start let's blink the lights to show we're ready
push {lr}
bl blink_led
bl blink_led
bl blink_led
pop {lr}


; Outer loop variables
; We're using r8 as our x and r9 as our y.
mov r8,#320                   ; Start at center
mov r9,#240                   ; Start at center

Loop:
  ; Draw our current position
  push {r0-r4,lr}
  mov r0,r7                     ; Screen address
  mov r1,r8                     ; Use our current x
  mov r2,r9                     ; Use our current y
  mov r3,#1                     ; 1 pixel length square
  mov r4,r6                     ; White
  bl drawsquare
  pop {r0-r4,lr}

  ; Accept input and manipulate our position
  push {lr}
  bl poll_for_any_button_press    ; Returns the GPIO event mask in r0
  pop {lr}

  ; If 18 was pushed, move up
  mov r1,#1
  lsl r1,#18
  tst r0,r1                     ; tst will return "not equal" if the 18th bit is set
  subne r9,r9,#1                ; for both r0 and r1.

  ; If 23 was pushed, move right
  mov r1,#1
  lsl r1,#23
  tst r0,r1
  addne r8,r8,#1

  ; If 24 was pushed, move down
  mov r1,#1
  lsl r1,#24
  tst r0,r1
  addne r9,r9,#1

  ; If 25 was pushed, move left
  mov r1,#1
  lsl r1,#25
  tst r0,r1
  subne r8,r8,#1

  ; Wait a bit so we don't draw super-fast
  push {r0,lr}
  mov r0, #50
  bl delay
  pop {r0,lr}
b Loop  ;wait forever

CoreLoop: ; Infinite Loop For Core 1..3
  b CoreLoop

include "fbinit8.asm"
include "base.asm"
include "draw.asm"
include "button.asm"
include "delay.asm"
include "led.asm"
