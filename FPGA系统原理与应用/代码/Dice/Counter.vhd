library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Port (
        clk   : in  std_logic; -- Clock signal
        rst   : in  std_logic; -- Reset signal
        roll  : in  std_logic;
        count : out std_logic_vector(2 downto 0);  -- 3-bit output
        cycle : out std_logic
    );
end Counter;

architecture Behavioral of Counter is
    signal count_signal : std_logic_vector(2 downto 0) := "001"; -- Initial value
    signal cycle_signal : std_logic := '0'; -- Signal for cycle output
begin
    process (clk, rst)
        variable count_var : std_logic_vector(2 downto 0) := "001"; -- Internal variable
    begin
        if rst = '1' then
            count_var := "001"; -- Reset to "001" (binary 1)
            cycle_signal <= '0';
        elsif rising_edge(clk) then
            if roll = '1' then
                if count_var = "110" then -- Check if it is "110" (binary 6)
                    count_var := "001"; -- Wrap around to "001" (binary 1)
                    cycle_signal <= '1'; -- New clock to the next counter
                else
                    count_var := std_logic_vector(unsigned(count_var) + 1); -- Increment counter
                    cycle_signal <= '0'; -- Same
                end if;
            end if;
        end if;
        -- Update the signal outputs
        count_signal <= count_var;
    end process;

    -- Assign signals to the output ports
    count <= count_signal;
    cycle <= cycle_signal;

end Behavioral;

