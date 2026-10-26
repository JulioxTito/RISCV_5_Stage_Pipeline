`timescale 1ns / 1ps

module stage_writeback (
    input  logic [31:0] alu_result,
    input  logic [31:0] mem_rdata,
    input  logic        mem_to_reg,
    output logic [31:0] wb_data
);
    assign wb_data = (mem_to_reg) ? mem_rdata : alu_result;
endmodule
