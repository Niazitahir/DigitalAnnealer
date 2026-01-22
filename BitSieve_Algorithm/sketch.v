// ========================================================
//  Top-Level Engine Skeleton
// ========================================================
module ising_engine #(
    parameter integer N           = 256,   // or 512
    parameter integer PAR         = 16,    // spins processed per cycle
    parameter integer W_WIDTH     = 16,
    parameter integer H_WIDTH     = 27,
    parameter integer BETA_WIDTH  = 16,
    parameter integer RNG_WIDTH   = 16
)(
    input  wire                     clk,
    input  wire                     rst_n,

    // Control from host
    input  wire                     start,
    input  wire [31:0]              steps,       // num MCMC iterations
    input  wire [BETA_WIDTH-1:0]    beta,
    output reg                      done,

    // (Optional) load interface for problem data (weights, fields)
    // You will likely replace this with AXI/Avalon or preload from MIF.
    input  wire                     load_en,
    input  wire [1:0]               load_sel,   // 0:W, 1:h_init, 2:x_init
    input  wire [$clog2(N)-1:0]     load_i,
    input  wire [$clog2(N)-1:0]     load_j,
    input  wire [W_WIDTH-1:0]       load_w_data,
    input  wire [H_WIDTH-1:0]       load_h_data,
    input  wire                     load_x_bit,

    // Output best solution found
    output reg  [N-1:0]             best_x
);

    // ------------------------------
    // Internal state
    // ------------------------------
    localparam integer IDX_W = $clog2(N);

    // Spin state x[i]
    reg [N-1:0] x;

    // Local fields h[i]
    reg signed [H_WIDTH-1:0] h [0:N-1];

    // Weight matrix W[i][j] (conceptual 2D; you’ll map to BRAMs)
    reg signed [W_WIDTH-1:0] W [0:N-1][0:N-1];

    // Current iteration counter
    reg [31:0] iter_cnt;

    // FSM States
    typedef enum logic [2:0] {
        S_IDLE       = 3'd0,
        S_INIT       = 3'd1,
        S_ITER_DELTA = 3'd2,
        S_ITER_SELECT= 3'd3,
        S_ITER_FUPD  = 3'd4,
        S_DONE       = 3'd5
    } state_t;
    state_t state, next_state;

    // For sweeping spins in batches of PAR
    reg [IDX_W-1:0] sweep_base_idx; // points to first spin in current batch

    // Accumulated accept_mask across all batches
    reg [N-1:0] accept_mask_accum;

    // Selected index to flip
    reg [IDX_W-1:0] flip_idx;
    reg             flip_valid;

    // Track old x_j for field update sign
    reg             flip_old_xj;

    // Handshake signals with submodules
    wire [PAR-1:0]                     accept_mask_batch;
    wire [PAR-1:0]                     valid_batch;
    wire                               delta_batch_done;

    wire                               field_update_done;

    // RNG stubs (you’ll replace with real LFSRs / RNG bank)
    wire [RNG_WIDTH-1:0] rng_batch   [0:PAR-1];
    wire [RNG_WIDTH-1:0] rng_block;
    wire [RNG_WIDTH-1:0] rng_local;

    genvar gi;
    generate
        for (gi = 0; gi < PAR; gi = gi + 1) begin : RNG_GEN
            // super dumb LFSR stub; replace with real RNG
            lfsr_16 rng_inst (
                .clk (clk),
                .rst_n (rst_n),
                .rnd (rng_batch[gi])
            );
        end
    endgenerate

    lfsr_16 rng_block_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .rnd   (rng_block)
    );

    lfsr_16 rng_local_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .rnd   (rng_local)
    );

    // ====================================================
    //  Load interface for W, h, x (simplified)
    // ====================================================
    integer i, j;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // init memories to 0 in simulation (synth tools may remove this)
            for (i = 0; i < N; i = i + 1) begin
                x[i] <= 1'b0;
                h[i] <= '0;
                for (j = 0; j < N; j = j + 1) begin
                    W[i][j] <= '0;
                end
            end
        end else if (load_en) begin
            case (load_sel)
                2'd0: W[load_i][load_j] <= load_w_data;
                2'd1: h[load_i]         <= load_h_data;
                2'd2: x[load_i]         <= load_x_bit;
                default: ;
            endcase
        end
    end

    // ====================================================
    //  FSM: next_state logic
    // ====================================================
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (start)
                    next_state = S_INIT;
            end

            S_INIT: begin
                next_state = S_ITER_DELTA;
            end

            S_ITER_DELTA: begin
                // when we’ve swept all N spins in batches
                if (sweep_base_idx >= N[IDX_W-1:0])
                    next_state = S_ITER_SELECT;
            end

            S_ITER_SELECT: begin
                next_state = flip_valid ? S_ITER_FUPD : S_ITER_DELTA;
            end

            S_ITER_FUPD: begin
                if (field_update_done) begin
                    if (iter_cnt + 1 >= steps)
                        next_state = S_DONE;
                    else
                        next_state = S_ITER_DELTA;
                end
            end

            S_DONE: begin
                // wait for host to deassert start or reset us
                if (!start)
                    next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // ====================================================
    //  FSM: state + control registers
    // ====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state           <= S_IDLE;
            iter_cnt        <= 32'd0;
            sweep_base_idx  <= {IDX_W{1'b0}};
            done            <= 1'b0;
            accept_mask_accum <= {N{1'b0}};
        end else begin
            state <= next_state;

            case (state)
                S_IDLE: begin
                    done            <= 1'b0;
                    iter_cnt        <= 32'd0;
                    sweep_base_idx  <= {IDX_W{1'b0}};
                    accept_mask_accum <= {N{1'b0}};
                    if (start) begin
                        // optionally randomize x / initialize best_x here
                        best_x <= x;
                    end
                end

                S_INIT: begin
                    sweep_base_idx     <= {IDX_W{1'b0}};
                    accept_mask_accum  <= {N{1'b0}};
                end

                S_ITER_DELTA: begin
                    // As we process each batch (PAR) spins, we OR their accept
                    // mask into the global one.
                    if (delta_batch_done) begin
                        // Expand batch accept mask into global bit positions
                        integer k;
                        for (k = 0; k < PAR; k = k + 1) begin
                            if (sweep_base_idx + k < N) begin
                                accept_mask_accum[sweep_base_idx + k] 
                                    <= accept_mask_accum[sweep_base_idx + k] 
                                       | accept_mask_batch[k];
                            end
                        end

                        // Move to next batch
                        sweep_base_idx <= sweep_base_idx + PAR[IDX_W-1:0];
                    end
                end

                S_ITER_SELECT: begin
                    sweep_base_idx <= {IDX_W{1'b0}}; // reset for next iter
                    // nothing else; combinational bit_sieve decides flip_idx/valid
                end

                S_ITER_FUPD: begin
                    if (field_update_done) begin
                        iter_cnt <= iter_cnt + 1;
                        accept_mask_accum <= {N{1'b0}}; // reset for next iteration
                    end
                end

                S_DONE: begin
                    done <= 1'b1;
                end

                default: ;
            endcase
        end
    end

    // ====================================================
    //  Hook up ΔE + accept unit for batched spins
    // ====================================================
    wire [IDX_W-1:0] batch_indices [0:PAR-1];
    generate
        for (gi = 0; gi < PAR; gi = gi + 1) begin : IDX_GEN
            assign batch_indices[gi] = sweep_base_idx + gi[IDX_W-1:0];
        end
    endgenerate

    deltaE_accept_batch #(
        .N         (N),
        .PAR       (PAR),
        .H_WIDTH   (H_WIDTH),
        .BETA_WIDTH(BETA_WIDTH),
        .RNG_WIDTH (RNG_WIDTH)
    ) deltaE_unit (
        .clk           (clk),
        .rst_n         (rst_n),
        .enable        (state == S_ITER_DELTA),
        .beta          (beta),
        .x             (x),
        .h             (h),
        .indices       (batch_indices),
        .rng           (rng_batch),
        .accept_mask   (accept_mask_batch),
        .valid_mask    (valid_batch),
        .batch_done    (delta_batch_done)
    );

    // ====================================================
    //  Bit Sieve Selector (global accept_mask_accum -> flip_idx)
    // ====================================================
    bit_sieve_selector #(
        .N          (N),
        .BLOCK_SIZE (32)
    ) sieve (
        .accept_mask (accept_mask_accum),
        .rng_block   (rng_block),
        .rng_local   (rng_local),
        .selected_idx(flip_idx),
        .has_selection(flip_valid)
    );

    // ====================================================
    //  Spin flip + field update unit
    // ====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            flip_old_xj <= 1'b0;
        end else if (state == S_ITER_SELECT && flip_valid) begin
            flip_old_xj      <= x[flip_idx];
            x[flip_idx]      <= ~x[flip_idx];
            // (optional) track best_x here by computing/estimating energy
        end
    end

    field_update_unit #(
        .N        (N),
        .W_WIDTH  (W_WIDTH),
        .H_WIDTH  (H_WIDTH)
    ) fupd (
        .clk            (clk),
        .rst_n          (rst_n),
        .start_update   (state == S_ITER_SELECT && flip_valid),
        .flip_index_j   (flip_idx),
        .flip_old_xj    (flip_old_xj),
        .W              (W),
        .h              (h),
        .update_done    (field_update_done)
    );

endmodule


// ========================================================
//  ΔE + Acceptance (Batch) Skeleton
// ========================================================

module deltaE_accept_batch #(
    parameter integer N          = 256,
    parameter integer PAR        = 16,
    parameter integer H_WIDTH    = 27,
    parameter integer BETA_WIDTH = 16,
    parameter integer RNG_WIDTH  = 16
)(
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       enable,
    input  wire [BETA_WIDTH-1:0]      beta,
    input  wire [N-1:0]               x,
    input  wire signed [H_WIDTH-1:0]  h [0:N-1],

    input  wire [$clog2(N)-1:0]       indices [0:PAR-1],
    input  wire [RNG_WIDTH-1:0]       rng     [0:PAR-1],

    output reg  [PAR-1:0]             accept_mask,
    output reg  [PAR-1:0]             valid_mask,
    output reg                        batch_done
);
    integer k;
    reg working;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accept_mask <= '0;
            valid_mask  <= '0;
            batch_done  <= 1'b0;
            working     <= 1'b0;
        end else begin
            batch_done <= 1'b0;

            if (enable && !working) begin
                working <= 1'b1;
                // In a real design you probably pipeline this.
                for (k = 0; k < PAR; k = k + 1) begin
                    if (indices[k] < N) begin
                        valid_mask[k] <= 1'b1;

                        // compute ΔE_i = (x_i ? +h_i : -h_i)
                        // sign depends on your chosen convention; adjust if needed
                        reg xi;
                        reg signed [H_WIDTH-1:0] hi, deltaE;
                        xi     = x[ indices[k] ];
                        hi     = h[ indices[k] ];
                        deltaE = xi ? hi : -hi;

                        // *** TODO: implement Metropolis / Gibbs properly ***
                        // For now, simple heuristic:
                        // accept if ΔE <= 0 or rng below some threshold
                        if (deltaE <= 0)
                            accept_mask[k] <= 1'b1;
                        else
                            accept_mask[k] <= 1'b0; // stub; ignore rng, beta
                    end else begin
                        valid_mask[k]  <= 1'b0;
                        accept_mask[k] <= 1'b0;
                    end
                end

                batch_done <= 1'b1;
                working    <= 1'b0;
            end
        end
    end
endmodule

// ========================================================
//  Bit-Sieve Selector Skeleton (Block-Based)
// ========================================================

module bit_sieve_selector #(
    parameter integer N          = 256,
    parameter integer BLOCK_SIZE = 32
)(
    input  wire [N-1:0]           accept_mask,
    input  wire [15:0]            rng_block,   // unused in this stub
    input  wire [15:0]            rng_local,   // unused in this stub
    output reg  [$clog2(N)-1:0]   selected_idx,
    output reg                    has_selection
);
    integer i;
    always @(*) begin
        has_selection = 1'b0;
        selected_idx  = {($clog2(N)){1'b0}};
        for (i = 0; i < N; i = i + 1) begin
            if (!has_selection && accept_mask[i]) begin
                has_selection = 1'b1;
                selected_idx  = i[$clog2(N)-1:0];
            end
        end
    end
endmodule

// ========================================================
//  Field Update Unit (DeGloria)
// ========================================================

module field_update_unit #(
    parameter integer N        = 256,
    parameter integer W_WIDTH  = 16,
    parameter integer H_WIDTH  = 27
)(
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire                      start_update,
    input  wire [$clog2(N)-1:0]      flip_index_j,
    input  wire                      flip_old_xj,  // old x_j BEFORE flip

    // weight + field memories (passed by reference, not synthesizable as-is)
    // In a real design you’d connect BRAM ports here.
    input  wire signed [W_WIDTH-1:0] W    [0:N-1][0:N-1],
    output reg signed [H_WIDTH-1:0] h    [0:N-1],

    output reg                       update_done
);
    localparam integer IDX_W = $clog2(N);
    reg [IDX_W-1:0] i_idx;
    reg working;

    wire signed [1:0] sj = flip_old_xj ? -2'sd1 : 2'sd1; // sign based on old x_j

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i_idx       <= {IDX_W{1'b0}};
            working     <= 1'b0;
            update_done <= 1'b0;
        end else begin
            update_done <= 1'b0;

            if (start_update && !working) begin
                working <= 1'b1;
                i_idx   <= {IDX_W{1'b0}};
            end else if (working) begin
                // one i per cycle; can unroll / parallelize if desired
                if (i_idx < N[IDX_W-1:0]) begin
                    // h[i] += W[i][j] * sj
                    h[i_idx] <= h[i_idx] + W[i_idx][flip_index_j] * sj;
                    i_idx    <= i_idx + 1'b1;
                end else begin
                    working     <= 1'b0;
                    update_done <= 1'b1;
                end
            end
        end
    end
endmodule

// ========================================================
//  Tiny 16-bit LFSR Stub (for RNG)
// ========================================================
module lfsr_16 (
    input  wire        clk,
    input  wire        rst_n,
    output reg [15:0]  rnd
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rnd <= 16'h1ACE;
        end else begin
            // x^16 + x^14 + x^13 + x^11 + 1 primitive polynomial (example)
            rnd <= {rnd[14:0], rnd[15] ^ rnd[13] ^ rnd[12] ^ rnd[10]};
        end
    end
endmodule
