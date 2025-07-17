library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TestLogic is
    Port ( 
        Sum     : in std_logic_vector(3 downto 0); -- Sum of the two dice
        D7      : out STD_LOGIC;
        D711    : out STD_LOGIC;
        D2312   : out STD_LOGIC
    );
end TestLogic;

architecture Behavioral of TestLogic is
begin
    PROCESS(Sum)
    BEGIN
        -- Default outputs
        D7    <= '0';
        D711  <= '0';
        D2312 <= '0';

        CASE Sum IS
            WHEN "0111" =>
                D7    <= '1';
                D711  <= '1';
            WHEN "1011" =>
                D711  <= '1';
            WHEN "0010" | "0011" | "1100" =>
                D2312 <= '1';
            WHEN OTHERS =>
                -- Do nothing, all signals remain '0'
                NULL;
        END CASE;
    END PROCESS;
end Behavioral;
