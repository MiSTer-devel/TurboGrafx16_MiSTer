library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.HUC6280_PKG.all;

entity HUC6280_MC is
    port( 
        CLK		: in std_logic;
		  RST_N	: in std_logic;
		  EN		: in std_logic;
        IR		: in std_logic_vector(7 downto 0);
        STATE	: in unsigned(4 downto 0);
        M		: out MCode_r
    );
end HUC6280_MC;

architecture rtl of HUC6280_MC is
 
	type MicroInst_t is array(0 to 256*23-1) of MicroInst_r;
	constant M_TAB: MicroInst_t := (
  --STATE ADBUS SDLH  P    T   ADDRCTRL  PC    SP  AXYBUS  ALUBUS  ALUCTRL  OUT  MCYC
	-- 00 BRK
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","010","00","000","00","000000","000","011","000","000000","00000","0110",'1'),-- ['PCH->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0111",'1'),-- ['PCL->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0101",'1'),-- ['P->[21:SP]', 'SP--', '0->T]
	("00","100","00","010","00","000000","010","000","000","000000","00000","0000",'1'),-- ['[VECT+0]->PCL', '1->I', '0->D', '1->B']
	("10","100","00","000","00","000000","011","000","000","000000","00000","0000",'1'),-- ['[VECT+1]->PCH']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 01 ORA (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 02 SXY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","10","000000","000","000","010","001100","00000","0000",'1'),-- ['X->T', 'Y->X'] 
	("10","000","00","000","00","000000","000","000","100","010100","00000","0000",'0'),-- ['T->Y'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 03 ST0
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("10","101","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[ST]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 04 TSB ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","101","01","000000","000","000","000","000100","01110","0000",'1'),-- ['ALU(A,[20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 05 ORA ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 06 ASL ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","101","01","000000","000","000","000","000000","01000","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 07 RMB0
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 08 PHP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","010","00","000","00","000000","000","011","000","000000","00000","0101",'1'),-- ['P->[21:SP]', 'SP--']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 09 ORA IMM / IMM,(X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","001","000","001","000100","00010","0000",'1'),-- ['ALU(A,[PC])->A', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 0A ASL A
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","000","000","001","000100","01000","0000",'1'),-- ['ALU(A)->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 0B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 0C TSB ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","101","01","000000","000","000","000","000100","01110","0000",'1'),-- ['ALU(A,[AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 0D ORA ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 0E ASL ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","101","01","000000","000","000","000","000000","01000","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 0F BBR0
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 10 BPL
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 11 ORA (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'1'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 12 ORA (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 13 ST1
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("10","101","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[ST]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 14 TRB ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","101","01","000000","000","000","000","000100","01101","0000",'1'),-- ['ALU(A,[20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 15 ORA ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[20:AAL])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 16 ASL ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","101","01","000000","000","000","000","000000","01000","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 17 RMB1
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 18 CLC
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","100","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 19 ORA ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 1A INC A
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","001","000100","00111","0000",'1'),-- ['ALU(A)->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 1B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 1C TRB ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","101","01","000000","000","000","000","000100","01101","0000",'1'),-- ['ALU(A,[AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 1D ORA ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00010","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00010","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 1E ASL ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","101","01","000000","000","000","000","000000","01000","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 1F BBR1
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 20 JSR ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","000","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0110",'1'),-- ['PCH->[00:SP]', 'SP--']
	("00","010","00","000","00","000000","000","011","000","000000","00000","0111",'1'),-- ['PCL->[00:SP]', 'SP--'] 
	("10","000","00","000","00","000000","110","000","000","000000","00000","0000",'0'),-- ['AA->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 21 AND (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 22 SAX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","10","000000","000","000","010","000100","00000","0000",'1'),-- ['X->T', 'A->X'] 
	("10","000","00","000","00","000000","000","000","001","010100","00000","0000",'0'),-- ['T->A'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 23 ST2
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("10","101","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[ST]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 24 BIT ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","101","00","000000","000","000","000","000100","01100","0000",'1'),-- ['ALU(A,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 25 AND ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[20:AAL])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 26 ROL ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","101","01","000000","000","000","000","000000","01010","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 27 RMB2
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 28 PLP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","010","000","000000","00000","0000",'0'),-- ['SP++']
	("10","010","00","011","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[21:SP]->P']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 29 AND IMM / IMM,(X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","001","000","001","000100","00001","0000",'1'),-- ['ALU(A,[PC])->A', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 2A ROL A
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","000","000","001","000100","01010","0000",'1'),-- ['ALU(A)->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 2B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 2C BIT ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","000100","01100","0000",'1'),-- ['ALU(A,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 2D AND ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 2E ROL ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","101","01","000000","000","000","000","000000","01010","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 2F BBR2
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 30 BMI
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 31 AND (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 32 AND (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 33
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 34 BIT ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","101","00","000000","000","000","000","000100","01100","0000",'1'),-- ['ALU(A,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 35 AND ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[20:AAL])->A'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 36 ROL ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","101","01","000000","000","000","000","000000","01010","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 37 RMB3
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 38 SEC
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","100","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 39 AND ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 3A DEC A
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","001","000100","00110","0000",'1'),-- ['ALU(A)->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 3B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 3C BIT ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","101","00","000000","000","000","000","000100","01100","0000",'1'),-- ['ALU(A,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 3D AND ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00001","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->A']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00001","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 3E ROL ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","101","01","000000","000","000","000","000000","01010","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 3F BBR3
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 40 RTI
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","010","000","000000","00000","0000",'0'),-- ['SP++']
	("00","010","00","011","00","000000","000","010","000","000000","00000","0000",'1'),-- ['[21:SP]->P', 'SP++']
	("00","010","00","000","00","000000","010","010","000","000000","00000","0000",'1'),-- ['[21:SP]->PCL', 'SP++']
	("10","010","00","000","00","000000","011","000","000","000000","00000","0000",'1'),-- ['[21:SP]->PCH']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 41 EOR (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[AA])->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 42 SAY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","11","000000","000","000","100","000100","00000","0000",'1'),-- ['Y->T', 'A->Y'] 
	("10","000","00","000","00","000000","000","000","001","010100","00000","0000",'0'),-- ['T->A'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 43 TMAi
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","000","00","000","00","000000","000","000","001","101100","00000","0000",'0'),-- ['MPR->A']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 44 BSR
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","010","00","000","00","000000","000","011","000","000000","00000","0110",'1'),-- ['PCH->[00:SP]', 'SP--']
	("00","010","00","000","00","000000","000","011","000","000000","00000","0111",'1'),-- ['PCL->[00:SP]', 'SP--'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 45 EOR ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['ALU(A,[20:AAL])->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 46 LSR ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","101","01","000000","000","000","000","000000","01001","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 47 RMB4
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T']  
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 48 PHA
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","010","00","000","00","000000","000","011","000","000000","00000","0001",'1'),-- ['A->[21:SP]', 'SP--']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 49 EOR IMM / IMM,(X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","001","000","001","000100","00011","0000",'1'),-- ['ALU(A,[PC])->A', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 4A LSR A
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","000","000","001","000100","01001","0000",'1'),-- ['ALU(A)->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 4B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 4C JMP ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","000","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH']
	("10","000","00","000","00","000000","110","000","000","000000","00000","0000",'0'),-- ['AA->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 4D EOR ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 4E LSR ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","101","01","000000","000","000","000","000000","01001","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 4F BBR4
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 50 BVC
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 51 EOR (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 52 EOR (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 53 TAMi
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- ['A->MPR']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 54 CSL
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 55 EOR ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 56 LSR ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","101","01","000000","000","000","000","000000","01001","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 57 RMB5
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 58 CLI
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","100","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 59 EOR ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 5A PHY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","010","00","000","00","000000","000","011","000","000000","00000","0011",'1'),-- ['Y->[21:SP]', 'SP--']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 5B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 5C
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 5D EOR ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000100","00011","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","001","01","000000","000","000","000","010100","00011","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 5E LSR ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","101","01","000000","000","000","000","000000","01001","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 5F BBR5
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 60 RTS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","010","000","000000","00000","0000",'0'),-- ['SP++']
	("00","010","00","000","00","000000","010","010","000","000000","00000","0000",'1'),-- ['[21:SP]->PCL', 'SP++']
	("00","010","00","000","00","000000","011","000","000","000000","00000","0000",'1'),-- ['[21:SP]->PCH']
	("10","000","00","000","00","000000","001","000","000","000000","00000","0000",'0'),-- ['PC++'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 61 ADC (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("01","001","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 62 CLA
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","001","111100","00000","0000",'1'),-- ['0->A'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 63
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 64 STZ ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","1111",'1'),-- ['0->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 65 ADC ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("01","011","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 66 ROR ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","101","01","000000","000","000","000","000000","01011","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 67 RMB6
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 68 PLA
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","010","000","000000","00000","0000",'0'),-- ['SP++']
	("10","010","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([21:SP])->A']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 69 ADC IMM / IMM,(X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("01","000","00","101","00","000000","001","000","001","000100","00100","0000",'1'),-- ['ALU(A,[PC])->A', 'PC++', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 6A ROR A
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","000","000","001","000100","01011","0000",'1'),-- ['ALU(A)->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 6B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 6C JMP (ABS)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","00","010000","010","000","000","000000","00000","0000",'1'),-- ['[AA]->PCL', 'AAL+1->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","000","00","000000","011","000","000","000000","00000","0000",'1'),-- ['[AA]->PCH']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 6D ADC ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("01","001","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 6E ROR ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","101","01","000000","000","000","000","000000","01011","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 6F BBR6
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 70 BVS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 71 ADC (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH']
	("01","001","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH']
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 72 ADC (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("01","001","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 73 TII
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0011",'1'),-- ['Y->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0001",'1'),-- ['A->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[21:SP]'] 
	("00","000","00","000","00","000000","001","000","010","000000","00000","0000",'1'),-- ['[PC]->X', 'PC++'] 
	("00","000","01","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->SH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","100","000000","00000","0000",'1'),-- ['[PC]->Y', 'PC++'] 
	("00","000","10","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->DH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","001","000000","00000","0000",'1'),-- ['[PC]->A', 'PC++'] 
	("00","000","11","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->LH', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("00","000","00","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","110","00","000","00","000000","000","000","010","001000","00111","0000",'1'),-- ['[SH:X]->DR', 'ALU(X+/-1)->X'] 
	("00","111","01","000","00","000000","000","000","000","100000","10001","1000",'1'),-- ['DR->[DH:Y]', 'ALU(SH+/-C)->SH'] 
	("00","000","00","000","00","000000","000","000","100","001100","00111","0000",'0'),-- ['ALU(Y+/-1)->Y'] 
	("00","000","10","000","00","000000","000","000","000","100100","10001","0000",'0'),-- ['ALU(DH+/-C)->DH'] 
	("00","000","00","000","00","000000","000","000","001","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("11","000","11","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","010","00","000","00","000000","000","010","010","000000","00000","0000",'1'),-- ['ALU([21:SP])->X', 'SP++'] 
	("00","010","00","000","00","000000","000","010","001","000000","00000","0000",'1'),-- ['ALU([21:SP])->A', 'SP++'] 
	("10","010","00","000","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([21:SP])->Y']
	-- 74 STZ ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","000","00","000000","000","000","000","000000","00000","1111",'1'),-- ['0->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 75 ADC ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("01","011","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 76 ROR ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","101","01","000000","000","000","000","000000","01011","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 77 RMB7
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01101","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 78 SEI
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","100","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 79 ADC ABS,Y/ABS,Y,(X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH']
	("01","001","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T'] 
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 7A PLY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","010","000","000000","00000","0000",'0'),-- ['SP++']
	("10","010","00","001","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([21:SP])->Y']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 7B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 7C JMP (ABS,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","00","010000","010","000","000","000000","00000","0000",'1'),-- ['[AA]->PCL', 'AAL+1->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","000","00","000000","011","000","000","000000","00000","0000",'1'),-- ['[AA]->PCH']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 7D ADC ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("01","001","00","101","00","000000","000","000","001","000100","00100","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","001","00","000","01","000000","000","000","000","000000","00000","0000",'1'),-- ['[AA]->T']
	("00","000","00","000","00","111000","000","000","000","000000","00000","0000",'0'),-- ['X->AAL'] 
	("00","011","00","101","01","000000","000","000","000","010100","00100","0000",'1'),-- ['ALU(T,[20:AAL])->T', 'Flags'] 
	("01","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 7E ROR ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH']
	("00","001","00","101","01","000000","000","000","000","000000","01011","0000",'1'),-- ['ALU([AA])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 7F BBR7
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'1'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 80 BRA
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 81 STA (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[AA]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 82 CLX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","010","111100","00000","0000",'1'),-- ['0->X'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 83 TST IMM,ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","101","00","000000","000","000","000","010100","01100","0000",'1'),-- ['ALU(T,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 84 STY ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0011",'1'),-- ['Y->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 85 STA ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 86 STX ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 87 SMB0
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 88 DEY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","100","001100","00110","0000",'1'),-- ['ALU(Y)->Y', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 89 BIT IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","001","000","000","000100","01100","0000",'1'),-- ['ALU(A,[PC])', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 8A TXA
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","001","001000","00000","0000",'1'),-- ['ALU(X)->A']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 8B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 8C STY ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0011",'1'),-- ['Y->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 8D STA ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 8E STX ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 8F BBS0
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 90 BCC
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 91 STA (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[AA]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 92 STA (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[AA]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 93 TST IMM,ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","010100","01100","0000",'1'),-- ['ALU(T,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 94 STY ZP, X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","000","00","000000","000","000","000","000000","00000","0011",'1'),-- ['Y->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 95 STA ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 96 STX ZP,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100000","000","000","000","000000","00000","0000",'0'),-- ['AAL+Y->AAL']
	("10","011","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 97 SMB1
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 98 TYA
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","001","001100","00000","0000",'1'),-- ['ALU(Y)->A'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 99 STA ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 9A TXS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","001","000","001000","00000","0000",'1'),-- ['X->SP'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 9B
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 9C STZ ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","1111",'1'),-- ['0->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 9D STA ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","000","00","000000","000","000","000","000000","00000","0001",'1'),-- ['A->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 9E STZ ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","000","00","000000","000","000","000","000000","00000","1111",'1'),-- ['0->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- 9F BBS1
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A0 LDY IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","001","000","100","000000","00000","0000",'1'),-- ['ALU([PC])->Y', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A1 LDA (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A2 LDX IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","001","000","010","000000","00000","0000",'1'),-- ['ALU([PC])->X', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A3 TST IMM,ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","101","00","000000","000","000","000","010100","01100","0000",'1'),-- ['ALU(T,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A4 LDY ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","001","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([20:AAL])->Y', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A5 LDA ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A6 LDX ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","001","00","000000","000","000","010","000000","00000","0000",'1'),-- ['ALU([20:AAL])->X', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A7 SMB2
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A8 TAY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","100","000100","00000","0000",'1'),-- ['ALU(A)->Y', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- A9 LDA IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","001","000","001","000000","00000","0000",'1'),-- ['ALU([PC])->A', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- AA TAX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","010","000100","00000","0000",'1'),-- ['ALU(A)->X', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- AB
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- AC LDY ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([AA])->Y', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- AD LDA ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- AE LDX ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","010","000000","00000","0000",'1'),-- ['ALU([AA])->X', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- AF BBS2
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B0 BCS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B1 LDA (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B2 LDA (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([AA])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B3 TST IMM,ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","01","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->T', 'PC++']
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","010100","01100","0000",'1'),-- ['ALU(T,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B4 LDY ZP, X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","001","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([20:AAL])->Y', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B5 LDA ZP, X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([20:AAL])->A', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B6 LDX ZP, Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100000","000","000","000","000000","00000","0000",'0'),-- ['AAL+Y->AAL']
	("10","011","00","001","00","000000","000","000","010","000000","00000","0000",'1'),-- ['ALU([20:AAL])->X', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B7 SMB3
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B8 CLV
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","100","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- B9 LDA ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- BA TSX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","010","010000","00000","0000",'1'),-- ['ALU(SP)->X'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- BB
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- BC LDY ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X/Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([AA])->Y', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- BD LDA ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","001","000000","00000","0000",'1'),-- ['ALU([AA])->A', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- BE LDX ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X/Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","001","00","000000","000","000","010","000000","00000","0000",'1'),-- ['ALU([AA])->X', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- BF BBS3
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C0 CPY IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","001","000","000","001100","01111","0000",'1'),-- ['ALU(Y,[PC])', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C1 CMP (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[AA])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C2 CLY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","100","111100","00000","0000",'1'),-- ['0->Y'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C3 TDD
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0011",'1'),-- ['Y->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0001",'1'),-- ['A->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[21:SP]'] 
	("00","000","00","000","00","000000","001","000","010","000000","00000","0000",'1'),-- ['[PC]->X', 'PC++'] 
	("00","000","01","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->SH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","100","000000","00000","0000",'1'),-- ['[PC]->Y', 'PC++'] 
	("00","000","10","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->DH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","001","000000","00000","0000",'1'),-- ['[PC]->A', 'PC++'] 
	("00","000","11","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->LH', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("00","000","00","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","110","00","000","00","000000","000","000","010","001000","00110","0000",'1'),-- ['[SH:X]->DR', 'ALU(X+/-1)->X'] 
	("00","111","01","000","00","000000","000","000","000","100000","10000","1000",'1'),-- ['DR->[DH:Y]', 'ALU(SH+/-C)->SH'] 
	("00","000","00","000","00","000000","000","000","100","001100","00110","0000",'0'),-- ['ALU(Y+/-1)->Y'] 
	("00","000","10","000","00","000000","000","000","000","100100","10000","0000",'0'),-- ['ALU(DH+/-C)->DH'] 
	("00","000","00","000","00","000000","000","000","001","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("11","000","11","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","010","00","000","00","000000","000","010","010","000000","00000","0000",'1'),-- ['ALU([21:SP])->X', 'SP++'] 
	("00","010","00","000","00","000000","000","010","001","000000","00000","0000",'1'),-- ['ALU([21:SP])->A', 'SP++'] 
	("10","010","00","000","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([21:SP])->Y']
	-- C4 CPY ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","101","00","000000","000","000","000","001100","01111","0000",'1'),-- ['ALU(Y,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C5 CMP ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C6 DEC ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","001","01","000000","000","000","000","000000","00110","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C7 SMB4
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C8 INY
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","100","001100","00111","0000",'1'),-- ['ALU(Y)->Y', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- C9 CMP IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","001","000","000","000100","01111","0000",'1'),-- ['ALU(A,[PC])', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- CA DEX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","010","001000","00110","0000",'1'),-- ['ALU(X)->X', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- CB
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- CC CPY ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","001100","01111","0000",'1'),-- ['ALU(Y,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- CD CMP ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- CE DEC ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","001","01","000000","000","000","000","000000","00110","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- CF BBS4
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D0 BNE
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D1 CMP (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[AA])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D2 CMP (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[AA])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D3 TIN
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0011",'1'),-- ['Y->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0001",'1'),-- ['A->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[21:SP]'] 
	("00","000","00","000","00","000000","001","000","010","000000","00000","0000",'1'),-- ['[PC]->X', 'PC++'] 
	("00","000","01","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->SH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","100","000000","00000","0000",'1'),-- ['[PC]->Y', 'PC++'] 
	("00","000","10","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->DH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","001","000000","00000","0000",'1'),-- ['[PC]->A', 'PC++'] 
	("00","000","11","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->LH', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("00","000","00","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","110","00","000","00","000000","000","000","010","001000","00111","0000",'1'),-- ['[SH:X]->DR', 'ALU(X+/-1)->X'] 
	("00","111","01","000","00","000000","000","000","000","100000","10001","1000",'1'),-- ['DR->[DH:Y]', 'ALU(SH+/-C)->SH'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","001","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("11","000","11","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","010","00","000","00","000000","000","010","010","000000","00000","0000",'1'),-- ['ALU([21:SP])->X', 'SP++'] 
	("00","010","00","000","00","000000","000","010","001","000000","00000","0000",'1'),-- ['ALU([21:SP])->A', 'SP++'] 
	("10","010","00","000","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([21:SP])->Y']
	-- D4 CSH
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D5 CMP ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("10","011","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D6 DEC ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","001","01","000000","000","000","000","000000","00110","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D7 SMB5
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D8 CLD
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","100","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- D9 CMP ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- DA PHX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","010","00","000","00","000000","000","011","000","000000","00000","0010",'1'),-- ['X->[21:SP]', 'SP--']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- DB
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- DC
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- DD CMP ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("10","001","00","101","00","000000","000","000","000","000100","01111","0000",'1'),-- ['ALU(A,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- DE DEC ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH']
	("00","001","00","001","01","000000","000","000","000","000000","00110","0000",'1'),-- ['ALU([AA])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- DF BBS5
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E0 CPX IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","101","00","000000","001","000","000","001000","01111","0000",'1'),-- ['ALU(X,[PC])', 'PC++', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E1 SBC (ZP,X)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("01","001","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E2
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E3 TIA
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0011",'1'),-- ['Y->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0001",'1'),-- ['A->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[21:SP]'] 
	("00","000","00","000","00","000000","001","000","010","000000","00000","0000",'1'),-- ['[PC]->X', 'PC++'] 
	("00","000","01","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->SH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","100","000000","00000","0000",'1'),-- ['[PC]->Y', 'PC++'] 
	("00","000","10","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->DH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","001","000000","00000","0000",'1'),-- ['[PC]->A', 'PC++'] 
	("00","000","11","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->LH', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("00","000","00","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","110","00","000","00","000000","000","000","010","001000","00111","0000",'1'),-- ['[SH:X]->DR', 'ALU(X+/-1)->X'] 
	("00","111","01","000","00","000000","000","000","000","100000","10001","1000",'1'),-- ['DR->[DH:Y]', 'ALU(SH+/-C)->SH'] 
	("00","000","00","000","00","000000","000","000","100","001100","00110","0000",'0'),-- ['ALU(Y+/-1)->Y'] 
	("00","000","10","000","00","000000","000","000","000","100100","10000","0000",'0'),-- ['ALU(DH+/-C)->DH'] 
	("00","000","00","000","00","000000","000","000","001","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("11","000","11","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","010","00","000","00","000000","000","010","010","000000","00000","0000",'1'),-- ['ALU([21:SP])->X', 'SP++'] 
	("00","010","00","000","00","000000","000","010","001","000000","00000","0000",'1'),-- ['ALU([21:SP])->A', 'SP++'] 
	("10","010","00","000","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([21:SP])->Y']
	-- E4 CPX ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","101","00","000000","000","000","000","001000","01111","0000",'1'),-- ['ALU(X,[20:AAL])', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E5 SBC ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("01","011","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E6 INC ZP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","001","01","000000","000","000","000","000000","00111","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E7 SMB6
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E8 INX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","001","00","000000","000","000","010","001000","00111","0000",'1'),-- ['ALU(X)->X', 'Flags'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- E9 SBC IMM
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("01","000","00","101","00","000000","001","000","001","000100","00101","0000",'1'),-- ['ALU(A,[PC])->A', 'PC++', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- EA NOP
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- EB
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- EC CPX ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","000","001000","01111","0000",'1'),-- ['ALU(X,[AA])', 'Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- ED SBC ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- EE INC ABS
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","001","00","001","01","000000","000","000","000","000000","00111","0000",'1'),-- ['ALU([AA])->T', 'Flags']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- EF BBS6
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F0 BEQ
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- []
	("10","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F1 SBC (ZP),Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","110001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("01","001","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F2 SBC (ZP)
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","010000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR', 'AAL+1->AAL'] 
	("00","011","00","000","00","101001","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->AAH', 'DR->AAL']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("01","001","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F3 TAI
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0011",'1'),-- ['Y->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","011","000","000000","00000","0001",'1'),-- ['A->[21:SP]', 'SP--'] 
	("00","010","00","000","00","000000","000","000","000","000000","00000","0010",'1'),-- ['X->[21:SP]'] 
	("00","000","00","000","00","000000","001","000","010","000000","00000","0000",'1'),-- ['[PC]->X', 'PC++'] 
	("00","000","01","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->SH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","100","000000","00000","0000",'1'),-- ['[PC]->Y', 'PC++'] 
	("00","000","10","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->DH', 'PC++'] 
	("00","000","00","000","00","000000","001","000","001","000000","00000","0000",'1'),-- ['[PC]->A', 'PC++'] 
	("00","000","11","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->LH', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- [] 
	("00","000","00","000","00","000000","000","000","000","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("00","000","00","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH']  
	("00","110","00","000","00","000000","000","000","010","001000","00110","0000",'1'),-- ['[SH:X]->DR', 'ALU(X+/-1)->X'] 
	("00","111","01","000","00","000000","000","000","000","100000","10000","1000",'1'),-- ['DR->[DH:Y]', 'ALU(SH+/-C)->SH'] 
	("00","000","00","000","00","000000","000","000","100","001100","00111","0000",'0'),-- ['ALU(Y+/-1)->Y'] 
	("00","000","10","000","00","000000","000","000","000","100100","10001","0000",'0'),-- ['ALU(DH+/-C)->DH'] 
	("00","000","00","000","00","000000","000","000","001","000100","00110","0000",'0'),-- ['ALU(A+/-1)->A'] 
	("11","000","11","000","00","000000","000","000","000","101000","10000","0000",'0'),-- ['ALU(LH+/-C)->LH'] 
	("00","010","00","000","00","000000","000","010","010","000000","00000","0000",'1'),-- ['ALU([21:SP])->X', 'SP++'] 
	("00","010","00","000","00","000000","000","010","001","000000","00000","0000",'1'),-- ['ALU([21:SP])->A', 'SP++'] 
	("10","010","00","000","00","000000","000","000","100","000000","00000","0000",'1'),-- ['ALU([21:SP])->Y']
	-- F4 SET
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","110","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F5 SBC ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("01","011","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[20:AAL])->A', 'Flags'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F6 INC ZP,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011000","000","000","000","000000","00000","0000",'0'),-- ['AAL+X->AAL']
	("00","011","00","001","01","000000","000","000","000","000000","00111","0000",'1'),-- ['ALU([20:AAL])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F7 SMB7
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","01","000000","000","000","000","110000","01110","0000",'1'),-- ['ALU([20:AAL])->T'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","011","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[20:AAL]'] 
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F8 SED
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","100","00","000000","000","000","000","000000","00000","0000",'1'),-- ['Flags']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- F9 SBC ABS,Y
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","100001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+Y->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH'] 
	("01","001","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- FA PLX
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","010","000","000000","00000","0000",'0'),-- ['SP++']
	("10","010","00","001","00","000000","000","000","010","000000","00000","0000",'1'),-- ['ALU([21:SP])->X']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- FB
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- FC
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- FD SBC ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH']
	("01","001","00","101","00","000000","000","000","001","000100","00101","0000",'1'),-- ['ALU(A,[AA])->A', 'Flags']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- FE INC ABS,X
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","011001","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAH', 'PC++', 'AAL+X->AAL']
	("00","000","00","000","00","000011","000","000","000","000000","00000","0000",'0'),-- ['AAH+AALCarry->AAH']
	("00","001","00","001","01","000000","000","000","000","000000","00111","0000",'1'),-- ['ALU([AA])->T', 'Flags'] 
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("10","001","00","000","00","000000","000","000","000","000000","00000","0100",'1'),-- ['T->[AA]']
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	-- FF BBS7
	("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->IR', 'PC++'] 
	("00","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("00","011","00","000","00","000000","000","000","000","000000","00000","0000",'1'),-- ['[20:AAL]->DR']
	("10","000","00","000","00","001000","001","000","000","000000","00000","0000",'1'),-- ['[PC]->AAL', 'PC++']
	("00","000","00","000","00","000000","100","000","000","000000","00000","0000",'0'),-- ['PC+AAL->PC']
	("10","000","00","000","00","000000","000","000","000","000000","00000","0000",'0'),-- []
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X'),
	("XX","XXX","XX","XXX","XX","XXXXXX","XXX","XXX","XXX","XXXXXX","XXXXX","XXXX",'X')
	);
	
	type ALUCtrl_t is array(0 to 17) of ALUCtrl_r;
	constant ALU_TAB: ALUCtrl_t := (
	("100","100",'0'),-- 00000 LOAD
	("100","001",'0'),-- 00001 AND
	("100","000",'0'),-- 00010 ORA
	("100","010",'0'),-- 00011 EOR
	("100","011",'0'),-- 00100 ADC
	("100","111",'1'),-- 00101 SBC
	("110","111",'0'),-- 00110 DEC 
	("110","011",'0'),-- 00111 INC
	("000","100",'0'),-- 01000 ASL
	("010","100",'0'),-- 01001 LSR
	("001","100",'0'),-- 01010 ROL
	("011","100",'0'),-- 01011 ROR
	("100","001",'1'),-- 01100 BIT
	("100","101",'0'),-- 01101 TRB
	("100","101",'1'),-- 01110 TSB
	("100","110",'0'),-- 01111 CMP
	("111","111",'0'),-- 10000 DEC16 
	("111","011",'0') -- 10001 INC16
	);


	signal MI    		: MicroInst_r;
	signal ALUFlags	: ALUCtrl_r;

begin
	
	ALUFlags <= ALU_TAB(to_integer(unsigned(MI.ALUCtrl)));

	process(CLK, RST_N)
		variable N : unsigned(12 downto 0);
	begin
		if RST_N = '0' then
			MI <= ("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1');
		elsif rising_edge(CLK) then
			if EN = '1' then
				N := resize( ("0"&unsigned(IR) * 23) + STATE, N'length);
				if STATE = "00000" then
					MI <= ("00","000","00","000","00","000000","001","000","000","000000","00000","0000",'1');
				else
					MI <= M_TAB(to_integer(N));
				end if;
			end if;
		end if;
	end process;
	 
	M <= (MI.STATE_CTRL,
			MI.ADDR_BUS,
			MI.LOAD_SDLH,
			MI.LOAD_P,
			MI.LOAD_T,
			MI.ADDR_CTRL,
			MI.LOAD_PC,
			MI.LOAD_SP,
			MI.AXY_CTRL,
			MI.ALUBUS_CTRL(5 downto 2),
			MI.OUT_BUS,
			MI.MEM_CYCLE,
			ALUFlags);

	 
end rtl;