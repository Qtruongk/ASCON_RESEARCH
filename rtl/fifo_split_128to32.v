`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2026 03:41:37 PM
// Design Name: 
// Module Name: fifo_split_128to32
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

module fifo_split_128to32 #(
    parameter FIFO_DEPTH = 16 // S? ph?n t? 32-bit t?i ?a
)(
    input wire clk,
    input wire rst_n,
    input wire [127:0] data_in, // D? li?u 128-bit c?n tách
    input wire load, // Kích ho?t n?p toàn b? data_in
    input wire rd_en, // Kích ho?t ??c FIFO
    input wire mode, // 0 = ch? n?p 64-bit MSB, 1 = n?p ?? 128-bit
    output reg [31:0] data_out, // D? li?u ??c ra
    output wire empty,
    output wire full,
    output reg valid // B?t 1 chu k? khi data_out h?p l?
);
    // =====================================================
    // FIFO memory (32-bit)
    // =====================================================
    reg [31:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH)-1:0] wr_ptr;
    reg [$clog2(FIFO_DEPTH)-1:0] rd_ptr;
    reg [$clog2(FIFO_DEPTH+1)-1:0] fifo_count;
    assign empty = (fifo_count == 0);
    assign full = (fifo_count == FIFO_DEPTH);

    reg [2:0] num_words;
    reg [$clog2(FIFO_DEPTH+1)-1:0] effective_count;

    // =====================================================
    // Single always block for write and read logic
    // =====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
            data_out <= 32'd0;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;
            wr_ptr <= wr_ptr;
            rd_ptr <= rd_ptr;
            fifo_count <= fifo_count;
            data_out <= data_out;

            if (rd_en && (fifo_count > 0)) begin
                data_out <= fifo_mem[rd_ptr];
                valid <= 1'b1;
            if (rd_ptr == FIFO_DEPTH - 1)
                rd_ptr <= 0;
            else
                rd_ptr <= rd_ptr + 1;
                fifo_count <= fifo_count - 1;
            end

            if (load) begin
                num_words = (mode == 1'b0) ? 3'd2 : 3'd4;
                effective_count = fifo_count - ((rd_en && (fifo_count > 0)) ? 1'd1 : 1'd0);
                if (effective_count <= FIFO_DEPTH - num_words) begin
                    fifo_mem[wr_ptr] <= data_in[127:96];
                    fifo_mem[(wr_ptr + 1) % FIFO_DEPTH] <= data_in[95:64];
                    if (num_words == 4) begin
                        fifo_mem[(wr_ptr + 2) % FIFO_DEPTH] <= data_in[63:32];
                        fifo_mem[(wr_ptr + 3) % FIFO_DEPTH] <= data_in[31:0];
                    end
                    if (wr_ptr + num_words >= FIFO_DEPTH)
                        wr_ptr <= (wr_ptr + num_words) - FIFO_DEPTH;
                    else
                        wr_ptr <= wr_ptr + num_words;
                    fifo_count <= effective_count + num_words;
                end
            end
        end
    end
endmodule
