`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 03/06/2022 10:52:23 AM
// Implemented for ECE462
//////////////////////////////////////////////////////////////////////////////////


module InstructionMemoryCached(
        clk,
        rst,
        r_en,
        r_addr,
        r_data,
        hit
    );
    
    parameter ADDR_SIZE = 12;
    parameter CACHE_SETS = 16;
    parameter LINE_WORDS = 4;
    parameter MEM_BLOCKS = 256; // 256 16 byte blocks
    
    input clk;
    input rst;
    input r_en;
    input [ADDR_SIZE-1:0] r_addr;
    output reg hit;
    output reg [31:0] r_data;
    
    // For FSM
    localparam STATE_READY = 0, STATE_STALL = 1, STATE_EVICT = 2;
    reg [1:0] state;
    reg [1:0] next_state;
    // For simulated stalling
    localparam MEM_STALL = 100; // Total access time on miss = MEM_STALL+3 (+3 for overhead of hit/eviction)
    reg [$clog2(MEM_STALL)+1:0] stall_count;
    reg [$clog2(MEM_STALL)+1:0] next_stall_count;
    
    // For interconnect
    reg e_en;
    reg c_ren;
    reg [ADDR_SIZE-1:0] c_raddr;
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
        c_raddr <= 0;
        r_data <= 0;
        hit <= 1'b0;
    end

    InstructionCacheMemory #(.ADDR_SIZE(ADDR_SIZE), .CACHE_SETS(CACHE_SETS), .LINE_WORDS(LINE_WORDS)) cache(
        .clk(clk),
        .addr(c_raddr),
        .r_en(c_ren),
        .r_data(c_rdata),
        .e_en(e_en),
        .e_data(e_data),
        .hit(c_hit)
    );
    
    InstructionMainMemory #(.ADDR_SIZE(ADDR_SIZE), .MEM_BLOCKS(MEM_BLOCKS), .LINE_WORDS(LINE_WORDS)) memory(
        .addr(c_raddr),
        .data(e_data)
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

    //state, r_en, r_addr, hit, c_r_data, stall_count
    always @(state, r_en, r_addr, c_rdata, c_hit, stall_count) begin
        case(state)
            STATE_READY: begin
                e_en <= 1'b0;
                c_raddr <= r_addr;
                if(r_en) begin
                    c_ren <= 1'b1;
                    if(c_hit) begin
                        next_state <= STATE_READY;
                        next_stall_count <= 0;
                        r_data <= #1 c_rdata;
                        hit <= #1 1'b1;
                    end
                    else begin
                        next_state <= STATE_STALL;
                        next_stall_count <= 0;
                        r_data <= #1 32'hXXXXXXXX;
                        hit <= #1 1'b0;
                    end
                end
                else begin
                    c_ren <= 1'b0;
                    r_data <= #1 32'hXXXXXXXX;
                    next_state <= STATE_READY;
                    next_stall_count <= 0;
                    hit <= #1 1'b0;
                end
            end
            STATE_STALL: begin
                e_en <= 1'b0;
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXXXXXX;
                c_raddr <= c_raddr;
                c_ren <= 1'b0;
                next_stall_count = stall_count + 1;
                if(stall_count != MEM_STALL) begin
                    next_state <= STATE_STALL;
                end
                else begin
                    next_state <= STATE_EVICT;
                end
            end
            STATE_EVICT: begin
                e_en <= 1'b1;
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXXXXXX;
                c_raddr <= c_raddr;
                c_ren <= 1'b0;
                next_stall_count <= 0;
                next_state <= STATE_READY;
            end
            default: begin
                e_en <= 1'b0;
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXXXXXX;
                c_ren = 1'b0;
                next_stall_count <= 0;
                next_state <= STATE_READY;
            end
        endcase
    end
endmodule