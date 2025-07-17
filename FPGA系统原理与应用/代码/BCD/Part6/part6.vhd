library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity part6 is
	port(
		sw : in std_logic_vector(15 downto 0);
		hex7, hex6, hex5, hex4, hex2, hex1, hex0 : out std_logic_vector(7 downto 0)
	);
end part6;

architecture behavior of part6 is
	
	signal a, b, c, t, z : integer := 0;
	signal a_1, a_0, b_1, b_0 : integer range 9 downto 0 := 0;
	signal c_2, c_1, c_0, t_1, t_0, z_1, z_0 : integer := 0;
	signal s_0, s_1, s_2 : integer range 9 downto 0 := 0;
	
begin
	process(sw, a, b, c, t, z)
	begin
		a_1 <= to_integer(unsigned(sw(15 downto 12)));
		a_0 <=  to_integer(unsigned(sw(11 downto 8)));
		b_1 <= to_integer(unsigned(sw(7 downto 4)));
		b_0 <= to_integer(unsigned(sw(3 downto 0)));

		-- algorithm given --
		t_0 <= a_0 + b_0;
		if t_0 > 9 then
			z_0 <= 10;
			c_1 <= 1;
		else
			z_0 <= 0;
			c_1 <= 0;
		end if;

		s_0 <= t_0 - z_0;
		t_1 <= a_1 + b_1 + c_1;

		if t_1 > 9 then
			z_1 <= 10;
			c_2 <= 1;
		else
			z_1 <= 0;
			c_2 <= 0;
		end if;

		s_1 <= t_1 - z_1;
		s_2 <= c_2;

		-- a display --
		case a_1 is
			when 0 => hex7 <= "11111111";
			when 1 => hex7 <= "11111001";
			when 2 => hex7 <= "10100100";
			when 3 => hex7 <= "10110000";
			when 4 => hex7 <= "10011001";
			when 5 => hex7 <= "10010010";
			when 6 => hex7 <= "10000010";
			when 7 => hex7 <= "11111000";
			when 8 => hex7 <= "10000000";
			when 9 => hex7 <= "10010000";
		end case;
		
		case a_0 is
			when 0 => hex6 <= "11000000";
			when 1 => hex6 <= "11111001";
			when 2 => hex6 <= "10100100";
			when 3 => hex6 <= "10110000";
			when 4 => hex6 <= "10011001";
			when 5 => hex6 <= "10010010";
			when 6 => hex6 <= "10000010";
			when 7 => hex6 <= "11111000";
			when 8 => hex6 <= "10000000";
			when 9 => hex6 <= "10010000";
		end case;
		
		-- b display --
		
		case b_1 is
			when 0 => hex5 <= "11111111";
			when 1 => hex5 <= "11111001";
			when 2 => hex5 <= "10100100";
			when 3 => hex5 <= "10110000";
			when 4 => hex5 <= "10011001";
			when 5 => hex5 <= "10010010";
			when 6 => hex5 <= "10000010";
			when 7 => hex5 <= "11111000";
			when 8 => hex5 <= "10000000";
			when 9 => hex5 <= "10010000";
		end case;
		
		case b_0 is
			when 0 => hex4 <= "11000000";
			when 1 => hex4 <= "11111001";
			when 2 => hex4 <= "10100100";
			when 3 => hex4 <= "10110000";
			when 4 => hex4 <= "10011001";
			when 5 => hex4 <= "10010010";
			when 6 => hex4 <= "10000010";
			when 7 => hex4 <= "11111000";
			when 8 => hex4 <= "10000000";
			when 9 => hex4 <= "10010000";
		end case;
		
		-- sum display --
		
		case s_2 is
			when 0 => hex2 <= "11111111";
			when 1 => hex2 <= "11111001";
			when 2 => hex2 <= "10100100";
			when 3 => hex2 <= "10110000";
			when 4 => hex2 <= "10011001";
			when 5 => hex2 <= "10010010";
			when 6 => hex2 <= "10000010";
			when 7 => hex2 <= "11111000";
			when 8 => hex2 <= "10000000";
			when 9 => hex2 <= "10010000";
		end case;
		
		case s_1 is
			when 0 => hex1 <= "11000000";
			when 1 => hex1 <= "11111001";
			when 2 => hex1 <= "10100100";
			when 3 => hex1 <= "10110000";
			when 4 => hex1 <= "10011001";
			when 5 => hex1 <= "10010010";
			when 6 => hex1 <= "10000010";
			when 7 => hex1 <= "11111000";
			when 8 => hex1 <= "10000000";
			when 9 => hex1 <= "10010000";
		end case;
		
		case s_0 is
			when 0 => hex0 <= "11000000";
			when 1 => hex0 <= "11111001";
			when 2 => hex0 <= "10100100";
			when 3 => hex0 <= "10110000";
			when 4 => hex0 <= "10011001";
			when 5 => hex0 <= "10010010";
			when 6 => hex0 <= "10000010";
			when 7 => hex0 <= "11111000";
			when 8 => hex0 <= "10000000";
			when 9 => hex0 <= "10010000";
		end case;		
	end process;
end behavior;