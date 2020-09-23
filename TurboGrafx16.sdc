derive_pll_clocks
derive_clock_uncertainty

set_multicycle_path -from {emu|sdram|*} -to [get_clocks {*|pll|pll_inst|altera_pll_i|*[1].*|divclk}] -start -setup 2
set_multicycle_path -from {emu|sdram|*} -to [get_clocks {*|pll|pll_inst|altera_pll_i|*[1].*|divclk}] -start -hold 1
set_multicycle_path -from {emu|ddram|*} -to [get_clocks {*|pll|pll_inst|altera_pll_i|*[1].*|divclk}] -start -setup 2
set_multicycle_path -from {emu|ddram|*} -to [get_clocks {*|pll|pll_inst|altera_pll_i|*[1].*|divclk}] -start -hold 1

set_multicycle_path -from {emu|psg_filter|*} -setup 3
set_multicycle_path -from {emu|psg_filter|*} -hold 2
set_multicycle_path -from {emu|adpcm_filter|*} -setup 3
set_multicycle_path -from {emu|adpcm_filter|*} -hold 2

set_false_path -from {emu|use_sdr}
