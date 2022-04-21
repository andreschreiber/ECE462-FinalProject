`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Implemented in ECE369
////////////////////////////////////////////////////////////////////////////////

module SignExtension(in, out, en);

    /* A 16-Bit input word */
    input [15:0] in;
    input en;
    
    /* A 32-Bit output word */
    output reg [31:0] out;
    
    /* Fill in the implementation here ... */
    
    always @(*) begin
        if(en == 1'b0) begin
            out <= {16'h0000, in[15:0]};
        end
        else begin
            if(in[15] == 1'b1) begin
                out <= {16'hFFFF, in[15:0]};
            end
            else begin
                out <= {16'h0000, in[15:0]};
            end
        end
    end

endmodule
