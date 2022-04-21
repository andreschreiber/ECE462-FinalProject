`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Implemented in ECE369
////////////////////////////////////////////////////////////////////////////////

module PCAdder(PCResult, PCAddResult);
    input [31:0] PCResult;
    (* mark_debug = "true" *) output reg [31:0] PCAddResult;

	always @(PCResult) begin
		PCAddResult <= PCResult + 4;
	end
endmodule
