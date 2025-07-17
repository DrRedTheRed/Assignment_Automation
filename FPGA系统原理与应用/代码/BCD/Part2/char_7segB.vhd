library ieee;
use ieee.std_logic_1164.all;

entity char_7segB is
    port (
        c : in std_logic; -- 1-bit input character code
        display : out std_logic_vector(7 downto 0) -- 7-segment output
    );
end char_7segB;

architecture behavior of char_7segB is
begin
    process(c)
    begin
        case c is
            when '0' => display <= "11000000"; -- 0
            when '1' => display <= "11111001"; -- 1
            when others => display <= "11111111"; -- Default to blank
        end case;
    end process;
end behavior;