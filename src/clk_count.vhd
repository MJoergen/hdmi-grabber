library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

library xpm;
use xpm.vcomponents.all;

entity clk_count is
   generic (
      G_COUNTER_SIZE         : integer := 28,
      G_INPUT_CLOCK_SPPED_HZ : integer := 200_000_000
   );
   port (
      clk_i     : in  std_logic;
      count_o   : out std_logic_vector(G_COUNTER_SIZE-1 downto 0);
      obj_clk_i : in  std_logic
   );
end entity clk_count;

architecture synthesis of clk_count is

   -- clk domain
   signal clk_counter : std_logic_vector(G_COUNTER_SIZE-1 downto 0);
   signal clk_pps     : std_logic;

   -- obj_clk domain
   signal obj_counter : std_logic_vector(G_COUNTER_SIZE-1 downto 0);
   signal obj_latch   : std_logic_vector(G_COUNTER_SIZE-1 downto 0);
   signal obj_pps     : std_logic;

begin

   --------------
   -- clk domain
   --------------

   clk_counter_p : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if clk_counter = G_INPUT_CLOCK_SPPED_HZ - 1 then
            clk_counter <= (others => '0');
            clk_pps     <= '1';
         else
            clk_counter <= clk_counter + 1;
            clk_pps     <= '0';
         end if;
      end if;
   end process clk_counter_p;


   -------------------
   -- CDC
   -------------------

   xpm_cdc_pulse_inst : xpm_cdc_pulse
      generic map (
         RST_USED     => 0,
         DEST_SYNC_FF => 2
      )
      port map (
         src_clk    => clk_i,
         src_rst    => '0',
         src_pulse  => clk_pps,
         dest_clk   => obj_clk_i,
         dest_rst   => '0',
         dest_pulse => obj_pps
      ); -- xpm_cdc_pulse_inst

   xpm_cdc_array_single_inst : xpm_cdc_array_single
      generic map (
         DEST_SYNC_FF => 2,
         WIDTH        => G_COUNTER_SIZE
      )
      port map (
         src_clk  => obj_clk_i,
         src_in   => obj_latch,
         dest_clk => clk_i,
         dest_out => count_o
      ); -- xpm_cdc_array_single_inst


   -------------------
   -- obj_clk domain
   -------------------

   obj_counter_p : process (obj_clk_i)
   begin
      if rising_edge(obj_clk_i) then
         obj_counter <= obj_counter + 1;
         if obj_pps = '1' then
            obj_latch <= obj_counter;
            obj_counter <= (others => '0');
         end if;
      end if;
   end process obj_counter_p;

end architecture synthesis;

