`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 10/05/2019 08:22:48 PM
// Implemented in ECE369
//////////////////////////////////////////////////////////////////////////////////

module HiLoRegisters(Clk, Rst, in_Hi, in_Lo, out_Hi, out_Lo, write);
    input Clk;
    input Rst;
    input write;
    input [31:0] in_Hi;
    input [31:0] in_Lo;
    (* mark_debug = "true" *) output reg [31:0] out_Hi;
    (* mark_debug = "true" *) output reg [31:0] out_Lo;
    
    always @(posedge Clk) begin
        if(Rst) begin
            out_Hi <= 0;
            out_Lo <= 0;
        end
        else begin
            if(write == 1'b1) begin
                out_Hi <= in_Hi;
                out_Lo <= in_Lo;
            end
        end
    end
    
endmodule