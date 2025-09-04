# 2 Bus Multi-Cycle CPU in VHDL

This project is a VHDL implementation of a **multi-cycle CPU**, designed to demonstrate how instructions can be executed across multiple clock cycles under the control of a finite state machine. It is aimed at learning and teaching computer architecture concepts, with compatibility for FPGA boards like the DE10.

## Overview

The CPU is built around two main ideas:

- A **control unit** that generates signals based on the current instruction and state.  
- A **datapath** that performs arithmetic, memory access, and data movement according to those signals.

Together, these components show how multi-cycle execution works in practice, making it easier to study the inner workings of processors.

## Testing

Simulation testbenches are included to provide clock/reset generation, memory initialization, and step-by-step instruction execution. This allows verification of the CPU’s behavior before synthesis on hardware.

## Documentation

A detailed explanation of the design and lab context is available in the DOC file in 2-Bus-Multi-Cycle-CPU.pdf
