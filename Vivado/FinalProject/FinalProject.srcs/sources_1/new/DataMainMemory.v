`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 04/13/2022 06:31:03 PM
// Implemented for ECE462
//////////////////////////////////////////////////////////////////////////////////


module DataMainMemory(
        addr,
        r_data,
        w_en,
        w_data
    );
    
    parameter ADDR_SIZE = 12;
    parameter MEM_BLOCKS = 256;
    parameter LINE_WORDS = 4;
    
    input w_en;
    input [ADDR_SIZE-1:0] addr;
    input [31:0] w_data;
    output reg [(LINE_WORDS*32)-1:0] r_data;
    
    reg [31:0] memory[0:MEM_BLOCKS-1][0:LINE_WORDS-1];

    initial begin
        $readmemh("Data_memory.txt", memory);
    end
    
    always @(*) begin
        if(w_en) begin
            memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][addr[($clog2(LINE_WORDS)+1):2]] = w_data;
        end
        r_data = {
            memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][3],
            memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][2],
            memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][1],
            memory[addr[(ADDR_SIZE-1):($clog2(LINE_WORDS)+2)]][0]
        };
    end
endmodule