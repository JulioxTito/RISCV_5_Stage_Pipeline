
# Verification & Architecture Report: 5-Stage Pipelined RISC Core

This report details the microarchitectural implementation and functional verification of a 32-bit 5-stage pipelined RISC execution processor designed in SystemVerilog. Unlike basic unpipelined or pseudo-pipelined datapaths, this core integrates synchronous boundary registers across all five stages, full EX/MEM and MEM/WB operand forwarding networks, and hardware stall/flush interlocks for load-use hazards.

---

## Architecture Overview

The core decouples execution across 5 isolated stages separated by clocked boundary registers (`reg_if_id`, `reg_id_ex`, `reg_ex_mem`, `reg_mem_wb`):

1. **Instruction Fetch (`stage_fetch.sv`):** Increments the 32-bit Program Counter (`pc + 4`) and fetches aligned instructions from instruction memory. Supports synchronous stall (PC freeze) asserted by the hazard unit.
2. **Instruction Decode (`stage_decode.sv`):** Decodes instruction fields, performs sign-extension for immediate variants, reads dual register operands asynchronously, and interfaces with the hazard detection logic.
3. **Execute (`stage_execute.sv`):** Computes arithmetic/logical operations (`alu.sv`) and integrates 3:1 operand forwarding multiplexers controlled by the active forwarding unit.
4. **Memory Access (`stage_memory.sv`):** Isolates data memory bus transactions from execute timing, preventing combinational critical-path stretching.
5. **Writeback (`stage_writeback.sv`):** Multiplexes between memory load data and ALU execution results, synchronously committing data back to the register file (`register_file.sv`) on the rising clock edge.

---

## Hazard Management & Bypass Microarchitecture

* **Synchronous Boundary Isolation:** Eliminates cumulative datapath delays by breaking the single-cycle critical path into balanced stage intervals, raising maximum attainable clock frequency ($f_{\text{max}}$).
* **RAW Data Hazard Forwarding (`forwarding_unit.sv`):** Detects Read-After-Write register collisions between instructions in flight and steers computed operands directly from `EX/MEM` (`forward = 2'b10`) or `MEM/WB` (`forward = 2'b01`) into the ALU inputs, avoiding pipeline stalls and sustaining near 1.0 CPI on arithmetic streams.
* **Load-Use Hazard Detection (`hazard_unit.sv`):** Identifies when an instruction depends on a pending memory read (`LW`), simultaneously halting PC advancement, freezing the `IF/ID` boundary register, and injecting a synchronous bubble (`flush`) into `ID/EX`.

---

## Functional Verification & Waveform Analysis

Verification was conducted using Aldec Riviera-PRO / ModelSim (`tb/top_tb.sv`). The test sequence evaluates back-to-back dependent arithmetic instructions to stress-test adjacent and multi-stage forwarding paths:

1. **Instruction 0 (`ADD R1 = R2 + R5`):** Computes $2 + 5 = 7$.
2. **Instruction 1 (`SUB R4 = R1 - R3`):** Immediately consumes $R1$ in the consecutive cycle. The forwarding unit activates `forward_a = 2'b10`, pulling `7` directly from the `EX/MEM` boundary register to compute $7 - 3 = 4$ with zero stall cycles.
3. **Instruction 2 (`ADD R6 = R4 + R1`):** Simultaneously requires $R4$ (from `EX/MEM`) and $R1$ (from `MEM/WB`). Dual forwarding paths steer both operands into the ALU at the exact same cycle, calculating $4 + 7 = 11$.

### Verification Waveform

![Simulation Waveform](waveform_proof.png)

### Key Waveform Observations:
* **Pipelined Latency vs. Throughput:** Instruction 0 fetches at $t = 30\,\text{ns}$, reaches Execute at $t = 50\,\text{ns}$, and completes Writeback at $t = 90\,\text{ns}$ (5 cycles latency). Once the pipeline is primed, instructions commit writeback on every consecutive clock edge ($t = 90\,\text{ns}, 110\,\text{ns}, 130\,\text{ns}$).
* **Active Bypass Trace:** At $t = 70\,\text{ns}$, `forward_a` pulses to `2` (`2'b10`), proving immediate bypass of $R1$ into `alu_result_ex = 4`. At $t = 90\,\text{ns}$, `forward_b` asserts to `1` (`2'b01`), verifying multi-stage bypass from Writeback.
* **Register Commit:** Register file probe signal `prode` updates cleanly from initial reset state (`1`) to final computed state (`7`) upon writeback commit.

---

## Testbench Output Log

```text
# KERNEL: ==================================================
# KERNEL: EDA PLAYGROUND VERIFICATION COMPLETE
# KERNEL: R[1] = 7 (Expected: 7)
# KERNEL: R[4] = 4 (Expected: 4) [Forwarded R1]
# KERNEL: R[6] = 11 (Expected: 11) [Forwarded R4 & R1]
# KERNEL: ==================================================
# KERNEL: >>> TEST PASSED: 5-Stage Forwarding Hardware Verified! <<<
# RUNTIME: Info: RUNTIME_0068 testbench.sv (53): $finish called.
# KERNEL: Time: 165 ns, Iteration: 0
