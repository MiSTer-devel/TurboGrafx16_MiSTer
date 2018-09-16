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
		--For convenience
		DOTCLOCK_O : out std_logic_vector(1 downto 0);

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
		
		-- NTSC/RGB Video Output
		R			: out std_logic_vector(2 downto 0);
		G			: out std_logic_vector(2 downto 0);
		B			: out std_logic_vector(2 downto 0);		
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
signal BW		: std_logic;
signal DOTCLOCK	: std_logic_vector(1 downto 0);

-- CPU Color RAM Interface
signal RAM_A	: std_logic_vector(8 downto 0);
signal RAM_DI	: std_logic_vector(8 downto 0);
signal RAM_WE	: std_logic := '0';
signal RAM_DO	: std_logic_vector(8 downto 0);

-- Color RAM Output
signal COLOR	: std_logic_vector(8 downto 0);

-- Video Counting
constant LINE_CLOCKS	   : integer := 2736; -- should be divisible by 24 (LCM of 4, 6 and 8)
constant HS_CLOCKS		: integer := 192;
constant LEFT_BL_CLOCKS	: integer := 416;
constant DISP_CLOCKS	   : integer := 2088;

constant TOTAL_LINES		: integer := 263;  -- 525
constant VS_LINES			: integer := 3; 	 -- pcetech.txt
constant TOP_BL_LINES	: integer := 17;	 -- pcetech.txt
constant DISP_LINES		: integer := 242;	 -- pcetech.txt

signal H_CNT	: std_logic_vector(11 downto 0);
signal V_CNT	: std_logic_vector(9 downto 0);

-- Clock generation
signal CLKEN_CNT	: std_logic_vector(2 downto 0);

begin

-- Color RAM
ram : entity work.dpram generic map (9,9)
port map(
	clock			=> CLK,

	address_a	=> RAM_A,
	data_a		=> RAM_DI,
	wren_a		=> RAM_WE,
	q_a			=> RAM_DO,
	
	address_b	=> COLNO,
	data_b		=> "000000000",
	wren_b		=> '0',
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
		if RESET_N = '0' then
			H_CNT <= (others => '0');
			V_CNT <= (others => '0');
			
			BW <= '0';
			-- DOTCLOCK <= "11";
			DOTCLOCK <= "00";
			
			CLKEN <= '0';
			CLKEN_CNT <= (others => '0');
		else
			H_CNT <= H_CNT + 1;
			
			CLKEN <= '0';
			CLKEN_CNT <= CLKEN_CNT + 1;
			if DOTCLOCK = "00" and CLKEN_CNT = "111" then
				CLKEN_CNT <= (others => '0');
				CLKEN <= '1';
			elsif DOTCLOCK = "01" and CLKEN_CNT = "101" then
				CLKEN_CNT <= (others => '0');
				CLKEN <= '1';				
			elsif (DOTCLOCK = "10" or DOTCLOCK = "11") and CLKEN_CNT = "011" then
				CLKEN_CNT <= (others => '0');
				CLKEN <= '1';				
			end if;
			
			if H_CNT = LINE_CLOCKS-1 then
				H_CNT <= (others => '0');
				V_CNT <= V_CNT + 1;
				if V_CNT = TOTAL_LINES-1 then
					V_CNT <= (others => '0');
					-- Reload registers
					BW <= CR(7);
					DOTCLOCK <= CR(1 downto 0);
				end if;
			end if;
		end if;
	end if;
end process;

-- Horizontal Sync
process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			HS_N <= '0';
		else
			if H_CNT = 0 then
				HS_N <= '0';
			end if;
			if H_CNT = HS_CLOCKS-1 then
				HS_N <= '1';
			end if;
		end if;
	end if;
end process;

-- Vertical Sync
process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			VS_N <= '0';
		else
			if V_CNT = 0 then
				VS_N <= '0';
			end if;
			if V_CNT = VS_LINES-1 then
				VS_N <= '1';
			end if;
		end if;
	end if;
end process;

-- Blanking
-- It is performed "at the source" by clearing the input of the scanline RAMs
-- Based on VGA blanking periods
process( CLK )

variable L_V : std_logic_vector(4 downto 0);
variable BW_V : std_logic_vector(2 downto 0);
variable R_V : std_logic_vector(2 downto 0);
variable B_V : std_logic_vector(2 downto 0);
variable G_V : std_logic_vector(2 downto 0);

begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			HBL <= '0';
			VBL <= '0';
		else
			if H_CNT >= LEFT_BL_CLOCKS and H_CNT < LEFT_BL_CLOCKS + DISP_CLOCKS then
				HBL <= '0';
			else
				HBL <= '1';
			end if;

			if V_CNT >= TOP_BL_LINES and V_CNT < TOP_BL_LINES + DISP_LINES	then
				VBL <= '0';
			else
				VBL <= '1';
			end if;

			G_V := COLOR(8 downto 6);
			R_V := COLOR(5 downto 3);
			B_V := COLOR(2 downto 0);
			if (BW = '1') then
				L_V := ("00" & G_V) + ("00" & R_V) + ("00" & B_V);
				-- Divide by 3 (dropped lowest bit)
				-- Patent uses a ROM table to get 5-bit luminance (not just divide by 3).
				case L_V(4 downto 1) is
				when "0000" =>
					BW_V := "000";
				when "0001" | "0010" =>
					BW_V := "001";
				when "0011" =>
					BW_V := "010";
				when "0100" =>
					BW_V := "011";
				when "0101" | "0110" =>
					BW_V := "100";
				when "0111" =>
					BW_V := "101";
				when "1000" | "1001" =>
					BW_V := "110";
				when others =>
					BW_V := "111";
				end case;
				G_V := BW_V;
				R_V := BW_V;
				B_V := BW_V;
			end if;
			G <= G_V;
			R <= R_V;
			B <= B_V;
		end if;
	end if;
end process;

DOTCLOCK_O <= DOTCLOCK;

end rtl;
