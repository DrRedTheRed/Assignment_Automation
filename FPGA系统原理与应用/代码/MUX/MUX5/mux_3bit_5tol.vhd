library ieee;
use ieee.std_logic_1164.all;

entity mux_3bit_5to1 is
    port (
        s : in std_logic_vector(2 downto 0);        -- select signal
        u, v, w, x, y : in std_logic_vector(2 downto 0); -- 5 inputs
        m : out std_logic_vector(2 downto 0)       -- output
    );
end mux_3bit_5to1;

architecture behavior of mux_3bit_5to1 is
begin
    process(s, u, v, w, x, y)
    begin
        case s is
            when "000" => m <= u;
            when "001" => m <= v;
            when "010" => m <= w;
            when "011" => m <= x;
            when "100" => m <= y;
            when others => m <= (others => '0'); -- Default case
        end case;
    end process;
end behavior;
