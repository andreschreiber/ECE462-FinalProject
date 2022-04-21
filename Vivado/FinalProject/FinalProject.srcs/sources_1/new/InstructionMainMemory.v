`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 03/06/2022 10:52:23 AM
// Implemented for ECE462
//////////////////////////////////////////////////////////////////////////////////


module InstructionMainMemory(
        addr,
        data
    );
    parameter ADDR_SIZE = 12;
    parameter MEM_BLOCKS = 256;
    parameter LINE_WORDS = 4;
    
    input [ADDR_SIZE-1:0] addr;
    output [(LINE_WORDS*32)-1:0] data;
    
    reg [31:0] memory[0:MEM_BLOCKS-1][0:LINE_WORDS-1];

    initial begin
        $readmemh("Instruction_memory.txt", memory);
    end
    
    assign data = {
        memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][3],
        memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][2],
        memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][1],
        memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][0]
    };
endmodule