library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD is
    Port (
        binary_in : in STD_LOGIC_VECTOR(5 downto 0); -- 6-bit binary input
		hex1,hex0 : out STD_LOGIC_VECTOR(7 downto 0)
    );
end BCD;

architecture TruthTable of BCD is
	
	-- Component declarations
    component char_7seg
        port (
            c : in std_logic_vector(3 downto 0);   -- 3-bit input for the character
            display : out std_logic_vector(7 downto 0) -- 7-segment output
        );
    end component;
	
	signal bcd_tens : STD_LOGIC_VECTOR(3 downto 0);
	signal bcd_ones  : STD_LOGIC_VECTOR(3 downto 0);
	
begin
    -- Map binary input to BCD tens digit (MSB)
    with binary_in select
        bcd_tens <= 
            "0000" when "000000" | "000001" | "000010" | "000011" |
                       "000100" | "000101" | "000110" | "000111" |
                       "001000" | "001001",
            "0001" when "001010" | "001011" | "001100" | "001101" |
                       "001110" | "001111" | "010000" | "010001" |
                       "010010" | "010011",
            "0010" when "010100" | "010101" | "010110" | "010111" |
                       "011000" | "011001" | "011010" | "011011" |
                       "011100" | "011101" ,
            "0011" when "011110" | "011111" | "100000" | "100001" | 
						"100010" | "100011" | "100100" | "100101" | 
						"100110" | "100111" ,
            "0100" when "101000" | "101001" | "101010" | "101011" |
						"101100" | "101101" | "101110" | "101111" |
						"110000" | "110001" ,
            "0101" when "110010" | "110011" | "110100" | "110101" |
						"110110" | "110111" | "111000" | "111001" |
						"111010" | "111011" ,
            "0110" when "111100" | "111101" | "111110" | "111111",
            "0000" when others;

    -- Map binary input to BCD ones digit (LSB)
    with binary_in select
        bcd_ones <= 
            "0000" when "000000" | "001010" | "010100" | "011110" |
                       "101000" | "110010" | "111100",
            "0001" when "000001" | "001011" | "010101" | "011111" |
                       "101001" | "110011" | "111101",
            "0010" when "000010" | "001100" | "010110" | "100000" |
                       "101010" | "110100" | "111110",
            "0011" when "000011" | "001101" | "010111" | "100001" |
                       "101011" | "110101" | "111111",
            "0100" when "000100" | "001110" | "011000" | "100010" |
                       "101100" | "110110",
            "0101" when "000101" | "001111" | "011001" | "100011" |
                       "101101" | "110111",
            "0110" when "000110" | "010000" | "011010" | "100100" |
                       "101110" | "111000",
            "0111" when "000111" | "010001" | "011011" | "100101" |
                       "101111" | "111001",
            "1000" when "001000" | "010010" | "011100" | "100110" |
                       "110000" | "111010",
            "1001" when "001001" | "010011" | "011101" | "100111" |
                       "110001" | "111011",
            "0000" when others;
    
    Hex_0: char_7seg
        port map (c => bcd_ones, display => hex0);

    Hex_1: char_7seg
        port map (c => bcd_tens, display => hex1);
        
end TruthTable;
