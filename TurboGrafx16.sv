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

	input         OSD_STATUS
);

`define USE_SP64

`ifdef USE_SP64
localparam MAX_SPPL = 63;
localparam SP64     = 1'b1;
`else
localparam MAX_SPPL = 15;
localparam SP64     = 1'b0;
`endif

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign VGA_F1 = 0;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;

assign LED_USER  = cart_download | bk_state | (status[23] & bk_pending);
assign LED_DISK  = 0;
assign LED_POWER = 0;
assign BUTTONS   = 0;

assign VIDEO_ARX = status[1] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[1] ? 8'd9  : 8'd3; 

`include "build_id.v" 
parameter CONF_STR = {
	"TGFX16;;",
	"FS,PCEBIN,Load TurboGrafx;",
	"FS,SGX,Load SuperGrafx;",
	"-;",
	"C,Cheats;",
	"H1OO,Cheats enabled,ON,OFF;",
	"-;",
	"D0RG,Load Backup RAM;",
	"D0R7,Save Backup RAM;",
	"D0ON,Autosave,OFF,ON;",
	"D0RC,Format Save;",
	"-;",
	"O1,Aspect ratio,4:3,16:9;",
	"O8A,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"OH,Vertical blank,Normal,Reduced;",
`ifdef USE_SP64
	"OB,Sprites per line,Std(16),All(64);",
`endif
	"-;",
	"O3,ROM Data Swap,No,Yes;",
	"O6,ROM Storage,DDR3,SDRAM;",
	"O2,Turbo Tap,Disabled,Enabled;",
	"O4,Controller Buttons,2,6;",
	"R0,Reset;",
	"J1,Button I,Button II,Select,Run,Button III,Button IV,Button V,Button VI;",
	"V,v",`BUILD_DATE
};

wire code_index = &ioctl_index;
wire code_download = ioctl_download & code_index;
wire cart_download = ioctl_download & ~code_index;

////////////////////   CLOCKS   ///////////////////

wire clk_sys, clk_ram;
wire pll_locked;
		
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_ram),
	.outclk_1(SDRAM_CLK),
	.outclk_2(clk_sys),
	.locked(pll_locked)
);

///////////////////////////////////////////////////

wire [31:0] status;
wire  [1:0] buttons;

wire [11:0] joystick_0, joystick_1, joystick_2, joystick_3, joystick_4;
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

hps_io #(.STRLEN($size(CONF_STR)>>3), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.buttons(buttons),
	.status(status),
	.status_menumask({~gg_avail,~bk_ena}),
	.forced_scandoubler(forced_scandoubler),

	.new_vmode(0),
	
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
	.joystick_4(joystick_4)
);

wire [23:0] audio_l, audio_r;
assign AUDIO_L = audio_l[23:8];
assign AUDIO_R = audio_r[23:8];
assign AUDIO_S = 1;
assign AUDIO_MIX = 0;

wire reset = (RESET | status[0] | buttons[1] | bk_loading);
wire ce_rom;

reg use_sdr = 0;
always @(posedge clk_ram) if(rom_rd) use_sdr <= status[6];

pce_top #(MAX_SPPL) pce_top
(
	.RESET(reset|cart_download),

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
	
	.AUD_LDATA(audio_l),
	.AUD_RDATA(audio_r),

	.GG_EN(status[24]),
	.GG_CODE(gg_code),
	.GG_RESET(ioctl_download && ioctl_wr && !ioctl_addr),
	.GG_AVAIL(gg_avail),


	.SP64(status[11] & SP64),
	.SGX(sgx),
	.TURBOTAP(status[2]),
	.SIXBUTTON(status[4]),
	.JOY1(~{joystick_0[11:4], joystick_0[1], joystick_0[2], joystick_0[0], joystick_0[3]}),
	.JOY2(~{joystick_1[11:4], joystick_1[1], joystick_1[2], joystick_1[0], joystick_1[3]}),
	.JOY3(~{joystick_2[11:4], joystick_2[1], joystick_2[2], joystick_2[0], joystick_2[3]}),
	.JOY4(~{joystick_3[11:4], joystick_3[1], joystick_3[2], joystick_3[0], joystick_3[3]}),
	.JOY5(~{joystick_4[11:4], joystick_4[1], joystick_4[2], joystick_4[0], joystick_4[3]}),

	.ReducedVBL(status[17]),
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

wire [2:0] r,g,b;
wire hs,vs;
wire hbl,vbl;
wire bw;

wire ce_vid;
assign CLK_VIDEO = clk_ram;

reg ce_pix;
always @(posedge clk_ram) begin
	reg old_ce;
	
	old_ce <= ce_vid;
	ce_pix <= ~old_ce & ce_vid;
end

color_mix color_mix
(
	.clk_vid(clk_ram),
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
	.HSync_out(HSync),
	.VSync_out(VSync),
	.HBlank_out(HBlank),
	.VBlank_out(VBlank)
);

wire [7:0] R,G,B;
wire HSync,VSync;
wire HBlank,VBlank;

wire [2:0] scale = status[10:8];
wire [2:0] sl = scale ? scale - 1'd1 : 3'd0;

assign VGA_SL = sl[1:0];

video_mixer #(.LINE_LENGTH(560)) video_mixer
(
	.*,

	.clk_sys(clk_ram),
	.ce_pix(ce_pix),
	.ce_pix_out(CE_PIXEL),

	.scanlines(0),
	.scandoubler(scale || forced_scandoubler),
	.hq2x(scale==1),
	.mono(0)
);

wire [21:0] rom_rdaddr;
wire [7:0] rom_ddata, rom_sdata;
wire rom_rd, rom_sdrdy, rom_ddrdy;

assign DDRAM_CLK = clk_ram;
ddram ddram
(
	.*,

   .wraddr(romwr_a),
   .din(romwr_d),
   .we_req(rom_wr),
   .we_ack(dd_wrack),

   .rdaddr(rom_rdaddr + (romwr_a[9] ? 28'h200 : 28'h0)),
   .dout(rom_ddata),
   .rd_req(~use_sdr & rom_rd),
   .rd_rdy(rom_ddrdy)
);

sdram sdram
(
	.*,

	.init(~pll_locked),
	.clk(clk_ram),
	.clkref(ce_rom),

	.waddr(romwr_a),
	.din(romwr_d),
	.we(rom_wr),
	.we_ack(sd_wrack),

	.raddr(rom_rdaddr + (romwr_a[9] ? 28'h200 : 28'h0)),
	.rd(use_sdr & rom_rd),
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
		sgx <= (ioctl_index[4:0] == 2);
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


/////////////////////////  STATE SAVE/LOAD  /////////////////////////////

wire bk_save_write = bram_wr;
reg bk_pending;

always @(posedge clk_sys) begin
	if (bk_ena && ~OSD_STATUS && bk_save_write)
		bk_pending <= 1'b1;
	else if (bk_state)
		bk_pending <= 1'b0;
end

wire [10:0] bram_addr;
wire [7:0] bram_data;
wire [7:0] bram_q = bram_addr[0] ? bram_qh : bram_ql;
wire [7:0] bram_ql,bram_qh;
wire bram_wr;

wire format = status[12];
reg [3:0] defbram = 4'hF;
integer defval[4] = '{ 16'h5548, 16'h4D42, 16'h8800, 16'h8010 }; //{ HUBM,0x00881080 };

dpram #(12) backram_l
(
	.clock(clk_sys),

   .address_a({2'b00,bram_addr[10:1]}),
	.data_a(bram_data),
	.wren_a(bram_wr & ~bram_addr[0]),
	.q_a(bram_ql),

   .address_b(defbram[3] ? {sd_lba[3:0],sd_buff_addr} : {12'h00,defbram[2:1]}),
	.data_b(defbram[3] ? sd_buff_dout[7:0] : defval[defbram[2:1]][7:0]),
	.wren_b(defbram[3] ? sd_buff_wr & sd_ack : defbram[0] & ~defbram[3]),
	.q_b(sd_buff_din[7:0])
);

dpram #(12) backram_h
(
	.clock(clk_sys),

   .address_a({2'b00,bram_addr[10:1]}),
	.data_a(bram_data),
	.wren_a(bram_wr & bram_addr[0]),
	.q_a(bram_qh),

   .address_b(defbram[3] ? {sd_lba[3:0],sd_buff_addr} : {12'h00,defbram[2:1]}),
	.data_b(defbram[3] ? sd_buff_dout[15:8] : defval[defbram[2:1]][15:8]),
	.wren_b(defbram[3] ? sd_buff_wr & sd_ack : defbram[0] & ~defbram[3]),
	.q_b(sd_buff_din[15:8])
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

	old_load <= bk_load;
	old_save <= bk_save;
	old_ack  <= sd_ack;
	
	if(~old_ack & sd_ack) {sd_rd, sd_wr} <= 0;
	
	if(!bk_state) begin
		if(bk_ena & ((~old_load & bk_load) | (~old_save & bk_save))) begin
			bk_state <= 1;
			bk_loading <= bk_load;
			sd_lba <= 0;
			sd_rd <=  bk_load;
			sd_wr <= ~bk_load;
		end
		if(old_downloading & ~downloading & |img_size & bk_ena) begin
			bk_state <= 1;
			bk_loading <= 1;
			sd_lba <= 0;
			sd_rd <= 1;
			sd_wr <= 0;
		end
	end else begin
		if(old_ack & ~sd_ack) begin
			if(&sd_lba[3:0]) begin
				bk_loading <= 0;
				bk_state <= 0;
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

endmodule
