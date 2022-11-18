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
      hdmi_rx_n     : in  std_logic_vector(2 downto 0)
   );
end entity Zybo_Z7_Master;

architecture synthesis of Zybo_Z7_Master is

   signal clk200      : std_logic;  -- 200.00 MHz
   signal hdmi_rx_clk : std_logic;  --  74.25 Mhz
   signal tmds_rx_clk : std_logic;  -- 371.25 MHz

   signal hdmi_rx_dat : std_logic_vector(29 downto 0);

begin

   i_clk : entity work.clk
      port map (
         sysclk_i       => sysclk,
         pad_rx_clk_p_i => hdmi_rx_clk_p,
         pad_rx_clk_n_i => hdmi_rx_clk_n,
         clk200_o       => clk200,
         hdmi_rx_clk_o  => hdmi_rx_clk,
         tmds_rx_clk_o  => tmds_rx_clk
      ); -- i_clk

   i_hdmi_rx : entity work.hdmi_rx
      port map (
         delay_clk_i    => clk200,
         hdmi_rx_clk_i  => hdmi_rx_clk,
         tmds_rx_clk_i  => tmds_rx_clk,
         pad_rx_dat_p_i => hdmi_rx_p,
         pad_rx_dat_n_i => hdmi_rx_n,
         hdmi_rx_dat_o  => hdmi_rx_dat
      ); -- i_hdmi_rx

end architecture synthesis;

