`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 04/18/2022 03:39:03 PM
// Modified for ECE462
//////////////////////////////////////////////////////////////////////////////////


module DataMemoryFast(
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
    output reg [31:0] r_data;
    output reg hit;
    
    reg [31:0] memory [0:MEM_SIZE_WORDS-1];

    initial begin
        $readmemh("Data_memory.txt", memory);
    end
    
    always @(posedge clk) begin
        if(w_en) begin
            memory[addr[ADDR_SIZE-1:2]] <= w_data;
        end
    end
    
    always @(*) begin
        if(r_en) begin
            r_data <= memory[addr[ADDR_SIZE-1:2]];
            hit <= 1'b1;
        end
        else begin
            r_data <= 32'hXXXX_XXXX;
            hit <= 1'b1;
        end
    end
    
endmodule
