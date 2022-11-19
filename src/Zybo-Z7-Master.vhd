library ieee;
use ieee.std_logic_1164.all;

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

   signal hdmi_pad_clk : std_logic;
   signal hdmi_pad_dat : std_logic_vector(2 downto 0);

   signal hdmi_clk : std_logic;
   signal hdmi_rst : std_logic;
   signal hdmi_dat : std_logic_vector(29 downto 0);

   signal sys_hdmi_rx_clk : std_logic_vector(27 downto 0);

   attribute mark_debug : boolean;
   attribute mark_debug of sys_hdmi_rx_clk : signal is true;
   attribute mark_debug of hdmi_dat : signal is true;

begin

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

   hdmi_rx_inst : entity work.hdmi_rx
      port map (
         sysclk_i       => sysclk,
         hdmi_pad_clk_i => hdmi_pad_clk,
         hdmi_pad_dat_i => hdmi_pad_dat,
         hdmi_clk_o     => hdmi_clk,
         hdmi_rst_o     => hdmi_rst,
         hdmi_dat_o     => hdmi_dat
      ); -- i_hdmi_rx


   -----------------------------------
   -- Measure HDMI Rx clock
   -----------------------------------

   clk_count_inst : entity work.clk_count
      generic map (
         G_COUNTER_SIZE         => 28,
         G_INPUT_CLOCK_SPEED_HZ => 125_000_000
      )
      port map (
         clk_i     => sysclk,
         obj_clk_i => hdmi_clk,
         count_o   => sys_hdmi_rx_clk
      );

end architecture synthesis;

