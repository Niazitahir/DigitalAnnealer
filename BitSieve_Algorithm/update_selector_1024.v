module tournament_tree_1024 (
    // 1024 Valid bits from the E_i modules
    input wire [1023:0] v_in,
    
    // 1023 Random bits needed for the 1023 selectors in the tree
    // (512 + 256 + ... + 1 = 1023 bits)
    input wire [1022:0] rand_bits,
    
    // The winner's index (0 to 1023) and valid status
    output wire [9:0] final_index,
    output wire final_valid
);

    // --- Internal Wiring for the Tree ---
    // We have 11 "layers" of signals (0 to 10).
    // Layer 0 = Inputs, Layer 10 = Final Output.
    // The width of the array at each layer decreases, but for simplicity
    // in Verilog we can declare a partially unused 2D array or use logic vectors.
    // Here we use a packed array style for modern Verilog support.
    
    // 'tree_idx' stores the 10-bit indices at each stage
    // 'tree_val' stores the valid bits at each stage
    wire [9:0] tree_idx [10:0][1023:0]; 
    wire       tree_val [10:0][1023:0];

    // --- Stage 0: Initialization (The Leaves) ---
    genvar k;
    generate
        for (k = 0; k < 1024; k = k + 1) begin : init_leaves
            // Hardcode the index for each input slot (Identity Mapping)
            assign tree_idx[0][k] = k[9:0];
            // Connect the input valid bits
            assign tree_val[0][k] = v_in[k];
        end
    endgenerate

    // --- Stages 1 to 10: The Selector Tree ---
    genvar stage, i;
    generate
        // Loop through the 10 stages of the tree
        for (stage = 0; stage < 10; stage = stage + 1) begin : build_tree
            
            // Calculate the number of selectors in this stage
            // Stage 0 has 512 selectors, Stage 1 has 256...
            localparam NUM_SELECTORS = 1024 >> (stage + 1);
            
            // Calculate the starting offset in the rand_bits vector for this stage
            // Stage 0 uses bits 0-511. Stage 1 uses 512-767, etc.
            localparam RAND_OFFSET = 1024 - (1024 >> stage);

            for (i = 0; i < NUM_SELECTORS; i = i + 1) begin : row_selectors
                
                // Instantiate the randomized selector
                randomized_selector_2to1 u_mux (
                    // Input A (from current stage, even index)
                    .indexA   (tree_idx[stage][2*i]),
                    .vA       (tree_val[stage][2*i]),
                    
                    // Input B (from current stage, odd index)
                    .indexB   (tree_idx[stage][2*i + 1]),
                    .vB       (tree_val[stage][2*i + 1]),
                    
                    // Random tie-breaker bit
                    .rand_bit (rand_bits[RAND_OFFSET + i]),
                    
                    // Output (feeds into next stage, index i)
                    .indexO   (tree_idx[stage + 1][i]),
                    .vO       (tree_val[stage + 1][i])
                );
            end
        end
    endgenerate

    // --- Final Output ---
    // The result is the single entry remaining at Stage 10, index 0.
    assign final_index = tree_idx[10][0];
    assign final_valid = tree_val[10][0];

endmodule