`timescale 1ns / 1ps

module riscv_top (
    input  logic        clk,
    input  logic        rst,
    output logic [31:0] probe_reg1
);
    logic pc_write, if_id_write, id_ex_flush;
    logic [1:0] forward_a, forward_b;

    // 1. Fetch Stage
    logic [31:0] if_pc, if_instr;
    stage_fetch u_fetch (
        .clk(clk), .rst(rst),
        .pc_write(pc_write),
        .pc_out(if_pc), .instr_out(if_instr)
    );

    // IF/ID Register
    logic [31:0] id_pc, id_instr;
    reg_if_id r_if_id (
        .clk(clk), .rst(rst),
        .stall(!if_id_write), .flush(1'b0),
        .pc_in(if_pc), .instr_in(if_instr),
        .pc_out(id_pc), .instr_out(id_instr)
    );

    // 2. Decode Stage
    logic [4:0]  id_rs1, id_rs2, id_rd;
    logic [31:0] id_rdata1, id_rdata2, id_imm;
    logic [2:0]  id_alu_ctrl;
    logic        id_reg_write, id_mem_to_reg, id_mem_read, id_mem_write, id_alu_src;
    logic [4:0]  wb_rd;
    logic [31:0] wb_data;
    logic        wb_reg_write;

    stage_decode u_decode (
        .clk(clk), .rst(rst),
        .instr_in(id_instr),
        .wb_rd(wb_rd), .wb_data(wb_data), .wb_reg_write(wb_reg_write),
        .rs1_out(id_rs1), .rs2_out(id_rs2), .rd_out(id_rd),
        .rdata1_out(id_rdata1), .rdata2_out(id_rdata2), .imm_out(id_imm),
        .alu_control_out(id_alu_ctrl),
        .reg_write_out(id_reg_write), .mem_to_reg_out(id_mem_to_reg),
        .mem_read_out(id_mem_read), .mem_write_out(id_mem_write),
        .alu_src_out(id_alu_src),
        .probe_reg1(probe_reg1)
    );

    // Hazard Detection Unit
    logic [4:0] ex_rd;
    logic       ex_mem_read;
    hazard_unit u_hazard (
        .id_ex_mem_read(ex_mem_read), .id_ex_rd(ex_rd),
        .if_id_rs1(id_rs1), .if_id_rs2(id_rs2),
        .pc_write(pc_write), .if_id_write(if_id_write), .id_ex_flush(id_ex_flush)
    );

    // ID/EX Register
    logic        ex_reg_write, ex_mem_to_reg, ex_mem_write, ex_alu_src;
    logic [2:0]  ex_alu_ctrl;
    logic [31:0] ex_rdata1, ex_rdata2, ex_imm;
    logic [4:0]  ex_rs1, ex_rs2;

    reg_id_ex r_id_ex (
        .clk(clk), .rst(rst), .flush(id_ex_flush),
        .reg_write_in(id_reg_write), .mem_to_reg_in(id_mem_to_reg),
        .mem_read_in(id_mem_read), .mem_write_in(id_mem_write),
        .alu_control_in(id_alu_ctrl), .alu_src_in(id_alu_src),
        .rdata1_in(id_rdata1), .rdata2_in(id_rdata2), .imm_in(id_imm),
        .rs1_in(id_rs1), .rs2_in(id_rs2), .rd_in(id_rd),
        .reg_write_out(ex_reg_write), .mem_to_reg_out(ex_mem_to_reg),
        .mem_read_out(ex_mem_read), .mem_write_out(ex_mem_write),
        .alu_control_out(ex_alu_ctrl), .alu_src_out(ex_alu_src),
        .rdata1_out(ex_rdata1), .rdata2_out(ex_rdata2), .imm_out(ex_imm),
        .rs1_out(ex_rs1), .rs2_out(ex_rs2), .rd_out(ex_rd)
    );

    // 3. Execute Stage
    logic [31:0] ex_alu_res, ex_wr_data;
    logic [31:0] mem_alu_res;

    stage_execute u_execute (
        .rdata1(ex_rdata1), .rdata2(ex_rdata2), .imm(ex_imm),
        .forward_a(forward_a), .forward_b(forward_b),
        .ex_mem_data(mem_alu_res), .wb_data(wb_data),
        .alu_src(ex_alu_src), .alu_control(ex_alu_ctrl),
        .alu_result(ex_alu_res), .write_data_mem(ex_wr_data)
    );

    // Forwarding Unit
    logic [4:0] mem_rd;
    logic       mem_reg_write;
    forwarding_unit u_forward (
        .id_ex_rs1(ex_rs1), .id_ex_rs2(ex_rs2),
        .ex_mem_rd(mem_rd), .ex_mem_reg_write(mem_reg_write),
        .mem_wb_rd(wb_rd), .mem_wb_reg_write(wb_reg_write),
        .forward_a(forward_a), .forward_b(forward_b)
    );

    // EX/MEM Register
    logic mem_to_reg_m, mem_read_m, mem_write_m;
    logic [31:0] mem_wr_data;

    reg_ex_mem r_ex_mem (
        .clk(clk), .rst(rst),
        .reg_write_in(ex_reg_write), .mem_to_reg_in(ex_mem_to_reg),
        .mem_read_in(ex_mem_read), .mem_write_in(ex_mem_write),
        .alu_result_in(ex_alu_res), .write_data_in(ex_wr_data), .rd_in(ex_rd),
        .reg_write_out(mem_reg_write), .mem_to_reg_out(mem_to_reg_m),
        .mem_read_out(mem_read_m), .mem_write_out(mem_write_m),
        .alu_result_out(mem_alu_res), .write_data_out(mem_wr_data), .rd_out(mem_rd)
    );

    // 4. Memory Stage
    logic [31:0] mem_rdata, mem_alu_res_stage;
    stage_memory u_memory (
        .alu_result_in(mem_alu_res), .write_data_in(mem_wr_data),
        .mem_read(mem_read_m), .mem_write(mem_write_m),
        .mem_rdata_out(mem_rdata), .alu_result_out(mem_alu_res_stage)
    );

    // MEM/WB Register
    logic [31:0] wb_mem_rdata, wb_alu_res;
    logic        wb_mem_to_reg;

    reg_mem_wb r_mem_wb (
        .clk(clk), .rst(rst),
        .reg_write_in(mem_reg_write), .mem_to_reg_in(mem_to_reg_m),
        .mem_rdata_in(mem_rdata), .alu_result_in(mem_alu_res_stage), .rd_in(mem_rd),
        .reg_write_out(wb_reg_write), .mem_to_reg_out(wb_mem_to_reg),
        .mem_rdata_out(wb_mem_rdata), .alu_result_out(wb_alu_res), .rd_out(wb_rd)
    );

    // 5. Writeback Stage
    stage_writeback u_writeback (
        .alu_result(wb_alu_res),
        .mem_rdata(wb_mem_rdata),
        .mem_to_reg(wb_mem_to_reg),
        .wb_data(wb_data)
    );
endmodule
