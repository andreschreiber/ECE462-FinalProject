//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module TopLevel_tb();
    
    reg Clk;
    reg Rst;
    wire [31:0] debug_Hi;
    wire [31:0] debug_Lo;
    wire [31:0] debug_Write;
    wire [31:0] debug_PC;
    
    TopLevel topLevel(.Clk(Clk), .Rst(Rst), .debug_Lo(debug_Lo), .debug_Hi(debug_Hi),
                      .debug_Write(debug_Write), .debug_PC(debug_PC));

    initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end
	
	initial begin
	   Rst <= 1'b1;
	   #20;
	   Rst <= 1'b0;
	end

endmodule
