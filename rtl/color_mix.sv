//
//
// Copyright (c) 2018 Sorgelig
//
// This program is GPL v2+ Licensed.
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

module color_mix
(
	input            clk_vid,
	input            ce_pix,
	input      [2:0] mix,

	input      [7:0] R_in,
	input      [7:0] G_in,
	input      [7:0] B_in,
	input            HSync_in,
	input            VSync_in,
	input            HBlank_in,
	input            VBlank_in,

	output reg [7:0] R_out,
	output reg [7:0] G_out,
	output reg [7:0] B_out,
	output reg       HSync_out,
	output reg       VSync_out,
	output reg       HBlank_out,
	output reg       VBlank_out
);


reg [7:0] R,G,B;
reg HBl, VBl, HS, VS;
always @(posedge clk_vid) if(ce_pix) begin
	R   <= R_in;
	G   <= G_in;
	B   <= B_in;
	HS  <= HSync_in;
	VS  <= VSync_in;
	HBl <= HBlank_in;
	VBl <= VBlank_in;
end

wire [15:0] px = R * 16'd054 + G * 16'd183 + B * 16'd018;

always @(posedge clk_vid) if(ce_pix) begin
	{R_out, G_out, B_out} <= 0;

	case(mix)
		0,
		1: {R_out, G_out, B_out} <= {R,        G,        B         }; // color
		2: {       G_out       } <= {          px[15:8]            }; // green
		3: {R_out, G_out       } <= {px[15:8], px[15:8] - px[15:10]}; // amber
		4: {       G_out, B_out} <= {          px[15:8], px[15:8]  }; // cyan
		5: {R_out, G_out, B_out} <= {px[15:8], px[15:8], px[15:8]  }; // gray
	endcase

	HSync_out  <= HS;
	VSync_out  <= VS;
	HBlank_out <= HBl;
	VBlank_out <= VBl;
end

endmodule
