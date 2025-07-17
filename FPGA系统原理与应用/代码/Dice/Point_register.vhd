library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Point_register is
    generic ( width : integer := 3 );

    Port ( clk       : in  std_logic;                            -- Clock input
           rst       : in  std_logic;                            -- Synchronous reset
           Sp        : in  std_logic;                            -- Load enable signal
           Data_In   : in  std_logic_vector(width downto 0);     -- Data input
           Data_Out  : out std_logic_vector(width downto 0)      -- Data output
    );
end Point_register;

architecture slice of Point_register is
    signal Data : std_logic_vector(width downto 0) := (others => '0'); -- Internal signal
begin
    process(clk)  -- Only clk in the sensitivity list for synchronous logic
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset the register synchronously
                Data <= (others => '0');
            elsif Sp = '1' then
                -- Load new data when Sp is high
                Data <= Data_In;
            end if;
        end if;
    end process;

    -- Assign internal signal to output
    Data_Out <= Data;

end slice;
