library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Comparator4 is
    Port (
        binary_in : in STD_LOGIC_VECTOR(3 downto 0); -- 4-bit binary input
        z         : out STD_LOGIC -- High if binary_in >= 10
    );
end Comparator4;

architecture PureLogic of Comparator4 is
begin
    -- z = 1 when binary_in >= 10
    z <= binary_in(3) and (binary_in(2) or binary_in(1));
end PureLogic;
