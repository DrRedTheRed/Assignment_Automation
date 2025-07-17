library ieee;
use ieee.std_logic_1164.all;

entity char_7seg is
    port (
        c : in std_logic_vector(3 downto 0); -- 4-bit input character code
        display : out std_logic_vector(7 downto 0) -- 7-segment output
    );
end char_7seg;

architecture behavior of char_7seg is
begin
    process(c)
    begin
        case c is
            when "0000" => display <= "11000000"; -- 0
            when "0001" => display <= "11111001"; -- 1
            when "0010" => display <= "10100100"; -- 2
            when "0011" => display <= "10110000"; -- 3
            when "0100" => display <= "10011001"; -- 4
            when "0101" => display <= "10010010"; -- 5
            when "0110" => display <= "10000010"; -- 6
            when "0111" => display <= "11111000"; -- 7
            when "1000" => display <= "10000000"; -- 8
            when "1001" => display <= "10010000"; -- 9
            when others => display <= "11111111"; -- Default to blank
        end case;
    end process;
end behavior;