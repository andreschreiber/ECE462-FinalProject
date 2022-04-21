`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 10/08/2019 06:43:05 PM
// Implemented in ECE369
//////////////////////////////////////////////////////////////////////////////////


module PipelinedRegisters(Clk, Rst, w_en, IFID_Write, in_IFID, in_IDEX, in_EXMEM, in_MEMWB,
    out_IFID, out_IDEX, out_EXMEM, out_MEMWB);
    
    input Clk, Rst, w_en;
    
    input IFID_Write;
    input[63:0] in_IFID;
    output reg[63:0] out_IFID;
    
    input[159:0] in_IDEX;
    output reg[159:0] out_IDEX;
    
    input[108:0] in_EXMEM;
    output reg[108:0] out_EXMEM;
    
    input[70:0] in_MEMWB;
    output reg[70:0] out_MEMWB;
    
    initial begin
        out_IFID <= 64'b0;
        out_IDEX <= 160'b0;
        out_EXMEM <= 109'b0;
        out_MEMWB <= 71'b0;
    end
    
    always @(posedge Clk) begin
        if(Rst == 1'b1) begin
            out_IFID <= 0;
            out_IDEX <= 0;
            out_EXMEM <= 0;
            out_MEMWB <= 0;
        end
        else begin
            if(w_en) begin
                if(IFID_Write) begin
                    out_IFID <= in_IFID;
                end
                out_IDEX <= in_IDEX;
                out_EXMEM <= in_EXMEM;
                out_MEMWB <= in_MEMWB;
            end
        end
    end
    
endmodule
