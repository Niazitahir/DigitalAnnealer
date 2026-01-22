module lfsr_16bit (
    input wire clk,
    // The output is the 16-bit 'random' number
    output wire [15:0] data_out
);

    // 1. Internal Register
    // I initialized this to 0xFFFF (all 1s) to ensure the taps catch a non-zero value.
    // If initialized to 16'd1 (only bit 0 is 1), and taps exclude bit 0, 
    // the '1' would shift out instantly, killing the LFSR.
    reg [15:0] lfsr_reg = 16'hFFFF;

    // 2. Feedback Logic (The "XOR" Tree)
    // Taps at bits 1, 2, 4, and 15 (using 0-based indexing [15:0])
    wire feedback;
    assign feedback = lfsr_reg[1] ^ lfsr_reg[2] ^ lfsr_reg[4] ^ lfsr_reg[15];

    // 3. Sequential Logic
    always @(posedge clk) begin
        // Right shift: bits [15:1] move to [14:0]
        // The Feedback result is shifted into the MSB (Bit 15)
        lfsr_reg <= {feedback, lfsr_reg[15:1]};
    end

    // 4. Output Assignment
    assign data_out = lfsr_reg;

endmodule