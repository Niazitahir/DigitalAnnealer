#include <stdint.h>
#include <stdio.h>


/* * PHYSICAL ADDRESS MAP
 * 0x0000_0000 to 0x3FFF_FFFF: HPS DDR3 SDRAM (Up to 1GB)
 * 0xFFFF_0000 to 0xFFFF_FFFF: On-Chip RAM (64KB)
 */
#define HEAVY_BRIDGE_BASE 0xC0000000
#define RAM_BASE 0xF0000000    
#define FPGA_RAM_BASE 0x30000000    
#define LIGHT_BRIDGE_BASE 0xFF200000
#define SDRAM_BASE          0x01000000  // 16MB offset (safe zone)
#define TEST_VALUE          0xBCE12345
#define SEQUENCER_RAM_BASE 0x20000
#define RSTMGR_BRGMODRST 0xFFD05010
#define TEST_2 0xBCE99999
#define DMA_0_BASE 0xFF200000





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
    // Pointer to the Reset Manager Bridge Mode Reset Register
    volatile int * rst_mgr_ptr = (volatile int *) RSTMGR_BRGMODRST;

    // Clear bits 0, 1, and 2 to release all bridges from reset
    // This allows reset_n to go HIGH (1) in your Verilog
    *rst_mgr_ptr = 0;
    // Create a volatile pointer to ensure the compiler doesn't optimize out the access
    volatile uint32_t *sdram_ptr = (volatile uint32_t *)SDRAM_BASE;
    printf("DDR3 Test: \n");
    // 1. Write to memory
    printf("Writing to physical address 0x%08X...\n", (uint32_t)sdram_ptr);
    *sdram_ptr = TEST_VALUE;
    sdram_ptr[1] = TEST_2;

    // 2. Read back from memory
    uint32_t read_back = *sdram_ptr;

    // 3. Verify
    if (read_back == TEST_VALUE) {
        printf("Success! Read value: 0x%08X\n", read_back);
    } else {
        printf("Failure! Expected 0x%08X but read 0x%08X\n", TEST_VALUE, read_back);
    }

    read_back = sdram_ptr[1];
    if (read_back == TEST_2) {
        printf("Success! Read value: 0x%08X\n", read_back);
    } else {
        printf("Failure! Expected 0x%08X but read 0x%08X\n", TEST_VALUE, read_back);
    }


    int tester[1] = {10};
    printf("DMA Test: \n");
    //DMA TEST
    volatile uint32_t *dma = (uint32_t *) DMA_0_BASE;
    // 1. Clear any stale status bits
    dma[0] = 0x0;

    // 2. Set source address (HPS DDR)
    dma[2] = SDRAM_BASE;   // offset 0x08

    // 3. Set destination address (FPGA on-chip RAM)
    dma[3] = FPGA_RAM_BASE;   // offset 0x0C

    // 4. Set transfer length in bytes
    dma[4] = 4;     // offset 0x10

    // 5. Start the DMA
    dma[1] = 0x1;        // offset 0x04, bit0 = GO
    while (dma[0] == 0x1) {
        printf("Checking\n");
        // bit0 = busy
    }
    
    volatile uint32_t *fpga_ptr2 = (volatile uint32_t *)RAM_BASE;
    printf("Reading from FPGA address 0x%08X...\n", (uint32_t)fpga_ptr2);
    
    // 2. read back from memory
    volatile uint32_t *read_backs = (volatile uint32_t *)RAM_BASE;

    uint32_t val = *read_backs;
    if (val == TEST_VALUE) {
        printf("Success! Read value: 0x%08X\n", val);
    } else {
        printf("Failure! Expected 0x%08X but read 0x%08X\n", TEST_VALUE, val);
    }
    // volatile uint32_t *fpga_ptr = (volatile uint32_t *)HEAVY_BRIDGE_BASE;
    // printf("Writing to FPGA address 0x%08X...\n", (uint32_t)fpga_ptr);
    // *fpga_ptr = TEST_VALUE;

    // // 2. Read back from memory
    // volatile uint32_t *read_backs = (volatile uint32_t *)HEAVY_BRIDGE_BASE;


    // // 3. Verify
    // if (*read_backs == TEST_VALUE) {
    //     printf("Success! Read value: 0x%08X\n", *read_backs);
    // } else {
    //     printf("Failure! Expected 0x%08X but read 0x%08X\n", TEST_VALUE, *read_backs);
    // }
    
    //64bit test
    // volatile uint32_t *fpga_ptr2 = (volatile uint32_t *)HEAVY_BRIDGE_BASE;
    // printf("Writing to FPGA address 0x%08X...\n", (uint32_t)fpga_ptr2);
    // fpga_ptr2[0] = TEST_VALUE;
    // fpga_ptr2[1] = TEST_2;
    // fpga_ptr2[2] = TEST_2;
    // fpga_ptr2[3] = TEST_VALUE;

    // // 2. Read back from memory
    // volatile uint32_t *read_backs2 = (volatile uint32_t *)HEAVY_BRIDGE_BASE;

    // printf("0x%08x%08x%08x%08x\n", read_backs2[0], read_backs2[1], read_backs2[2], read_backs2[3]);
    // // 3. Verify
    // if (*read_backs2 == TEST_VALUE) {
    //     printf("Success! Read value: 0x%08X, 0x%08X, 0x%08X\n", *read_backs2);
    // } else {
    //     printf("Failure! Expected 0x%016X but read 0x%016X\n", TEST_2, *read_backs2);
    // }
}