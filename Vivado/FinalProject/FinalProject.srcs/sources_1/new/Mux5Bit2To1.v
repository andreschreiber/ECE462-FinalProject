`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 10/09/2019 07:49:40 PM
// Implemented in ECE369
//////////////////////////////////////////////////////////////////////////////////

module Mux5Bit2To1(out, inA, inB, sel);

    output reg [4:0] out;
    
    input [4:0] inA;
    input [4:0] inB;
    input sel;

    always @(*) begin
        case(sel)
            1'b0: out <= inB;
            1'b1: out <= inA;
        endcase
    end

endmodule