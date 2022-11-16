library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity Zybo_Z7_Master is
   port (
      sysclk        : in    std_logic;
      -- HDMI Rx
      hdmi_rx_hpd   : in    std_logic;
      hdmi_rx_scl   : inout std_logic;
      hdmi_rx_sda   : inout std_logic;
      hdmi_rx_clk_n : in    std_logic;
      hdmi_rx_clk_p : in    std_logic;
      hdmi_rx_n     : in    std_logic_vector(2 downto 0);
      hdmi_rx_p     : in    std_logic_vector(2 downto 0);
      hdmi_rx_cec   : inout std_logic;
      -- HDMI Tx
      hdmi_tx_hpd   : out   std_logic;
      hdmi_tx_scl   : inout std_logic;
      hdmi_tx_sda   : inout std_logic;
      hdmi_tx_clk_n : out   std_logic;
      hdmi_tx_clk_p : out   std_logic;
      hdmi_tx_n     : out   std_logic_vector(2 downto 0);
      hdmi_tx_p     : out   std_logic_vector(2 downto 0);
      hdmi_tx_cec   : inout std_logic
   );
end entity Zybo_Z7_Master;

architecture synthesis of Zybo_Z7_Master is

   signal hdmi_rx_clk : std_logic;
   signal hdmi_rx_dat : std_logic_vector(2 downto 0);
   signal hdmi_tx_clk : std_logic;
   signal hdmi_tx_dat : std_logic_vector(2 downto 0);

begin

   -- Connect input to output
   hdmi_tx_hpd   <= hdmi_rx_hpd;

   -- Tri-state bidirectional ports
   hdmi_rx_scl   <= 'Z';
   hdmi_rx_sda   <= 'Z';
   hdmi_rx_cec   <= 'Z';
   hdmi_tx_scl   <= 'Z';
   hdmi_tx_sda   <= 'Z';
   hdmi_tx_cec   <= 'Z';

   ibufds_clk_inst : ibufds
      port map (
         i  => hdmi_rx_clk_p,
         ib => hdmi_rx_clk_n,
         o  => hdmi_rx_clk
      ); -- ibufds_clk_inst

   gen_ibuf : for i in 0 to 2 generate
      ibufds_dat_inst : ibufds
         port map (
            i  => hdmi_rx_p(i),
            ib => hdmi_rx_n(i),
            o  => hdmi_rx_dat(i)
         ); -- ibufds_dat_inst
      end generate gen_ibuf;

   hdmi_tx_clk <= hdmi_rx_clk;
   hdmi_tx_dat <= hdmi_rx_dat;

   obufds_clk_inst : obufds
      port map (
         i  => hdmi_tx_clk,
         o  => hdmi_tx_clk_p,
         ob => hdmi_tx_clk_n
      ); -- obufds_clk_inst

   gen_obuf : for i in 0 to 2 generate
      obufds_dat_inst : obufds
         port map (
            i  => hdmi_tx_dat(i),
            o  => hdmi_tx_p(i),
            ob => hdmi_tx_n(i)
         ); -- obufds_dat_inst
      end generate gen_obuf;

end architecture synthesis;

