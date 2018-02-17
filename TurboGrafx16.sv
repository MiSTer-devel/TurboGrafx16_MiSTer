//============================================================================
//  TurboGrafx16 / PC Engine
//
//  Port to MiSTer
//  Copyright (C) 2017 Sorgelig
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
	inout  [43:0] HPS_BUS,

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

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S, // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)
	input         TAPE_IN,

	// SD-SPI
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
	output        SDRAM_nWE
);

assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;

assign LED_USER  = ioctl_download;
assign LED_DISK  = 0;
assign LED_POWER = 0;

assign VIDEO_ARX = status[1] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[1] ? 8'd9  : 8'd3; 

wire [1:0] scale = status[8:7];

`include "build_id.v" 
localparam CONF_STR = {
	"TGFX16;;",
	"-;",
	"F,PCEBIN;",
	"O3,ROM Data Swap,No,Yes;",
	"-;",
	"O1,Aspect ratio,4:3,16:9;",
	"O78,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%;",
	"-;",
	"O2,Turbo Tap,Disable,Enable;",
	"-;",
	"T6,Reset;",
	"J1,Button I,Button II,Select,Run;",
	"V,v1.10.",`BUILD_DATE
};

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

wire [15:0] joystick_0, joystick_1;
wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_dout;
reg         ioctl_wait;
wire        forced_scandoubler;

hps_io #(.STRLEN($size(CONF_STR)>>3), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.buttons(buttons),
	.status(status),
	.forced_scandoubler(forced_scandoubler),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_wait(ioctl_wait),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1)
);

wire [23:0] audio_l, audio_r;
assign AUDIO_L = audio_l[23:8];
assign AUDIO_R = audio_r[23:8];
assign AUDIO_S = 1;
assign AUDIO_MIX = 0;

wire reset = (RESET | status[0] | status[6] | buttons[1]);

pce_top pce_top
(
	.ROM_RESET_N(~(reset|ioctl_download)),

	.CLK(clk_sys),

	.romrd_req(rom_rd),
	.romrd_ack(rom_rdack),
	.romrd_a(rom_rdaddr),
	.romrd_q(rom_data),
	.rom_sz(romwr_a[23:16]),

	.AUD_LDATA(audio_l),
	.AUD_RDATA(audio_r),

	.TURBOTAP(status[2]),
	.JOY1(~joystick_0[7:0]),
	.JOY2(~joystick_1[7:0]),

	.VIDEO_R(r),
	.VIDEO_G(g),
	.VIDEO_B(b),
	.VIDEO_CE(ce_vid),
	.VIDEO_VS_N(vs),
	.VIDEO_HS_N(hs),
	.VIDEO_HBL(hblank),
	.VIDEO_VBL(vblank)
);

wire [2:0] r,g,b;
wire vs,hs;
wire hblank, vblank;

wire ce_vid;
assign CLK_VIDEO = clk_ram;

reg ce_pix;
always @(posedge clk_ram) begin
	reg old_ce;
	
	old_ce <= ce_vid;
	ce_pix <= ~old_ce & ce_vid;
end

video_mixer #(.LINE_LENGTH(560), .HALF_DEPTH(1)) video_mixer
(
	.*,

	.clk_sys(clk_ram),
	.ce_pix(ce_pix),
	.ce_pix_out(CE_PIXEL),

	.scanlines({scale == 3, scale == 2}),
	.scandoubler(scale || forced_scandoubler),
	.hq2x(scale==1),

	.mono(0),

	.R({r,r[2]}),
	.G({g,g[2]}),
	.B({b,b[2]}),

	// Positive pulses.
	.HSync(~hs),
	.VSync(~vs),
	.HBlank(hblank),
	.VBlank(vblank)
);

wire [19:0] rom_rdaddr;
wire [63:0] rom_data;
wire rom_rd, rom_rdack;

assign DDRAM_CLK = clk_ram;

ddram ddram
(
	.*,
	.reset(reset & ~ioctl_download),

   .wraddr(romwr_a),
   .din(romwr_d),
   .we_req(rom_wr),
   .we_ack(rom_wrack),

   .rdaddr({rom_rdaddr, 3'b000} + (romwr_a[9] ? 28'h200 : 28'h0)),
   .dout(rom_data),
   .rd_req(rom_rd),
   .rd_ack(rom_rdack)
);

wire        romwr_ack;
reg  [23:0] romwr_a;
wire [15:0] romwr_d = status[3] ? 
		{ ioctl_dout[8], ioctl_dout[9], ioctl_dout[10],ioctl_dout[11],ioctl_dout[12],ioctl_dout[13],ioctl_dout[14],ioctl_dout[15],
		  ioctl_dout[0], ioctl_dout[1], ioctl_dout[2], ioctl_dout[3], ioctl_dout[4], ioctl_dout[5], ioctl_dout[6], ioctl_dout[7] }
		: ioctl_dout;

reg  rom_wr;
wire rom_wrack;

always @(posedge clk_sys) begin
	reg old_download, old_reset;

	old_download <= ioctl_download;
	old_reset <= reset;

	if(~old_reset && reset) ioctl_wait <= 0;
	if(~old_download && ioctl_download) begin
		rom_wr <= 0;
		romwr_a <= 0;
	end
	else begin
		if(ioctl_wr) begin
			ioctl_wait <= 1;
			rom_wr <= ~rom_wr;
		end else if(ioctl_wait && (rom_wr == rom_wrack)) begin
			ioctl_wait <= 0;
			romwr_a <= romwr_a + 2'd2;
		end
	end
end

endmodule
