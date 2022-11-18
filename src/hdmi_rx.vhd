library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

-- This block handles the low-level I/O SERDES of the TMDS signal.
-- The output is synchronous and contains the encoded symbol stream.

entity hdmi_rx is
   port (
      delay_clk_i    : in  std_logic;   -- 200.00 MHz
      hdmi_rx_clk_i  : in  std_logic;   --  74.25 MHz
      tmds_rx_clk_i  : in  std_logic;   -- 371.25 MHz
      pad_rx_dat_p_i : in  std_logic_vector(2 downto 0);
      pad_rx_dat_n_i : in  std_logic_vector(2 downto 0);
      hdmi_rx_dat_o  : out std_logic_vector(29 downto 0)
   );
end entity hdmi_rx;

architecture synthesis of hdmi_rx is

   signal pad_rx_dat : std_logic_vector(2 downto 0);

   signal delayed    : std_logic := '0';
   signal shift1     : std_logic := '0';
   signal shift2     : std_logic := '0';
   signal clkb       : std_logic := '1';

   attribute IODELAY_GROUP : string;
   attribute IODELAY_GROUP of IDELAYE2_inst: label is "idelay_group";

begin

   gen_ibufds : for i in 0 to 2 generate
      ibufds_clk_inst : ibufds
         port map (
            i  => pad_rx_dat_p_i(i),
            ib => pad_rx_dat_n_i(i),
            o  => pad_rx_dat(i)
         ); -- ibufds_clk_inst
      end generate gen_ibufds;


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

