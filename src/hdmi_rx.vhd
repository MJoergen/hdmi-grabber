library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity hdmi_rx is
   port (
      pad_rx_clk_i  : in  std_logic;
      pad_rx_dat_i  : in  std_logic_vector(2 downto 0);
      hdmi_rx_clk_o : out std_logic;
      hdmi_rx_dat_o : out std_logic_vector(29 downto 0)
   );
end entity hdmi_rx;

architecture synthesis of hdmi_rx is

   signal clk_pixel_raw    : std_logic;
   signal clk_pixel_x1_raw : std_logic;
   signal clk_pixel_x5_raw : std_logic;
   signal clk_pixel        : std_logic;
   signal clk_pixel_x1     : std_logic;
   signal clk_pixel_x5     : std_logic;
   signal clkfb_2          : std_logic;
   signal locked           : std_logic;

   signal delayed          : std_logic := '0';
   signal shift1           : std_logic := '0';
   signal shift2           : std_logic := '0';
   signal clkb             : std_logic := '1';
   attribute IODELAY_GROUP : string;
   attribute IODELAY_GROUP of IDELAYE2_inst: label is "idelay_group";

begin

   --------------------------------
   -- MMCM driven by the HDMI clock
   --------------------------------

   mmcm_rx_clk_inst : MMCME2_BASE
      generic map (
         BANDWIDTH        => "OPTIMIZED", -- Jitter programming (OPTIMIZED, HIGH, LOW)
         DIVCLK_DIVIDE    => 1,           -- Master division value (1-106)
         CLKFBOUT_MULT_F  => 5.0,         -- Multiply value for all CLKOUT (2.000-64.000).
         CLKIN1_PERIOD    => 12.5,        -- 1000.0/148.5, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
         CLKOUT0_DIVIDE_F => 5.0,         -- Divide amount for CLKOUT0 (1.000-128.000).
         CLKOUT1_DIVIDE   => 5,
         CLKOUT2_DIVIDE   => 1,
         REF_JITTER1      => 0.0,         -- Reference input jitter in UI (0.000-0.999).
         STARTUP_WAIT     => FALSE        -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
      port map (
         CLKIN1    => pad_rx_clk_i,     -- 1-bit input: Clock
         CLKOUT0   => clk_pixel_raw,    -- 1-bit output: CLKOUT0
         CLKOUT1   => clk_pixel_x1_raw, -- 1-bit output: CLKOUT1
         CLKOUT2   => clk_pixel_x5_raw, -- 1-bit output: CLKOUT2
         CLKFBOUT  => clkfb_2,       -- 1-bit output: Feedback clock
         LOCKED    => locked,        -- 1-bit output: LOCK
         PWRDWN    => '0',           -- 1-bit input: Power-down
         RST       => '0',           -- 1-bit input: Reset
         CLKFBIN   => clkfb_2        -- 1-bit input: Feedback clock
      );

      ----------------------------------
      -- Force the highest speed clock
      -- through the IO clock buffer
      -- (this is only rated for 600MHz!)
      -----------------------------------
   BUFIO_x5_inst : BUFIO
      port map (
         I => clk_pixel_x5_raw, -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
         O => clk_pixel_x5      -- 1-bit output: Clock output (connect to I/O clock loads).
      );

   BUFIO_x1_inst : BUFG
         port map (
            I => clk_pixel_x1_raw, -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
            O => clk_pixel_x1      -- 1-bit output: Clock output (connect to I/O clock loads).
         );

   BUFIO_inst : BUFG
         port map (
            I => clk_pixel_raw, -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
            O => clk_pixel      -- 1-bit output: Clock output (connect to I/O clock loads).
         );

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
             DATAIN      => serial,
             IDATAIN     => '0',
             DATAOUT     => delayed,
             --
             CNTVALUEOUT => open,
             C           => clk,
             CE          => delay_ce,
             CINVCTRL    => '0',
             CNTVALUEIN  => delay_count,
             INC         => '0',
             LD          => '1',
             LDPIPEEN    => '0',
             REGRST      => '0'
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

