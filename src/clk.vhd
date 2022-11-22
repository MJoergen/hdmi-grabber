library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library xpm;
use xpm.vcomponents.all;

entity clk is
   port (
      sysclk_i       : in  std_logic;
      hdmi_pad_clk_i : in  std_logic;  -- 74.25 MHz
      delay_clk_o    : out std_logic;  -- 200 MHz
      delay_rst_o    : out std_logic;
      hdmi_clk_o     : out std_logic;  -- 74.25 MHz
      hdmi_rst_o     : out std_logic;
      tmds_clk_o     : out std_logic   -- 371.25 MHz
   );
end entity clk;

architecture synthesis of clk is

   signal tmds_clk_unbuf : std_logic;
   signal mmcm_clk_unbuf : std_logic;
   signal mmcm_locked    : std_logic;

   signal delay_clk_unbuf      : std_logic;
   signal delay_mmcm_clk_unbuf : std_logic;
   signal delay_mmcm_clk       : std_logic;

begin

   -----------------------------------
   -- MMCM driven by the pad rx clock
   -----------------------------------

   mmcm_rx_clk_inst : MMCME2_BASE
      generic map (
         BANDWIDTH        => "OPTIMIZED",
         CLKFBOUT_MULT_F  => 10.0,
         CLKIN1_PERIOD    => 13.468,      -- 74.25 MHz
         CLKOUT0_DIVIDE_F => 2.0,         -- 371.25 MHz
         DIVCLK_DIVIDE    => 1,
         REF_JITTER1      => 0.0,
         STARTUP_WAIT     => FALSE        -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
      port map (
         CLKFBIN   => mmcm_clk_unbuf,
         CLKFBOUT  => mmcm_clk_unbuf,
         CLKIN1    => hdmi_pad_clk_i,
         CLKOUT0   => tmds_clk_unbuf,
         PWRDWN    => '0',
         RST       => '0',
         LOCKED    => mmcm_locked
      ); -- mmcm_rx_clk_inst : MMCME2_BASE


   -----------------------------------
   -- MMCM driven by the sysclk
   -----------------------------------

   delay_mmcm_clk_inst : MMCME2_BASE
      generic map (
         BANDWIDTH        => "OPTIMIZED",
         CLKFBOUT_MULT_F  => 8.0,
         CLKIN1_PERIOD    => 8.000,       -- 125 MHz
         CLKOUT0_DIVIDE_F => 5.0,         -- 200 MHz
         DIVCLK_DIVIDE    => 1,
         REF_JITTER1      => 0.0,
         STARTUP_WAIT     => FALSE        -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
      port map (
         CLKFBIN   => delay_mmcm_clk,
         CLKFBOUT  => delay_mmcm_clk_unbuf,
         CLKIN1    => sysclk_i,
         CLKOUT0   => delay_clk_unbuf,
         PWRDWN    => '0',
         RST       => '0'
      ); -- delay_mmcm_clk_inst : MMCME2_BASE


   -------------------------------------------------------------------------------------
   -- Clock buffers
   -------------------------------------------------------------------------------------

   bufg_tmds_inst : BUFIO
      port map (
         I => tmds_clk_unbuf,
         O => tmds_clk_o
      ); -- bufg_tmds_inst

   bufg_hdmi_inst : BUFR
      generic map (
         BUFR_DIVIDE => "5",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"·
         SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES"·
      )
      port map (
         CE  => '1',
         CLR => not mmcm_locked,
         I   => tmds_clk_unbuf,
         O   => hdmi_clk_o
      ); -- bufg_hdmi_inst


   bufg_mmcm_clk200_inst : BUFG
      port map (
         I => delay_mmcm_clk_unbuf,
         O => delay_mmcm_clk
      ); -- bufg_mmcm_clk200_inst

   bufg_clk200_inst : BUFG
      port map (
         I => delay_clk_unbuf,
         O => delay_clk_o
      ); -- bufg_clk200_inst


   -------------------------------------------------------------------------------------
   -- Reset generation
   -------------------------------------------------------------------------------------

   xpm_cdc_async_rst_delay_inst : xpm_cdc_async_rst
      generic map (
         DEST_SYNC_FF => 8,
         INIT_SYNC_FF => 1,
         RST_ACTIVE_HIGH => 1
      )
      port map (
         src_arst  => '0',
         dest_clk  => delay_clk_o,
         dest_arst => delay_rst_o
      ); -- xpm_cdc_async_rst_delay_inst

   xpm_cdc_async_rst_hdmi_inst : xpm_cdc_async_rst
      generic map (
         DEST_SYNC_FF => 8,
         INIT_SYNC_FF => 1,
         RST_ACTIVE_HIGH => 1
      )
      port map (
         src_arst  => '0',
         dest_clk  => hdmi_clk_o,
         dest_arst => hdmi_rst_o
      ); -- xpm_cdc_async_rst_hdmi_inst

end architecture synthesis;

