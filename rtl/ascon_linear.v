`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 10:51:21 AM
// Design Name: 
// Module Name: ascon_linear
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

module ascon_linear (
    input  wire [63:0] x0_in, x1_in, x2_in, x3_in, x4_in,
    output wire [63:0] x0_out, x1_out, x2_out, x3_out, x4_out
);

    // Linear diffusion functions as specified in ASCON
    // ?0(x0) = x0 ? (x0 >>> 19) ? (x0 >>> 28)
    // ?1(x1) = x1 ? (x1 >>> 61) ? (x1 >>> 39)  
    // ?2(x2) = x2 ? (x2 >>> 1)  ? (x2 >>> 6)
    // ?3(x3) = x3 ? (x3 >>> 10) ? (x3 >>> 17)
    // ?4(x4) = x4 ? (x4 >>> 7)  ? (x4 >>> 41)

    function [63:0] rotr64;
        input [63:0] value;
        input [5:0] amount;
        begin
            rotr64 = (value >> amount) | (value << (64 - amount));
        end
    endfunction

    assign x0_out = x0_in ^ rotr64(x0_in, 19) ^ rotr64(x0_in, 28);
    assign x1_out = x1_in ^ rotr64(x1_in, 61) ^ rotr64(x1_in, 39);
    assign x2_out = x2_in ^ rotr64(x2_in, 1)  ^ rotr64(x2_in, 6);
    assign x3_out = x3_in ^ rotr64(x3_in, 10) ^ rotr64(x3_in, 17);
    assign x4_out = x4_in ^ rotr64(x4_in, 7)  ^ rotr64(x4_in, 41);

endmodule
