`timescale 1ns / 1ps

module stage_memory (
    input  logic [31:0] alu_result_in,
    input  logic [31:0] write_data_in,
    input  logic        mem_read,
    input  logic        mem_write,
    output logic [31:0] mem_rdata_out,
    output logic [31:0] alu_result_out
);
    assign alu_result_out = alu_result_in;
    assign mem_rdata_out  = 32'd0;
endmodule
