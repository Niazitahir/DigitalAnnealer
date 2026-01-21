module hex_decoder (
    input  [3:0] bin_digit, // The 4-bit number (0-15)
    output reg [6:0] hex_segments // The 7 segments for the display
);

    always @(*) begin
        case (bin_digit)
            4'h0: hex_segments = 7'h40;
            4'h1: hex_segments = 7'h79;
            4'h2: hex_segments = 7'h24;
            4'h3: hex_segments = 7'h30;
            4'h4: hex_segments = 7'h19;
            4'h5: hex_segments = 7'h12;
            4'h6: hex_segments = 7'h02;
            4'h7: hex_segments = 7'h78;
            4'h8: hex_segments = 7'h00;
            4'h9: hex_segments = 7'h10;
            4'hA: hex_segments = 7'h08;
            4'hB: hex_segments = 7'h03;
            4'hC: hex_segments = 7'h46;
            4'hD: hex_segments = 7'h21;
            4'hE: hex_segments = 7'h06;
            4'hF: hex_segments = 7'h0E;
            default: hex_segments = 7'h7F; // All segments OFF
        endcase
    end
endmodule