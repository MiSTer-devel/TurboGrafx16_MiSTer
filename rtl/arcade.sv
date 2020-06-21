//
// Arcade Card
// Copyright (c) 2020 Alexey Melnikov
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

module ARCADE_CARD
(
	input         CLK,
	input         RST_N,

	input         EN,
	input         WR_N,
	input         RD_N,
	input  [20:0] A,
	input   [7:0] DI,
	output  [7:0] DO,
	output        SEL_N,
	
	output        RAM_CS_N,
	output [20:0] RAM_A
);


typedef struct packed
{
	reg [23:0] base;
	reg [15:0] offset;
	reg [15:0] increment;
	reg  [6:0] control;
	reg [20:0] addr;
} port_t;

port_t port[4];
wire [1:0] p;

reg        ena;
reg [31:0] shift_latch;
reg  [7:0] shift_bits;
reg  [7:0] rotate_bits;

assign SEL_N = ~(EN && &A[20:13] && (A[12:8] == 'h1A));
assign RAM_A = port[p].addr;

always_comb begin
	DO = 8'hFF;
	RAM_CS_N = 1;

	if(A[20:15] == 16) begin // pages 0x40-0x43
		p = A[14:13];
		RAM_CS_N = ~EN | ~ena;
	end
	else begin
		p = A[5:4];

		if(!A[7]) begin

			case(A[3:0])
				0,1: RAM_CS_N = SEL_N;

				2: DO = port[p].base[7:0];
				3: DO = port[p].base[15:8];
				4: DO = port[p].base[23:16];
				5: DO = port[p].offset[7:0];
				6: DO = port[p].offset[15:8];
				7: DO = port[p].increment[7:0];
				8: DO = port[p].increment[15:8];
				9: DO = port[p].control;
				default:;
			endcase
		end
		else if(&A[6:5]) begin

			case (A[4:0])
				0: DO = shift_latch[7:0];
				1: DO = shift_latch[15:8];
				2: DO = shift_latch[23:16];
				3: DO = shift_latch[31:24];
				4: DO = shift_bits;
				5: DO = rotate_bits;

				'h1C: DO = 0;
				'h1D: DO = 0;

				'h1E: DO = 8'h10;
				'h1F: DO = 8'h51;
				default:;
			endcase
		end
	end
end

always @(posedge CLK) begin
	for(int i=0; i<4; i++) begin
		port[i].addr = port[i].base[20:0] + (port[i].control[1] ? {{5{port[i].control[3]}}, port[i].offset} : 21'd0);
	end
end

wire [3:0] rot = DI[3] ? (4'd8 - DI[2:0]) : DI[2:0];
wire acc = ~(WR_N & RD_N);

always @(posedge CLK) begin
	reg old_acc;

	old_acc <= acc;

	if(~RST_N) begin
		for(int i=0; i<4; i++) begin
			port[i].base <= 0;
			port[i].offset <= 0;
			port[i].increment <= 0;
			port[i].control <= 0;
		end
		ena <= 0;
		shift_latch <= 0;
		shift_bits <= 0;
		rotate_bits <= 0;
	end
	else if(~old_acc & acc) begin

		if(~SEL_N & ~WR_N) begin
			if(!A[7]) begin

				ena <= 1;
				case(A[3:0])
					2: port[p].base[7:0] <= DI;
					3: port[p].base[15:8] <= DI;
					4: port[p].base[23:16] <= DI;
					5: begin
							port[p].offset[7:0] <= DI;
							if(port[p].control[6:5] == 1) port[p].base <= port[p].base + {{8{port[p].control[3]}}, port[p].offset[15:8], DI};
						end
					6: begin
							port[p].offset[15:8] <= DI;
							if(port[p].control[6:5] == 2) port[p].base <= port[p].base + {{8{port[p].control[3]}}, DI, port[p].offset[7:0]};
						end
					7: port[p].increment[7:0] <= DI;
					8: port[p].increment[15:8] <= DI;
					9: port[p].control <= DI[6:0];
					10: if(port[p].control[6:5] == 3) port[p].base <= port[p].base + {{8{port[p].control[3]}}, port[p].offset};
				endcase
			end
			else if(&A[6:5]) begin

				case (A[4:0])
					0: shift_latch[7:0] <= DI;
					1: shift_latch[15:8] <= DI;
					2: shift_latch[23:16] <= DI;
					3: shift_latch[31:24] <= DI;
					4: begin
							shift_bits <= DI[3:0];
							shift_latch <= DI[3] ? (shift_latch >> (8 - DI[2:0])) : (shift_latch << DI[2:0]);
						end
					5: begin
							rotate_bits <= DI[3:0];
							if(DI[3]) shift_latch <= (shift_latch >> rot) | (shift_latch << (32 - rot));
							else shift_latch <= (shift_latch << rot) | ((shift_latch >> (32 - rot)) & ((32'd1 << rot) - 1'd1));
						end
				endcase
			end
		end

		if(~RAM_CS_N & port[p].control[0]) begin
			if(port[p].control[4]) port[p].base <= port[p].base + port[p].increment;
			else port[p].offset <= port[p].offset + port[p].increment;
		end
	end
end

endmodule
