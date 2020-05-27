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
	input	        reset_n,     // reset - active low

	input         i_Clk,       // Joypad Clr/Reset line, clocks the SPI-like MB128 protocol 
	input         i_Data,      // Joypad Sel line, provides data to the SPI-like MB128 protocol

	output        o_Active,
	output  [3:0] o_Data,
	output reg [17:0] d_MB128_Bytes,

	input	        bk_clk,
	input  [15:0] bk_address,
	input  [15:0] bk_din,
	output [15:0] bk_dout,
	input         bk_we,
	output        bk_written
);

// constants - STATEs
// STATE GROUP 1 - Request identification
parameter  STATE_IDLE         = 4'd0;
parameter  STATE_A8_A1        = 4'd1;
parameter  STATE_A8_A2        = 4'd2;

// STATE GROUP 2 - Synced; request infromation
parameter  STATE_REQ          = 4'd3;
parameter  STATE_ADDR         = 4'd4;
parameter  STATE_LENBITS      = 4'd5;
parameter  STATE_LENBYTES     = 4'd6;

// STATE GROUP 3 - Synced; in-transfer states
parameter  STATE_READ         = 4'd7;
parameter  STATE_READBITS     = 4'd8;
parameter  STATE_READ_TRAIL   = 4'd9;
parameter  STATE_WRITE        = 4'd10;
parameter  STATE_WRITEBITS    = 4'd11;
parameter  STATE_WRITE_TRAIL  = 4'd12;

// STATE FINAL - ERROR
parameter  STATE_ERROR        = 4'd15;
  
parameter  CMD_WRITE          = 1'b0;
parameter  CMD_READ           = 1'b1;


// registers
reg [3:0]  r_State            = STATE_IDLE;
reg [7:0]  r_Register         = 0;
reg        r_Req              = CMD_READ;

reg [5:0]  r_Bit_Count        = 0;
reg [16:0] r_MB128_Addr       = 0;
reg [17:0] r_MB128_Bytes      = 0;
reg [2:0]  r_MB128_Bits       = 0;
reg [3:0]  r_Data             = 0;

reg [7:0]  r_Read_Byte        = 0;
reg [7:0]  r_Write_Byte       = 0;
reg [7:0]  ram_data           = 0;
 
reg        mb_Clr_Clk_prev    = 0;
reg        trigger_read		   = 0;
reg        trigger_fetchwrite = 0;
reg        trigger_write		= 0;
reg        wren_a         	   = 0;

wire [7:0] q_a;

//
// master storage - should be backed by permanent storage like SDCard
//
dpram_difclk #(17,8,16,16) back128_l
(
	.clock0(clk_sys),

	// Port A for MB128 access
	//
   .address_a(r_MB128_Addr),
	.data_a(ram_data),					// data into memory
	.wren_a(wren_a),						// active high
	.q_a(q_a),								// data from memory


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

	if (~reset_n) begin
		r_State           <= STATE_IDLE;
		r_Bit_Count       <= 6'b000000;
		r_Data            <= 4'b0000;
		trigger_read      <= 1'b0;
		trigger_write     <= 1'b0;
		ram_data          <= 8'b00000000;
		wren_a            <= 1'b0;
	end

	// transfer byte from memory to internal register on interstitial cycle
	if (trigger_read) begin
		r_Read_Byte  <= q_a;
		trigger_read <= 0;
		r_MB128_Addr <= r_MB128_Addr + 1'b1;
	end

	// Needed for altering final bits (less than a full byte)
	if (trigger_fetchwrite) begin
		r_Write_Byte <= q_a;
		ram_data     <= q_a;
		trigger_fetchwrite <= 0;
	end

	// transfer byte from internal register to memory on interstitial cycle
	// 1) wait for data to settle, and asset wren
	if (trigger_write) begin
		trigger_write <= 0;
		wren_a        <= 1;
		bk_written    <= 1;
	end

	// transfer byte from internal register to memory on interstitial cycle
	// 2) de-asset wren
	if (wren_a) begin
		wren_a <= 0;
		r_MB128_Addr <= r_MB128_Addr + 1'b1;
	end

	mb_Clr_Clk_prev <= i_Clk;
	if (!mb_Clr_Clk_prev && i_Clk) begin		// drive the SPI-like protocol based on this signal's positive edge

		case (r_State)
		STATE_IDLE:
			begin
				if (r_Bit_Count <= 7) r_Bit_Count <= r_Bit_Count + 1'b1;
		  
				r_Register    <= {i_Data, r_Register[7:1]};
				r_Data        <= 0;

				if (({i_Data, r_Register[7:1]} == 8'hA8) && (r_Bit_Count >= 7))  r_State <= STATE_A8_A1;
			end

		STATE_A8_A1:
			begin
				r_State       <= STATE_A8_A2;
			end

		STATE_A8_A2:
			begin
				// Note that IDENT actually takes the value sent in data
				r_Data        <= { 1'b0, i_Data, 1'b0, 1'b0 };
				r_State       <= STATE_REQ;
			end

		STATE_REQ:
			begin
				r_Req         <= i_Data;
			 
				r_Data        <= 0;
				r_MB128_Addr  <= 0;
				r_MB128_Bits  <= 0;
				r_MB128_Bytes <= 0;
				r_Bit_Count   <= 0;

				r_State       <= STATE_ADDR;
			end

		STATE_ADDR:
			begin
				// 10 address bits come in
				// LSB signifies 128 bytes of offset
				r_MB128_Addr    <= { i_Data , r_MB128_Addr[16:1] };

				r_Bit_Count     <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 9) begin
					r_Bit_Count <= 0;
					r_State     <= STATE_LENBITS;
				end
			end

		STATE_LENBITS:
			begin
				// 3 bits come in identifying # of bits (smaller than full-byte read/writes)
				r_MB128_Bits    <= { i_Data, r_MB128_Bits[2:1] };

				r_Bit_Count     <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 2) begin
					if (r_Req == CMD_WRITE)
						r_Write_Byte <= 0;				// initialize write in case of WRITE command
					else
						trigger_read <= 1;				// get read byte in advance of use (if READ command)

					r_Bit_Count <= 0;
					r_State     <= STATE_LENBYTES;
				end
			end

		STATE_LENBYTES:
			begin
				// 17 bits come in identifying # of bytes in payload
				r_MB128_Bytes   <= { i_Data,r_MB128_Bytes[16:1] };
				d_MB128_Bytes   <= { i_Data,r_MB128_Bytes[16:1] };

				r_Bit_Count     <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 16) begin
					r_Data      <= { 3'b000 , r_Req };
				  
					r_Bit_Count <= 0;
				  
					if (!{ i_Data , r_MB128_Bytes[16:1] }) begin	// zero bytes, but will execute on at least 1 bit
						if (r_Req == CMD_WRITE) r_State <= r_MB128_Bits ? STATE_WRITEBITS : STATE_WRITEBITS;
						else r_State <= r_MB128_Bits ? STATE_READBITS : STATE_READ_TRAIL;
					end
					else begin
						if (r_Req == CMD_WRITE) r_State <= STATE_WRITE;
						else r_State <= STATE_READ;
					end
				end
			end

		STATE_READ:
			begin
				// assumption: we have already read the first byte, above
				r_Data            <= { 3'b000, r_Read_Byte[0] };
				r_Read_Byte       <= { 1'b0, r_Read_Byte[7:1] };

				r_Bit_Count       <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 7) begin
					r_Bit_Count   <= 0;
				  
					if (r_MB128_Bytes == 1) begin
						if (r_MB128_Bits) begin
							trigger_read <= 1;			// Get next byte from memory & inc addr
							r_State      <= STATE_READBITS;
						end
						else begin
							r_State      <= STATE_READ_TRAIL;
						end
					end
					else begin
						r_MB128_Bytes <= r_MB128_Bytes - 1'b1;
						trigger_read <= 1;				// Get next byte from memory & inc addr
					end
				end
			end

		STATE_READBITS:
			begin
				// assumption: we have already read the full byte, above
				r_Bit_Count      <= r_Bit_Count + 1'b1;
			 
				r_Data           <= { 3'b000, r_Read_Byte[0] };
				r_Read_Byte      <= { 1'b0, r_Read_Byte[7:1] };
			 
				if ((r_Bit_Count + 1) == r_MB128_Bits) begin
					r_Bit_Count  <= 0;
					r_State      <= STATE_READ_TRAIL;
				end
			end

		STATE_READ_TRAIL:
			begin
				r_Data      <= 0;
				r_Bit_Count <= r_Bit_Count + 1'b1;
				if (r_Bit_Count == 2) begin
					r_Bit_Count  <= 0;
					r_Register   <= 0;
					r_State      <= STATE_IDLE;
				end
			end

		STATE_WRITE:
			begin
				r_Data          <= 0;
				r_Bit_Count     <= r_Bit_Count + 1'b1;
			 
				r_Write_Byte[r_Bit_Count] <= i_Data;
			 
				if (r_Bit_Count == 7) begin
					r_Bit_Count   <= 0;

					trigger_write <= 1;					// write byte to memory & inc addr
					ram_data		  <= { i_Data , r_Write_Byte[6:0] };
				  
					r_Write_Byte  <= 0;
				  
					if (r_MB128_Bytes == 1) begin
						if (r_MB128_Bits) begin
							trigger_fetchwrite <= 1;	// fetch last byte for partial update
							r_State     <= STATE_WRITEBITS;
						end
						else begin
							r_State     <= STATE_WRITE_TRAIL;
						end
					end
					else begin
						r_MB128_Bytes <= r_MB128_Bytes - 1'b1;
					end
				end
			end

		STATE_WRITEBITS:
			begin
				r_Data      <= 0;
				r_Bit_Count <= r_Bit_Count + 1'b1;

				r_Write_Byte[r_Bit_Count] <= i_Data;
				ram_data[r_Bit_Count]     <= i_Data;
			 
				if ((r_Bit_Count + 1) == r_MB128_Bits) begin

					// Note to read byte, mix bits, and rewrite byte at end of receiving data
				  
					trigger_write <= 1;				// write byte to memory (& inc addr)
					r_Bit_Count   <= 0;
					r_State       <= STATE_WRITE_TRAIL;
				end
			end


		STATE_WRITE_TRAIL:
			begin
				r_Data      <= 0;
				r_Bit_Count <= r_Bit_Count + 1'b1;
			 
				if (r_Bit_Count == 4) begin
					r_Bit_Count  <= 0;
					r_Register   <= 0;
					r_State      <= STATE_IDLE;
				end
			end
		endcase
	end
end

assign o_Active  = r_State != STATE_IDLE;
assign o_Data    = r_Data;

endmodule
