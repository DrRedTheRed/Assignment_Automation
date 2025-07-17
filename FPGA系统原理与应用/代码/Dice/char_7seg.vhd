library ieee;
use ieee.std_logic_1164.all;

entity char_7seg is
    port (
        c : in std_logic_vector(2 downto 0); -- 4-bit input character code
        display : out std_logic_vector(7 downto 0) -- 7-segment output
    );
end char_7seg;

architecture behavior of char_7seg is
begin
    process(c)
    begin
        case c is
            when "000" => display <= "11000000"; -- 0
            when "001" => display <= "11111001"; -- 1
            when "010" => display <= "10100100"; -- 2
            when "011" => display <= "10110000"; -- 3
            when "100" => display <= "10011001"; -- 4
            when "101" => display <= "10010010"; -- 5
            when "110" => display <= "10000010"; -- 6
            when others => display <= "11111111"; -- Default to blank
        end case;
    end process;
end behavior;