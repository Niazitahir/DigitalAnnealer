	component DE1_SOC is
		port (
			clk_clk                         : in    std_logic                     := 'X';             -- clk
			hex30_export                    : out   std_logic_vector(31 downto 0);                    -- export
			hex54_export                    : out   std_logic_vector(15 downto 0);                    -- export
			hps_0_h2f_mpu_events_eventi     : in    std_logic                     := 'X';             -- eventi
			hps_0_h2f_mpu_events_evento     : out   std_logic;                                        -- evento
			hps_0_h2f_mpu_events_standbywfe : out   std_logic_vector(1 downto 0);                     -- standbywfe
			hps_0_h2f_mpu_events_standbywfi : out   std_logic_vector(1 downto 0);                     -- standbywfi
			leds_export                     : out   std_logic_vector(9 downto 0);                     -- export
			memory_mem_a                    : out   std_logic_vector(12 downto 0);                    -- mem_a
			memory_mem_ba                   : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                   : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n                 : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke                  : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n                 : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n                : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n                : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n                 : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n              : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                   : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dq
			memory_mem_dqs                  : inout std_logic                     := 'X';             -- mem_dqs
			memory_mem_dqs_n                : inout std_logic                     := 'X';             -- mem_dqs_n
			memory_mem_odt                  : out   std_logic;                                        -- mem_odt
			memory_mem_dm                   : out   std_logic;                                        -- mem_dm
			memory_oct_rzqin                : in    std_logic                     := 'X';             -- oct_rzqin
			keys_export                     : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			sys_sdram_pll_0_ref_reset_reset : in    std_logic                     := 'X';             -- reset
			reset_reset_n                   : in    std_logic                     := 'X'              -- reset_n
		);
	end component DE1_SOC;

	u0 : component DE1_SOC
		port map (
			clk_clk                         => CONNECTED_TO_clk_clk,                         --                       clk.clk
			hex30_export                    => CONNECTED_TO_hex30_export,                    --                     hex30.export
			hex54_export                    => CONNECTED_TO_hex54_export,                    --                     hex54.export
			hps_0_h2f_mpu_events_eventi     => CONNECTED_TO_hps_0_h2f_mpu_events_eventi,     --      hps_0_h2f_mpu_events.eventi
			hps_0_h2f_mpu_events_evento     => CONNECTED_TO_hps_0_h2f_mpu_events_evento,     --                          .evento
			hps_0_h2f_mpu_events_standbywfe => CONNECTED_TO_hps_0_h2f_mpu_events_standbywfe, --                          .standbywfe
			hps_0_h2f_mpu_events_standbywfi => CONNECTED_TO_hps_0_h2f_mpu_events_standbywfi, --                          .standbywfi
			leds_export                     => CONNECTED_TO_leds_export,                     --                      leds.export
			memory_mem_a                    => CONNECTED_TO_memory_mem_a,                    --                    memory.mem_a
			memory_mem_ba                   => CONNECTED_TO_memory_mem_ba,                   --                          .mem_ba
			memory_mem_ck                   => CONNECTED_TO_memory_mem_ck,                   --                          .mem_ck
			memory_mem_ck_n                 => CONNECTED_TO_memory_mem_ck_n,                 --                          .mem_ck_n
			memory_mem_cke                  => CONNECTED_TO_memory_mem_cke,                  --                          .mem_cke
			memory_mem_cs_n                 => CONNECTED_TO_memory_mem_cs_n,                 --                          .mem_cs_n
			memory_mem_ras_n                => CONNECTED_TO_memory_mem_ras_n,                --                          .mem_ras_n
			memory_mem_cas_n                => CONNECTED_TO_memory_mem_cas_n,                --                          .mem_cas_n
			memory_mem_we_n                 => CONNECTED_TO_memory_mem_we_n,                 --                          .mem_we_n
			memory_mem_reset_n              => CONNECTED_TO_memory_mem_reset_n,              --                          .mem_reset_n
			memory_mem_dq                   => CONNECTED_TO_memory_mem_dq,                   --                          .mem_dq
			memory_mem_dqs                  => CONNECTED_TO_memory_mem_dqs,                  --                          .mem_dqs
			memory_mem_dqs_n                => CONNECTED_TO_memory_mem_dqs_n,                --                          .mem_dqs_n
			memory_mem_odt                  => CONNECTED_TO_memory_mem_odt,                  --                          .mem_odt
			memory_mem_dm                   => CONNECTED_TO_memory_mem_dm,                   --                          .mem_dm
			memory_oct_rzqin                => CONNECTED_TO_memory_oct_rzqin,                --                          .oct_rzqin
			keys_export                     => CONNECTED_TO_keys_export,                     --                      keys.export
			sys_sdram_pll_0_ref_reset_reset => CONNECTED_TO_sys_sdram_pll_0_ref_reset_reset, -- sys_sdram_pll_0_ref_reset.reset
			reset_reset_n                   => CONNECTED_TO_reset_reset_n                    --                     reset.reset_n
		);

