library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    Port (
        clk : in STD_LOGIC;              -- Clock input
        reset : in STD_LOGIC;           -- Active-low reset
        w : in STD_LOGIC;               -- Input signal
        z : out STD_LOGIC;              -- Output signal
        y : out STD_LOGIC_VECTOR(8 downto 0) -- State outputs for debugging
    );
end FSM;

architecture Behavioral of FSM is
    signal state : STD_LOGIC_VECTOR(8 downto 0) := "000000001"; -- One-hot encoding

begin

    process (clk, reset)
    begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= "000000001"; -- Reset to state A
			else
				-- Logic expressions for state transitions
				state(0) <= '0'; -- State A
				state(1) <= (state(0) and not w) or (state(5) and not w) or (state(6) and not w) or (state(7) and not w) or (state(8) and not w);     -- State B
				state(2) <= (state(1) and not w);                    -- State C
				state(3) <= (state(2) and not w);                    -- State D
				state(4) <= (state(3) and not w) or (state(4) and not w);                    -- State E (z = 1)
				state(5) <= (state(0) and w) or (state(1) and w) or (state(2) and w) or (state(3) and w) or (state(4) and w);                            -- State F
				state(6) <= (state(5) and w);                            -- State G
				state(7) <= (state(6) and w);                            -- State H
				state(8) <= (state(7) and w) or (state(8) and w);                            -- State I (z = 1)
        end if;
    end process;

    -- Assign outputs
    y <= state; -- Debugging output for current state

    -- Output z logic
    z <= state(4) or state(8); -- z = 1 when in state E or I

end Behavioral;
