`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
//
// Originally by Andre Schreiber (Original Lab Partner in ECE369: Emiliano Mendez).
// Newly modified by Andre Schreiber, Erin Ok, Ian Bell, William Hentig, and Ramon Driesen.
// Branches resolved in mem stage. Jumps resolved in decode stage.
// Modified for ECE462
////////////////////////////////////////////////////////////////////////////////

module TopLevel(Clk, Rst, debug_Lo, debug_Hi, debug_Write, debug_PC);
    input Clk;
    input Rst;
    
    output [31:0] debug_Lo;
    output [31:0] debug_Hi;
    output [31:0] debug_Write;
    output [31:0] debug_PC;
    
    localparam ADDR_SIZE = 12;
    localparam CACHE_SETS = 16;
    localparam LINE_WORDS = 4;
    localparam MEM_BLOCKS = 256;
    
    wire instrHit;
    wire dataHit;
    wire pipeline_wen;
    
    //
    // Write back phase
    //
    
    wire memBranch;
    wire PCSrcBranchTemp; // anded branch and aluzero
    wire[31:0] memPCAddResultShifted;
    wire[31:0] decodePCJump;
    wire[31:0] exALUResult;
    wire[31:0] memALUResult;
    wire decodeJump;
    wire PCSrc;
    wire wbMemToReg, wbRegWrite;
    wire[31:0] wbMemoryReadData;
    wire[31:0] wbALUResult;
    wire[4:0] wbWriteReg;
    
    // Which data to write back to register (memory or ALU result)
    (* mark_debug = "true" *) wire[31:0] finalWbWriteData;
    wire[31:0] writeDataTempFor0Debug;
    Mux32Bit2To1 wbWriteDataMux(.out(writeDataTempFor0Debug), .inA(wbMemoryReadData), .inB(wbALUResult), .sel(wbMemToReg));
    // Added to make it easier to read the write_data output.
    Mux32Bit2To1 debugWriteData0Mux(.out(finalWbWriteData), .inA(writeDataTempFor0Debug), .inB(32'b0), .sel(wbRegWrite));
    // OLDER - did not show 0 on branch, jump, etc...
    //(* mark_debug = "true" *) wire[31:0] finalWbWriteData;
    //Mux32Bit2To1 wbWriteDataMux(.out(finalWbWriteData), .inA(wbMemoryReadData), .inB(wbALUResult), .sel(wbMemToReg));
    
    //
    // Fetch phase
    //
    
    wire[31:0] fetchPCAddResult;
    (* mark_debug = "true" *) wire[31:0] fetchPCAddr;
    wire[31:0] fetchInstruction;
    wire[31:0] fetchPCInput;
    wire pcShouldWrite;
    
    PCAdder pcAdder(.PCResult(fetchPCAddr), .PCAddResult(fetchPCAddResult));
    // Muxes for branching/jumping
    wire[31:0] jumpBranchPCTemp;
    // Whether we should jump or branch
    Mux32Bit2To1 muxForBranchJump(.out(jumpBranchPCTemp), .inA(memPCAddResultShifted), .inB(decodePCJump), .sel(PCSrcBranchTemp));
    // Whether to use incremented PC result or jump/branch result
    Mux32Bit2To1 progCntMux(.out(fetchPCInput), .inA(jumpBranchPCTemp), .inB(fetchPCAddResult), .sel(PCSrc));
    
    ProgramCounter progCnt(.Address(fetchPCInput), .PCResult(fetchPCAddr), .en(pcShouldWrite), .Reset(Rst), .Clk(Clk));
    // OLD - original from ECE369
    //InstructionMemory instrMemory(.Address(fetchPCAddr), .Instruction(fetchInstruction));
    // Variant 1 - cached
    InstructionMemoryCached #(.ADDR_SIZE(ADDR_SIZE), .CACHE_SETS(CACHE_SETS), .LINE_WORDS(LINE_WORDS), .MEM_BLOCKS(MEM_BLOCKS)) instrMemory(.clk(Clk), .rst(Rst), .r_en(1'b1), .r_addr(fetchPCAddr), .r_data(fetchInstruction), .hit(instrHit));
    // Variant 2 - very slow (no cache, slow memory)
    //InstructionMemorySlow instrMemory(.clk(Clk), .rst(Rst), .r_en(1'b1), .r_addr(fetchPCAddr), .r_data(fetchInstruction), .hit(instrHit));
    // Variant 3 - instant
    //InstructionMemoryFast instrMemory(.clk(Clk), .rst(Rst), .r_en(1'b1), .r_addr(fetchPCAddr), .r_data(fetchInstruction), .hit(instrHit));
    
    //
    // Decode phase
    //
    
    wire[31:0] decodeInstruction;
    wire[31:0] decodePCAddResult;
    wire decodeRegDst, decodeALUSrc, decodeMemToReg, decodeRegWrite, decodeMemRead, decodeMemWrite, decodeBranch, decodeALUShamt;
    wire decodeMemByte, decodeMemHalf, decodeALUBZero, decodeJumpReg, decodeJumpLink;
    wire decodeSignExtend;
    wire[4:0] decodeALUOp;
    wire[31:0] decodeReadData1Direct;
    wire[31:0] decodeReadData2Direct;
    wire[31:0] decodeReadData1;
    wire[31:0] decodeReadData2;
    wire[31:0] decodeSignExtendedImmediate;
    wire [1:0] decodeFwdIFIDRead1;
    wire decodeFwdIFIDRead2;
    
    // Configure jump depending on j or jr
    Mux32Bit2To1 muxPCJumpEx(.out(decodePCJump), .inA(decodeReadData1),
                             .inB({decodePCAddResult[31:28], decodeInstruction[25:0], 2'b00}),
                             .sel(decodeJumpReg));
    
    SignExtension signExtender(.in(decodeInstruction[15:0]), .out(decodeSignExtendedImmediate), .en(decodeSignExtend));
    RegisterFile registerFile(.ReadRegister1(decodeInstruction[25:21]),
                              .ReadRegister2(decodeInstruction[20:16]),
                              .WriteRegister(wbWriteReg),
                              .WriteData(finalWbWriteData),
                              .RegWrite(wbRegWrite),
                              .Clk(Clk),
                              .ReadData1(decodeReadData1Direct),
                              .ReadData2(decodeReadData2Direct));

    // Used to forward register file outputs.
    Mux32Bit4To1 decodeReadData1Mux(.out(decodeReadData1), .inA(decodeReadData1Direct),
                                            .inB(memALUResult), .inC(exALUResult), .inD(finalWbWriteData), .sel(decodeFwdIFIDRead1));
    Mux32Bit2To1 decodeReadData2Mux(.out(decodeReadData2), .inA(finalWbWriteData), .inB(decodeReadData2Direct), .sel(decodeFwdIFIDRead2));

    Control controlUnit(.Op(decodeInstruction[31:26]), .Funct(decodeInstruction[5:0]), .Bit21(decodeInstruction[21]), .Bit16(decodeInstruction[16]),
                        .Bit9(decodeInstruction[9]), .Bit6(decodeInstruction[6]), .RegDst(decodeRegDst), .ALUSrc(decodeALUSrc),
                        .MemToReg(decodeMemToReg), .RegWrite(decodeRegWrite), .MemRead(decodeMemRead), 
                        .MemWrite(decodeMemWrite), .Branch(decodeBranch), .ALUOp(decodeALUOp), .ALUShamt(decodeALUShamt),
                        .signExtend(decodeSignExtend), .MemByte(decodeMemByte), .MemHalf(decodeMemHalf), .ALUBZero(decodeALUBZero),
                        .Jump(decodeJump), .JumpReg(decodeJumpReg), .JumpLink(decodeJumpLink));
    
    //
    // Execute
    //
    
    wire exRegDst, exALUSrc, exMemToReg, exRegWrite, exMemRead, exMemWrite, exBranch, exALUShamt;
    wire exMemByte, exMemHalf, exALUBZero, exJumpLink;
    wire[4:0] exALUOp;
    wire[31:0] exPCAddResult;
    wire[31:0] exReadData1;
    wire[31:0] exReadData2;
    wire[31:0] exSignExtendedImmediate;
    wire[4:0] exInstruction2521; // rs (for R-type)
    wire[4:0] exInstruction2016; // rt (for R-type)
    wire[4:0] exInstruction1511; // rd (for R-type)
    
    // For computing shifted address in branching
    wire[31:0] exPCShiftedBranch;
    ShiftAdder shiftAdder(.pcBase(exPCAddResult), .offset(exSignExtendedImmediate), .outputAddr(exPCShiftedBranch));
    
    // For forwarding
    wire[31:0] exFwdA;
    wire[31:0] exFwdB;
    // Results to give to ALU.
    wire[31:0] exALUInANotJALMuxed;
    wire[31:0] exALUInA;
    wire[31:0] exALUInBNotZeroMuxed;
    wire[31:0] exALUInB;
    // For rt in shifting as operand
    Mux32Bit2To1 muxALUinA(.out(exALUInANotJALMuxed), .inA({27'b0, exSignExtendedImmediate[10:6]}), .inB(exFwdA), .sel(exALUShamt));
    // For JAL
    Mux32Bit2To1 muxALUinAJumpLink(.out(exALUInA), .inA(exPCAddResult), .inB(exALUInANotJALMuxed), .sel(exJumpLink));
    // Configure B for either register or sign extended (final B value later muxed before being sent in)
    Mux32Bit2To1 muxALUinBImm(.out(exALUInBNotZeroMuxed), .inA(exSignExtendedImmediate), .inB(exFwdB), .sel(exALUSrc));
    // For when we need zero for input to B (as is case with some branch instructions)
    Mux32Bit2To1 aluBinZeroMux(.out(exALUInB), .inA(0), .inB(exALUInBNotZeroMuxed), .sel(exALUBZero));
    
    // HiLo register management
    wire[31:0] inHi;
    wire[31:0] inLo;
    (* mark_debug = "true" *) wire[31:0] outHi;
    (* mark_debug = "true" *) wire[31:0] outLo;
    wire hiloWrite;
    wire hiloWriteFinal;
    and(hiloWriteFinal, hiloWrite, ~PCSrcBranchTemp);
    HiLoRegisters hiloReg(.Clk(Clk), .Rst(Rst), .in_Hi(inHi), .in_Lo(inLo), .out_Hi(outHi), .out_Lo(outLo), .write(hiloWriteFinal));
    
    // Calculate ALU results
    wire exALUZero;
    wire exALUMove;
    ALU32Bit alu(.ALUControl(exALUOp), .A(exALUInA), .B(exALUInB),
                 .ALUResult(exALUResult), .Zero(exALUZero), .ALUMove(exALUMove),
                 .in_Hi(outHi), .in_Lo(outLo), .out_Hi(inHi), .out_Lo(inLo), .hiloWrite(hiloWrite));
                 
    wire exRegWriteORed;
    or muxRegWriteMoveORed(exRegWriteORed, exALUMove, exRegWrite);
    
    // To increment the PC add result to PC+8 for JAL.
    // wire[31:0] exPCAddResultPlusFour;
    // PCAdder exPCJALIncrementor(.PCResult(exPCAddResult), .PCAddResult(exPCAddResultPlusFour));
    
    wire[4:0] exMuxWriteRegInter;
    wire[4:0] exMuxWriteReg;
    Mux5Bit2To1 mux5Bit(.out(exMuxWriteRegInter), .inA(exInstruction1511), .inB(exInstruction2016), .sel(exRegDst));
    Mux5Bit2To1 mux5BitJAL(.out(exMuxWriteReg), .inA(5'b11111), .inB(exMuxWriteRegInter), .sel(exJumpLink));
    
    //
    // Memory
    //
    
    // membranch declared above
    wire memMemToReg, memRegWrite, memMemRead, memMemWrite, memALUZero;
    wire memMemByte, memMemHalf;
    wire[31:0] memDataMemWriteData;
    wire[4:0] memMuxWriteReg;
    
    // For determining whether to jump
    and pcSRCBranchAnd(PCSrcBranchTemp, memBranch, memALUZero);
    or pcSRCOr(PCSrc, PCSrcBranchTemp, decodeJump);
    
    // Memory reading/writing
    wire[31:0] memMemoryReadData;
    
    // Old - from ECE369
    // NOTE: we drop support for byte and half word access, but this doesn't matter since it's not used in our programs.
    //DataMemory #(.NUM_BITS_ADDRESS_UPPER(11), .MEMORY_SIZE_WORDS(1024))
    //           dataMemory(.Address(memALUResult), .WriteData(memDataMemWriteData), .Clk(Clk),
    //                      .MemWrite(memMemWrite), .MemRead(memMemRead), .ReadData(memMemoryReadData),
    //                      .MemByte(memMemByte), .MemHalf(memMemHalf));
    
    // Variant 1 - cached
    DataMemoryCached #(.ADDR_SIZE(ADDR_SIZE), .CACHE_SETS(CACHE_SETS), .LINE_WORDS(LINE_WORDS), .MEM_BLOCKS(MEM_BLOCKS)) dataMemory(.clk(Clk), .rst(Rst), .r_en(memMemRead), .w_en(memMemWrite), .addr(memALUResult),
                                .r_data(memMemoryReadData), .w_data(memDataMemWriteData), .hit(dataHit));
    // Variant 2 - very slow (no cache and slow memory)
    //DataMemorySlow dataMemory(.clk(Clk), .rst(Rst), .r_en(memMemRead), .w_en(memMemWrite), .addr(memALUResult),
    //                   .r_data(memMemoryReadData), .w_data(memDataMemWriteData), .hit(dataHit));
    // Variant 3 - instant
    //DataMemoryFast dataMemory(.clk(Clk), .rst(Rst), .r_en(memMemRead), .w_en(memMemWrite), .addr(memALUResult),
    //                          .r_data(memMemoryReadData), .w_data(memDataMemWriteData), .hit(dataHit));
    
    //
    // Forwarding and hazard detection.
    //
                              
    
    // Forwarding
    wire [1:0] forwardingUnitA;
    wire [1:0] forwardingUnitB;
    
    Forwarding forwardingUnit(.mem_wb_RegWrite(wbRegWrite), .ex_mem_RegWrite(memRegWrite), .if_id_JumpReg(decodeJumpReg), .id_ex_RegWrite(exRegWriteORed),
                              .if_id_Read1(decodeInstruction[25:21]), .if_id_Read2(decodeInstruction[20:16]), .id_ex_RegRd(exMuxWriteReg),
                              .ex_mem_RegRd(memMuxWriteReg), .mem_wb_RegRd(wbWriteReg), .id_ex_RegRs(exInstruction2521), .id_ex_RegRt(exInstruction2016),
                              .fwdA(forwardingUnitA), .fwdB(forwardingUnitB), .fwdIFIDRead1(decodeFwdIFIDRead1), .fwdIFIDRead2(decodeFwdIFIDRead2));
    
    // For forwarding with A input
    Mux32Bit3To1 muxForwardALUA(.out(exFwdA), .inA(exReadData1), .inB(finalWbWriteData), .inC(memALUResult), .sel(forwardingUnitA));
    // For forwarding with B input
    Mux32Bit3To1 muxForwardALUB(.out(exFwdB), .inA(exReadData2), .inB(finalWbWriteData), .inC(memALUResult), .sel(forwardingUnitB));   

    // Hazard unit
    wire if_id_Write;
    wire if_id_ControlClear;
    wire id_ex_ControlClear;
    wire ex_mem_ControlClear;
    HazardDetection hazardDetectionUnit(.fetchOp(fetchInstruction[31:26]), .fetchFunct(fetchInstruction[5:0]),
                    .shouldBranch(PCSrcBranchTemp), .shouldJump(decodeJump), .decodeBranch(decodeBranch), .exBranch(exBranch),
                    .instrHit(instrHit), .dataHit(dataHit), .data_ren(memMemRead), .data_wen(memMemWrite), .pipeline_wen(pipeline_wen),
                    .id_ex_MemRead(exMemRead), .if_id_MemRead(decodeMemRead), .ex_mem_MemRead(memMemRead),
                    .if_id_Write(if_id_Write), .pcWrite(pcShouldWrite),
                    .if_id_ControlClear(if_id_ControlClear), .id_ex_ControlClear(id_ex_ControlClear),
                    .ex_mem_ControlClear(ex_mem_ControlClear), .id_ex_RegRt(exInstruction2016),
                    .if_id_RegRs(decodeInstruction[25:21]), .if_id_RegRt(decodeInstruction[20:16]),
                    .ex_mem_RegRd(memMuxWriteReg), .fetchRs(fetchInstruction[25:21]));
                    
    
    // Flushing IF/ID
    // IF/ID
    wire[31:0] fetchHazInstruction;
    Mux32Bit2To1 muxFetchHazardsInstruction(.out(fetchHazInstruction), .inA(32'b0), .inB(fetchInstruction[31:0]), .sel(if_id_ControlClear));
    
    // Flushing ID/EX
    // ID/EX
    wire decodeHazRegDst, decodeHazALUSrc, decodeHazMemToReg, decodeHazRegWrite, decodeHazMemRead;
    wire decodeHazMemWrite, decodeHazBranch, decodeHazALUShamt, decodeHazMemByte, decodeHazMemHalf;
    wire decodeHazALUBZero, decodeHazJumpLink;
    wire [4:0] decodeHazALUOp;
    Mux17Bit2To1 muxDecodeHazards(.out({decodeHazRegDst, decodeHazALUSrc, decodeHazMemToReg, decodeHazRegWrite, decodeHazMemRead,
                                        decodeHazMemWrite, decodeHazBranch, decodeHazALUShamt, decodeHazMemByte, decodeHazMemHalf,
                                        decodeHazALUBZero, decodeHazJumpLink, decodeHazALUOp}),
                                        .inA(17'b0),
                                        .inB({decodeRegDst, decodeALUSrc, decodeMemToReg, decodeRegWrite, decodeMemRead, decodeMemWrite, decodeBranch, decodeALUShamt,
                                        decodeMemByte, decodeMemHalf, decodeALUBZero, decodeJumpLink, decodeALUOp[4:0]}),
                                        .sel(id_ex_ControlClear));
    // Flushing EX/MEM
    // EX/MEM
    wire exHazMemToReg, exHazRegWrite, exHazMemRead, exHazMemWrite;
    wire exHazBranch, exHazALUZero, exHazMemByte, exHazMemHalf;
    Mux8Bit2To1 muxExecuteHazards(.out({exHazMemToReg, exHazRegWrite, exHazMemRead, exHazMemWrite,
                                         exHazBranch, exHazALUZero, exHazMemByte, exHazMemHalf}),
                                   .inA(8'b0),
                                   .inB({exMemToReg, exRegWriteORed, exMemRead, exMemWrite,
                                         exBranch, exALUZero, exMemByte, exMemHalf}),
                                   .sel(ex_mem_ControlClear));
    
    PipelinedRegisters pipelinedReg(Clk, Rst, pipeline_wen, if_id_Write,
            // inputs
            // IF/ID
            {fetchPCAddResult[31:0], fetchHazInstruction[31:0]},
            // ID/EX
            {decodeHazRegDst, decodeHazALUSrc, decodeHazMemToReg, decodeHazRegWrite, decodeHazMemRead, decodeHazMemWrite,
            decodeHazBranch, decodeHazALUShamt, decodeHazMemByte, decodeHazMemHalf, decodeHazALUBZero, decodeHazJumpLink, decodeHazALUOp[4:0],
            decodePCAddResult[31:0], decodeReadData1[31:0], decodeReadData2[31:0], decodeSignExtendedImmediate[31:0],
            decodeInstruction[25:21], decodeInstruction[20:16], decodeInstruction[15:11]},
            // EX/MEM
            {exHazMemToReg, exHazRegWrite, exHazMemRead, exHazMemWrite,
            exHazBranch, exHazALUZero, exHazMemByte, exHazMemHalf,
            exPCShiftedBranch[31:0], exALUResult[31:0], exFwdB[31:0], exMuxWriteReg[4:0]},
            // MEM/WB
            {memMemToReg, memRegWrite,
            memMemoryReadData[31:0], memALUResult[31:0], memMuxWriteReg[4:0]},
            // outputs
            // IF/ID
            {decodePCAddResult[31:0], decodeInstruction[31:0]},
            // ID/EX
            {exRegDst, exALUSrc, exMemToReg, exRegWrite, exMemRead, exMemWrite, exBranch, exALUShamt,
            exMemByte, exMemHalf, exALUBZero, exJumpLink,
            exALUOp[4:0], exPCAddResult[31:0], exReadData1[31:0], exReadData2[31:0], exSignExtendedImmediate[31:0],
            exInstruction2521[4:0], exInstruction2016[4:0], exInstruction1511[4:0]},
            // EX/MEM
            {memMemToReg, memRegWrite, memMemRead, memMemWrite, memBranch, memALUZero,
            memMemByte, memMemHalf,
            memPCAddResultShifted[31:0], memALUResult[31:0], memDataMemWriteData[31:0], memMuxWriteReg[4:0]},
            // MEM/WB
            {wbMemToReg, wbRegWrite, wbMemoryReadData[31:0], wbALUResult[31:0], wbWriteReg[4:0]});
    
    // Assign the debugs.        
    assign debug_Lo = outLo;
    assign debug_Hi = outHi;
    assign debug_PC = fetchPCAddr;
    assign debug_Write = finalWbWriteData;
endmodule
