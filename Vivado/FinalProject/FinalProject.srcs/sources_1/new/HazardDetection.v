`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 11/09/2019 02:54:45 PM
// Implemented in ECE369
//////////////////////////////////////////////////////////////////////////////////

module HazardDetection(fetchOp, fetchFunct, shouldBranch, shouldJump, decodeBranch, exBranch, instrHit, dataHit, data_ren, data_wen, pipeline_wen,
                       id_ex_MemRead, if_id_MemRead, ex_mem_MemRead, id_ex_RegRt, if_id_RegRs, if_id_RegRt,
                       fetchRs, ex_mem_RegRd,
                       if_id_Write, pcWrite, if_id_ControlClear,
                       id_ex_ControlClear, ex_mem_ControlClear);
    
	input id_ex_MemRead;
	input if_id_MemRead;
	input ex_mem_MemRead;
	input [4:0] fetchRs;
	input [4:0] ex_mem_RegRd;
    input [4:0] id_ex_RegRt;
    input [4:0] if_id_RegRs;
    input [4:0] if_id_RegRt;
    input instrHit;
    input dataHit;
    input data_ren;
    input data_wen;
    input shouldJump;
    input decodeBranch;
    input exBranch;
    input [5:0] fetchOp;
    input [5:0] fetchFunct;
    input shouldBranch;
    output reg if_id_Write;
    output reg pcWrite;
    output reg if_id_ControlClear;
    output reg id_ex_ControlClear;
    output reg ex_mem_ControlClear;
    output reg pipeline_wen;
    
    always @(*) begin
        
        // So, methinks there are two potential strategies to use here.
        // Strategy one:
        // 1) If both (or either) of the stall conditions for caches occur,
        //    we can go ahead and just prevent writes to both PC and all
        //    pipeline registers.
        // 2) This can be decomposed into 3 cases.
        //      2a) Only instruction cache has a miss. In this case,
        //          we could propagate the instructions beyond one with a
        //          instruction fetch miss down pipeline. I.e. do NOPs
        //          for subsequent instructions until miss is resolved.
        //          The thing I don't like here, though is that we could
        //          have problems with hazards in between.
        //      2b) Only data cache has a miss. In this case,
        //          we stall all instructions except last one maybe.
        //      2c) Both caches have misses. This case will be same as 
        //          2b?
        //
        //
        //
        
        // Cache miss (data not ready)
        if(!instrHit || (!dataHit && (data_ren || data_wen))) begin
            pcWrite <= 1'b0;
            if_id_Write <= 1'b0;
            if_id_ControlClear <= 1'b0;
            id_ex_ControlClear <= 1'b0;
            ex_mem_ControlClear <= 1'b0;
            pipeline_wen <= 1'b0;
        end
        // Branch hazard
        else if(shouldBranch) begin
            // Flush.
            pcWrite <= 1'b1;
            if_id_Write <= 1'b1;
            if_id_ControlClear <= 1'b1;
            id_ex_ControlClear <= 1'b1;
            ex_mem_ControlClear <= 1'b1;
            pipeline_wen <= 1'b1;
        end
        // Load use hazard
        else if(id_ex_MemRead && (id_ex_RegRt != 0) && ((id_ex_RegRt == if_id_RegRs) || (id_ex_RegRt == if_id_RegRt))) begin
            // Stall the pipeline.
            pcWrite <= 1'b0;
            if_id_Write <= 1'b0;
            if_id_ControlClear <= 1'b0;
            id_ex_ControlClear <= 1'b1;
            ex_mem_ControlClear <= 1'b0;
            pipeline_wen <= 1'b1;
        end
        // Jump should make next operation a nop
        else if(shouldJump) begin
            // Make next operation a no-op
            pcWrite <= 1'b1;
            if_id_Write <= 1'b1;
            if_id_ControlClear <= 1'b1;
            id_ex_ControlClear <= 1'b0;
            ex_mem_ControlClear <= 1'b0;
            pipeline_wen <= 1'b1;
        end
        // We're fetching a jump instuction and there's a branch in decode or execute
        else if((fetchOp == 6'b000010 || fetchOp == 6'b000011 ||
                (fetchOp == 6'b000000 && fetchFunct == 6'b001000)) && (decodeBranch || exBranch)) begin
            // Stall pipeline
            // (For branch in mem it's not needed since branch mux take priority over jump).
            pcWrite <= 1'b0;
            if_id_Write <= 1'b1;
            if_id_ControlClear <= 1'b1;
            id_ex_ControlClear <= 1'b0;
            ex_mem_ControlClear <= 1'b0;
            pipeline_wen <= 1'b1;
        end
        // Stall if jr and there is a lw happening (need to wait for the lw to complete).
        else if((fetchOp == 6'b000000 && fetchFunct == 6'b001000) && (fetchRs != 5'b00000) &&
                ((if_id_MemRead && (if_id_RegRt == fetchRs)) ||
                 (id_ex_MemRead && (id_ex_RegRt == fetchRs)) ||
                 (ex_mem_MemRead && (ex_mem_RegRd == fetchRs)))) begin
            pcWrite <= 1'b0;
            if_id_Write <= 1'b1;
            if_id_ControlClear <= 1'b1;
            id_ex_ControlClear <= 1'b0;
            ex_mem_ControlClear <= 1'b0;
            pipeline_wen <= 1'b1;
        end
        // No Hazards
        else begin
            pcWrite <= 1'b1;
            if_id_Write <= 1'b1;
            if_id_ControlClear <= 1'b0;
            id_ex_ControlClear <= 1'b0;
            ex_mem_ControlClear <= 1'b0;
            pipeline_wen <= 1'b1;
        end
    end
    
endmodule
