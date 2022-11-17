library ieee;
use ieee.std_logic_1164.all;

entity input_channel is
   port (
      clk_mgmt        : in  std_logic;
      clk             : in  std_logic;
      clk_x1          : in  std_logic;
      clk_x5          : in  std_logic;
      serial          : in  std_logic;
      reset           : in  std_logic;
      ce              : in  std_logic;
      invalid_symbol  : out std_logic;
      symbol          : out std_logic_vector (9 downto 0);
      ctl_valid       : out std_logic;
      ctl             : out std_logic_vector (1 downto 0);
      terc4_valid     : out std_logic;
      terc4           : out std_logic_vector (3 downto 0);
      guardband_valid : out std_logic;
      guardband       : out std_logic_vector (0 downto 0);
      data_valid      : out std_logic;
      data            : out std_logic_vector (7 downto 0);
      symbol_sync     : out std_logic
   );
end entity input_channel;

architecture synthesis of input_channel is

    signal delay_count     : std_logic_vector (4 downto 0);
    signal delay_ce        : STD_LOGIC;
    signal bitslip         : STD_LOGIC;
    signal symbol_sync_i   : STD_LOGIC;
    signal symbol_i        : std_logic_vector (9 downto 0);
    signal invalid_symbol_i: STD_LOGIC;

begin

    symbol <= symbol_i;

   i_deser: deserialiser_1_to_10 port map (
           clk_mgmt    => clk_mgmt,
           delay_ce    => delay_ce,
           delay_count => delay_count,
           ce          => ce,
           clk         => clk,
           clk_x1      => clk_x1,
           bitslip     => bitslip,
           clk_x5      => clk_x5,
           reset       => reset,
           serial      => serial,
           data        => symbol_i);

   i_decoder: tmds_decoder port map (
           clk             => clk,
           symbol          => symbol_i,
           invalid_symbol  => invalid_symbol_i,
           ctl_valid       => ctl_valid,
           ctl             => ctl,
           terc4_valid     => terc4_valid,
           terc4           => terc4,
           guardband_valid => guardband_valid,
           guardband       => guardband,
           data_valid      => data_valid,
           data            => data
       );
       
       invalid_symbol <= invalid_symbol_i;
        
   i_alignment_detect: alignment_detect port map (
              clk            => clk,
              invalid_symbol => invalid_symbol_i,
              delay_count    => delay_count,
              delay_ce       => delay_ce,
              bitslip        => bitslip,
              symbol_sync    => symbol_sync);

end architecture synthesis;

