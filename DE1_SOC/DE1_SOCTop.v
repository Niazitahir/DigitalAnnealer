`define ENABLE_HPS
module DE1_SOCTop(
      
		///////// CLOCK /////////
      input              CLOCK_50,
      ///////// CLOCK2 /////////
      input              CLOCK2_50,

      ///////// CLOCK3 /////////
      input              CLOCK3_50,

      ///////// CLOCK4 /////////
      input              CLOCK4_50,


`ifdef ENABLE_HPS
      ///////// HPS /////////
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,

`endif /*ENABLE_HPS*/

      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,

      ///////// SW /////////
      input       [9:0]  SW,
		
		///////// RAM /////////
		output 		[5:0] fpga_addr,
		output 				fpga_we,
		input 		[7:0] fpga_q,
		output 		[7:0] fpga_data,
		////////  Debug  ////////
		output [9:0] leds,
		output [31:0] hex0,
		output [15:0] hex1
);

	wire [9:0] fpga_leds;
	wire [31:0] fpga_hex0;
	wire [15:0] fpga_hex1;
	assign LEDR = fpga_leds;
	assign {HEX3, HEX2, HEX1, HEX0} = fpga_hex0;
	assign {HEX5, HEX4} = fpga_hex1;
	wire hps_fpga_reset_n; // Declare the wire
    DE1_SOC u0 (
	 	  .clk_clk 										  (CLOCK_50),
        .memory_mem_a                          ( HPS_DDR3_ADDR),                          //          memory.mem_a
        .memory_mem_ba                         ( HPS_DDR3_BA),                         //                .mem_ba
        .memory_mem_ck                         ( HPS_DDR3_CK_P),                         //                .mem_ck
        .memory_mem_ck_n                       ( HPS_DDR3_CK_N),                       //                .mem_ck_n
        .memory_mem_cke                        ( HPS_DDR3_CKE),                        //                .mem_cke
        .memory_mem_cs_n                       ( HPS_DDR3_CS_N),                       //                .mem_cs_n
        .memory_mem_ras_n                      ( HPS_DDR3_RAS_N),                      //                .mem_ras_n
        .memory_mem_cas_n                      ( HPS_DDR3_CAS_N),                      //                .mem_cas_n
        .memory_mem_we_n                       ( HPS_DDR3_WE_N),                       //                .mem_we_n
        .memory_mem_reset_n                    ( HPS_DDR3_RESET_N),                    //                .mem_reset_n
        .memory_mem_dq                         ( HPS_DDR3_DQ),                         //                .mem_dq
        .memory_mem_dqs                        ( HPS_DDR3_DQS_P),                        //                .mem_dqs
        .memory_mem_dqs_n                      ( HPS_DDR3_DQS_N),                      //                .mem_dqs_n
        .memory_mem_odt                        ( HPS_DDR3_ODT),                        //                .mem_odt
        .memory_mem_dm                         ( HPS_DDR3_DM),                         //                .mem_dm
        .memory_oct_rzqin                      ( HPS_DDR3_RZQ),                      //                .oct_rzqin
		  .leds_export                     (leds),                     //                 leds.export
        .hex30_export                    (hex0),                    //                hex30.export
        .hex54_export                    (hex1),
		  .keys_export(KEY)
		
	 );
	single_port_ram u1(
		.clk												  (CLOCK_50),
		.data												  (fpga_data),
		.addr												  (fpga_addr),
		.we												  (fpga_we), 
		.q													  (fpga_q),
		.leds												  (fpga_leds),
		.hex0												  (fpga_hex0),
		.hex1												  (fpga_hex1)
	);


endmodule

  