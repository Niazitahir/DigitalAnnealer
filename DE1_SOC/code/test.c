#include <stdint.h>
#include <stdio.h>


/* * PHYSICAL ADDRESS MAP
 * 0x0000_0000 to 0x3FFF_FFFF: HPS DDR3 SDRAM (Up to 1GB)
 * 0xFFFF_0000 to 0xFFFF_FFFF: On-Chip RAM (64KB)
 */

#define SDRAM_BASE          0x01000000  // 16MB offset (safe zone)
#define TEST_VALUE          0xACE12345
#define SEQUENCER_RAM_BASE 0x20000
// Function Prototypes
void sdram_test(void);

int main(void) {
    // Note: In baremetal, your UART must be initialized to see printf output.
    // This is usually handled by the Preloader/Pre-Main startup code.
    
    printf("--- HPS Baremetal SDRAM Test ---\n");
    
    sdram_test();

    while(1); // Infinite loop to prevent processor runaway
    return 0;
}

void sdram_test(void) {
    // Create a volatile pointer to ensure the compiler doesn't optimize out the access
    volatile uint32_t *sdram_ptr = (volatile uint32_t *)SDRAM_BASE;

    // 1. Write to memory
    printf("Writing to physical address 0x%08X...\n", (uint32_t)sdram_ptr);
    *sdram_ptr = TEST_VALUE;

    // 2. Read back from memory
    uint32_t read_back = *sdram_ptr;

    // 3. Verify
    if (read_back == TEST_VALUE) {
        printf("Success! Read value: 0x%08X\n", read_back);
    } else {
        printf("Failure! Expected 0x%08X but read 0x%08X\n", TEST_VALUE, read_back);
    }

    volatile uint32_t *fpga_ptr = (volatile uint32_t *)SEQUENCER_RAM_BASE;
    printf("Writing to FPGA address 0x%08X...\n", (uint32_t)fpga_ptr);
    *fpga_ptr = TEST_VALUE;

    // 2. Read back from memory
    uint32_t read_backs = *fpga_ptr;


    // 3. Verify
    if (read_backs == TEST_VALUE) {
        printf("Success! Read value: 0x%08X\n", read_backs);
    } else {
        printf("Failure! Expected 0x%08X but read 0x%08X\n", TEST_VALUE, read_backs);
    }
}