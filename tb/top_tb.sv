`timescale 1ns / 1ps

module top_tb;
    logic clk;
    logic rst;
    logic [31:0] probe_reg1;

    riscv_top dut (
        .clk(clk),
        .rst(rst),
        .probe_reg1(probe_reg1)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("waveform_pipeline.vcd");
        $dumpvars(0, top_tb);

        clk = 0;
        rst = 1;

        // Test instructions:
        // 0: ADD R1 = R2 + R5   (2 + 5 = 7)
        // 1: SUB R4 = R1 - R3   (7 - 3 = 4, forwarded R1)
        // 2: ADD R6 = R4 + R1   (4 + 7 = 11, forwarded R4 and R1)
        dut.u_fetch.instr_mem[0] = {6'b000000, 5'd2, 5'd5, 5'd1, 5'd0, 6'b100000};
        dut.u_fetch.instr_mem[1] = {6'b000000, 5'd1, 5'd3, 5'd4, 5'd0, 6'b100010};
        dut.u_fetch.instr_mem[2] = {6'b000000, 5'd4, 5'd1, 5'd6, 5'd0, 6'b100000};

        for (int i = 3; i < 32; i++) dut.u_fetch.instr_mem[i] = 32'd0;

        #25;
        rst = 0;

        #140;

        $display("R[1] = %0d (Expected: 7)", dut.u_decode.rf.R[1]);
        $display("R[4] = %0d (Expected: 4)", dut.u_decode.rf.R[4]);
        $display("R[6] = %0d (Expected: 11)", dut.u_decode.rf.R[6]);

        if (dut.u_decode.rf.R[1] == 7 && dut.u_decode.rf.R[4] == 4 && dut.u_decode.rf.R[6] == 11)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
