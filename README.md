# 5-Stage Pipelined RISC-V CPU (SV)

32-bit 5-stage pipelined RISC execution core implemented in SystemVerilog. The architecture incorporates synchronous pipeline registers, hazard detection, and an active forwarding network to resolve RAW data dependencies.

## Architecture

The datapath is partitioned into 5 discrete stages:
- **IF (Instruction Fetch):** Program counter generation and word-aligned instruction memory fetch.
- **ID (Instruction Decode):** Instruction decoding, immediate sign-extension, and register file operand fetch.
- **EX (Execute):** ALU arithmetic/logical operations and operand bypass multiplexing.
- **MEM (Memory):** Data memory access stage.
- **WB (Writeback):** Synchronous register file commit.

## Microarchitectural Features

- **Pipeline Registers:** Boundary flip-flops (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) separate each stage to reduce combinational path delays compared to a single-cycle implementation.
- **Operand Forwarding:** Active forwarding unit detects RAW dependencies and routes results directly from `EX/MEM` or `MEM/WB` into the ALU inputs.
- **Hazard Handling:** Load-use hazard detection unit asserts stall signals and flushes the `ID/EX` stage when an instruction depends on a pending memory read.
- **Register Bypassing:** Internal write-through logic prevents same-cycle write-during-read contention (`WB` to `ID`).
- **Zero Register Invariant:** Hardware guarantees writes to `x0` do not trigger invalid forwarding (`rd != 5'd0`).

## File Structure

- `src/`: Modular SystemVerilog source files partitioned by pipeline stage, control logic, and boundary registers.
- `tb/`: Testbench verifying pipeline throughput and back-to-back dependency resolution.
- `sim/`: Waveform capture (`waveform_cpu.png`) and comprehensive simulation execution report.

## Verification

Simulated via EDA Playground (Aldec Riviera-PRO) and Icarus Verilog. The testbench verifies back-to-back dependent arithmetic instructions to validate continuous 1.0 CPI throughput across pipeline stages.
