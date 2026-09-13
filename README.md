# UART Full-Duplex Transceiver — SystemVerilog

A parameterized UART Full-Duplex Transceiver designed and verified in SystemVerilog using AMD/Xilinx Vivado.

The project implements independent UART transmitter and receiver modules, integrates them into a full-duplex top-level design, and validates functionality through simulation, synthesis, implementation, timing analysis, and FPGA resource utilization analysis.

---

## Project Overview

UART (Universal Asynchronous Receiver/Transmitter) is a widely used asynchronous serial communication protocol.

This project implements an **8N1 UART Full-Duplex Transceiver** supporting simultaneous transmission and reception.

### UART Configuration

| Parameter | Value |
|---|---|
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |
| Format | 8N1 |
| Default Clock | 50 MHz |
| Default Baud Rate | 9600 |
| Data Order | LSB First |
| Target FPGA | AMD/Xilinx Artix-7 |
| Target Part | `xc7a35tcpg236-1` |

---

## Architecture

The design consists of three main RTL modules:

``
                    UART FULL-DUPLEX SYSTEM
                            │
              ┌─────────────┴─────────────┐
              │                           │
              ▼                           ▼
       ┌──────────────┐           ┌──────────────┐
       │   UART TX    │           │   UART RX    │
       │              │           │              │
       │ IDLE         │           │ IDLE         │
       │ START        │           │ START        │
       │ DATA         │           │ DATA         │
       │ STOP         │           │ STOP         │
       └──────┬───────┘           └──────▲───────┘
              │                          │
              │        Serial Line       │
              └──────────────────────────┘

Transmitter

The transmitter converts an 8-bit parallel data word into a UART serial frame.

IDLE → START → DATA → STOP → IDLE

Frame format:

START | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | STOP
  0      LSB                         MSB          1
Receiver

The receiver detects the start bit, samples the incoming serial data, reconstructs the 8-bit byte, validates the stop bit, and generates an rx_done pulse.

IDLE → START → DATA → STOP → IDLE

The receiver samples the start bit near its midpoint to improve robustness against timing uncertainty.

RTL Modules
uart_tx.sv

Parameterized UART transmitter.

Responsibilities:

Accept 8-bit parallel input data
Generate UART start bit
Transmit data LSB first
Generate stop bit
Generate tx_busy status
Support configurable clock frequency and baud rate
uart_rx.sv

Parameterized UART receiver.

Responsibilities:

Detect UART start bit
Validate the start bit
Sample eight serial data bits
Reconstruct the received byte
Validate the stop bit
Generate rx_done
Reject invalid stop-bit frames
uart_top.sv

Top-level integration module connecting the transmitter and receiver into one UART full-duplex system.

Parameterization

The UART modules use configurable parameters:

parameter int CLK_FREQ_HZ = 50_000_000,
parameter int BAUD_RATE   = 9_600

The number of FPGA clock cycles per UART bit is calculated as:

localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;

For the default configuration:

Clock Frequency = 50 MHz
Baud Rate       = 9600

Therefore:

CLKS_PER_BIT ≈ 5208
Verification

The design was verified using Vivado Simulator with separate testbenches for the transmitter, receiver, and integrated full-duplex system.

TX Verification

Test patterns:

B2
CA
00
FF
AA
55

The transmitter waveform was inspected to verify:

Idle-high UART line
Start bit
LSB-first transmission
Eight data bits
Stop bit
tx_busy operation
RX Verification

Test patterns:

B2
CA
00
FF
AA
55

Additional verification:

Invalid stop-bit frame
Stop-bit rejection
rx_done completion pulse
Correct reconstructed data
Full-Duplex Verification

A loopback connection was used:

UART TX ─────────────► UART RX

The following patterns were transmitted and checked at the receiver:

B2
CA
00
FF
AA
55

All six patterns were successfully verified in the completed simulation.

Simulation Results
UART Transmitter

UART Receiver

Full-Duplex Loopback

FPGA Implementation

The design was synthesized and implemented using:

AMD/Xilinx Vivado
Artix-7 target architecture
Device: xc7a35tcpg236-1

Implementation completed successfully.

Resource Utilization

Post-implementation utilization included approximately:

Resource	Used
Slice LUTs	198
Slice Registers	157
Slices	101
Bonded IOBs	23
BUFGCTRL	1

Timing Analysis

Post-implementation timing analysis reported:

Metric	Result
Worst Negative Slack (WNS)	13.738 ns
Total Negative Slack (TNS)	0.000 ns
Worst Hold Slack (WHS)	0.168 ns
Total Hold Slack (THS)	0.000 ns
Failing Setup Endpoints	0
Failing Hold Endpoints	0

Vivado reported that all user-specified timing constraints were met.

Project Structure
UART-Full-Duplex-SystemVerilog/
│
├── README.md
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
    ├── tx_waveform.png
    ├── rx_waveform.png
    ├── full_duplex_waveform.png
    ├── utilization.png
    └── timing_summary.png
Tools & Technologies
SystemVerilog
RTL Design
Finite State Machines
UART Serial Communication
Vivado Simulator
Vivado Synthesis
Vivado Implementation
Static Timing Analysis
FPGA Resource Utilization Analysis
Skills Demonstrated

This project demonstrates practical experience in:

SystemVerilog RTL design
Synchronous digital design
FSM design
Serial communication protocols
Parameterized hardware design
Testbench development
Simulation-based verification
Waveform debugging
FPGA synthesis
FPGA implementation
Timing analysis
Resource utilization analysis
Hardware design documentation
Verification Summary
                    ┌──────────────────────┐
                    │    UART TX TEST      │
                    │   6 Test Patterns    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │    UART RX TEST      │
                    │   6 Test Patterns    │
                    │ + Invalid Stop Test  │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ FULL-DUPLEX LOOPBACK │
                    │   6 Patterns Tested  │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ SYNTHESIS + P&R      │
                    │      SUCCESS         │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   TIMING ANALYSIS    │
                    │  No Failing Paths    │
                    └──────────────────────┘
Future Improvements

Possible extensions include:

Configurable parity support
5/6/7/8 data-bit configurations
Multiple stop-bit configurations
Baud-rate error handling
RX oversampling
FIFO buffering
Break detection
Framing error flags
Parity error flags
AXI4-Lite register interface
FPGA board-level UART validation
Project Status

Completed

RTL Design              ✓
TX Verification         ✓
RX Verification         ✓
Full-Duplex Verification ✓
Synthesis               ✓
Implementation          ✓
Timing Analysis         ✓
Resource Analysis       ✓
Documentation           ✓
Author

Sutej Vedula

B.Tech Electronics and Communication Engineering

License

This project is intended for educational, portfolio, and RTL design practice purposes.
