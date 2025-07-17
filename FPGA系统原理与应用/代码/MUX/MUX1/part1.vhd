library ieee;
use ieee.std_logic_1164.all;

entity part1 is
	port(iSW:in std_logic_vector(17 downto 0);
		oLEDR:out std_logic_vector(17 downto 0));
end part1;

architecture behavior of part1 is
begin
	oLEDR <= iSW;
end behavior;