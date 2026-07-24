// RetroAchievements RAM Mirror for TurboGrafx-16 / PC Engine — Option C
//
// Each VBlank, reads a list of specific addresses from DDRAM (written by ARM),
// fetches byte values from BRAM (Work RAM) or DDRAM (CD/SCD RAM), and writes
// results back to DDRAM for the ARM to read via rcheevos.
//
// rcheevos Memory Map (PC Engine):
//   0x000000-0x001FFF  Work RAM (8KB)    — in BRAM (pce_top dpram port B)
//   0x002000-0x011FFF  CD RAM (64KB)     — in DDRAM (when cd_en && !use_sdr)
//   0x012000-0x041FFF  SCD RAM (192KB)   — in DDRAM (when cd_en && !use_sdr)
//   0x042000-0x0427FF  CD BRAM (2KB)     — not supported (save data, rarely needed)
//
// DDRAM Layout (at DDRAM_BASE, ARM phys 0x3D000000):
//   [0x00000] Header:   magic(32) + 0(8) + flags(8) + 0(16)
//   [0x00008] Frame:    frame_counter(32) + 0(32)
//   [0x00010] Debug1:   ver(8) + dispatch(8) + first_dout(16) + timeout(16) + ok(16)
//   [0x00018] Debug2:   first_addr(16) + wram_cnt(16) + cdram_cnt(16) + max_timeout(16)
//   [0x40000] AddrReq:  addr_count(32) + request_id(32)       (ARM → FPGA)
//   [0x40008] Addrs:    addr[0](32) + addr[1](32), ...        (2 per 64-bit word)
//   [0x48000] ValResp:  response_id(32) + response_frame(32)  (FPGA → ARM)
//   [0x48008] Values:   val[0..7](8b each), ...               (8 per 64-bit word)

module ra_ram_mirror_tgfx16 #(
        parameter [28:0] DDRAM_BASE = 29'h07A00000  // ARM phys 0x3D000000 >> 3
)(
        input             clk,           // clk_sys (~21.477 MHz)
        input             reset,
        input             vblank,

        // Work RAM BRAM read port (pce_top port B)
        output reg [14:0] wram_addr,
        input       [7:0] wram_dout,

        // CD mode flags
        input             cd_en,         // CD game loaded
        input             use_sdr,       // CD RAM in SDRAM (not DDRAM)

        // DDRAM write interface (toggle req/ack)
        output reg [28:0] ddram_wr_addr,
        output reg [63:0] ddram_wr_din,
        output reg  [7:0] ddram_wr_be,
        output reg        ddram_wr_req,
        input             ddram_wr_ack,

        // DDRAM read interface (toggle req/ack)
        output reg [28:0] ddram_rd_addr,
        output reg        ddram_rd_req,
        input             ddram_rd_ack,
        input      [63:0] ddram_rd_dout,

        // Status
        output reg        active,
        output reg [31:0] dbg_frame_counter
);

// ======================================================================
// Constants
// ======================================================================
localparam [28:0] ADDRLIST_BASE  = DDRAM_BASE + 29'h8000;  // byte offset 0x40000 / 8
localparam [28:0] VALCACHE_BASE  = DDRAM_BASE + 29'h9000;  // byte offset 0x48000 / 8
localparam [12:0] MAX_ADDRS      = 13'd4096;

// Realtime query mailbox (see ra_ramread.h): ARM writes requests, FPGA answers.
localparam [28:0] QUERY_CTRL_ADDR = DDRAM_BASE + 29'hA000;  // byte offset 0x50000 / 8
localparam [28:0] QUERY_REQ_BASE  = DDRAM_BASE + 29'hA001;  // byte offset 0x50008 / 8
localparam [28:0] QUERY_RESP_BASE = DDRAM_BASE + 29'hA011;  // byte offset 0x50088 / 8
localparam [28:0] ARM_CFG_ADDR    = DDRAM_BASE + 29'd8;     // byte offset 0x40 (RA_ARM_CFG_RTQUERY)

// rcheevos address boundaries
localparam [31:0] WRAM_END       = 32'h002000;  // Work RAM: 0x0000-0x1FFF
localparam [31:0] CDRAM_START    = 32'h002000;
localparam [31:0] CDRAM_END      = 32'h012000;  // CD RAM: 0x2000-0x11FFF (64KB)
localparam [31:0] SCDRAM_START   = 32'h012000;
localparam [31:0] SCDRAM_END     = 32'h042000;  // SCD RAM: 0x12000-0x41FFF (192KB)

// DDRAM word addresses for CD/SCD RAM reads
// Core writes CD RAM at wraddr = 0x0600000 + offset
// Core writes SCD RAM at wraddr = 0x0610000 + offset
// DDRAM word addr = {4'b0011, wraddr[27:3]}
localparam [28:0] CDRAM_DDRAM_BASE  = 29'h060C0000;  // {4'b0011, 28'h0600000 >> 3}
localparam [28:0] SCDRAM_DDRAM_BASE = 29'h060C2000;  // {4'b0011, 28'h0610000 >> 3}

// ======================================================================
// Clock domain crossing synchronizers
// ======================================================================
reg dwr_ack_s1, dwr_ack_s2;
reg drd_ack_s1, drd_ack_s2;
always @(posedge clk) begin
        dwr_ack_s1 <= ddram_wr_ack; dwr_ack_s2 <= dwr_ack_s1;
        drd_ack_s1 <= ddram_rd_ack; drd_ack_s2 <= drd_ack_s1;
end

// ======================================================================
// VBlank edge detection
// ======================================================================
reg vblank_prev;
wire vblank_rising = vblank & ~vblank_prev;
always @(posedge clk) vblank_prev <= vblank;

// Sticky pending flag: the rising pulse is 1 clk wide and would be missed if
// the FSM is busy answering a realtime query when it fires.
reg vblank_pending;
always @(posedge clk) begin
        if (reset) vblank_pending <= 1'b0;
        else if (vblank_rising) vblank_pending <= 1'b1;
        else if (state == S_IDLE && vblank_pending) vblank_pending <= 1'b0;
end

// ======================================================================
// State machine
// ======================================================================
localparam S_IDLE         = 5'd0;
localparam S_DD_WR_WAIT   = 5'd1;
localparam S_DD_RD_WAIT   = 5'd2;
localparam S_READ_HDR     = 5'd3;
localparam S_PARSE_HDR    = 5'd4;
localparam S_READ_PAIR    = 5'd5;
localparam S_PARSE_ADDR   = 5'd6;
localparam S_DISPATCH     = 5'd7;
localparam S_FETCH_BRAM   = 5'd8;   // Work RAM BRAM read
localparam S_BRAM_WAIT    = 5'd9;   // BRAM addr registered
localparam S_BRAM_READ    = 5'd19;  // BRAM data available
localparam S_FETCH_CDRAM  = 5'd10;  // CD/SCD RAM DDRAM read
localparam S_CDRAM_PARSE  = 5'd11;  // Extract byte from DDRAM word
localparam S_STORE_VAL    = 5'd12;
localparam S_FLUSH_BUF    = 5'd13;
localparam S_WRITE_RESP   = 5'd14;
localparam S_WR_HDR0      = 5'd15;
localparam S_WR_HDR1      = 5'd16;
localparam S_WR_DBG       = 5'd17;
localparam S_WR_DBG2      = 5'd18;
// Realtime query states (v2)
localparam S_RD_ARMCFG    = 5'd20;
localparam S_PARSE_ARMCFG = 5'd21;
localparam S_QRY_PARSE    = 5'd22;
localparam S_QRY_RD_REQ   = 5'd23;
localparam S_QRY_SETUP    = 5'd24;
localparam S_QRY_WR_RESP  = 5'd25;
localparam S_QRY_WR_CTRL  = 5'd26;

reg [4:0]  state;
reg [4:0]  return_state;

reg [31:0] frame_counter;
always @(posedge clk) dbg_frame_counter <= frame_counter;

reg [63:0] rd_data;
reg [31:0] req_count;
reg [31:0] req_id;
reg [12:0] addr_idx;
reg [63:0] addr_word;
reg [31:0] cur_addr;
reg [63:0] collect_buf;
reg  [3:0] collect_cnt;
reg [12:0] val_word_idx;
reg  [7:0] fetch_byte;
reg  [2:0] cdram_byte_sel;  // byte position within DDRAM word for CD RAM reads

// Realtime query registers
reg        rtquery_armed;
reg [10:0] qry_poll_timer;
reg  [7:0] qry_last_seen_seq;
reg  [7:0] qry_request_seq;
reg  [7:0] qry_num;
reg  [3:0] qry_idx;
reg [31:0] qry_value;
reg  [2:0] qry_byte_idx;
reg  [2:0] qry_num_bytes;
reg        qry_mode;         // 1 = current fetch belongs to a realtime query

// Debug counters (reset each frame)
reg [15:0] dbg_ok_cnt;
reg [15:0] dbg_timeout_cnt;
reg [15:0] dbg_first_dout;
reg        dbg_first_cap;
reg  [7:0] dbg_dispatch_cnt;
reg [15:0] dbg_wram_cnt;
reg [15:0] dbg_cdram_cnt;
reg [15:0] dbg_first_addr;
reg [15:0] dbg_max_timeout;

// ======================================================================
// Main state machine
// ======================================================================
always @(posedge clk) begin
        if (reset) begin
                state        <= S_IDLE;
                active       <= 1'b0;
                frame_counter <= 32'd0;
                ddram_wr_req <= dwr_ack_s2;
                ddram_rd_req <= drd_ack_s2;
                rtquery_armed     <= 1'b0;
                qry_poll_timer    <= 11'd0;
                qry_last_seen_seq <= 8'd0;
                qry_mode          <= 1'b0;
        end
        else begin
                case (state)

                // =============================================================
                // IDLE: Wait for VBlank rising edge
                // =============================================================
                S_IDLE: begin
                        active   <= 1'b0;
                        qry_mode <= 1'b0;
                        if (vblank_pending) begin
                                active <= 1'b1;
                                qry_poll_timer   <= 11'd0;
                                dbg_ok_cnt       <= 16'd0;
                                dbg_timeout_cnt  <= 16'd0;
                                dbg_first_cap    <= 1'b0;
                                dbg_first_dout   <= 16'd0;
                                dbg_max_timeout  <= 16'd0;
                                dbg_dispatch_cnt <= 8'd0;
                                dbg_wram_cnt     <= 16'd0;
                                dbg_cdram_cnt    <= 16'd0;
                                dbg_first_addr   <= 16'd0;
                                // Write header with busy=1
                                ddram_wr_addr <= DDRAM_BASE;
                                ddram_wr_din  <= {16'd0, 8'h01, 8'd0, 32'h52414348};
                                ddram_wr_be   <= 8'hFF;
                                ddram_wr_req  <= ~ddram_wr_req;
                                return_state  <= S_READ_HDR;
                                state         <= S_DD_WR_WAIT;
                        end
                        else if (qry_poll_timer < 11'd1500) begin
                                // Rate limit query-mailbox polling (~70us at 21.5MHz)
                                qry_poll_timer <= qry_poll_timer + 11'd1;
                        end
                        else if (rtquery_armed) begin
                                qry_poll_timer <= 11'd0;
                                ddram_rd_addr  <= QUERY_CTRL_ADDR;
                                ddram_rd_req   <= ~ddram_rd_req;
                                return_state   <= S_QRY_PARSE;
                                state          <= S_DD_RD_WAIT;
                        end
                        else begin
                                qry_poll_timer <= 11'd0;
                        end
                end

                // =============================================================
                // Generic DDRAM write wait
                // =============================================================
                S_DD_WR_WAIT: begin
                        if (ddram_wr_req == dwr_ack_s2)
                                state <= return_state;
                end

                // =============================================================
                // Generic DDRAM read wait — capture data
                // =============================================================
                S_DD_RD_WAIT: begin
                        if (ddram_rd_req == drd_ack_s2) begin
                                rd_data <= ddram_rd_dout;
                                state   <= return_state;
                        end
                end

                // =============================================================
                // Read address list header from DDRAM
                // =============================================================
                S_READ_HDR: begin
                        ddram_rd_addr <= ADDRLIST_BASE;
                        ddram_rd_req  <= ~ddram_rd_req;
                        return_state  <= S_PARSE_HDR;
                        state         <= S_DD_RD_WAIT;
                end

                // =============================================================
                // Parse header: extract addr_count and request_id
                // =============================================================
                S_PARSE_HDR: begin
                        req_id <= rd_data[63:32];
                        if (rd_data[31:0] == 32'd0) begin
                                req_count <= 32'd0;
                                state     <= S_WRITE_RESP;
                        end else begin
                                req_count    <= (rd_data[31:0] > {19'd0, MAX_ADDRS}) ?
                                                {19'd0, MAX_ADDRS} : rd_data[31:0];
                                addr_idx     <= 13'd0;
                                collect_cnt  <= 4'd0;
                                collect_buf  <= 64'd0;
                                val_word_idx <= 13'd0;
                                state        <= S_READ_PAIR;
                        end
                end

                // =============================================================
                // Read address pair from DDRAM (2 addrs per 64-bit word)
                // =============================================================
                S_READ_PAIR: begin
                        ddram_rd_addr <= ADDRLIST_BASE + 29'd1 + {16'd0, addr_idx[12:1]};
                        ddram_rd_req  <= ~ddram_rd_req;
                        return_state  <= S_PARSE_ADDR;
                        state         <= S_DD_RD_WAIT;
                end

                // =============================================================
                // Extract current address from cached word
                // =============================================================
                S_PARSE_ADDR: begin
                        if (!addr_idx[0]) begin
                                addr_word <= rd_data;
                                cur_addr  <= rd_data[31:0];
                        end else begin
                                cur_addr <= addr_word[63:32];
                        end
                        state <= S_DISPATCH;
                end

                // =============================================================
                // Route to Work RAM (BRAM) or CD RAM (DDRAM) or zero
                // =============================================================
                S_DISPATCH: begin
                        dbg_dispatch_cnt <= dbg_dispatch_cnt + 8'd1;
                        if (!dbg_dispatch_cnt)
                                dbg_first_addr <= cur_addr[15:0];

                        if (cur_addr < WRAM_END) begin
                                // Work RAM: read from BRAM
                                dbg_wram_cnt <= dbg_wram_cnt + 16'd1;
                                state <= S_FETCH_BRAM;
                        end
                        else if (cd_en && !use_sdr && cur_addr >= CDRAM_START && cur_addr < CDRAM_END) begin
                                // CD RAM: read from DDRAM
                                dbg_cdram_cnt <= dbg_cdram_cnt + 16'd1;
                                state <= S_FETCH_CDRAM;
                        end
                        else if (cd_en && !use_sdr && cur_addr >= SCDRAM_START && cur_addr < SCDRAM_END) begin
                                // SCD RAM: read from DDRAM
                                dbg_cdram_cnt <= dbg_cdram_cnt + 16'd1;
                                state <= S_FETCH_CDRAM;
                        end
                        else begin
                                // Unsupported address: return zero
                                fetch_byte <= 8'd0;
                                dbg_timeout_cnt <= dbg_timeout_cnt + 16'd1;
                                state <= S_STORE_VAL;
                        end
                end

                // =============================================================
                // Work RAM: BRAM read (1-cycle latency)
                // =============================================================
                S_FETCH_BRAM: begin
                        wram_addr <= cur_addr[14:0];
                        state     <= S_BRAM_WAIT;
                end

                // BRAM_WAIT: address was registered by BRAM at this posedge,
                // output (q_b) will be valid after this edge. Wait 1 more cycle.
                S_BRAM_WAIT: begin
                        state <= S_BRAM_READ;
                end

                // BRAM_READ: q_b now has correct data for the address set in S_FETCH_BRAM
                S_BRAM_READ: begin
                        fetch_byte <= wram_dout;
                        dbg_ok_cnt <= dbg_ok_cnt + 16'd1;
                        if (!dbg_first_cap) begin
                                dbg_first_dout <= {8'd0, wram_dout};
                                dbg_first_cap  <= 1'b1;
                        end
                        state <= S_STORE_VAL;
                end

                // =============================================================
                // CD/SCD RAM: DDRAM read
                // Computes DDRAM word address and byte select from rcheevos address
                // =============================================================
                S_FETCH_CDRAM: begin
                        if (cur_addr >= SCDRAM_START) begin
                                // SCD RAM: DDRAM word addr = SCDRAM_DDRAM_BASE + ((cur_addr - SCDRAM_START) >> 3)
                                ddram_rd_addr <= SCDRAM_DDRAM_BASE + {10'd0, cur_addr[18:3] - SCDRAM_START[18:3]};
                        end else begin
                                // CD RAM: DDRAM word addr = CDRAM_DDRAM_BASE + ((cur_addr - CDRAM_START) >> 3)
                                ddram_rd_addr <= CDRAM_DDRAM_BASE + {13'd0, cur_addr[15:3] - CDRAM_START[15:3]};
                        end
                        cdram_byte_sel <= cur_addr[2:0];
                        ddram_rd_req   <= ~ddram_rd_req;
                        return_state   <= S_CDRAM_PARSE;
                        state          <= S_DD_RD_WAIT;
                end

                S_CDRAM_PARSE: begin
                        case (cdram_byte_sel)
                                3'd0: fetch_byte <= rd_data[ 7: 0];
                                3'd1: fetch_byte <= rd_data[15: 8];
                                3'd2: fetch_byte <= rd_data[23:16];
                                3'd3: fetch_byte <= rd_data[31:24];
                                3'd4: fetch_byte <= rd_data[39:32];
                                3'd5: fetch_byte <= rd_data[47:40];
                                3'd6: fetch_byte <= rd_data[55:48];
                                3'd7: fetch_byte <= rd_data[63:56];
                        endcase
                        dbg_ok_cnt <= dbg_ok_cnt + 16'd1;
                        if (!dbg_first_cap) begin
                                dbg_first_dout <= rd_data[15:0];
                                dbg_first_cap  <= 1'b1;
                        end
                        state <= S_STORE_VAL;
                end

                // =============================================================
                // Store byte in collect buffer, advance index.
                // In query mode the fetched byte belongs to the realtime query
                // instead: assemble the (little-endian) 32-bit value.
                // =============================================================
                S_STORE_VAL: if (qry_mode) begin
                        case (qry_byte_idx[1:0])
                                2'd0: qry_value[ 7: 0] <= fetch_byte;
                                2'd1: qry_value[15: 8] <= fetch_byte;
                                2'd2: qry_value[23:16] <= fetch_byte;
                                2'd3: qry_value[31:24] <= fetch_byte;
                        endcase
                        qry_byte_idx <= qry_byte_idx + 3'd1;
                        if (qry_byte_idx + 3'd1 >= qry_num_bytes) begin
                                state <= S_QRY_WR_RESP;
                        end else begin
                                cur_addr <= cur_addr + 32'd1;
                                state    <= S_DISPATCH;
                        end
                end else begin
                        case (collect_cnt[2:0])
                                3'd0: collect_buf[ 7: 0] <= fetch_byte;
                                3'd1: collect_buf[15: 8] <= fetch_byte;
                                3'd2: collect_buf[23:16] <= fetch_byte;
                                3'd3: collect_buf[31:24] <= fetch_byte;
                                3'd4: collect_buf[39:32] <= fetch_byte;
                                3'd5: collect_buf[47:40] <= fetch_byte;
                                3'd6: collect_buf[55:48] <= fetch_byte;
                                3'd7: collect_buf[63:56] <= fetch_byte;
                        endcase
                        collect_cnt <= collect_cnt + 4'd1;
                        addr_idx    <= addr_idx + 13'd1;

                        if (collect_cnt == 4'd7 || (addr_idx + 13'd1 >= req_count[12:0])) begin
                                state <= S_FLUSH_BUF;
                        end
                        else if (addr_idx[0]) begin
                                state <= S_READ_PAIR;
                        end else begin
                                state <= S_PARSE_ADDR;
                        end
                end

                // =============================================================
                // Flush collect buffer to DDRAM value cache
                // =============================================================
                S_FLUSH_BUF: begin
                        ddram_wr_addr <= VALCACHE_BASE + 29'd1 + {16'd0, val_word_idx};
                        ddram_wr_din  <= collect_buf;
                        ddram_wr_be   <= (collect_cnt == 4'd8) ? 8'hFF
                                         : ((8'd1 << collect_cnt[2:0]) - 8'd1);
                        ddram_wr_req  <= ~ddram_wr_req;
                        val_word_idx  <= val_word_idx + 13'd1;
                        collect_cnt   <= 4'd0;
                        collect_buf   <= 64'd0;

                        if (addr_idx >= req_count[12:0]) begin
                                return_state <= S_WRITE_RESP;
                        end else if (!addr_idx[0]) begin
                                return_state <= S_READ_PAIR;
                        end else begin
                                return_state <= S_PARSE_ADDR;
                        end
                        state <= S_DD_WR_WAIT;
                end

                // =============================================================
                // Write response header
                // =============================================================
                S_WRITE_RESP: begin
                        ddram_wr_addr <= VALCACHE_BASE;
                        ddram_wr_din  <= {frame_counter + 32'd1, req_id};
                        ddram_wr_be   <= 8'hFF;
                        ddram_wr_req  <= ~ddram_wr_req;
                        return_state  <= S_WR_HDR0;
                        state         <= S_DD_WR_WAIT;
                end

                // =============================================================
                // Write header word 0: magic + busy=0
                // =============================================================
                S_WR_HDR0: begin
                        ddram_wr_addr <= DDRAM_BASE;
                        ddram_wr_din  <= {16'd0, 8'h00, 8'd0, 32'h52414348};
                        ddram_wr_be   <= 8'hFF;
                        ddram_wr_req  <= ~ddram_wr_req;
                        return_state  <= S_WR_HDR1;
                        state         <= S_DD_WR_WAIT;
                end

                // =============================================================
                // Write header word 1: frame_counter
                // =============================================================
                S_WR_HDR1: begin
                        ddram_wr_addr <= DDRAM_BASE + 29'd1;
                        ddram_wr_din  <= {32'd0, frame_counter + 32'd1};
                        ddram_wr_be   <= 8'hFF;
                        ddram_wr_req  <= ~ddram_wr_req;
                        frame_counter <= frame_counter + 32'd1;
                        return_state  <= S_WR_DBG;
                        state         <= S_DD_WR_WAIT;
                end

                // =============================================================
                // Debug word 1: {ver(8), dispatch(8), first_dout(16), timeout(16), ok(16)}
                // =============================================================
                S_WR_DBG: begin
                        ddram_wr_addr <= DDRAM_BASE + 29'd2;
                        // ver=0x02: advertises the realtime-query mailbox (ra_rtquery_supported)
                        ddram_wr_din  <= {8'h02, dbg_dispatch_cnt, dbg_first_dout, dbg_timeout_cnt, dbg_ok_cnt};
                        ddram_wr_be   <= 8'hFF;
                        ddram_wr_req  <= ~ddram_wr_req;
                        return_state  <= S_WR_DBG2;
                        state         <= S_DD_WR_WAIT;
                end

                // =============================================================
                // Debug word 2: {first_addr(16), wram_cnt(16), cdram_cnt(16), max_timeout(16)}
                // =============================================================
                S_WR_DBG2: begin
                        ddram_wr_addr <= DDRAM_BASE + 29'd3;
                        ddram_wr_din  <= {dbg_first_addr, dbg_wram_cnt, dbg_cdram_cnt, dbg_max_timeout};
                        ddram_wr_be   <= 8'hFF;
                        ddram_wr_req  <= ~ddram_wr_req;
                        return_state  <= S_RD_ARMCFG;
                        state         <= S_DD_WR_WAIT;
                end

                // =============================================================
                // Read ARM-written config byte once per VBlank: bit 0 arms the
                // realtime-query mailbox polling (RA_ARM_CFG_RTQUERY).
                // =============================================================
                S_RD_ARMCFG: begin
                        ddram_rd_addr <= ARM_CFG_ADDR;
                        ddram_rd_req  <= ~ddram_rd_req;
                        return_state  <= S_PARSE_ARMCFG;
                        state         <= S_DD_RD_WAIT;
                end

                S_PARSE_ARMCFG: begin
                        rtquery_armed <= rd_data[0];
                        state <= S_IDLE;
                end

                // =============================================================
                // Realtime query: parse control word, serve each request by
                // routing through the normal S_DISPATCH fetch machinery
                // (qry_mode reroutes S_STORE_VAL), write value + control back.
                // =============================================================
                S_QRY_PARSE: begin
                        if (rd_data[7:0] != qry_last_seen_seq && rd_data[15:8] != 8'd0) begin
                                qry_request_seq <= rd_data[7:0];
                                qry_num         <= (rd_data[15:8] > 8'd16) ? 8'd16 : rd_data[15:8];
                                qry_idx         <= 4'd0;
                                state           <= S_QRY_RD_REQ;
                        end else begin
                                state <= S_IDLE;
                        end
                end

                S_QRY_RD_REQ: begin
                        ddram_rd_addr <= QUERY_REQ_BASE + {25'd0, qry_idx};
                        ddram_rd_req  <= ~ddram_rd_req;
                        return_state  <= S_QRY_SETUP;
                        state         <= S_DD_RD_WAIT;
                end

                S_QRY_SETUP: begin
                        cur_addr      <= rd_data[31:0];
                        qry_num_bytes <= (rd_data[34:32] == 3'd0 || rd_data[39:32] > 8'd4)
                                         ? 3'd1 : rd_data[34:32];
                        qry_value     <= 32'd0;
                        qry_byte_idx  <= 3'd0;
                        qry_mode      <= 1'b1;
                        state         <= S_DISPATCH;
                end

                S_QRY_WR_RESP: begin
                        ddram_wr_addr <= QUERY_RESP_BASE + {25'd0, qry_idx};
                        ddram_wr_din  <= {32'd0, qry_value};
                        ddram_wr_be   <= 8'hFF;
                        ddram_wr_req  <= ~ddram_wr_req;
                        qry_idx       <= qry_idx + 4'd1;
                        if (qry_idx + 4'd1 >= qry_num[3:0])
                                return_state <= S_QRY_WR_CTRL;
                        else
                                return_state <= S_QRY_RD_REQ;
                        state <= S_DD_WR_WAIT;
                end

                S_QRY_WR_CTRL: begin
                        qry_mode          <= 1'b0;
                        qry_last_seen_seq <= qry_request_seq;
                        ddram_wr_addr     <= QUERY_CTRL_ADDR;
                        ddram_wr_din      <= {24'd0, qry_request_seq, 16'd0, qry_num, qry_request_seq};
                        ddram_wr_be       <= 8'hFF;
                        ddram_wr_req      <= ~ddram_wr_req;
                        return_state      <= S_IDLE;
                        state             <= S_DD_WR_WAIT;
                end

                default: state <= S_IDLE;
                endcase
        end
end

endmodule
