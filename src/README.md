# Source RTL Architecture

This directory contains the synthesizable SystemVerilog modules implementing the 5-stage pipelined RISC core.

### Module Breakdown

| Module | File | Description |
| :--- | :--- | :--- |
| **Top-Level** | `riscv_top.sv` | Top-level netlist integrating pipeline stages, registers, and hazard units. |
| **Fetch** | `stage_fetch.sv` | Program Counter generation and instruction memory interface. |
| **Decode** | `stage_decode.sv` | Instruction decoding, immediate sign-extension, and register file read. |
| **Execute** | `stage_execute.sv` | ALU arithmetic execution and operand bypass multiplexers. |
| **Memory** | `stage_memory.sv` | Data memory bus interface. |
| **Writeback** | `stage_writeback.sv` | Register commit multiplexer (ALU vs. memory data). |
| **Pipeline Registers** | `pipe_regs.sv` | Synchronous boundary registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`). |
| **Forwarding Unit** | `forwarding_unit.sv` | Detects RAW dependencies and steers data from EX/MEM and MEM/WB stages. |
| **Hazard Unit** | `hazard_unit.sv` | Identifies load-use hazards to freeze the PC and inject stall bubbles. |
| **ALU** | `alu.sv` | Arithmetic Logic Unit supporting ADD and SUB operations. |
| **Register File** | `register_file.sv` | 32-entry dual-read, single-synchronous-write register array. |
