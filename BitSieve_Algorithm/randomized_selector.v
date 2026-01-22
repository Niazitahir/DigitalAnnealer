module randomized_selector_2to1 (
    input wire [9:0] indexA,
    input wire [9:0] indexB,
    input wire vA,
    input wire vB,
    input wire rand_bit, // Connect to LFSR[0] or similar
    output wire [9:0] indexO,
    output wire vO
);

    // Output is valid if either A OR B is valid (same as before)
    assign vO = vA | vB;

    // Selection Logic with Randomized Tie-Breaker
    assign indexO = (vA && vB) ? (rand_bit ? indexA : indexB) : // Collision: Flip a coin
                    (vA)       ? indexA :                       // Only A is valid
                    (vB)       ? indexB :                       // Only B is valid
                                 10'd0;                         // Neither is valid

endmodule