`timescale 1ns / 1ps

// IF to ID pipeline register
module reg_if_id (
    input  logic        clk, rst, stall, flush,
    input  logic [31:0] pc_in, instr_in,
    output logic [31:0] pc_out, instr_out
);
    always_ff @(posedge clk) begin
        if (rst || flush) begin
            pc_out    <= 32'b0;
            instr_out <= 32'b0;
        end else if (!stall) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule

// ID to EX pipeline register
module reg_id_ex (
    input  logic        clk, rst, flush,
    input  logic        reg_write_in, mem_to_reg_in, mem_read_in, mem_write_in, alu_src_in,
    input  logic [2:0]  alu_control_in,
    input  logic [31:0] rdata1_in, rdata2_in, imm_in,
    input  logic [4:0]  rs1_in, rs2_in, rd_in,
    output logic        reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out, alu_src_out,
    output logic [2:0]  alu_control_out,
    output logic [31:0] rdata1_out, rdata2_out, imm_out,
    output logic [4:0]  rs1_out, rs2_out, rd_out
);
    always_ff @(posedge clk) begin
        if (rst || flush) begin
            reg_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            alu_src_out     <= 1'b0;
            alu_control_out <= 3'b0;
            rdata1_out      <= 32'b0;
            rdata2_out      <= 32'b0;
            imm_out         <= 32'b0;
            rs1_out         <= 5'b0;
            rs2_out         <= 5'b0;
            rd_out          <= 5'b0;
        end else begin
            reg_write_out   <= reg_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            alu_src_out     <= alu_src_in;
            alu_control_out <= alu_control_in;
            rdata1_out      <= rdata1_in;
            rdata2_out      <= rdata2_in;
            imm_out         <= imm_in;
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;
        end
    end
endmodule

// EX to MEM pipeline register
module reg_ex_mem (
    input  logic        clk, rst,
    input  logic        reg_write_in, mem_to_reg_in, mem_read_in, mem_write_in,
    input  logic [31:0] alu_result_in, write_data_in,
    input  logic [4:0]  rd_in,
    output logic        reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out,
    output logic [31:0] alu_result_out, write_data_out,
    output logic [4:0]  rd_out
);
    always_ff @(posedge clk) begin
        if (rst) begin
            reg_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            alu_result_out  <= 32'b0;
            write_data_out  <= 32'b0;
            rd_out          <= 5'b0;
        end else begin
            reg_write_out   <= reg_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            alu_result_out  <= alu_result_in;
            write_data_out  <= write_data_in;
            rd_out          <= rd_in;
        end
    end
endmodule

// MEM to WB pipeline register
module reg_mem_wb (
    input  logic        clk, rst,
    input  logic        reg_write_in, mem_to_reg_in,
    input  logic [31:0] mem_rdata_in, alu_result_in,
    input  logic [4:0]  rd_in,
    output logic        reg_write_out, mem_to_reg_out,
    output logic [31:0] mem_rdata_out, alu_result_out,
    output logic [4:0]  rd_out
);
    always_ff @(posedge clk) begin
        if (rst) begin
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_rdata_out  <= 32'b0;
            alu_result_out <= 32'b0;
            rd_out         <= 5'b0;
        end else begin
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_rdata_out  <= mem_rdata_in;
            alu_result_out <= alu_result_in;
            rd_out         <= rd_in;
        end
    end
endmodule
