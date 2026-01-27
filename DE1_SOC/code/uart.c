#include <stdint.h>

// ===== FPGA RS232 (LW bridge) =====
#define FPGA_UART_BASE     0xFF205000
#define FPGA_UART_TX_FIFO  (*(volatile uint32_t *)(FPGA_UART_BASE + 0x0))  // TX FIFO (FPGA → HPS)
#define FPGA_UART_RX_FIFO  (*(volatile uint32_t *)(FPGA_UART_BASE + 0x4))  // RX FIFO (HPS → FPGA)
#define FPGA_UART_STATUS   (*(volatile uint32_t *)(FPGA_UART_BASE + 0x8))

#define FPGA_RX_EMPTY  (1 << 0)
#define FPGA_RX_FULL   (1 << 1)
#define FPGA_TX_EMPTY  (1 << 2)
#define FPGA_TX_FULL   (1 << 3)

// ===== HPS UART0 (COM4) =====
#define HPS_UART0_BASE   0xFFFEC000
#define HPS_UART0_DR     (*(volatile uint32_t *)(HPS_UART0_BASE + 0x00))
#define HPS_UART0_FR     (*(volatile uint32_t *)(HPS_UART0_BASE + 0x18))

#define UART0_TX_FULL    (1 << 5)
#define UART0_RX_EMPTY   (1 << 4)

// ===== Helper functions =====

// Send one byte from HPS to FPGA RX FIFO
void send_byte_to_fpga(uint8_t byte)
{
    while (FPGA_UART_STATUS & FPGA_RX_FULL) {} // wait until RX FIFO not full
    FPGA_UART_RX_FIFO = byte;
}

// Send one byte from FPGA TX FIFO to HPS UART0
void send_byte_to_hps(uint8_t byte)
{
    while (HPS_UART0_FR & UART0_TX_FULL) {} // wait until HPS UART TX FIFO has room
    HPS_UART0_DR = byte;
}

// Check if FPGA has data to send
int fpga_has_data(void)
{
    return !(FPGA_UART_STATUS & FPGA_TX_EMPTY);
}

// Read one byte from FPGA TX FIFO
uint8_t read_byte_from_fpga(void)
{
    return (uint8_t)FPGA_UART_TX_FIFO;
}

// Check if HPS UART has data to send to FPGA
int hps_uart_has_data(void)
{
    return !(HPS_UART0_FR & UART0_RX_EMPTY);
}

// Read one byte from HPS UART0
uint8_t read_byte_from_hps(void)
{
    return (uint8_t)HPS_UART0_DR;
}

// ===== Main bridge loop =====
int main(void)
{
    while (1)
    {
        // ===== FPGA → HPS (to COM4) =====
        if (fpga_has_data())
        {
            uint8_t byte = read_byte_from_fpga();
            send_byte_to_hps(byte);
        }

        // ===== HPS → FPGA (from COM4) =====
        if (hps_uart_has_data())
        {
            uint8_t byte = read_byte_from_hps();
            send_byte_to_fpga(byte);
        }
    }

    return 0; // never reached
}