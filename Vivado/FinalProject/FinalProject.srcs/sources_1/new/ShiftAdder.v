`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 10/09/2019 07:30:12 PM
// Implemented in ECE369
//////////////////////////////////////////////////////////////////////////////////


module ShiftAdder(pcBase, offset, outputAddr);
    input [31:0] pcBase;
    input [31:0] offset;
    output reg [31:0] outputAddr;
    
    always @(*) begin
        outputAddr <= pcBase + (offset << 2);
    end
endmodule
