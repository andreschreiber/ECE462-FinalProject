//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module ALU32Bit(ALUControl, A, B, ALUResult, Zero, ALUMove, in_Hi, in_Lo, out_Hi, out_Lo, hiloWrite);

	input [4:0] ALUControl; // control bits for ALU operation
                                // you need to adjust the bitwidth as needed
	input [31:0] A, B;	    // inputs

	output reg [31:0] ALUResult;	// answer
	output reg ALUMove;
	input [31:0] in_Hi;
	input [31:0] in_Lo;
	
	output reg [31:0] out_Hi;
	output reg [31:0] out_Lo;
	output reg hiloWrite;
	output reg Zero;	    // Zero=1 if ALUResult == 0
    reg[63:0] temp;

    always @(*) begin
        case (ALUControl)
            0: begin // Add
                ALUResult = A + B;
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            1: begin // Sub
                ALUResult = A - B;
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            2: begin // Mul
                {out_Hi, out_Lo} = $signed(A)*$signed(B);
                ALUResult = out_Lo;
                ALUMove = 1'b0;
                hiloWrite = 1'b1;
            end
            3: begin // Mult 
                {out_Hi, out_Lo} = $signed(A)*$signed(B);
                ALUResult = 0;
                ALUMove = 1'b0;
                hiloWrite = 1'b1;
            end
            4: begin // Mult unsigned
                {out_Hi, out_Lo} = A * B;
                ALUResult = 0;
                ALUMove = 1'b0;
                hiloWrite = 1'b1;
            end
            5: begin // MAdd
                temp = $signed(A) * $signed(B);
                temp = {in_Hi, in_Lo} + $signed(temp);
                {out_Hi, out_Lo} = temp;
                ALUResult = 0;
                ALUMove = 1'b0;
                hiloWrite = 1'b1;
            end
            6: begin // MSub
                temp = $signed(A) * $signed(B);
                temp = {in_Hi, in_Lo} - $signed(temp);
                {out_Hi, out_Lo} = temp;
                ALUResult = 0;
                ALUMove = 1'b0;
                hiloWrite = 1'b1;
            end
            7: begin // Equal
                ALUResult = (A == B);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            8: begin // Not equal
                ALUResult = (A != B);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            9: begin // Signed less than
                ALUResult = ($signed(A) < $signed(B));
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            10: begin // Signed less than or equal to
                ALUResult = ($signed(A) < $signed(B)) | ($signed(A) == $signed(B));
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            11: begin // Signed greater than
                ALUResult = ($signed(A) > $signed(B));
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            12: begin // Signed greater than or equal to
                ALUResult = ($signed(A) > $signed(B)) | ($signed(A) == $signed(B));
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            13: begin // Unsigned less than
                ALUResult = (A < B);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            14: begin // And
                ALUResult = (A & B);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            15: begin // Or
                ALUResult = (A | B);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            16: begin // Nor
                ALUResult = ~(A | B);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            17: begin // Xor
                ALUResult = (A ^ B);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            18: begin // Sll
                ALUResult = (B << A);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            19: begin // Srl
                ALUResult = (B >> A);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            20: begin // Sra
                ALUResult = ($signed(B) >>> A);
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            21: begin // Rotr
                ALUResult = ((B >> A) | (B << (32 - A)));
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            22: begin // Move to hi
                out_Hi = A;
                out_Lo = in_Lo;
                ALUResult = 0;
                hiloWrite = 1'b1;
                ALUMove = 1'b0;
            end
            23: begin // Move to lo
                out_Lo = A;
                out_Hi = in_Hi;
                ALUResult = 0;
                hiloWrite = 1'b1;
                ALUMove = 1'b0;
            end
            24: begin // Move from hi
                ALUResult = in_Hi;
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            25: begin // Move from lo
                ALUResult = in_Lo;
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            26: begin // Sign extend B as byte
                ALUResult = { {24{B[7]}}, B[7:0]};
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            27: begin // Sign extend B as half-word
                ALUResult = { {16{B[15]}}, B[15:0] } ; 
                ALUMove = 1'b0;
                hiloWrite = 1'b0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            28: begin // Movn
                hiloWrite = 1'b0;
                ALUResult = A;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
                if(B != 0) begin
                    ALUMove = 1'b1;
                end
                else begin
                    ALUMove = 1'b0;
                end
            end
            29: begin // Movz
                hiloWrite = 1'b0;
                ALUResult = A;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
                if(B == 0) begin
                    ALUMove = 1'b1; 
                end
                else begin
                    ALUMove = 1'b0;
                end
            end
            30: begin // Lui
                hiloWrite = 1'b0;
                ALUMove = 1'b0;
                ALUResult = {B[15:0], 16'h0000};
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
            default: begin
                hiloWrite = 1'b0;
                ALUMove = 1'b0;
                ALUResult = 0;
                out_Hi = in_Hi;
                out_Lo = in_Lo;
            end
        endcase
        if (ALUResult == 0) begin
            Zero = 1'b1;
        end
        else begin
            Zero = 1'b0;
        end
    end

endmodule
