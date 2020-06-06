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
assign DDRAM_BE       = ram_read ? 8'hFF : ({6'd0,~b,1'b1} << {ram_addr[2:1],ram_addr[0] & b});
assign DDRAM_ADDR     = {4'b0011, ram_addr[27:4], ram_addr[3] & ram_write}; // RAM at 0x30000000
assign DDRAM_RD       = ram_read;
assign DDRAM_DIN      = ram_data;
assign DDRAM_WE       = ram_write;

assign dout = data;

reg  [7:0] ram_burst;
reg [63:0] ram_data;
reg [27:0] ram_addr;
reg  [7:0] data;
reg        ram_read = 0;
reg        ram_write = 0;
reg        b;

always @(posedge DDRAM_CLK) begin
	reg  [1:0] state = 0;
	reg        old_ref;
	reg        start;
	reg [27:0] raddr;
	reg [27:4] cache_addr;
	reg[127:0] ram_q;

	old_ref <= clkref;
	start <= ~old_ref & clkref;

	if(start) begin
		if(we) we_rdy <= 0;
		else if(rd) rd_rdy <= 0;
	end

	raddr <= rdaddr;

	if(!DDRAM_BUSY) begin
		ram_write <= 0;
		ram_read  <= 0;
		case(state)
			0: begin
					we_rdy <= 1;
					rd_rdy <= 1;
					if(we_ack != we_req) begin
						ram_data   <= {4{din}};
						ram_addr   <= wraddr;
						ram_write  <= 1;
						ram_burst  <= 1;
						state      <= 1;
						b          <= 0;
						cache_addr <= '1;
					end
					else if(start) begin
						if(we) begin
							we_rdy    <= 0;
							ram_data  <= {8{din[7:0]}};
							ram_addr  <= wraddr;
							ram_write <= 1;
							ram_burst <= 1;
							state     <= 1;
							b         <= 1;
							if(cache_addr == wraddr[27:4]) ram_q[{wraddr[3:0], 3'b000} +:8] <= din[7:0];
						end
						else if(rd) begin
							if(cache_addr != raddr[27:4]) begin
								rd_rdy     <= 0;
								ram_addr   <= raddr;
								cache_addr <= raddr[27:4];
								ram_read   <= 1;
								ram_burst  <= 2;
								state      <= 2;
							end
							else begin
								data <= ram_q[{raddr[3:0], 3'b000} +:8];
							end
						end
					end
				end

			1: begin
					we_ack <= we_req;
					we_rdy <= 1;
					state  <= 0;
				end

			2: if(DDRAM_DOUT_READY) begin
					ram_q[63:0] <= DDRAM_DOUT;
					state  <= 3;
				end

			3: if(DDRAM_DOUT_READY) begin
					ram_q[127:64] <= DDRAM_DOUT;
					data   <= ram_addr[3] ? DDRAM_DOUT[{ram_addr[2:0], 3'b000} +:8] : ram_q[{1'b0, raddr[2:0], 3'b000} +:8];
					rd_rdy <= 1;
					state  <= 0;
				end
		endcase
	end
end

endmodule
