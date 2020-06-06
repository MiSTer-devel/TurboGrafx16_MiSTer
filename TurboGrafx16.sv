//============================================================================
//  TurboGrafx16 / PC Engine
//
//  Port to MiSTer
//  Copyright (C) 2017-2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] VIDEO_ARX,
	output  [7:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S, // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS,

	output reg  [7:0] stat_cnt, comm_cnt
);


//`define DEBUG_BUILD


`ifdef DEBUG_BUILD
	localparam LITE = 1;
`else
	localparam LITE = 0;
`endif

assign ADC_BUS  = 'Z;
assign VGA_F1 = 0;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;

assign LED_USER  = cart_download | bk_state | bk_pending;
assign LED_DISK  = 0;
assign LED_POWER = 0;
assign BUTTONS   = osd_btn | llapi_osd;

assign VIDEO_ARX = status[1] ? 8'd16 : overscan ? 8'd4 : 8'd47;
assign VIDEO_ARY = status[1] ? 8'd9  : overscan ? 8'd3 : 8'd37;

// Status Bit Map:
// 0         1         2         3
// 01234567890123456789012345678901
// 0123456789ABCDEFGHIJKLMNOPQRSTUV
// XXXXX XXXXXXX XXXXXXXX X  XX  XX

`include "build_id.v"
parameter CONF_STR = {
	"TGFX16;;",
	"FS0,PCEBIN,Load TurboGrafx;",
`ifndef DEBUG_BUILD
	"FS1,SGX,Load SuperGrafx;",
`endif
	"-;",
	"S0,CUE,Insert CD;",
	"-;",
	"C,Cheats;",
	"H1OO,Cheats enabled,ON,OFF;",
	"-;",
	"D0RG,Load Backup RAM;",
	"D0R7,Save Backup RAM;",
	"D0ON,Autosave,OFF,ON;",
	"-;",
	"P1,Audio & Video;",
	"P1-;",
	"P1O1,Aspect ratio,4:3,16:9;",
	"P1O8A,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"P1-;",
	"P1OH,Overscan,Hidden,Visible;",
	"P1OF,Border Color,Original,Black;",
	"P1OB,Sprites per line,Normal,Extra;",
	"P1-;",
	"P1OK,CD Audio Boost,No,2x;",
	"P1OIJ,Master Audio Boost,No,2x,4x;",
	"P2,Hardware;",
	"P2-;",
	"P2O3,ROM Data Swap,No,Yes;",
`ifdef DEBUG_BUILD
	"P2O6,ROM Storage,SDRAM,DDR3;",
`else
	"D4H2P2O6,ROM Storage,SDRAM,SDRAM;",
	"D4H3P2O6,ROM Storage,DDR3,DDR3;",
`endif
	"P2-;",
	"P2OE,Arcade Card,Disabled,Enabled;",
	"P2OP,CD Seek,Normal,Fast;",
	"P2-;",
	"P2OUV,USER I/O,Off,SNAC,LLAPI;",
	"H5P2OL,MB128,Disabled,Enabled;",
	"P2-;",
	"D0P2RC,Format Backup RAM;",
	"-;",
	"H5O2,Turbo Tap,Disabled,Enabled;",
	"H5O4,Controller,2 Buttons,6 Buttons;",
	"H5OQR,Special,None,Mouse,Pachinko;",
	"H5-;",
	"R0,Reset;",
	"J1,Button I,Button II,Select,Run,Button III,Button IV,Button V,Button VI;",
	"jn,A,B,Select,Start,X,Y,L,R;",
	"jp,A,B,Select,Start,L,R,Y,X;",
	"V,v",`BUILD_DATE
};


reg osd_btn = 0;
always @(posedge clk_sys) begin
	integer timeout = 0;
	reg	has_bootrom = 0;
	reg	last_rst = 0;

	if (reset) last_rst = 0;
	if (status[0]) last_rst = 1;

	if (cart_download & ioctl_wr & status[0]) has_bootrom <= 1;

	if (last_rst & ~status[0]) begin
		osd_btn <= 0;
		if (timeout < 24000000) begin
			timeout <= timeout + 1;
			osd_btn <= ~has_bootrom;
		end
	end
end

////////////////////   CLOCKS   ///////////////////

wire clk_sys, clk_ram;
wire pll_locked;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_ram),
	.outclk_1(clk_sys),
	.locked(pll_locked)
);

///////////////////////////////////////////////////

wire [31:0] status;
wire  [1:0] buttons;

wire [11:0] joystick_0, joystick_1, joystick_2, joystick_3, joystick_4;
wire [15:0] joy_a;
wire  [7:0] pd_0;

wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_dout;
reg         ioctl_wait;
wire        forced_scandoubler;

reg  [31:0] sd_lba;
reg         sd_rd = 0;
reg         sd_wr = 0;
wire        sd_ack;
wire  [7:0] sd_buff_addr;
wire [15:0] sd_buff_dout;
wire [15:0] sd_buff_din;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [63:0] img_size;

wire [21:0] gamma_bus;
wire [15:0] sdram_sz;

wire [10:0] ps2_key;
wire [24:0] ps2_mouse;

hps_io #(.STRLEN($size(CONF_STR)>>3), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.buttons(buttons),
	.status(status),
	.status_menumask({snac, 1'd1, use_sdr, ~use_sdr, ~gg_avail,~bk_ena}),
	.forced_scandoubler(forced_scandoubler),

	.sdram_sz(sdram_sz),

	.new_vmode(0),
	.gamma_bus(gamma_bus),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_wait(ioctl_wait),

	.sd_lba(sd_lba),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.joystick_2(joystick_2),
	.joystick_3(joystick_3),
	.joystick_4(joystick_4),
	.joystick_analog_0(joy_a),
	.paddle_0(pd_0),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),

	.EXT_BUS(EXT_BUS)
);

wire reset = (RESET | status[0] | buttons[1] | bk_loading);

wire code_index      = &ioctl_index;
wire code_download   = ioctl_download & code_index;
wire cart_download   = ioctl_download & (ioctl_index[5:0] <= 6'h01);
wire cd_dat_download = ioctl_download & (ioctl_index[5:0] == 6'h02);

wire overscan = ~status[17];

wire [95:0] cd_comm;
wire        cd_comm_send;
reg  [15:0] cd_stat;
reg         cd_stat_rec;
reg         cd_dataout_req;
wire [79:0] cd_dataout;
wire        cd_dataout_send;
wire        cd_reset_req;
reg         cd_region;

wire [21:0] cd_ram_a;
wire        cd_ram_rd, cd_ram_wr;
wire  [7:0] cd_ram_do;

wire        ce_rom;

wire [15:0] cdda_sl, cdda_sr, adpcm_s, psg_sl, psg_sr;

pce_top #(LITE) pce_top
(
	.RESET(reset|cart_download),
	.COLD_RESET(cart_download),

	.CLK(clk_sys),

	.ROM_RD(rom_rd),
	.ROM_RDY(rom_sdrdy & rom_ddrdy),
	.ROM_A(rom_rdaddr),
	.ROM_DO(use_sdr ? rom_sdata : rom_ddata),
	.ROM_SZ(romwr_a[23:16]),
	.ROM_POP(populous[romwr_a[9]]),
	.ROM_CLKEN(ce_rom),

	.BRM_A(bram_addr),
	.BRM_DO(bram_q),
	.BRM_DI(bram_data),
	.BRM_WE(bram_wr),

	.GG_EN(status[24]),
	.GG_CODE(gg_code),
	.GG_RESET((cart_download | code_download) & ioctl_wr & !ioctl_addr),
	.GG_AVAIL(gg_avail),

	.SP64(status[11]),
	.SGX(sgx && !LITE),
	
	.JOY_OUT(joy_out),
	.JOY_IN(joy_in),

	.CD_EN(cd_en),
	.AC_EN(status[14]),

	.CD_RAM_A(cd_ram_a),
	.CD_RAM_DO(cd_ram_do),
	.CD_RAM_DI(use_sdr ? rom_sdata : rom_ddata),
	.CD_RAM_RD(cd_ram_rd),
	.CD_RAM_WR(cd_ram_wr),

	.CD_STAT(cd_stat[7:0]),
	.CD_MSG(cd_stat[15:8]),
	.CD_STAT_GET(cd_stat_rec),

	.CD_COMM(cd_comm),
	.CD_COMM_SEND(cd_comm_send),

	.CD_DOUT_REQ(cd_dataout_req),
	.CD_DOUT(cd_dataout),
	.CD_DOUT_SEND(cd_dataout_send),

	.CD_REGION(cd_region),
	.CD_RESET(cd_reset_req),

	.CD_DATA(!cd_dat_byte ? cd_dat[7:0] : cd_dat[15:8]),
	.CD_WR(cd_wr),
	.CD_DATA_END(cd_dat_req),
	.CD_DM(cd_dm),

	.CDDA_SL(cdda_sl),
	.CDDA_SR(cdda_sr),
	.ADPCM_S(adpcm_s),
	.PSG_SL(psg_sl),
	.PSG_SR(psg_sr),

	.BG_EN(VDC_BG_EN),
	.SPR_EN(VDC_SPR_EN),
	.GRID_EN(VDC_GRID_EN),
	.CPU_PAUSE_EN(CPU_PAUSE_EN),

	.ReducedVBL(~overscan),
	.BORDER_EN(~status[15]),
	.VIDEO_R(r),
	.VIDEO_G(g),
	.VIDEO_B(b),
	.VIDEO_BW(bw),
	//.VIDEO_CE(ce_vid),
	.VIDEO_CE_FS(ce_vid),
	.VIDEO_VS(vs),
	.VIDEO_HS(hs),
	.VIDEO_HBL(hbl),
	.VIDEO_VBL(vbl)
);


//CD communication

wire  [35:0] EXT_BUS;
reg  [112:0] cd_in = 0;
wire [112:0] cd_out;
hps_ext hps_ext
(
	.clk_sys(clk_sys),
	.EXT_BUS(EXT_BUS),
	.cd_in(cd_in),
	.cd_out(cd_out)
);

reg cd_en = 0;
always @(posedge clk_sys) begin
	if(img_mounted && img_size) cd_en <= 1;
	if(cart_download) cd_en <= 0;
end

reg        cd_dat_req;
always @(posedge clk_sys) begin
	reg cd_out112_last = 1;
	reg cd_comm_send_old = 0, cd_dataout_send_old = 0, cd_dat_req_old = 0, cd_reset_req_old = 0;

	cd_stat_rec <= 0;
	cd_dataout_req <= 0;
	if (reset || cart_download) begin
		comm_cnt <= 0;
		stat_cnt <= 0;
		cd_region <= 0;
	end
	else begin
		if (cd_out[112] != cd_out112_last) begin
			cd_out112_last <= cd_out[112];

			cd_stat <= cd_out[15:0];
			cd_stat_rec <= ~cd_out[16];
			cd_dataout_req <= cd_out[16];
			cd_region <= cd_out[17];

			stat_cnt <= stat_cnt + 8'd1;
		end

		cd_comm_send_old <= cd_comm_send;
		cd_dataout_send_old <= cd_dataout_send;
		cd_dat_req_old <= cd_dat_req;
		cd_reset_req_old <= cd_reset_req;
		if (cd_comm_send && !cd_comm_send_old) begin
			cd_in[95:0] <= cd_comm;
			cd_in[111:96] <= {status[25],15'd0};
			cd_in[112] <= ~cd_in[112];

			comm_cnt <= comm_cnt + 8'd1;
		end
		else if (cd_dataout_send && !cd_dataout_send_old) begin
			cd_in[79:0] <= cd_dataout;
			cd_in[111:96] <= 16'h0001;
			cd_in[112] <= ~cd_in[112];

//			comm_cnt <= comm_cnt + 8'd1;
		end
		else if (cd_dat_req && !cd_dat_req_old) begin
			cd_in[111:96] <= 16'h0002;
			cd_in[112] <= ~cd_in[112];
		end
		else if (cd_reset_req && !cd_reset_req_old) begin
			cd_in[111:96] <= 16'h00FF;
			cd_in[112] <= ~cd_in[112];
		end
	end
end

reg [15:0] cd_dat;
reg        cd_wr;
reg        cd_dat_byte;
reg        cd_dm;
always @(posedge clk_sys) begin
	reg old_download;
	reg head_pos, cd_dat_write;
	reg [14:0] cd_dat_len, cd_dat_cnt;

	old_download <= cd_dat_download;
	if ((~old_download && cd_dat_download) || reset) begin
		head_pos <= 0;
		cd_dat_len <= 0;
		cd_dat_cnt <= 0;
	end
	else if (ioctl_wr && cd_dat_download) begin
		if (!head_pos) begin
			{cd_dm,cd_dat_len} <= ioctl_dout;
			cd_dat_cnt <= 0;
			head_pos <= 1;
		end
		else if (cd_dat_cnt < cd_dat_len) begin
			cd_dat_write <= 1;
			cd_dat_byte <= 0;
			cd_dat <= ioctl_dout;
		end
	end

	if (cd_dat_write) begin
		if (!cd_wr) begin
			cd_wr <= 1;
		end
		else begin
			cd_wr <= 0;
			cd_dat_byte <= ~cd_dat_byte;
			cd_dat_cnt <= cd_dat_cnt + 15'd1;
			if (cd_dat_byte || cd_dat_cnt >= cd_dat_len-1) begin
				cd_dat_write <= 0;
			end
		end
	end
end


////////////////////////////  VIDEO  ///////////////////////////////////

wire [2:0] r,g,b;
wire hs,vs;
wire hbl,vbl;
wire bw;

wire ce_vid;
assign CLK_VIDEO = clk_ram;

reg ce_pix;
always @(posedge CLK_VIDEO) begin
	reg old_ce;

	old_ce <= ce_vid;
	ce_pix <= ~old_ce & ce_vid;
end

color_mix color_mix
(
	.clk_vid(CLK_VIDEO),
	.ce_pix(ce_pix),
	.mix(bw ? 3'd5 : 0),

	.R_in({r,r,r[2:1]}),
	.G_in({g,g,g[2:1]}),
	.B_in({b,b,b[2:1]}),
	.HSync_in(hs),
	.VSync_in(vs),
	.HBlank_in(hbl),
	.VBlank_in(vbl),

	.R_out(R),
	.G_out(G),
	.B_out(B),
	.HSync_out(HS),
	.VSync_out(VS),
	.HBlank_out(HBlank),
	.VBlank_out(VBlank)
);

wire [7:0] R,G,B;
wire HS,VS;
wire HBlank,VBlank;

wire [2:0] scale = status[10:8];
wire [2:0] sl = scale ? scale - 1'd1 : 3'd0;

assign VGA_SL = sl[1:0];

reg VSync, HSync;
always @(posedge CLK_VIDEO) begin
	HSync <= HS;
	if(~HSync & HS) VSync <= VS;
end

video_mixer #(.LINE_LENGTH(560), .GAMMA(1)) video_mixer
(
	.*,

	.clk_vid(CLK_VIDEO),
	.ce_pix(ce_pix),
	.ce_pix_out(CE_PIXEL),

	.scanlines(0),
	.scandoubler(scale || forced_scandoubler),
	.hq2x(scale==1),
	.mono(0)
);


////////////////////////////  AUDIO  ///////////////////////////////////

localparam [3:0] comp_f1 = 4;
localparam [3:0] comp_a1 = 2;
localparam       comp_x1 = ((32767 * (comp_f1 - 1)) / ((comp_f1 * comp_a1) - 1)) + 1; // +1 to make sure it won't overflow
localparam       comp_b1 = comp_x1 * comp_a1;

localparam [3:0] comp_f2 = 8;
localparam [3:0] comp_a2 = 4;
localparam       comp_x2 = ((32767 * (comp_f2 - 1)) / ((comp_f2 * comp_a2) - 1)) + 1; // +1 to make sure it won't overflow
localparam       comp_b2 = comp_x2 * comp_a2;

function [15:0] compr; input [15:0] inp;
	reg [15:0] v, v1, v2;
	begin
		v  = inp[15] ? (~inp) + 1'd1 : inp;
		v1 = (v < comp_x1[15:0]) ? (v * comp_a1) : (((v - comp_x1[15:0])/comp_f1) + comp_b1[15:0]);
		v2 = (v < comp_x2[15:0]) ? (v * comp_a2) : (((v - comp_x2[15:0])/comp_f2) + comp_b2[15:0]);
		v  = status[19] ? v2 : v1;
		compr = inp[15] ? ~(v-1'd1) : v;
	end
endfunction

reg [17:0] audio_l, audio_r;
reg [15:0] cmp_l, cmp_r;
always @(posedge clk_sys) begin
	reg [17:0] pre_l, pre_r;
	reg [15:0] psg_sl_red, psg_sr_red, adpcm_s_red;

	psg_sl_red  <=  ($signed(psg_sl) >>> 1) +  ($signed(psg_sl) >>> 2) +  ($signed(psg_sl) >>> 4);
	psg_sr_red  <=  ($signed(psg_sr) >>> 1) +  ($signed(psg_sr) >>> 2) +  ($signed(psg_sr) >>> 4);
	adpcm_s_red <= ($signed(adpcm_s) >>> 1) + ($signed(adpcm_s) >>> 2) + ($signed(adpcm_s) >>> 3);

	pre_l <= ( CDDA_EN                ? {{2{cdda_sl[15]}},         cdda_sl} : 18'd0)
			 + ((CDDA_EN && status[20]) ? {{2{cdda_sl[15]}},         cdda_sl} : 18'd0)
			 + ( PSG_EN                 ? {{2{psg_sl_red[15]}},   psg_sl_red} : 18'd0)
			 + ( ADPCM_EN               ? {{2{adpcm_s_red[15]}}, adpcm_s_red} : 18'd0);

	pre_r <= ( CDDA_EN                ? {{2{cdda_sr[15]}},         cdda_sr} : 18'd0)
			 + ((CDDA_EN && status[20]) ? {{2{cdda_sr[15]}},         cdda_sr} : 18'd0)
			 + ( PSG_EN                 ? {{2{psg_sr_red[15]}},   psg_sr_red} : 18'd0)
			 + ( ADPCM_EN               ? {{2{adpcm_s_red[15]}}, adpcm_s_red} : 18'd0);

	if(~status[20]) begin
		// 3/4 + 1/4 to cover the whole range.
		audio_l <= $signed(pre_l) + ($signed(pre_l)>>>2);
		audio_r <= $signed(pre_r) + ($signed(pre_r)>>>2);
	end
	else begin
		audio_l <= pre_l;
		audio_r <= pre_r;
	end

	cmp_l <= compr(audio_l[17:2]);
	cmp_r <= compr(audio_r[17:2]);
end

assign AUDIO_L = status[19:18] ? cmp_l : audio_l[17:2];
assign AUDIO_R = status[19:18] ? cmp_r : audio_r[17:2];
assign AUDIO_S = 1;
assign AUDIO_MIX = 0;


////////////////////////////  MEMORY  //////////////////////////////////

reg use_sdr = 0;
always @(posedge clk_ram) if(~rom_rd) use_sdr <= LITE ? ~status[6] : |sdram_sz[14:0];

wire [21:0] rom_rdaddr;
wire  [7:0] rom_ddata, rom_sdata;
wire        rom_rd, rom_sdrdy, rom_ddrdy;

assign DDRAM_CLK = clk_ram;
ddram ddram
(
	.*,

	.wraddr(cart_download ? romwr_a : {3'b001,cd_ram_a}),
	.din(cart_download ? romwr_d : {cd_ram_do,cd_ram_do}),
	.we(cart_download ? 0 : cd_ram_wr & ce_rom),
	.we_req(rom_wr),
	.we_ack(dd_wrack),

	.rdaddr(rom_rd ? {3'b000,(rom_rdaddr + (romwr_a[9] ? 22'h200 : 22'h0))} : {3'b001,cd_ram_a}),
	.dout(rom_ddata),
	.rd_req(~use_sdr & (rom_rd | cd_ram_rd) & ce_rom),
	.rd_rdy(rom_ddrdy)
);

sdram sdram
(
	.*,

	.init(~pll_locked),
	.clk(clk_ram),
	.clkref(ce_rom),

	.waddr(cart_download ? romwr_a : {3'b001,cd_ram_a}),
	.din(cart_download ? romwr_d : {cd_ram_do,cd_ram_do}),
	.we(cart_download ? 0 : cd_ram_wr & ce_rom),
	.we_req(rom_wr),
	.we_ack(sd_wrack),

	.raddr(rom_rd ? {3'b000,(rom_rdaddr + (romwr_a[9] ? 22'h200 : 22'h0))} : {3'b001,cd_ram_a}),
	.rd(use_sdr & (rom_rd | cd_ram_rd) & ce_rom),
	.rd_rdy(rom_sdrdy),
	.dout(rom_sdata)
);


wire        romwr_ack;
reg  [23:0] romwr_a;
wire [15:0] romwr_d = status[3] ?
		{ ioctl_dout[8], ioctl_dout[9], ioctl_dout[10],ioctl_dout[11],ioctl_dout[12],ioctl_dout[13],ioctl_dout[14],ioctl_dout[15],
		  ioctl_dout[0], ioctl_dout[1], ioctl_dout[2], ioctl_dout[3], ioctl_dout[4], ioctl_dout[5], ioctl_dout[6], ioctl_dout[7] }
		: ioctl_dout;

reg  rom_wr = 0;
wire sd_wrack, dd_wrack;

reg [1:0] populous;
reg sgx;
always @(posedge clk_sys) begin
	reg old_download, old_reset;

	old_download <= cart_download;
	old_reset <= reset;

	if(~old_reset && reset) ioctl_wait <= 0;
	if(~old_download && cart_download) begin
		romwr_a <= 0;
		populous <= 2'b11;
		sgx <= ioctl_index[0];
	end
	else begin
		if(ioctl_wr & cart_download) begin
			ioctl_wait <= 1;
			rom_wr <= ~rom_wr;
			if((romwr_a[23:4] == 'h212) || (romwr_a[23:4] == 'h1f2)) begin
				case(romwr_a[3:0])
					 6: if(romwr_d != 'h4F50) populous[romwr_a[13]] <= 0;
					 8: if(romwr_d != 'h5550) populous[romwr_a[13]] <= 0;
					10: if(romwr_d != 'h4F4C) populous[romwr_a[13]] <= 0;
					12: if(romwr_d != 'h5355) populous[romwr_a[13]] <= 0;
				endcase
			end
		end else if(ioctl_wait && (rom_wr == dd_wrack) && (rom_wr == sd_wrack)) begin
			ioctl_wait <= 0;
			romwr_a <= romwr_a + 2'd2;
		end
	end
end

//////////////////   LLAPI   ///////////////////

wire [31:0] llapi_buttons, llapi_buttons2;
wire [71:0] llapi_analog, llapi_analog2;
wire [7:0]  llapi_type, llapi_type2;
wire llapi_en, llapi_en2;

wire llapi_select = status[31];

wire llapi_latch_o, llapi_latch_o2, llapi_data_o, llapi_data_o2;

always_comb begin
	USER_OUT = 6'b111111;
	if (llapi_select) begin
		USER_OUT[0] = llapi_latch_o;
		USER_OUT[1] = llapi_data_o;
		USER_OUT[2] = ~(llapi_select & ~OSD_STATUS);
		USER_OUT[4] = llapi_latch_o2;
		USER_OUT[5] = llapi_data_o2;
	end else if (snac & ~OSD_STATUS) begin
		USER_OUT = {2'b11, snac_clr, 1'b1, snac_sel, 2'b11};
	end
end

LLAPI llapi
(
	.CLK_50M(CLK_50M),
	.LLAPI_SYNC(VSync),
	.IO_LATCH_IN(USER_IN[0]),
	.IO_LATCH_OUT(llapi_latch_o),
	.IO_DATA_IN(USER_IN[1]),
	.IO_DATA_OUT(llapi_data_o),
	.ENABLE(llapi_select & ~OSD_STATUS),
	.LLAPI_BUTTONS(llapi_buttons),
	.LLAPI_ANALOG(llapi_analog),
	.LLAPI_TYPE(llapi_type),
	.LLAPI_EN(llapi_en)
);

LLAPI llapi2
(
	.CLK_50M(CLK_50M),
	.LLAPI_SYNC(VSync),
	.IO_LATCH_IN(USER_IN[4]),
	.IO_LATCH_OUT(llapi_latch_o2),
	.IO_DATA_IN(USER_IN[5]),
	.IO_DATA_OUT(llapi_data_o2),
	.ENABLE(llapi_select & ~OSD_STATUS),
	.LLAPI_BUTTONS(llapi_buttons2),
	.LLAPI_ANALOG(llapi_analog2),
	.LLAPI_TYPE(llapi_type2),
	.LLAPI_EN(llapi_en2)
);

reg llapi_button_pressed, llapi_button_pressed2;

always @(posedge CLK_50M) begin
        if (reset) begin
                llapi_button_pressed  <= 0;
                llapi_button_pressed2 <= 0;
	end else begin
		if (|llapi_buttons)
                	llapi_button_pressed  <= 1;
        	if (|llapi_buttons2)
                	llapi_button_pressed2 <= 1;
	end
end

// controller id is 0 if there is either an Atari controller or no controller
// if id is 0, assume there is no controller until a button is pressed
wire use_llapi = llapi_en && llapi_select && (|llapi_type || llapi_button_pressed);
wire use_llapi2 = llapi_en2 && llapi_select && (|llapi_type2 || llapi_button_pressed2);

// Indexes:
// 0 = D+    = P1 Latch
// 1 = D-    = P1 Data
// 2 = TX-   = LLAPI Enable
// 3 = GND_d = N/C
// 4 = RX+   = P2 Latch
// 5 = RX-   = P2 Data

wire [11:0] joy_ll_a;
always_comb begin
        // button layout for genesis controllers
        if (llapi_type == 20 || llapi_type == 21) begin
                joy_ll_a = {
                        llapi_buttons[6],  llapi_buttons[3],  llapi_buttons[2],  llapi_buttons[0], // VI, V, IV, III
                        llapi_buttons[5],  llapi_buttons[4], // Run, Select
                        llapi_buttons[1],  llapi_buttons[7], // II, I
                        llapi_buttons[27], llapi_buttons[26], llapi_buttons[25], llapi_buttons[24] // d-pad
                };
        // button layout for tg16 controllers
        end else if (llapi_type == 54 || llapi_type == 23) begin
                joy_ll_a = {
                        llapi_buttons[3],  llapi_buttons[2],  llapi_buttons[8],  llapi_buttons[9], // VI, V, IV, III
                        llapi_buttons[5],  llapi_buttons[4], // Run, Select
                        llapi_buttons[0],  llapi_buttons[1], // II, I
                        llapi_buttons[27], llapi_buttons[26], llapi_buttons[25], llapi_buttons[24] // d-pad
                };
        // saturn controller layout, same as genesis with select moved to RT
        end else if (llapi_type == 8 || llapi_type == 3) begin
                joy_ll_a = {
                        llapi_buttons[6],  llapi_buttons[3],  llapi_buttons[2],  llapi_buttons[0], // VI, V, IV, III
                        llapi_buttons[5],  llapi_buttons[9], // Run, Select
                        llapi_buttons[1],  llapi_buttons[7], // II, I
                        llapi_buttons[27], llapi_buttons[26], llapi_buttons[25], llapi_buttons[24] // d-pad
                };
        end else begin
                joy_ll_a = {
                        llapi_buttons[7],  llapi_buttons[3],  llapi_buttons[6],  llapi_buttons[2], // VI, V, IV, III
                        llapi_buttons[5],  llapi_buttons[4], // Run, Select
                        llapi_buttons[0],  llapi_buttons[1], // II, I
                        llapi_buttons[27], llapi_buttons[26], llapi_buttons[25], llapi_buttons[24] // d-pad
                };
        end
end

wire [11:0] joy_ll_b;
always_comb begin
        // button layout for genesis controllers
        if (llapi_type2 == 20 || llapi_type2 == 21) begin
                joy_ll_b = {
                        llapi_buttons2[6],  llapi_buttons2[3],  llapi_buttons2[2],  llapi_buttons2[0], // VI, V, IV, III
                        llapi_buttons2[5],  llapi_buttons2[4], // Run, Select
                        llapi_buttons2[1],  llapi_buttons2[7], // II, I
                        llapi_buttons2[27], llapi_buttons2[26], llapi_buttons2[25], llapi_buttons2[24] // d-pad
                };
        // button layout for tg16 controllers
        end else if (llapi_type2 == 54 || llapi_type2 == 23) begin
                joy_ll_b = {
                        llapi_buttons2[3],  llapi_buttons2[2],  llapi_buttons2[8],  llapi_buttons2[9], // VI, V, IV, III
                        llapi_buttons2[5],  llapi_buttons2[4], // Run, Select
                        llapi_buttons2[0],  llapi_buttons2[1], // II, I
                        llapi_buttons2[27], llapi_buttons2[26], llapi_buttons2[25], llapi_buttons2[24] // d-pad
                };
        // saturn controller layout, same as genesis with select moved to RT
        end else if (llapi_type2 == 8 || llapi_type2 == 3) begin
                joy_ll_b = {
                        llapi_buttons2[6],  llapi_buttons2[3],  llapi_buttons2[2],  llapi_buttons2[0], // VI, V, IV, III
                        llapi_buttons2[5],  llapi_buttons2[9], // Run, Select
                        llapi_buttons2[1],  llapi_buttons2[7], // II, I
                        llapi_buttons2[27], llapi_buttons2[26], llapi_buttons2[25], llapi_buttons2[24] // d-pad
                };
        end else begin
                joy_ll_b = {
                        llapi_buttons2[7],  llapi_buttons2[3],  llapi_buttons2[6],  llapi_buttons2[2], // VI, V, IV, III
                        llapi_buttons2[5],  llapi_buttons2[4], // Run, Select
                        llapi_buttons2[0],  llapi_buttons2[1], // II, I
                        llapi_buttons2[27], llapi_buttons2[26], llapi_buttons2[25], llapi_buttons2[24] // d-pad
                };
        end
end

wire llapi_osd = (llapi_buttons[26] & llapi_buttons[5] & llapi_buttons[0]) || (llapi_buttons2[26] & llapi_buttons2[5] & llapi_buttons2[0]);

// if LLAPI is enabled, shift USB controllers over to the next available player slot
wire [11:0] joy_0, joy_1, joy_2, joy_3, joy_4;
always_comb begin
        if (use_llapi & use_llapi2) begin
                joy_0 = joy_ll_a;
                joy_1 = joy_ll_b;
                joy_2 = joystick_0;
                joy_3 = joystick_1;
                joy_4 = joystick_2;
        end else if (use_llapi ^ use_llapi2) begin
                joy_0 = use_llapi  ? joy_ll_a : joystick_0;
                joy_1 = use_llapi2 ? joy_ll_b : joystick_0;
                joy_2 = joystick_1;
                joy_3 = joystick_2;
                joy_4 = joystick_3;
        end else begin
                joy_0 = joystick_0;
                joy_1 = joystick_1;
                joy_2 = joystick_2;
                joy_3 = joystick_3;
                joy_4 = joystick_4;
        end
end

////////////////////////////  CODES  ///////////////////////////////////

reg [128:0] gg_code;
wire gg_avail;

// Code layout:
// {clock bit, code flags,     32'b address, 32'b compare, 32'b replace}
//  128        127:96          95:64         63:32         31:0
// Integer values are in BIG endian byte order, so it up to the loader
// or generator of the code to re-arrange them correctly.

always_ff @(posedge clk_sys) begin
	gg_code[128] <= 1'b0;

	if (code_download & ioctl_wr) begin
		case (ioctl_addr[3:0])
			0:  gg_code[111:96]  <= ioctl_dout; // Flags Bottom Word
			2:  gg_code[127:112] <= ioctl_dout; // Flags Top Word
			4:  gg_code[79:64]   <= ioctl_dout; // Address Bottom Word
			6:  gg_code[95:80]   <= ioctl_dout; // Address Top Word
			8:  gg_code[47:32]   <= ioctl_dout; // Compare Bottom Word
			10: gg_code[63:48]   <= ioctl_dout; // Compare top Word
			12: gg_code[15:0]    <= ioctl_dout; // Replace Bottom Word
			14: begin
				gg_code[31:16]   <= ioctl_dout; // Replace Top Word
				gg_code[128]     <=  1'b1;      // Clock it in
			end
		endcase
	end
end


////////////////////////////  INPUT  ///////////////////////////////////

wire [15:0] joy_data;
always_comb begin
	case (joy_port)
		0: joy_data = status[26] ? {mouse_data, mouse_data} : ~{4'hF, joy_0[11:8], joy_0[1], joy_0[2], joy_0[0], joy_0[3], joy_0[7:4]};
		1: joy_data = status[27] ? pachinko                 : ~{4'hF, joy_1[11:8], joy_1[1], joy_1[2], joy_1[0], joy_1[3], joy_1[7:4]};
		2: joy_data = ~{4'hF, joy_2[11:8], joy_2[1], joy_2[2], joy_2[0], joy_2[3], joy_2[7:4]};
		3: joy_data = ~{4'hF, joy_3[11:8], joy_3[1], joy_3[2], joy_3[0], joy_3[3], joy_3[7:4]};
		4: joy_data = ~{4'hF, joy_4[11:8], joy_4[1], joy_4[2], joy_4[0], joy_4[3], joy_4[7:4]};
		default: joy_data = 16'h0FFF;
	endcase
end

reg [6:0] pachinko;
always @(posedge clk_sys) begin
	reg use_paddle = 0;
	reg old_pd = 0;

	old_pd <= pd_0[5];
	if(old_pd ^ pd_0[5]) use_paddle <= 1;
	if(reset | cart_download) use_paddle <= 0;

	if(use_paddle) begin
		// use only second half of paddle range
		// Spring centering paddles then can simulate pachinko's spring

		pachinko <= pd_0[6:0];
		if(pd_0 < 8'h83) pachinko <= 7'h3;
		else if(pd_0 > 8'hF4) pachinko <= 7'h74;
	end
	else begin
		pachinko <= 7'd0 - joy_a[14:8];
		if(joy_a[15:8] > 8'hFC || !joy_a[15]) pachinko <= 7'h3;
		else if(joy_a[15:8] < 8'h8B) pachinko <= 7'h74;
	end
end

wire [7:0] mouse_data;
assign mouse_data[3:0] = ~{joy_0[7:6], ps2_mouse[0], ps2_mouse[1]};

always_comb begin
	case (mouse_cnt)
		0: mouse_data[7:4] = ms_x[7:4];
		1: mouse_data[7:4] = ms_x[3:0];
		2: mouse_data[7:4] = ms_y[7:4];
		3: mouse_data[7:4] = ms_y[3:0];
	endcase
end

reg [3:0] joy_latch;
reg [2:0] joy_port;
reg [1:0] mouse_cnt;
reg [7:0] ms_x, ms_y;

always @(posedge clk_sys) begin : input_block
	reg  [1:0] last_gp;
	reg        high_buttons;
	reg [14:0] mouse_to;
	reg        ms_stb;
	reg  [7:0] msr_x, msr_y;

	joy_latch <= joy_data[{high_buttons, joy_out[0], 2'b00} +:4];

	last_gp <= joy_out;

	if(joy_out[1]) mouse_to <= 0;
	else if(~&mouse_to) mouse_to <= mouse_to + 1'd1;

	if(&mouse_to) mouse_cnt <= 3;
	if(~last_gp[1] & joy_out[1]) begin
		mouse_cnt <= mouse_cnt + 1'd1;
		if(&mouse_cnt) begin
			ms_x  <= msr_x;
			ms_y  <= msr_y;
			msr_x <= 0;
			msr_y <= 0;
		end
	end

	ms_stb <= ps2_mouse[24];
	if(ms_stb ^ ps2_mouse[24]) begin
		msr_x <= 8'd0 - ps2_mouse[15:8];
		msr_y <= ps2_mouse[23:16];
	end

	if (joy_out[1]) begin
		joy_port  <= 0;
		joy_latch <= 0;
		if (~last_gp[1]) high_buttons <= ~high_buttons && status[4];
	end
	else if (joy_out[0] && ~last_gp[0] && (status[2] | status[27])) begin
		joy_port <= joy_port + 3'd1;
	end
end

wire snac = status[30];

// Index Name    HDMI System
// 0   = D+    = 2  = d1/right/2
// 1   = D-    = 1  = d0/up/1
// 2   = TX-   = 5  = SEL
// 3   = GND_d = 4  = d3/left/run
// 4   = RX+   = 6  = CLR
// 5   = RX-   = 3  = d2/down/sel

reg [3:0] snac_dat;
reg       snac_sel, snac_clr;
always @(posedge clk_sys) begin
	reg [2:0] d0sr, d1sr, d2sr, d3sr;
	reg [20:0] sesr, clsr;

	d0sr <= {d0sr[1:0],  USER_IN[1]};
	d1sr <= {d1sr[1:0],  USER_IN[0]};
	d2sr <= {d2sr[1:0],  USER_IN[5]};
	d3sr <= {d3sr[1:0],  USER_IN[3]};
	sesr <= {sesr[8:0],  joy_out[0]};
	clsr <= {clsr[19:0], joy_out[1]};

	snac_dat <= {|d3sr, |d2sr, |d1sr, |d0sr};
	snac_sel <= |sesr;
	snac_clr <= |clsr;
end

wire [1:0] joy_out;
wire [3:0] joy_in = snac ? snac_dat : (mb128_ena & mb128_Active) ? mb128_Data : joy_latch;

/////////////////////////  BACKUP RAM SAVE/LOAD  /////////////////////////////

wire [15:0] mb128_dout;
wire        mb128_dirty;
wire        mb128_ena = status[21];
wire        mb128_Active;
wire  [3:0] mb128_Data;

MB128 MB128
(
	.reset(reset|cart_download),
	.clk_sys(clk_sys),

	.i_Clk(mb128_ena & joy_out[1]),	// send only if MB128 enabled
	.i_Data(joy_out[0]),
	
   .o_Active(mb128_Active),	// high if MB128 asserts itself instead of joypad inputs
	.o_Data(mb128_Data),

	.bk_clk(clk_sys),
	.bk_address({sd_lba[7:0] - 3'd4,sd_buff_addr}),
	.bk_din(sd_buff_dout),
	.bk_dout(mb128_dout),
	.bk_we(~bk_int & sd_buff_wr & sd_ack),
	.bk_written(mb128_dirty)
);

reg bk_pending;

always @(posedge clk_sys) begin
	if (bk_ena && ~OSD_STATUS && (bram_wr || mb128_dirty))
		bk_pending <= 1'b1;
	else if (bk_state)
		bk_pending <= 1'b0;
end

wire [10:0] bram_addr;
wire  [7:0] bram_data;
wire  [7:0] bram_q;
wire        bram_wr;

wire        format = status[12];
reg   [3:0] defbram = 4'hF;
reg  [15:0] defval[4] = '{ 16'h5548, 16'h4D42, 16'h8800, 16'h8010 }; //{ HUBM,0x00881080 };

wire        bk_int = !sd_lba[31:2];
wire [15:0] bk_int_dout;

assign      sd_buff_din = bk_int ? bk_int_dout : mb128_dout;

dpram_difclk #(11,8,10,16) backram
(
	.clock0(clk_sys),
   .address_a(bram_addr),
	.data_a(bram_data),
	.wren_a(bram_wr),
	.q_a(bram_q),

	.clock1(clk_sys),
	.address_b(defbram[3] ? {sd_lba[1:0],sd_buff_addr} : defbram[2:1]),
	.data_b(defbram[3] ? sd_buff_dout : defval[defbram[2:1]]),
	.wren_b(defbram[3] ? bk_int & sd_buff_wr & sd_ack : 1'b1),
	.q_b(bk_int_dout)
);

wire downloading = cart_download;
reg old_downloading = 0;

reg bk_ena = 0;
always @(posedge clk_sys) begin

	old_downloading <= downloading;
	if(~old_downloading & downloading) bk_ena <= 0;

	//Save file always mounted in the end of downloading state.
	if(downloading && img_mounted && !img_readonly) bk_ena <= 1;
end

wire bk_load    = status[16];
wire bk_save    = status[7] | (bk_pending & OSD_STATUS && status[23]);
reg  bk_loading = 0;
reg  bk_state   = 0;

always @(posedge clk_sys) begin
	reg old_format;
	reg old_load = 0, old_save = 0, old_ack;
	reg mb128sz;

	old_load <= bk_load;
	old_save <= bk_save;
	old_ack  <= sd_ack;

	if(~old_ack & sd_ack) {sd_rd, sd_wr} <= 0;

	if(!bk_state) begin
		if(bk_ena & ((~old_load & bk_load) | (~old_save & bk_save))) begin
			bk_state <= 1;
			bk_loading <= bk_load;
			mb128sz <= bk_load || (mb128_ena && mb128_dirty);
			sd_lba <= 0;
			sd_rd <=  bk_load;
			sd_wr <= ~bk_load;
		end
		if(old_downloading & ~downloading & bk_ena) begin
			bk_state <= 1;
			bk_loading <= 1;
			mb128sz <= 1;
			sd_lba <= 0;
			sd_rd <= 1;
			sd_wr <= 0;
		end
	end else begin
		if(old_ack & ~sd_ack) begin
			if(sd_lba[8] == mb128sz && &sd_lba[1:0]) begin
				bk_loading <= 0;
				bk_state <= 0;
				sd_lba <= 0;
			end else begin
				sd_lba <= sd_lba + 1'd1;
				sd_rd  <=  bk_loading;
				sd_wr  <= ~bk_loading;
			end
		end
	end

	old_format <= format;
	if(~old_format && format) begin
		defbram <= 0;
	end
	if(~defbram[3]) begin
		defbram <= defbram + 4'd1;
	end
end


/////////////////////////////////////////////////////////////////////////

//reg dbg_menu = 0;
//always @(posedge clk_sys) begin
//	reg old_stb;
//	reg enter = 0;
//	reg esc = 0;
//
//	old_stb <= ps2_key[10];
//	if(old_stb ^ ps2_key[10]) begin
//		if(ps2_key[7:0] == 'h5A) enter <= ps2_key[9];
//		if(ps2_key[7:0] == 'h76) esc   <= ps2_key[9];
//	end
//
//	if(enter & esc) begin
//		dbg_menu <= ~dbg_menu;
//		enter <= 0;
//		esc <= 0;
//	end
//end

`ifdef DEBUG_BUILD

reg VDC_BG_EN  = 1;
reg VDC_SPR_EN = 1;
reg [1:0] VDC_GRID_EN = 2'd0;
reg CPU_PAUSE_EN = 0;
reg PSG_EN  = 1;
reg CDDA_EN = 1;
reg ADPCM_EN = 1;

wire       pressed = ps2_key[9];
wire [8:0] code    = ps2_key[8:0];
always @(posedge clk_sys) begin
	reg old_state = 0;

	old_state <= ps2_key[10];

	if((ps2_key[10] != old_state) && pressed) begin
		casex(code)
			'h005: begin VDC_BG_EN <= ~VDC_BG_EN; end 			// F1
			'h006: begin VDC_SPR_EN <= ~VDC_SPR_EN; end 			// F2
			'h004: begin VDC_GRID_EN <= VDC_GRID_EN + 2'd1; end// F3
			'h00C: begin PSG_EN <= ~PSG_EN; end 					// F4
			'h003: begin CDDA_EN <= ~CDDA_EN; end 					// F5
			'h00B: begin ADPCM_EN <= ~ADPCM_EN; end 				// F6
			'h083: begin CPU_PAUSE_EN <= ~CPU_PAUSE_EN; end 	// F7
		endcase
	end
end

`else

wire VDC_BG_EN  = 1;
wire VDC_SPR_EN = 1;
wire [1:0] VDC_GRID_EN = 2'd0;
wire CPU_PAUSE_EN = 0;
wire PSG_EN  = 1;
wire CDDA_EN = 1;
wire ADPCM_EN = 1;

`endif

endmodule
