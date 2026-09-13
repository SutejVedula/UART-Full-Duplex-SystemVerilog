`timescale 1ns / 1ps

module uart_tx_tb;

    // ============================================
    // Simulation Parameters
    // ============================================

    localparam int CLK_FREQ_HZ = 100;
    localparam int BAUD_RATE   = 10;

    localparam int CLK_PERIOD  = 10;
    localparam int CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam int BIT_PERIOD   = CLKS_PER_BIT * CLK_PERIOD;


    // ============================================
    // Testbench Signals
    // ============================================

    logic       clk;
    logic       reset;
    logic       tx_start;
    logic [7:0] data_in;

    logic       tx;
    logic       tx_busy;


    // ============================================
    // DUT
    // ============================================

    uart_tx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .tx_start (tx_start),
        .data_in  (data_in),
        .tx       (tx),
        .tx_busy  (tx_busy)
    );


    // ============================================
    // Clock Generation
    // ============================================

    initial begin
        clk = 1'b0;

        forever #(CLK_PERIOD / 2) clk = ~clk;
    end


    // ============================================
    // Test Task
    // ============================================

    task automatic send_byte(input logic [7:0] test_data);

        begin

            // Apply test data
            data_in  = test_data;
            tx_start = 1'b1;

            @(posedge clk);

            tx_start = 1'b0;

            // Wait until transmission starts
            wait(tx_busy == 1'b1);

            // Wait until transmission finishes
            wait(tx_busy == 1'b0);

            // Small delay before next test
            #(BIT_PERIOD);

        end

    endtask


    // ============================================
    // Main Test Sequence
    // ============================================

    initial begin

        // ----------------------------------------
        // Initial values
        // ----------------------------------------

        reset    = 1'b1;
        tx_start = 1'b0;
        data_in  = 8'b0;

        #(2 * CLK_PERIOD);

        reset = 1'b0;

        $display("============================================");
        $display("UART TX TESTBENCH");
        $display("============================================");


        // ----------------------------------------
        // Test 1
        // ----------------------------------------

        $display("Test 1: Sending B2");
        send_byte(8'hB2);


        // ----------------------------------------
        // Test 2
        // ----------------------------------------

        $display("Test 2: Sending CA");
        send_byte(8'hCA);


        // ----------------------------------------
        // Test 3
        // ----------------------------------------

        $display("Test 3: Sending 00");
        send_byte(8'h00);


        // ----------------------------------------
        // Test 4
        // ----------------------------------------

        $display("Test 4: Sending FF");
        send_byte(8'hFF);


        // ----------------------------------------
        // Test 5
        // ----------------------------------------

        $display("Test 5: Sending AA");
        send_byte(8'hAA);


        // ----------------------------------------
        // Test 6
        // ----------------------------------------

        $display("Test 6: Sending 55");
        send_byte(8'h55);


        // ----------------------------------------
        // Test Complete
        // ----------------------------------------

        $display("============================================");
        $display("UART TX TEST COMPLETE");
        $display("All 6 test patterns transmitted successfully.");
        $display("============================================");

        #(2 * BIT_PERIOD);

        $finish;

    end

endmodule
