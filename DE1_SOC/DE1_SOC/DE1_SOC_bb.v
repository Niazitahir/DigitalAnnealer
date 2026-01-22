
module DE1_SOC (
	clk_clk,
	hex30_export,
	hex54_export,
	hps_0_h2f_mpu_events_eventi,
	hps_0_h2f_mpu_events_evento,
	hps_0_h2f_mpu_events_standbywfe,
	hps_0_h2f_mpu_events_standbywfi,
	keys_export,
	leds_export,
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin,
	reset_reset_n,
	sys_sdram_pll_0_ref_reset_reset);	

	input		clk_clk;
	output	[31:0]	hex30_export;
	output	[15:0]	hex54_export;
	input		hps_0_h2f_mpu_events_eventi;
	output		hps_0_h2f_mpu_events_evento;
	output	[1:0]	hps_0_h2f_mpu_events_standbywfe;
	output	[1:0]	hps_0_h2f_mpu_events_standbywfi;
	input	[3:0]	keys_export;
	output	[9:0]	leds_export;
	output	[12:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[7:0]	memory_mem_dq;
	inout		memory_mem_dqs;
	inout		memory_mem_dqs_n;
	output		memory_mem_odt;
	output		memory_mem_dm;
	input		memory_oct_rzqin;
	input		reset_reset_n;
	input		sys_sdram_pll_0_ref_reset_reset;
endmodule
