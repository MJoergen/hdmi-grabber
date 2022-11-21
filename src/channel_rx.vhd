library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

-- This block handles the low-level I/O SERDES of the TMDS signal.
-- The output is synchronous and contains the encoded symbol stream.

entity channel_rx is
   port (
      delay_clk_i : in  std_logic;   -- 200.00 MHz
      hdmi_clk_i  : in  std_logic;   --  74.25 MHz
      hdmi_rst_i  : in  std_logic;
      tmds_clk_i  : in  std_logic;   -- 371.25 MHz
      pad_dat_i   : in  std_logic;
      hdmi_dat_o  : out std_logic_vector(9 downto 0)
   );
end entity channel_rx;

architecture synthesis of channel_rx is

   signal delay_dat            : std_logic;

   signal hdmi_bitslip         : std_logic;
   signal hdmi_shift1          : std_logic;
   signal hdmi_shift2          : std_logic;
   signal hdmi_symbol_sync     : std_logic;
   signal hdmi_symbol          : std_logic_vector(9 downto 0);

   signal hdmi_delay_count     : std_logic_vector(4 downto 0);
   signal hdmi_delay_ce        : std_logic;
   signal hdmi_invalid_symbol  : std_logic;
   signal hdmi_ctl_valid       : std_logic;
   signal hdmi_ctl             : std_logic_vector(1 downto 0);
   signal hdmi_terc4_valid     : std_logic;
   signal hdmi_terc4           : std_logic_vector(3 downto 0);
   signal hdmi_guardband_valid : std_logic;
   signal hdmi_guardband       : std_logic_vector(0 downto 0);
   signal hdmi_data_valid      : std_logic;
   signal hdmi_data            : std_logic_vector(7 downto 0);

   attribute mark_debug : boolean;
   attribute mark_debug of hdmi_bitslip        : signal is true;
   attribute mark_debug of hdmi_symbol         : signal is true;
   attribute mark_debug of hdmi_data           : signal is true;
   attribute mark_debug of hdmi_delay_count    : signal is true;
   attribute mark_debug of hdmi_delay_ce       : signal is true;
   attribute mark_debug of hdmi_invalid_symbol : signal is true;
   attribute mark_debug of hdmi_symbol_sync    : signal is true;

begin

   -------------------------------------------------------------------------------------
   -- Tuneable input delay
   -------------------------------------------------------------------------------------

   IDELAYE2_inst : IDELAYE2
      generic map (
         CINVCTRL_SEL          => "FALSE",
         DELAY_SRC             => "DATAIN",
         HIGH_PERFORMANCE_MODE => "TRUE",
         IDELAY_TYPE           => "VAR_LOAD",
         IDELAY_VALUE          => 0,
         PIPE_SEL              => "FALSE",
         REFCLK_FREQUENCY      => 200.0,  -- Tap resolution of 1000000/(64*200) = 78.125  ps.
         SIGNAL_PATTERN        => "DATA"
      )
      port map (
         C           => hdmi_clk_i,       -- input
         CE          => '1',              -- input
         CINVCTRL    => '0',              -- input
         CNTVALUEIN  => hdmi_delay_count, -- input
         CNTVALUEOUT => open,             -- output
         DATAIN      => pad_dat_i,        -- input
         DATAOUT     => delay_dat,        -- output
         IDATAIN     => '0',              -- input
         INC         => '0',              -- input
         LD          => hdmi_delay_ce,    -- input
         LDPIPEEN    => '0',              -- input
         REGRST      => '0'               -- input
      ); -- IDELAYE2_inst


   -------------------------------------------------------------------------------------
   -- Input deserialization
   -------------------------------------------------------------------------------------

   ISERDESE2_master_inst : ISERDESE2
      generic map (
         DATA_RATE         => "DDR",
         DATA_WIDTH        => 10,
         DYN_CLKDIV_INV_EN => "FALSE",
         DYN_CLK_INV_EN    => "FALSE",
         INIT_Q1           => '0',
         INIT_Q2           => '0',
         INIT_Q3           => '0',
         INIT_Q4           => '0',
         INTERFACE_TYPE    => "NETWORKING",
         IOBDELAY          => "IFD",
         NUM_CE            => 1,
         OFB_USED          => "FALSE",
         SERDES_MODE       => "MASTER",
         SRVAL_Q1          => '0',
         SRVAL_Q2          => '0',
         SRVAL_Q3          => '0',
         SRVAL_Q4          => '0'
      )
      port map (
         BITSLIP      => hdmi_bitslip,
         CE1          => '1',
         CE2          => '1',
         CLKB         => not tmds_clk_i,
         CLK          => tmds_clk_i,
         CLKDIV       => hdmi_clk_i,
         CLKDIVP      => '0',
         D            => '0',
         DDLY         => delay_dat,
         DYNCLKDIVSEL => '0',
         DYNCLKSEL    => '0',
         OCLK         => '0',
         OCLKB        => '0',
         OFB          => '0',
         O            => open,
         Q1           => hdmi_symbol(9),
         Q2           => hdmi_symbol(8),
         Q3           => hdmi_symbol(7),
         Q4           => hdmi_symbol(6),
         Q5           => hdmi_symbol(5),
         Q6           => hdmi_symbol(4),
         Q7           => hdmi_symbol(3),
         Q8           => hdmi_symbol(2),
         RST          => hdmi_rst_i,
         SHIFTIN1     => '0',
         SHIFTIN2     => '0',
         SHIFTOUT1    => hdmi_shift1,
         SHIFTOUT2    => hdmi_shift2
      ); -- ISERDESE2_master_inst

   ISERDESE2_slave_inst : ISERDESE2
      generic map (
         DATA_RATE         => "DDR",
         DATA_WIDTH        => 10,
         DYN_CLKDIV_INV_EN => "FALSE",
         DYN_CLK_INV_EN    => "FALSE",
         INIT_Q1           => '0',
         INIT_Q2           => '0',
         INIT_Q3           => '0',
         INIT_Q4           => '0',
         INTERFACE_TYPE    => "NETWORKING",
         IOBDELAY          => "IFD",
         NUM_CE            => 1,
         OFB_USED          => "FALSE",
         SERDES_MODE       => "SLAVE",
         SRVAL_Q1          => '0',
         SRVAL_Q2          => '0',
         SRVAL_Q3          => '0',
         SRVAL_Q4          => '0'
      )
      port map (
         BITSLIP      => hdmi_bitslip,
         CE1          => '1',
         CE2          => '1',
         CLKB         => not tmds_clk_i,
         CLK          => tmds_clk_i,
         CLKDIV       => hdmi_clk_i,
         CLKDIVP      => '0',
         D            => '0',
         DDLY         => '0',
         DYNCLKDIVSEL => '0',
         DYNCLKSEL    => '0',
         OCLK         => '0',
         OCLKB        => '0',
         OFB          => '0',
         Q1           => open,
         Q2           => open,
         Q3           => hdmi_symbol(1),
         Q4           => hdmi_symbol(0),
         Q5           => open,
         Q6           => open,
         Q7           => open,
         Q8           => open,
         RST          => hdmi_rst_i,
         SHIFTIN1     => hdmi_shift1,
         SHIFTIN2     => hdmi_shift2
      ); -- ISERDESE2_slave_inst : ISERDESE2

   hdmi_dat_o <= hdmi_symbol;


   -------------------------------------------------------------------------------------
   -- Input decoding
   -------------------------------------------------------------------------------------

   tmds_decoder_inst : entity work.tmds_decoder
      port map (
         clk_i             => hdmi_clk_i,
         symbol_i          => hdmi_symbol,
         invalid_symbol_o  => hdmi_invalid_symbol,
         ctl_valid_o       => hdmi_ctl_valid,
         ctl_o             => hdmi_ctl,
         terc4_valid_o     => hdmi_terc4_valid,
         terc4_o           => hdmi_terc4,
         guardband_valid_o => hdmi_guardband_valid,
         guardband_o       => hdmi_guardband,
         data_valid_o      => hdmi_data_valid,
         data_o            => hdmi_data
      ); -- tmds_decoder_inst


   -------------------------------------------------------------------------------------
   -- Adjust alignment
   -------------------------------------------------------------------------------------

   alignment_detect_inst : entity work.alignment_detect
      port map (
         clk_i            => hdmi_clk_i,
         invalid_symbol_i => hdmi_invalid_symbol,
         delay_count_o    => hdmi_delay_count,
         delay_ce_o       => hdmi_delay_ce,
         bitslip_o        => hdmi_bitslip,
         symbol_sync_o    => hdmi_symbol_sync
      ); -- alignment_detect_inst

end architecture synthesis;

