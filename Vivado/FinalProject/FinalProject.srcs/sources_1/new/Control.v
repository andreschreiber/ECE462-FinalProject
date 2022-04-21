`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Implemented in ECE369
//////////////////////////////////////////////////////////////////////////////////

module Control(Op, Funct, Bit21, Bit16, Bit9, Bit6, RegDst, ALUSrc, MemToReg,
               RegWrite, MemRead, MemWrite, Branch, ALUOp, ALUShamt, signExtend,
               MemByte, MemHalf, ALUBZero, Jump, JumpReg, JumpLink);
    input [5:0] Op;
    input [5:0] Funct;
    
    input Bit21; // Differentiate ROTR and SRL
    input Bit16; // Differentiate between BGEZ amd BLTZ
    input Bit9; // Used for seb and seh
    input Bit6; // Used for srlv and rotrv
    output reg RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUShamt, signExtend, MemByte, MemHalf, ALUBZero, Jump, JumpReg, JumpLink;
    output reg[4:0] ALUOp;
    
    always @(*) begin
            if(Op == 6'b000000) begin // R-type
                RegDst <= 1;
                ALUSrc <= 0;
                MemToReg <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                Branch <= 0;
                MemByte <= 0;
                MemHalf <= 0;
                ALUBZero <= 0;
                JumpLink <= 0;
                signExtend <= 1;
                if (Funct == 6'b001000) begin // For jr set jump and jumpreg to 1
                    Jump <= 1;
                    JumpReg <= 1;
                end
                else begin // Set jump and jumpreg to 0 otherwise
                    Jump <= 0;
                    JumpReg <= 0;
                end
                // RegWrite is 0 for mult, multu, movn, movz, mthi, mtlo, and jr
                if (Funct == 6'b011000 || Funct == 6'b011001 ||
                    Funct == 6'b010001 || Funct == 6'b010011 ||
                    Funct == 6'b001011 || Funct == 6'b001010 ||
                    Funct == 6'b001000) begin
                        RegWrite <= 0;
                end
                else begin // RegWrite is 1 otherwise
                    RegWrite <= 1;
                end
                // ALUShamt is 1 for srl, sll, rotr, and sra
                if (Funct == 6'b000000 || Funct == 6'b000010 ||
                    Funct == 6'b000011) begin
                    ALUShamt <= 1;    
                end
                else begin
                    ALUShamt <= 0;
                end
                // Set op codes
                if (Funct == 6'b100000) begin // Add
                    ALUOp <= 0;
                end
                else if(Funct == 6'b100001) begin // Addu
                    ALUOp <= 0;
                end
                else if(Funct == 6'b100010) begin // Sub
                    ALUOp <= 1;
                end
                else if(Funct == 6'b011000) begin // Mult
                    ALUOp <= 3;
                end
                else if(Funct == 6'b011001) begin // Multu
                    ALUOp <= 4;
                end
                else if(Funct == 6'b101010) begin // Slt
                    ALUOp <= 9;
                end
                else if(Funct == 6'b101011) begin // Sltu
                    ALUOp <= 13;
                end
                else if(Funct == 6'b100100) begin // And
                    ALUOp <= 14;
                end
                else if(Funct == 6'b100101) begin // Or
                    ALUOp <= 15;
                end
                else if(Funct == 6'b100111) begin // Nor
                    ALUOp <= 16;
                end
                else if(Funct == 6'b100110) begin // Xor
                    ALUOp <= 17;
                end
                else if(Funct == 6'b000000) begin // Sll
                    ALUOp <= 18;
                end
                else if(Funct == 6'b000100) begin // Sllv
                    ALUOp <= 18;
                end
                else if(Funct == 6'b000010) begin // Srl or rotr
                    if(Bit21 == 1'b0) begin // Sll
                        ALUOp <= 19;
                    end
                    else begin // Rotr
                        ALUOp <= 21;
                    end
                end
                else if(Funct == 6'b000110) begin // Srlv or rotrv
                    if(Bit6 == 1'b0) begin // Srlv
                        ALUOp <= 19;
                    end
                    else begin // Rotrv
                        ALUOp <= 21;
                    end
                end
                else if(Funct == 6'b000011) begin // Sra
                    ALUOp <= 20;
                end
                else if(Funct == 6'b000111) begin // Srav
                    ALUOp <= 20;
                end
                else if(Funct == 6'b010001) begin // Mthi
                    ALUOp <= 22;
                end
                else if(Funct == 6'b010011) begin // Mtlo
                    ALUOp <= 23;
                end
                else if(Funct == 6'b010000) begin // Mfhi
                    ALUOp <= 24;
                end
                else if(Funct == 6'b010010) begin // Mflo
                    ALUOp <= 25;
                end
                else if(Funct == 6'b001011) begin // Movn
                    ALUOp <= 28;
                end
                else if(Funct == 6'b001010) begin // Movz
                    ALUOp <= 29;
                end
                else if(Funct == 6'b001000) begin // jr
                    ALUOp <= 0;
                end
                else begin // Unknown
                    ALUOp <= 0;
                end
            end
            else begin // Not R-type
                // Phase 2
                if(Op == 6'b101011) begin // Store word
                    RegDst <= 0;
                    ALUSrc <= 1;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 1;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b100011) begin // Load Word
                    RegDst <= 0;
                    ALUSrc <= 1;
                    MemToReg <= 1;
                    RegWrite <= 1;
                    MemRead <= 1;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b100000) begin // Load byte
                    RegDst <= 0;
                    ALUSrc <= 1;
                    MemToReg <= 1;
                    RegWrite <= 1;
                    MemRead <= 1;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 1;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b101000) begin // Store byte
                    RegDst <= 0;
                    ALUSrc <= 1;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 1;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 1;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b100001) begin // Load half
                    RegDst <= 0;
                    ALUSrc <= 1;
                    MemToReg <= 1;
                    RegWrite <= 1;
                    MemRead <= 1;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 1;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b101001) begin // Store half
                    RegDst <= 0;
                    ALUSrc <= 1;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 1;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 1;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b001111) begin // Load upper immediate
                    RegDst <= 0;
                    ALUSrc <= 1;
                    MemToReg <= 0;
                    RegWrite <= 1;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUOp <= 30;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b000001) begin
                    if(Bit16 == 1'b1) begin // BGEZ
                        RegDst <= 0;
                        ALUSrc <= 0;
                        MemToReg <= 0;
                        RegWrite <= 0;
                        MemRead <= 0;
                        MemWrite <= 0;
                        Branch <= 1;
                        ALUOp <= 9;
                        ALUShamt <= 0;
                        MemByte <= 0;
                        MemHalf <= 0;
                        ALUBZero <= 1;
                        Jump <= 0;
                        JumpReg <= 0;
                        JumpLink <= 0;
                        signExtend <= 1;
                    end
                    else begin // BLTZ
                        RegDst <= 0;
                        ALUSrc <= 0;
                        MemToReg <= 0;
                        RegWrite <= 0;
                        MemRead <= 0;
                        MemWrite <= 0;
                        Branch <= 1;
                        ALUOp <= 12;
                        ALUShamt <= 0;
                        MemByte <= 0;
                        MemHalf <= 0;
                        ALUBZero <= 1;
                        Jump <= 0;
                        JumpReg <= 0;
                        JumpLink <= 0;
                        signExtend <= 1;
                    end
                end
                else if(Op == 6'b000100) begin // BEQ
                    RegDst <= 0;
                    ALUSrc <= 0;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 1;
                    ALUOp <= 8;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b000101) begin // BNE
                    RegDst <= 0;
                    ALUSrc <= 0;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 1;
                    ALUOp <= 7;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b000111) begin // BGTZ
                    RegDst <= 0;
                    ALUSrc <= 0;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 1;
                    ALUOp <= 10;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 1;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b000110) begin // BLEZ
                    RegDst <= 0;
                    ALUSrc <= 0;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 1;
                    ALUOp <= 11;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 1;
                    Jump <= 0;
                    JumpReg <= 0;
                    JumpLink <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b000010) begin // J
                    RegDst <= 0;
                    ALUSrc <= 0;
                    MemToReg <= 0;
                    RegWrite <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 1;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b000011) begin // JAL
                    RegDst <= 0;
                    ALUSrc <= 0;
                    MemToReg <= 0;
                    RegWrite <= 1;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUOp <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 1;
                    Jump <= 1;
                    JumpReg <= 0;
                    JumpLink <= 1;
                    signExtend <= 1;
                end
                // Phase 1
                else if(Op == 6'b001000) begin // Addi
                    RegDst <= 0;
                    ALUSrc <= 1;
                    RegWrite <= 1;
                    ALUOp <= 0;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 1;
                end    
                else if(Op == 6'b001001) begin // Addiu
                    RegDst <= 0;
                    ALUSrc <= 1;
                    RegWrite <= 1;
                    ALUOp <= 0;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b001010) begin // Slti
                    RegDst <= 0;
                    ALUSrc <= 1;
                    RegWrite <= 1;
                    ALUOp <= 9;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b001011) begin // Sltiu
                    RegDst <= 0;
                    ALUSrc <= 1;
                    RegWrite <= 1;
                    ALUOp <= 13;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 1;
                end
                else if(Op == 6'b001100) begin // Andi
                    RegDst <= 0;
                    ALUSrc <= 1;
                    RegWrite <= 1;
                    ALUOp <= 14;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 0;
                end
                else if(Op == 6'b001101) begin // Ori
                    RegDst <= 0;
                    ALUSrc <= 1;
                    RegWrite <= 1;
                    ALUOp <= 15;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 0;
                end
                else if(Op == 6'b001110) begin // Xori
                    RegDst <= 0;
                    ALUSrc <= 1;
                    RegWrite <= 1;
                    ALUOp <= 17;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 0;
                end
                else if(Op == 6'b011100) begin // Mul, madd, or msub
                    ALUSrc <= 0;
                    RegDst <= 1; // Don't care for cases 2 & 3
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 1;
                    if(Funct == 6'b000010) begin // Mul
                        RegWrite <= 1;
                        ALUOp <= 2;
                    end
                    else if(Funct == 6'b000000) begin // Madd
                        RegWrite <= 0;
                        ALUOp <= 5;
                    end
                    else begin // Msub (6'b000100)
                        RegWrite <= 0;
                        ALUOp <= 6;
                    end
                end
                else if(Op == 6'b011111) begin // Seh or Seb
                    RegDst <= 1;
                    ALUSrc <= 0; // Don't care
                    RegWrite <= 1;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 1;
                    if(Bit9 == 1'b1) begin // Seh
                        ALUOp <= 27;
                    end
                    else begin
                        ALUOp <= 26; // Seb
                    end
                end
                else begin // Unknown
                    RegDst <= 0;
                    ALUSrc <= 0;
                    RegWrite <= 0;
                    MemToReg <= 0;
                    MemRead <= 0;
                    MemWrite <= 0;
                    Branch <= 0;
                    ALUShamt <= 0;
                    MemByte <= 0;
                    MemHalf <= 0;
                    ALUBZero <= 0;
                    Jump <= 0;
                    JumpLink <= 0;
                    JumpReg <= 0;
                    signExtend <= 0;
                    ALUOp <= 0;
                end
            end
    end
endmodule
