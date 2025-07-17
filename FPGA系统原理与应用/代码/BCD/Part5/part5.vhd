library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity part5 is
	port(
		sw : in std_logic_vector(15 downto 0);
		hex7, hex6, hex5, hex4, hex2, hex1, hex0 : out std_logic_vector(7 downto 0)
	);
end part5;

architecture behavior of part5 is
	signal num_one : integer := 0;
	signal num_two : integer := 0;
	signal num_one_tens_digit : integer range 9 downto 0 := 0;
	signal num_one_ones_digit : integer range 9 downto 0 := 0;
	signal num_two_tens_digit : integer range 9 downto 0 := 0;
	signal num_two_ones_digit : integer range 9 downto 0 := 0;
	
	signal sum : integer := 0;
	signal sum_hundreds_digit : integer range 9 downto 0 := 0;
	signal sum_tens_digit : integer range 9 downto 0 := 0;
	signal sum_ones_digit : integer range 9 downto 0 := 0;
	
begin
	hex_0: entity work.char_7seg
		Port Map(
			c => sum_ones_digit,
			display => hex0
		);
	
	hex_1: entity work.char_7seg
		Port Map(
			c => sum_tens_digit,
			display => hex1
		);
		
	hex_2: entity work.char_7seg
		Port Map(
			c => sum_hundreds_digit,
			display => hex2
		);
		
	hex_4: entity work.char_7seg
		Port Map(
			c => num_two_ones_digit,
			display => hex4
		);
		
	hex_5: entity work.char_7seg
	Port Map(
		c => num_two_tens_digit,
		display => hex5
		);
	
	hex_6: entity work.char_7seg
		Port Map(
			c => num_one_ones_digit,
			display => hex6
		);
		
	hex_7: entity work.char_7seg
		Port Map(
			c => num_one_tens_digit,
			display => hex7
		);
	
	process(sw, num_one, num_two, sum)
	begin
		num_one <= to_integer(unsigned(sw(15 downto 12))) * 10 + to_integer(unsigned(sw(11 downto 8)));
		num_two <= to_integer(unsigned(sw(7 downto 4))) * 10 + to_integer(unsigned(sw(3 downto 0)));
		sum <= num_one + num_two;
		
		-- num_one display --
		num_one_tens_digit <= num_one / 10;
		num_one_ones_digit <= num_one mod 10;
		
		
		-- num_two display --
		num_two_tens_digit <= num_two / 10;
		num_two_ones_digit <= num_two mod 10;
		
		
		-- sum display --
		sum_hundreds_digit <= sum / 100;
		sum_tens_digit <= ((sum - 100 * sum_hundreds_digit) - (sum - 100 * sum_hundreds_digit) mod 10) / 10;
		sum_ones_digit <= sum mod 10;

	end process;
end behavior;