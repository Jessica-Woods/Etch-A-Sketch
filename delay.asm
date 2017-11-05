delay:
  ; parameters:
  ; r0 = how much time to wait in milliseconds
push {r0-r8,lr}
  ; Convert r0 into microseconds since that's what we're loading
  mov r4, r0
  mov r1, #1000
  mul r4, r1

  ; Load the timer memory offset into r1
  mov r1, BASE
  orr r1, TIMER_OFFSET

  ; Load start time into r5
  ldrd r6,r7,[r1,#4]
  mov r5,r6

  delay_loop:
    ldrd r6,r7,[r1,#4]          ; Load current time into r6
    sub r8,r6,r5                ; Subtract our start time from our current
    cmp r8,r4                   ; See if the time that has passed exceeds our time to wait
  bls delay_loop                ; If not, loop
pop {r0-r8,pc}
