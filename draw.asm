;FILE draw.asm
drawpixel:
  ; parameters:
  ; r0 = screen memory address incl channel number
  ; r1 = x
  ; r2 = y
  ; r3 = colour (8bit RGB)
  ; assume BITS_PER_PIXEL, SCREEN_X are shared constants
  ; (they're not, but they are global pointers to values)
  ; r8 and r9 are used as temp registers
  ;
  ; Example usage:
  ;
  ;     push {r0-r3}
  ;     mov r0,...    ; Screen address
  ;     mov r1,...    ; x
  ;     mov r2,...    ; y
  ;     mov r3,...    ; colour
  ;     bl drawpixel
  ;     pop {r0-r3}

  ;calculate x term (x * BITS_PER_PIXEL  / BITS PER BYTE)
  push {r8-r9}
  mov r8,r1   ;x
  mov r9, BITS_PER_PIXEL   ;*BITS_PER_PIXEL (16)
  mul r8,r9
  lsr r8,#3   ;/8 (bits per byte)
  add r0,r8   ;add x term

  ;calc y term (y * SCREEN_X * BITS_PER_PIXEL / BITS PER BYTE)
  mov r8,SCREEN_X ;640
  mul r8,r2  ;* y
  mul r8,r9  ;*BITS_PER_PIXEL
  lsr r8,#3  ;/8 bits per byte
  add r0,r8   ;add y term
  pop {r8-r9}

  ; Write the colour to the address we calculated
  strb r3,[r0]
bx lr

drawline:
  ; parameters:
  ; r0 = screen memory address incl channel number
  ; r1 = start x
  ; r2 = start y
  ; r3 = x increment (amount to increment x by each step)
  ; r4 = y increment (amount to increment y by each step)
  ; r5 = pixels_to_draw (how many pixels the line has)
  ; r6 = colour
  ;
  ; We use r1 and r2 as our "current x" and "current y"
  ; We check if length is negative to see if we exceed it
  drawline_drawloop:
    ; Draw our current pixels based on our increments
    push {lr,r0-r3}
      ; mov r0,r0    ; Screen address
      ; mov r1,r1    ; x
      ; mov r2,r2    ; y
      mov r3,r6    ; colour
      bl drawpixel
    pop {lr,r0-r3}

    ; Increment
    add r1,r1,r3
    add r2,r2,r4

    ; Lower our pixels_to_draw since we've drawn one pixel we have one less to draw
    sub r5,r5,#1

    ; Check if we've exceeded our pixels to draw
    cmp r5,#0
  bgt drawline_drawloop
bx lr

drawsquare:
  ; parameters:
  ; r0 = screen memory address incl channel number
  ; r1 = start x
  ; r2 = start y
  ; r3 = edge_length (how many pixels per edge of the square)
  ; r4 = colour

  ; Draw the top line
  push {lr,r0-r6}
    ; mov r0,r0 ; screen memory address
    ; mov r1,r1 ; line start x
    ; mov r2,r2 ; line start y
    mov r5,r3 ; Edge length, must be done before we set r3
    mov r6,r4 ; Colour, must be done before we set r4
    mov r3,#1 ; x increment
    mov r4,#0 ; y increment
    bl drawline
  pop {lr,r0-r6}

  ; Draw the left line
  push {lr,r0-r6}
    ; mov r0,r0 ; screen memory address
    ; mov r1,r1 ; line start x
    ; mov r2,r2 ; line start y
    mov r5,r3 ; Edge length, must be done before we set r3
    mov r6,r4 ; Colour, must be done before we set r4
    mov r3,#0 ; x increment
    mov r4,#1 ; y increment
    bl drawline
  pop {lr,r0-r6}

  ; Draw the right line
  push {lr,r0-r6}
    ; Set our x to the right of the square
    add r1,r1,r3

    ; mov r0,r0 ; screen memory address
    ; mov r1,r1 ; line start x
    ; mov r2,r2 ; line start y
    mov r5,r3 ; Edge length, must be done before we set r3
    mov r6,r4 ; Colour, must be done before we set r4
    mov r3,#0 ; x increment
    mov r4,#1 ; y increment
    bl drawline
  pop {lr,r0-r6}

  ; Draw the bottom line
  push {lr,r0-r6}
    ; Set our y to the bottom of the square
    add r2,r2,r3

    ; Make the last line slightly longer to complete the square
    add r3,r3,#1

    ; mov r0,r0 ; screen memory address
    ; mov r1,r1 ; line start x
    ; mov r2,r2 ; line start y
    mov r5,r3 ; Edge length, must be done before we set r3
    mov r6,r4 ; Colour, must be done before we set r4
    mov r3,#1 ; x increment
    mov r4,#0 ; y increment
    bl drawline
  pop {lr,r0-r6}
bx lr
