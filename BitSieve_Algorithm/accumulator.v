module accumulator (
    input wire clk,
    input wire rst,      // Reset (Active High)
    input wire en,       // Enable
    input wire [7:0] D,  // Data Input
    output reg [7:0] Q   // Data Output (Accumulator value)
);

    // The sequential logic for the register
    always @(posedge clk) begin
        if (rst) begin
            // On reset, clear the register to 0
            Q <= 8'b0;
        end else if (en) begin
            // If enabled, add input D to current value Q
            // This line infers both the Adder and the Register update
            Q <= Q + D;
        end
        // If !en, the register implicitly holds its current value
    end

endmodule