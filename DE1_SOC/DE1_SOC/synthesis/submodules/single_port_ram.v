
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
#(parameter DATA_WIDTH=32, parameter DMA_ADDR_WIDTH=24, parameter ADDR_WIDTH=4)
(
	input [(DATA_WIDTH-1):0] data,
	input [(DMA_ADDR_WIDTH-1):0] addr,
	input wire read, 
	input we, clk, reset_n, burstcount,
	input  wire [3:0] byteenable,

	output reg [(DATA_WIDTH-1):0] q,
	output wire waitrequest,
	output reg readdatavalid
);

	wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];
	localparam DEPTH = 1 << ADDR_WIDTH;

	// Variable to hold the registered read address
	reg [DMA_ADDR_WIDTH-1:0] addr_reg;
	
	reg [DATA_WIDTH-1:0] mem [0:15];
	reg valid;
	
	
	assign waitrequest = 1'b0;
	
	always @ (posedge clk or negedge reset_n)
	begin
		if (!reset_n) begin
			addr_reg <= {DMA_ADDR_WIDTH{1'b0}};
		end
		// Write
		else begin
			if (we) begin
				mem[word_addr] <= data;
				valid <= 1'b0;
				addr_reg <= addr;
			end
			readdatavalid <= 1'b1;
			q<=mem[0];
		end

	end
//	always @ (*) begin
//		case (addr)
//			0: q = reg0; // Select input 'a'
//			4: q = reg1; // Select input 'b'
//			8: q = reg2; // Select input 'c'
//			12: q = load; // Select input 'd'
//			default:  q = 1'b1; // Default case
//		endcase
//	end
	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  


endmodule
