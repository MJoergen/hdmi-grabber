library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-------------------------------------------------------------
-- If there are a dozen or so symbol errors in at a rate of
-- greater than 1 in a million then advance the delay and
-- if that wraps then assert the bitslip signal.
--
-- Each error increase the sync_countdown by a million,
-- each valid sysmbol decreases the sync_countdown by
-- one. So after 12 errors it will cause us to
-- change bitslip or delay settings, but it will
-- take 7 million cycles until the high four
-- bits are zeros (and the link considered OK)
-----------------------------------------------
-------------------------------------------------------------

entity alignment_detect is
   port (
      clk_i            : in  std_logic;
      invalid_symbol_i : in  std_logic;
      delay_count_o    : out std_logic_vector(4 downto 0);
      delay_ce_o       : out std_logic;
      bitslip_o        : out std_logic;
      symbol_sync_o    : out std_logic
   );
end entity alignment_detect;

architecture synthesis of alignment_detect is

   signal error_seen     : std_logic;
   signal holdoff        : std_logic_vector(9 downto 0);
   signal sync_countdown : std_logic_vector(27 downto 0);

begin

   error_seen_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         error_seen <= '0';
         if invalid_symbol_i = '1' and holdoff = 0 then
            error_seen <= '1';
         end if;
      end if;
   end process error_seen_proc;

   detect_alignment_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         delay_ce_o    <= '0';
         bitslip_o     <= '0';
         symbol_sync_o <= '0';

         -- Holdoff gives a few cycles for bitslips and delay changes to take effect.
         if holdoff /= 0 then
            holdoff <= holdoff-1;
         end if;

         if error_seen = '1' then
            if sync_countdown(27 downto 24) = x"F" then
               --------------------------------------
               -- Hold off acting on any more errors
               -- while we adjust the delay or bitslip
               --------------------------------------
               holdoff <= (others => '1');

               -------------------------------------------------------------------
               -- And adjust the delay setting (will wrap to 0 when bitslipping)
               -------------------------------------------------------------------
               delay_count_o <= delay_count_o + 1;
               delay_ce_o    <= '1';

               -----------------------
               -- Bitslip if required
               -----------------------
               if delay_count_o = "11111" then
                  bitslip_o <= '1';
               end if;

               -------------------------------------------------------------------
               -- It will need 4M good symbols to avoid adjusting the timing again
               -------------------------------------------------------------------
               sync_countdown(27 downto 24) <= x"4";
            else
               sync_countdown <= sync_countdown + x"100000";   -- add a million if there is a symbol error
            end if;
         else
            -----------------------------------------------
            -- Count down by one, as we are one symbol
            -- closer to having a valid stream
            -----------------------------------------------
            if sync_countdown(27 downto 24) > 0 then
               sync_countdown <= sync_countdown - 1;
            end if;
         end if;

         ------------------------------------
         -- if we have counted down about 3M
         -- symbols without any symbol errors
         -- being seen then we are in sync
         ------------------------------------
         if sync_countdown(27 downto 24) = "0000" then
            symbol_sync_o <= '1';
         end if;
      end if;
   end process;

end architecture synthesis;

