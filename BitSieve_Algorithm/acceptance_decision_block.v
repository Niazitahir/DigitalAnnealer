module acceptance_decision_block #(
    parameter DATA_WIDTH = 27,   // Width of Energy values and LUT data
    parameter ADDR_WIDTH = 16    // Width of LFSR / LUT Address
)(
    input wire clk,
    // We use 'signed' inputs to ensure Verilog handles the negative math correctly
    input wire signed [DATA_WIDTH-1:0] deltaE,
    input wire signed [DATA_WIDTH-1:0] E_off,
    output wire decision
);

    // --- Internal Signals ---
    wire [ADDR_WIDTH-1:0] rand_addr;
    wire signed [DATA_WIDTH-1:0] lut_val;
    
    // We need an extra bit for the intermediate sum to prevent overflow 
    // before the final comparison (e.g., adding two large positive numbers).
    wire signed [DATA_WIDTH:0] calculation_result;

    // --- 1. Instantiate the Random Number Generator (LFSR) ---
    // This generates the address 'r' for the table.
    lfsr_16bit rng_inst (
        .clk(clk),
        .data_out(rand_addr)
    );

    // --- 2. Instantiate the Look-Up Table (LUT) ---
    // Retrieves 'x' based on the random address 'r'.
    lookup_table #(
        .N(ADDR_WIDTH), 
        .DATA_WIDTH(DATA_WIDTH)
    ) lut_inst (
        .addr(rand_addr),
        .data_out(lut_val)
    );

    // --- 3. Arithmetic Logic & Decision ---
    // Equation: (-deltaE) + E_off + x
    // Note: We extend inputs to DATA_WIDTH + 1 to handle potential carry/overflow safely.
    assign calculation_result = E_off - deltaE + lut_val;

    // Check if result >= 0.
    // In 2's complement, if the MSB (Sign Bit) is 0, the number is positive or zero.
    // If the MSB is 1, the number is negative.
    assign decision = ~calculation_result[DATA_WIDTH]; 

endmodule