library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

-- This block handles the low-level I/O SERDES of the TMDS signal.
-- The output is synchronous and contains the encoded symbol stream.

entity hdmi_rx is
   port (
      delay_clk_i   : in  std_logic;   -- 200 MHz
      pad_rx_clk_i  : in  std_logic;
      pad_rx_dat_i  : in  std_logic_vector(2 downto 0);
      hdmi_rx_clk_o : out std_logic;
      hdmi_rx_dat_o : out std_logic_vector(29 downto 0)
   );
end entity hdmi_rx;

architecture synthesis of hdmi_rx is

   signal tmds_clk_unbuf   : std_logic;
   signal tmds_clk         : std_logic;
   signal hdmi_clk_unbuf   : std_logic;
   signal hdmi_clk         : std_logic;
   signal mmcm_clk_unbuf   : std_logic;
   signal mmcm_clk         : std_logic;

   signal delayed          : std_logic := '0';
   signal shift1           : std_logic := '0';
   signal shift2           : std_logic := '0';
   signal clkb             : std_logic := '1';

   attribute IODELAY_GROUP : string;
   attribute IODELAY_GROUP of IDELAYE2_inst: label is "idelay_group";

begin

   ------------------------------
   -- Input Delay reference
   --
   -- These are tied to the delay instances··
   -- by the IODELAY_GROUP attribute.
   --------------------------------------------····
   idelayctrl_inst : IDELAYCTRL
      port map (
         RDY    => open,
         REFCLK => delay_clk_i,
         RST    => '0'
      ); -- IDELAYCTRL_inst


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
         CLKIN1    => pad_rx_clk_i,
         CLKOUT0   => tmds_clk_unbuf,
         CLKOUT1   => hdmi_clk_unbuf,
         CLKFBOUT  => mmcm_clk_unbuf,
         PWRDWN    => '0',
         RST       => '0',
         CLKFBIN   => mmcm_clk
      ); -- mmcm_rx_clk_inst : MMCME2_BASE


   -------------------------------------------------------------------------------------
   -- Clock buffers
   -------------------------------------------------------------------------------------

   bufg_tmds_inst : BUFG
      port map (
         I => tmds_clk_unbuf,
         O => tmds_clk
      ); -- bufg_tmds_inst

   bufg_hdmi_inst : BUFG
      port map (
         I => hdmi_clk_unbuf,
         O => hdmi_clk
      ); -- bufg_hdmi_inst

   bufg_mmcm_inst : BUFG
      port map (
         I => mmcm_clk_unbuf,
         O => mmcm_clk
      ); -- bufg_mmcm_inst


   gen_tmds_io : for i in 0 to 2 generate
      i_tmds_io : entity work.tmds_io
         port map (
            delay_clk_i   => delay_clk,
            hdmi_rx_clk_i => hdmi_rx_clk,
            pad_rx_dat_i  => pad_rx_dat_i(i),
            hdmi_rx_dat_o => hdmi_rx_dat_o(10*i+9 downto 10*i)
         ); -- i_tmds_io
      end generate gen_tmds_io;

end architecture synthesis;

