`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2026 03:39:50 PM
// Design Name: 
// Module Name: data_assembler_160
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


module data_assembler_160 (
	input  wire         clk,
	input  wire         rst_n,
	input  wire [31:0]  data_in,
	input  wire         wr_en,
	output reg  [159:0] data_out
);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			data_out <= 160'b0;
		end else if (wr_en) begin
			// D?ch trái 32 bit (lo?i b? word c? nh?t), thêm word m?i vào MSB
			data_out <= {data_out[127:0],data_in};
		end
	end

endmodule
