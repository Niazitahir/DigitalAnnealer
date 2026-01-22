module xor_register_1024 (
    input wire clk,
    input wire rst,          // Active High Reset
    input wire en,           // Enable
    input wire [1023:0] D,   // Input Data mask
    output reg [1023:0] Q    // Stored State
);

    always @(posedge clk) begin
        if (rst) begin
            Q <= 1024'd0;
        end else if (en) begin
            // Q = Q XOR D
            // Zeros in 'D' keep 'Q' unchanged.
            // Ones in 'D' toggle the corresponding bits in 'Q'.
            Q <= Q ^ D;
        end
    end

endmodule