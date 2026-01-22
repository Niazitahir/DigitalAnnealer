module selector_2to1 (
    input wire [9:0] indexA,
    input wire [9:0] indexB,
    input wire vA,
    input wire vB,
    output wire [9:0] indexO,
    output wire vO
);

    // Output Valid Logic:
    // vO is high if at least one input is valid.
    assign vO = vA | vB;

    // Output Data Logic (Priority Mux):
    // Priority 1: If vA is valid, pick indexA (regardless of vB).
    // Priority 2: If vA is invalid but vB is valid, pick indexB.
    // Default:    If neither is valid, output 0.
    assign indexO = (vA) ? indexA : 
                    (vB) ? indexB : 10'd0;

endmodule