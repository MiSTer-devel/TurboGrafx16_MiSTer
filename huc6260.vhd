library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
library STD;
use STD.TEXTIO.ALL;

entity huc6260 is
	port (
		CLK 		: in std_logic;
		RESET_N	: in std_logic;
		HSIZE		: out std_logic_vector(9 downto 0);
		HSTART	: out std_logic_vector(9 downto 0);

		-- CPU Interface
		A			: in std_logic_vector(2 downto 0);
		CE_N		: in std_logic;
		WR_N		: in std_logic;
		RD_N		: in std_logic;
		DI			: in std_logic_vector(7 downto 0);
		DO 		: out std_logic_vector(7 downto 0);

		-- VDC Interface
		COLNO		: in std_logic_vector(8 downto 0);
		CLKEN		: out std_logic;
		CLKEN_FS	: out std_logic;
		RVBL		: in std_logic;

		-- NTSC/RGB Video Output
		R			: out std_logic_vector(2 downto 0);
		G			: out std_logic_vector(2 downto 0);
		B			: out std_logic_vector(2 downto 0);
		BW			: out std_logic;

		VS_N		: out std_logic;
		HS_N		: out std_logic;
		HBL		: out std_logic;
		VBL		: out std_logic
	);
end huc6260;

architecture rtl of huc6260 is

-- CPU Interface
signal PREV_A	: std_logic_vector(2 downto 0);

type ctrl_t is ( CTRL_IDLE, CTRL_WAIT, CTRL_INCR );
signal CTRL		: ctrl_t;
signal CR		: std_logic_vector(7 downto 0);

-- VCE Registers
signal DOTCLOCK	: std_logic_vector(1 downto 0);
signal DOTCLOCK_FS: std_logic_vector(1 downto 0);

-- CPU Color RAM Interface
signal RAM_A	: std_logic_vector(8 downto 0);
signal RAM_DI	: std_logic_vector(8 downto 0);
signal RAM_WE	: std_logic := '0';
signal RAM_DO	: std_logic_vector(8 downto 0);

-- Color RAM Output
signal COLOR	: std_logic_vector(8 downto 0);

-- Video Counting. All horizontal constants should be divisible by 24! (LCM of 4, 6 and 8)
constant LEFT_BL_CLOCKS	: integer := 432;
constant DISP_CLOCKS	   : integer := 2160;
constant LINE_CLOCKS	   : integer := 2730;
constant HS_CLOCKS		: integer := 192;

constant TOTAL_LINES		: integer := 263;  -- 525
constant VS_LINES			: integer := 3; 	 -- pcetech.txt
constant TOP_BL_LINES_E	: integer := 19;   -- pcetech.txt (must include VS_LINES in current implementation)
constant DISP_LINES_E	: integer := 242;	 -- same as in mednafen
signal TOP_BL_LINES		: integer;
signal DISP_LINES			: integer;

constant HSIZE0 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(DISP_CLOCKS/8,10));
constant HSIZE1 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(DISP_CLOCKS/6,10));
constant HSIZE2 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(DISP_CLOCKS/4,10));

constant HSTART0 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(LEFT_BL_CLOCKS/8,10));
constant HSTART1 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(LEFT_BL_CLOCKS/6,10));
constant HSTART2 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(LEFT_BL_CLOCKS/4,10));

signal H_CNT	: std_logic_vector(11 downto 0);
signal V_CNT	: std_logic_vector(9 downto 0);

signal HBL_FF, HBL_FF2	: std_logic;
signal VBL_FF, VBL_FF2	: std_logic;

-- Clock generation
signal CLKEN_CNT	: std_logic_vector(2 downto 0);
signal CLKEN_FS_CNT: std_logic_vector(2 downto 0);
signal CLKEN_FF	: std_logic;

begin

TOP_BL_LINES <= TOP_BL_LINES_E when RVBL = '1' else TOP_BL_LINES_E+3;
DISP_LINES   <= DISP_LINES_E   when RVBL = '1' else DISP_LINES_E-10;

-- Color RAM
ram : entity work.dpram generic map (9,9)
port map(
	clock			=> CLK,

	address_a	=> RAM_A,
	data_a		=> RAM_DI,
	wren_a		=> RAM_WE,
	q_a			=> RAM_DO,
	
	address_b	=> COLNO,
	q_b			=> COLOR
);

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			RAM_A <= (others => '0');
			RAM_DI <= (others => '0');
			RAM_WE <= '0';
			CR <= x"00";
			
			PREV_A <= (others => '0');
			CTRL <= CTRL_IDLE;
		else
			case CTRL is
			
			when CTRL_IDLE =>
				RAM_WE <= '0';
				if CE_N = '0' and WR_N = '0' then
					-- CPU Write
					PREV_A <= A;
					CTRL <= CTRL_WAIT;
					case A is
					when "000" =>
						CR <= DI;
					when "010" =>
						RAM_A(7 downto 0) <= DI;
					when "011" =>
						RAM_A(8) <= DI(0);
					when "100" =>
						RAM_WE <= '1';
						RAM_DI <= RAM_DO(8) & DI;
					when "101" =>
						RAM_WE <= '1';
						RAM_DI <= DI(0) & RAM_DO(7 downto 0);
						CTRL <= CTRL_INCR;
					when others => null;
					end case;
					
				elsif CE_N = '0' and RD_N = '0' then
					-- CPU Read
					PREV_A <= A;
					CTRL <= CTRL_WAIT;
					DO <= x"FF";
					case A is
					when "100" =>
						DO <= RAM_DO(7 downto 0);
					when "101" =>
						DO <= "1111111" & RAM_DO(8);
						CTRL <= CTRL_INCR;
					when others => null;
					end case;
				end if;
			
			when CTRL_INCR =>
				RAM_WE <= '0';
				RAM_A <= RAM_A + 1;
				CTRL <= CTRL_WAIT;
			
			when CTRL_WAIT =>
				RAM_WE <= '0';
				-- Wait for the CPU to "release" the VCE.
				-- I don't know what happens in the case of an address change
				-- however it can be achieved only with addresses read/write cycles,
				-- so it seems unlikely. The case has been handled, though.
				-- HuC6280 Rmw instructions are safe, as there is a "dummy cycle"
				-- between the read cycle and the write cycle.
				CTRL <= CTRL_IDLE;
				if CE_N = '0' and (WR_N = '0' or RD_N = '0') and PREV_A = A then
					CTRL <= CTRL_WAIT;
				end if;
			
			when others => null;
			end case;
		end if;
	end if;
end process;

-- Video counting, register loading and clock generation
process( CLK )
begin
	if rising_edge( CLK ) then
		H_CNT <= H_CNT + 1;

		CLKEN_FF <= '0';
		CLKEN_CNT <= CLKEN_CNT + 1;
		if DOTCLOCK = "00" and CLKEN_CNT = "111" then
			CLKEN_CNT <= (others => '0');
			CLKEN_FF <= '1';
		elsif DOTCLOCK = "01" and CLKEN_CNT = "101" then
			CLKEN_CNT <= (others => '0');
			CLKEN_FF <= '1';				
		elsif DOTCLOCK(1) = '1' and CLKEN_CNT = "011" then
			CLKEN_CNT <= (others => '0');
			CLKEN_FF <= '1';				
		end if;

		if H_CNT = LINE_CLOCKS-1 then
			CLKEN_CNT <= (others => '0');
			CLKEN_FF <= '1';				
			H_CNT <= (others => '0');
			V_CNT <= V_CNT + 1;
			if V_CNT = TOTAL_LINES-1 then
				V_CNT <= (others => '0');
			end if;
			-- Reload registers
			BW <= CR(7);
			DOTCLOCK <= CR(1 downto 0);
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		CLKEN_FS <= '0';
		CLKEN_FS_CNT <= CLKEN_FS_CNT + 1;
		if DOTCLOCK_FS = "00" and CLKEN_FS_CNT = "111" then
			CLKEN_FS_CNT <= (others => '0');
			CLKEN_FS <= '1';
		elsif DOTCLOCK_FS = "01" and CLKEN_FS_CNT = "101" then
			CLKEN_FS_CNT <= (others => '0');
			CLKEN_FS <= '1';				
		elsif DOTCLOCK_FS(1) = '1' and CLKEN_FS_CNT = "011" then
			CLKEN_FS_CNT <= (others => '0');
			CLKEN_FS <= '1';				
		end if;

		if H_CNT = LINE_CLOCKS-1 then
			 CLKEN_FS_CNT <= (others => '0');
			 CLKEN_FS <= '1';
		end if;

		if H_CNT = LEFT_BL_CLOCKS and V_CNT = TOP_BL_LINES then
			DOTCLOCK_FS <= CR(1 downto 0);
		end if;
	end if;
end process;

-- Sync
process( CLK )
begin
	if rising_edge( CLK ) then
		if H_CNT = 0           then HS_N <= '0'; end if;
		if H_CNT = HS_CLOCKS-1 then HS_N <= '1'; end if;
		if V_CNT = 0           then VS_N <= '0'; end if;
		if V_CNT = VS_LINES-1  then VS_N <= '1'; end if;
	end if;
end process;

-- Blank
process( CLK )
begin
	if rising_edge( CLK ) then
		if H_CNT = LEFT_BL_CLOCKS               then HBL_FF <= '0'; end if;
		if H_CNT = LEFT_BL_CLOCKS + DISP_CLOCKS then HBL_FF <= '1'; end if;
		if V_CNT = TOP_BL_LINES                 then VBL_FF <= '0'; end if;
		if V_CNT = TOP_BL_LINES + DISP_LINES    then VBL_FF <= '1'; end if;
	end if;
end process;

-- Final output
process( CLK )
begin
	if rising_edge( CLK ) then
		if CLKEN_FF = '1' then

			-- compensate HUC6202 delay
			VBL_FF2 <= VBL_FF;
			HBL_FF2 <= HBL_FF;

			VBL <= VBL_FF2;
			HBL <= HBL_FF2;

			G <= COLOR(8 downto 6);
			R <= COLOR(5 downto 3);
			B <= COLOR(2 downto 0);
		end if;
	end if;
end process;

CLKEN  <= CLKEN_FF;
HSIZE  <= HSIZE0  when DOTCLOCK = "00" else HSIZE1  when DOTCLOCK = "01" else HSIZE2;
HSTART <= HSTART0 when DOTCLOCK = "00" else HSTART1 when DOTCLOCK = "01" else HSTART2;

end rtl;
