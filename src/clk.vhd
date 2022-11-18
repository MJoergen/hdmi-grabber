library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity clk is
   port (
      sysclk_i       : in  std_logic;
      pad_rx_clk_p_i : in  std_logic;
      pad_rx_clk_n_i : in  std_logic;
      clk200_o       : out std_logic;
      hdmi_rx_clk_o  : out std_logic;
      tmds_rx_clk_o  : out std_logic;
   );
end entity clk;

architecture synthesis of clk is

   signal pad_rx_clk        : std_logic;
   signal tmds_rx_clk_unbuf : std_logic;
   signal hdmi_rx_clk_unbuf : std_logic;
   signal mmcm_rx_clk_unbuf : std_logic;
   signal mmcm_rx_clk       : std_logic;

   signal clk200_unbuf      : std_logic;
   signal mmcm_clk200_unbuf : std_logic;
   signal mmcm_clk200       : std_logic;

begin

   ibufds_clk_inst : ibufds
      port map (
         i  => pad_rx_clk_p_i,
         ib => pad_rx_clk_n_i,
         o  => pad_rx_clk
      ); -- ibufds_clk_inst


   -----------------------------------
   -- MMCM driven by the pad rx clock
   -----------------------------------

   mmcm_rx_clk_inst : MMCME2_BASE
      generic map (
         BANDWIDTH        => "OPTIMIZED",
         CLKFBOUT_MULT_F  => 10.0,
         CLKIN1_PERIOD    => 13.468,      -- 74.25 MHz
         CLKOUT0_DIVIDE_F => 2.0,         -- 371.25 MHz
         CLKOUT1_DIVIDE   => 10,          -- 74.25 MHz
         DIVCLK_DIVIDE    => 1,
         REF_JITTER1      => 0.0,         -- Reference input jitter in UI (0.000-0.999).
         STARTUP_WAIT     => FALSE        -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
      port map (
         CLKIN1    => pad_rx_clk,
         CLKOUT0   => tmds_rx_clk_unbuf,
         CLKOUT1   => hdmi_rx_clk_unbuf,
         CLKFBOUT  => mmcm_rx_clk_unbuf,
         PWRDWN    => '0',
         RST       => '0',
         CLKFBIN   => mmcm_rx_clk
      ); -- mmcm_rx_clk_inst : MMCME2_BASE


   -----------------------------------
   -- MMCM driven by the sysclk
   -----------------------------------

   mmcm_clk200_inst : MMCME2_BASE
      generic map (
         BANDWIDTH        => "OPTIMIZED",
         CLKFBOUT_MULT_F  => 10.0,
         CLKIN1_PERIOD    => 8.0068,      -- 125 MHz
         CLKOUT0_DIVIDE_F => 5.0,         -- 200 MHz
         DIVCLK_DIVIDE    => 1,
         REF_JITTER1      => 0.0,         -- Reference input jitter in UI (0.000-0.999).
         STARTUP_WAIT     => FALSE        -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
      port map (
         CLKIN1    => sysclk,
         CLKOUT0   => clk200_unbuf,
         CLKFBOUT  => mmcm_clk200_unbuf,
         PWRDWN    => '0',
         RST       => '0',
         CLKFBIN   => mmcm_clk200
      ); -- mmcm_clk200_inst : MMCME2_BASE


   -------------------------------------------------------------------------------------
   -- Clock buffers
   -------------------------------------------------------------------------------------

   bufg_tmds_inst : BUFG
      port map (
         I => tmds_rx_clk_unbuf,
         O => tmds_rx_clk_o
      ); -- bufg_tmds_inst

   bufg_hdmi_inst : BUFG
      port map (
         I => hdmi_rx_clk_unbuf,
         O => hdmi_rx_clk_o
      ); -- bufg_hdmi_inst

   bufg_mmcm_inst : BUFG
      port map (
         I => mmcm_rx_clk_unbuf,
         O => mmcm_rx_clk
      ); -- bufg_mmcm_inst


   bufg_mmcm_clk200_inst : BUFG
      port map (
         I => mmcm_clk200_unbuf,
         O => mmcm_clk200
      ); -- bufg_mmcm_clk200_inst

   bufg_clk200_inst : BUFG
      port map (
         I => clk200_unbuf,
         O => clk200_o
      ); -- bufg_clk200_inst

end architecture synthesis;

