library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CircuitA4 is
    Port (
        binary_in : in STD_LOGIC_VECTOR(3 downto 0); -- 4-bit binary input
        z         : in STD_LOGIC; -- Comparator result (1 if tens digit is 1)
        bcd_ones  : out STD_LOGIC_VECTOR(3 downto 0) -- Adjusted BCD ones digit
    );
end CircuitA4;

architecture PureLogic of CircuitA4 is
    signal subtract_10 : STD_LOGIC_VECTOR(3 downto 0) := "1001"; -- Binary 9
    signal result      : STD_LOGIC_VECTOR(3 downto 0); -- Result after subtraction
    signal borrow      : STD_LOGIC_VECTOR(4 downto 0); -- Borrow propagation
begin
    -- Borrow propagation and subtraction
    borrow(0) <= z; -- Borrow starts only when z = 1
    result(0) <= binary_in(0) xor subtract_10(0) xor borrow(0);
    borrow(1) <= (not binary_in(0) and subtract_10(0)) or 
                 (not binary_in(0) and borrow(0)) or 
                 (subtract_10(0) and borrow(0));

    result(1) <= binary_in(1) xor subtract_10(1) xor borrow(1);
    borrow(2) <= (not binary_in(1) and subtract_10(1)) or 
                 (not binary_in(1) and borrow(1)) or 
                 (subtract_10(1) and borrow(1));

    result(2) <= binary_in(2) xor subtract_10(2) xor borrow(2);
    borrow(3) <= (not binary_in(2) and subtract_10(2)) or 
                 (not binary_in(2) and borrow(2)) or 
                 (subtract_10(2) and borrow(2));

    result(3) <= binary_in(3) xor subtract_10(3) xor borrow(3);

    -- MUX to select adjusted or unadjusted value
    bcd_ones(0) <= (not z and binary_in(0)) or (z and result(0));
    bcd_ones(1) <= (not z and binary_in(1)) or (z and result(1));
    bcd_ones(2) <= (not z and binary_in(2)) or (z and result(2));
    bcd_ones(3) <= (not z and binary_in(3)) or (z and result(3));
end PureLogic;
