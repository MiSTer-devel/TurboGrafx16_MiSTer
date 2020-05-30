// MB128.v
//
// This executes a compatible protocol to the Memory Base 128
// or Save-kun peripheral as used by the PC Engine
//
// (c) 2020 by David Shadoff
//
//

module MB128 
(
	input	        clk_sys,     // system clock
	input	        reset,

	input         i_Clk,       // Joypad Clr/Reset line, clocks the SPI-like MB128 protocol 
	input         i_Data,      // Joypad Sel line, provides data to the SPI-like MB128 protocol

	output        o_Active,
	output  [3:0] o_Data,

	input	        bk_clk,
	input  [15:0] bk_address,
	input  [15:0] bk_din,
	output [15:0] bk_dout,
	input         bk_we,
	output        bk_written
);

// constants - STATEs
// STATE GROUP 1 - Request identification
localparam STATE_IDLE        = 0;
localparam STATE_A8_A1       = 1;
localparam STATE_A8_A2       = 2;

// STATE GROUP 2 - Synced; request infromation
localparam STATE_REQ         = 3;
localparam STATE_ADDR        = 4;
localparam STATE_LEN         = 5;

// STATE GROUP 3 - Synced; in-transfer states
localparam STATE_READ        = 6;
localparam STATE_READ_TRAIL  = 7;
localparam STATE_WRITE       = 8;
localparam STATE_WRITE_TRAIL = 9;

localparam CMD_WRITE         = 0;
localparam CMD_READ          = 1;


// registers
reg [3:0]  r_State    = STATE_IDLE;
reg [7:0]  r_Register = 0;

reg        r_Req;
reg [19:0] r_Bit_Count;
reg [19:0] r_MB128_Addr;
reg [19:0] r_MB128_Bits;
reg  [3:0] r_Data;

reg        clk_prev;

reg        ram_din;
reg        ram_we;
wire       ram_dout;

//
// master storage - should be backed by permanent storage like SDCard
//
dpram_difclk #(20,1,16,16) back128_l
(
	// Port A for MB128 access
	//
	.clock0(clk_sys),
   .address_a(r_MB128_Addr),
	.data_a(ram_din),
	.wren_a(ram_we),
	.q_a(ram_dout),

	// Port B save/load
	//
	.clock1(bk_clk),
	.address_b(bk_address),
	.data_b(bk_din),
	.wren_b(bk_we),
	.q_b(bk_dout)
);
  

always @(posedge clk_sys) begin

	if(bk_address[15:10] == 2) bk_written <= 0;

	ram_we <= 0;
	if (ram_we) r_MB128_Addr <= r_MB128_Addr + 1'b1;

	clk_prev <= i_Clk;

	if (reset) begin
		r_State <= STATE_IDLE;
		r_Bit_Count <= 0;
	end
	else if (~clk_prev & i_Clk) begin		// drive the SPI-like protocol based on this signal's positive edge

		r_Data <= 0;

		case (r_State)
		STATE_IDLE:
			begin
				if (r_Bit_Count <= 7) r_Bit_Count <= r_Bit_Count + 1'b1;
				r_Register <= {i_Data, r_Register[7:1]};
				if (({i_Data, r_Register[7:1]} == 8'hA8) && (r_Bit_Count >= 7))  r_State <= STATE_A8_A1;
			end

		STATE_A8_A1:
			begin
				r_State       <= STATE_A8_A2;
			end

		STATE_A8_A2:
			begin
				// Note that IDENT actually takes the value sent in data
				r_Data[2]     <= i_Data;
				r_State       <= STATE_REQ;
			end

		STATE_REQ:
			begin
				r_Req         <= i_Data;
			 
				r_MB128_Addr  <= 0;
				r_MB128_Bits  <= 0;
				r_Bit_Count   <= 0;

				r_State       <= STATE_ADDR;
			end

		STATE_ADDR:
			begin
				// 10 address bits come in LSB signifies 128 bytes of offset
				r_MB128_Addr    <= {i_Data, r_MB128_Addr[19:1]};

				r_Bit_Count     <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 9) begin
					r_Bit_Count  <= 0;
					r_State      <= STATE_LEN;
				end
			end

		STATE_LEN:
			begin
				// 20 bits come in identifying # of bits
				r_MB128_Bits <= {i_Data, r_MB128_Bits[19:1]};

				r_Bit_Count  <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 19) begin

					r_Data[0] <= r_Req;
					r_State   <= (r_Req == CMD_WRITE) ? STATE_WRITE : STATE_READ;
					r_Bit_Count <= 1;

					if (!{i_Data, r_MB128_Bits[19:1]}) begin
						r_Bit_Count <= 0;
						r_State <= (r_Req == CMD_WRITE) ? STATE_WRITE_TRAIL : STATE_READ_TRAIL;
					end
				end
			end

		STATE_READ:
			begin
				r_Bit_Count    <= r_Bit_Count + 1'b1;
				r_Data[0]      <= ram_dout;
				r_MB128_Addr   <= r_MB128_Addr + 1'b1;

				if (r_Bit_Count == r_MB128_Bits) begin
					r_Bit_Count  <= 0;
					r_State      <= STATE_READ_TRAIL;
				end
			end

		STATE_READ_TRAIL:
			begin
				r_Bit_Count <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 2) begin
					r_Bit_Count  <= 0;
					r_State      <= STATE_IDLE;
				end
			end

		STATE_WRITE:
			begin
				r_Bit_Count <= r_Bit_Count + 1'b1;
				ram_din     <= i_Data;
				ram_we      <= 1;
				bk_written  <= 1;

				if (r_Bit_Count == r_MB128_Bits) begin
					r_Bit_Count <= 0;
					r_State     <= STATE_WRITE_TRAIL;
				end
			end

		STATE_WRITE_TRAIL:
			begin
				r_Bit_Count <= r_Bit_Count + 1'b1;

				if (r_Bit_Count == 4) begin
					r_Bit_Count  <= 0;
					r_State      <= STATE_IDLE;
				end
			end
		endcase
	end
end

assign o_Active = r_State != STATE_IDLE;
assign o_Data = r_Data;

endmodule
