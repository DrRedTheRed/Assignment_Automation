library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity part5 is
    port (
        iSW : in std_logic_vector(17 downto 0);
        oHEX0_D, oHEX1_D, oHEX2_D, oHEX3_D, oHEX4_D : out std_logic_vector(6 downto 0)
    );
end part5;

architecture behavior of part5 is

    component mux_3bit_5to1
        port (
            s, u, v, w, x, y : in std_logic_vector(2 downto 0);
            m : out std_logic_vector(2 downto 0)
        );
    end component;

    component char_7seg
        port (
            c : in std_logic_vector(2 downto 0);
            display : out std_logic_vector(0 to 6)
        );
    end component;

    signal m0, m1, m2, m3, m4 : std_logic_vector(2 downto 0);
    signal s0, s1, s2, s3, s4 : std_logic_vector(2 downto 0);

begin

    process(iSW)
        variable temp : unsigned(3 downto 0); 
    begin
        temp := to_unsigned(to_integer(unsigned(iSW(17 downto 15))), 4) mod 5;
        s0 <= std_logic_vector(temp(2 downto 0));

        temp := to_unsigned(to_integer(unsigned(iSW(17 downto 15))) + 1, 4) mod 5;
        s1 <= std_logic_vector(temp(2 downto 0));

        temp := to_unsigned(to_integer(unsigned(iSW(17 downto 15))) + 2, 4) mod 5;
        s2 <= std_logic_vector(temp(2 downto 0));

        temp := to_unsigned(to_integer(unsigned(iSW(17 downto 15))) + 3, 4) mod 5;
        s3 <= std_logic_vector(temp(2 downto 0));

        temp := to_unsigned(to_integer(unsigned(iSW(17 downto 15))) + 4, 4) mod 5;
        s4 <= std_logic_vector(temp(2 downto 0));
    end process;

    mux0: mux_3bit_5to1
        port map (
            s => s0,
            u => iSW(14 downto 12),
            v => iSW(11 downto 9),
            w => iSW(8 downto 6),
            x => iSW(5 downto 3),
            y => iSW(2 downto 0),
            m => m0
        );

    mux1: mux_3bit_5to1
        port map (
            s => s1,
            u => iSW(14 downto 12),
            v => iSW(11 downto 9),
            w => iSW(8 downto 6),
            x => iSW(5 downto 3),
            y => iSW(2 downto 0),
            m => m1
        );

    mux2: mux_3bit_5to1
        port map (
            s => s2,
            u => iSW(14 downto 12),
            v => iSW(11 downto 9),
            w => iSW(8 downto 6),
            x => iSW(5 downto 3),
            y => iSW(2 downto 0),
            m => m2
        );

    mux3: mux_3bit_5to1
        port map (
            s => s3,
            u => iSW(14 downto 12),
            v => iSW(11 downto 9),
            w => iSW(8 downto 6),
            x => iSW(5 downto 3),
            y => iSW(2 downto 0),
            m => m3
        );

    mux4: mux_3bit_5to1
        port map (
            s => s4,
            u => iSW(14 downto 12),
            v => iSW(11 downto 9),
            w => iSW(8 downto 6),
            x => iSW(5 downto 3),
            y => iSW(2 downto 0),
            m => m4
        );

    char0: char_7seg
        port map (c => m4, display => oHEX0_D);

    char1: char_7seg
        port map (c => m3, display => oHEX1_D);

    char2: char_7seg
        port map (c => m2, display => oHEX2_D);

    char3: char_7seg
        port map (c => m1, display => oHEX3_D);

    char4: char_7seg
        port map (c => m0, display => oHEX4_D);

end behavior;