library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity hdmi_intercept is
   port (
      hdmi_rx_clk_p  : in  std_logic;
      hdmi_rx_clk_n  : in  std_logic;
      hdmi_rx_p      : in  std_logic_vector(2 downto 0);
      hdmi_rx_n      : in  std_logic_vector(2 downto 0);

      hdmi_tx_clk_p  : out std_logic;
      hdmi_tx_clk_n  : out std_logic;
      hdmi_tx_p      : out std_logic_vector(2 downto 0);
      hdmi_tx_n      : out std_logic_vector(2 downto 0);

      hdmi_pad_clk_o : out std_logic;
      hdmi_pad_dat_o : out std_logic_vector(2 downto 0)
   );
end entity hdmi_intercept;

architecture synthesis of hdmi_intercept is

begin

   -----------------------------------
   -- Differential input
   -----------------------------------

   ibufds_clk_inst : ibufds
      generic map (
         DIFF_TERM    => FALSE,  -- Differential Termination·
         IBUF_LOW_PWR => TRUE,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
         IOSTANDARD   => "TMDS_33"
      )
      port map (
         i  => hdmi_rx_clk_p,
         ib => hdmi_rx_clk_n,
         o  => hdmi_pad_clk_o
      ); -- ibufds_clk_inst

   ibufds_gen : for i in 0 to 2 generate
      ibufds_dat_inst : ibufds
         generic map (
            DIFF_TERM  => FALSE,
            IOSTANDARD => "TMDS_33"
         )
         port map (
            i  => hdmi_rx_p(i),
            ib => hdmi_rx_n(i),
            o  => hdmi_pad_dat_o(i)
         ); -- ibufds_dat_inst
      end generate ibufds_gen;


   -----------------------------------
   -- Differential output
   -----------------------------------

   obufds_clk_inst : obufds
      port map (
         i  => hdmi_pad_clk_o,
         o  => hdmi_tx_clk_p,
         ob => hdmi_tx_clk_n
      ); -- obufds_clk_inst

   obufds_gen : for i in 0 to 2 generate
      obufds_dat_inst : obufds
         port map (
            i  => hdmi_pad_dat_o(i),
            o  => hdmi_tx_p(i),
            ob => hdmi_tx_n(i)
         ); -- obufds_dat_inst
      end generate obufds_gen;

end architecture synthesis;

