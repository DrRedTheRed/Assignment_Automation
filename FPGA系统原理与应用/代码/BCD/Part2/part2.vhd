library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity part2 is
    Port (
        sw : in STD_LOGIC_VECTOR(3 downto 0); -- 4-bit binary input
		hex1,hex0 : out STD_LOGIC_VECTOR(7 downto 0)
    );
end part2;

architecture Structural of part2 is
    -- Signals
    signal z          : STD_LOGIC; -- Comparator result
    signal bcd_tens  : STD_LOGIC; -- BCD tens digit
    signal bcd_ones  : STD_LOGIC_VECTOR(3 downto 0);  -- BCD ones digit
    
begin
    -- Instantiate Comparator
    COMP: entity work.Comparator4
        Port Map (
            binary_in => sw,
            z => z
        );

    -- Instantiate Circuit A (Ones)
    CIRCA: entity work.CircuitA4
        Port Map (
            binary_in => sw,
            z => z,
            bcd_ones => bcd_ones
        );

    -- Instantiate Circuit B (Tens)
    CIRCB: entity work.CircuitB4
        Port Map (
            z => z,
            bcd_tens => bcd_tens
        );
        
    HEX_1: entity work.char_7segB
        Port Map (
            c => bcd_tens,
            display => hex1
        );
	
	HEX_0: entity work.char_7seg
	Port Map (
		c => bcd_ones,
		display => hex0
	);

end Structural;
