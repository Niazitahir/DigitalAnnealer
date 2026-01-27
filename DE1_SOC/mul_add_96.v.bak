module mul_add_96 (
    input  wire [95:0] data_in,
    output wire [33:0] z
);

    // Unpack 16-bit values
    wire [15:0] x1 = data_in[95:80];
    wire [15:0] x2 = data_in[79:64];
    wire [15:0] x3 = data_in[63:48];
    wire [15:0] x4 = data_in[47:32];
    wire [15:0] x5 = data_in[31:16];
    wire [15:0] x6 = data_in[15:0];   // unused but extracted for completeness
	 
	 always @(posedge clk) begin
		wire [31:0] y1_r <= x1 * x2;
		wire [31:0] y2_r <= x3 * x4;
		wire [31:0] y3_r <= x4 * x5;
    end


    // Final sum (34 bits)
    assign z = y1 + y2 + y3;

endmodule
