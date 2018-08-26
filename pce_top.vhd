library STD;
use STD.TEXTIO.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use IEEE.NUMERIC_STD.ALL;

entity pce_top is
	port(
		ROM_RESET_N	: in std_logic;

		CLK 			: in std_logic;

		romrd_req 	: out std_logic := '0';
		romrd_ack 	: in std_logic;
		romrd_a 		: out std_logic_vector((12+8+2) downto 3);
		romrd_q 		: in std_logic_vector(63 downto 0);
		rom_sz 		: in std_logic_vector(7 downto 0);

		AUD_LDATA	: out std_logic_vector(23 downto 0);
		AUD_RDATA	: out std_logic_vector(23 downto 0);

		AUD_XCK		: out std_logic;
		AUD_BCLK		: out std_logic;
		AUD_DACDAT	: out std_logic;
		AUD_DACLRCK	: out std_logic;
		I2C_SDAT		: out std_logic;
		I2C_SCLK		: out std_logic;

		TURBOTAP    : in std_logic;
		JOY1 		   : in std_logic_vector(7 downto 0);
		JOY2 		   : in std_logic_vector(7 downto 0);

		VIDEO_R		: out std_logic_vector(2 downto 0);
		VIDEO_G		: out std_logic_vector(2 downto 0);
		VIDEO_B		: out std_logic_vector(2 downto 0);
		VIDEO_CE		: out std_logic;
		VIDEO_VS_N	: out std_logic;
		VIDEO_HS_N	: out std_logic;
		VIDEO_HBL	: out std_logic;
		VIDEO_VBL	: out std_logic
	);
end pce_top;

architecture rtl of pce_top is

signal RESET_N			: std_logic := '0';

-- CPU signals
signal CPU_NMI_N		: std_logic;
signal CPU_IRQ1_N		: std_logic;
signal CPU_IRQ2_N		: std_logic;
signal CPU_RD_N		: std_logic;
signal CPU_WR_N		: std_logic;
signal CPU_DI			: std_logic_vector(7 downto 0);
signal CPU_DO			: std_logic_vector(7 downto 0);
signal CPU_A			: std_logic_vector(20 downto 0);
signal CPU_HSM			: std_logic;

signal CPU_CLKOUT		: std_logic;
signal CPU_CLKEN		: std_logic;
signal CPU_CLKRST		: std_logic;
signal CPU_RDY			: std_logic;

signal CPU_VCE_SEL_N	: std_logic;
signal CPU_VDC_SEL_N	: std_logic;
signal CPU_RAM_SEL_N	: std_logic;

signal CPU_IO_DI		: std_logic_vector(7 downto 0);
signal CPU_IO_DO		: std_logic_vector(7 downto 0);

-- RAM signals
signal RAM_A			: std_logic_vector(12 downto 0);
signal RAM_DI			: std_logic_vector(7 downto 0);
signal RAM_WE			: std_logic;
signal RAM_DO			: std_logic_vector(7 downto 0);

-- VCE signals
signal VCE_DO			: std_logic_vector(7 downto 0);

-- VDC signals
signal VDC_DO			: std_logic_vector(7 downto 0);
signal VDC_BUSY_N		: std_logic;
signal VDC_IRQ_N		: std_logic;

-- NTSC/RGB Video Output
signal R					: std_logic_vector(2 downto 0);
signal G					: std_logic_vector(2 downto 0);
signal B					: std_logic_vector(2 downto 0);		
signal VS_N				: std_logic;
signal HS_N				: std_logic;

-- VDC signals
signal VDC_COLNO		: std_logic_vector(8 downto 0);
signal VDC_CLKEN		: std_logic;


signal VDCBG_RAM_A	: std_logic_vector(15 downto 0);		
signal VDCBG_RAM_DO	: std_logic_vector(15 downto 0);
signal VDCBG_RAM_REQ	: std_logic;
signal VDCBG_RAM_ACK	: std_logic;
		
signal VDCSP_RAM_A	: std_logic_vector(15 downto 0);
signal VDCSP_RAM_DO	: std_logic_vector(15 downto 0);
signal VDCSP_RAM_REQ	: std_logic;
signal VDCSP_RAM_ACK	: std_logic;

signal VDCCPU_RAM_REQ: std_logic;
signal VDCCPU_RAM_A	: std_logic_vector(15 downto 0);
signal VDCCPU_RAM_DO	: std_logic_vector(15 downto 0); -- Output from RAM
signal VDCCPU_RAM_DI	: std_logic_vector(15 downto 0);
signal VDCCPU_RAM_WE	: std_logic;
signal VDCCPU_RAM_ACK: std_logic;

signal VDCDMA_RAM_REQ: std_logic;
signal VDCDMA_RAM_A	: std_logic_vector(15 downto 0);
signal VDCDMA_RAM_DO	: std_logic_vector(15 downto 0); -- Output from RAM
signal VDCDMA_RAM_DI	: std_logic_vector(15 downto 0);
signal VDCDMA_RAM_WE	: std_logic;
signal VDCDMA_RAM_ACK: std_logic;

signal VDCDMAS_RAM_REQ	: std_logic;
signal VDCDMAS_RAM_A		: std_logic_vector(15 downto 0);
signal VDCDMAS_RAM_DO	: std_logic_vector(15 downto 0); -- Output from RAM
signal VDCDMAS_RAM_ACK	: std_logic;

signal romrd_a_cached : std_logic_vector((12+8+2) downto 3);
signal romrd_q_cached : std_logic_vector(63 downto 0);

type romStates is (ROM_IDLE, ROM_READ);
signal romState : romStates := ROM_IDLE;

signal CPU_A_PREV : std_logic_vector(20 downto 0);
signal ROM_RDY	: std_logic;
signal ROM_DO	: std_logic_vector(7 downto 0);

signal romrd_reqReg : std_logic;

signal gamepad_port : unsigned(2 downto 0);
signal prev_sel : std_logic;

begin

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- CPU
CPU : entity work.huc6280 port map(
	CLK 	=> CLK,
	RESET_N	=> RESET_N,
	
	NMI_N	=> CPU_NMI_N,
	IRQ1_N	=> CPU_IRQ1_N,
	IRQ2_N	=> CPU_IRQ2_N,

	DI		=> CPU_DI,
	DO 		=> CPU_DO,
	
	HSM		=> CPU_HSM,
	
	A 		=> CPU_A,
	WR_N 	=> CPU_WR_N,
	RD_N	=> CPU_RD_N,
	
	CLKOUT	=> CPU_CLKOUT,
	CLKRST	=> CPU_CLKRST,
	RDY		=> CPU_RDY,
	ROM_RDY	=> ROM_RDY,
	
	CEK_N	=> CPU_VCE_SEL_N,
	CE7_N	=> CPU_VDC_SEL_N,
	CER_N	=> CPU_RAM_SEL_N,
	
	K		=> CPU_IO_DI,
	O		=> CPU_IO_DO,
	
	AUD_LDATA => AUD_LDATA,
	AUD_RDATA => AUD_RDATA,

	AUD_XCK		=> AUD_XCK,
	AUD_BCLK	=> AUD_BCLK,
	AUD_DACDAT	=> AUD_DACDAT,
	AUD_DACLRCK	=> AUD_DACLRCK,
	I2C_SDAT	=> I2C_SDAT,
	I2C_SCLK	=> I2C_SCLK
);

-- RAM
RAM : entity work.ram port map(
	address	=> RAM_A,
	clock	=> CLK,
	data	=> RAM_DI,
	wren	=> RAM_WE,
	q		=> RAM_DO
);

VIDEO_R <= R;
VIDEO_G <= G;
VIDEO_B <= B;
VIDEO_CE <= VDC_CLKEN;
VIDEO_VS_N <= VS_N;
VIDEO_HS_N <= HS_N;

VCE : entity work.huc6260 port map(
	CLK 		=> CLK,
	RESET_N		=> RESET_N,

	-- CPU Interface
	A			=> CPU_A(2 downto 0),
	CE_N		=> CPU_VCE_SEL_N,
	WR_N		=> CPU_WR_N,
	RD_N		=> CPU_RD_N,
	DI			=> CPU_DO,
	DO 			=> VCE_DO,
		
	-- VDC Interface
	COLNO		=> VDC_COLNO,
	CLKEN		=> VDC_CLKEN,
		
	-- NTSC/RGB Video Output
	R			=> R,
	G			=> G,
	B			=> B,
	VS_N		=> VS_N,
	HS_N		=> HS_N,
	HBL		=> VIDEO_HBL,
	VBL		=> VIDEO_VBL
);


VDC : entity work.huc6270 port map(
	CLK 		=> CLK,
	RESET_N		=> RESET_N,

	-- CPU Interface
	A			=> CPU_A(1 downto 0),
	CE_N		=> CPU_VDC_SEL_N,
	WR_N		=> CPU_WR_N,
	RD_N		=> CPU_RD_N,
	DI			=> CPU_DO,
	DO 			=> VDC_DO,
	BUSY_N		=> VDC_BUSY_N,
	IRQ_N		=> VDC_IRQ_N,
	
	BG_RAM_A	=> VDCBG_RAM_A,
	BG_RAM_DO	=> VDCBG_RAM_DO,
	BG_RAM_REQ	=> VDCBG_RAM_REQ,
	BG_RAM_ACK	=> VDCBG_RAM_ACK,
	
	SP_RAM_A	=> VDCSP_RAM_A,
	SP_RAM_DO	=> VDCSP_RAM_DO,
	SP_RAM_REQ	=> VDCSP_RAM_REQ,
	SP_RAM_ACK	=> VDCSP_RAM_ACK,
	
	CPU_RAM_REQ	=> VDCCPU_RAM_REQ,
	CPU_RAM_A	=> VDCCPU_RAM_A,
	CPU_RAM_DO	=> VDCCPU_RAM_DO,
	CPU_RAM_DI	=> VDCCPU_RAM_DI,
	CPU_RAM_WE	=> VDCCPU_RAM_WE,
	CPU_RAM_ACK	=> VDCCPU_RAM_ACK,
	
	DMA_RAM_REQ => VDCDMA_RAM_REQ,
	DMA_RAM_A	=> VDCDMA_RAM_A,
	DMA_RAM_DO	=> VDCDMA_RAM_DO,
	DMA_RAM_DI	=> VDCDMA_RAM_DI,
	DMA_RAM_WE	=> VDCDMA_RAM_WE,
	DMA_RAM_ACK	=> VDCDMA_RAM_ACK,
	
	DMAS_RAM_REQ	=> VDCDMAS_RAM_REQ,
	DMAS_RAM_A		=> VDCDMAS_RAM_A,
	DMAS_RAM_DO		=> VDCDMAS_RAM_DO,
	DMAS_RAM_ACK	=> VDCDMAS_RAM_ACK,
	
	-- VCE Interface
	COLNO		=> VDC_COLNO,
	CLKEN		=> VDC_CLKEN,
	HS_N		=> HS_N,
	VS_N		=> VS_N

);
-- VDC_RAM_A_FULL <= "00" & "1000" & VDC_RAM_A;


ram_ctl : entity work.ram_controller port map(
	clk			=> CLK,
	
	vdccpu_req	=> VDCCPU_RAM_REQ,
	vdccpu_ack	=> VDCCPU_RAM_ACK,
	vdccpu_we	=> VDCCPU_RAM_WE,
	vdccpu_a		=> VDCCPU_RAM_A,
	vdccpu_d		=> VDCCPU_RAM_DI,
	vdccpu_q		=> VDCCPU_RAM_DO,

	vdcbg_a		=> VDCBG_RAM_A,
	vdcbg_q		=> VDCBG_RAM_DO,
	vdcbg_req	=> VDCBG_RAM_REQ,
	vdcbg_ack	=> VDCBG_RAM_ACK,
	
	vdcsp_a		=> VDCSP_RAM_A,
	vdcsp_q		=> VDCSP_RAM_DO,
	vdcsp_req	=> VDCSP_RAM_REQ,
	vdcsp_ack	=> VDCSP_RAM_ACK,
	
	vdcdma_req 	=> VDCDMA_RAM_REQ,
	vdcdma_a		=> VDCDMA_RAM_A,
	vdcdma_q		=> VDCDMA_RAM_DO,
	vdcdma_d		=> VDCDMA_RAM_DI,
	vdcdma_we	=> VDCDMA_RAM_WE,
	vdcdma_ack	=> VDCDMA_RAM_ACK,
	
	vdcdmas_req	=> VDCDMAS_RAM_REQ,
	vdcdmas_a	=> VDCDMAS_RAM_A,
	vdcdmas_q	=> VDCDMAS_RAM_DO,
	vdcdmas_ack	=> VDCDMAS_RAM_ACK
);

-- Interrupt signals
CPU_NMI_N <= '1';
CPU_IRQ1_N <= VDC_IRQ_N;
CPU_IRQ2_N <= '1';
CPU_RDY <= VDC_BUSY_N and ROM_RDY;

-- CPU data bus
CPU_DI <= RAM_DO when CPU_RD_N = '0' and CPU_RAM_SEL_N = '0' 
	else ROM_DO when CPU_RD_N = '0' and CPU_A(20) = '0'
	else VCE_DO when CPU_RD_N = '0' and CPU_VCE_SEL_N = '0'
	else VDC_DO when CPU_RD_N = '0' and CPU_VDC_SEL_N = '0'
	else "ZZZZZZZZ";

-- ROM_RDY <= '1' when romrd_req = romrd_ack else '0';

romrd_req <= romrd_reqReg;

process( CLK )
begin
	if rising_edge( CLK ) then
		if ROM_RESET_N = '0' then
			RESET_N <= '0';
			romrd_reqReg <= '0';
			romrd_a_cached <= (others => '0');
			romrd_q_cached <= (others => '0');
			ROM_RDY <= '0';
			CPU_A_PREV <= (others => '0');
		elsif ROM_RESET_N = '1' and RESET_N = '0' then
			if CPU_CLKRST = '1' then
				romrd_reqReg <= not romrd_reqReg;
				romrd_a<=(others=>'0');
				romrd_a(19 downto 3) <= CPU_A(19 downto 3);
				romrd_a_cached<=(others=>'0');
				romrd_a_cached(19 downto 3) <= CPU_A(19 downto 3);
				ROM_RDY <= '0';
				romState <= ROM_READ;				
				RESET_N <= '1';
			end if;
		else
			case romState is
			when ROM_IDLE =>
				if CPU_CLKOUT = '1' then
					if CPU_RD_N = '0' or CPU_WR_N = '0' then
						CPU_A_PREV <= CPU_A;
					else 
						CPU_A_PREV <= (others => '1');
					end if;
					if CPU_A(20) = '0' and CPU_RD_N = '0' and CPU_A /= CPU_A_PREV then
						if CPU_A(19 downto 3) = romrd_a_cached(19 downto 3) then
							case CPU_A(2 downto 0) is
								when "000" =>
									ROM_DO <= romrd_q_cached(7 downto 0);
								when "001" =>
									ROM_DO <= romrd_q_cached(15 downto 8);
								when "010" =>
									ROM_DO <= romrd_q_cached(23 downto 16);
								when "011" =>
									ROM_DO <= romrd_q_cached(31 downto 24);
								when "100" =>
									ROM_DO <= romrd_q_cached(39 downto 32);
								when "101" =>
									ROM_DO <= romrd_q_cached(47 downto 40);
								when "110" =>
									ROM_DO <= romrd_q_cached(55 downto 48);
								when "111" =>
									ROM_DO <= romrd_q_cached(63 downto 56);
								when others => null;
							end case;						
						else
							romrd_reqReg <= not romrd_reqReg;
							romrd_a<=(others=>'0');
							romrd_a(19 downto 3) <= CPU_A(19 downto 3);

							-- Perform address mangling to mimic HuCard chip mapping.
							-- Straight mapping
							-- 384K ROM, split in 3, mapped ABABCCCC
							-- Are these needed?
							-- 768K ROM, split in 6, mapped ABCDEFEF
							-- 512K ROM,             mapped ABCDABCD
							-- 256K ROM,             mapped ABABABAB
							-- 128K ROM,             mapped AAAAAAAA
							
							if rom_sz = X"06" then                    -- bits 19 downto 16
								-- 00000 -> 20000  => 00000 -> 20000		0000 -> 0000
								-- 20000 -> 40000  => 20000 -> 40000		0010 -> 0010
								-- 40000 -> 60000  => 00000 -> 20000		0100 -> 0000
								-- 60000 -> 80000  => 20000 -> 40000		0110 -> 0010
								-- 80000 -> A0000  => 40000 -> 60000		1000 -> 0100
								-- A0000 -> C0000  => 40000 -> 60000		1010 -> 0100
								-- C0000 -> E0000  => 40000 -> 60000		1100 -> 0100
								-- E0000 ->100000  => 40000 -> 60000		1110 -> 0100
								romrd_a(19)<='0';
								romrd_a(18)<=CPU_A(19);
								romrd_a(17)<=CPU_A(17) and not CPU_A(19);
							elsif rom_sz = X"0C" then                    -- bits 19 downto 16
								-- 00000 -> 20000  => 00000 -> 20000		0000 -> 0000
								-- 20000 -> 40000  => 20000 -> 40000		0010 -> 0010
								-- 40000 -> 60000  => 40000 -> 60000		0100 -> 0100
								-- 60000 -> 80000  => 60000 -> 80000		0110 -> 0110
								-- 80000 -> A0000  => 80000 -> A0000		1000 -> 1000
								-- A0000 -> C0000  => A0000 -> C0000		1010 -> 1010
								-- C0000 -> E0000  => 80000 -> A0000		1100 -> 1000
								-- E0000 ->100000  => A0000 -> C0000		1110 -> 1010
								romrd_a(18)<=CPU_A(18) and not CPU_A(19);
							elsif rom_sz = X"08" then                    -- bits 19 downto 16
								romrd_a(19)<='0';
							elsif rom_sz = X"04" then                    -- bits 19 downto 16
								romrd_a(19)<='0';
								romrd_a(18)<='0';
							elsif rom_sz = X"02" then                    -- bits 19 downto 16
								romrd_a(19)<='0';
								romrd_a(18)<='0';
								romrd_a(17)<='0';
							end if;
								

							romrd_a_cached<=(others=>'0');
							romrd_a_cached(19 downto 3) <= CPU_A(19 downto 3);
							ROM_RDY <= '0';
							romState <= ROM_READ;
						end if;
					end if;
				end if;
			when ROM_READ =>
				if romrd_reqReg = romrd_ack then
					ROM_RDY <= '1';
					romrd_q_cached <= romrd_q;
					case CPU_A(2 downto 0) is
						when "000" =>
							ROM_DO <= romrd_q(7 downto 0);
						when "001" =>
							ROM_DO <= romrd_q(15 downto 8);
						when "010" =>
							ROM_DO <= romrd_q(23 downto 16);
						when "011" =>
							ROM_DO <= romrd_q(31 downto 24);
						when "100" =>
							ROM_DO <= romrd_q(39 downto 32);
						when "101" =>
							ROM_DO <= romrd_q(47 downto 40);
						when "110" =>
							ROM_DO <= romrd_q(55 downto 48);
						when "111" =>
							ROM_DO <= romrd_q(63 downto 56);
						when others => null;
					end case;
					romState <= ROM_IDLE;
				end if;
			when others => null;
			end case;
		end if;
	end if;
end process;


-- Block RAM
RAM_A <= CPU_A(12 downto 0);
RAM_DI <= CPU_DO;
process( CLK )
begin
	if rising_edge( CLK ) then
		RAM_WE <= '0';
		if CPU_CLKOUT = '1' and CPU_RAM_SEL_N = '0' and CPU_WR_N = '0' then
			RAM_WE <= '1';
		end if;
	end if;
end process;

-- I/O Port
CPU_IO_DI(7 downto 4) <= "1011"; -- No CD-Rom unit, TGFX-16
CPU_IO_DI(3 downto 0) <=  joy1(7 downto 4)  when CPU_IO_DO(1 downto 0) = "00" and gamepad_port = "000"
							else joy1(1) & joy1(2) & joy1(0) & joy1(3) when CPU_IO_DO(1 downto 0) = "01" and gamepad_port = "000"
							else joy2(7 downto 4)  when CPU_IO_DO(1 downto 0) = "00" and gamepad_port = "001"
							else joy2(1) & joy2(2) & joy2(0) & joy2(3) when CPU_IO_DO(1 downto 0) = "01" and gamepad_port = "001"
							else "1111" when CPU_IO_DO(1) = '0' and (gamepad_port = "010" or gamepad_port = "011" or gamepad_port = "100")
							else "0000";


process(clk)
begin
	if rising_edge(clk) then
		if CPU_IO_DO(1)='1' then -- reset pad
			gamepad_port<=(others => '0');
		elsif prev_sel='0' and CPU_IO_DO(0)='1' and turbotap='1' and gamepad_port /= "101" then -- Rising edge of select bit
			gamepad_port<=gamepad_port+1;
		end if;
		prev_sel<=CPU_IO_DO(0);
	end if;
end process;

end rtl;
