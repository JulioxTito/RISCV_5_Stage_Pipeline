`timescale 1ns / 1ps

module hazard_unit (
    input  logic       id_ex_mem_read,
    input  logic [4:0] id_ex_rd,
    input  logic [4:0] if_id_rs1, if_id_rs2,
    output logic       pc_write, if_id_write, id_ex_flush
);
    always_comb begin
        pc_write    = 1'b1;
        if_id_write = 1'b1;
        id_ex_flush = 1'b0;

        // Detect load-use dependency and inject bubble
        if (id_ex_mem_read && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)) && (id_ex_rd != 5'd0)) begin
            pc_write    = 1'b0;
            if_id_write = 1'b0;
            id_ex_flush = 1'b1;
        end
    end
endmodule
