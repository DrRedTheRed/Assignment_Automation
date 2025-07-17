library ieee;
use ieee.std_logic_1164.all;

entity char_7seg is
    port (
        c : in std_logic_vector(2 downto 0); -- 3-bit input character code
        display : out std_logic_vector(6 downto 0) -- 7-segment output
    );
end char_7seg;

architecture behavior of char_7seg is
begin
    process(c)
    begin
        case c is
            when "000" => display <= "0001001"; -- H
            when "001" => display <= "0000110"; -- E
            when "010" => display <= "1000111"; -- L
            when "011" => display <= "1000000"; -- O
            when "100" => display <= "1111111"; -- Blank (all segments off)
            when others => display <= "1111111"; -- Default to Blank
        end case;
    end process;
end behavior;
