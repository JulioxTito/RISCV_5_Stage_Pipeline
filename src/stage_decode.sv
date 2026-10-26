`timescale 1ns / 1ps

module stage_decode (
    input  logic        clk, rst,
    input  logic [31:0] instr_in,
    input  logic [4:0]  wb_rd,
    input  logic [31:0] wb_data,
    input  logic        wb_reg_write,

    output logic [4:0]  rs1_out, rs2_out, rd_out,
    output logic [31:0] rdata1_out, rdata2_out, imm_out,
    output logic [2:0]  alu_control_out,
    output logic        reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out, alu_src_out,
    output logic [31:0] probe_reg1
);
    assign rs1_out = instr_in[25:21];
    assign rs2_out = instr_in[20:16];
    assign rd_out  = instr_in[15:11];
    assign imm_out = {{16{instr_in[15]}}, instr_in[15:0]};

    // Decode opcode and funct fields
    always_comb begin
        case (instr_in[31:26])
            6'b000000: begin
                reg_write_out   = (instr_in != 32'b0);
                mem_to_reg_out  = 1'b0;
                mem_read_out    = 1'b0;
                mem_write_out   = 1'b0;
                alu_src_out     = 1'b0;
                alu_control_out = (instr_in[5:0] == 6'b100010) ? 3'b110 : 3'b010;
            end
            default: begin
                reg_write_out   = 1'b0;
                mem_to_reg_out  = 1'b0;
                mem_read_out    = 1'b0;
                mem_write_out   = 1'b0;
                alu_src_out     = 1'b0;
                alu_control_out = 3'b000;
            end
        endcase
    end

    register_file rf (
        .clk(clk),
        .rst(rst),
        .A1(rs1_out),
        .A2(rs2_out),
        .A3(wb_rd),
        .WD3(wb_data),
        .WE3(wb_reg_write),
        .RD1(rdata1_out),
        .RD2(rdata2_out),
        .prode(probe_reg1)
    );
endmodule
