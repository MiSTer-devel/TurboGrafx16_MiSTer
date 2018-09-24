library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity huc6280 is
	port (
		CLK 		: in std_logic;
		RESET_N	: in std_logic;

		NMI_N		: in std_logic := '1';
		IRQ1_N	: in std_logic := '1';
		IRQ2_N	: in std_logic := '1';
		
		DI			: in std_logic_vector(7 downto 0);
		DO 		: out std_logic_vector(7 downto 0);
		
		HSM		: out std_logic;
		
		A 			: out std_logic_vector(20 downto 0);
		WR_N 		: out std_logic;
		RD_N		: out std_logic;
		
		RDY		: in std_logic;
		CLKEN		: out std_logic;
		CLKEN7	: out std_logic;
		
		CEK_N		: out std_logic; -- VCE
		CE7_N		: out std_logic; -- VDC
		CER_N		: out std_logic; -- RAM
		CEB_N		: out std_logic; -- BRM
		CEI_N		: out std_logic; -- I/O

		VDCNUM	: in std_logic;

		K			: in std_logic_vector(7 downto 0);
		O			: out std_logic_vector(7 downto 0);
		
		AUD_LDATA: out std_logic_vector(23 downto 0);
		AUD_RDATA: out std_logic_vector(23 downto 0)
	);
end huc6280;

architecture rtl of huc6280 is

signal CPU_ADDR_U : unsigned(20 downto 0);
signal CPU_DO_U 	: unsigned(7 downto 0);

signal CPU_A		: std_logic_vector(20 downto 0);
signal CPU_DI		: std_logic_vector(7 downto 0);
signal CPU_DO		: std_logic_vector(7 downto 0);

signal CPU_HSM		: std_logic;
signal CPU_BLK		: std_logic;

signal CPU_WE		: std_logic;
signal CPU_OE		: std_logic;

signal CPU_NMI_N	: std_logic;
signal CPU_IRQ1_N	: std_logic;
signal CPU_IRQ2_N	: std_logic;
signal CPU_TIQ_N	: std_logic;

signal CPU_EN		: std_logic;

-- Clock dividers
signal CLKDIV_HI	: std_logic_vector(2 downto 0) := (others => '0');
signal CPU_CLKEN	: std_logic := '0';
signal TMR_CLKEN	: std_logic := '0';
signal PSG_CLKEN	: std_logic := '0';

-- Address decoding
signal ROM_SEL_N	: std_logic;
signal RAM_SEL_N	: std_logic;
signal BRM_SEL_N	: std_logic;
signal VDC_SEL_N	: std_logic;
signal VCE_SEL_N	: std_logic;
signal PSG_SEL_N	: std_logic; -- PSG
signal TMR_SEL_N	: std_logic; -- Timer
signal IOP_SEL_N	: std_logic; -- I/O Port
signal INT_SEL_N	: std_logic; -- Interrupt controller

signal PSG_DO		: std_logic_vector(7 downto 0);
signal TMR_DO		: std_logic_vector(7 downto 0);
signal IOP_DO		: std_logic_vector(7 downto 0);
signal INT_DO		: std_logic_vector(7 downto 0);

-- Internal data buffer
signal DATA_BUF	: std_logic_vector(7 downto 0);

-- Timer
signal TMR_LATCH	: std_logic_vector(6 downto 0);
signal TMR_VALUE	: std_logic_vector(16 downto 0);
signal TMR_EN		: std_logic;
signal TMR_RELOAD	: std_logic;
signal TMR_IRQ		: std_logic;
signal TMR_IRQ_REQ: std_logic;
signal TMR_IRQ_ACK: std_logic;

-- Interrupt controller
signal INT_MASK	: std_logic_vector(2 downto 0);

-- Output port buffer
signal O_FF			: std_logic_vector(7 downto 0);

signal CLKEN_FF	: std_logic;
signal CLKEN7_FF	: std_logic;
signal CLKEN7_FF2	: std_logic;

signal VRDY			: std_logic;
signal VSEL_N		: std_logic;

begin

CPU: entity work.cpu65xx(fast)
	generic map (
		pipelineOpcode 	=> false,
		pipelineAluMux 	=> false,
		pipelineAluOut 	=> false
	)
	port map (
		clk 			=> CLK,
		enable 		=> CPU_EN,
		reset 		=> not RESET_N,
		nmi_n 		=> CPU_NMI_N,
		irq1_n 		=> CPU_IRQ1_N,
		irq2_n 		=> CPU_IRQ2_N,
		tiq_n			=> CPU_TIQ_N,
		vdcn   		=> VDCNUM,

		di 			=> unsigned(CPU_DI),
		do 			=> CPU_DO_U,
		addr 			=> CPU_ADDR_U,
		we 			=> CPU_WE,
		oe				=> CPU_OE,
		
		hsm			=> CPU_HSM,
		blk			=> CPU_BLK
	);

-- Unsigned / std_logic_vector conversion
CPU_A <= std_logic_vector(CPU_ADDR_U);
CPU_DO <= std_logic_vector(CPU_DO_U);

-- Output wires
WR_N <= not CPU_WE;
RD_N <= not CPU_OE;
A <= CPU_A;
HSM <= CPU_HSM;
DO <= CPU_DO;
CEK_N <= VCE_SEL_N;
CE7_N <= VDC_SEL_N;
CER_N <= RAM_SEL_N;
CEB_N <= BRM_SEL_N;
CEI_N <= IOP_SEL_N;

O <= O_FF;
CLKEN <= CLKEN_FF;
CLKEN7 <= CLKEN7_FF2;

-- Input wires
CPU_NMI_N <= NMI_N;

-- Clock dividers
process( CLK )
begin
	if rising_edge( CLK ) then
		TMR_CLKEN <= '0';
		PSG_CLKEN <= '0';
		CPU_EN    <= '0';
		CLKEN7_FF <= '0';

		CLKDIV_HI <= CLKDIV_HI + 1;
		if CLKDIV_HI = "101" then
			CPU_EN    <= RDY and VRDY;
			CLKEN7_FF <= '1';
			TMR_CLKEN <= '1';
			PSG_CLKEN <= '1';
			CLKDIV_HI <= "000";
		end if;
	end if;
end process;

-- XOUT signal is probably set that way
-- Here it will be used to drive the WE signal of the synchronous BRAM
process( CLK )
begin
	if rising_edge( CLK ) then
		CLKEN_FF <= CPU_EN;
		CLKEN7_FF2 <= CLKEN7_FF;
	end if;
end process;

-- according to pcetech.txt access to VDC/VCE produces an extra cycle.
-- So, do this here, to pace down the CPU.
VSEL_N <= (VDC_SEL_N and VCE_SEL_N) or not (CPU_WE or CPU_OE);
process( CLK ) begin
	if rising_edge( CLK ) then
		if CLKEN_FF = '1' and VSEL_N = '0' then
			VRDY <= '0';
		elsif CLKEN7_FF2 = '1' then
			VRDY <= '1';
		end if;
	end if;
end process;

-- Address decoding
ROM_SEL_N <= CPU_A(20);                                        -- ROM : Page $00 - $7F
RAM_SEL_N <= '0' when CPU_A(20 downto 15) = "111110" else '1'; -- RAM : Page $F8 - $FB
BRM_SEL_N <= '0' when CPU_A(20 downto 13) = x"F7"    else '1'; -- BRM : Page $F7

-- I/O Page $FF
VDC_SEL_N <= '0' when CPU_A(20 downto 13) = x"FF" and CPU_A(12 downto 10) = "000" else '1'; -- VDC : $0000 - $03FF
VCE_SEL_N <= '0' when CPU_A(20 downto 13) = x"FF" and CPU_A(12 downto 10) = "001" else '1'; -- VCE : $0400 - $07FF
PSG_SEL_N <= '0' when CPU_A(20 downto 13) = x"FF" and CPU_A(12 downto 10) = "010" else '1'; -- PSG : $0800 - $0BFF
TMR_SEL_N <= '0' when CPU_A(20 downto 13) = x"FF" and CPU_A(12 downto 10) = "011" else '1'; -- TMR : $0C00 - $0FFF
IOP_SEL_N <= '0' when CPU_A(20 downto 13) = x"FF" and CPU_A(12 downto 10) = "100" else '1'; -- IOP : $1000 - $13FF
INT_SEL_N <= '0' when CPU_A(20 downto 13) = x"FF" and CPU_A(12 downto 10) = "101" else '1'; -- INT : $1400 - $17FF

-- On-chip hardware CPU interface
process( CLK )
begin
	if rising_edge( CLK ) then
		
		TMR_RELOAD <= '0';
		TMR_IRQ_ACK <= '0';
		
		if RESET_N = '0' then
			DATA_BUF <= (others => '0');
			
			TMR_LATCH <= (others => '0');
			TMR_EN <= '0';
			
			INT_MASK <= (others => '0');
			O_FF <= (others => '0');
		else
			-- if CPU_EN = '1' and CPU_WE = '1' then
			if CLKEN_FF = '1' and CPU_WE = '1' then
				-- CPU Write
				if PSG_SEL_N = '0' then
					DATA_BUF <= CPU_DO;
				elsif TMR_SEL_N = '0' then
					DATA_BUF <= CPU_DO;
					if CPU_A(0) = '0' then
						-- Timer latch
						TMR_LATCH <= CPU_DO(6 downto 0);
					else
						-- Timer enable
						TMR_EN <= CPU_DO(0);
						if TMR_EN = '0' and CPU_DO(0) = '1' then
							TMR_RELOAD <= '1';
						end if;
					end if;				
				elsif IOP_SEL_N = '0' then
					DATA_BUF <= CPU_DO;
					O_FF <= CPU_DO;
				elsif INT_SEL_N = '0' then
					DATA_BUF <= CPU_DO;
					case CPU_A(1 downto 0) is
					when "10" =>
						INT_MASK <= CPU_DO(2 downto 0);
					when "11" =>
						TMR_IRQ_ACK <= '1';
					when others =>
						null;
					end case;
				end if;
			-- elsif CPU_EN = '1' and CPU_OE = '1' then
			elsif CLKEN_FF = '1' and CPU_OE = '1' then
				-- CPU Read
				if PSG_SEL_N = '0' then
					if CPU_BLK = '1' then
						PSG_DO <= (others => '0');
					else
						PSG_DO <= DATA_BUF;
					end if;
				elsif TMR_SEL_N = '0' then
					if CPU_BLK = '1' then
						TMR_DO <= (others => '0');
					else
						DATA_BUF <= DATA_BUF(7) & TMR_VALUE(16 downto 10);
						TMR_DO <= DATA_BUF(7) & TMR_VALUE(16 downto 10);
					end if;
				elsif IOP_SEL_N = '0' then
					if CPU_BLK = '1' then
						IOP_DO <= (others => '0');
					else	
						IOP_DO <= K;
--						DATA_BUF <= K;
					end if;
				elsif INT_SEL_N = '0' then
					if CPU_BLK = '1' then
						INT_DO <= (others => '0');
					else					
						case CPU_A(1 downto 0) is
						when "10" =>
							DATA_BUF <= DATA_BUF(7 downto 3) & INT_MASK;
							INT_DO <= DATA_BUF(7 downto 3) & INT_MASK;
							TMR_IRQ_ACK <= '1';
						when "11" =>
							DATA_BUF <= DATA_BUF(7 downto 3) & TMR_IRQ & not( IRQ1_N ) & not( IRQ2_N );
							INT_DO <= DATA_BUF(7 downto 3) & TMR_IRQ & not( IRQ1_N ) & not( IRQ2_N );
						when others =>
							INT_DO <= DATA_BUF;
						end case;
					end if;
				end if;
			end if;
		end if;
		
	end if;
end process;

-- Timer Interrupt
process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			TMR_IRQ <= '0';
		elsif TMR_IRQ_REQ = '1' then
			TMR_IRQ <= '1';
		elsif TMR_IRQ_ACK = '1' then
			TMR_IRQ <= '0';
		end if;
	end if;
end process;

-- Timer
process( CLK )
begin
	if rising_edge( CLK ) then
		TMR_IRQ_REQ <= '0';
	
		if RESET_N = '0' then
			TMR_VALUE <= (others => '0');
		elsif TMR_RELOAD = '1' then
			TMR_VALUE <= TMR_LATCH & "1111111110";
		elsif TMR_CLKEN = '1' and TMR_EN = '1' then
			TMR_VALUE <= TMR_VALUE - 1;
			if TMR_VALUE = "1111111" & "1111111111" then
				TMR_VALUE <= TMR_LATCH & "1111111110";
				TMR_IRQ_REQ <= '1';
			end if;
		end if;
	end if;
end process;

-- CPU data bus
CPU_DI <=   DI when (ROM_SEL_N and RAM_SEL_N and BRM_SEL_N and VDC_SEL_N and VCE_SEL_N) = '0'
	else PSG_DO when PSG_SEL_N = '0'
	else TMR_DO when TMR_SEL_N = '0'
	else IOP_DO when IOP_SEL_N = '0'
	else INT_DO when INT_SEL_N = '0'
	else x"FF";

CPU_TIQ_N <= not( TMR_IRQ ) or INT_MASK(2);
CPU_IRQ1_N <= IRQ1_N or INT_MASK(1);
CPU_IRQ2_N <= IRQ2_N or INT_MASK(0);

-- PSG
PSG : entity work.psg port map (
	CLK		=> CLK,
	CLKEN		=> PSG_CLKEN,	-- 7.16 Mhz clock
	RESET_N	=> RESET_N,
	
	DI			=> CPU_DO(7 downto 0),
	A			=> CPU_A(3 downto 0),
	WE			=> CPU_WE and CLKEN_FF and not PSG_SEL_N,
	
	DAC_LATCH=> '1',
	LDATA		=> AUD_LDATA,
	RDATA		=> AUD_RDATA
);

end rtl;
