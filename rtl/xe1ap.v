// XE-1AP / CyberStick support module
// (c) 2022, 2025 by David Shadoff
//
// Implements analog joysticks according to CyberStick/XE-1AP/XE-1AJ protocol
//
module XE1AP
  #(parameter CLKPERUSEC=50)	// we need fixed time intervals in microseconds;
										// clk_sys may vary from core to core; this is
										// the number of clk_sys cycles in a microsecond
  (input  clk_sys,
   input  reset,
   input  [31:0] joystick_0,				// 3 = up, 2 = down, 1 = left, 0 = right
													// 7 = run, 6 = select, 5 = button 2, 4 - button 1
													
   input  [15:0] joystick_l_analog_0,	// [15:8] is up/down, range +/- 127 (up is minus)
													// [7:0] is left/right, range +/- 127 (left is minus)
   input  [15:0] joystick_r_analog_0,
	
	input  orientation,		// orientation: 0 = CyberStick (stick right/throttle left)
									//              1 = XE-1AP     (stick left/throttle right)

   input  req,					// signal requesting response from XE-1AP (on return to high)
									// pin 8 on original 9-pin connector 

   output reg lo_hi,			// pin 6 on original 9-pin connector
   output reg ack,			// pin 7 on original 9-pin connector

   output reg [3:0] data,	// Data[3] = pin 4 on original 9-pin connector
									// Data[2] = pin 3 on original 9-pin connector
									// Data[1] = pin 2 on original 9-pin connector
									// Data[0] = pin 1 on original 9-pin connector

   output reg run_btn,		// need to send back for the XHE-3 PC Engine attachment
   output reg select_btn	// need to send back for the XHE-3 PC Engine attachment
);

// Note that output data is sent 4 bits at a time, with ack == LOW signalling "data ready"
//
// The sequence of data (and bit-order) is as follows (from original joystick):
//  (Note that not all buttons are currently mapped for PC-Engine implementation)
//
//  All values are low when pressed, high when not pressed
//
//  1: Buttons A,  B,  C,  D   (Note: A is pressed if either A or A' is pressed; same with B or B')
//  2: Buttons E1, E2, Start(F), Select (G)
//  3: Top 4 bits of 'channel 0' (Y-axis;   limit up   = 0x00, limit down  = 0xFF)
//  4: Top 4 bits of 'channel 1' (X-axis;   limit left = 0x00, limit right = 0xFF)
//  5: Top 4 bits of 'channel 2' (Throttle; limit up   = 0xFF, limit down  = 0x00)
//  6: 0000 (unused)
//  7: Bottom 4 bits of 'channel 0' (Y-axis)
//  8: Bottom 4 bits of 'channel 1' (X-axis)
//  9: Bottom 4 bits of 'channel 2' (Throttle)
// 10: 0000 (unused)
// 11: Buttons A,  B,  A',  B' (This can differentiate between the buttons, whereas scan #1 merges them)
// 12: 1111 (all high)
//

  // registers

  // timings are in sub-microsecond intervals
  // using half-microsecond steps to approximate as closely as realistic
  //
  reg [7:0]  clks_per_hlfusec = CLKPERUSEC[6:1] + CLKPERUSEC[0];	// don't truncate the lowest bit; round up instead
  
  wire [7:0]  throttle;
  wire [7:0]  stick_x;
  wire [7:0]  stick_y;
  

  reg [7:0]  clk_counter     = 0;
  reg [8:0]  hlfusec_ctr     = 0;
  reg [8:0]  hlfusec_ctr_ff  = 0;

  reg [8:0]  trig_wait;				// wait time after trigger goes low, until ack of response
  reg [8:0]  ack1_hi_trig;			// duration of initial ack, until transition to HIGH (with hi_lo = LOW)
  reg [8:0]  hilo_hi_trig;			// point at which hi_lo transitions to HIGH (ack = HIGH)
  reg [8:0]  ack2_lo_trig;			// point at which ack transitions to LOW (now with hi_lo = HIGH)
  reg [8:0]  ack2_hi_trig;			// point at which ack transitions to HIGH (with hi_lo = HIGH still)
  reg [8:0]  hilo_lo_trig;			// point at which hi_lo transitions to LOW (ack = HIGH)
  reg [8:0]  data_preload_trig;	// point at which data preload occurs before next cycle
  reg [8:0]  acknxt_lo_trig;		// end of cycle; start of next
 
  reg [47:0] shift_output    = 48'h0;

  reg        active          = 1'b0;
  reg        req_ff          = 1'b1;
  reg        req_fff         = 1'b1;
  
  reg [1:0]  proto_speed     = 2'b11;	// slowest speed
 
  reg [2:0]  cycle_count     = 3'b0;	// 0   = wait before pulse train
													// 1-6 = normal pulse cycles
													// 7   = cycle train completed

//  reg protocol               = 1'b1;	// XE-1AP output protocol = 0; CyberStick = 1
  
  //
  // Need to invert most-significant bit because
  //   MiSTer values are signed (-128 to 127), but
  //   CyberStick/XE-1AP are unsigned (0 to 255)
  //
  assign throttle = orientation ? {~joystick_r_analog_0[15], joystick_r_analog_0[14:8]} : {~joystick_l_analog_0[15], joystick_l_analog_0[14:8]};
  assign stick_x  = orientation ? {~joystick_l_analog_0[7],  joystick_l_analog_0[6:0] } : {~joystick_r_analog_0[7],  joystick_r_analog_0[6:0] };
  assign stick_y  = orientation ? {~joystick_l_analog_0[15], joystick_l_analog_0[14:8]} : {~joystick_r_analog_0[15], joystick_r_analog_0[14:8]};
  
  always @(posedge clk_sys)
  begin

    req_ff <= req;
    req_fff <= req_ff;
    
    if (reset == 1'b1) begin
      clks_per_hlfusec <= CLKPERUSEC[6:1] + CLKPERUSEC[0];
		proto_speed  <= 2'b11;		// start out slowest speed
      active       <= 1'b0;
      data[3:0]    <= 4'b1111;
      lo_hi        <= 1'b0;
      ack	       <= 1'b1;
      cycle_count  <= 3'b0;
      clk_counter  <= 0;
      hlfusec_ctr  <= 0;
    end

    if (active == 1'b0) begin
      lo_hi        <= 1'b0;
      ack          <= 1'b1;
      if ((req_fff == 1) && (req_ff == 0))
      begin
        case (proto_speed)
           2'b00: begin
             trig_wait         <= 142;		// 71 uS
				 ack1_hi_trig      <= 25;		// 12.5 uS (should be 12.1)
				 hilo_hi_trig      <= 25;		//
				 ack2_lo_trig      <= 32;		// + 3.5 uS (should be 3.88)
				 ack2_hi_trig      <= 57;		// + 12.5 uS (should be 12.1)
				 hilo_lo_trig      <= 64;		// + 3.5 uS (should be 3.88)
				 data_preload_trig <= 88;		// + 12 uS
				 acknxt_lo_trig    <= 100;		// + 6 uS
			  end
			  2'b01: begin
             trig_wait         <= 154;		// 77 uS
				 ack1_hi_trig      <= 53;		// 26.5 uS (should be 26.1)
				 hilo_hi_trig      <= 61;		// + 4 uS
				 ack2_lo_trig      <= 68;		// + 3.5 uS (should be 3.88)
				 ack2_hi_trig      <= 149;		// + 40.5 uS (should be 40.1)
				 hilo_lo_trig      <= 156;		// + 3.5 uS (should be 3.88)
				 data_preload_trig <= 180;		// + 12 uS
				 acknxt_lo_trig    <= 192;		// + 6 uS
			  end
           2'b10: begin
             trig_wait         <= 156;		// 78 uS
				 ack1_hi_trig      <= 100;		// 50 uS
				 hilo_hi_trig      <= 108;		// + 4 uS
				 ack2_lo_trig      <= 116;		// + 4 uS (should be 3.88)
				 ack2_hi_trig      <= 244;		// + 64 uS
				 hilo_lo_trig      <= 252;		// + 4 uS (should be 3.88)
				 data_preload_trig <= 276;		// + 12 uS
				 acknxt_lo_trig    <= 288;		// + 6 uS
			  end
			  2'b11: begin			// Slowest
             trig_wait         <= 172;		// 86 uS
				 ack1_hi_trig      <= 149;		// 74.5 uS (should be 74.12)
				 hilo_hi_trig      <= 157;		// + 4 uS
				 ack2_lo_trig      <= 164;		// + 3.5 uS (should be 3.88)
				 ack2_hi_trig      <= 340;		// + 88 uS
				 hilo_lo_trig      <= 348;		// + 4 uS (should be 3.88)
				 data_preload_trig <= 372;		// + 12 uS
				 acknxt_lo_trig    <= 384;		// + 6 uS
			  end
		  endcase

        active        <= 1'b1;
        cycle_count   <= 3'b0;
        clk_counter   <= 0;
        hlfusec_ctr   <= 0;

		  
        run_btn       <= ~joystick_0[6];
        select_btn    <= ~joystick_0[7];

        shift_output  <= { 4'b1111,		// Need to put first nybble as least-significant
								  ~joystick_0[4], ~joystick_0[5], ~joystick_0[11], ~joystick_0[10], 		// A, B, A', B'
								  4'b0000,
								  throttle[3:0],		// throttle[3:0]
								  stick_x[3:0],		// x[3:0]
								  stick_y[3:0],		// y[3:0]
								  4'b0000,
								  throttle[7:4],		// throttle[7:4]
								  stick_x[7:4],		// x[7:4]
								  stick_y[7:4],		// y[7:4]
								  2'b11, ~joystick_0[6], ~joystick_0[7],		// E1, E2, start, select
								  ~(joystick_0[4] | joystick_0[11]), ~(joystick_0[5] | joystick_0[10]), ~joystick_0[8], ~joystick_0[9] };	// A, B, C, D
      end
    end

    else if (active == 1) begin
      hlfusec_ctr_ff  <= hlfusec_ctr;
      clk_counter     <= clk_counter + 1'd1;
      if (clk_counter == (clks_per_hlfusec - 1))
      begin
        clk_counter     <= 0;
        hlfusec_ctr     <= hlfusec_ctr + 1'd1;
      end

		// Cycle 0 is actually waiting after trigger, until ACK response
		//
      if (cycle_count == 0) begin
        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == (trig_wait - 8))) begin		// 4uS before ACK transition
          data[3:0]          <= shift_output[3:0];
        end
        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == trig_wait)) begin
          data[3:0]          <= shift_output[3:0];
          shift_output[43:0] <= shift_output[47:4];
          ack                <= 1'b0;
          cycle_count        <= 1;
          hlfusec_ctr        <= 0;
        end
      end

		// Cycles 1-6 are providing data in two phases, where ACK=LOW for data presentation, and LO_HI is first low, and then HIGH
		//
      else if ((cycle_count >= 1) && (cycle_count <= 6)) begin	// normal 6 cycles of data output
        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == ack1_hi_trig)) begin
          ack   <= 1'b1;
        end

        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == hilo_hi_trig)) begin
          data[3:0]          <= shift_output[3:0];
          lo_hi <= 1'b1;
        end

        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == ack2_lo_trig)) begin
          data[3:0]          <= shift_output[3:0];
          shift_output[43:0] <= shift_output[47:4];
          ack                <= 1'b0;
        end

		  // check status of req signal 1 microsecond after second ACK=LO transition; this determines protocol speed
		  // if it is high on the first cycle, protocol is the fastest (next iteration)
		  // if it remains low on the third (or later) cycles, it is the slowest
		  //
        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == (ack2_lo_trig + 2))) begin
          if ((req == 1'b1) && (proto_speed >= cycle_count)) begin
			   proto_speed <= (cycle_count - 1);
			 end
		  end

        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == ack2_hi_trig)) begin
          ack   <= 1'b1;
        end

        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == hilo_lo_trig)) begin
          lo_hi <= 1'b0;
          if (cycle_count == 6)
          begin
            cycle_count <= 7;
          end
        end

        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == data_preload_trig)) begin
          data[3:0]          <= shift_output[3:0];
        end
		  
        if ((hlfusec_ctr > hlfusec_ctr_ff) && (hlfusec_ctr == acknxt_lo_trig)) begin
          data[3:0]          <= shift_output[3:0];
          shift_output[43:0] <= shift_output[47:4];
          ack                <= 1'b0;
          cycle_count        <= cycle_count + 1'd1;
          hlfusec_ctr        <= 0;
        end
      end

      else if (cycle_count == 7) 	 // Data train completed; ready to reset
      begin
        active <= 1'b0;
        lo_hi  <= 1'b0;
        ack    <= 1'b1;
        data[3:0] <= 4'b1111;
        cycle_count  <= 3'b0;
        clk_counter  <= 0;
        hlfusec_ctr  <= 0;
      end

    end
  end

endmodule
