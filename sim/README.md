# Simulation & Hazard Verification Report

Functional simulation and timing analysis of the 5-stage pipelined processor core verified in Aldec Riviera-PRO / EDA Playground.

## Waveform Analysis

![Waveform Capture](waveform_cpu.png)

The waveform demonstrates continuous PC incrementation, active bypass selection on `forward_a` and `forward_b`, and sequential register commits at 110 ns, 130 ns, and 150 ns.

## Test Program & Data Dependencies

The test suite evaluates three back-to-back arithmetic instructions with data dependencies. Registers are initialized upon reset to their respective index (`R[i] = i`):

- **Instr 0:** `ADD R1, R2, R5` $\rightarrow 2 + 5 = 7$ (Target: `R1`)
- **Instr 1:** `SUB R4, R1, R3` $\rightarrow 7 - 3 = 4$ (Target: `R4`, requires `R1` forwarded from Instr 0)
- **Instr 2:** `ADD R6, R4, R1` $\rightarrow 4 + 7 = 11$ (Target: `R6`, requires dual forward of `R4` and `R1`)


## Testbench Output

```text
==================================================
EDA PLAYGROUND VERIFICATION COMPLETE
R[1] = 7 (Expected: 7)
R[4] = 4 (Expected: 4) [Forwarded R1]
R[6] = 11 (Expected: 11) [Forwarded R4 & R1]
==================================================
TEST PASSED: 5-Stage Forwarding Hardware Verified
