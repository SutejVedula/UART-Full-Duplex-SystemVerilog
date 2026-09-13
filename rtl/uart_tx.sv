`timescale 1ns / 1ps

module uart_tx #(
    parameter int CLK_FREQ_HZ = 50_000_000,
    parameter int BAUD_RATE   = 9_600
) (
    input clk,
    input reset,
    input tx_start,
    input [7:0] data_in,
    output logic tx,
    output logic tx_busy
);

    // ============================================
    // UART Parameters
    // ============================================

    // Number of FPGA clock cycles per UART bit
    localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;


    // ============================================
    // UART Transmitter States
    // ============================================

    typedef enum logic [1:0] {
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

    // Keeps track of which data bit is being transmitted
    int bit_counter;

    // Stores the byte currently being transmitted
    logic [7:0] tx_data_reg;


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
            tx_data_reg  <= 8'b0;
        end

        else begin

            case (state)

                // --------------------------------
                // IDLE STATE
                // --------------------------------

                IDLE: begin

                    if (tx_start) begin
                        tx_data_reg  <= data_in;
                        baud_counter <= 0;
                        bit_counter  <= 0;
                        state        <= START;
                    end

                end


                // --------------------------------
                // START BIT
                // --------------------------------

                START: begin

                    if (baud_counter < CLKS_PER_BIT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end

                    else begin
                        baud_counter <= 0;
                        state        <= DATA;
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
                        state        <= IDLE;
                    end

                end


                // --------------------------------
                // SAFETY DEFAULT
                // --------------------------------

                default: begin
                    state        <= IDLE;
                    baud_counter <= 0;
                    bit_counter  <= 0;
                end

            endcase

        end

    end


    // ============================================
    // Combinational Output Logic
    // ============================================

    always_comb begin

        // Default values
        tx      = 1'b1;
        tx_busy = 1'b0;

        case (state)

            // --------------------------------
            // IDLE
            // --------------------------------

            IDLE: begin
                tx      = 1'b1;
                tx_busy = 1'b0;
            end


            // --------------------------------
            // START BIT
            // --------------------------------

            START: begin
                tx      = 1'b0;
                tx_busy = 1'b1;
            end


            // --------------------------------
            // DATA BITS
            // --------------------------------

            DATA: begin
                tx      = tx_data_reg[bit_counter];
                tx_busy = 1'b1;
            end


            // --------------------------------
            // STOP BIT
            // --------------------------------

            STOP: begin
                tx      = 1'b1;
                tx_busy = 1'b1;
            end


            // --------------------------------
            // DEFAULT
            // --------------------------------

            default: begin
                tx      = 1'b1;
                tx_busy = 1'b0;
            end

        endcase

    end

endmodule
