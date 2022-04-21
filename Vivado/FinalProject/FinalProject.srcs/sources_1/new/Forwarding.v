`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 11/09/2019 12:43:58 PM
// Implemented in ECE369
//////////////////////////////////////////////////////////////////////////////////


module Forwarding(mem_wb_RegWrite, ex_mem_RegWrite, if_id_JumpReg, id_ex_RegWrite,
                  if_id_Read1, if_id_Read2, id_ex_RegRd, ex_mem_RegRd, mem_wb_RegRd, id_ex_RegRs, id_ex_RegRt,
                  fwdA, fwdB, fwdIFIDRead1, fwdIFIDRead2);
    
    input mem_wb_RegWrite;
    input ex_mem_RegWrite;
    input if_id_JumpReg;
    input id_ex_RegWrite;
    input [4:0] if_id_Read1;
    input [4:0] if_id_Read2;
    input [4:0] id_ex_RegRd;
    input [4:0] ex_mem_RegRd;
    input [4:0] mem_wb_RegRd;
    input [4:0] id_ex_RegRs;
    input [4:0] id_ex_RegRt;
    output reg [1:0] fwdA;
    output reg [1:0] fwdB;
    output reg [1:0] fwdIFIDRead1;
    output reg fwdIFIDRead2;
    
    always @(*) begin
        // For forwarding to decode stage
        if(if_id_JumpReg && (if_id_Read1 == id_ex_RegRd) && id_ex_RegWrite && (if_id_Read1 != 0)) begin
            fwdIFIDRead1 <= 2'b10;
        end
        else if(if_id_JumpReg && (if_id_Read1 == ex_mem_RegRd) && ex_mem_RegWrite && (if_id_Read1 != 0)) begin
            fwdIFIDRead1 <= 2'b01;
        end
        else if(mem_wb_RegWrite && (mem_wb_RegRd != 0) && (mem_wb_RegRd == if_id_Read1)) begin
            fwdIFIDRead1 <= 2'b11;
        end
        else begin
            fwdIFIDRead1 <= 2'b00;
        end
        if(mem_wb_RegWrite && (mem_wb_RegRd != 0) && (mem_wb_RegRd == if_id_Read2)) begin
            fwdIFIDRead2 <= 1'b1;
        end
        else begin
            fwdIFIDRead2 <= 1'b0;
        end
    
        // For forwarding with ALU operands
        if(ex_mem_RegWrite && (ex_mem_RegRd != 0) && (ex_mem_RegRd == id_ex_RegRs)) begin
            fwdA <= 2'b10;
        end
        else if (mem_wb_RegWrite && (mem_wb_RegRd != 0) && (mem_wb_RegRd == id_ex_RegRs)) begin
            fwdA <= 2'b01;
        end
        else begin
            fwdA <= 2'b00;
        end
        if(ex_mem_RegWrite && (ex_mem_RegRd != 0) && (ex_mem_RegRd == id_ex_RegRt)) begin
            fwdB <= 2'b10;
        end
        else if (mem_wb_RegWrite && (mem_wb_RegRd != 0) && (mem_wb_RegRd == id_ex_RegRt)) begin
            fwdB <= 2'b01;    
        end
        else begin
            fwdB <= 2'b00;
        end
    end
                      
endmodule
