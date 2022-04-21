`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Implemented in ECE369
////////////////////////////////////////////////////////////////////////////////

module ProgramCounter(Address, PCResult, en, Reset, Clk);

	input [31:0] Address;
	input Reset, Clk;
	input en;
	(* mark_debug = "true" *) output reg [31:0] PCResult;

	always @(posedge Clk) begin
	   if(Reset) begin
	       PCResult <= 32'h00000000;
	   end
	   else begin
	       if(en) begin
	           PCResult <= Address;
	       end
	   end
	end

endmodule