BASE = $3F000000 ;$ means HEX
GPIO_OFFSET=$200000
TIMER_OFFSET=$3000 ; Used to read system clock
GPFSEL1_OFFSET=$4  ; GPIO function select 1 offset (GPIO 10-19). 3 bits per GPIO
GPFSEL2_OFFSET=$8  ; GPIO function select 2 offset (GPIO 20-29). 3 bits per GPIO
GPSET0_OFFSET=$1C  ; Covers GPIO 0-31. Used to set output
GPCLR0_OFFSET=$28  ; Covers GPIO 0-31. Used to clear output
GPLEV0_OFFSET=$34  ; Covers GPIO 0-31. Use to read input
GPEDS0_OFFSET=$40  ; Covers GPIO 0-31. Used to check for detected events
GPREN0_OFFSET=$4C  ; Covers GPIO 0-31. Rising edge detect enable
GPHEN0_OFFSET=$64  ; Covers GPIO 0-31. High detect enable

; Both of these are used together to enable pull-up/pull-down. Needed for buttons
GPPUD_OFFSET=$94
GPPUDCLK0_OFFSET=$98
