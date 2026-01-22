module conditional_inverter #(parameter WIDTH = 8) (
    input wire signed [WIDTH-1:0] Din,
    input wire Sel,
    output wire signed [WIDTH-1:0] Dout
);

    // If Sel is 1, pass Din. 
    // If Sel is 0, pass -Din (Two's Complement Negation).
    assign Dout = (Sel) ? Din : -Din;

endmodule