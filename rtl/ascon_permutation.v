`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2026 02:14:31 PM
// Design Name: 
// Module Name: ascon_permutation
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


module ascon_permutation #(
    parameter MAX_ROUNDS = 12
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [3:0]   rounds,
    input  wire [319:0] state_in,
    output reg  [319:0] state_out,
    output reg          done
);

    reg [319:0] current_state;
    reg [3:0] round_cnt;
    reg [1:0] perm_state;

    localparam P_IDLE = 2'b00;
    localparam P_ROUND = 2'b01;
    localparam P_DONE = 2'b10;

    // Round function wires
    wire [319:0] round_out;
    wire [63:0] round_constant;

    // Instantiate round function
    ascon_round round_inst (
        .state_in(current_state),
        .round_constant(round_constant),
        .state_out(round_out)
    );

    // Round constant generation
    ascon_round_constant rc_gen (
        .round_num(round_cnt),
        .total_rounds(rounds),
        .round_constant(round_constant)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= 320'h0;
            round_cnt <= 4'h0;
            perm_state <= P_IDLE;
            done <= 1'b0;
            state_out <= 320'h0;
        end else begin
            case (perm_state)
                P_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        current_state <= state_in;
                        round_cnt <= 4'h0;
                        perm_state <= P_ROUND;
                    end
                end

                P_ROUND: begin
                    current_state <= round_out;
                    round_cnt <= round_cnt + 1;
                    if (round_cnt == rounds - 1) begin
                        perm_state <= P_DONE;
                        state_out <= round_out;
                        done <= 1'b1;
                    end
                end

                P_DONE: begin
                    perm_state <= P_IDLE;
                    done <= 1'b0;
                end
            endcase
        end
    end

endmodule
