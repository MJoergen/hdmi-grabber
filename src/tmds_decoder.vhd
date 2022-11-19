library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tmds_decoder is
   port (
      clk_i              : in  std_logic;
      symbol_i           : in  std_logic_vector(9 downto 0);
      invalid_symbol_o   : out std_logic;
      ctl_valid_o        : out std_logic;
      ctl_o              : out std_logic_vector(1 downto 0);
      terc4_valid_o      : out std_logic;
      terc4_o            : out std_logic_vector(3 downto 0);
      guardband_valid_o  : out std_logic;
      guardband_o        : out std_logic_vector(0 downto 0);
      data_valid_o       : out std_logic;
      data_o             : out std_logic_vector(7 downto 0)
   );
end entity tmds_decoder;

architecture synthesis of tmds_decoder is

   signal lookup : std_logic_vector(8 downto 0);

   attribute mark_debug : boolean;
   attribute mark_debug of lookup        : signal is true;

begin

   lookup_proc :  process(clk_i)
   begin
      if rising_edge(clk_i) then
         -------------------------------------------------------------
         -- convert the incoming signal to something we can decode
         --
         -- for data symbols
         -- ----------------
         -- bit 8    - 1 -- data word flage
         -- bits 7:0 - xxxxxxxx - data value
         --
         -- for ctl symbols
         -- ---------------
         -- bit 8    - 0 - data word flage
         -- bit 7    - 1 - ctl indicator
         -- bits 6:2 - x - ignored
         -- bits 1:0 - xx - ctl value
         --
         -- for invalid symbols
         -- -------------------
         -- bit 8    - 0 - data word flage
         -- bit 7    - 0 - terc4 inicated
         -- bit 6    - 0 - ctl indicator
         -- bit 5    - 0 - guard band indicator
         -- bits 4:0 - x - unused
         --
         -------------------------------------------------------------
         case symbol_i is
            -- dvi-d data sybmols
            -- data 00
            when "1111111111" => lookup <= "100000000";
            when "0100000000" => lookup <= "100000000";
            -- data 01
            when "0111111111" => lookup <= "100000001";
            when "1100000000" => lookup <= "100000001";
            -- data 02
            when "0111111110" => lookup <= "100000010";
            when "1100000001" => lookup <= "100000010";
            -- data 03
            when "1111111110" => lookup <= "100000011";
            when "0100000001" => lookup <= "100000011";
            -- data 04
            when "0111111100" => lookup <= "100000100";
            when "1100000011" => lookup <= "100000100";
            -- data 05
            when "1111111100" => lookup <= "100000101";
            when "0100000011" => lookup <= "100000101";
            -- data 06
            when "1111111101" => lookup <= "100000110";
            when "0100000010" => lookup <= "100000110";
            -- data 07
            when "0111111101" => lookup <= "100000111";
            when "1100000010" => lookup <= "100000111";
            -- data 08
            when "0111111000" => lookup <= "100001000";
            when "1100000111" => lookup <= "100001000";
            -- data 09
            when "1111111000" => lookup <= "100001001";
            when "0100000111" => lookup <= "100001001";
            -- data 0a
            when "1111111001" => lookup <= "100001010";
            when "0100000110" => lookup <= "100001010";
            -- data 0b
            when "0111111001" => lookup <= "100001011";
            when "1100000110" => lookup <= "100001011";
            -- data 0c
            when "1111111011" => lookup <= "100001100";
            when "0100000100" => lookup <= "100001100";
            -- data 0d
            when "0111111011" => lookup <= "100001101";
            when "1100000100" => lookup <= "100001101";
            -- data 0e
            when "0111111010" => lookup <= "100001110";
            when "1100000101" => lookup <= "100001110";
            -- data 0f
            when "1111111010" => lookup <= "100001111";
            when "0100000101" => lookup <= "100001111";
            -- data 10
            when "0111110000" => lookup <= "100010000";
            -- data 11
            when "0100001111" => lookup <= "100010001";
            -- data 12
            when "1111110001" => lookup <= "100010010";
            when "0100001110" => lookup <= "100010010";
            -- data 13
            when "0111110001" => lookup <= "100010011";
            when "1100001110" => lookup <= "100010011";
            -- data 14
            when "1111110011" => lookup <= "100010100";
            when "0100001100" => lookup <= "100010100";
            -- data 15
            when "0111110011" => lookup <= "100010101";
            when "1100001100" => lookup <= "100010101";
            -- data 16
            when "0111110010" => lookup <= "100010110";
            when "1100001101" => lookup <= "100010110";
            -- data 17
            when "1111110010" => lookup <= "100010111";
            when "0100001101" => lookup <= "100010111";
            -- data 18
            when "1111110111" => lookup <= "100011000";
            when "0100001000" => lookup <= "100011000";
            -- data 19
            when "0111110111" => lookup <= "100011001";
            when "1100001000" => lookup <= "100011001";
            -- data 1a
            when "0111110110" => lookup <= "100011010";
            when "1100001001" => lookup <= "100011010";
            -- data 1b
            when "1111110110" => lookup <= "100011011";
            when "0100001001" => lookup <= "100011011";
            -- data 1c
            when "0111110100" => lookup <= "100011100";
            when "1100001011" => lookup <= "100011100";
            -- data 1d
            when "1111110100" => lookup <= "100011101";
            when "0100001011" => lookup <= "100011101";
            -- data 1e
            when "1001011111" => lookup <= "100011110";
            when "0010100000" => lookup <= "100011110";
            -- data 1f
            when "0001011111" => lookup <= "100011111";
            when "1010100000" => lookup <= "100011111";
            -- data 20
            when "1100011111" => lookup <= "100100000";
            when "0111100000" => lookup <= "100100000";
            -- data 21
            when "0100011111" => lookup <= "100100001";
            when "1111100000" => lookup <= "100100001";
            -- data 22
            when "0100011110" => lookup <= "100100010"; -- terc4 0101
            -- data 23
            when "0111100001" => lookup <= "100100011";
            -- data 24
            when "1111100011" => lookup <= "100100100";
            when "0100011100" => lookup <= "100100100";
            -- data 25
            when "0111100011" => lookup <= "100100101";
            when "1100011100" => lookup <= "100100101";
            -- data 26
            when "0111100010" => lookup <= "100100110";
            -- data 27
            when "0100011101" => lookup <= "100100111";
            -- data 28
            when "1111100111" => lookup <= "100101000";
            when "0100011000" => lookup <= "100101000";
            -- data 29
            when "0111100111" => lookup <= "100101001";
            when "1100011000" => lookup <= "100101001";
            -- data 2a
            when "0111100110" => lookup <= "100101010";
            when "1100011001" => lookup <= "100101010";
            -- data 2b
            when "1111100110" => lookup <= "100101011";
            when "0100011001" => lookup <= "100101011";
            -- data 2c
            when "0111100100" => lookup <= "100101100";
            -- data 2d
            when "0100011011" => lookup <= "100101101";
            -- data 2e
            when "1001001111" => lookup <= "100101110";
            when "0010110000" => lookup <= "100101110";
            -- data 2f
            when "0001001111" => lookup <= "100101111";
            when "1010110000" => lookup <= "100101111";
            -- data 30
            when "1111101111" => lookup <= "100110000";
            when "0100010000" => lookup <= "100110000";
            -- data 31
            when "0111101111" => lookup <= "100110001";
            when "1100010000" => lookup <= "100110001";
            -- data 32
            when "0111101110" => lookup <= "100110010";
            when "1100010001" => lookup <= "100110010";
            -- data 33
            when "1111101110" => lookup <= "100110011";
            when "0100010001" => lookup <= "100110011";
            -- data 34
            when "0111101100" => lookup <= "100110100";
            when "1100010011" => lookup <= "100110100";
            -- data 35
            when "1111101100" => lookup <= "100110101";
            when "0100010011" => lookup <= "100110101";
            -- data 36
            when "1001000111" => lookup <= "100110110";
            -- data 37
            when "1010111000" => lookup <= "100110111";
            -- data 38
            when "0111101000" => lookup <= "100111000";
            -- data 39
            when "0100010111" => lookup <= "100111001";
            -- data 3a
            when "0010111100" => lookup <= "100111010";
            when "1001000011" => lookup <= "100111010";
            -- data 3b
            when "1010111100" => lookup <= "100111011";
            when "0001000011" => lookup <= "100111011";
            -- data 3c
            when "0010111110" => lookup <= "100111100";
            when "1001000001" => lookup <= "100111100";
            -- data 3d
            when "1010111110" => lookup <= "100111101";
            when "0001000001" => lookup <= "100111101";
            -- data 3e
            when "1010111111" => lookup <= "100111110";
            when "0001000000" => lookup <= "100111110";
            -- data 3f
            when "0010111111" => lookup <= "100111111";
            when "1001000000" => lookup <= "100111111";
            -- data 40
            when "1100111111" => lookup <= "101000000";
            when "0111000000" => lookup <= "101000000";
            -- data 41
            when "0100111111" => lookup <= "101000001";
            when "1111000000" => lookup <= "101000001";
            -- data 42
            when "0100111110" => lookup <= "101000010";
            when "1111000001" => lookup <= "101000010";
            -- data 43
            when "1100111110" => lookup <= "101000011";
            when "0111000001" => lookup <= "101000011";
            -- data 44
            when "0100111100" => lookup <= "101000100"; -- terc4 0111
            -- data 45
            when "0111000011" => lookup <= "101000101";
            -- data 46
            when "1100111101" => lookup <= "101000110";
            when "0111000010" => lookup <= "101000110";
            -- data 47
            when "0100111101" => lookup <= "101000111";
            when "1111000010" => lookup <= "101000111";
            -- data 48
            when "1111000111" => lookup <= "101001000";
            when "0100111000" => lookup <= "101001000";
            -- data 49
            when "0111000111" => lookup <= "101001001";
            when "1100111000" => lookup <= "101001001";
            -- data 4a
            when "0111000110" => lookup <= "101001010";
            -- data 4b
            when "0100111001" => lookup <= "101001011";  -- terc4 1001
            -- data 4c
            when "1100111011" => lookup <= "101001100";
            when "0111000100" => lookup <= "101001100";
            -- data 4d
            when "0100111011" => lookup <= "101001101";
            when "1111000100" => lookup <= "101001101";
            -- data 4e
            when "1001101111" => lookup <= "101001110";
            when "0010010000" => lookup <= "101001110";
            -- data 4f
            when "0001101111" => lookup <= "101001111";
            when "1010010000" => lookup <= "101001111";
            -- data 50
            when "1111001111" => lookup <= "101010000";
            when "0100110000" => lookup <= "101010000";
            -- data 51
            when "0111001111" => lookup <= "101010001";
            when "1100110000" => lookup <= "101010001";
            -- data 52
            when "0111001110" => lookup <= "101010010";
            when "1100110001" => lookup <= "101010010";
            -- data 53
            when "1111001110" => lookup <= "101010011";
            when "0100110001" => lookup <= "101010011";
            -- data 54
            when "0111001100" => lookup <= "101010100";
            -- data 55
            when "0100110011" => lookup <= "101010101"; -- hdmi guard band (video c1, data c1 & c2)
            -- data 56
            when "1001100111" => lookup <= "101010110";
            when "0010011000" => lookup <= "101010110";
            -- data 57
            when "0001100111" => lookup <= "101010111";
            when "1010011000" => lookup <= "101010111";
            -- data 58
            when "1100110111" => lookup <= "101011000";
            when "0111001000" => lookup <= "101011000";
            -- data 59
            when "0100110111" => lookup <= "101011001";
            when "1111001000" => lookup <= "101011001";
            -- data 5a
            when "1001100011" => lookup <= "101011010"; -- terc4 0001
            -- data 5b
            when "1010011100" => lookup <= "101011011"; -- terc4 0000
            -- data 5c
            when "0010011110" => lookup <= "101011100";
            when "1001100001" => lookup <= "101011100";
            -- data 5d
            when "1010011110" => lookup <= "101011101";
            when "0001100001" => lookup <= "101011101";
            -- data 5e
            when "1010011111" => lookup <= "101011110";
            when "0001100000" => lookup <= "101011110";
            -- data 5f
            when "0010011111" => lookup <= "101011111";
            when "1001100000" => lookup <= "101011111";
            -- data 60
            when "1111011111" => lookup <= "101100000";
            when "0100100000" => lookup <= "101100000";
            -- data 61
            when "0111011111" => lookup <= "101100001";
            when "1100100000" => lookup <= "101100001";
            -- data 62
            when "0111011110" => lookup <= "101100010";
            when "1100100001" => lookup <= "101100010";
            -- data 63
            when "1111011110" => lookup <= "101100011";
            when "0100100001" => lookup <= "101100011";
            -- data 64
            when "0111011100" => lookup <= "101100100";
            when "1100100011" => lookup <= "101100100";
            -- data 65
            when "1111011100" => lookup <= "101100101";
            when "0100100011" => lookup <= "101100101";
            -- data 66
            when "1001110111" => lookup <= "101100110";
            when "0010001000" => lookup <= "101100110";
            -- data 67
            when "0001110111" => lookup <= "101100111";
            when "1010001000" => lookup <= "101100111";
            -- data 68
            when "0111011000" => lookup <= "101101000";
            -- data 69
            when "0100100111" => lookup <= "101101001";
            -- data 6a
            when "1001110011" => lookup <= "101101010";
            when "0010001100" => lookup <= "101101010";
            -- data 6b
            when "0001110011" => lookup <= "101101011";
            when "1010001100" => lookup <= "101101011";
            -- data 6c
            when "1001110001" => lookup <= "101101100"; -- terc4 1101
            -- data 6d
            when "1010001110" => lookup <= "101101101"; -- terc4 1100
            -- data 6e
            when "1010001111" => lookup <= "101101110";
            when "0001110000" => lookup <= "101101110";
            -- data 6f
            when "0010001111" => lookup <= "101101111";
            when "1001110000" => lookup <= "101101111";
            -- data 70
            when "1100101111" => lookup <= "101110000";
            when "0111010000" => lookup <= "101110000";
            -- data 71
            when "0100101111" => lookup <= "101110001";
            when "1111010000" => lookup <= "101110001";
            -- data 72
            when "1001111011" => lookup <= "101110010";
            when "0010000100" => lookup <= "101110010";
            -- data 73
            when "0001111011" => lookup <= "101110011";
            when "1010000100" => lookup <= "101110011";
            -- data 74
            when "1001111001" => lookup <= "101110100";
            when "0010000110" => lookup <= "101110100";
            -- data 75
            when "0001111001" => lookup <= "101110101";
            when "1010000110" => lookup <= "101110101";
            -- data 76
            when "1010000111" => lookup <= "101110110";
            -- data 77
            when "1001111000" => lookup <= "101110111";
            -- data 78
            when "1001111101" => lookup <= "101111000";
            when "0010000010" => lookup <= "101111000";
            -- data 79
            when "0001111101" => lookup <= "101111001";
            when "1010000010" => lookup <= "101111001";
            -- data 7a
            when "0001111100" => lookup <= "101111010";
            when "1010000011" => lookup <= "101111010";
            -- data 7b
            when "1001111100" => lookup <= "101111011";
            when "0010000011" => lookup <= "101111011";
            -- data 7c
            when "0001111110" => lookup <= "101111100";
            when "1010000001" => lookup <= "101111100";
            -- data 7d
            when "1001111110" => lookup <= "101111101";
            when "0010000001" => lookup <= "101111101";
            -- data 7e
            when "1001111111" => lookup <= "101111110";
            when "0010000000" => lookup <= "101111110";
            -- data 7f
            when "0001111111" => lookup <= "101111111";
            when "1010000000" => lookup <= "101111111";
            -- data 80
            when "1101111111" => lookup <= "110000000";
            when "0110000000" => lookup <= "110000000";
            -- data 81
            when "0101111111" => lookup <= "110000001";
            when "1110000000" => lookup <= "110000001";
            -- data 82
            when "0101111110" => lookup <= "110000010";
            when "1110000001" => lookup <= "110000010";
            -- data 83
            when "1101111110" => lookup <= "110000011";
            when "0110000001" => lookup <= "110000011";
            -- data 84
            when "0101111100" => lookup <= "110000100";
            when "1110000011" => lookup <= "110000100";
            -- data 85
            when "1101111100" => lookup <= "110000101";
            when "0110000011" => lookup <= "110000101";
            -- data 86
            when "1101111101" => lookup <= "110000110";
            when "0110000010" => lookup <= "110000110";
            -- data 87
            when "0101111101" => lookup <= "110000111";
            when "1110000010" => lookup <= "110000111";
            -- data 88
            when "0101111000" => lookup <= "110001000";
            -- data 89
            when "0110000111" => lookup <= "110001001";
            -- data 8a
            when "1101111001" => lookup <= "110001010";
            when "0110000110" => lookup <= "110001010";
            -- data 8b
            when "0101111001" => lookup <= "110001011";
            when "1110000110" => lookup <= "110001011";
            -- data 8c
            when "1101111011" => lookup <= "110001100";
            when "0110000100" => lookup <= "110001100";
            -- data 8d
            when "0101111011" => lookup <= "110001101";
            when "1110000100" => lookup <= "110001101";
            -- data 8e
            when "1000101111" => lookup <= "110001110";
            when "0011010000" => lookup <= "110001110";
            -- data 8f
            when "0000101111" => lookup <= "110001111";
            when "1011010000" => lookup <= "110001111";
            -- data 90
            when "1110001111" => lookup <= "110010000";
            when "0101110000" => lookup <= "110010000";
            -- data 91
            when "0110001111" => lookup <= "110010001";
            when "1101110000" => lookup <= "110010001";
            -- data 92
            when "0110001110" => lookup <= "110010010"; -- terc4 0110
            -- data 93
            when "0101110001" => lookup <= "110010011"; -- terc4 0100
            -- data 94
            when "1101110011" => lookup <= "110010100";
            when "0110001100" => lookup <= "110010100";
            -- data 95
            when "0101110011" => lookup <= "110010101";
            when "1110001100" => lookup <= "110010101";
            -- data 96
            when "1000100111" => lookup <= "110010110";
            -- data 97
            when "1011011000" => lookup <= "110010111";
            -- data 98
            when "1101110111" => lookup <= "110011000";
            when "0110001000" => lookup <= "110011000";
            -- data 99
            when "0101110111" => lookup <= "110011001";
            when "1110001000" => lookup <= "110011001";
            -- data 9a
            when "0011011100" => lookup <= "110011010";
            when "1000100011" => lookup <= "110011010";
            -- data 9b
            when "1011011100" => lookup <= "110011011";
            when "0000100011" => lookup <= "110011011";
            -- data 9c
            when "0011011110" => lookup <= "110011100";
            when "1000100001" => lookup <= "110011100";
            -- data 9d
            when "1011011110" => lookup <= "110011101";
            when "0000100001" => lookup <= "110011101";
            -- data 9e
            when "1011011111" => lookup <= "110011110";
            when "0000100000" => lookup <= "110011110";
            -- data 9f
            when "0011011111" => lookup <= "110011111";
            when "1000100000" => lookup <= "110011111";
            -- data a0
            when "1110011111" => lookup <= "110100000";
            when "0101100000" => lookup <= "110100000";
            -- data a1
            when "0110011111" => lookup <= "110100001";
            when "1101100000" => lookup <= "110100001";
            -- data a2
            when "0110011110" => lookup <= "110100010";
            when "1101100001" => lookup <= "110100010";
            -- data a3
            when "1110011110" => lookup <= "110100011";
            when "0101100001" => lookup <= "110100011";
            -- data a4
            when "0110011100" => lookup <= "110100100"; -- terc4 1010
            -- data a5
            when "0101100011" => lookup <= "110100101"; -- terc4 1110
            -- data a6
            when "1000110111" => lookup <= "110100110";
            when "0011001000" => lookup <= "110100110";
            -- data a7
            when "0000110111" => lookup <= "110100111";
            when "1011001000" => lookup <= "110100111";
            -- data a8
            when "1101100111" => lookup <= "110101000";
            when "0110011000" => lookup <= "110101000";
            -- data a9
            when "0101100111" => lookup <= "110101001";
            when "1110011000" => lookup <= "110101001";
            -- data aa
            when "1000110011" => lookup <= "110101010";
            -- data ab
            when "1011001100" => lookup <= "110101011"; -- terc4 1000 & hdmi guard band (video c0 and video c2)
            -- data ac
            when "0011001110" => lookup <= "110101100";
            when "1000110001" => lookup <= "110101100";
            -- data ad
            when "1011001110" => lookup <= "110101101";
            when "0000110001" => lookup <= "110101101";
            -- data ae
            when "1011001111" => lookup <= "110101110";
            when "0000110000" => lookup <= "110101110";
            -- data af
            when "0011001111" => lookup <= "110101111";
            when "1000110000" => lookup <= "110101111";
            -- data b0
            when "1101101111" => lookup <= "110110000";
            when "0110010000" => lookup <= "110110000";
            -- data b1
            when "0101101111" => lookup <= "110110001";
            when "1110010000" => lookup <= "110110001";
            -- data b2
            when "1000111011" => lookup <= "110110010";
            when "0011000100" => lookup <= "110110010";
            -- data b3
            when "0000111011" => lookup <= "110110011";
            when "1011000100" => lookup <= "110110011";
            -- data b4
            when "1000111001" => lookup <= "110110100";
            -- data b5
            when "1011000110" => lookup <= "110110101"; -- terc4 1011
            -- data b6
            when "1011000111" => lookup <= "110110110";
            when "0000111000" => lookup <= "110110110";
            -- data b7
            when "0011000111" => lookup <= "110110111";
            when "1000111000" => lookup <= "110110111";
            -- data b8
            when "1000111101" => lookup <= "110111000";
            when "0011000010" => lookup <= "110111000";
            -- data b9
            when "0000111101" => lookup <= "110111001";
            when "1011000010" => lookup <= "110111001";
            -- data ba
            when "1011000011" => lookup <= "110111010"; -- terc4 1111
            -- data bb
            when "1000111100" => lookup <= "110111011";
            -- data bc
            when "0000111110" => lookup <= "110111100";
            when "1011000001" => lookup <= "110111100";
            -- data bd
            when "1000111110" => lookup <= "110111101";
            when "0011000001" => lookup <= "110111101";
            -- data be
            when "1000111111" => lookup <= "110111110";
            when "0011000000" => lookup <= "110111110";
            -- data bf
            when "0000111111" => lookup <= "110111111";
            when "1011000000" => lookup <= "110111111";
            -- data c0
            when "1110111111" => lookup <= "111000000";
            when "0101000000" => lookup <= "111000000";
            -- data c1
            when "0110111111" => lookup <= "111000001";
            when "1101000000" => lookup <= "111000001";
            -- data c2
            when "0110111110" => lookup <= "111000010";
            when "1101000001" => lookup <= "111000010";
            -- data c3
            when "1110111110" => lookup <= "111000011";
            when "0101000001" => lookup <= "111000011";
            -- data c4
            when "0110111100" => lookup <= "111000100";
            when "1101000011" => lookup <= "111000100";
            -- data c5
            when "1110111100" => lookup <= "111000101";
            when "0101000011" => lookup <= "111000101";
            -- data c6
            when "1000010111" => lookup <= "111000110";
            -- data c7
            when "1011101000" => lookup <= "111000111";
            -- data c8
            when "0110111000" => lookup <= "111001000";
            -- data c9
            when "0101000111" => lookup <= "111001001";
            -- data ca
            when "0011101100" => lookup <= "111001010";
            when "1000010011" => lookup <= "111001010";
            -- data cb
            when "1011101100" => lookup <= "111001011";
            when "0000010011" => lookup <= "111001011";
            -- data cc
            when "0011101110" => lookup <= "111001100";
            when "1000010001" => lookup <= "111001100";
            -- data cd
            when "1011101110" => lookup <= "111001101";
            when "0000010001" => lookup <= "111001101";
            -- data ce
            when "1011101111" => lookup <= "111001110";
            when "0000010000" => lookup <= "111001110";
            -- data cf
            when "0011101111" => lookup <= "111001111";
            when "1000010000" => lookup <= "111001111";
            -- data d0
            when "1101001111" => lookup <= "111010000";
            when "0110110000" => lookup <= "111010000";
            -- data d1
            when "0101001111" => lookup <= "111010001";
            when "1110110000" => lookup <= "111010001";
            -- data d2
            when "1000011011" => lookup <= "111010010";
            -- data d3
            when "1011100100" => lookup <= "111010011"; -- terc4 0010
            -- data d4
            when "0011100110" => lookup <= "111010100";
            when "1000011001" => lookup <= "111010100";
            -- data d5
            when "1011100110" => lookup <= "111010101";
            when "0000011001" => lookup <= "111010101";
            -- data d6
            when "1011100111" => lookup <= "111010110";
            when "0000011000" => lookup <= "111010110";
            -- data d7
            when "0011100111" => lookup <= "111010111";
            when "1000011000" => lookup <= "111010111";
            -- data d8
            when "1000011101" => lookup <= "111011000";
            -- data d9
            when "1011100010" => lookup <= "111011001"; -- terc4 0011
            -- data da
            when "1011100011" => lookup <= "111011010";
            when "0000011100" => lookup <= "111011010";
            -- data db
            when "0011100011" => lookup <= "111011011";
            when "1000011100" => lookup <= "111011011";
            -- data dc
            when "1011100001" => lookup <= "111011100";
            -- data dd
            when "1000011110" => lookup <= "111011101";
            -- data de
            when "1000011111" => lookup <= "111011110";
            when "0011100000" => lookup <= "111011110";
            -- data df
            when "0000011111" => lookup <= "111011111";
            when "1011100000" => lookup <= "111011111";
            -- data e0
            when "1101011111" => lookup <= "111100000";
            when "0110100000" => lookup <= "111100000";
            -- data e1
            when "0101011111" => lookup <= "111100001";
            when "1110100000" => lookup <= "111100001";
            -- data e2
            when "0011110100" => lookup <= "111100010";
            when "1000001011" => lookup <= "111100010";
            -- data e3
            when "1011110100" => lookup <= "111100011";
            when "0000001011" => lookup <= "111100011";
            -- data e4
            when "0011110110" => lookup <= "111100100";
            when "1000001001" => lookup <= "111100100";
            -- data e5
            when "1011110110" => lookup <= "111100101";
            when "0000001001" => lookup <= "111100101";
            -- data e6
            when "1011110111" => lookup <= "111100110";
            when "0000001000" => lookup <= "111100110";
            -- data e7
            when "0011110111" => lookup <= "111100111";
            when "1000001000" => lookup <= "111100111";
            -- data e8
            when "0011110010" => lookup <= "111101000";
            when "1000001101" => lookup <= "111101000";
            -- data e9
            when "1011110010" => lookup <= "111101001";
            when "0000001101" => lookup <= "111101001";
            -- data ea
            when "1011110011" => lookup <= "111101010";
            when "0000001100" => lookup <= "111101010";
            -- data eb
            when "0011110011" => lookup <= "111101011";
            when "1000001100" => lookup <= "111101011";
            -- data ec
            when "1011110001" => lookup <= "111101100";
            when "0000001110" => lookup <= "111101100";
            -- data ed
            when "0011110001" => lookup <= "111101101";
            when "1000001110" => lookup <= "111101101";
            -- data ee
            when "1000001111" => lookup <= "111101110";
            -- data ef
            when "1011110000" => lookup <= "111101111";
            -- data f0
            when "0011111010" => lookup <= "111110000";
            when "1000000101" => lookup <= "111110000";
            -- data f1
            when "1011111010" => lookup <= "111110001";
            when "0000000101" => lookup <= "111110001";
            -- data f2
            when "1011111011" => lookup <= "111110010";
            when "0000000100" => lookup <= "111110010";
            -- data f3
            when "0011111011" => lookup <= "111110011";
            when "1000000100" => lookup <= "111110011";
            -- data f4
            when "1011111001" => lookup <= "111110100";
            when "0000000110" => lookup <= "111110100";
            -- data f5
            when "0011111001" => lookup <= "111110101";
            when "1000000110" => lookup <= "111110101";
            -- data f6
            when "0011111000" => lookup <= "111110110";
            when "1000000111" => lookup <= "111110110";
            -- data f7
            when "1011111000" => lookup <= "111110111";
            when "0000000111" => lookup <= "111110111";
            -- data f8
            when "1011111101" => lookup <= "111111000";
            when "0000000010" => lookup <= "111111000";
            -- data f9
            when "0011111101" => lookup <= "111111001";
            when "1000000010" => lookup <= "111111001";
            -- data fa
            when "0011111100" => lookup <= "111111010";
            when "1000000011" => lookup <= "111111010";
            -- data fb
            when "1011111100" => lookup <= "111111011";
            when "0000000011" => lookup <= "111111011";
            -- data fc
            when "0011111110" => lookup <= "111111100";
            when "1000000001" => lookup <= "111111100";
            -- data fd
            when "1011111110" => lookup <= "111111101";
            when "0000000001" => lookup <= "111111101";
            -- data fe
            when "1011111111" => lookup <= "111111110";
            when "0000000000" => lookup <= "111111110";
            -- data ff
            when "0011111111" => lookup <= "111111111";
            when "1000000000" => lookup <= "111111111";

            -- dvi-d ctl symbols
            when "0010101011" => lookup <= "01" & "00000" &  "01";  -- ctl1
            when "0101010100" => lookup <= "01" & "00000" &  "10";  -- ctl2
            when "1010101011" => lookup <= "01" & "00000" &  "11";  -- ctl3
            when "1101010100" => lookup <= "01" & "00000" &  "00";  -- ctl0

            -- invalid symbols
            when others       => lookup <= "0000" & "00000";
         end case;
      end if;
   end process lookup_proc;


   decode_proc :  process(clk_i)
   begin
      if rising_edge(clk_i) then
         ------------------
         -- tmds data bytes
         if lookup(8) = '1' then
            data_valid_o <= '1';
            data_o       <= lookup(7 downto 0);
         else
            data_valid_o <= '0';
         end if;

            ------------
            -- ctl codes
         if lookup(8 downto 7) = "01" then
            ctl_valid_o <= '1';
            ctl_o       <= lookup(1 downto 0);
         else
            ctl_valid_o <= '0';
         end if;

            ------------------------------
            -- all other codes are invalid
            ------------------------------
         if lookup(8 downto 7) = "00" then
            invalid_symbol_o <= '1';
         else
            invalid_symbol_o <= '0';
         end if;

         terc4_valid_o     <= '0';
         guardband_valid_o <= '0';
         if lookup(8) = '1' then
                -------------------------
                -- decode the guard bands
                -------------------------
            case lookup(7 downto 0) is
               when x"55"  => guardband_valid_o <= '1'; guardband_o <= "0";
               when x"ab"  => guardband_valid_o <= '1'; guardband_o <= "1";
               when others => null;
            end case;

                -------------------------
                -- decode terc4 data
                -------------------------
            case lookup(7 downto 0) is
               when x"5b"  => terc4_valid_o <= '1'; terc4_o <= "0000";-- "1010011100" terc4 0000
               when x"5a"  => terc4_valid_o <= '1'; terc4_o <= "0001"; -- "1001100011" terc4 0001
               when x"d3"  => terc4_valid_o <= '1'; terc4_o <= "0010"; -- "1011100100" terc4 0010
               when x"d9"  => terc4_valid_o <= '1'; terc4_o <= "0011"; -- "1011100010" terc4 0011
               when x"93"  => terc4_valid_o <= '1'; terc4_o <= "0100"; -- "0101110001" terc4 0100
               when x"22"  => terc4_valid_o <= '1'; terc4_o <= "0101"; -- "0100011110" terc4 0101
               when x"92"  => terc4_valid_o <= '1'; terc4_o <= "0110"; -- "0110001110" terc4 0110
               when x"44"  => terc4_valid_o <= '1'; terc4_o <= "0111"; -- "0100111100" terc4 0111
               when x"ab"  => terc4_valid_o <= '1'; terc4_o <= "1000"; -- "1011001100" terc4 1000 & hdmi guard band (video c0 and video c2)
               when x"4b"  => terc4_valid_o <= '1'; terc4_o <= "1001"; -- "0100111001" terc4 1001
               when x"a4"  => terc4_valid_o <= '1'; terc4_o <= "1010"; -- "0110011100" terc4 1010
               when x"b5"  => terc4_valid_o <= '1'; terc4_o <= "1011"; -- "1011000110" terc4 1011
               when x"6d"  => terc4_valid_o <= '1'; terc4_o <= "1100"; -- "1010001110" terc4 1100
               when x"6c"  => terc4_valid_o <= '1'; terc4_o <= "1101"; -- "1001110001" terc4 1101
               when x"a5"  => terc4_valid_o <= '1'; terc4_o <= "1110"; -- "0101100011" terc4 1110
               when x"ba"  => terc4_valid_o <= '1'; terc4_o <= "1111"; -- "1011000011" terc4 1111
               when others => null;
            end case;
         end if;
      end if;
   end process decode_proc;

end architecture synthesis;

-- for guard band and terc4 decoding (to be done later!)
-- when x"55" => -- "0100110011" hdmi guard band (video c1, data c1 & c2)
-- when x"5b" => -- "1010011100" terc4 0000
-- when x"5a" => -- "1001100011" terc4 0001
-- when x"d3" => -- "1011100100" terc4 0010
-- when x"d9" => -- "1011100010" terc4 0011
-- when x"93" => -- "0101110001" terc4 0100
-- when x"22" => -- "0100011110" terc4 0101
-- when x"92" => -- "0110001110" terc4 0110
-- when x"44" => -- "0100111100" terc4 0111
-- when x"ab" => -- "1011001100" terc4 1000 & hdmi guard band (video c0 and video c2)
-- when x"4b" => -- "0100111001" terc4 1001
-- when x"a4" => -- "0110011100" terc4 1010
-- when x"b5" => -- "1011000110" terc4 1011
-- when x"6d" => -- "1010001110" terc4 1100
-- when x"6c" => -- "1001110001" terc4 1101
-- when x"a5" => -- "0101100011" terc4 1110
-- when x"ba" => -- "1011000011" terc4 1111

