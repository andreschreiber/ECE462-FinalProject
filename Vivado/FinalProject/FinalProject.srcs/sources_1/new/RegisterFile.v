`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Implemented in ECE369
////////////////////////////////////////////////////////////////////////////////

module RegisterFile(ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, Clk, ReadData1, ReadData2);

	/* Please fill in the implementation here... */
	input [4:0] ReadRegister1;
	input [4:0] ReadRegister2;
	input [4:0] WriteRegister;
	input [31:0] WriteData;
	input RegWrite;
	input Clk;
	output reg [31:0] ReadData1;
	output reg [31:0] ReadData2;
	
	reg [31:0] registerFile [0:31];
	
	integer i;
	initial begin
	   for(i = 0; i < 32; i = i + 1) begin
	       registerFile[i] = 32'h00000000;
	   end
	end
	
	always @(posedge Clk) begin
        if(RegWrite == 1'b1) begin
            if(WriteRegister != 5'b00000) begin
                registerFile[WriteRegister] <= WriteData;
            end
	   end
	end
	
	always @(negedge Clk) begin
	   ReadData1 <= registerFile[ReadRegister1];
	   ReadData2 <= registerFile[ReadRegister2];
	end

endmodule
