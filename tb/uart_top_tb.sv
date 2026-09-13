`timescale 1ns / 1ps

module uart_top_tb;

    // ============================================
    // Simulation Parameters
    // ============================================

    localparam int CLK_FREQ_HZ  = 100;
    localparam int BAUD_RATE    = 10;

    localparam int CLK_PERIOD   = 10;
    localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam int BIT_PERIOD   = CLKS_PER_BIT * CLK_PERIOD;


    // ============================================
    // Testbench Signals
    // ============================================

    logic       clk;
    logic       reset;

    logic       tx_start;
    logic [7:0] tx_data;

    logic       tx;
    logic       tx_busy;

    logic [7:0] rx_data;
    logic       rx_done;


    // ============================================
    // UART LOOPBACK SIGNAL
    // ============================================

    // TX output is directly connected to RX input
    logic rx;


    assign rx = tx;


    // ============================================
    // Device Under Test
    // ============================================

    uart_top #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk      (clk),
        .reset    (reset),

        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx),
        .tx_busy  (tx_busy),

        .rx       (rx),
        .rx_data  (rx_data),
        .rx_done  (rx_done)
    );


    // ============================================
    // Clock Generation
    // ============================================

    initial begin
        clk = 1'b0;

        forever #(CLK_PERIOD / 2) clk = ~clk;
    end


    // ============================================
    // Test Statistics
    // ============================================

    integer total_tests;
    integer failed_tests;


    // ============================================
    // UART Full-Duplex Test Task
    // ============================================

    task automatic test_uart(input logic [7:0] test_data);

        begin

            total_tests = total_tests + 1;

            $display("--------------------------------------------");
            $display("Test %0d: Sending %h", total_tests, test_data);

            // ------------------------------------
            // Apply transmit data
            // ------------------------------------

            tx_data  = test_data;
            tx_start = 1'b1;

            // Hold tx_start for one clock cycle
            @(posedge clk);

            tx_start = 1'b0;


            // ------------------------------------
            // Wait for receiver to complete
            // ------------------------------------

            wait(rx_done == 1'b1);


            // ------------------------------------
            // Check received data
            // ------------------------------------

            if (rx_data == test_data) begin

                $display(
                    "PASS: TX=%h  RX=%h",
                    test_data,
                    rx_data
                );

            end

            else begin

                $display(
                    "FAIL: Expected=%h  Received=%h",
                    test_data,
                    rx_data
                );

                failed_tests = failed_tests + 1;

            end


            // ------------------------------------
            // Wait before next test
            // ------------------------------------

            #(2 * BIT_PERIOD);

        end

    endtask


    // ============================================
    // Main Test Sequence
    // ============================================

    initial begin

        // ----------------------------------------
        // Initial Conditions
        // ----------------------------------------

        reset       = 1'b1;
        tx_start    = 1'b0;
        tx_data     = 8'b0;

        total_tests = 0;
        failed_tests = 0;


        // ----------------------------------------
        // Reset
        // ----------------------------------------

        #(2 * CLK_PERIOD);

        reset = 1'b0;


        $display("");
        $display("============================================");
        $display("UART FULL-DUPLEX LOOPBACK TESTBENCH");
        $display("============================================");
        $display("Clock Frequency : %0d Hz", CLK_FREQ_HZ);
        $display("Baud Rate       : %0d", BAUD_RATE);
        $display("Clock Period    : %0d ns", CLK_PERIOD);
        $display("Bit Period      : %0d ns", BIT_PERIOD);
        $display("============================================");


        // ----------------------------------------
        // Test 1
        // ----------------------------------------

        test_uart(8'hB2);


        // ----------------------------------------
        // Test 2
        // ----------------------------------------

        test_uart(8'hCA);


        // ----------------------------------------
        // Test 3
        // ----------------------------------------

        test_uart(8'h00);


        // ----------------------------------------
        // Test 4
        // ----------------------------------------

        test_uart(8'hFF);


        // ----------------------------------------
        // Test 5
        // ----------------------------------------

        test_uart(8'hAA);


        // ----------------------------------------
        // Test 6
        // ----------------------------------------

        test_uart(8'h55);


        // ----------------------------------------
        // Final Results
        // ----------------------------------------

        $display("");
        $display("============================================");
        $display("UART FULL-DUPLEX TEST RESULTS");
        $display("============================================");
        $display("Total Tests  : %0d", total_tests);
        $display("Failed Tests : %0d", failed_tests);


        if (failed_tests == 0) begin

            $display("RESULT       : ALL TESTS PASSED");

        end

        else begin

            $display("RESULT       : TEST FAILURES DETECTED");

        end


        $display("============================================");


        // ----------------------------------------
        // Finish Simulation
        // ----------------------------------------

        #(2 * BIT_PERIOD);

        $finish;

    end

endmodule
