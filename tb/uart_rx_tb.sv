`timescale 1ns / 1ps

module uart_rx_tb;

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
    logic       rx;

    logic [7:0] data_out;
    logic       rx_done;


    // ============================================
    // DUT
    // ============================================

    uart_rx #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .rx       (rx),
        .data_out (data_out),
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
    // UART Byte Transmission Task
    // ============================================

    task automatic send_uart_byte(input logic [7:0] test_data);

        integer i;

        begin

            // ------------------------------------
            // Start Bit
            // ------------------------------------

            rx = 1'b0;
            #(BIT_PERIOD);


            // ------------------------------------
            // Data Bits - LSB First
            // ------------------------------------

            for (i = 0; i < 8; i = i + 1) begin

                rx = test_data[i];
                #(BIT_PERIOD);

            end


            // ------------------------------------
            // Stop Bit
            // ------------------------------------

            rx = 1'b1;
            #(BIT_PERIOD);

        end

    endtask


    // ============================================
    // Test Sequence
    // ============================================

    initial begin

        // ----------------------------------------
        // Initial Conditions
        // ----------------------------------------

        reset = 1'b1;
        rx    = 1'b1;

        #(2 * CLK_PERIOD);

        reset = 1'b0;

        $display("============================================");
        $display("UART RX TESTBENCH");
        $display("============================================");


        // ----------------------------------------
        // Test 1
        // ----------------------------------------

        $display("Test 1: Receiving B2");

        send_uart_byte(8'hB2);

        wait(rx_done);

        if (data_out == 8'hB2)
            $display("PASS: Received B2");
        else
            $display("FAIL: Expected B2, Received %h", data_out);

        #(BIT_PERIOD);


        // ----------------------------------------
        // Test 2
        // ----------------------------------------

        $display("Test 2: Receiving CA");

        send_uart_byte(8'hCA);

        wait(rx_done);

        if (data_out == 8'hCA)
            $display("PASS: Received CA");
        else
            $display("FAIL: Expected CA, Received %h", data_out);

        #(BIT_PERIOD);


        // ----------------------------------------
        // Test 3
        // ----------------------------------------

        $display("Test 3: Receiving 00");

        send_uart_byte(8'h00);

        wait(rx_done);

        if (data_out == 8'h00)
            $display("PASS: Received 00");
        else
            $display("FAIL: Expected 00, Received %h", data_out);

        #(BIT_PERIOD);


        // ----------------------------------------
        // Test 4
        // ----------------------------------------

        $display("Test 4: Receiving FF");

        send_uart_byte(8'hFF);

        wait(rx_done);

        if (data_out == 8'hFF)
            $display("PASS: Received FF");
        else
            $display("FAIL: Expected FF, Received %h", data_out);

        #(BIT_PERIOD);


        // ----------------------------------------
        // Test 5
        // ----------------------------------------

        $display("Test 5: Receiving AA");

        send_uart_byte(8'hAA);

        wait(rx_done);

        if (data_out == 8'hAA)
            $display("PASS: Received AA");
        else
            $display("FAIL: Expected AA, Received %h", data_out);

        #(BIT_PERIOD);


        // ----------------------------------------
        // Test 6
        // ----------------------------------------

        $display("Test 6: Receiving 55");

        send_uart_byte(8'h55);

        wait(rx_done);

        if (data_out == 8'h55)
            $display("PASS: Received 55");
        else
            $display("FAIL: Expected 55, Received %h", data_out);

        #(BIT_PERIOD);


        // ----------------------------------------
        // Invalid Stop Bit Test
        // ----------------------------------------

        $display("Invalid Stop Bit Test");

        // Start bit
        rx = 1'b0;
        #(BIT_PERIOD);

        // Data bits
        for (int j = 0; j < 8; j = j + 1) begin
            rx = 8'hA5[j];
            #(BIT_PERIOD);
        end

        // Invalid stop bit
        rx = 1'b0;
        #(BIT_PERIOD);

        // Give receiver time to process
        #(BIT_PERIOD);

        if (rx_done == 1'b0)
            $display("PASS: Invalid stop bit rejected");
        else
            $display("FAIL: Invalid stop bit accepted");


        // ----------------------------------------
        // Test Complete
        // ----------------------------------------

        rx = 1'b1;

        #(2 * BIT_PERIOD);

        $display("============================================");
        $display("UART RX TEST COMPLETE");
        $display("6 valid test patterns verified.");
        $display("Invalid stop-bit test verified.");
        $display("============================================");

        $finish;

    end

endmodule
