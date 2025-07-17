library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CircuitB4 is
    Port (
        z        : in STD_LOGIC; -- Comparator result
        bcd_tens : out STD_LOGIC -- Tens digit
    );
end CircuitB4;

architecture PureLogic of CircuitB4 is
begin
    -- Tens digit logic
    bcd_tens <= z;
end PureLogic;
