library ieee;
use ieee.std_logic_1164.all;

entity part4 is
	port(
		iSW : in std_logic_vector(2 downto 0);
		oHEX0_D : out std_logic_vector(6 downto 0)
	);
end part4;

architecture behavior of part4 is
begin
	process(iSW)
	begin
		case iSW is
			when "000"=>oHEX0_D<="0001001";
			when "001"=>oHEX0_D<="0000110";
			when "010"=>oHEX0_D<="1000111";
			when "011"=>oHEX0_D<="1000000";
			when others => oHEX0_D <= "1111111";
		end case;
	end process;
end behavior;