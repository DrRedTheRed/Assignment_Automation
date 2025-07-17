library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- For unsigned arithmetic

entity BCD is
    Port (
        bin : in std_logic_vector(9 downto 0); -- Binary input (0 to 1023)
        hex3, hex2, hex1, hex0 : out STD_LOGIC_VECTOR(7 downto 0) -- 7-segment displays
    );
end BCD;

architecture Behavioral of BCD is

    -- Component declaration for 7-segment decoder
    component char_7seg
        port (
            c : in std_logic_vector(3 downto 0); -- 4-bit BCD input
            display : out std_logic_vector(7 downto 0) -- 7-segment output
        );
    end component;

    -- BCD representation signals
    signal bcd_thousands : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_hundreds  : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_tens      : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_ones      : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- Binary-to-BCD conversion using Double-Dabble algorithm
    process(bin)
        variable bcd : unsigned(15 downto 0); -- BCD representation (4 digits)
        variable binary : unsigned(9 downto 0); -- Local binary variable
    begin
        -- Initialize BCD and load the binary value
        bcd := (others => '0');
        binary := unsigned(bin);

        -- Double-Dabble algorithm
        for i in 9 downto 0 loop
            -- Adjust digits if they are >= 5
            if bcd(15 downto 12) >= "0101" then
                bcd(15 downto 12) := bcd(15 downto 12) + 3;
            end if;
            if bcd(11 downto 8) >= "0101" then
                bcd(11 downto 8) := bcd(11 downto 8) + 3;
            end if;
            if bcd(7 downto 4) >= "0101" then
                bcd(7 downto 4) := bcd(7 downto 4) + 3;
            end if;
            if bcd(3 downto 0) >= "0101" then
                bcd(3 downto 0) := bcd(3 downto 0) + 3;
            end if;

            -- Shift left BCD and binary by 1 bit
            bcd := bcd(14 downto 0) & binary(9);
            binary := binary(8 downto 0) & '0';
        end loop;

        -- Assign BCD digits to output signals
        bcd_thousands <= std_logic_vector(bcd(15 downto 12));
        bcd_hundreds  <= std_logic_vector(bcd(11 downto 8));
        bcd_tens      <= std_logic_vector(bcd(7 downto 4));
        bcd_ones      <= std_logic_vector(bcd(3 downto 0));
    end process;

    -- Instantiate 7-segment decoders
    Hex_3: char_7seg
        port map (c => bcd_thousands, display => hex3);

    Hex_2: char_7seg
        port map (c => bcd_hundreds, display => hex2);

    Hex_1: char_7seg
        port map (c => bcd_tens, display => hex1);

    Hex_0: char_7seg
        port map (c => bcd_ones, display => hex0);

end Behavioral;
