.section .rodata
    RCC_AHB2ENR : .word 0x4002104c // AHB2 peripheral clock enable reg
    RCC_APB1ENR1: .word 0x40021058 // APB1 peripheral clock enable reg 1
    TIM2_CR1    : .word 0x40000000 // TIM2 control reg 1
    TIM2_DIER   : .word 0x4000000c // TIM2 DMA/interrupt enable reg
    TIM2_SR     : .word 0x40000010 // TIM2 status reg
    TIM2_CNT    : .word 0x40000028 // TIM2 counter reg
    TIM2_PSC    : .word 0x40000028 // TIM2 prescaler reg
    TIM2_ARR    : .word 0x4000002c // TIM2 auto-reload reg
    GPIOB_MODER : .word 0x48000400 // GPIOB mode reg
    GPIOB_OTYPER: .word 0x48000404 // GPIOB output type reg
    GPIOB_ODR   : .word 0x48000414 // GPIOB output data reg
    GPIOB_BSRR  : .word 0x48000418 // GPIOB bit set reset reg
    NVIC_ISER0  : .word 0xE000E100 // NVIC interrupt set enable reg

.section .text
.global SystemInit
.global _start

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
    mvn     r2, r2 // clear bit 13 mask
    ldr     r3, [r0]
    and     r3, r3, r2
    orr     r3, r3, r1
    str     r3, [r0]

    // Set push-pull output
    ldr     r0, =GPIOB_OTYPER
    ldr     r0, [r0]
    lsr     r1, r1, #7 // clear bit 6 mask
    mvn     r1, r1
    ldr     r2, [r0]
    and     r2, r2, r1
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
    mov     r1, #1
    lsl     r1, r1, #28
    ldr     r2, [r0]
    orr     r2, r2, r1
    str     r2, [r0]

    // Enable TIM2 counter
    ldr     r0, =TIM2_CR1
    ldr     r0, [r0]
    mov     r1, #1
    ldrh    r2, [r0]
    orr     r2, r2, r1
    strh    r2, [r0]

    ldr     r0, =RCC_APB1ENR1
    ldr     r1, =TIM2_CR1
    ldr     r2, =TIM2_DIER
    ldr     r3, =TIM2_SR
    ldr     r4, =TIM2_PSC
    ldr     r5, =TIM2_ARR
    ldr     r6, =NVIC_ISER0
    ldr     r0, [r0]
    ldr     r1, [r1]
    ldr     r2, [r2]
    ldr     r3, [r3]
    ldr     r4, [r4]
    ldr     r5, [r5]
    ldr     r6, [r6]
    ldr     r0, [r0]
    ldr     r1, [r1]
    ldr     r2, [r2]
    ldr     r3, [r3]
    ldr     r4, [r4]
    ldr     r5, [r5]
    ldr     r6, [r6]

counter_loop:
    ldr     r7, =TIM2_CNT
    ldr     r7, [r7]
    ldr     r7, [r7]
    b       counter_loop

_start:
    bx      lr

.global TIM2_IRQHandler
TIM2_IRQHandler:
    push    {lr}
    ldr     r0, =TIM2_SR
    ldr     r0, [r0]
    mov     r1, #1
    ldr     r2, [r0]
    tst     r2, r1

    ldr     r0, =GPIOB_BSRR
    ldr     r0, [r0]
    mov     r1, #1
    lsl     r1, r1, #6
    ldr     r2, [r0]
    orr     r2, r2, r1
    str     r2, [r0]
    pop     {pc}
