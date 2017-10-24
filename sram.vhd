library ieee;
use ieee.std_logic_1164.all,ieee.numeric_std.all;

entity sram is
port (
	clk  : in  std_logic;
	addr : in  std_logic_vector(15 downto 0);
	dout : out std_logic_vector(15 downto 0);
	we   : in  std_logic;
	din  : in  std_logic_vector(15 downto 0)
);
end entity;

architecture prom of sram is
	type rom is array(0 to  65535) of std_logic_vector(15 downto 0);
	signal rom_data: rom;
begin
process(clk)
begin
	if rising_edge(clk) then
		if we = '1' then
			rom_data(to_integer(unsigned(addr))) <= din;
			dout <= din;
		else
			dout <= rom_data(to_integer(unsigned(addr)));
		end if;
	end if;
end process;
end architecture;
