`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 11:40:58 AM
// Design Name: 
// Module Name: ascon_round
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

module ascon_round (
    input  wire [319:0] state_in,
    input  wire [63:0]  round_constant,
    output wire [319:0] state_out
);

    // State word extraction
    wire [63:0] x0_in = state_in[319:256];
    wire [63:0] x1_in = state_in[255:192];
    wire [63:0] x2_in = state_in[191:128];
    wire [63:0] x3_in = state_in[127:64];
    wire [63:0] x4_in = state_in[63:0];

    // After constant addition
    wire [63:0] x0_c = x0_in;
    wire [63:0] x1_c = x1_in;
    wire [63:0] x2_c = x2_in ^ round_constant;
    wire [63:0] x3_c = x3_in;
    wire [63:0] x4_c = x4_in;

    // After substitution layer
    wire [63:0] x0_s, x1_s, x2_s, x3_s, x4_s;

    ascon_sbox sbox_inst (
        .x0_in(x0_c), .x1_in(x1_c), .x2_in(x2_c), 
        .x3_in(x3_c), .x4_in(x4_c),
        .x0_out(x0_s), .x1_out(x1_s), .x2_out(x2_s),
        .x3_out(x3_s), .x4_out(x4_s)
    );

    // After linear diffusion layer
    wire [63:0] x0_l, x1_l, x2_l, x3_l, x4_l;

    ascon_linear linear_inst (
        .x0_in(x0_s), .x1_in(x1_s), .x2_in(x2_s),
        .x3_in(x3_s), .x4_in(x4_s),
        .x0_out(x0_l), .x1_out(x1_l), .x2_out(x2_l),
        .x3_out(x3_l), .x4_out(x4_l)
    );

    // Output state assembly
    assign state_out = {x0_l, x1_l, x2_l, x3_l, x4_l};

endmodule
