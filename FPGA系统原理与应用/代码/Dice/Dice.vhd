library IEEE;
use ieee.std_logic_1164.all;

entity Dice is
generic(
        width : Natural := 3 -- 
    );
    	port (	
	   clk     : in  std_logic;
	   Rb     : in std_logic;
           rst     : in  std_logic;

	   win : out std_logic;
	   lose : out std_logic;
	   
	   display0 : out std_logic_vector(7 downto 0);
	   display1 : out std_logic_vector(7 downto 0)

	);
end Dice;

Architecture structural of Dice is
-----------------------------------------------
component MultiAdder
    	port (	
		A       : In  std_logic_vector(width -1 downto 0);
		B       : In  std_logic_vector(width -1 downto 0);
		Sum     : Out std_logic_vector(width    downto 0)	 	
	);
end component;
------------------------------------------------
component Counter
    	Port ( clk      : in std_logic;
               rst      : in std_logic;
	       roll     : in std_logic;
               count    : out std_logic_vector (width -1 downto 0);
               cycle    : out std_logic
	);
end component;
-----------------------------------------------
component Point_register
    	Port (
	       clk      : in  std_logic;
               rst      : in  std_logic;
	       Sp       : in  std_logic;
               Data_In  : in  std_logic_vector (width downto 0);
               Data_Out : out std_logic_vector (width downto 0)
	);
end component;
-----------------------------------------------
component comparator
    	Port ( clk      : in  std_logic;
               CompA    : in  STD_LOGIC_VECTOR (width    downto 0);
               CompB    : in  STD_LOGIC_VECTOR (width    downto 0);
               Eq       : out STD_LOGIC
	);
end component;
-----------------------------------------------
component TestLogic
	Port ( 
        Sum     : in std_logic_vector(3 downto 0); -- Sum of the two dice
        D7      : out STD_LOGIC;
        D711    : out STD_LOGIC;
        D2312   : out STD_LOGIC
    );
end component;
-----------------------------------------------
component Control
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
end component;
-----------------------------------------------
component char_7seg
    Port ( 
        c : in std_logic_vector(2 downto 0); -- 4-bit input character code
        display : out std_logic_vector(7 downto 0) -- 7-segment output
    );
end component;
-----------------------------------------------
	   signal Cnt0  : std_logic_vector(width -1 downto 0):= (others => '0');
	   signal Cnt1  : std_logic_vector(width -1 downto 0):= (others => '0');
	   signal DatIn : std_logic_vector(width    downto 0):= (others => '0');
	   signal DatOut: std_logic_vector(width    downto 0):= (others => '0');
	   signal Sum0  : std_logic_vector(width    downto 0);
	   signal Sp0 : std_logic;
	   signal Eq0 : std_logic;
	   signal D70 : std_logic;
	   signal D7110 : std_logic;
	   signal D23120 : std_logic;
	   signal Roll0 : std_logic;
	   signal cycle0 : std_logic;
	   signal cycle1 : std_logic;
	   

Begin

	Counter0:    	     Counter             port map (clk => clk , rst   => rst   , roll    => Roll0 , count => cnt0, cycle => cycle0);
	Counter1:    	     Counter             port map (clk => cycle0 , rst   => rst   , roll    => Roll0 , count => cnt1, cycle => cycle1 );
	MultiAdder0: 	     MultiAdder          port map (A   => cnt0, B     => cnt1  , Sum   => Sum0 );
	Point_register0:     Point_register      port map (clk => clk , rst   => rst   , Sp    => Sp0    , Data_In => Sum0, Data_Out => DatOut);
	comparator0:         comparator          port map (clk => clk , CompA => DatOut, CompB => Sum0  , Eq => Eq0 );
	TestLogic0:			 TestLogic           port map (Sum => Sum0, D7 => D70 , D711 => D7110, D2312 => D23120);
	Control0:            Control             port map (clk => clk , rst => rst , Rb => Rb, D7 => D70, D711 => D7110, D2312 => D23120 , Eq => Eq0, Win => win, Lose => lose, Sp => Sp0, Roll => Roll0);
	Char_7seg0:            char_7seg           port map (c => cnt0, display => display0 );
	Char_7seg1:            char_7seg           port map (c => cnt1, display => display1 );

end structural; 
