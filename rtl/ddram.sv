//
// ddram.v
// Copyright (c) 2020 Sorgelig
//
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. 
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License 
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// ------------------------------------------
//


module ddram
(
	input         DDRAM_CLK,

	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	input         clkref,

	input  [27:0] wraddr,
	input  [15:0] din,
	input         we,
	output reg    we_rdy,
	input         we_req,
	output reg    we_ack,

	input  [27:0] rdaddr,
	output  [7:0] dout,
	input         rd,
	output reg    rd_rdy
);

assign DDRAM_BURSTCNT = ram_burst;
assign DDRAM_BE       = DDRAM_RD ? 8'hFF : ({6'd0,~b,1'b1} << {ram_addr[2:1],ram_addr[0] & b});
assign DDRAM_ADDR     = {4'b0011, ram_addr[27:3]}; // RAM at 0x30000000
assign DDRAM_DIN      = ram_data;
assign DDRAM_WE       = ram_write;

assign dout = data;

reg  [7:0] ram_burst;
reg [63:0] ram_data;
reg [27:0] ram_addr;
reg  [7:0] data;
reg        ram_write = 0;
reg        b;
reg        start;
reg  [1:0] state = 0;

reg [27:0] addr;

always @(posedge DDRAM_CLK) begin
	reg        old_ref;
	reg[127:0] ram_q;

	old_ref <= clkref;
	start <= ~old_ref & clkref;

	if(start) begin
		if(we) we_rdy <= 0;
		else if(rd) rd_rdy <= 0;
	end

	ram_burst <= 1;
	addr <= rdaddr;

	if(!DDRAM_BUSY) begin
		ram_write <= 0;
		case(state)
			0: begin
					we_rdy <= 1;
					rd_rdy <= 1;
					cache_cs <= 0;
					if(we_ack != we_req) begin
						we_ack     <= we_req;
						ram_data   <= {4{din}};
						ram_addr   <= wraddr;
						ram_write  <= 1;
						b          <= 0;
					end
					else if(start) begin
						if(we) begin
							we_rdy    <= 0;
							ram_data  <= {8{din[7:0]}};
							ram_addr  <= addr;
							ram_write <= 1;
							b         <= 1;
							cache_cs  <= 1;
							cache_we  <= 1;
							state     <= 1;
						end
						else if(rd) begin
							ram_addr  <= addr;
							rd_rdy    <= 0;
							cache_cs  <= 1;
							cache_we  <= 0;
							state     <= 2;
						end
					end
				end

			1: if(cache_wrack) begin
					cache_cs <= 0;
					we_rdy <= 1;
					state  <= 0;
				end

			2: if(cache_rdack) begin
					cache_cs <= 0;
					data <= ram_addr[0] ? cache_do[15:8] : cache_do[7:0];
					rd_rdy <= 1;
					state  <= 0;
				end
		endcase
	end
end

wire [15:0] cache_do;
wire        cache_rdack;
wire        cache_wrack;
reg         cache_cs;
reg         cache_we;

cache_2way cache
(
	.clk(DDRAM_CLK),
	.rst(we_ack != we_req),

	.cache_enable(1),

	.cpu_cs(cache_cs),
	.cpu_adr(addr[27:1]),
	.cpu_bs({addr[0],~addr[0]}),
	.cpu_we(cache_we),
	.cpu_rd(~cache_we),
	.cpu_dat_w(ram_data[15:0]),
	.cpu_dat_r(cache_do),
	.cpu_ack(cache_rdack),
	.wb_en(cache_wrack),

	.mem_dat_r(DDRAM_DOUT),
	.mem_read_req(DDRAM_RD),
	.mem_read_ack(DDRAM_DOUT_READY)
);

endmodule
