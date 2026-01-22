module engine_control_fsm (
    input wire clk,
    input wire rst,
    input wire start,            // Master enable signal to start the engine
    
    // Feedback from Datapath
    input wire winner_found,     // From Tournament Tree (final_valid bit)
    
    // Control Outputs
    output reg rng_en,           // Advance LFSRs to generate new noise
    output reg latch_winner,     // Capture the 'winner' index into a stable register
    output reg state_update_en,  // Enable XOR Register to flip the bit
    output reg h_update_en,      // Enable Accumulators to update local fields
    output reg e_off_update_en,  // Enable Energy Offset update (Inc or Reset)
    output reg busy              // FSM is running
);

    // State Encoding (One-Hot or Binary)
    localparam S_IDLE        = 3'd0;
    localparam S_RNG_GEN     = 3'd1; // Cycle 1: Generate Randomness
    localparam S_SIEVE_WAIT  = 3'd2; // Cycle 2: Wait for ADB + Tree propagation
    localparam S_SIEVE_WAIT2 = 3'd3; // Cycle 3: Extra propagation cycle (if needed for 10 layers)
    localparam S_DECIDE      = 3'd4; // Cycle 4: Latch the result
    localparam S_UPDATE      = 3'd5; // Cycle 5: Write to Registers

    reg [2:0] current_state, next_state;

    // --- Sequential Logic ---
    always @(posedge clk) begin
        if (rst) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // --- Next State Logic ---
    always @(*) begin
        next_state = current_state; // Default stay
        
        case (current_state)
            S_IDLE: begin
                if (start) next_state = S_RNG_GEN;
            end
            
            // The 5-Cycle Trial Loop
            S_RNG_GEN:     next_state = S_SIEVE_WAIT;
            S_SIEVE_WAIT:  next_state = S_SIEVE_WAIT2;
            S_SIEVE_WAIT2: next_state = S_DECIDE;
            S_DECIDE:      next_state = S_UPDATE;
            S_UPDATE: begin
                // Loop back to start immediately if still enabled
                if (start) next_state = S_RNG_GEN;
                else       next_state = S_IDLE;
            end
            
            default: next_state = S_IDLE;
        endcase
    end

    // --- Output Logic ---
    always @(*) begin
        // Default outputs
        rng_en          = 1'b0;
        latch_winner    = 1'b0;
        state_update_en = 1'b0;
        h_update_en     = 1'b0;
        e_off_update_en = 1'b0;
        busy            = 1'b0;

        case (current_state)
            S_IDLE: begin
                busy = 1'b0;
            end

            S_RNG_GEN: begin
                busy = 1'b1;
                // Tick the LFSRs to get new 'r' values for this trial
                rng_en = 1'b1; 
            end

            S_SIEVE_WAIT, S_SIEVE_WAIT2: begin
                busy = 1'b1;
                // Just waiting for signals to propagate through the 
                // massive ADB and Tournament Tree logic.
            end

            S_DECIDE: begin
                busy = 1'b1;
                // Capture the output of the tournament tree.
                // We need this stable before we write to memories.
                latch_winner = 1'b1;
            end

            S_UPDATE: begin
                busy = 1'b1;
                
                // Orchestrate the update based on whether a winner was found.
                if (winner_found) begin
                    // 1. Flip the state bit (X_j)
                    state_update_en = 1'b1;
                    
                    // 2. Update local fields (h_i)
                    // (This assumes the datapath has fetched weights W_ij 
                    // based on the latched winner index)
                    h_update_en = 1'b1;
                    
                    // 3. Reset E_off (handled by e_off module when enabled)
                    e_off_update_en = 1'b1; 
                end else begin
                    // No winner found (Local Minimum).
                    // Do NOT update state or h fields.
                    // Increment E_off to lower the barrier for next time.
                    e_off_update_en = 1'b1; 
                end
            end
        endcase
    end

endmodule