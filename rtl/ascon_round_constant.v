`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 10:29:32 AM
// Design Name: 
// Module Name: ascon_round_constant
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

module ascon_round_constant (
    input  wire [3:0] round_num,
    input  wire [3:0] total_rounds,
    output reg  [63:0] round_constant
);

    wire [3:0] rc_index;
    assign rc_index = (total_rounds == 12) ? round_num :
                     (total_rounds == 8)  ? round_num + 4 :
                     (total_rounds == 6)  ? round_num + 6 : round_num;

    always @(*) begin
        case (rc_index)
            4'h0: round_constant = 64'h00000000000000f0;
            4'h1: round_constant = 64'h00000000000000e1;
            4'h2: round_constant = 64'h00000000000000d2;
            4'h3: round_constant = 64'h00000000000000c3;
            4'h4: round_constant = 64'h00000000000000b4;
            4'h5: round_constant = 64'h00000000000000a5;
            4'h6: round_constant = 64'h0000000000000096;
            4'h7: round_constant = 64'h0000000000000087;
            4'h8: round_constant = 64'h0000000000000078;
            4'h9: round_constant = 64'h0000000000000069;
            4'ha: round_constant = 64'h000000000000005a;
            4'hb: round_constant = 64'h000000000000004b;
            default: round_constant = 64'h0000000000000000;
        endcase
    end

endmodule