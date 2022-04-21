`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Implemented in ECE369
////////////////////////////////////////////////////////////////////////////////

module Mux17Bit2To1(out, inA, inB, sel);

    output reg [16:0] out;
    
    input[16:0] inA;
    input[16:0] inB;
    input sel;

    always @(*) begin
        case(sel)
            1'b0: out <= inB;
            1'b1: out <= inA;
        endcase
    end

endmodule