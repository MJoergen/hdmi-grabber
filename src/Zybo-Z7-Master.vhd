library ieee;
use ieee.std_logic_1164.all;

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

begin

   -- Connect input to output
   hdmi_tx_hpd   <= hdmi_rx_hpd;
   hdmi_tx_clk_n <= hdmi_rx_clk_n;
   hdmi_tx_clk_p <= hdmi_rx_clk_p;
   hdmi_tx_n     <= hdmi_rx_n;
   hdmi_tx_p     <= hdmi_rx_p;

   -- Tri-state bidirectional ports
   hdmi_rx_scl   <= 'Z';
   hdmi_rx_sda   <= 'Z';
   hdmi_rx_cec   <= 'Z';
   hdmi_tx_scl   <= 'Z';
   hdmi_tx_sda   <= 'Z';
   hdmi_tx_cec   <= 'Z';

end architecture synthesis;

