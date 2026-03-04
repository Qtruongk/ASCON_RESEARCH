`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2026 03:40:31 PM
// Design Name: 
// Module Name: fifo_in
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

module fifo_in #(
    parameter FIFO_DEPTH = 8  // có th? thay ??i chi?u sâu FIFO
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  data_in,
    input  wire         wr_en,
    input  wire         rd_en,      // tín hi?u ??c
    input  wire         mode_sel,   // 0 = ch? ?? 1 (4 data), 1 = ch? ?? 2 (2 data + pad)
    output reg  [127:0] data_out,
    output wire         empty,
    output reg          valid
);
    // =====================================================
    // Internal signals
    // =====================================================
    reg [127:0] data_buffer;     // l?u t?m 128-bit
    reg [1:0]   count;           // ??m s? l?n ghi 32-bit
    reg         pack_ready;      // báo khi ?ã gom ?? 128-bit

    // FIFO memory
    reg [127:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH)-1:0]  wr_ptr;
    reg [$clog2(FIFO_DEPTH)-1:0]  rd_ptr;
    reg [$clog2(FIFO_DEPTH+1)-1:0] fifo_count;

    assign empty = (fifo_count == 0);

    // =====================================================
    // Gom d? li?u 32-bit thành 128-bit
    // =====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_buffer <= 128'd0;
            count       <= 2'd0;
            pack_ready  <= 1'b0;
        end else begin
            pack_ready <= 1'b0;
            if (wr_en) begin
                // shift theo big-endian: t? trái sang ph?i
                data_buffer <= {data_buffer[95:0], data_in};
                count <= count + 1;

                // Ki?m tra khi ?? d? li?u ?? n?p vào FIFO
                if ((!mode_sel && count == 2'd3) || (mode_sel && count == 2'd1)) begin
                    pack_ready <= 1'b1;
                    count <= 2'd0;

                    // N?u ch? ?? 2, pad 64-bit zero ? ph?n sau
                    if (mode_sel)
                        data_buffer <= {data_buffer[63:0], data_in, 64'd0};
                    else
                        data_buffer <= {data_buffer[95:0], data_in};
                end
            end
        end
    end

    // =====================================================
    // Ghi vào và ??c ra FIFO (có wrap-around)
    // =====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
            data_out <= 128'd0;
            valid <= 1'b0;
        end else begin
            valid <= 1'b0;
            // ---------- Ghi vào FIFO ----------
            if (pack_ready && fifo_count < FIFO_DEPTH) begin
                fifo_mem[wr_ptr] <= data_buffer;

                // t?ng con tr?, có wrap-around
                if (wr_ptr == FIFO_DEPTH - 1)
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;

                fifo_count <= fifo_count + 1;
            end

            // ---------- ??c ra FIFO ----------
            if (rd_en && fifo_count > 0) begin
                data_out <= fifo_mem[rd_ptr];
                valid <= 1'b1;

                // t?ng con tr?, có wrap-around
                if (rd_ptr == FIFO_DEPTH - 1)
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;

                fifo_count <= fifo_count - 1;
            end
        end
    end

endmodule

