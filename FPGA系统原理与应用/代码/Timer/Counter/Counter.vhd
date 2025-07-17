library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- For unsigned arithmetic

entity Counter is
    Port (
        clk : in STD_LOGIC; -- Clock signal
        rst : in STD_LOGIC; -- Reset signal
        hex2, hex1, hex0 : out STD_LOGIC_VECTOR(7 downto 0) -- 7-segment displays
    );
end Counter;

architecture Behavioral of Counter is
    -- Component declaration for 7-segment decoder
    component char_7seg
        port (
            c : in std_logic_vector(3 downto 0); -- 4-bit BCD input
            display : out std_logic_vector(7 downto 0) -- 7-segment output
        );
    end component;

    -- Signals for the counter and BCD representation
    signal counter : unsigned(9 downto 0) := "0000000000"; -- 10-bit counter for 0 to 999
    signal bcd_hundreds : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_tens : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_ones : STD_LOGIC_VECTOR(3 downto 0);
    signal clock_divider : integer := 0;
    signal slow_clock : STD_LOGIC;

begin
	process (clk,rst)
    begin
		if rst = '1' then
			clock_divider <= 0;
        elsif rising_edge(clk) then
            if clock_divider = 10 - 1 then -- Board frequency 50MHz, this is a faster version for waveform simulation convenience
                slow_clock <= not slow_clock;
                clock_divider <= 0;
            else
                clock_divider <= clock_divider + 1;
            end if;
        end if;
    end process;
    
    -- Process for the counter with clock and reset
    process(slow_clock, rst)
    begin
        if rst = '1' then
            counter <= (others => '0'); -- Reset counter to 0
        elsif rising_edge(slow_clock) then
            if counter = 999 then
                counter <= (others => '0'); -- Wrap around after 999
            else
                counter <= counter + 1; -- Increment counter
            end if;
        end if;
    end process;

    -- Binary-to-BCD conversion using Double-Dabble
    process(counter)
        variable bin : unsigned(9 downto 0); -- Binary input as unsigned
        variable bcd : unsigned(11 downto 0); -- BCD representation (3 digits)
    begin
        -- Initialize variables
        bin := counter;
        bcd := (others => '0');

        -- Shift and adjust algorithm
        for i in 9 downto 0 loop
            -- Adjust BCD digits if >= 5
            if bcd(11 downto 8) >= "0101" then
                bcd(11 downto 8) := bcd(11 downto 8) + 3;
            end if;
            if bcd(7 downto 4) >= "0101" then
                bcd(7 downto 4) := bcd(7 downto 4) + 3;
            end if;
            if bcd(3 downto 0) >= "0101" then
                bcd(3 downto 0) := bcd(3 downto 0) + 3;
            end if;

            -- Shift BCD and binary left by 1 bit
            bcd := bcd(10 downto 0) & bin(9);
            bin := bin(8 downto 0) & '0';
        end loop;

        -- Assign BCD digits to output signals
        bcd_hundreds <= std_logic_vector(bcd(11 downto 8));
        bcd_tens <= std_logic_vector(bcd(7 downto 4));
        bcd_ones <= std_logic_vector(bcd(3 downto 0));
    end process;

    -- Instantiate 7-segment decoders
    Hex_2: char_7seg
        port map (c => bcd_hundreds, display => hex2);

    Hex_1: char_7seg
        port map (c => bcd_tens, display => hex1);

    Hex_0: char_7seg
        port map (c => bcd_ones, display => hex0);

end Behavioral;


