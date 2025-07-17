library ieee;
use ieee.std_logic_1164.all;

entity char_7seg is
    port (
        c : in integer; -- 4-bit input character code
        display : out std_logic_vector(7 downto 0) -- 7-segment output
    );
end char_7seg;

architecture behavior of char_7seg is
begin
    process(c)
    begin
        case c is
            when 0 => display <= "11000000"; -- 0
            when 1 => display <= "11111001"; -- 1
            when 2 => display <= "10100100"; -- 2
            when 3 => display <= "10110000"; -- 3
            when 4 => display <= "10011001"; -- 4
            when 5 => display <= "10010010"; -- 5
            when 6 => display <= "10000010"; -- 6
            when 7 => display <= "11111000"; -- 7
            when 8 => display <= "10000000"; -- 8
            when 9 => display <= "10010000"; -- 9
            when others => display <= "11111111"; -- Default to blank
        end case;
    end process;
end behavior;