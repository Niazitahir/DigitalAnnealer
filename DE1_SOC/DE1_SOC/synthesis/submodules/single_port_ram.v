
//This works similar to ram, communicating with the CPU to exchange information. However: 

//Function 1: Import information
//Function 1.5: Pipe imported information into DSP
//Function 2: DSP multiplies 2 shorts together
//Function 3: Save information and send back when requested. 

//Format: h2f bridge is 128 bits. This will fit 128 / 16 bits (len of short) = 8 shorts. Each transmission will therefore send 8 numbers
//this allows for 4 dsps to work in parallel. 

//Note: Considering splitting data 3/4 into DDR on HPS and 1/4 on SDRAM. This will allow for more parallelism with the caveat of 
//slower initialization in the beginning (moving data into SDRAM from the processor)

module single_port_ram 
#(parameter DATA_WIDTH=64, parameter ADDR_WIDTH=1)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] addr,
	input we, clk, reset_n,
	output [(DATA_WIDTH-1):0] q,
	output reg [9:0] leds,
	output [31:0] hex0,
	output [15:0] hex1
);
	reg [9:0] led_arr;
	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Variable to hold the registered read address
	reg [ADDR_WIDTH-1:0] addr_reg;

	always @ (posedge clk or negedge reset_n)
	begin
		
		if (!reset_n) begin
			addr_reg <= {ADDR_WIDTH{1'b0}};
			leds <= {10'b1111111111};
		end
		// Write
		else begin
		   //led_arr <= {10'b1100000000};
			if (we) begin
				leds <= {10'b1100000111};
				ram[addr] <= data;
			addr_reg <= addr;
			end
		end
	end
	assign q = ram[addr_reg];
	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  


endmodule
