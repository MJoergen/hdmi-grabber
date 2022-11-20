library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity Zybo_Z7_Master is
   port (
      sysclk        : in  std_logic;   -- 125 MHz
      hdmi_rx_clk_p : in  std_logic;   -- Expected 74.25 MHz
      hdmi_rx_clk_n : in  std_logic;
      hdmi_rx_p     : in  std_logic_vector(2 downto 0);
      hdmi_rx_n     : in  std_logic_vector(2 downto 0);
      hdmi_tx_clk_p : out std_logic;
      hdmi_tx_clk_n : out std_logic;
      hdmi_tx_p     : out std_logic_vector(2 downto 0);
      hdmi_tx_n     : out std_logic_vector(2 downto 0)
   );
end entity Zybo_Z7_Master;

architecture synthesis of Zybo_Z7_Master is

   signal mmcm_clk100       : std_logic;
   signal mmcm_clk100_unbuf : std_logic;
   signal clk100_unbuf      : std_logic;

   signal hdmi_pad_clk : std_logic;
   signal hdmi_pad_dat : std_logic_vector(2 downto 0);

   signal sys_clk100  : std_logic_vector(27 downto 0);

   signal clk100      : std_logic;
   signal pixel_clk   : std_logic;
   signal symbol_sync : std_logic;
   signal raw_blank   : std_logic;
   signal raw_hsync   : std_logic;
   signal raw_vsync   : std_logic;
   signal raw_ch0     : std_logic_vector(7 downto 0);
   signal raw_ch1     : std_logic_vector(7 downto 0);
   signal raw_ch2     : std_logic_vector(7 downto 0);
   signal symbol_ch0  : std_logic_vector(9 downto 0);
   signal symbol_ch1  : std_logic_vector(9 downto 0);
   signal symbol_ch2  : std_logic_vector(9 downto 0);

   attribute mark_debug : boolean;
   attribute mark_debug of sys_clk100  : signal is true;
   attribute mark_debug of symbol_sync : signal is true;
   attribute mark_debug of raw_blank   : signal is true;
   attribute mark_debug of raw_hsync   : signal is true;
   attribute mark_debug of raw_vsync   : signal is true;
   attribute mark_debug of raw_ch0     : signal is true;
   attribute mark_debug of raw_ch1     : signal is true;
   attribute mark_debug of raw_ch2     : signal is true;
   attribute mark_debug of symbol_ch0  : signal is true;
   attribute mark_debug of symbol_ch1  : signal is true;
   attribute mark_debug of symbol_ch2  : signal is true;

begin

   mmcm_clk100_inst : MMCME2_BASE
      generic map (
         BANDWIDTH        => "OPTIMIZED",
         CLKFBOUT_MULT_F  => 8.0,
         CLKIN1_PERIOD    => 8.000,       -- 125 MHz
         CLKOUT0_DIVIDE_F => 10.0,        -- 100 MHz
         DIVCLK_DIVIDE    => 1,
         REF_JITTER1      => 0.0,
         STARTUP_WAIT     => FALSE        -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
      port map (
         CLKFBIN   => mmcm_clk100,
         CLKFBOUT  => mmcm_clk100_unbuf,
         CLKIN1    => sysclk,
         CLKOUT0   => clk100_unbuf,
         PWRDWN    => '0',
         RST       => '0'
      ); -- mmcm_clk100_inst : MMCME2_BASE

   bufg_mmcm_clk100_inst : BUFG
      port map (
         I => mmcm_clk100_unbuf,
         O => mmcm_clk100
      ); -- bufg_mmcm_clk100_inst

   bufg_clk100_inst : BUFG
      port map (
         I => clk100_unbuf,
         O => clk100
      ); -- bufg_clk100_inst


   -----------------------------------
   -- Intercept differential signals
   -----------------------------------

   hdmi_intercept_inst : entity work.hdmi_intercept
      port map (
         hdmi_rx_clk_p  => hdmi_rx_clk_p,
         hdmi_rx_clk_n  => hdmi_rx_clk_n,
         hdmi_rx_p      => hdmi_rx_p,
         hdmi_rx_n      => hdmi_rx_n,
         hdmi_tx_clk_p  => hdmi_tx_clk_p,
         hdmi_tx_clk_n  => hdmi_tx_clk_n,
         hdmi_tx_p      => hdmi_tx_p,
         hdmi_tx_n      => hdmi_tx_n,
         hdmi_pad_clk_o => hdmi_pad_clk,
         hdmi_pad_dat_o => hdmi_pad_dat
      ); -- hdmi_intercept_inst


   -----------------------------------
   -- Sample and decode Rx channels
   -----------------------------------


   hdmi_input_inst : entity work.hdmi_input
      port map (
         system_clk          => clk100,
         hdmi_in_clk         => hdmi_pad_clk,
         hdmi_in_ch0         => hdmi_pad_dat(0),
         hdmi_in_ch1         => hdmi_pad_dat(1),
         hdmi_in_ch2         => hdmi_pad_dat(2),

         debug               => open,
         hdmi_detected       => open,
         pixel_clk           => pixel_clk,
         pixel_io_clk_x1     => open,
         pixel_io_clk_x5     => open,
         pll_locked          => open,
         symbol_sync         => symbol_sync,
         raw_blank           => raw_blank,
         raw_hsync           => raw_hsync,
         raw_vsync           => raw_vsync,
         raw_ch0             => raw_ch0,
         raw_ch1             => raw_ch1,
         raw_ch2             => raw_ch2,
         adp_data_valid      => open,
         adp_header_bit      => open,
         adp_frame_bit       => open,
         adp_subpacket0_bits => open,
         adp_subpacket1_bits => open,
         adp_subpacket2_bits => open,
         adp_subpacket3_bits => open,
         symbol_ch0          => symbol_ch0,
         symbol_ch1          => symbol_ch1,
         symbol_ch2          => symbol_ch2
      ); -- hdmi_input_inst : entity work.hdmi_input


   -----------------------------------
   -- Measure HDMI Rx clock
   -----------------------------------

   clk_count_inst : entity work.clk_count
      generic map (
         G_COUNTER_SIZE         => 28,
         G_INPUT_CLOCK_SPEED_HZ => 74_250_000
      )
      port map (
         clk_i     => pixel_clk,
         obj_clk_i => clk100,
         count_o   => sys_clk100
      );

end architecture synthesis;

