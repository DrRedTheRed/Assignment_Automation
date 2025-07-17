library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Reactivity is
    Port (
        clk50MHz : in STD_LOGIC;          -- 50 MHz clock input
        reset    : in STD_LOGIC;          -- KEY0: Reset
        stop     : in STD_LOGIC;          -- KEY3: Stop the timer
        SW       : in STD_LOGIC_VECTOR(7 downto 0); -- Set delay time in seconds
        LEDR0    : out STD_LOGIC;         -- Red LED output
        HEX3     : out STD_LOGIC_VECTOR(7 downto 0); -- Display digit 3
        HEX2     : out STD_LOGIC_VECTOR(7 downto 0); -- Display digit 2
        HEX1     : out STD_LOGIC_VECTOR(7 downto 0); -- Display digit 1
        HEX0     : out STD_LOGIC_VECTOR(7 downto 0)  -- Display digit 0
    );
end Reactivity;

architecture Behavioral of Reactivity is
	
	component BCD is
		Port (
			bin : in std_logic_vector(9 downto 0); -- Binary input (0 to 1023)
			hex3, hex2, hex1, hex0 : out STD_LOGIC_VECTOR(7 downto 0) -- 7-segment displays
		);
	end component;
	
	component char_7seg
	    port (
			c : in std_logic_vector(3 downto 0); -- 4-bit input character code
			display : out std_logic_vector(7 downto 0) -- 7-segment output
		);
	end component;
	
    signal clk_1kHz : STD_LOGIC := '0';   -- 1 kHz clock
    signal delay_counter : INTEGER := 0; -- Delay counter (seconds)
    signal reaction_counter : INTEGER := 0; -- Reaction time counter (milliseconds)
    signal led_on : STD_LOGIC := '0';    -- LEDR0 state
    signal counting : STD_LOGIC := '0';  -- Counter state
    signal reaction_bin : std_logic_vector(9 downto 0) := (others=>'0');

    -- Clock Divider: 50 MHz to 1 kHz
    signal clk_divider : INTEGER range 0 to 49_999_999 := 0;

begin

    -- Clock Divider Process
    process (clk50MHz, reset)
    begin
        if reset = '1' then
            clk_divider <= 0;
            clk_1kHz <= '0';
        elsif rising_edge(clk50MHz) then
            if clk_divider = 9 then --if clk_divider = 49_999_999 then
                clk_divider <= 0;
                clk_1kHz <= not clk_1kHz;
            else
                clk_divider <= clk_divider + 1;
            end if;
        end if;
    end process;

    
    process (clk_1kHz, reset, stop)
    begin
		-- Delay Logic Process
        if reset = '1' then
            delay_counter <= 0;
            led_on <= '0';
            counting <= '0';
        elsif rising_edge(clk_1kHz) then
            if delay_counter < to_integer(unsigned(SW)) then --if delay_counter < to_integer(unsigned(SW))*1000
                delay_counter <= delay_counter + 1;
            else
                led_on <= '1'; -- Turn on LEDR0
                counting <= '1'; -- Start reaction timer
            end if;
        end if;
        
        -- Reaction Timer Process
        if reset = '1' then
            reaction_counter <= 0;
        elsif rising_edge(clk_1kHz) then
            if counting = '1' and stop = '0' then
                reaction_counter <= reaction_counter + 1;
            elsif stop = '1' then
                counting <= '0'; -- Stop counting when KEY3 is pressed
            end if;
        end if;
        
    end process;
	
	reaction_bin <= std_logic_vector(to_unsigned(reaction_counter,10));
	
    -- Assign LEDR0
    LEDR0 <= led_on;

    -- BCD Conversion and Display
	BCD_0 : BCD
		port map(bin => reaction_bin,hex3 => HEX3, hex2 => HEX2 , hex1=> HEX1, hex0 => HEX0);

end Behavioral;
