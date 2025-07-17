library ieee;
use ieee.std_logic_1164.all;

entity part2 is
    port (
        iSW   : in std_logic_vector(17 downto 0);  -- Switches SW17-SW0
        oLEDR : out std_logic_vector(17 downto 0);  -- Output to LEDR
        oLEDG : out std_logic_vector(7 downto 0)    -- Output to LEDG
    );
end part2;

architecture behaviour of part2 is
begin
    -- 2-to-1 multiplexer logic using variables for immediate update
    process(iSW)  -- Sensitivity list includes only iSW since we're using variables
        variable X : std_logic_vector(7 downto 0);  -- Local variable for X (SW7-SW0)
        variable Y : std_logic_vector(7 downto 0);  -- Local variable for Y (SW15-SW8)
        variable s : std_logic;  -- Local variable for select input (SW17)
        variable M_var : std_logic_vector(7 downto 0);  -- Variable for immediate update of M
    begin
        -- Assign values from switches to variables (no signal assignment)
        X := iSW(7 downto 0);    -- SW7-0 for X input
        Y := iSW(15 downto 8);   -- SW15-8 for Y input
        s := iSW(17);            -- SW17 for select input

        -- Perform immediate assignment to M_var based on the select input
        if (s = '0') then
            M_var := X;  -- Select X if s = 0
        else
            M_var := Y;  -- Select Y if s = 1
        end if;

        -- Assign the value of the variable M_var directly to the output signal
        oLEDG(7 downto 0) <= M_var;  -- Output to LEDG (green LEDs)

        -- Output to LEDR (red LEDs) showing the state of all switches
        oLEDR(17 downto 0) <= iSW(17 downto 0);  -- Red LEDs reflecting the switch input values
    end process;

end behaviour;
