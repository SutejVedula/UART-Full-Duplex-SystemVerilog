# UART Full-Duplex Documentation

This directory contains simulation waveforms and FPGA implementation results for the UART Full-Duplex Transceiver.

## Contents

- `tx_waveform.png` — UART transmitter simulation waveform
- `rx_waveform.png` — UART receiver simulation waveform
- `full_duplex_waveform.png` — Full-duplex TX-to-RX loopback simulation
- `utilization.png` — FPGA resource utilization after implementation
- `timing_summary.png` — Post-implementation timing summary

## Target FPGA

- Device: AMD/Xilinx Artix-7
- Part: `xc7a35tcpg236-1`

## UART Configuration

- Data bits: 8
- Parity: None
- Stop bits: 1
- Baud rate: 9600 baud
- Clock frequency: 50 MHz

## Verification

The design was verified using Vivado Simulator with separate transmitter, receiver, and full-duplex loopback testbenches.

Test patterns included:

- `8'hB2`
- `8'hCA`
- `8'h00`
- `8'hFF`
- `8'hAA`
- `8'h55`

The receiver verification also included an invalid stop-bit test.

## Implementation

The design was synthesized and implemented successfully using Vivado.

The post-implementation timing analysis reported no failing setup or hold endpoints.
