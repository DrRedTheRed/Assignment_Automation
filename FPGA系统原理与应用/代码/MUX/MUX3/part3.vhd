library ieee;
use ieee.std_logic_1164.all;

entity part3 is
	port(
		iSW : in std_logic_vector(17 downto 0);
		oLEDR : out std_logic_vector(17 downto 0);
		oLEDG : out std_logic_vector(2 downto 0)
	);
end part3;

architecture behavior of part3 is
	signal M : STD_LOGIC_VECTOR(2 downto 0);  -- Output of the multiplexer (3-bit wide)
    signal sel : STD_LOGIC_VECTOR(2 downto 0); -- Select input (3 bits)
    signal U : STD_LOGIC_VECTOR(14 downto 0);  -- 5 sets of 3-bit data inputs
begin
    -- Assign the 3-bit select inputs (SW17 to SW15)
    sel <= iSW(17 downto 15);

    -- Assign the 5 sets of 3-bit wide data inputs (SW14 to SW0)
    U <= iSW(14 downto 0);

    -- Multiplexer process
    process(sel, U)
    begin
        case sel is
            when "100" => M <= U(2 downto 0);    -- Select the first input (SW2 to SW0)
            when "011" => M <= U(5 downto 3);    -- Select the second input (SW5 to SW3)
            when "010" => M <= U(8 downto 6);    -- Select the third input (SW8 to SW6)
            when "001" => M <= U(11 downto 9);   -- Select the fourth input (SW11 to SW9)
            when "000" => M <= U(14 downto 12);  -- Select the fifth input (SW14 to SW12)
            when others => M <= "000";            -- Default case
        end case;
    end process;

    -- Connect the switches (SW) to the red LEDs (LEDR)
    oLEDR <= iSW;

    -- Connect the 3-bit output M to the green LEDs (LEDG)
    oLEDG <= M;
    
end behavior;