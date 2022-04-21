`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Implemented in ECE369
////////////////////////////////////////////////////////////////////////////////

module Mux32Bit3To1(out, inA, inB, inC, sel);

    output reg [31:0] out;
    
    input [31:0] inA;
    input [31:0] inB;
    input [31:0] inC;
    input [1:0] sel;

    always @(*) begin
        case(sel)
            2'b00: out <= inA;
            2'b01: out <= inB;
            2'b10: out <= inC;
            2'b11: out <= 32'b0;
        endcase
    end

endmodule