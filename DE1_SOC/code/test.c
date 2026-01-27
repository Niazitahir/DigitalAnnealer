#include <stdint.h>

#define UART0_BASE  0xFFC02000

#define UART_DR     (*(volatile uint32_t *)(UART0_BASE + 0x00))
#define UART_FR     (*(volatile uint32_t *)(UART0_BASE + 0x18))
#define UART_IBRD   (*(volatile uint32_t *)(UART0_BASE + 0x24))
#define UART_FBRD   (*(volatile uint32_t *)(UART0_BASE + 0x28))
#define UART_LCRH   (*(volatile uint32_t *)(UART0_BASE + 0x2C))
#define UART_CR     (*(volatile uint32_t *)(UART0_BASE + 0x30))
#define UART_IMSC   (*(volatile uint32_t *)(UART0_BASE + 0x38))

#define CLK_MGR_BASE      0xFFD04000
#define CLK_MGR_PER_EN    (*(volatile uint32_t *)(CLK_MGR_BASE + 0xA4))

void enable_uart0_clock(void)
{
    CLK_MGR_PER_EN |= (1 << 16);  // UART0 clock enable
}

void uart_init(void)
{
    enable_uart0_clock();

    UART_CR = 0x0;   // Disable UART

    /*
     * Baud rate calculation:
     * BaudDiv = UARTCLK / (16 * Baud)
     * UARTCLK ≈ 100 MHz
     *
     * IBRD = 54
     * FBRD = 16
     */

    UART_IBRD = 54;
    UART_FBRD = 16;

    // 8-bit, no parity, 1 stop bit, FIFO enabled
    UART_LCRH = (3 << 5) | (1 << 4);

    // Mask all interrupts
    UART_IMSC = 0x0;

    // Enable UART, TX, RX
    UART_CR = (1 << 9) | (1 << 8) | (1 << 0);
}

void uart_putc(char c)
{
    while (UART_FR & (1 << 5));  // TX FIFO full
    UART_DR = c;
}

char uart_getc(void)
{
    while (UART_FR & (1 << 4));  // RX FIFO empty
    return (char)(UART_DR & 0xFF);
}

int main(void)
{
    uart_init();

    const char *msg = "Hello from bare-metal HPS UART!\r\n";
    while (*msg)
        uart_putc(*msg++);

    // Echo loop
    while (1)
    {
        char c = uart_getc();
        uart_putc(c);
    }
}