# Simulation & Functional Verification

This directory contains the simulation results and verification evidence for the 5-stage pipelined RISC-V processor using Aldec Riviera-PRO in EDA Playground.

## Waveform Execution

![Simulation Waveform](waveform_CPU.png)

---

## Simulation Console Output

```text
==================================================
EDA PLAYGROUND VERIFICATION COMPLETE
R[1] = 7 (Expected: 7)
R[4] = 4 (Expected: 4) [Forwarded R1]
R[6] = 11 (Expected: 11) [Forwarded R4 & R1]
==================================================
>>> TEST PASSED: 5-Stage Forwarding Hardware Verified! <<<
Time: 165 ns
