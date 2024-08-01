.syntax unified
.cpu cortex-m4
.thumb

.section .rodata
    RCC_AHB2ENR : .word 0x4002104c // AHB2 peripheral clock enable reg
    RCC_APB1ENR1: .word 0x40021058 // APB1 peripheral clock enable reg 1
    TIM2_CR1    : .word 0x40000000 // TIM2 control reg 1
    TIM2_DIER   : .word 0x4000000c // TIM2 DMA/interrupt enable reg
    TIM2_SR     : .word 0x40000010 // TIM2 status reg
    TIM2_CNT    : .word 0x40000024 // TIM2 counter reg
    TIM2_PSC    : .word 0x40000028 // TIM2 prescaler reg
    TIM2_ARR    : .word 0x4000002c // TIM2 auto-reload reg
    GPIOB_MODER : .word 0x48000400 // GPIOB mode reg
    GPIOB_OTYPER: .word 0x48000404 // GPIOB output type reg
    GPIOB_ODR   : .word 0x48000414 // GPIOB output data reg
    GPIOB_BSRR  : .word 0x48000418 // GPIOB bit set reset reg
    NVIC_ISER0  : .word 0xE000E100 // NVIC interrupt set enable reg

.section .text

.global SystemInit
SystemInit:
    // Enable GPIOB clock
    ldr     r0, =RCC_AHB2ENR
    ldr     r0, [r0]
    mov     r1, #1
    lsl     r1, r1, #1 // set bit 1 mask
    ldr     r2, [r0]
    orr     r2, r2, r1
    str     r2, [r0]

    // Enable TIM2 clock
    ldr     r0, =RCC_APB1ENR1
    ldr     r0, [r0]
    lsr     r1, r1, #1 // set bit 0 mask
    ldr     r2, [r0]
    orr     r2, r2, r1
    str     r2, [r0]

    // Set output mode for PB6
    ldr     r0, =GPIOB_MODER
    ldr     r0, [r0]
    lsl     r1, r1, #12 // set bit 12 mask
    lsl     r2, r1, #1
    ldr     r3, [r0]
    bic     r3, r3, r2 // clear bit 13
    orr     r3, r3, r1
    str     r3, [r0]

    // Set push-pull output
    ldr     r0, =GPIOB_OTYPER
    ldr     r0, [r0]
    lsr     r1, r1, #7 // clear bit 6 mask
    ldr     r2, [r0]
    bic     r2, r2, r1
    str     r2, [r0]

    // Set timer to 1Hz
    ldr     r0, =TIM2_PSC
    ldr     r0, [r0]
    ldr     r1, =399 // 4Mhz / 400 = 10KHz
    strh    r1, [r0]

    ldr     r0, =TIM2_ARR
    ldr     r0, [r0]
    ldr     r1, =9999 // 10KHz / 10000 = 1Hz
    str     r1, [r0]

    // Enable TIM2 update interrupt
    ldr     r0, =TIM2_DIER
    ldr     r0, [r0]
    mov     r1, #1
    ldrh    r2, [r0]
    orr     r2, r2, r1
    strh    r2, [r0]

    // Enable NVIC TIM2 global interrupt
    ldr     r0, =NVIC_ISER0
    ldr     r0, [r0]
    lsl     r1, r1, #28
    ldr     r2, [r0]
    orr     r2, r2, r1
    str     r2, [r0]

    // Enable TIM2 counter
    ldr     r0, =TIM2_CR1
    ldr     r0, [r0]
    lsr     r1, r1, #28
    ldrh    r2, [r0]
    orr     r2, r2, r1
    strh    r2, [r0]
    bx      lr

.global _start
_start:
    // Pre-load registers with special values
    ldr     r0, =TIM2_SR
    ldr     r0, [r0]
    ldr     r1, =GPIOB_ODR
    ldr     r1, [r1]
    ldr     r2, =GPIOB_BSRR
    ldr     r2, [r2]
    mov     r3, #1
    lsl     r5, r3, #6
    mov     r6, #6
    mov     r7, #22
    b       .               // Infinite loop

.global TIM2_IRQHandler
.type   TIM2_IRQHandler, %function
TIM2_IRQHandler:
    ldr     r8, [r0]        // Load TIM2 status reg
    bic     r9, r8, r3      // Clear bit 0
    str     r9, [r0]        // Write updated status reg
    tst     r8, #1          // Check update interrupt flag
    bne     toggle_led      // Conditional branch to toggle_led
    bx      lr
toggle_led:
    ldr     r8, [r1]        // Load GPIOB_ODR
    tst     r8, r5          // Check bit 6
    bne     reset_bsrr
set_bsrr:
    lsl     r8, r3, r6      // 1 << 6 to set ODR
    b       write_bsrr
reset_bsrr:
    lsl     r8, r3, r7      // 1 << 22 to reset ODR
write_bsrr:
    str     r8, [r2]        // Write to GPIOB_BSRR
    bx      lr
