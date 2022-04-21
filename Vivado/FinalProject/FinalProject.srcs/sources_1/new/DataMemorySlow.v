`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 04/13/2022 06:31:03 PM
// Implemented for ECE462
//////////////////////////////////////////////////////////////////////////////////


module DataMemorySlow(
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
    parameter MEM_SIZE_WORDS = 1024;
    
    input clk;
    input rst;
    input r_en;
    input w_en;
    input [ADDR_SIZE-1:0] addr;
    input [31:0] w_data;
    output reg hit;
    output reg [31:0] r_data;
    
    reg m_ren, m_wen;
    reg [ADDR_SIZE-1:0] m_addr;
    reg [31:0] m_data;
    
    // For FSM
    localparam STATE_READY = 0, STATE_STALL = 1, STATE_ACT = 2;
    reg [1:0] state;
    reg [1:0] next_state;
    // For simulated stalling
    localparam MEM_STALL = 100; // Data will be ready after MEM_STALL + 1 cycles (right after rising edge)
    reg [7:0] stall_count; // Update these sizes accordingly if you change the MEM_RD/WR_STALL params
    reg [7:0] next_stall_count; // Update these sizes accordingly if you change the MEM_RD/WR_STALL addr
    
    // Memory
    reg [31:0] memory [0:MEM_SIZE_WORDS-1];
    
    initial begin
        state <= STATE_READY;
        next_state <= STATE_READY;
        stall_count <= 0;
        next_stall_count <= 0;
        m_ren <= 1'b0;
        m_wen <= 1'b0;
        m_addr <= 0;
        m_data <= 0;
        r_data <= 32'hXXXX_XXXX;
        hit <= 1'b0;
        
        $readmemh("Data_memory.txt", memory);
    end
    
    always @(posedge clk) begin
        if(rst) begin
            state = STATE_READY;
        end
        else begin
            state = next_state;
            stall_count = next_stall_count;
        end
    end
    
    always @(state, addr, w_data, r_en, w_en,  stall_count) begin
        case(state)
            STATE_READY: begin
                hit <= #1 1'b0;
                r_data <= #1 32'hXXXX_XXXX;
                m_data <= w_data;
                m_addr <= addr;
                m_ren <= r_en;
                m_wen <= w_en;
                stall_count <= 0;
                next_stall_count <= 0;
                if(r_en || w_en) begin
                    next_state <= STATE_STALL;
                end
                else begin
                    next_state <= STATE_READY;
                end
            end
            STATE_STALL: begin
                hit <= #1 1'b0;
                m_addr <= m_addr;
                m_data <= m_data;
                r_data <= #1 32'hXXXX_XXXX;
                m_ren <= m_ren;
                m_wen <= m_wen;
                next_stall_count = stall_count + 1;
                if(stall_count != MEM_STALL) begin
                    next_state <= STATE_STALL;
                end
                else begin
                    next_state <= STATE_ACT;
                end
            end
            STATE_ACT: begin
                hit <= #1 1'b1;
                m_addr <= m_addr;
                m_data <= m_data;
                m_ren <= m_ren;
                m_wen <= m_wen;
                stall_count <= 0;
                next_stall_count <= 0;
                if(m_wen) begin
                    memory[m_addr[ADDR_SIZE-1:2]] <= m_data;
                end
                if(m_ren) begin
                    r_data <= #1 memory[m_addr[ADDR_SIZE-1:2]];
                end
                else begin
                    r_data <= #1 32'hXXXX_XXXX;
                end
                next_state <= STATE_READY;
            end
        endcase
    end
endmodule