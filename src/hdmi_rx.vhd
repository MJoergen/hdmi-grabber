library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

-- This block handles the low-level I/O SERDES of the TMDS signal.
-- The output is synchronous and contains the encoded symbol stream.

entity hdmi_rx is
   port (
      sysclk_i       : in  std_logic;   -- 125.00 MHz
      hdmi_pad_clk_i : in  std_logic;
      hdmi_pad_dat_i : in  std_logic_vector(2 downto 0);
      hdmi_clk_o     : out std_logic;
      hdmi_rst_o     : out std_logic;
      hdmi_dat_o     : out std_logic_vector(29 downto 0)
   );
end entity hdmi_rx;

architecture synthesis of hdmi_rx is

   signal delay_clk   : std_logic;   -- 200.00 MHz
   signal delay_rst   : std_logic;
   signal tmds_clk    : std_logic;   -- 371.25 MHz

   signal pad_rx_dat  : std_logic_vector(2 downto 0);

   signal delayed     : std_logic := '0';
   signal shift1      : std_logic := '0';
   signal shift2      : std_logic := '0';
   signal clkb        : std_logic := '1';

begin

   -----------------------------------
   -- Generate clocks
   -----------------------------------

   clk_inst : entity work.clk
      port map (
         sysclk_i       => sysclk_i,         -- 125.00 MHz
         delay_clk_o    => delay_clk,        -- 200.00 MHz
         delay_rst_o    => delay_rst,
         hdmi_pad_clk_i => hdmi_pad_clk_i,   --  74.25 MHz
         hdmi_clk_o     => hdmi_clk_o,       --  74.25 MHz
         hdmi_rst_o     => hdmi_rst_o,
         tmds_clk_o     => tmds_clk          -- 371.25 MHz
      ); -- clk_inst


   ------------------------------
   -- Input Delay reference
   --
   -- These are tied to the delay instances
   -- by the IODELAY_GROUP attribute.
   --------------------------------------------

   idelayctrl_inst : IDELAYCTRL
      port map (
         REFCLK => delay_clk,
         RST    => delay_rst,
         RDY    => open
      ); -- IDELAYCTRL_inst


   gen_channel_rx : for i in 0 to 2 generate
      channel_rx_inst : entity work.channel_rx
         port map (
            delay_clk_i => delay_clk,
            hdmi_clk_i  => hdmi_clk_o,
            hdmi_rst_i  => hdmi_rst_o,
            tmds_clk_i  => tmds_clk,
            pad_dat_i   => hdmi_pad_dat_i(i),
            hdmi_dat_o  => hdmi_dat_o(10*i+9 downto 10*i)
         ); -- channel_rx_inst
      end generate gen_channel_rx;

end architecture synthesis;

