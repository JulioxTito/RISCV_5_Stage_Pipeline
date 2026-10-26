`timescale 1ns / 1ps

module register_file (
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  A1, A2, A3,      // rs1, rs2, rd
    input  logic [31:0] WD3,             // write data
    input  logic        WE3,             // write enable
    output logic [31:0] RD1, RD2,        // read data
    output logic [31:0] prode            // probe output
);
    logic [31:0] R [0:31];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) R[i] <= i;
        end else if (WE3 && (A3 != 5'd0)) begin
            R[A3] <= WD3;
        end
    end

    // Asynchronous read ports (Register 0 hardwired to 0)
    assign RD1   = (A1 == 5'd0) ? 32'd0 : R[A1];
    assign RD2   = (A2 == 5'd0) ? 32'd0 : R[A2];
    assign prode = R[1];
endmodule
