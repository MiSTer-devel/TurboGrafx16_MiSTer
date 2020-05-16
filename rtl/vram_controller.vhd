
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- -----------------------------------------------------------------------

entity vram_controller is
	port (
		-- System
		clk : in std_logic;

		vdccpu_req : in std_logic;
		vdccpu_ack : out std_logic;
		vdccpu_we : in std_logic;
		vdccpu_a : in std_logic_vector(16 downto 1);
		vdccpu_d : in std_logic_vector(15 downto 0);
		vdccpu_q : out std_logic_vector(15 downto 0);

		vdcbg_req : in std_logic;
		vdcbg_ack : out std_logic;
		vdcbg_a : in std_logic_vector(16 downto 1);
		vdcbg_q : out std_logic_vector(15 downto 0);

		vdcsp_req : in std_logic;
		vdcsp_ack : out std_logic;
		vdcsp_a : in std_logic_vector(16 downto 1);
		vdcsp_q : out std_logic_vector(15 downto 0);

		vdcdma_req : in std_logic;
		vdcdma_ack : out std_logic;
		vdcdma_we : in std_logic;
		vdcdma_a : in std_logic_vector(16 downto 1);
		vdcdma_d : in std_logic_vector(15 downto 0);
		vdcdma_q : out std_logic_vector(15 downto 0);
		
		vdcdmas_req : in std_logic;
		vdcdmas_ack : out std_logic;
		vdcdmas_a : in std_logic_vector(16 downto 1);
		vdcdmas_q : out std_logic_vector(15 downto 0)
	);
end entity;

-- -----------------------------------------------------------------------

architecture rtl of vram_controller is
	signal ram_a : std_logic_vector(15 downto 0);
	signal ram_d : std_logic_vector(15 downto 0);
	signal ram_q : std_logic_vector(15 downto 0);
	signal ram_we: std_logic;

	signal vdccpu_ackReg : std_logic := '0';
	signal vdcdma_ackReg : std_logic := '0';
	signal vdcsp_ackReg : std_logic := '0';
	signal vdcbg_ackReg : std_logic := '0';
	signal vdcdmas_ackReg : std_logic := '0';

	signal vdccpur_q : std_logic_vector(15 downto 0);
	signal vdcbgr_q : std_logic_vector(15 downto 0);
	signal vdcdmar_q : std_logic_vector(15 downto 0);
	signal vdcdmasr_q : std_logic_vector(15 downto 0);
		
	type ramPorts is (
		PORT_NONE,
		PORT_VDCCPU,
		PORT_VDCDMA,
		PORT_VDCSP,
		PORT_VDCBG,
		PORT_VDCDMAS,
		PORT_ROMRD,
		PORT_ROMWR
	);

	signal ramport  : ramPorts := PORT_NONE;
	signal ramstage : std_logic := '0';

begin
	
	vdccpu_ack  <= vdccpu_ackReg;
	vdcdma_ack  <= vdcdma_ackReg;
	vdcsp_ack   <= vdcsp_ackReg;
	vdcbg_ack   <= vdcbg_ackReg;
	vdcdmas_ack <= vdcdmas_ackReg;

	ram : entity work.dpram generic map (15,16)
		port map (
			clock     => clk,
			address_a => ram_a(14 downto 0),
			cs_a      => not ram_a(15),
			q_a       => ram_q,
			wren_a    => ram_we,
			data_a    => ram_d,

			address_b => vdcsp_a(15 downto 1),
			cs_b      => not vdcsp_a(16),
			q_b       => vdcsp_q
		);
	
	process(clk) begin
		if rising_edge(clk) then
			ram_we <= '0';
			vdcsp_ackReg <= vdcsp_req;

			if ramstage = '0' then
				ramport <= PORT_NONE;

				case ramport is
				when PORT_VDCCPU =>
					vdccpur_q <= ram_q;
				when PORT_VDCBG =>
					vdcbgr_q <= ram_q;
				when PORT_VDCDMA =>
					vdcdmar_q <= ram_q;
				when PORT_VDCDMAS =>
					vdcdmasr_q <= ram_q;
				when others =>
					if vdcbg_req /= vdcbg_ackReg then
						ram_a <= vdcbg_a;
						ramport <= PORT_VDCBG;
						ramstage <= '1';
					elsif vdcdmas_req /= vdcdmas_ackReg then
						ram_a <= vdcdmas_a;
						ramport <= PORT_VDCDMAS;
						ramstage <= '1';
					elsif vdcdma_req /= vdcdma_ackReg then
						ram_a <= vdcdma_a;
						ram_d <= vdcdma_d;
						ram_we <= vdcdma_we;
						ramport <= PORT_VDCDMA;
						ramstage <= '1';
					elsif vdccpu_req /= vdccpu_ackReg then
						ram_a <= vdccpu_a;
						ram_d <= vdccpu_d;
						ram_we <= vdccpu_we;
						ramport <= PORT_VDCCPU;
						ramstage <= '1';
					end if;
				end case;
			else
				ramstage <= '0';
				case ramport is
				when PORT_VDCCPU =>
					vdccpu_ackReg <= vdccpu_req;
				when PORT_VDCBG =>
					vdcbg_ackReg <= vdcbg_req;
				when PORT_VDCDMA =>
					vdcdma_ackReg <= vdcdma_req;
				when PORT_VDCDMAS =>
					vdcdmas_ackReg <= vdcdmas_req;
				when others =>	null;
				end case;
			end if;
		end if;
	end process;

vdccpu_q <= ram_q when ramport = PORT_VDCCPU else vdccpur_q;
vdcbg_q <= ram_q when ramport = PORT_VDCBG else vdcbgr_q;
vdcdma_q <= ram_q when ramport = PORT_VDCDMA else vdcdmar_q;
vdcdmas_q <= ram_q when ramport = PORT_VDCDMAS else vdcdmasr_q;

end architecture;
