`timescale 1ns / 1ps

module uart_top #(
    parameter int CLK_FREQ_HZ = 50_000_000,
    parameter int BAUD_RATE   = 9_600
) (
    input clk,
    input reset,

    // -----------------------------
    // Transmitter Interface
    // -----------------------------
    input        tx_start,
    input [7:0]  tx_data,
    output       tx,
    output       tx_busy,

    // -----------------------------
    // Receiver Interface
    // -----------------------------
    input        rx,
    output [7:0] rx_data,
    output       rx_done
);


    // ============================================
    // UART TRANSMITTER
    // ============================================

    uart_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk      (clk),
        .reset    (reset),
        .tx_start (tx_start),
        .data_in  (tx_data),
        .tx       (tx),
        .tx_busy  (tx_busy)
    );


    // ============================================
    // UART RECEIVER
    // ============================================

    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk      (clk),
        .reset    (reset),
        .rx       (rx),
        .data_out (rx_data),
        .rx_done  (rx_done)
    );


endmodule
