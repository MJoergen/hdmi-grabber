library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

-- This block handles the low-level I/O SERDES of the TMDS signal.
-- The output is synchronous and contains the encoded symbol stream.

entity tmds_io is
   port (
      delay_clk_i   : in  std_logic;   -- 200 MHz
      hdmi_rx_clk_i : in  std_logic;
      pad_rx_dat_i  : in  std_logic;
      hdmi_rx_dat_o : out std_logic_vector(9 downto 0)
   );
end entity tmds_io;

architecture synthesis of tmds_io is

begin

   -------------------------------------------------------------------------------------
   -- Input deserialization
   -------------------------------------------------------------------------------------

   IDELAYE2_inst : IDELAYE2
      generic map (
         CINVCTRL_SEL          => "FALSE",
         DELAY_SRC             => "DATAIN",
         HIGH_PERFORMANCE_MODE => "TRUE",
         IDELAY_TYPE           => "VAR_LOAD",
         IDELAY_VALUE          => 0,
         PIPE_SEL              => "FALSE",
         REFCLK_FREQUENCY      => 200.0,
         SIGNAL_PATTERN        => "DATA"
      )
      port map (
         C           => hdmi_clk,         -- input
         CE          => '1',              -- input
         CINVCTRL    => '0',              -- input
         CNTVALUEIN  => hdmi_delay_count, -- input
         CNTVALUEOUT => open,             -- output
         DATAIN      => pad_rx_dat,       -- input
         DATAOUT     => delay_rx_dat,     -- output
         IDATAIN     => '0',              -- input
         INC         => '0',              -- input
         LD          => hdmi_delay_ce,    -- input
         LDPIPEEN    => '0',              -- input
         REGRST      => '0'               -- input
      );
   clkb <= not clk_x5;

   ISERDESE2_master : ISERDESE2
      generic map (
         DATA_RATE         => "DDR",
         DATA_WIDTH        => 10,
         DYN_CLKDIV_INV_EN => "FALSE",
         DYN_CLK_INV_EN    => "FALSE",
         INIT_Q1           => '0',
         INIT_Q2           => '0',
         INIT_Q3           => '0',
         INIT_Q4           => '0',
         INTERFACE_TYPE    => "NETWORKING",
         IOBDELAY          => "IFD",
         NUM_CE            => 1,
         OFB_USED          => "FALSE",
         SERDES_MODE       => "MASTER",
         SRVAL_Q1          => '0',
         SRVAL_Q2          => '0',
         SRVAL_Q3          => '0',
         SRVAL_Q4          => '0'
      )
      port map (
         O            => open,
         Q1           => data(9),
         Q2           => data(8),
         Q3           => data(7),
         Q4           => data(6),
         Q5           => data(5),
         Q6           => data(4),
         Q7           => data(3),
         Q8           => data(2),
         SHIFTOUT1    => shift1,
         SHIFTOUT2    => shift2,
         BITSLIP      => bitslip,
         CE1          => ce,
         CE2          => '1',
         CLKDIVP      => '0',
         CLK          => clk_x5,
         CLKB         => clkb,
         CLKDIV       => clk_x1,
         OCLK         => '0',
         DYNCLKDIVSEL => '0',
         DYNCLKSEL    => '0',
         D            => '0',
         DDLY         => delayed,
         OFB          => '0',
         OCLKB        => '0',
         RST          => reset,
         SHIFTIN1     => '0',
         SHIFTIN2     => '0'
      ); -- ISERDESE2_master

   ISERDESE2_slave : ISERDESE2
      generic map (
         DATA_RATE         => "DDR",
         DATA_WIDTH        => 10,
         DYN_CLKDIV_INV_EN => "FALSE",
         DYN_CLK_INV_EN    => "FALSE",
         INIT_Q1           => '0',
         INIT_Q2           => '0',
         INIT_Q3           => '0',
         INIT_Q4           => '0',
         INTERFACE_TYPE    => "NETWORKING",
         IOBDELAY          => "IFD",
         NUM_CE            => 1,
         OFB_USED          => "FALSE",
         SERDES_MODE       => "SLAVE",
         SRVAL_Q1          => '0',
         SRVAL_Q2          => '0',
         SRVAL_Q3          => '0',
         SRVAL_Q4          => '0'
      )
      port map (
         Q3           => data(1),
         Q4           => data(0),
         BITSLIP      => bitslip,
         CE1          => ce,
         CE2          => '1',
         CLKDIVP      => '0',
         CLK          => CLK_x5,
         CLKB         => clkb,
         CLKDIV       => clk_x1,
         OCLK         => '0',
         DYNCLKDIVSEL => '0',
         DYNCLKSEL    => '0',
         D            => '0',
         DDLY         => '0',
         OFB          => '0',
         OCLKB        => '0',
         RST          => reset,
         SHIFTIN1     => shift1,
         SHIFTIN2     => shift2
      ); -- ISERDESE2_slave : ISERDESE2

end architecture synthesis;

