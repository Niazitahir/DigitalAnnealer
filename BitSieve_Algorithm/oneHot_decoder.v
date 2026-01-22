module binary_to_onehot_1024 (
    input wire [9:0] in_index,
    output wire [1023:0] out_onehot
);

    // Shift '1' to the left by the amount specified by 'in_index'.
    // We explicitly cast the '1' to 1024 bits to ensure the shift 
    // happens within the correct width (avoiding 32-bit truncation).
    assign out_onehot = (1024'd1 << in_index);

endmodule