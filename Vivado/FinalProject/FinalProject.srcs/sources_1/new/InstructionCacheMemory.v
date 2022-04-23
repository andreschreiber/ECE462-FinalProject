`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Arizona
// Engineer: Andre Schreiber
// 
// Create Date: 03/06/2022 10:52:23 AM
// Implemented for ECE462
//////////////////////////////////////////////////////////////////////////////////


module InstructionCacheMemory(
        clk,
        addr,
        r_en,
        r_data,
        e_en,
        e_data,
        hit
    );
    
    parameter ADDR_SIZE = 12;
    parameter CACHE_SETS = 16;
    parameter LINE_WORDS = 4;
    localparam SET_WAYS = 2;
    
    input clk;
    input [ADDR_SIZE-1:0] addr;
    input r_en;
    input e_en;
    input [(32*LINE_WORDS)-1:0] e_data;
    output reg [31:0] r_data;
    output reg hit;
    
    reg lru[0:CACHE_SETS-1];
    reg valid[0:CACHE_SETS-1][0:SET_WAYS-1];
    reg [4:0] tag[0:CACHE_SETS-1][0:SET_WAYS-1];
    reg [31:0] cache[0:CACHE_SETS-1][0:SET_WAYS-1][0:LINE_WORDS-1];
    
    // we want to make sure all blocks invalid at start (cold cache)
    integer i;
    integer k;
    initial begin
        for(i = 0; i < CACHE_SETS; i = i + 1) begin
            for(k = 0; k < SET_WAYS; k = k + 1) begin
                valid[i][k] = 1'b0;
                lru[i] = 1'b0;
            end
        end
    end
    

    // 7:4 = (($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)
    // 8 = ($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)
    // Read
    always @(*) begin
        if(r_en && valid[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][0] && tag[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][0] == addr[ADDR_SIZE-1:($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)]) begin
            hit <= 1'b1;
            r_data <= cache[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][0][addr[($clog2(LINE_WORDS)+1):2]];
            lru[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]] <= 1'b1;
        end
        else if(r_en && valid[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][1] && tag[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][1] == addr[ADDR_SIZE-1:($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)]) begin
            hit <= 1'b1;
            r_data <= cache[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][1][addr[($clog2(LINE_WORDS)+1):2]];
            lru[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]] <= 1'b0;
        end
        else begin
            hit <= 1'b0;
            r_data <= 32'hXXXXXXXX;
            lru[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]] <= lru[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]];
        end
    end
    
    integer j;
    // Evict
    always @(posedge clk) begin
        if(e_en) begin
            case(lru[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]])
                1'b1: begin
                    for(j = LINE_WORDS-1; j >= 0; j = j - 1) begin
                        cache[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][1][j] <= e_data[j*32 +: 32];
                    end
                    tag[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][1] <= addr[ADDR_SIZE-1:($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)];
                    valid[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][1] <= 1'b1;
                end
                default: begin // 1'b0
                    for(j = LINE_WORDS-1; j >= 0; j = j - 1) begin
                        cache[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][0][j] <= e_data[j*32 +: 32];
                    end
                    tag[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][0] <= addr[ADDR_SIZE-1:($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)];
                    valid[addr[(($clog2(CACHE_SETS)+$clog2(LINE_WORDS)+2)-1):($clog2(LINE_WORDS)+2)]][0] <= 1'b1;
                end
            endcase
        end
    end
endmodule