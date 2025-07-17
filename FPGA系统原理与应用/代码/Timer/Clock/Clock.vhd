library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- For unsigned arithmetic

entity Clock is
    Port (
        clk50MHz : in STD_LOGIC;           -- 50 MHz clock input
        set    : in STD_LOGIC;           -- Asynchronous reset
        SW       : in STD_LOGIC_VECTOR(15 downto 0); -- Switch inputs for setting time
        HEX7     : out STD_LOGIC_VECTOR(7 downto 0); -- Hour tens digit
        HEX6     : out STD_LOGIC_VECTOR(7 downto 0); -- Hour units digit
        HEX5     : out STD_LOGIC_VECTOR(7 downto 0); -- Minute tens digit
        HEX4     : out STD_LOGIC_VECTOR(7 downto 0); -- Minute units digit
        HEX3     : out STD_LOGIC_VECTOR(7 downto 0); -- Second tens digit
        HEX2     : out STD_LOGIC_VECTOR(7 downto 0)  -- Second units digit
    );
end Clock;

architecture Behavioral of Clock is
	
	component char_7seg
		port (
			c : in std_logic_vector(3 downto 0); -- 4-bit BCD input
			display : out std_logic_vector(7 downto 0) -- 7-segment output
		);
    end component;
    
    component BCD
		Port (
			binary_in : in STD_LOGIC_VECTOR(5 downto 0); -- 6-bit binary input
			hex1,hex0 : out STD_LOGIC_VECTOR(7 downto 0)
		);
	end component;
	
    signal clk_1Hz    : STD_LOGIC := '0';   -- 1 Hz clock signal
    signal counter    : INTEGER range 0 to 49_999_999 := 0; -- Clock divider counter
    signal seconds    : INTEGER range 0 to 59 := 0; -- Seconds counter
    signal minutes    : INTEGER range 0 to 59 := 0; -- Minutes counter
    signal hours      : INTEGER range 0 to 23 := 0; -- Hours counter
	
	signal hours_bi   : std_logic_vector(5 downto 0);
	signal minutes_bi : std_logic_vector(5 downto 0);
	signal seconds_bi : std_logic_vector(5 downto 0);
	
begin

    -- Clock Divider: 50 MHz to 1 Hz
    process (clk50MHz, set)
    begin
        if set = '1' then
            counter <= 0;
            clk_1Hz <= '0';
        elsif rising_edge(clk50MHz) then
            if counter = 9 then --if counter = 49_999_999 then
                counter <= 0;
                clk_1Hz <= not clk_1Hz;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Seconds Counter
    process (clk_1Hz, SW, set)
    begin
        if set = '1' then
            seconds <= 0;
            hours <= to_integer(unsigned(SW(15 downto 12))) * 10 + to_integer(unsigned(SW(11 downto 8)));
			minutes <= to_integer(unsigned(SW(7 downto 4))) * 10 + to_integer(unsigned(SW(3 downto 0)));
        elsif rising_edge(clk_1Hz) then
            if seconds = 59 then
                seconds <= 0;
                if minutes = 59 then
                    minutes <= 0;
                    if hours = 23 then
                        hours <= 0;
                    else
                        hours <= hours + 1;
                    end if;
                else
                    minutes <= minutes + 1;
                end if;
            else
                seconds <= seconds + 1;
            end if;
        end if;
        
    end process;
	
	hours_bi <= std_logic_vector(to_unsigned(hours, 6));
	minutes_bi <= std_logic_vector(to_unsigned(minutes, 6));
	seconds_bi <= std_logic_vector(to_unsigned(seconds, 6));
	
	BCD_hours : BCD
		port map (binary_in => hours_bi, hex1 =>hex7, hex0 => hex6);
		
	BCD_minutes : BCD
		port map (binary_in => minutes_bi, hex1 => hex5, hex0 => hex4);
	
	BCD_seconds : BCD
		port map (binary_in => seconds_bi, hex1 => hex3, hex0 => hex2);

end Behavioral;
