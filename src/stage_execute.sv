`timescale 1ns / 1ps

module stage_execute (
    input  logic [31:0] rdata1, rdata2, imm,
    input  logic [1:0]  forward_a, forward_b,
    input  logic [31:0] ex_mem_data, wb_data,
    input  logic        alu_src,
    input  logic [2:0]  alu_control,

    output logic [31:0] alu_result,
    output logic [31:0] write_data_mem
);
    logic [31:0] op_a, op_b_pre, op_b;

    // Operand A forwarding select
    always_comb begin
        case (forward_a)
            2'b10:   op_a = ex_mem_data;
            2'b01:   op_a = wb_data;
            default: op_a = rdata1;
        endcase
    end

    // Operand B forwarding select
    always_comb begin
        case (forward_b)
            2'b10:   op_b_pre = ex_mem_data;
            2'b01:   op_b_pre = wb_data;
            default: op_b_pre = rdata2;
        endcase
    end

    assign write_data_mem = op_b_pre;
    assign op_b           = (alu_src) ? imm : op_b_pre;

    alu alu_inst (
        .SrcA(op_a),
        .SrcB(op_b),
        .ALUControl(alu_control),
        .ALUResult(alu_result)
    );
endmodule
