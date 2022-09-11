// Code your design here
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

   input  req,					// signal requesting response from XE-1AP (on return to high)
									// pin 8 on original 9-pin connector 

   output reg trg1,			// pin 6 on original 9-pin connector
   output reg trg2,			// pin 7 on original 9-pin connector

   output reg [3:0] data,	// Data[3] = pin 4 on original 9-pin connector
									// Data[2] = pin 3 on original 9-pin connector
									// Data[1] = pin 2 on original 9-pin connector
									// Data[0] = pin 1 on original 9-pin connector

   output reg run_btn,		// need to send back for the XHE-3 PC Engine attachment
   output reg select_btn	// need to send back for the XHE-3 PC Engine attachment
);

// Note that output data is sent 4 bits at a time, with trg2 == LOW signalling "data ready"
//
// The sequence of data (and bit-order) is as follows (from original joystick):
//  (Note that not all buttons are currently mapped for PC-Engine implementation)
//
//  All values are low when pressed, high when not pressed
//
//  1: Buttons A,  B,  C,        D - (Note: A is pressed if either A or A' is pressed; same with B or B')
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
 
  reg [6:0]  clks_per_usec   = CLKPERUSEC;

  reg [6:0]  clk_counter     = 0;
  reg [6:0]  usec_counter    = 0;
  reg [6:0]  usec_counter_ff = 0;
  reg [47:0] shift_output    = 48'h0;

  reg        active          = 1'b0;
  reg        req_ff          = 1'b1;
  reg        req_fff         = 1'b1;
  
  reg [2:0]  cycle_count     = 3'b0;	// 0   = wait before pulse train
													// 1-6 = normal pulse cycles
													// 7   = cycle train completed

  always @(posedge clk_sys)
  begin

    req_ff <= req;
    req_fff <= req_ff;
    
    if (reset == 1'b1) begin
      active       <= 1'b0;
      trg1         <= 1'b0;
      trg2         <= 1'b1;
      cycle_count  <= 3'b0;
      clk_counter  <= 0;
      usec_counter <= 0;
    end

    if (active == 1'b0) begin
      trg1         <= 1'b0;
      trg2         <= 1'b1;
      if ((req_fff == 0) && (req_ff == 1))
      begin
        active        <= 1'b1;
        cycle_count   <= 3'b0;
        clk_counter   <= 0;
        usec_counter  <= 0;
        run_btn            <= ~joystick_0[7];
        select_btn         <= ~joystick_0[6];

        shift_output  <= { 4'b1111,		// Need to put first nybble as least-significant
                             ~joystick_0[4], ~joystick_0[5], 2'b11, 						// A, B, A', B'
                             4'b0000,
                             ~joystick_r_analog_0[11:8],										// throttle[3:0]
                             joystick_l_analog_0[3:0],										// x[3:0]
                             joystick_l_analog_0[11:8],										// y[3:0]
                             4'b0000,
                             joystick_r_analog_0[15], ~joystick_r_analog_0[14:12],	// throttle[7:4]
                             ~joystick_l_analog_0[7],  joystick_l_analog_0[6:4],		// x[7:4]
                             ~joystick_l_analog_0[15], joystick_l_analog_0[14:12],	// y[7:4]
                             2'b11, ~joystick_0[7], ~joystick_0[6],						// E1, E2, start, select
                             ~joystick_0[4], ~joystick_0[5], 2'b11 };					// A, B, C, D
      end
    end

    else if (active == 1) begin
      usec_counter_ff <= usec_counter;
      clk_counter     <= clk_counter + 1;
      if (clk_counter == clks_per_usec)
      begin
        clk_counter     <= 0;
        usec_counter    <= usec_counter + 1;
      end

      if (cycle_count == 0) begin		// first cycle needs 68 microseconds until output
        if ((usec_counter > usec_counter_ff) && (usec_counter == 68)) begin
          data[3:0]          <= shift_output[3:0];
          shift_output[43:0] <= shift_output[47:4];
          trg2               <= 1'b0;
          cycle_count        <= 1;
          usec_counter       <= 0;
        end
      end

      else if ((cycle_count >= 1) && (cycle_count <= 6)) begin	// normal 6 cycles of data output
        if ((usec_counter > usec_counter_ff) && (usec_counter == 13)) begin
          trg1 <= 1'b1;
          trg2 <= 1'b1;
        end

        else if ((usec_counter > usec_counter_ff) && (usec_counter == 17)) begin
          data[3:0]          <= shift_output[3:0];
          shift_output[43:0] <= shift_output[47:4];
          trg2               <= 1'b0;
        end

        else if ((usec_counter > usec_counter_ff) && (usec_counter == 30)) begin
          trg2 <= 1'b1;
        end

        else if ((usec_counter > usec_counter_ff) && (usec_counter == 34)) begin
          trg1 <= 1'b0;
          if (cycle_count == 6)
          begin
            cycle_count <= 7;
          end
        end

        else if ((usec_counter > usec_counter_ff) && (usec_counter == 50)) begin
          data[3:0]          <= shift_output[3:0];
          shift_output[43:0] <= shift_output[47:4];
          trg2               <= 1'b0;
          cycle_count        <= cycle_count + 1;
          usec_counter       <= 0;
        end
      end

      else if (cycle_count == 7) 	 // Data train completed; ready to reset
      begin
        active <= 1'b0;
        trg1 <= 1'b0;
        trg2 <= 1'b1;
        data[3:0] <= 4'b1111;
        cycle_count  <= 3'b0;
        clk_counter  <= 0;
        usec_counter <= 0;
      end

    end
  end

endmodule
