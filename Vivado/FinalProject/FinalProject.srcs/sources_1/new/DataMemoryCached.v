`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 04/13/2022 06:31:03 PM
// Implemented for ECE462
//////////////////////////////////////////////////////////////////////////////////


module DataMemoryCached(
        clk,
        rst,
        r_en,
        w_en,
        addr,
        r_data,
        w_data,
        hit
    );
    
    parameter ADDR_SIZE = 12;
    parameter CACHE_SETS = 16;
    parameter LINE_WORDS = 4;
    parameter MEM_BLOCKS = 256; // 256 16 byte blocks
    
    input clk;
    input rst;
    input r_en;
    input w_en;
    input [31:0] w_data;
    input [ADDR_SIZE-1:0] addr;
    output reg hit;
    output reg [31:0] r_data;
    
    // For FSM
    localparam STATE_READY = 0, STATE_RD_STALL = 1, STATE_WR_STALL = 2, STATE_EVICT = 3, STATE_WRITE = 4;
    reg [2:0] state;
    reg [2:0] next_state;
    // For simulated stalling
    localparam MEM_RD_STALL = 100; // Total access time on miss = MEM_STALL+3 (+3 for overhead of hit/eviction)
    localparam MEM_WR_STALL = 100;
    reg [7:0] stall_count; // Update these sizes accordingly if you change the MEM_RD/WR_STALL params
    reg [7:0] next_stall_count; // Update these sizes accordingly if you change the MEM_RD/WR_STALL params
    
    // For interconnect
    reg e_en;
    reg c_ren;
    reg c_wen;
    reg m_wen;
    
    reg [31:0] cm_wdata;
    reg [ADDR_SIZE-1:0] c_addr;
    wire [31:0] c_rdata;
    wire [(LINE_WORDS*32)-1:0] e_data;
    wire c_hit;

    initial begin
        state <= STATE_READY;
        next_state <= STATE_READY;
        stall_count <= 0;
        next_stall_count <= 0;
        e_en <= 1'b0;
        c_ren <= 1'b0;
        c_wen <= 1'b0;
        m_wen <= 1'b0;
        c_addr <= 0;
        cm_wdata <= 0;
        r_data <= 0;
        hit <= 1'b0;
    end

    DataCacheMemory #(.ADDR_SIZE(ADDR_SIZE), .CACHE_SETS(CACHE_SETS), .LINE_WORDS(LINE_WORDS)) cache(
        .clk(clk),
        .addr(c_addr),
        .r_en(c_ren),
        .r_data(c_rdata),
        .w_en(c_wen),
        .w_data(cm_wdata),
        .e_en(e_en),
        .e_data(e_data),
        .hit(c_hit)
    );
    
    DataMainMemory #(.ADDR_SIZE(ADDR_SIZE), .MEM_BLOCKS(MEM_BLOCKS), .LINE_WORDS(LINE_WORDS)) memory(
        .addr(c_addr),
        .r_data(e_data),
        .w_en(m_wen),
        .w_data(cm_wdata)
    );
    
    always @(posedge clk) begin
        if(rst) begin
            state = STATE_READY;
        end
        else begin
            state = next_state;
            stall_count = next_stall_count;
        end
    end
    
    always @(state, addr, r_en, w_en, c_rdata, w_data, c_hit, stall_count) begin
        case(state)
            STATE_READY: begin
                e_en <= 1'b0;
                c_addr <= addr;
                c_wen <= 1'b0;
                m_wen <= 1'b0;
                cm_wdata <= w_data;
                if(r_en) begin // Read overrides write, so don't do r_en and w_en at same time.
                    c_ren <= 1'b1;
                    if(c_hit) begin
                        next_state <= STATE_READY;
                        next_stall_count <= 0;
                        r_data <= #1 c_rdata;
                        hit <= #1 1'b1;
                    end
                    else begin
                        next_state <= STATE_RD_STALL;
                        next_stall_count <= 0;
                        r_data <= #1 32'hXXXXXXXX;
                        hit <= #1 1'b0;
                    end
                end
                else if(w_en) begin
                    c_ren <= 1'b0;
                    r_data <= #1 32'hXXXXXXXX;
                    next_state <= STATE_WR_STALL;
                    next_stall_count <= 0;
                    hit <= #1 1'b0;
                end
                else begin
                    c_ren <= 1'b0;
                    r_data <= #1 32'hXXXXXXXX;
                    next_state <= STATE_READY;
                    next_stall_count <= 0;
                    hit <= #1 1'b0;
                end
            end
            STATE_RD_STALL: begin
                e_en <= 1'b0;
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXXXXXX;
                cm_wdata <= cm_wdata;
                c_addr <= c_addr;
                c_ren <= 1'b0;
                c_wen <= 1'b0;
                m_wen <= 1'b0;
                next_stall_count = stall_count + 1;
                if(stall_count != MEM_RD_STALL) begin
                    next_state <= STATE_RD_STALL;
                end
                else begin
                    next_state <= STATE_EVICT;
                end
            end
            STATE_WR_STALL: begin
                e_en <= 1'b0;
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXXXXXX;
                cm_wdata <= cm_wdata;
                c_addr <= c_addr;
                c_ren <= 1'b0;
                c_wen <= 1'b1;
                m_wen <= 1'b0;
                next_stall_count = stall_count + 1;
                if(stall_count != MEM_WR_STALL) begin
                    next_state <= STATE_WR_STALL;
                end
                else begin
                    next_state <= STATE_WRITE;
                end
            end
            STATE_EVICT: begin
                e_en <= 1'b1;
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXXXXXX;
                c_addr <= c_addr;
                cm_wdata <= cm_wdata;
                c_ren <= 1'b0;
                c_wen <= 1'b0;
                m_wen <= 1'b0;
                next_stall_count <= 0;
                next_state <= STATE_READY;
            end
            STATE_WRITE: begin
                e_en <= 1'b0;
                hit <= #1 1'b1;
                r_data <= #1 32'hXXXXXXXX;
                cm_wdata <= cm_wdata;
                c_addr <= c_addr;
                c_ren <= 1'b0;
                c_wen <= 1'b0;
                m_wen <= 1'b1;
                next_stall_count <= 0;
                next_state <= STATE_READY;
                // This part doesn't seem like it's needed.
                /*if(w_en && addr == c_addr && w_data == cm_wdata) begin
                    next_state <= STATE_WRITE;
                end
                else begin
                    next_state <= STATE_READY;
                end*/
            end
            default: begin
                e_en <= 1'b0;
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXXXXXX;
                c_ren = 1'b0;
                c_wen <= 1'b0;
                m_wen <= 1'b0;
                next_stall_count <= 0;
                next_state <= STATE_READY;
            end
        endcase
    end
endmodule