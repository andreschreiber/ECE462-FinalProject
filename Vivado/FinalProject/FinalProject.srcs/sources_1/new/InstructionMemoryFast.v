`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 04/18/2022 03:39:03 PM
// Modified for ECE462
//////////////////////////////////////////////////////////////////////////////////


module InstructionMemoryFast(
        clk,
        rst,
        r_en,
        r_addr,
        r_data,
        hit
    );
    
    parameter ADDR_SIZE = 12;
    parameter MEM_SIZE_WORDS = 1024;
    
    input clk;
    input rst;
    input r_en;
    input [ADDR_SIZE-1:0] r_addr;
    output reg [31:0] r_data;
    output reg hit;

    reg [31:0] memory [0:MEM_SIZE_WORDS-1];

	initial begin
	   $readmemh("Instruction_memory.txt", memory);
    end
	
	always @(r_en, r_addr) begin
	   if(r_en) begin
	       r_data <= #1 memory[r_addr[ADDR_SIZE-1:2]];
	       hit <= #1 1'b1;
	   end
	   else begin
	       r_data <= #1 32'hXXXX_XXXX;
	       hit <= #1 1'b1;
	   end
    end
    
endmodule
