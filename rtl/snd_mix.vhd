library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library STD;
use IEEE.NUMERIC_STD.ALL;

entity SND_MIX is
	port(
		CH0_R			: in signed(15 downto 0);
		CH0_L			: in signed(15 downto 0);
		CH0_EN		: in std_logic;
		
		CH1_R			: in signed(15 downto 0);
		CH1_L			: in signed(15 downto 0);
		CH1_EN		: in std_logic;
		
		OUT_R			: out signed(15 downto 0);
		OUT_L			: out signed(15 downto 0)
	);
end SND_MIX;

architecture rtl of SND_MIX is

	signal TEMP_CH0_R	: signed(15 downto 0);
	signal TEMP_CH0_L	: signed(15 downto 0);
	signal TEMP_CH1_R	: signed(15 downto 0);
	signal TEMP_CH1_L	: signed(15 downto 0);

begin

	TEMP_CH0_R <= CH0_R when CH0_EN = '1' else (others => '0');
	TEMP_CH0_L <= CH0_L when CH0_EN = '1' else (others => '0');
	TEMP_CH1_R <= CH1_R when CH1_EN = '1' else (others => '0');
	TEMP_CH1_L <= CH1_L when CH1_EN = '1' else (others => '0');
	
	OUT_R <= shift_right(TEMP_CH0_R, 1) + shift_right(TEMP_CH1_R, 1);
	OUT_L <= shift_right(TEMP_CH0_L, 1) + shift_right(TEMP_CH1_L, 1);

end rtl;