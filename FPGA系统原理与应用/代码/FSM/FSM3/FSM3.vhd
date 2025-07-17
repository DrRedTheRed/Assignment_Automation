LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FSM3 IS
    PORT (
        clk : IN STD_LOGIC;              -- Clock input
        reset : IN STD_LOGIC;           -- Active-low reset
        w : IN STD_LOGIC;               -- Input signal
        z : OUT STD_LOGIC;              -- Output signal
        leds : OUT STD_LOGIC_VECTOR(8 DOWNTO 0) -- State display on LEDs
    );
END FSM3;

ARCHITECTURE Behavior OF FSM3 IS
    -- Declare state type
    TYPE State_type IS (A, B, C, D, E, F, G, H, I);
    SIGNAL y_Q, y_D : State_type; -- y_Q: Present state, y_D: Next state
BEGIN

    -- State transition logic (State table)
    PROCESS (w, y_Q)
    BEGIN
        CASE y_Q IS
            WHEN A =>
                IF w = '0' THEN
                    y_D <= B;
                ELSE
                    y_D <= F;
                END IF;
            WHEN B =>
                IF w = '0' THEN
                    y_D <= C;
                ELSE
                    y_D <= F;
                END IF;
            WHEN C =>
                IF w = '0' THEN
                    y_D <= D;
                ELSE
                    y_D <= F;
                END IF;
            WHEN D =>
                IF w = '0' THEN
                    y_D <= E;
                ELSE
                    y_D <= F;
                END IF;
            WHEN E =>
                IF w = '0' THEN
                    y_D <= E;
                ELSE
                    y_D <= F;
                END IF;
            WHEN F =>
                IF w = '1' THEN
                    y_D <= G;
                ELSE
                    y_D <= B;
                END IF;
            WHEN G =>
                IF w = '1' THEN
                    y_D <= H;
                ELSE
                    y_D <= B;
                END IF;
            WHEN H =>
                IF w = '1' THEN
                    y_D <= I;
                ELSE
                    y_D <= B;
                END IF;
            WHEN I =>
                IF w = '1' THEN
                    y_D <= I;
                ELSE
                    y_D <= B;
                END IF;
            WHEN OTHERS =>
                y_D <= A; -- Default state
        END CASE;
    END PROCESS;

    -- State flip-flops (Sequential logic)
    PROCESS (clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
				y_Q <= A; -- Reset to initial state
            ELSE
				y_Q <= y_D; -- Update to next state
			END IF;
        END IF;
    END PROCESS;

    -- Output logic for z
    z <= '1' WHEN (y_Q = E OR y_Q = I) ELSE '0';

    -- Assign LEDs to display the current state
    leds <= "000000001" WHEN y_Q = A ELSE
            "000000010" WHEN y_Q = B ELSE
            "000000100" WHEN y_Q = C ELSE
            "000001000" WHEN y_Q = D ELSE
            "000010000" WHEN y_Q = E ELSE
            "000100000" WHEN y_Q = F ELSE
            "001000000" WHEN y_Q = G ELSE
            "010000000" WHEN y_Q = H ELSE
            "100000000";

END Behavior;
