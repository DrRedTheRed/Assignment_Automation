library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control is
    Port ( 
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        Rb      : in  STD_LOGIC; -- Roll button
        D7      : in  STD_LOGIC;
        D711    : in  STD_LOGIC;
        D2312   : in  STD_LOGIC;
        Eq      : in  STD_LOGIC;

        -- Outputs
        Win     : out STD_LOGIC;
        Lose    : out STD_LOGIC;
        Sp      : out STD_LOGIC;
        Roll    : out STD_LOGIC
    );
end Control;

architecture Behavioral of Control is
    -- State Declaration
    TYPE STATE_TYPE IS (Start, Play1, Play2Interval, Play2, EndGame);
    SIGNAL state : STATE_TYPE := Start;
    SIGNAL Roll0 : std_logic;

begin
    PROCESS(clk, rst)
    BEGIN
    
        Roll0 <= Rb;
        Roll <= Roll0;
        
		IF rst = '1' THEN
            state  <= Start;
            Win    <= '0';
            Lose   <= '0';
            Sp     <= '1';
            Roll   <= '0';
            
        ELSIF state = EndGame THEN
			Roll <= '0';
			
        ELSIF rising_edge(clk) THEN
            -- Default outputs

            CASE state IS
                WHEN Start =>
                    IF Rb = '1' THEN
                        state <= Play1;
                    END IF;
				
				WHEN Play1 =>
					IF Rb = '0' THEN
						Sp <= '0';
						IF D711 = '1' THEN
							Win <= '1';
							state <= EndGame;
						ElSIF D2312 = '1' THEN
							Lose <= '1';
							state <= EndGame;
						ELSE
							state <= Play2Interval;
						END IF;
					END IF;
				
				When Play2Interval =>
					IF Rb = '1' THEN
						state <= Play2;
					END IF;
				
                WHEN Play2 =>
                    IF Rb = '0' THEN
                        IF D7 = '1' THEN
                            Lose <= '1';
                            state <= EndGame;
                        ELSIF Eq = '1' THEN
                            Win <= '1';
                            state <= EndGame;
                        ELSE
							state <= Play2Interval;
                        END IF;
                    END IF;

                WHEN EndGame =>
                    -- Wait for reset
                    NULL;
            END CASE;
        END IF;
    END PROCESS;

end Behavioral;
