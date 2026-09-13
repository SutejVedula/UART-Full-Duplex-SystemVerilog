# UART Full-Duplex Transceiver — SystemVerilog RTL

A parameterized **UART Full-Duplex Transceiver** designed and implemented in **SystemVerilog RTL** using AMD Vivado.

The project implements independent UART transmitter and receiver modules with finite state machines, configurable clock and baud-rate parameters, automated simulation testbenches, full-duplex loopback verification, synthesis, implementation, resource utilization analysis, and static timing analysis.

---

## Project Overview

UART (Universal Asynchronous Receiver/Transmitter) is a widely used asynchronous serial communication protocol.

This project implements a complete **8N1 UART communication system**, consisting of:

- UART Transmitter (TX)
- UART Receiver (RX)
- Top-level integration module
- Parameterized baud-rate generation
- TX and RX finite state machines
- Automated SystemVerilog testbenches
- Full-duplex loopback verification
- RTL architecture documentation
- FPGA synthesis and implementation analysis
- Timing analysis
- Resource utilization analysis

The design is written to be reusable by allowing the clock frequency and baud rate to be configured through parameters.

---

## UART Configuration

The implemented UART communication format is:

| Parameter | Configuration |
|---|---|
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |
| Format | 8N1 |
| Data Order | LSB First |
| Default Clock Frequency | 50 MHz |
| Default Baud Rate | 9600 |

### UART Frame

Each transmitted byte follows this structure:

```text
Idle   Start     Data Bits                  Stop
 1       0     D0 D1 D2 D3 D4 D5 D6 D7        1
```

For example, for the byte:

```text
10110010
```

The data is transmitted LSB first:

```text
0 1 0 0 1 1 0 1
```

Therefore, the complete UART frame is:

```text
Start | D0 D1 D2 D3 D4 D5 D6 D7 | Stop
  0   |  0  1  0  0  1  1  0  1 |  1
```

---

# RTL Architecture

![UART RTL Architecture](docs/rtl_architecture.png)

The architecture consists of independent parameterized UART transmitter and receiver FSMs integrated through `uart_top.sv`.

The diagram illustrates the parallel-to-serial TX path, serial-to-parallel RX path, UART 8N1 framing, and the loopback connection used during full-duplex verification.

---

## Architecture

The design is divided into three main RTL modules:

```text
                    +--------------------------+
                    |       uart_top.sv        |
                    |                          |
                    |   +------------------+   |
tx_start ---------->|   |    UART TX       |-----> TX
tx_data[7:0] ------>|   |   uart_tx.sv     |   |
                    |   +------------------+   |
                    |                          |
                    |   +------------------+   |
RX ---------------->|   |    UART RX       |<----- RX
                    |   |   uart_rx.sv     |   |
                    |   +------------------+   |
                    +--------------------------+
```

### Module Responsibilities

#### `uart_tx.sv`

Responsible for:

- Accepting an 8-bit parallel input
- Capturing the input byte
- Generating the UART start bit
- Serializing the data LSB first
- Generating the stop bit
- Indicating transmission status using `tx_busy`

TX state machine:

```text
IDLE → START → DATA → STOP → IDLE
```

---

#### `uart_rx.sv`

Responsible for:

- Detecting the UART start bit
- Validating the start bit near the middle of the bit period
- Sampling incoming serial data
- Receiving 8 data bits
- Reconstructing the received byte
- Validating the stop bit
- Generating a one-clock `rx_done` pulse

RX state machine:

```text
IDLE → START → DATA → STOP → IDLE
```

The receiver rejects a frame when the expected stop bit is invalid.

---

#### `uart_top.sv`

Integrates the transmitter and receiver into a single UART subsystem.

It provides:

- TX interface
- RX interface
- TX busy indication
- Received data output
- RX completion indication
- Configurable clock and baud-rate parameters

---

# Parameterization

The UART modules are parameterized using:

```systemverilog
parameter int CLK_FREQ_HZ = 50_000_000;
parameter int BAUD_RATE   = 9_600;
```

The number of clock cycles required for one UART bit is calculated as:

```systemverilog
localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
```

For the default configuration:

```text
Clock Frequency = 50 MHz
Baud Rate       = 9600

CLKS_PER_BIT ≈ 5208
```

This allows the same RTL architecture to be adapted for different clock frequencies and UART baud rates.

---

# Signal Interface

## UART Transmitter

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | System clock |
| `reset` | Input | Synchronous reset |
| `tx_start` | Input | Starts transmission |
| `data_in[7:0]` | Input | Byte to transmit |
| `tx` | Output | UART serial output |
| `tx_busy` | Output | High while transmitting |

---

## UART Receiver

| Signal | Direction | Description |
|---|---|---|
| `clk` | Input | System clock |
| `reset` | Input | Synchronous reset |
| `rx` | Input | UART serial input |
| `data_out[7:0]` | Output | Received byte |
| `rx_done` | Output | One-clock pulse when reception completes |

---

# Verification

The project uses dedicated SystemVerilog testbenches for:

1. UART transmitter
2. UART receiver
3. Full-duplex UART system

The testbenches use multiple data patterns to exercise normal and edge-case behavior.

---

## TX Verification

The transmitter was tested using the following data patterns:

```text
B2
CA
00
FF
AA
55
```

The testbench verifies:

- Start bit generation
- Data serialization
- LSB-first transmission
- Stop bit generation
- `tx_busy` behavior
- Correct UART timing

### TX Result

```text
Total Tests : 6
Failed Tests: 0

STATUS: PASS
```

---

## RX Verification

The receiver was tested using:

```text
B2
CA
00
FF
AA
55
```

The testbench verifies:

- Start-bit detection
- Mid-bit start validation
- Data sampling
- LSB-first reconstruction
- Stop-bit validation
- `rx_done` generation

An invalid stop-bit test was also included to verify that malformed UART frames are rejected.

### RX Result

```text
Valid Tests : 6
Failed Tests: 0

STATUS: PASS
```

---

# Full-Duplex Verification

The complete UART system was verified using a direct serial loopback connection:

```systemverilog
assign rx = tx;
```

This connects the transmitter output directly to the receiver input.

The following patterns were transmitted and received:

```text
10110010
11001010
00000000
11111111
10101010
01010101
```

### Full-Duplex Result

```text
Total Tests : 6
Failed Tests: 0

STATUS: PASS
```

The successful loopback verification demonstrates correct integration between the transmitter and receiver RTL.

---

# Simulation Results

The project was simulated using **AMD Vivado XSim**.

Simulation waveforms were captured for:

- TX operation
- RX operation
- Full-duplex loopback

## TX Waveform

![TX Waveform](docs/tx_waveform.png)

The waveform demonstrates UART transmission through the start bit, eight data bits, and stop bit.

---

## RX Waveform

![RX Waveform](docs/rx_waveform.png)

The waveform demonstrates serial data sampling, byte reconstruction, and `rx_done` generation.

---

## Full-Duplex Waveform

![Full-Duplex Waveform](docs/full_duplex_waveform.png)

The full-duplex waveform demonstrates the transmitted serial data being received correctly through the loopback connection.

---

# FPGA Synthesis

The design was synthesized using **AMD Vivado** targeting the following Artix-7 FPGA:

```text
Device: xc7a35tcpg236-1
Family: Artix-7
```

Synthesis completed successfully.

The implementation was also completed successfully in Vivado.

---

# Resource Utilization

Post-implementation resource utilization was analyzed using Vivado.

| Resource | Used | Available |
|---|---:|---:|
| Slice LUTs | 198 | 20,800 |
| Slice Registers | 157 | 41,600 |
| Slices | 101 | 8,150 |
| LUT as Logic | 198 | 20,800 |
| Bonded IOB | 23 | 106 |
| BUFGCTRL | 1 | 32 |

### Utilization Report

![Resource Utilization](docs/utilization.png)

The implemented UART design occupies a small portion of the available Artix-7 resources.

---

# Timing Analysis

Static timing analysis was performed after implementation using Vivado.

### Timing Summary

| Metric | Result |
|---|---:|
| Worst Negative Slack (WNS) | 13.738 ns |
| Total Negative Slack (TNS) | 0.000 ns |
| Failing Setup Endpoints | 0 |
| Worst Hold Slack (WHS) | 0.168 ns |
| Total Hold Slack (THS) | 0.000 ns |
| Failing Hold Endpoints | 0 |
| Worst Pulse Width Slack | 9.500 ns |
| Total Pulse Width Negative Slack | 0.000 ns |
| Failing Pulse Width Endpoints | 0 |

Vivado reported that all user-specified timing constraints were met.

![Timing Summary](docs/timing_summary.png)

---

# Implementation Breakdown

The main implemented RTL modules contributed approximately:

```text
uart_rx
    128 LUTs
     83 Registers

uart_tx
     70 LUTs
     74 Registers
```

The design uses independent transmitter and receiver state machines with counters for UART timing and bit sequencing.

---

# Project Structure

```text
UART-Full-Duplex-SystemVerilog/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── rtl/
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   └── uart_top.sv
│
├── tb/
│   ├── uart_tx_tb.sv
│   ├── uart_rx_tb.sv
│   └── uart_top_tb.sv
│
└── docs/
    ├── README.md
    ├── rtl_architecture.png
    ├── tx_waveform.png
    ├── rx_waveform.png
    ├── full_duplex_waveform.png
    ├── utilization.png
    └── timing_summary.png
```

---

# Tools & Technologies

- SystemVerilog
- RTL Design
- AMD Vivado
- Vivado XSim
- Artix-7 FPGA architecture
- Finite State Machines
- Static Timing Analysis
- FPGA Synthesis
- FPGA Implementation
- GitHub

---

# Skills Demonstrated

This project demonstrates practical experience in:

- SystemVerilog RTL design
- Sequential logic design
- Finite State Machine design
- Asynchronous serial communication
- UART protocol implementation
- Parallel-to-serial conversion
- Serial-to-parallel conversion
- Baud-rate timing generation
- Parameterized RTL
- Digital design verification
- SystemVerilog testbench development
- Waveform-based debugging
- Edge-case testing
- FPGA synthesis
- FPGA implementation
- Resource utilization analysis
- Static timing analysis
- RTL architecture documentation
- GitHub-based project documentation

---

# Engineering Workflow

The project followed a typical RTL development workflow:

```text
Specification
      ↓
Architecture
      ↓
RTL Design
      ↓
Module-Level Verification
      ↓
Integration
      ↓
Full-Duplex Verification
      ↓
Debugging
      ↓
Synthesis
      ↓
Implementation
      ↓
Timing Analysis
      ↓
Resource Analysis
      ↓
Documentation
      ↓
GitHub
```

---

# Verification Summary

| Verification Stage | Result |
|---|---|
| TX Module Simulation | PASS |
| RX Module Simulation | PASS |
| Invalid Stop-Bit Test | PASS |
| Full-Duplex Loopback | PASS |
| Synthesis | PASS |
| Implementation | PASS |
| Timing Analysis | PASS |
| Setup Violations | 0 |
| Hold Violations | 0 |
| Pulse Width Violations | 0 |

---

# Future Improvements

Potential extensions for future versions include:

- Configurable parity support
- 5/6/7/8 data-bit configurations
- Multiple stop-bit configurations
- Fractional baud-rate generation
- RX oversampling
- Framing-error status
- Overrun detection
- Receive buffering
- FIFO integration
- UART interrupt interface
- AXI4-Lite register-mapped UART peripheral
- FPGA hardware validation using a physical development board

---

# Project Status

**Status: Completed**

The UART Full-Duplex Transceiver has been:

- Designed in SystemVerilog
- Functionally verified
- Integrated using a top-level RTL module
- Verified using full-duplex loopback
- Synthesized successfully
- Implemented successfully
- Analyzed for resource utilization
- Analyzed for static timing
- Documented with RTL architecture and simulation/implementation results
- Published on GitHub

---

# Author

**Sutej Vedula**

B.Tech Electronics and Communication Engineering

---

# License

This project is licensed under the **MIT License**.

See the `LICENSE` file for details.

This project is intended for educational, portfolio, and RTL design practice purposes.
