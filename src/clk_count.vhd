library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity clk_count is
   generic (G_REF_CNT_LEN : integer := 15);
   port (
      ref_clk_i    : in  std_logic;
      clk0_clk_i   : in  std_logic;
      clk0_count_o : out std_logic_vector(15 downto 0)
   );
end entity clk_count;

architecture synthesis of clk_count is

   constant C_ALL_ONES     : std_logic_vector(G_REF_CNT_LEN-1 downto 0) := (others => '1');
   signal   ref_count_i    : std_logic_vector(G_REF_CNT_LEN-1 downto 0) := (others => '0');
   signal   ref_sample_out : std_logic                                  := '0';
   signal   ref_sample_in  : std_logic                                  := '0';

   signal clk0_count_i     : std_logic_vector(15 downto 0) := (others => '0');
   signal clk0_count_latch : std_logic_vector(15 downto 0) := (others => '0');
   signal clk0_count_sync  : std_logic_vector(15 downto 0) := (others => '0');
   signal clk0_count_ref   : std_logic_vector(15 downto 0) := (others => '0');
   signal clk0_count_rx    : std_logic_vector(15 downto 0) := (others => '0');
   signal clk0_sample_i    : std_logic                     := '0';

begin

   pci_proc : process(ref_clk_i)
   begin
      if rising_edge(ref_clk_i) then
         ref_count_i <= ref_count_i + 1;
         -- when rolling over on the reference counter, send out the last values
         -- and indicate to the other counters that their values
         -- shall be latched and sent to the reference clock domain:
         if ref_count_i = c_all_ones then
            ref_sample_out <= '1';
         else
            ref_sample_out <= '0';
         end if;

         if ref_sample_out = '1' then
            clk0_count_ref <= clk0_count_sync;
         else
            clk0_count_ref <= clk0_count_ref;
         end if;

         ref_sample_in <= ref_sample_out;

      end if;
   end process pci_proc;

   clk0_count_o <= clk0_count_ref;

   clk0_count_rx <= clk0_count_latch;

   clk0_sample_conv : entity work.pulse_conv
      port map(clk_src => ref_clk, en_src => ref_sample_in, clk_dst => clk0_clk, en_dst => clk0_sample_i);

   clk0_proc : process(clk0_clk_i)
   begin
      if rising_edge(clk0_clk_i) then
         clk0_count_i <= clk0_count_i + 1;
         if clk0_sample_i = '1' then
            clk0_count_latch <= clk0_count_i;  -- sample and hold counter value
            clk0_count_i     <= (others => '0');
         end if;
      end if;
   end process clk0_proc;

   cdc_sync_bundle_clk0_count : entity work.cdc_sync_bundle(synth)
      generic map( G_WIDTH      => 16, G_SYNC_DEPTH => 2  )
      port map ( clk => ref_clk, i => clk0_count_rx, o => clk0_count_sync );

end architecture synthesis;

