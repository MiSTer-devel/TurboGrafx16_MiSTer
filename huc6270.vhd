-- #############################################################################
-- ################################## TODO #####################################
-- #############################################################################
-- 1) Correct timing of CPU-to-VRAM availability windows
-- 2) Implement rendering of overscan areas (vertical and horizontal).  This
--    implies more correct usage of vertical and horizontal registers
-- 3) Once decapped Hu6270 is understood, validate implementation
-- #############################################################################
-- #############################################################################
-- #############################################################################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity huc6270 is
	generic (
		MAX_SPPL : integer := 15
	);
	port (
		CLK 		: in std_logic;
		RESET_N	: in std_logic;
		HSIZE		: in std_logic_vector(9 downto 0);
		HSTART	: in std_logic_vector(9 downto 0);
		SP64		: in std_logic;

		-- CPU Interface
		A			: in std_logic_vector(1 downto 0);
		CE_N		: in std_logic;
		WR_N		: in std_logic;
		RD_N		: in std_logic;		
		DI			: in std_logic_vector(7 downto 0);
		DO 		: out std_logic_vector(7 downto 0);
		BUSY_N	: out std_logic;
		IRQ_N		: out std_logic;

		-- VCE Interface
		COLNO		: out std_logic_vector(8 downto 0);
		CLKEN		: in std_logic;
		HS_N		: in std_logic;
		VS_N		: in std_logic
	);
end huc6270;

architecture rtl of huc6270 is

--------------------------------------------------------------------------------
-- Registers
--------------------------------------------------------------------------------
--
-- Status register is returned in $FF:$0000
-- ->  Sub-registers:
-- Bit   0   : CR -> Sprite #0 collision interrupt occurred
-- Bit   1   : OR -> Sprite overflow interrupt occurred
-- Bit   2   : RR -> RCR interrupt occurred
-- Bit   3   : DS -> VRAM to SAT DMA completion interrupt occurred
-- Bit   4   : DV -> VRAM to VRAM DMA completion interrupt occurred
-- Bit   5   : VD -> Vertical Blank interrupt occurred
-- Bit   6   : BSY-> VDC waiting for CPU access slot during acive display
-- Bits  7-15: (Unused)


-- VDC Register 00 (W): MAWR = Memory Address Write Register
-- VDC Register 01 (W): MARR = Memory Address Read Register
--
signal VDCREG_MAWR		: std_logic_vector(15 downto 0);
signal VDCREG_MARR		: std_logic_vector(15 downto 0);


-- VDC Register 02 (W): VWR = VRAM Data Write Register
-- VDC Register 02 (R): VRR = VRAM Data Read Register
--
signal VDCREG_VRR		: std_logic_vector(15 downto 0); -- VRAM Read Buffer
signal VDCREG_VWR		: std_logic_vector(15 downto 0); -- VRAM Write Latch

-- VDC Register 03 : Unused
-- VDC Register 04 : Unused


-- VDC Register 05 (W): CR = Control Register
-- ->  Sub-registers:
-- Bits  0- 3: IE = interrupt request enable
--             Bit 0 = CC = Collision Detect
--             Bit 1 = OC = Sprite Overflow Detect
--             Bit 2 = RC = Scanning Line Detect
--             Bit 3 = VC = Vertical Blanking Period Detect
--
-- Bits  4- 5: EX = External Sync:
--             00 = Both /Vsync and /Hsync work as input and are synchronized to external signals
--             01 = /Vsync works as input and is synchronized to external signal (/Hsync works as output)
--             10 = Invalid
--             11 = Both /Vsync and /Hsync work as output
--
-- Bit   6   : SB = Sprite blanking (0=suppress sprites; 1=display sprites)
-- Bit   7   : BB = Background blankng (0=suppress background; 1=display background)
-- Bits  8- 9: TE = Disp output select
-- Bit  10   : DR = Dynamic RAM refresh
-- Bits 11-12: IW = Increment select - read/write register is automatically incremented by:
--             00 = +1
--             01 = +$20
--             10 = +$40
--             11 = +$80

-- Bits 13-15: (Unused)
--
signal VDCREG_CR		: std_logic_vector(15 downto 0);

alias VDCREG_COLL_IRQEN_FLG	: std_logic is VDCREG_CR(0);
alias VDCREG_OVER_IRQEN_FLG	: std_logic is VDCREG_CR(1);
alias VDCREG_RCR_IRQEN_FLG		: std_logic is VDCREG_CR(2);
alias VDCREG_VBLNK_IRQEN_FLG	: std_logic is VDCREG_CR(3);

alias VDCREG_SPRITE_EN_FLG		: std_logic is VDCREG_CR(6);
alias VDCREG_BKGRND_EN_FLG		: std_logic is VDCREG_CR(7);
alias VDCREG_MAWR_RR_INC_SEL	: std_logic_vector(1 downto 0) is VDCREG_CR(12 downto 11);


-- VDC Register 06 (W): (bits 0-9 used) RCR = Raster Counter Register
-- VDC Register 07 (W): (bits 0-9 used) BXR = Background X scroll
-- VDC Register 08 (W): (bits 0-8 used) BYR = Background Y scroll
--
signal VDCREG_RCR		: std_logic_vector(15 downto 0);
signal VDCREG_BXR		: std_logic_vector(15 downto 0);
signal VDCREG_BYR		: std_logic_vector(15 downto 0);

-- VDC Register 09 (W): MWR = Memory Width Register
-- ->  Sub-registers:
-- Bits  0- 1: VM - VRAM Access mode width - how many clocks needed for access: 8-dot pattern as below:
--             00 = 1 cyc = | CPU | BAT | CPU |  -  | CPU | CG0 | CPU | CG1 |
--             01 = 2 cyc = |    BAT    |    CPU    |    CG0    |    CG1    |
--             10 = 2 cyc = |    BAT    |    CPU    |    CG0    |    CG1    |
--             11 = 4 cyc = |          BAT          |       CG0 or CG1      |
--
-- Bits  2- 3: SM - Sprite Access width mode - how many clocks needed for sprite generator access during HBLANK:
--             00 = 1 cyc = | SP0 | SP1 | SP2 | SP3 | SP0 | SP1 | SP2 | SP3 |
--             01 = 2 cyc = |  SP0/SP2  |  SP1/SP3  |  SP0/SP2  |  SP1/SP3  |
--             10 = 2 cyc = |    SP0    |    SP1    |    SP2    |    SP3    |
--             11 = 4 cyc = |        SP0/SP2        |        SP1/SP3        |
--
-- Bit   4- 6: SCREEN - # of characters on virtual screen
--             000 = X= 32, Y= 32
--             001 = X= 64, Y= 32
--             010 = X=128, Y= 32
--             011 = X=128, Y= 32
--             100 = X= 32, Y= 64
--             101 = X= 64, Y= 64
--             110 = X=128, Y= 64
--             111 = X=128, Y= 64
--
-- Bit   7   : CM = CG mode for 4-cycle access: 0 = CH0/CH1, 1 = CH2/CH3
-- Bits  8-15: (Unused)
--
signal VDCREG_MWR		: std_logic_vector(15 downto 0);

alias VDCREG_VRAM_ACCS_WDTH_MODE	: std_logic_vector(1 downto 0) is VDCREG_MWR(1 downto 0);
alias VDCREG_SPRT_ACCS_WDTH_MODE	: std_logic_vector(1 downto 0) is VDCREG_MWR(3 downto 2);
alias VDCREG_VSCRN_XSIZE	: std_logic_vector(1 downto 0) is VDCREG_MWR(5 downto 4);
alias VDCREG_VSCRN_YSIZE	: std_logic is VDCREG_MWR(6);
alias VDCREG_CG_MODE		: std_logic is VDCREG_MWR(7);


-- VDC Register 0A (W): HSR = Horizontal Sync Register
-- ->  Sub-registers:
-- Bits  0- 4: HSW = Horizontal Sync Width
-- Bits  5- 7: (Unused)
-- Bit   8-14: HDS = Horizontal Display Start
-- Bit   15  : (Unused)
--
signal VDCREG_HSR		: std_logic_vector(15 downto 0);

alias VDCREG_HSW	: std_logic_vector(4 downto 0) is VDCREG_HSR( 4 downto 0);
alias VDCREG_HDS	: std_logic_vector(6 downto 0) is VDCREG_HSR(14 downto 8);


-- VDC Register 0B (W): HDR = Horizontal Display Register
-- ->  Sub-registers:
-- Bits  0- 6: HDW = Horizontal Display Width
-- Bits  7   : (Unused)
-- Bit   8-14: HDE = Horizontal Display End
-- Bit   15  : (Unused)
--
signal VDCREG_HDR		: std_logic_vector(15 downto 0);

alias VDCREG_HDW	: std_logic_vector(6 downto 0) is VDCREG_HDR( 6 downto 0);
alias VDCREG_HDE	: std_logic_vector(6 downto 0) is VDCREG_HDR(14 downto 8);


-- VDC Register 0C (W): VSR (aka VPR) = (Vertical Period Register ?)
-- ->  Sub-registers:
-- Bits  0- 4: VSW = Vertical Sync Width
-- Bits  5- 7: (Unused)
-- Bit   8-15: VDS = Vertical Display Start
--
signal VDCREG_VSR		: std_logic_vector(15 downto 0);

alias VDCREG_VSW	: std_logic_vector(4 downto 0) is VDCREG_VSR( 4 downto 0);
alias VDCREG_VDS	: std_logic_vector(7 downto 0) is VDCREG_VSR(15 downto 8);


-- VDC Register 0D (W): (bits 0-8 used) VDR (aka VDW) = Vertical Display Width
--
signal VDCREG_VDR		: std_logic_vector(15 downto 0);

-- VDC Register 0E (W): (bits 0-7 used) VDE (aka VCR) = (Vertical Display End Position ?)
--
signal VDCREG_VDE		: std_logic_vector(15 downto 0);

-- VDC Register 0F (W): DCR = DMA Control Register
-- ->  Sub-registers:
-- Bit   0   : DSC  = VRAM-SATB xfer complete IRQ enable (0=disable)
-- Bit   1   : DVC  = VRAM-VRAM xfer complete IRQ enable (0=disable)
-- Bit   2   : SI/D = VRAM-VRAM source address control:      0=auto-increment, 1=auto=decrement
-- Bit   3   : DI/D = VRAM-VRAM destination address control: 0=auto-increment, 1=auto=decrement
-- Bit   4   : DSR  = VRAM-SATB xfer auto-repeat: 1 = repeat during each VBLANK period
-- Bit   5-15: (Unused)

signal VDCREG_DCR		: std_logic_vector(15 downto 0);

alias VDCREG_SATBDMA_IRQEN_FLG	: std_logic is VDCREG_DCR(0);
alias VDCREG_VRAMDMA_IRQEN_FLG	: std_logic is VDCREG_DCR(1);
alias VDCREG_VRAMDMA_SRCDEC_FLG	: std_logic is VDCREG_DCR(2);
alias VDCREG_VRAMDMA_DSTDEC_FLG	: std_logic is VDCREG_DCR(3);
alias VDCREG_SATBDMA_AUTORPT_FLG	: std_logic is VDCREG_DCR(4);


-- VDC Register 10 (W): SOUR = VRAM-VRAM DMA Source Address
-- VDC Register 11 (W): DESR = VRAM-VRAM DMA Destination Address
-- VDC Register 12 (W): LENR = VRAM-VRAM DMA Length
--
signal VDCREG_SOUR		: std_logic_vector(15 downto 0);
signal VDCREG_DESR		: std_logic_vector(15 downto 0);
signal VDCREG_LENR		: std_logic_vector(15 downto 0);

-- VDC Register 13 (W): DVSSR = VRAM-SATB block transfer source address
--
signal VDCREG_SATB		: std_logic_vector(15 downto 0);

--------------------------------------------------------------------------------
-- Video counting and internal synchronization
--------------------------------------------------------------------------------
-- Registers
signal HDW : std_logic_vector(6 downto 0);

signal RCNT	: std_logic_vector(8 downto 0);


-- Interrupts
signal IRQ_RCR_SET	: std_logic;
signal IRQ_VBL_SET	: std_logic;

-- Intermediate signals
signal X		: std_logic_vector(9 downto 0);
signal Y		: std_logic_vector(8 downto 0);
signal HS_N_PREV	: std_logic;
signal VS_N_PREV	: std_logic;

signal X_BG_START	: std_logic_vector(9 downto 0);
signal X_REN_START	: std_logic_vector(9 downto 0);
signal X_BG_END		: std_logic_vector(9 downto 0);
signal X_REN_END	: std_logic_vector(9 downto 0);
signal Y_BGREN_START	: std_logic_vector(8 downto 0);
signal Y_BGREN_END	: std_logic_vector(8 downto 0);

signal X_BYR_LATCH	: std_logic_vector(9 downto 0);
signal X_BXR_LTCH_DIFF	: std_logic_vector(3 downto 0);

-- signal X_SP_START	: std_logic_vector(9 downto 0);
-- signal X_SP_END		: std_logic_vector(9 downto 0);
signal Y_SP_START	: std_logic_vector(8 downto 0);
signal Y_SP_END		: std_logic_vector(8 downto 0);

signal BG_ACTIVE	: std_logic;
signal SP1_ACTIVE	: std_logic;
signal SP2_ACTIVE	: std_logic;
signal REN_ACTIVE	: std_logic;
signal DBG_VBL		: std_logic;
signal DCR_DMAS_REQ		: std_logic;

signal SP_ON		: std_logic;
signal BG_ON		: std_logic;
signal BURST		: std_logic;
signal FSTNONDISP	: std_logic;	-- first non-display line. Blank, same as when BG_ON and SP_ON = 0
signal VSYNCFIRST	: std_logic;	-- first line of VSYNC; not part of line count


--------------------------------------------------------------------------------
-- Background engine
--------------------------------------------------------------------------------
-- Pseudo-registers
signal BG_VS		: std_logic;
signal BG_HS		: std_logic_vector(1 downto 0);
signal BG_DW		: std_logic_vector(1 downto 0);
signal BG_CM		: std_logic;

-- Intermediate signals - Part 1
signal BG_Y			: std_logic_vector(8 downto 0);
signal BG_TX		: std_logic_vector(6 downto 0);
signal TX			: std_logic_vector(6 downto 0);
signal TX_MAX		: std_logic_vector(6 downto 0);
signal BG_PX		: std_logic_vector(9 downto 0);
signal BG_PAL		: std_logic_vector(3 downto 0);
signal BG_P01		: std_logic_vector(15 downto 0);
signal BG_P23		: std_logic_vector(15 downto 0);

signal YOFS			: std_logic_vector(8 downto 0);
signal YOFS_RELOAD	: std_logic;
signal YOFS_REL_REQ	: std_logic;
signal YOFS_REL_ACK	: std_logic;
signal XOFS			: std_logic_vector(9 downto 0);

-- State machine - Part 1
type bg1_t is ( BG1_INI, BG1_INI_W,
				BG1_CPU, BG1_CPU_W, 
				BG1_BAT, BG1_BAT_W,
				BG1_NOP, BG1_NOP_W,
				BG1_CG0, BG1_CG0_W,
				BG1_CG1, BG1_CG1_W,
				BG1_END );
signal BG1			: bg1_t;		
signal BG_CYC		: std_logic_vector(2 downto 0);
signal BG_BUSY		: std_logic;
signal BG_BUSY2		: std_logic;

-- Intermediate signals - Part 2
signal BG2_REQ		: std_logic;
signal BG2_INI_REQ	: std_logic;

signal BG2_MEM_A	: std_logic_vector(9 downto 0);
signal BG2_MEM_WE	: std_logic;
signal BG2_MEM_DI	: std_logic_vector(7 downto 0);
signal BG2_PAL		: std_logic_vector(3 downto 0);
signal BG2_P0		: std_logic_vector(7 downto 0);
signal BG2_P1		: std_logic_vector(7 downto 0);
signal BG2_P2		: std_logic_vector(7 downto 0);
signal BG2_P3		: std_logic_vector(7 downto 0);
signal TPX			: std_logic_vector(2 downto 0);

-- State machine - Part 2
type bg2_t is ( BG2_INI, BG2_WRITE, BG2_LOOP );
signal BG2			: bg2_t;		

-- Background engine - RAM access signals
signal BG_RAM_A_FF		: std_logic_vector(15 downto 0);
signal BG_RAM_REQ_FF	: std_logic := '0';
signal BG_RAM_DO		: std_logic_vector(15 downto 0);
signal BG_RAM_ACK		: std_logic;


--------------------------------------------------------------------------------
-- Sprite engine
--------------------------------------------------------------------------------
-- Pseudo-registers
signal SP_DW	: std_logic_vector(1 downto 0);

-- Interrupts
signal IRQ_COL_SET	: std_logic;
signal IRQ_COL_TRIG	: std_logic;
signal IRQ_OVF_SET	: std_logic;

-- Intermediate signals - Part 1
signal SP_NB	: std_logic_vector(6 downto 0);
signal SP_CUR_Y	: std_logic_vector(9 downto 0);
signal SP_Y		: std_logic_vector(9 downto 0);
signal SP_X		: std_logic_vector(9 downto 0);
signal SP_CG	: std_logic;
signal SP_NAME	: std_logic_vector(9 downto 0);
signal SP_VF	: std_logic;
signal SP_CGY	: std_logic_vector(1 downto 0);
signal SP_HF	: std_logic;
signal SP_CGX	: std_logic;
signal SP_PRI	: std_logic;
signal SP_PAL	: std_logic_vector(3 downto 0);

-- Sprite pre-buffers
type sp_prebuf_entry_t is
	record
		-- Information that will be copied as is in the Sprite buffers
		ZERO	: std_logic;
		PRI		: std_logic;
		PAL		: std_logic_vector(3 downto 0);
		HF		: std_logic;
		X		: std_logic_vector(9 downto 0);		
		-- Information required to fill the P0-P3 buffers
		CG		: std_logic;
		ADDR	: std_logic_vector(15 downto 0);
	end record;
type sp_prebuf_t is array(0 to MAX_SPPL) of sp_prebuf_entry_t;
signal SP_PREBUF	: sp_prebuf_t;

-- Sprite engine - SAT access signals
signal SP_SAT_A		: std_logic_vector(7 downto 0);
signal SP_SAT_DO	: std_logic_vector(15 downto 0);

-- State machine - Part 1
type sp1_t is ( SP1_INI, 
				SP1_RD0, SP1_RD1, SP1_RD2, SP1_RD3, SP1_TST,
				SP1_LEFT, SP1_RIGHT,
				SP1_LOOP, SP1_END );
signal SP1			: sp1_t;
signal SP1_CNT	: std_logic_vector(1 downto 0);



-- Intermediate signals - Part 2
signal SP_CUR	: std_logic_vector(5 downto 0);

-- Sprite buffers
type sp_buf_entry_t is
	record
		ZERO	: std_logic;
		PRI		: std_logic;
		PAL		: std_logic_vector(3 downto 0);
		HF		: std_logic;
		X		: std_logic_vector(9 downto 0);
		
		P0		: std_logic_vector(15 downto 0);
		P1		: std_logic_vector(15 downto 0);
		P2		: std_logic_vector(15 downto 0);
		P3		: std_logic_vector(15 downto 0);
	end record;
type sp_buf_t is array(0 to MAX_SPPL) of sp_buf_entry_t;
signal SP_BUF	: sp_buf_t;

-- Sprite engine - RAM access signals
signal SP_RAM_A_FF		: std_logic_vector(15 downto 0);
signal SP_RAM_REQ_FF	: std_logic := '0';
signal SP_RAM_DO		: std_logic_vector(15 downto 0);
signal SP_RAM_ACK		: std_logic;

-- State machine - Part 2
type sp2_t is ( SP2_INI, SP2_INI_W,
				SP2_RD0, SP2_RD0_W,
				SP2_RD1, SP2_RD1_W,
				SP2_RD2, SP2_RD2_W,
				SP2_RD3, SP2_RD3_W,
				SP2_END );
signal SP2	: sp2_t;
signal SP_BUSY		: std_logic;
signal SP_CYC		: std_logic_vector(1 downto 0);

--------------------------------------------------------------------------------
-- Line rendering
--------------------------------------------------------------------------------
-- Intermediate signals
signal REN_MEM_A	: std_logic_vector(9 downto 0);
signal REN_MEM_WE	: std_logic;
signal REN_MEM_DO	: std_logic_vector(7 downto 0);

signal REN_BG_COL	: std_logic_vector(7 downto 0);
signal REN_SP_OPQ	: std_logic_vector(MAX_SPPL downto 0); -- Sprite pixel on/off
constant SP_OPQ_Z : std_logic_vector(MAX_SPPL downto 0) := (others => '0');
type ren_sp_col_t is array(MAX_SPPL downto 0) of std_logic_vector(8 downto 0); -- PRI & PAL & COL
signal REN_SP_COLTAB	: ren_sp_col_t;

-- State machine
type ren_t is ( REN_INI, REN_BGR, REN_BGW, REN_CLK );
signal REN			: ren_t;		

-- Output buffers
signal COLNO_FF		: std_logic_vector(8 downto 0);

--------------------------------------------------------------------------------
-- CPU Interface
--------------------------------------------------------------------------------
signal PREV_A			: std_logic_vector(1 downto 0);

signal CPU_SOUR_SET_REQ	: std_logic;
signal CPU_SOUR_SET_VAL	: std_logic_vector(15 downto 0);

signal CPU_DESR_SET_REQ	: std_logic;
signal CPU_DESR_SET_VAL	: std_logic_vector(15 downto 0);

signal CPU_LENR_SET_REQ	: std_logic;
signal CPU_LENR_SET_VAL	: std_logic_vector(15 downto 0);

signal CPU_IRQ_CLR		: std_logic;
signal CPU_DMAS_REQ		: std_logic;
signal CPU_DMA_REQ		: std_logic;

signal RD_BUF		: std_logic_vector(15 downto 0);
signal WR_BUF		: std_logic_vector(15 downto 0);
signal REG_SEL		: std_logic_vector(4 downto 0);

-- Interrupts
signal IRQ_COL		: std_logic;
signal IRQ_OVF		: std_logic;
signal IRQ_RCR		: std_logic;
signal IRQ_DMAS		: std_logic;
signal IRQ_DMA		: std_logic;
signal IRQ_VBL		: std_logic;

-- RAM access signals
signal CPU_RAM_REQ_FF		: std_logic := '0';
signal CPU_RAM_A_FF		: std_logic_vector(15 downto 0);
signal CPU_RAM_DI_FF		: std_logic_vector(15 downto 0);
signal CPU_RAM_WE_FF		: std_logic := '0';
signal CPU_RAM_DO		: std_logic_vector(15 downto 0);
signal CPU_RAM_ACK	: std_logic;

-- Output buffers
signal DO_FF		: std_logic_vector(7 downto 0);
signal BUSY_N_FF	: std_logic;
signal IRQ_N_FF		: std_logic;

-- State machine
type cpu_t is ( CPU_IDLE,
				CPU_RAM_RD, CPU_RAM_PRE_RD,
				CPU_RAM_WR_INC, CPU_RAM_PRE_WR_INC,
				CPU_WAIT );
signal CPU			: cpu_t;

--------------------------------------------------------------------------------
-- VRAM-VRAM DMA
--------------------------------------------------------------------------------
signal DMA_REQ			: std_logic;

signal DMA_DMA_CLR		: std_logic;
signal IRQ_DMA_SET		: std_logic;

signal DMA_BUSY			: std_logic;

signal DMA_RAM_REQ_FF		: std_logic := '0';
signal DMA_RAM_A_FF		: std_logic_vector(15 downto 0);
signal DMA_RAM_DI_FF		: std_logic_vector(15 downto 0);
signal DMA_RAM_WE_FF		: std_logic := '0';
signal DMA_RAM_DO		: std_logic_vector(15 downto 0);
signal DMA_RAM_ACK	: std_logic;

signal DMA_SOUR_SET_REQ	: std_logic;
signal DMA_DESR_SET_REQ	: std_logic;
signal DMA_LENR_SET_REQ	: std_logic;

-- State machine
type dma_t is (	DMA_IDLE,
				DMA_READ, DMA_READ1, DMA_READ2,
				DMA_WRITE, DMA_WRITE1, DMA_WRITE2,
				DMA_LOOP, DMA_LOOP2 );
signal DMA	: dma_t;

--------------------------------------------------------------------------------
-- VRAM-SAT DMA
--------------------------------------------------------------------------------
signal DMAS_REQ			: std_logic;

signal DMAS_DMAS_CLR	: std_logic;
signal IRQ_DMAS_SET		: std_logic;

signal DMAS_BUSY		: std_logic;

signal DMAS_RAM_REQ_FF		: std_logic := '0';
signal DMAS_RAM_A_FF		: std_logic_vector(15 downto 0);
signal DMAS_RAM_DO	: std_logic_vector(15 downto 0);
signal DMAS_RAM_ACK	: std_logic;

signal DMAS_SAT_A		: std_logic_vector(7 downto 0);
signal DMAS_SAT_DI		: std_logic_vector(15 downto 0);
signal DMAS_SAT_WE		: std_logic := '0';

-- State machine
type dmas_t is (	DMAS_IDLE,
					DMAS_READ, DMAS_READ1, DMAS_READ2,
					DMAS_WRITE,
					DMAS_WAIT1, DMAS_WAIT2,
					DMAS_END );
signal DMAS	: dmas_t;

begin

--------------------------------------------------------------------------------
-- Background line buffer
--------------------------------------------------------------------------------

bg_buf : entity work.dpram generic map (10,8)
port map(
	clock		=> CLK,

	address_a=> BG2_MEM_A,
	data_a	=> BG2_MEM_DI,
	wren_a	=> BG2_MEM_WE,
	q_a		=> open,

	address_b=> REN_MEM_A,
	data_b	=> "00000000",
	wren_b	=> REN_MEM_WE,
	q_b		=> REN_MEM_DO
);

--------------------------------------------------------------------------------
-- SAT
--------------------------------------------------------------------------------
sat : entity work.dpram generic map (8,16)
port map(
	clock		=> CLK,
	
	data_a	=> DMAS_SAT_DI,
	address_a=> DMAS_SAT_A,
	wren_a	=> DMAS_SAT_WE,
	
	address_b=> SP_SAT_A,
	q_b		=> SP_SAT_DO
);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Video counting and internal synchronization
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
process( CLK )

variable V_HSW : std_logic_vector(9 downto 0);
variable V_HDS : std_logic_vector(9 downto 0);
variable V_HDE : std_logic_vector(6 downto 0);
variable V_HDW : std_logic_vector(9 downto 0);

variable V_VDS : std_logic_vector(8 downto 0);
variable V_VDE : std_logic_vector(8 downto 0);
variable V_VSW : std_logic_vector(5 downto 0);
variable V_VDW : std_logic_vector(8 downto 0);
variable V_VCR : std_logic_vector(7 downto 0);

begin
	if rising_edge(CLK) then
		IRQ_RCR_SET <= '0';
		IRQ_VBL_SET <= '0';
		YOFS_REL_ACK <= '0';
	
		if RESET_N = '0' then
			X <= (others => '0');
			Y <= (others => '1'); -- /!\
			
			HS_N_PREV <= '1';
			VS_N_PREV <= '0';

			BG_ACTIVE <= '0';
			SP1_ACTIVE <= '0';
			SP2_ACTIVE <= '0';
			REN_ACTIVE <= '0';
			DCR_DMAS_REQ <= '0';
			
			X_BG_START <= (others => '1');
			X_REN_START <= (others => '1');
			-- X_BG_END <= (others => '1');
			X_REN_END <= (others => '1');
			
			Y_BGREN_START <= (others => '1');
			Y_BGREN_END <= (others => '1');
			
			X_BYR_LATCH <= (others => '1');
			
			-- X_SP_START <= (others => '1');
			-- X_SP_END <= (others => '1');
			Y_SP_START <= (others => '1');
			Y_SP_END <= (others => '1');

			RCNT <= (others => '1');

			SP_ON <= '0';
			BG_ON <= '0';
			BURST <= '1';
			FSTNONDISP <= '0';
			VSYNCFIRST <= '0';

			YOFS <= (others => '0');
		else
			if CLKEN = '1' then
				HS_N_PREV <= HS_N;
				X <= X + 1;

				DCR_DMAS_REQ <= '0';

				if HS_N_PREV = '1' and HS_N = '0' then		-- start of HSYNC
					X <= (others => '0');
				end if;

				if HS_N_PREV = '0' and HS_N = '1' then		-- End of HSYNC

					--V_HDS := VDCREG_HSR(14 downto 8)&"000";
					V_HDW := (VDCREG_HDW + "1") & "000";

					if V_HDW >= HSIZE then 
						V_HDS := (others => '0');
						V_HDW := HSIZE;
					else
						V_HDS := HSIZE - V_HDW;
					end if;
					V_HDS := '0'&V_HDS(9 downto 1) + HSTART - 1;

					--V_HDS := VDCREG_HSR(4 downto 0);
					--V_HDE := VDCREG_HDR(14 downto 8);

					HDW <= VDCREG_HDW;

					X_REN_START <= V_HDS;
					X_REN_END   <= V_HDS + V_HDW;
					-- BG must start before REN (max 2*8 tile reads, plus render overhead)
					X_BG_START  <= V_HDS - "10101";

					-- Latches happen before display starts
					-- So, latch at start of render engine
					
					-- Several cycles are needed before render.  I'm not sure whether it's required for
					-- reasons of software or hardware, but if it's any later, Outrun gets double-lines
					-- and other titles get horizontal white lines near RCR interrupt areas.
					-- note that the number of cycles may depend on

					-- note that CR may also need to be latched at transition from HSync to HDS
					-- perhaps check for BURST mode here, at this transition, on every line
					
					if (V_HDS - "10101") > 6 then
						X_BYR_LATCH     <= V_HDS - "10101" - 6;
					else
						X_BYR_LATCH     <= "0000000010";		-- 2
					end if;
					
					X_BXR_LTCH_DIFF <= x"1";

					-- Raster counter
					RCNT <= RCNT + 1;
					if Y = Y_BGREN_START-1 then
						RCNT <= "0" & x"40";
					end if;

				end if;


				if Y >= Y_BGREN_START and Y < Y_BGREN_END and VDCREG_BKGRND_EN_FLG = '1' then

					if X = X_BYR_LATCH then
						YOFS_REL_ACK <= '1';
						if Y = Y_BGREN_START then
							YOFS <= VDCREG_BYR(8 downto 0);
						elsif YOFS_RELOAD = '1' then
							YOFS <= VDCREG_BYR(8 downto 0) + 1;
						else
							YOFS <= YOFS + 1;
						end if;
					end if;

					if X = X_BYR_LATCH + X_BXR_LTCH_DIFF then			-- BXR is latched 1 cycle later than BYR
						XOFS <= VDCREG_BXR(9 downto 0);
					end if;
					
				end if;
				
				if X = X_BG_START-1 then
					SP2_ACTIVE <= '0';
					BG_ON <= VDCREG_BKGRND_EN_FLG;

					-- VBlank Interrupt
					if Y = Y_BGREN_END and VDCREG_VBLNK_IRQEN_FLG = '1' then
						IRQ_VBL_SET <= '1';
						FSTNONDISP <= '1';			-- first line after displayable area is dark.
															-- May need to come back later and disable render for that line
					else
						FSTNONDISP <= '0';
					end if;


					if Y >= Y_BGREN_START and Y < Y_BGREN_END and VDCREG_BKGRND_EN_FLG = '1' then
						BG_ACTIVE <= '1';
					end if;
				end if;

				if X = X_REN_START-1 then
					SP_ON <= VDCREG_SPRITE_EN_FLG;
					if Y >= Y_BGREN_START and Y < Y_BGREN_END then
						REN_ACTIVE <= '1';
					end if;

					if Y >= Y_SP_START and Y < Y_SP_END and VDCREG_SPRITE_EN_FLG = '1' then
						SP1_ACTIVE <= '1';
					end if;


					-- Burst Mode
					-- Shouldn't VDCREG_CR(7 downto 6)be checked every visible line according to doc?
					if Y = Y_BGREN_START then
						if VDCREG_BKGRND_EN_FLG = '0' and VDCREG_SPRITE_EN_FLG = '0' then
							BURST <= '1';
						else
							BURST <= '0';
						end if;
					end if;
				end if;

				if X = X_REN_END - 13 then
					if RCNT = VDCREG_RCR(9 downto 0) and VDCREG_RCR_IRQEN_FLG = '1' then
						IRQ_RCR_SET <= '1';
					end if;
				end if;

				if X = X_REN_END-1 then
					BG_ACTIVE <= '0';
					REN_ACTIVE <= '0';
					SP1_ACTIVE <= '0';

					Y <= Y + 1;
					if (VSYNCFIRST = '1') then
						Y <= (others => '0');
					end if;

					VS_N_PREV <= VS_N;
					if VS_N_PREV = '1' and VS_N = '0' then		-- start of VSYNC signal
					
						VSYNCFIRST <= '1';							-- first line of VSYNC is non-counted

						V_VDS := ('0' & VDCREG_VDS) + 1;
						V_VSW := ('0' & VDCREG_VSW) + 1;
						V_VDW := VDCREG_VDR(8 downto 0);
						if V_VDW > 262 then
							-- some games use 1FF value for VDW which overflows calculations below
							-- thus limit it to max possible value.
							V_VDW := std_logic_vector(to_unsigned(262,9));
						end if;

						--V_VCR := VDCREG_VDE(7 downto 0);

						V_VDS := V_VDS + V_VSW;
						V_VDE := V_VDS + V_VDW + 1;

						-- Make sure display ends before vsync and there is at least 1 blank line at the end
						-- possible Y values 0..262 (limited by ext VS_N)
						if V_VDE > 262 then
							V_VDE := std_logic_vector(to_unsigned(262,9));
						end if;

						Y_BGREN_START <= V_VDS;
						Y_BGREN_END   <= V_VDE;
						Y_SP_START    <= V_VDS - 1;   -- SP1 state machine starts on line before BG REN
						Y_SP_END      <= V_VDE;

					else
						VSYNCFIRST <= '0';
					end if;

					if Y = Y_BGREN_END+1 then
						BURST <= '1';
						if VDCREG_SATBDMA_AUTORPT_FLG = '1' then -- Auto SATB DMA
							DCR_DMAS_REQ <= '1';
						end if;
					end if;

					if Y >= Y_SP_START-1 and Y < Y_SP_END-1 and SP_ON = '1' then
						SP2_ACTIVE <= '1';
					end if;
				end if;

			end if; -- CLKEN
		end if;
	end if;
end process;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Background engine
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BG_VS <= VDCREG_VSCRN_YSIZE;	-- virtual screen size (Y): 0 = 32, 1 = 64
BG_HS <= VDCREG_VSCRN_XSIZE;	-- virtual screen size (X): 0 = 32, 1 = 64, 2 = 128, 3 = 128
BG_DW <= VDCREG_VRAM_ACCS_WDTH_MODE; 
-- BG_DW <= "11";
BG_CM <= VDCREG_CG_MODE;
-- BG_CM <= '1';

--------------------------------------------------------------------------------
-- Background engine - Part 1
--------------------------------------------------------------------------------
process( CLK )

variable V_BG_Y	: std_logic_vector(8 downto 0);
variable V_BG_X_TX : std_logic_vector(6 downto 0);

begin
	if rising_edge(CLK) then
	
		BG2_INI_REQ <= '0';
		BG2_REQ <= '0';

		if RESET_N = '0' then
			BG1 <= BG1_INI;
			
			BG_RAM_REQ_FF <= '0';
			
			BG_BUSY <= '0';			
			--BG_BUSY2 <= '0';			
		else			
			case BG1 is
			when BG1_INI =>
				BG_BUSY <= '0';
				--BG_BUSY2 <= '0';			
				
				if BG_ACTIVE = '1' then
					BG_BUSY <= '1';
					--BG_BUSY2 <= '1';
					
					-- V_BG_Y := Y - Y_BGREN_START + VDCREG_BYR(8 downto 0);
					V_BG_Y := YOFS;
					if BG_VS = '0' then
						BG_Y <= "0" & V_BG_Y(7 downto 0);
					else
						BG_Y <= V_BG_Y;
					end if;
					BG_TX <= XOFS(9 downto 3);
				
					BG_PX <= X_REN_START - ("0000000" & XOFS(2 downto 0));
					
					TX <= (others => '0');
					if XOFS(2 downto 0) = "000" then
						TX_MAX <= HDW;
					else
						TX_MAX <= HDW + 1;
					end if;
				
					BG2_INI_REQ <= '1';
				
					BG_CYC <= "000";
					BG1 <= BG1_INI_W;
				end if;
			
			when BG1_INI_W =>
				if CLKEN = '1' then
					case BG_DW is
					when "00" =>
						BG1 <= BG1_CPU;
					when others =>
						BG1 <= BG1_BAT;
					end case;
				end if;
			
			when BG1_CPU =>
				-- Allow one pending CPU VRAM request to be handled
				BG_BUSY <= '0';
				--BG_BUSY2 <= '0';
				BG1 <= BG1_CPU_W;
			
			when BG1_CPU_W =>
				BG_BUSY <= '1';
				
				if CLKEN = '1' then
					BG_CYC <= BG_CYC + 1;
					case BG_DW is
					when "00" =>
						--BG_BUSY2 <= '1';
						case BG_CYC(2 downto 1) is
						when "00" => BG1 <= BG1_BAT; 
						when "01" => BG1 <= BG1_NOP;
						when "10" => BG1 <= BG1_CG0;
						when "11" => BG1 <= BG1_CG1;
						when others => null;
						end case;
					when others =>
						if BG_CYC = "011" then
							--BG_BUSY2 <= '1';
							BG1 <= BG1_CG0;
						end if;
					end case;
				end if;
						
			when BG1_BAT =>				
				BG_P01 <= x"0000";
				BG_P23 <= x"0000";
				
				V_BG_X_TX := BG_TX + TX;
				case BG_HS is
				when "00" =>
					BG_RAM_A_FF <= "00000" & BG_Y(8 downto 3) & V_BG_X_TX(4 downto 0);
				when "01" =>
					BG_RAM_A_FF <= "0000" & BG_Y(8 downto 3) & V_BG_X_TX(5 downto 0);
				when others =>
					BG_RAM_A_FF <= "000" & BG_Y(8 downto 3) & V_BG_X_TX(6 downto 0);
				end case;
				
				BG_RAM_REQ_FF <= not BG_RAM_REQ_FF;
				BG1 <= BG1_BAT_W;
				
			when BG1_BAT_W =>
				if CLKEN = '1' and BG_RAM_REQ_FF = BG_RAM_ACK then
					
					BG_PAL <= BG_RAM_DO(15 downto 12);
					BG_RAM_A_FF <= BG_RAM_DO(11 downto 0) & "0" & BG_Y(2 downto 0);
				
					BG_CYC <= BG_CYC + 1;
					case BG_DW is
					when "00" => BG1 <= BG1_CPU;
					when "11" => 
						if BG_CYC = "011" then
							BG1 <= BG1_CG1; -- CG0/CG1
						end if;
					when others =>
						if BG_CYC = "001" then
							BG1 <= BG1_CPU;
						end if;
					end case;
				end if;

			when BG1_NOP =>
				BG1 <= BG1_NOP_W;
			
			when BG1_NOP_W =>
				if CLKEN = '1' then
					BG_CYC <= BG_CYC + 1;
					BG1 <= BG1_CPU;
				end if;
				
			when BG1_CG0 =>
				BG_RAM_REQ_FF <= not BG_RAM_REQ_FF;
				BG1 <= BG1_CG0_W;
			
			when BG1_CG0_W =>
				if CLKEN = '1' and BG_RAM_REQ_FF = BG_RAM_ACK then
					BG_P01 <= BG_RAM_DO;
					
					BG_CYC <= BG_CYC + 1;
					case BG_DW is
					when "00" => BG1 <= BG1_CPU;
					when "11" => BG1 <= BG1_CG1; -- Just in case
					when others =>
						if BG_CYC = "101" then
							BG1 <= BG1_CG1;
						end if;
					end case;
				end if;
			
			when BG1_CG1 =>
				BG_RAM_REQ_FF <= not BG_RAM_REQ_FF;
				if BG_DW = "11" and BG_CM = '0' then
					BG_RAM_A_FF(3) <= '0';
				else
					BG_RAM_A_FF(3) <= '1';
				end if;
				BG1 <= BG1_CG1_W;

			when BG1_CG1_W =>				
				if CLKEN = '1' and BG_RAM_REQ_FF = BG_RAM_ACK then					
					if BG_DW = "11" and BG_CM = '0' then
						BG_P01 <= BG_RAM_DO;
					else
						BG_P23 <= BG_RAM_DO;
					end if;
										
					BG_CYC <= BG_CYC + 1;
					case BG_DW is
					when "00" =>
						TX <= TX + 1;
						BG2_REQ <= '1';
						if TX = TX_MAX then
							BG1 <= BG1_END;
						else
							BG1 <= BG1_CPU;
						end if;
					when others =>
						if BG_CYC = "111" then
							TX <= TX + 1;
							BG2_REQ <= '1';
							if TX = TX_MAX then
								BG1 <= BG1_END;
							else
								BG1 <= BG1_BAT;
							end if;
						end if;
					end case;
				end if;
				
			when BG1_END =>
				BG_BUSY <= '0';
				--BG_BUSY2 <= '0';
				if BG_ACTIVE = '0' then
					BG1 <= BG1_INI;
				end if;
			
			when others => null;
			end case;
		end if;
	end if;
end process;

--------------------------------------------------------------------------------
-- Background engine - Part 2
--------------------------------------------------------------------------------
process( CLK )
begin
	if rising_edge(CLK) then
		if RESET_N = '0' then
			BG2_MEM_WE <= '0';
		
			BG2 <= BG2_INI;
		else
			case BG2 is
			when BG2_INI =>
				BG2_MEM_WE <= '0';
				
				if BG2_INI_REQ = '1' then
					BG2_MEM_A <= BG_PX;
				end if;
				if BG2_REQ = '1' then
					TPX <= "111";
					
					BG2_PAL <= BG_PAL;
					BG2_P1 <= BG_P01(15 downto 8);
					BG2_P0 <= BG_P01(7 downto 0);
					BG2_P3 <= BG_P23(15 downto 8);
					BG2_P2 <= BG_P23(7 downto 0);
					
					BG2 <= BG2_WRITE;
				end if;
			
			when BG2_WRITE =>
				BG2_MEM_DI <= BG2_PAL 
					& BG2_P3(conv_integer(TPX)) 
					& BG2_P2(conv_integer(TPX)) 
					& BG2_P1(conv_integer(TPX)) 
					& BG2_P0(conv_integer(TPX));
				if (BG2_MEM_A >= X_REN_START) and (BG2_MEM_A < X_REN_END) then
					BG2_MEM_WE <= '1';
				end if;
				BG2 <= BG2_LOOP;
								
			when BG2_LOOP =>
				BG2_MEM_WE <= '0';
				TPX <= TPX - 1;
				BG2_MEM_A <= BG2_MEM_A + 1;
				if TPX = "000" then
					BG2 <= BG2_INI;
				else
					BG2 <= BG2_WRITE;
				end if;
			
			when others => null;
			end case;
		end if;
	end if;
end process;




--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Sprite engine
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
SP_DW <= VDCREG_SPRT_ACCS_WDTH_MODE;

--------------------------------------------------------------------------------
-- Sprite engine - Part 1
--------------------------------------------------------------------------------
process( CLK )
variable V_SP_H		: std_logic_vector(8 downto 0);
variable V_SP_NAME	: std_logic_vector(9 downto 0);
variable V_Y_OFS 	: std_logic_vector(9 downto 0);
begin
	if rising_edge(CLK) then
		
		IRQ_OVF_SET <= '0';
		
		if RESET_N = '0' then
			SP1 <= SP1_INI;			
			SP_NB <= "0000000";
		else
			case SP1 is
			when SP1_INI =>
				if SP1_ACTIVE = '1' then
					SP_NB <= "0000000";					
					SP_CUR_Y <= ("0" & Y) - ("0" & Y_SP_START) + 64;
					SP_SAT_A <= "000000" & "11";
					
					SP1_CNT <= "00";
					SP1 <= SP1_RD0;
				end if;
			
			when SP1_RD0 =>
				SP_SAT_A(1 downto 0) <= "00";
				SP1_CNT <= SP1_CNT + 1;
				if SP1_CNT = "11" then
					SP1_CNT <= "00";
					SP_Y <= SP_SAT_DO(9 downto 0);
					SP1 <= SP1_RD3;
				end if;
				
			when SP1_RD3 =>
				SP_SAT_A(1 downto 0) <= "11";
				SP1_CNT <= SP1_CNT + 1;
				if SP1_CNT = "11" then
					SP1_CNT <= "00";
					SP_VF <= SP_SAT_DO(15);
					SP_CGY <= SP_SAT_DO(13 downto 12);
					SP_HF <= SP_SAT_DO(11);
					SP_CGX <= SP_SAT_DO(8);
					SP_PRI <= SP_SAT_DO(7);
					SP_PAL <= SP_SAT_DO(3 downto 0);
					SP1 <= SP1_TST;
				end if;
			
			when SP1_TST =>
				case SP_CGY is
				when "00" =>
					V_SP_H := "000010000";
				when "01" =>
					V_SP_H := "000100000";
				when others =>
					V_SP_H := "001000000";
				end case;

				if ( SP_CUR_Y >= SP_Y) and ( SP_CUR_Y < SP_Y + V_SP_H) then
					if (SP_NB = "0010000" and SP64 = '0') or SP_NB = "1000000" then 
						SP_NB <= "1111111"; -- Overflow
						if VDCREG_OVER_IRQEN_FLG = '1' then
							IRQ_OVF_SET <= '1';
						end if;
						SP1 <= SP1_END;
					else
						SP1 <= SP1_RD1;
					end if;
				else
					SP1 <= SP1_LOOP;
				end if;
			
			when SP1_RD1 =>
				SP_SAT_A(1 downto 0) <= "01";
				SP1_CNT <= SP1_CNT + 1;
				if SP1_CNT = "11" then
					SP1_CNT <= "00";
					SP_X <= SP_SAT_DO(9 downto 0);
					SP1 <= SP1_RD2;
				end if;
				
			when SP1_RD2 =>
				SP_SAT_A(1 downto 0) <= "10";
				SP1_CNT <= SP1_CNT + 1;
				if SP1_CNT = "11" then
					SP1_CNT <= "00";
					SP_NAME <= SP_SAT_DO(10 downto 1);
					SP_CG <= SP_SAT_DO(0);
					SP1 <= SP1_LEFT;
				end if;
			
			when SP1_LEFT =>
				case SP_CGY is
				when "00" => 
					V_SP_H := "000010000";
				when "01" => 
					V_SP_H := "000100000";
				when others => 
					V_SP_H := "001000000";
				end case;
					
				if SP_VF = '1' then
					V_Y_OFS := V_SP_H + SP_Y - SP_CUR_Y - 1;
				else
					V_Y_OFS := SP_CUR_Y - SP_Y;
				end if;

				V_SP_NAME(9 downto 3) := SP_NAME(9 downto 3);
				
				case SP_CGY is
				when "00" => 				
					V_SP_NAME(2 downto 1) := SP_NAME(2 downto 1);
				when "01" =>
					V_SP_NAME(2) := SP_NAME(2);
					V_SP_NAME(1) := V_Y_OFS(4);
				when others =>
					V_SP_NAME(2 downto 1) := V_Y_OFS(5 downto 4);
				end case;
				
				if SP_CGX = '1' then
					V_SP_NAME(0) := SP_HF;
				else
					V_SP_NAME(0) := SP_NAME(0);
				end if;

				if SP_NB = "0000000" then
					SP_PREBUF(conv_integer(SP_NB(5 downto 0))).ZERO <= '1';
				else
					SP_PREBUF(conv_integer(SP_NB(5 downto 0))).ZERO <= '0';
				end if;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).PRI <= SP_PRI;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).PAL <= SP_PAL;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).X <= SP_X + X_REN_START - 32;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).HF <= SP_HF;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).ADDR <= V_SP_NAME & "00" & V_Y_OFS(3 downto 0);
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).CG <= SP_CG;

				if SP_CGX = '1' then
					if (SP_NB = "0001111" and SP64='0') or SP_NB = "0111111" then
						SP_NB <= "1111111"; -- Overflow
						if VDCREG_OVER_IRQEN_FLG = '1' then
							IRQ_OVF_SET <= '1';
						end if;						
						SP1 <= SP1_END;
					else
						SP_NB <= SP_NB + 1;
						SP1 <= SP1_RIGHT;
					end if;
				else
					SP_NB <= SP_NB + 1;
					SP1 <= SP1_LOOP;
				end if;
			
			when SP1_RIGHT =>
				case SP_CGY is
				when "00" => 
					V_SP_H := "000010000";
				when "01" => 
					V_SP_H := "000100000";
				when others => 
					V_SP_H := "001000000";
				end case;
									
				if SP_VF = '1' then
					V_Y_OFS := V_SP_H + SP_Y - SP_CUR_Y - 1;
				else
					V_Y_OFS := SP_CUR_Y - SP_Y;
				end if;

				V_SP_NAME(9 downto 3) := SP_NAME(9 downto 3);
				case SP_CGY is
				when "00" => 				
					V_SP_NAME(2 downto 1) := SP_NAME(2 downto 1);
				when "01" =>
					V_SP_NAME(2) := SP_NAME(2);
					V_SP_NAME(1) := V_Y_OFS(4);
				when others =>
					V_SP_NAME(2 downto 1) := V_Y_OFS(5 downto 4);
				end case;
				V_SP_NAME(0) := not SP_HF;

				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).ZERO <= '0';
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).PRI <= SP_PRI;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).PAL <= SP_PAL;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).X <= SP_X + X_REN_START - 32 + 16;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).HF <= SP_HF;
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).ADDR <= V_SP_NAME & "00" & V_Y_OFS(3 downto 0);
				SP_PREBUF(conv_integer(SP_NB(5 downto 0))).CG <= SP_CG;

				SP_NB <= SP_NB + 1;
				SP1 <= SP1_LOOP;
			
			when SP1_LOOP =>
				SP_SAT_A(7 downto 2) <= SP_SAT_A(7 downto 2) + 1;
				if SP_SAT_A(7 downto 2) = "111111" then
					SP1 <= SP1_END;
				else
					SP1 <= SP1_RD0;
				end if;
			
			when SP1_END =>
				if SP1_ACTIVE = '0' then
					SP1 <= SP1_INI;
				end if;
			
			when others => null;
			end case;
		end if;
	end if;
end process;

--------------------------------------------------------------------------------
-- Sprite engine - Part 2
--------------------------------------------------------------------------------
process( CLK )
variable V_ADDR		: std_logic_vector(15 downto 0);
begin
	if rising_edge(CLK) then
		if RESET_N = '0' then
			SP2 <= SP2_INI;
			
			SP_BUSY <= '0';
			SP_RAM_REQ_FF <= '0';
		else
			case SP2 is
			when SP2_INI =>
				SP_BUSY <= '0';
				if SP2_ACTIVE = '1' or SP_ON = '0' then
					for I in 0 to MAX_SPPL loop
						SP_BUF(I).X <= "1111111100"; -- Set off-screen
					end loop;
				end if;
				if SP2_ACTIVE = '1' then
					SP_BUSY <= '1';
					SP_CYC <= "00";
					
					SP_CUR <= "000000";
			
					SP2 <= SP2_INI_W;
				end if;

			when SP2_INI_W =>
				if CLKEN = '1' then
					if SP_NB /= "0000000" then
						SP2 <= SP2_RD0;
					else
						SP2 <= SP2_END;
					end if;
				end if;
				
			when SP2_RD0 =>
				V_ADDR := SP_PREBUF(conv_integer(SP_CUR)).ADDR;
			
				SP_CYC <= "00";
				
				SP_BUF(conv_integer(SP_CUR)).ZERO <= SP_PREBUF(conv_integer(SP_CUR)).ZERO;
				SP_BUF(conv_integer(SP_CUR)).PRI <= SP_PREBUF(conv_integer(SP_CUR)).PRI;
				SP_BUF(conv_integer(SP_CUR)).PAL <= SP_PREBUF(conv_integer(SP_CUR)).PAL;
				SP_BUF(conv_integer(SP_CUR)).HF <= SP_PREBUF(conv_integer(SP_CUR)).HF;
				-- X will be set at the end
				
				SP_BUF(conv_integer(SP_CUR)).P0 <= (others => '0');
				SP_BUF(conv_integer(SP_CUR)).P1 <= (others => '0');
				SP_BUF(conv_integer(SP_CUR)).P2 <= (others => '0');
				SP_BUF(conv_integer(SP_CUR)).P3 <= (others => '0');
				
				if SP_DW(0) = '1' and SP_PREBUF(conv_integer(SP_CUR)).CG = '1' then
					SP_RAM_A_FF <= V_ADDR(15 downto 6) & "10" & V_ADDR(3 downto 0);
				else
					SP_RAM_A_FF <= V_ADDR;
				end if;
				if SP2_ACTIVE = '1' then
					SP_RAM_REQ_FF <= not SP_RAM_REQ_FF;
					SP2 <= SP2_RD0_W;
				else
					SP2 <= SP2_END;
				end if;
			
			when SP2_RD0_W =>
				if SP_RAM_REQ_FF = SP_RAM_ACK then
					if SP2_ACTIVE = '0' then
						SP2 <= SP2_END;					
					else
						SP_CYC <= SP_CYC + 1;
						case SP_DW is
						when "00" =>
							SP_BUF(conv_integer(SP_CUR)).P0 <= SP_RAM_DO;
							SP2 <= SP2_RD1;
						when "01" =>
							if SP_CYC = "01" then
								SP_BUF(conv_integer(SP_CUR)).P0 <= SP_RAM_DO;
								SP2 <= SP2_RD3; -- /!\
							end if;
						when "10" => -- | "01" =>
							if SP_CYC = "01" then
								SP_BUF(conv_integer(SP_CUR)).P0 <= SP_RAM_DO;
								SP2 <= SP2_RD1;
							end if;
						when others =>
							if SP_CYC = "11" then
								if SP_PREBUF(conv_integer(SP_CUR)).CG = '1' then
									SP_BUF(conv_integer(SP_CUR)).P2 <= SP_RAM_DO;
								else
									SP_BUF(conv_integer(SP_CUR)).P0 <= SP_RAM_DO;
								end if;
								SP2 <= SP2_RD3; -- /!\
							end if;
						end case;
					end if;
				end if;
			
			when SP2_RD1 =>
				V_ADDR := SP_PREBUF(conv_integer(SP_CUR)).ADDR;
			
				SP_CYC <= "00";
			
				SP_RAM_A_FF <= V_ADDR(15 downto 6) & "01" & V_ADDR(3 downto 0);
				if SP2_ACTIVE = '1' then
					SP_RAM_REQ_FF <= not SP_RAM_REQ_FF;
					SP2 <= SP2_RD1_W;
				else
					SP2 <= SP2_END;
				end if;
				
			when SP2_RD1_W =>
				if SP_RAM_REQ_FF = SP_RAM_ACK then
					if SP2_ACTIVE = '0' then
						SP2 <= SP2_END;					
					else
						SP_CYC <= SP_CYC + 1;
						case SP_DW is
						when "00" =>
							SP_BUF(conv_integer(SP_CUR)).P1 <= SP_RAM_DO;
							SP2 <= SP2_RD2;
						when others =>
							if SP_CYC = "01" then
								SP_BUF(conv_integer(SP_CUR)).P1 <= SP_RAM_DO;
								SP2 <= SP2_RD2;
							end if;
						end case;
					end if;
				end if;
			
			when SP2_RD2 =>
				V_ADDR := SP_PREBUF(conv_integer(SP_CUR)).ADDR;
			
				SP_CYC <= "00";
			
				SP_RAM_A_FF <= V_ADDR(15 downto 6) & "10" & V_ADDR(3 downto 0);
				if SP2_ACTIVE = '1' then
					SP_RAM_REQ_FF <= not SP_RAM_REQ_FF;
					SP2 <= SP2_RD2_W;
				else
					SP2 <= SP2_END;
				end if;
				
			when SP2_RD2_W =>
				if SP_RAM_REQ_FF = SP_RAM_ACK then
					if SP2_ACTIVE = '0' then
						SP2 <= SP2_END;					
					else
						SP_CYC <= SP_CYC + 1;
						case SP_DW is
						when "00" =>
							SP_BUF(conv_integer(SP_CUR)).P2 <= SP_RAM_DO;
							SP2 <= SP2_RD3;
						when others =>
							if SP_CYC = "01" then
								SP_BUF(conv_integer(SP_CUR)).P2 <= SP_RAM_DO;
								SP2 <= SP2_RD3;
							end if;
						end case;
					end if;
				end if;
			
			when SP2_RD3 =>
				V_ADDR := SP_PREBUF(conv_integer(SP_CUR)).ADDR;
				
				SP_CYC <= "00";

				if SP_DW(0) = '1' and SP_PREBUF(conv_integer(SP_CUR)).CG = '0' then
					SP_RAM_A_FF <= V_ADDR(15 downto 6) & "01" & V_ADDR(3 downto 0);
				else
					SP_RAM_A_FF <= V_ADDR(15 downto 6) & "11" & V_ADDR(3 downto 0);
				end if;
				if SP2_ACTIVE = '1' then
					SP_RAM_REQ_FF <= not SP_RAM_REQ_FF;
					SP2 <= SP2_RD3_W;
				else
					SP2 <= SP2_END;
				end if;
				
			when SP2_RD3_W =>
				if SP_RAM_REQ_FF = SP_RAM_ACK then
					if SP2_ACTIVE = '0' then
						SP2 <= SP2_END;					
					else
						SP_CYC <= SP_CYC + 1;
						case SP_DW is
						when "00" =>
							SP_BUF(conv_integer(SP_CUR)).P3 <= SP_RAM_DO;
							SP_BUF(conv_integer(SP_CUR)).X <= SP_PREBUF(conv_integer(SP_CUR)).X;
							if (SP_CUR = "001111" and SP64 = '0') or (SP_CUR = "111111") or ("0" & SP_CUR = SP_NB-1) then
								SP2 <= SP2_END;
							else
								SP_CUR <= SP_CUR + 1;
								SP2 <= SP2_RD0;
							end if;
							
						when "01" =>
							if SP_CYC = "01" then
								SP_BUF(conv_integer(SP_CUR)).P1 <= SP_RAM_DO;
								SP_BUF(conv_integer(SP_CUR)).X <= SP_PREBUF(conv_integer(SP_CUR)).X;
								if (SP_CUR = "001111" and SP64 = '0') or (SP_CUR = "111111") or ("0" & SP_CUR = SP_NB-1) then
									SP2 <= SP2_END;
								else
									SP_CUR <= SP_CUR + 1;
									SP2 <= SP2_RD0;
								end if;
							end if;							

						when "10" =>-- | "01" =>
							if SP_CYC = "01" then
								SP_BUF(conv_integer(SP_CUR)).P3 <= SP_RAM_DO;
								SP_BUF(conv_integer(SP_CUR)).X <= SP_PREBUF(conv_integer(SP_CUR)).X;
								if (SP_CUR = "001111" and SP64 = '0') or (SP_CUR = "111111") or ("0" & SP_CUR = SP_NB-1) then
									SP2 <= SP2_END;
								else
									SP_CUR <= SP_CUR + 1;
									SP2 <= SP2_RD0;
								end if;
							end if;
						when others =>
							if SP_CYC = "11" then
								if SP_PREBUF(conv_integer(SP_CUR)).CG = '0' then
									SP_BUF(conv_integer(SP_CUR)).P1 <= SP_RAM_DO;
								else
									SP_BUF(conv_integer(SP_CUR)).P3 <= SP_RAM_DO;
								end if;
								SP_BUF(conv_integer(SP_CUR)).X <= SP_PREBUF(conv_integer(SP_CUR)).X;
								if (SP_CUR = "001111" and SP64 = '0') or (SP_CUR = "111111") or ("0" & SP_CUR = SP_NB-1) then
									SP2 <= SP2_END;
								else
									SP_CUR <= SP_CUR + 1;
									SP2 <= SP2_RD0;
								end if;
							end if;							
						end case;
					end if;
				end if;
			
			when SP2_END =>
				SP_BUSY <= '0';
				
				if SP2_ACTIVE = '0' then
					SP2 <= SP2_INI;
				end if;
				
			when others =>
			end case;
		end if;
	end if;
end process;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Line rendering
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- REN_MEM_A <= X;
process( CLK )
variable V_X	: std_logic_vector(9 downto 0);
variable REN_SP_COL	: std_logic_vector(7 downto 0);
variable REN_SP_PRI	: std_logic;

begin
	if rising_edge(CLK) then
		IRQ_COL_SET <= '0';
	
		if RESET_N = '0' then
			REN_MEM_WE <= '0';
		
			IRQ_COL_TRIG <= '0';
		
			COLNO_FF <= "1" & "00000000";			
			REN <= REN_BGR;
		else
			case REN is
			when REN_INI =>
				if REN_ACTIVE = '0' then
					IRQ_COL_TRIG <= '0';
					-- Overscan
					COLNO_FF <= "1" & "00000000";
					-- COLNO_FF <= "0" & "00000000";
				else
					REN <= REN_BGW;
					REN_MEM_A <= X;
					REN_MEM_WE <= '0';
				end if;

			when REN_BGW =>
				for I in 0 to MAX_SPPL loop
					if (X >= SP_BUF(I).X) and (X < SP_BUF(I).X + 16) and SP_ON = '1' then
						if SP_BUF(I).HF = '0' then
							V_X := "0000001111" - (X - SP_BUF(I).X);
						else
							V_X := X - SP_BUF(I).X;
						end if;
						
						REN_SP_COLTAB(I) <= SP_BUF(I).PRI & SP_BUF(I).PAL 
							& SP_BUF(I).P3(conv_integer(V_X(3 downto 0)))
							& SP_BUF(I).P2(conv_integer(V_X(3 downto 0)))
							& SP_BUF(I).P1(conv_integer(V_X(3 downto 0)))
							& SP_BUF(I).P0(conv_integer(V_X(3 downto 0)));
						
						if SP_BUF(I).P3(conv_integer(V_X(3 downto 0))) = '0'
						and SP_BUF(I).P2(conv_integer(V_X(3 downto 0))) = '0'
						and SP_BUF(I).P1(conv_integer(V_X(3 downto 0))) = '0'
						and SP_BUF(I).P0(conv_integer(V_X(3 downto 0))) = '0'
						then
							REN_SP_OPQ(I) <= '0';
						else
							REN_SP_OPQ(I) <= '1';
						end if;
					else
						REN_SP_OPQ(I) <= '0';
					end if;
				end loop;
				REN <= REN_BGR;
			
			when REN_BGR =>
				REN_SP_COL := x"00";
				REN_SP_PRI := '0';
				for I in MAX_SPPL downto 0 loop
					if REN_SP_OPQ(I) = '1' then
						REN_SP_COL := REN_SP_COLTAB(I)(7 downto 0);
						REN_SP_PRI := REN_SP_COLTAB(I)(8);
					end if;
				end loop;
				
				-- Collision
				if REN_SP_OPQ(0) = '1' 
				and REN_SP_OPQ /= SP_OPQ_Z
				and SP_BUF(0).ZERO = '1'
				and IRQ_COL_TRIG = '0'
				then
					IRQ_COL_TRIG <= '1';
					if VDCREG_COLL_IRQEN_FLG = '1' then
						IRQ_COL_SET <= '1';
					end if;
				end if;
				
				if REN_SP_PRI = '1' then
					COLNO_FF <= "1" & REN_SP_COL;
				-- elsif REN_BG_COL(3 downto 0) /= "0000" then
				--	COLNO_FF <= "0" & REN_BG_COL;
				elsif REN_MEM_DO(3 downto 0) /= "0000" and BG_ON = '1' then
					COLNO_FF <= "0" & REN_MEM_DO;
				elsif REN_SP_COL(3 downto 0) /= "0000" then
					COLNO_FF <= "1" & REN_SP_COL;
				else
					COLNO_FF <= "0" & "00000000";
				end if;
				
				if BG_ON = '0' AND SP_ON = '0' then		-- according to docs, this is "burst mode"
					COLNO_FF <= "1" & "00000000";			-- required for Air Zonk blank screen after "Toxy Lond"
				end if;
				
				if	FSTNONDISP = '1' then					-- first line after end of VDW is blank
					COLNO_FF <= "1" & "00000000";
				end if;

				-- REN_BG_COL <= REN_MEM_DO;
				REN <= REN_CLK;
			
			when REN_CLK =>
				
				-- REN_MEM_WE <= '1';
				if CLKEN = '1' then
					REN <= REN_INI;
				end if;
			
			when others => null;
			end case;
		end if;
	end if;
end process;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- VRAM-VRAM DMA
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

process( CLK )
begin
	if rising_edge(CLK) then
		DMA_SOUR_SET_REQ <= '0';
		DMA_DESR_SET_REQ <= '0';
		DMA_LENR_SET_REQ <= '0';
		
		DMA_DMA_CLR	<= '0';
		IRQ_DMA_SET	<= '0';

		if RESET_N = '0' then
			DMA_BUSY <= '0';

			DMA_RAM_REQ_FF <= '0';
			DMA_RAM_A_FF <= (others => '0');
			DMA_RAM_DI_FF <= (others => '0');
			DMA_RAM_WE_FF <= '0';

			DMA <= DMA_IDLE;
		else
			case DMA is
			when DMA_IDLE =>
				-- Can VRAM DMA happen at the same time as DMAS, or is paused during DMAS?
				if BURST = '1' and DMA_REQ = '1' and DMAS_REQ = '0' and DMAS_BUSY='0' then
					DMA_BUSY <= '1';
					DMA <= DMA_READ;
				else
					DMA_BUSY <= '0';
				end if;
			
			-- Wait state is to make the DMA take 4 dot clocks per transfer
			when DMA_READ =>
				if CLKEN = '1' then
					DMA_RAM_REQ_FF <= not DMA_RAM_REQ_FF;
					DMA_RAM_A_FF <= VDCREG_SOUR;
					DMA_RAM_WE_FF <= '0';
					DMA <= DMA_READ1;
				end if;
				
			when DMA_READ1 =>
				if CLKEN = '1' and DMA_RAM_REQ_FF = DMA_RAM_ACK then
					DMA <= DMA_READ2;
				end if;
			
			when DMA_READ2 =>
				DMA_RAM_DI_FF <= DMA_RAM_DO;
				DMA <= DMA_WRITE;
			
			when DMA_WRITE =>
				DMA_RAM_REQ_FF <= not DMA_RAM_REQ_FF;
				DMA_RAM_A_FF <= VDCREG_DESR;
				DMA_RAM_WE_FF <= '1';
				DMA <= DMA_WRITE1;
			-- check for BURST mode end and abort -> Needs testing
				--if BURST = '0' then --incomplete
				--	DMA <= DMA_IDLE;
				--	DMA_BUSY <= '0';
				--end if;

			when DMA_WRITE1 =>
				if CLKEN = '1' and DMA_RAM_REQ_FF = DMA_RAM_ACK then
					DMA_RAM_WE_FF <= '0';
					DMA_SOUR_SET_REQ <= '1';
					DMA_DESR_SET_REQ <= '1';
					DMA_LENR_SET_REQ <= '1';
					DMA <= DMA_WRITE2;
				end if;
			
			when DMA_WRITE2 =>
				DMA <= DMA_LOOP;
				
			-- Wait state is to make the DMA take 4 dot clocks per transfer
			when DMA_LOOP =>
				if CLKEN = '1' then
					DMA <= DMA_LOOP2;
					if VDCREG_LENR = x"FFFF" then
						DMA_DMA_CLR	<= '1';
						DMA_BUSY <= '0';
						if VDCREG_VRAMDMA_IRQEN_FLG = '1' then 
							IRQ_DMA_SET	<= '1';
						end if;
					end if;
				end if;
				
			when DMA_LOOP2 =>
				DMA <= DMA_IDLE;
				DMA_BUSY <= '0';
			
			when others => null;
			end case;
		end if;
	end if;
end process;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- VRAM-SAT DMA
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

process( CLK )
begin
	if rising_edge(CLK) then
		DMAS_DMAS_CLR <= '0';
		IRQ_DMAS_SET <= '0';

		if RESET_N = '0' then
			DMAS_BUSY <= '0';
			DMAS_RAM_REQ_FF <= '0';
			DMAS_RAM_A_FF <= (others => '0');

			DMAS_SAT_A <= (others => '0');
			DMAS_SAT_DI <= (others => '0');
			DMAS_SAT_WE <= '0';
			
			DMAS <= DMAS_IDLE;
		else
			case DMAS is
			when DMAS_IDLE =>
				if BURST = '1' and DMAS_REQ = '1' then
					DMAS_BUSY <= '1';
					DMAS_SAT_A <= x"00";
					DMAS_RAM_A_FF <= VDCREG_SATB;
					DMAS <= DMAS_WAIT1;
				end if;
			
			-- Wait state is to make the DMAS take 1024 dot clocks
			when DMAS_WAIT1 =>
				if CLKEN = '1' then
					DMAS <= DMAS_READ;
				end if;
			
			when DMAS_READ =>
				DMAS_RAM_REQ_FF <= not DMAS_RAM_REQ_FF;
				DMAS <= DMAS_READ1;
				
			when DMAS_READ1 =>
				if CLKEN = '1' and DMAS_RAM_REQ_FF = DMAS_RAM_ACK then
					DMAS <= DMAS_WAIT2;
				end if;
			
			-- Wait state is to make the DMAS take 1024 dot clocks
			when DMAS_WAIT2 =>
				if CLKEN = '1' then
					DMAS <= DMAS_READ2;
				end if;
			
			when DMAS_READ2 =>
				DMAS_SAT_DI <= DMAS_RAM_DO;
				DMAS_SAT_WE <= '1';
				DMAS <= DMAS_WRITE;
				
			when DMAS_WRITE =>
				DMAS_SAT_WE <= '0';
				if CLKEN = '1' then
					DMAS_SAT_A <= DMAS_SAT_A + 1;
					DMAS_RAM_A_FF <= DMAS_RAM_A_FF + 1;
					if DMAS_SAT_A = x"FF" then
						DMAS <= DMAS_END;
						DMAS_DMAS_CLR <= '1';
						DMAS_BUSY <= '0';
					elsif BURST = '0' then --incomplete
						DMAS <= DMAS_IDLE;
						DMAS_BUSY <= '0';
					else
						DMAS <= DMAS_WAIT1;
					end if;
				end if;
			
			when DMAS_END =>
				DMAS <= DMAS_IDLE;
				if VDCREG_SATBDMA_IRQEN_FLG = '1' then
						IRQ_DMAS_SET <= '1';
				end if;
			
			when others => null;
			end case;
		end if;
	end if;
end process;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- CPU Interface
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
IRQ_N_FF <= not ( IRQ_COL or IRQ_OVF or IRQ_RCR or IRQ_DMAS or IRQ_DMA or IRQ_VBL);

process( CLK )
variable V_MARR		: std_logic_vector(15 downto 0);
begin
	if rising_edge(CLK) then

		CPU_IRQ_CLR <= '0';
		CPU_SOUR_SET_REQ <= '0';
		CPU_DESR_SET_REQ <= '0';
		CPU_LENR_SET_REQ <= '0';
		CPU_DMAS_REQ <= '0';
		CPU_DMA_REQ <= '0';
		YOFS_REL_REQ <= '0';
	
		if RESET_N = '0' then
			
			VDCREG_MAWR <= x"0000";
			VDCREG_MARR <= x"0000";
			
			--VDCREG_VRR <= x"FFFF";
			--VDCREG_VWR <= x"FFFF";
			
			VDCREG_RCR <= x"0000";
						
			-- Values taken from The Kung Fu
			-- VDCREG_CR <= x"00CC";
			VDCREG_CR <= x"0000";
			-- VDCREG_MWR <= x"0010";
			VDCREG_MWR <= x"0000";
			VDCREG_HSR <= x"0202";
			VDCREG_HDR <= x"031F";
			VDCREG_VSR <= x"0F02";
			VDCREG_VDR <= x"00EF";
			--VDCREG_VDE <= x"0003";
			VDCREG_BXR <= x"0000";
			VDCREG_BYR <= x"0000";			
			-- VDCREG_DCR <= x"0010";
			VDCREG_DCR <= x"0000";
			--VDCREG_SATB <= x"0800";
			VDCREG_SATB <= x"0000";

			-- -- Values taken from BALL.PCE
			-- VDCREG_CR <= x"00C8";
			-- VDCREG_MWR <= x"0010";
			-- VDCREG_HSR <= x"0302";
			-- VDCREG_HDR <= x"031F";
			-- VDCREG_VSR <= x"1702";
			-- VDCREG_VDR <= x"00DF";
			-- VDCREG_VDE <= x"000C";
			-- VDCREG_BXR <= x"0000";
			-- VDCREG_BYR <= x"0000";
			-- VDCREG_DCR <= x"0010";
			-- VDCREG_SATB <= x"7F00";
			
			RD_BUF <= (others => '1');
			WR_BUF <= (others => '0');
			REG_SEL <= (others => '0');

			CPU_SOUR_SET_VAL <= (others => '0');
			CPU_DESR_SET_VAL <= (others => '0');
			CPU_LENR_SET_VAL <= (others => '0');
			
			CPU_RAM_REQ_FF <= '0';
			CPU_RAM_WE_FF <= '0';
			
			DO_FF <= x"FF";
			BUSY_N_FF <= '1';
			
			PREV_A <= (others => '0');
			CPU <= CPU_IDLE;
		else
			case CPU is
			when CPU_IDLE =>
				BUSY_N_FF <= '1';
				CPU_RAM_WE_FF <= '0';
			
				if CE_N = '0' and WR_N = '0' then
					-- CPU Write
					PREV_A <= A;
					CPU <= CPU_WAIT;
					case A is
					when "00" =>
						REG_SEL <= DI(4 downto 0);
						
					when "10" =>
						case REG_SEL is
						when "00000" =>
							VDCREG_MAWR(7 downto 0) <= DI;
						when "00001" =>
							VDCREG_MARR(7 downto 0) <= DI;
						when "00010" =>
							WR_BUF(7 downto 0) <= DI;
						when "00101" =>
							VDCREG_CR(7 downto 0) <= DI;
						when "00110" =>
							VDCREG_RCR(7 downto 0) <= DI;
						when "00111" =>
							VDCREG_BXR(7 downto 0) <= DI;
						when "01000" =>
							VDCREG_BYR(7 downto 0) <= DI;
							YOFS_REL_REQ <= '1';
						when "01001" =>
							VDCREG_MWR(7 downto 0) <= DI;
						when "01010" =>
							VDCREG_HSR(7 downto 0) <= DI;
						when "01011" =>
							VDCREG_HDR(7 downto 0) <= DI;
						when "01100" =>
							VDCREG_VSR(7 downto 0) <= DI;
						when "01101" =>
							VDCREG_VDR(7 downto 0) <= DI;
						when "01110" =>
							VDCREG_VDE(7 downto 0) <= DI;
						when "01111" =>
							VDCREG_DCR(7 downto 0) <= DI;
						when "10000" =>
							CPU_SOUR_SET_VAL <= VDCREG_SOUR(15 downto 8) & DI;
							CPU_SOUR_SET_REQ <= '1';
						when "10001" =>
							CPU_DESR_SET_VAL <= VDCREG_DESR(15 downto 8) & DI;
							CPU_DESR_SET_REQ <= '1';
						when "10010" =>
							CPU_LENR_SET_VAL <= VDCREG_LENR(15 downto 8) & DI;
							CPU_LENR_SET_REQ <= '1';
						when "10011" =>
							VDCREG_SATB(7 downto 0) <= DI;							
							CPU_DMAS_REQ <= '1';
						when others => null;
						end case;
					
					when "11" =>
						case REG_SEL is
						when "00000" =>
							VDCREG_MAWR(15 downto 8) <= DI;
						when "00001" =>
							VDCREG_MARR(15 downto 8) <= DI;
							
							CPU_RAM_A_FF <= DI & VDCREG_MARR(7 downto 0);
							CPU_RAM_WE_FF <= '0';
							-- CPU_RAM_REQ_FF <= not CPU_RAM_REQ_FF;
							BUSY_N_FF <= '0';
							CPU <= CPU_RAM_PRE_RD;
						when "00010" =>
							WR_BUF(15 downto 8) <= DI;
							CPU_RAM_A_FF <= VDCREG_MAWR;
							CPU_RAM_WE_FF <= '1';
							CPU_RAM_DI_FF <= DI & WR_BUF(7 downto 0);
							-- CPU_RAM_REQ_FF <= not CPU_RAM_REQ_FF;
							BUSY_N_FF <= '0';
							CPU <= CPU_RAM_PRE_WR_INC;
						when "00101" =>
							VDCREG_CR(15 downto 8) <= DI;
						when "00110" =>
							VDCREG_RCR(15 downto 8) <= DI;
						when "00111" =>
							VDCREG_BXR(15 downto 8) <= DI;
						when "01000" =>
							VDCREG_BYR(15 downto 8) <= DI;
							YOFS_REL_REQ <= '1';
						when "01001" =>
							VDCREG_MWR(15 downto 8) <= DI;
						when "01010" =>
							VDCREG_HSR(15 downto 8) <= DI;
						when "01011" =>
							VDCREG_HDR(15 downto 8) <= DI;
						when "01100" =>
							VDCREG_VSR(15 downto 8) <= DI;
						when "01101" =>
							VDCREG_VDR(15 downto 8) <= DI;
						when "01110" =>
							VDCREG_VDE(15 downto 8) <= DI;
						when "01111" =>
							VDCREG_DCR(15 downto 8) <= DI;
						when "10000" =>
							CPU_SOUR_SET_VAL <= DI & VDCREG_SOUR(7 downto 0);
							CPU_SOUR_SET_REQ <= '1';
						when "10001" =>
							CPU_DESR_SET_VAL <= DI & VDCREG_DESR(7 downto 0);
							CPU_DESR_SET_REQ <= '1';
						when "10010" =>
							CPU_LENR_SET_VAL <= DI & VDCREG_LENR(7 downto 0);
							CPU_LENR_SET_REQ <= '1';
							CPU_DMA_REQ <= '1';
						when "10011" =>
							VDCREG_SATB(15 downto 8) <= DI;
							CPU_DMAS_REQ <= '1';
						when others => null;
						end case;
					
					when others => null;
					end case;
				elsif CE_N = '0' and RD_N = '0' then
					-- CPU Read
					PREV_A <= A;
					CPU <= CPU_WAIT;
					DO_FF <= x"00";
					case A is
					when "00" =>
						DO_FF <= "0" 
							& not BUSY_N_FF -- (0)=CPU will always be stalled when this would be 1
							& IRQ_VBL
							& IRQ_DMA
							& IRQ_DMAS
							& IRQ_RCR
							& IRQ_OVF
							& IRQ_COL;
						CPU_IRQ_CLR <= '1';
					when "10" =>
						DO_FF <= RD_BUF(7 downto 0);
					when "11" =>
						DO_FF <= RD_BUF(15 downto 8);
						if REG_SEL = "0" & x"2" then
							case VDCREG_MAWR_RR_INC_SEL is
							when "00" => V_MARR := VDCREG_MARR + 1;
							when "01" => V_MARR := VDCREG_MARR + 32;
							when "10" => V_MARR := VDCREG_MARR + 64;
							when "11" => V_MARR := VDCREG_MARR + 128;
							when others => null;
							end case;
							VDCREG_MARR <= V_MARR;
							
							CPU_RAM_A_FF <= V_MARR;
							CPU_RAM_WE_FF <= '0';
							-- CPU_RAM_REQ_FF <= not CPU_RAM_REQ_FF;
							BUSY_N_FF <= '0';
							CPU <= CPU_RAM_PRE_RD;							
						end if;
					when others => null;
					end case;
				end if;
			
			when CPU_RAM_PRE_RD =>
				if SP_BUSY = '0' 
				and BG_BUSY = '0'
				and DMAS_BUSY = '0'
				and DMA_BUSY = '0'
				then
					CPU_RAM_REQ_FF <= not CPU_RAM_REQ_FF;
					CPU <= CPU_RAM_RD;
				end if;
			
			when CPU_RAM_RD =>
				if CPU_RAM_ACK = CPU_RAM_REQ_FF then
					RD_BUF <= CPU_RAM_DO;
					CPU <= CPU_WAIT;
				end if;
			
			when CPU_RAM_PRE_WR_INC =>
				if SP_BUSY = '0' 
				and BG_BUSY = '0'
				and DMAS_BUSY = '0'
				and DMA_BUSY = '0'
				then
					CPU_RAM_REQ_FF <= not CPU_RAM_REQ_FF;
					CPU <= CPU_RAM_WR_INC;
				end if;
			
			
			when CPU_RAM_WR_INC =>
				if CPU_RAM_ACK = CPU_RAM_REQ_FF then
					CPU_RAM_WE_FF <= '0';
					case VDCREG_MAWR_RR_INC_SEL is
					when "00" => VDCREG_MAWR <= VDCREG_MAWR + 1;
					when "01" => VDCREG_MAWR <= VDCREG_MAWR + 32;
					when "10" => VDCREG_MAWR <= VDCREG_MAWR + 64;
					when "11" => VDCREG_MAWR <= VDCREG_MAWR + 128;
					when others => null;
					end case;
					CPU <= CPU_WAIT;
				end if;
			
			when CPU_WAIT =>
				BUSY_N_FF <= '1';
				CPU_RAM_WE_FF <= '0';

				-- See the related comment in VCE's CPU interface
				CPU <= CPU_IDLE;
				if CE_N = '0' and (RD_N = '0' or WR_N = '0') and PREV_A = A then
					CPU <= CPU_WAIT;
				end if;
				
			when others => null;
			end case;
		end if;
	end if;
end process;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Dual-triggered latches
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Interrupts
process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			IRQ_RCR <= '0';
		elsif IRQ_RCR_SET = '1' then
			IRQ_RCR <= '1';
		elsif CPU_IRQ_CLR = '1' then
			IRQ_RCR <= '0';
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			IRQ_VBL <= '0';
		elsif IRQ_VBL_SET = '1' then
			IRQ_VBL <= '1';
		elsif CPU_IRQ_CLR = '1' then
			IRQ_VBL <= '0';
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			IRQ_COL <= '0';
		elsif IRQ_COL_SET = '1' then
			IRQ_COL <= '1';
		elsif CPU_IRQ_CLR = '1' then
			IRQ_COL <= '0';
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			IRQ_OVF <= '0';
		elsif IRQ_OVF_SET = '1' then
			IRQ_OVF <= '1';
		elsif CPU_IRQ_CLR = '1' then
			IRQ_OVF <= '0';
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			IRQ_DMA <= '0';
		elsif IRQ_DMA_SET = '1' then
			IRQ_DMA <= '1';
		elsif CPU_IRQ_CLR = '1' then
			IRQ_DMA <= '0';
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			IRQ_DMAS <= '0';
		elsif IRQ_DMAS_SET = '1' then
			IRQ_DMAS <= '1';
		elsif CPU_IRQ_CLR = '1' then
			IRQ_DMAS <= '0';
		end if;
	end if;
end process;

-- DMA/DMAS begin/end
process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			DMA_REQ <= '0';
		elsif CPU_DMA_REQ = '1' then
			DMA_REQ <= '1';
		elsif DMA_DMA_CLR = '1' then
			DMA_REQ <= '0';
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			DMAS_REQ <= '0';
		elsif CPU_DMAS_REQ = '1' or DCR_DMAS_REQ = '1' then
			DMAS_REQ <= '1';
		elsif DMAS_DMAS_CLR = '1' then
			DMAS_REQ <= '0';
		end if;
	end if;
end process;

-- VRAM-VRAM DMA registers
process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			VDCREG_SOUR <= (others => '0');
		elsif CPU_SOUR_SET_REQ = '1' then
			VDCREG_SOUR <= CPU_SOUR_SET_VAL;
		elsif DMA_SOUR_SET_REQ = '1' then
			if VDCREG_VRAMDMA_SRCDEC_FLG = '1' then
				VDCREG_SOUR <= VDCREG_SOUR - 1;
			else
				VDCREG_SOUR <= VDCREG_SOUR + 1;
			end if;
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			VDCREG_DESR <= (others => '0');
		elsif CPU_DESR_SET_REQ = '1' then
			VDCREG_DESR <= CPU_DESR_SET_VAL;
		elsif DMA_DESR_SET_REQ = '1' then
			if VDCREG_VRAMDMA_DSTDEC_FLG = '1' then
				VDCREG_DESR <= VDCREG_DESR - 1;
			else
				VDCREG_DESR <= VDCREG_DESR + 1;
			end if;
		end if;
	end if;
end process;

process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			VDCREG_LENR <= (others => '0');
		elsif CPU_LENR_SET_REQ = '1' then
			VDCREG_LENR <= CPU_LENR_SET_VAL;
		elsif DMA_LENR_SET_REQ = '1' then
			VDCREG_LENR <= VDCREG_LENR - 1;
		end if;
	end if;
end process;

-- YOFS Reload
process( CLK )
begin
	if rising_edge( CLK ) then
		if RESET_N = '0' then
			YOFS_RELOAD <= '0';
		elsif YOFS_REL_REQ = '1' then
			YOFS_RELOAD <= '1';
		elsif YOFS_REL_ACK = '1' then
			YOFS_RELOAD <= '0';
		end if;
	end if;
end process;


-- Output buffers
BUSY_N <= BUSY_N_FF;
IRQ_N <= IRQ_N_FF;
COLNO <= COLNO_FF;
DO <= DO_FF;

vram : entity work.vram_controller port map
(
	clk			=> CLK,
	
	vdccpu_req	=> CPU_RAM_REQ_FF,
	vdccpu_we	=> CPU_RAM_WE_FF,
	vdccpu_a		=> CPU_RAM_A_FF,
	vdccpu_d		=> CPU_RAM_DI_FF,
	vdccpu_ack	=> CPU_RAM_ACK,
	vdccpu_q		=> CPU_RAM_DO,

	vdcbg_a		=> BG_RAM_A_FF,
	vdcbg_req	=> BG_RAM_REQ_FF,
	vdcbg_q		=> BG_RAM_DO,
	vdcbg_ack	=> BG_RAM_ACK,
	
	vdcsp_a		=> SP_RAM_A_FF,
	vdcsp_req	=> SP_RAM_REQ_FF,
	vdcsp_q		=> SP_RAM_DO,
	vdcsp_ack	=> SP_RAM_ACK,
	
	vdcdma_req 	=> DMA_RAM_REQ_FF,
	vdcdma_a		=> DMA_RAM_A_FF,
	vdcdma_d		=> DMA_RAM_DI_FF,
	vdcdma_we	=> DMA_RAM_WE_FF,
	vdcdma_q		=> DMA_RAM_DO,
	vdcdma_ack	=> DMA_RAM_ACK,
	
	vdcdmas_req	=> DMAS_RAM_REQ_FF,
	vdcdmas_a	=> DMAS_RAM_A_FF,
	vdcdmas_q	=> DMAS_RAM_DO,
	vdcdmas_ack	=> DMAS_RAM_ACK
);


end rtl;
