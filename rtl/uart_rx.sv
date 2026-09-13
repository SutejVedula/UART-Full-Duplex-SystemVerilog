`timescale 1ns / 1ps

module uart_rx #(
    parameter int CLK_FREQ_HZ = 50_000_000,
    parameter int BAUD_RATE   = 9_600
) (
    input  clk,
    input  reset,
    input  rx,
    output logic [7:0] data_out,
    output logic rx_done
);

    // ============================================
    // UART Parameters
    // ============================================

    // Number of FPGA clock cycles per UART bit
    localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;


    // ============================================
    // UART Receiver States
    // ============================================

    typedef enum logic [2:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;


    // ============================================
    // Internal Registers
    // ============================================

    // Counts FPGA clock cycles for UART timing
    int baud_counter;

    // Keeps track of which data bit is being received
    int bit_counter;

    // Stores the received byte
    logic [7:0] rx_data_reg;


    // ============================================
    // Sequential Logic
    // ============================================

    always_ff @(posedge clk) begin

        // ----------------------------------------
        // RESET
        // ----------------------------------------

        if (reset) begin
            state        <= IDLE;
            baud_counter <= 0;
            bit_counter  <= 0;
            rx_data_reg  <= 8'b0;
            data_out     <= 8'b0;
            rx_done      <= 1'b0;
        end

        else begin

            // rx_done is a one-clock-cycle pulse
            rx_done <= 1'b0;

            case (state)

                // --------------------------------
                // IDLE STATE
                // --------------------------------

                IDLE: begin

                    baud_counter <= 0;
                    bit_counter  <= 0;

                    // UART start bit is LOW
                    if (rx == 1'b0) begin
                        state        <= START;
                        baud_counter <= 0;
                    end

                end


                // --------------------------------
                // START BIT
                // --------------------------------

                START: begin

                    // Wait until the middle of the start bit
                    if (baud_counter < (CLKS_PER_BIT / 2) - 1) begin
                        baud_counter <= baud_counter + 1;
                    end

                    else begin
                        baud_counter <= 0;

                        // Confirm that the start bit is still LOW
                        if (rx == 1'b0) begin
                            state       <= DATA;
                            bit_counter <= 0;
                        end

                        else begin
                            // False start detected
                            state <= IDLE;
                        end

                    end

                end


                // --------------------------------
                // DATA BITS
                // --------------------------------

                DATA: begin

                    if (baud_counter < CLKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end

                    else begin
                        baud_counter <= 0;

                        // Sample current data bit
                        rx_data_reg[bit_counter] <= rx;

                        if (bit_counter < 7) begin
                            bit_counter <= bit_counter + 1;
                        end

                        else begin
                            bit_counter <= 0;
                            state       <= STOP;
                        end

                    end

                end


                // --------------------------------
                // STOP BIT
                // --------------------------------

                STOP: begin

                    if (baud_counter < CLKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end

                    else begin
                        baud_counter <= 0;

                        // Stop bit must be HIGH
                        if (rx == 1'b1) begin
                            data_out <= rx_data_reg;
                            rx_done  <= 1'b1;
                        end

                        state <= IDLE;

                    end

                end


                // --------------------------------
                // SAFETY DEFAULT
                // --------------------------------

                default: begin
                    state        <= IDLE;
                    baud_counter <= 0;
                    bit_counter  <= 0;
                    rx_data_reg  <= 8'b0;
                end

            endcase

        end

    end

endmodule
