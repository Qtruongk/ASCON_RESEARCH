`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 10:50:45 AM
// Design Name: 
// Module Name: ascon_sbox
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ascon_sbox (
    input  wire [63:0] x0_in, x1_in, x2_in, x3_in, x4_in,
    output wire [63:0] x0_out, x1_out, x2_out, x3_out, x4_out
);

    // Bitsliced S-box implementation
    // S-box: 4,11,31,20,26,21,9,2,27,5,8,18,29,3,6,28,30,19,7,14,0,13,17,24,16,12,1,25,22,10,15,23
    // This is implemented using Boolean functions for efficiency
    wire [63:0] x0, x1, x2, x3, x4;
    assign x0 = x0_in ^ x4_in;
    assign x4 = x4_in ^ x3_in;
    assign x2 = x2_in ^ x1_in;
    assign x1 = x1_in;
    assign x3 = x3_in;

    // Nonlinear layer (5 AND operations)
    wire [63:0] t0 = ~x0 & x1;
    wire [63:0] t1 = ~x1 & x2;
    wire [63:0] t2 = ~x2 & x3;
    wire [63:0] t3 = ~x3 & x4;
    wire [63:0] t4 = ~x4 & x0;

    wire [63:0] y0 = x0 ^ t1;
    wire [63:0] y1 = x1 ^ t2;
    wire [63:0] y2 = x2 ^ t3;
    wire [63:0] y3 = x3 ^ t4;
    wire [63:0] y4 = x4 ^ t0;

    // Linear post-processing
    assign x0_out = y0 ^ y4;
    assign x1_out = y0 ^ y1;
    assign x2_out = ~y2;
    assign x3_out = y2 ^ y3;
    assign x4_out = y4;

endmodule
