#include <stdint.h>

static uint32_t *RCC_AHB2ENR  = (uint32_t *)0x4002104c; // AHB2 peripheral clock enable reg
static uint32_t *RCC_APB1ENR1 = (uint32_t *)0x40021058; // APB1 peripheral clock enable reg 1
static uint16_t *TIM2_CR1     = (uint16_t *)0x40000000; // TIM2 control reg 1
static uint16_t *TIM2_DIER    = (uint16_t *)0x4000000c; // TIM2 DMA/interrupt enable reg
static uint16_t *TIM2_SR      = (uint16_t *)0x40000010; // TIM2 status reg
static uint16_t *TIM2_PSC     = (uint16_t *)0x40000028; // TIM2 prescaler reg
static uint32_t *TIM2_ARR     = (uint32_t *)0x4000002c; // TIM2 auto-reload reg
static uint32_t *GPIOB_MODER  = (uint32_t *)0x48000400; // GPIOB mode reg
static uint32_t *GPIOB_OTYPER = (uint32_t *)0x48000404; // GPIOB output type reg
static uint32_t *GPIOB_ODR    = (uint32_t *)0x48000414; // GPIOB output data reg
static uint32_t *GPIOB_BSRR   = (uint32_t *)0x48000418; // GPIOB bit set reset reg
static uint32_t *NVIC_ISER0   = (uint32_t *)0xE000E100; // NVIC interrupt set enable reg

static const int set_or_reset[2] = { 6, 22 };

void SystemInit(void)
{
    // System clock initialized automatically @ 4 MHz

    // Enable GPIOB clock
    *RCC_AHB2ENR |= 1U << 1;
    // Enable TIM2 clock
    *RCC_APB1ENR1 |= 1U;

    // Set output mode for PB6
    *GPIOB_MODER &= ~(1U << 13);
    *GPIOB_MODER |= (1U << 12);
    // Set push-pull output
    *GPIOB_OTYPER &= ~(1 << 6);

    // Set timer to 1Hz
    *TIM2_PSC = 399; // 4Mhz / 400 = 10KHz
    *TIM2_ARR = 9999; // 10KHz / 10000 = 1Hz
    // Enable TIM2 update interrupt
    *TIM2_DIER |= 1;
    // Enable NVIC TIM2 global interrupt
    *NVIC_ISER0 |= 1 << 28;
    // Enable TIM2 counter
    *TIM2_CR1 |= 1;
}

void TIM2_IRQHandler(void)
{
    if (*TIM2_SR & 1) {
        *TIM2_SR &= ~1; // Clear update interrupt flag

        // Toggle PB6 based on ODR
        uint32_t is_set = (*GPIOB_ODR & (1 << 6)) >> 6;
        *GPIOB_BSRR = 1 << set_or_reset[is_set];
    }
}

void _start(void)
{
    while (1) {}

    // Link back to looping default handler
    return;
}
