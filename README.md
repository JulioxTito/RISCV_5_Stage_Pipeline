# 5-Stage Pipelined RISC Processor

32-bit 5-stage pipelined RISC execution core implemented in SystemVerilog. The architecture incorporates synchronous pipeline registers, hazard detection, and an active forwarding network to resolve RAW data dependencies.

## Architecture

The datapath is partitioned into 5 discrete stages:
* **IF (Instruction Fetch):** Program counter generation and word-aligned instruction memory fetch.
* **ID (Instruction Decode):** Instruction decoding, immediate sign-extension, and register file read.
* **EX (Execute):** ALU arithmetic/logical operations and operand bypass multiplexing.
* **MEM (Memory):** Data memory access stage.
* **WB (Writeback):** Register file commit.

## Microarchitectural Features

* **Pipeline Registers:** Boundary flip-flops (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) separate each stage to reduce combinational path delays compared to a single-cycle implementation.
* **Operand Forwarding:** Forwarding unit detects RAW dependencies and routes results directly from `EX/MEM` or `MEM/WB` into the ALU inputs.
* **Hazard Handling:** Load-use hazard detection unit asserts stall signals and flushes the `ID/EX` stage when an instruction depends on a pending memory read.

## Verification

Simulated with ModelSim / Icarus Verilog using `tb/top_tb.sv`. The testbench runs back-to-back dependent arithmetic instructions to verify correct forwarding operation across pipeline stages.
