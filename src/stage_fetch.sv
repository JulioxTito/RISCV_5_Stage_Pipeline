`timescale 1ns / 1ps

module stage_fetch (
    input  logic        clk, rst,
    input  logic        pc_write,
    output logic [31:0] pc_out,
    output logic [31:0] instr_out
);
    logic [31:0] pc;
    logic [31:0] instr_mem [0:31];

    always_ff @(posedge clk) begin
        if (rst) pc <= 32'd0;
        else if (pc_write) pc <= pc + 32'd4;
    end

    assign pc_out    = pc;
    assign instr_out = instr_mem[pc[6:2]];
endmodule
