`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/08/2026 03:35:17 AM
// Design Name: NgoVanThang
// Module Name: tb_register_file
// Roll Number: SS190566
//////////////////////////////////////////////////////////////////////////////////
module tb_register_file;
    reg        clk = 0;           // Clock generator
    reg        rst = 1;           // Reset signal (Active-high)
    reg  [1:0] ra = 0, rb = 0;    // Read addresses Port A and B
    reg  [1:0] wa = 0;            // Write address
    reg  [3:0] wd = 0;            // Write data bus
    reg        we = 0;            // Write enable signal
    wire [3:0] qa, qb;            // Read data buses Port A and B

    integer test_cnt = 0;         // Total test counter
    integer err_cnt = 0;          // Error counter

    // Clock generator: 100MHz (period = 10ns)
    always #5 clk = ~clk;

    // Instantiate Device Under Test (DUT)
    register_file DUT (
        .clk(clk),                // Clock connection
        .rst(rst),                // Reset connection
        .ra (ra),                 // Read address A connection
        .rb (rb),                 // Read address B connection
        .wa (wa),                 // Write address connection
        .wd (wd),                 // Write data connection
        .we (we),                 // Write enable connection
        .qa (qa),                 // Read data A connection
        .qb (qb)                  // Read data B connection
    );

    // Verification task to check read data against expected value
    task check_val;
        input [192:1] lbl;        // Test description label
        input [3:0]   actual;     // Actual output value
        input [3:0]   expect_val; // Expected output value
    begin
        test_cnt = test_cnt + 1;  // Increment total count
        if (actual === expect_val)
            $display("[PASS] %0s = %b", lbl, actual);
        else begin
            $display("[FAIL] %0s = %b (Expected %b)", lbl, actual, expect_val);
            err_cnt = err_cnt + 1; // Increment error count
        end
    end
    endtask

    // Helper task to synchronously write data into target register
    task write_reg;
        input [1:0] tgt_reg;      // Destination register
        input [3:0] tgt_data;     // Data to write
    begin
        wa = tgt_reg; wd = tgt_data; we = 1'b1; // Setup write inputs
        @(posedge clk); #1;                     // Wait for clock edge and delta
        we = 1'b0;                              // Deassert write enable
    end
    endtask

    // Main test sequence
    initial begin
        $display("\n============================================================");
        $display("   DIGITAL DESIGN PROJECT: 4-BIT CPU_DATAPATCH    ");
        $display("   Student Name : TRAN QUAN BAO");
        $display("   Roll Number  : SE190570");
        $display("   Date         : 2026-10-08");
        $display("============================================================\n");
        
        $display("===== START: tb_register_file Simulation =====");

        // Test 1: Check registers right after reset
        @(posedge clk); #1;
        rst = 0; ra = 0; rb = 3; #1;
        check_val("R0 post-reset (Port A)", qa, 4'b0000);
        check_val("R3 post-reset (Port B)", qb, 4'b0000);

        // Test 2: Write unique patterns into R0 to R3
        write_reg(2'd0, 4'b0001); // Write 4'b0001 to R0
        write_reg(2'd1, 4'b0101); // Write 4'b0101 to R1
        write_reg(2'd2, 4'b1010); // Write 4'b1010 to R2
        write_reg(2'd3, 4'b1111); // Write 4'b1111 to R3

        // Test 3: Read back R0 and R1
        ra = 0; rb = 1; #1;
        check_val("Read R0 on Port A", qa, 4'b0001);
        check_val("Read R1 on Port B", qb, 4'b0101);

        // Test 4: Read back R2 and R3
        ra = 2; rb = 3; #1;
        check_val("Read R2 on Port A", qa, 4'b1010);
        check_val("Read R3 on Port B", qb, 4'b1111);

        // Test 5: Simultaneous dual-port read from same register (R1)
        ra = 1; rb = 1; #1;
        check_val("Dual-port read R1 (Port A)", qa, 4'b0101);
        check_val("Dual-port read R1 (Port B)", qb, 4'b0101);

        // Test 6: Verify no overwrite occurs when we = 0
        wa = 2; wd = 4'b0000; we = 0;
        @(posedge clk); #1;
        ra = 2; #1;
        check_val("R2 remains unchanged when we=0", qa, 4'b1010);

        // Test 7: Verify reset clears all registers again
        rst = 1; @(posedge clk); #1; rst = 0;
        ra = 3; rb = 2; #1;
        check_val("R3 after 2nd reset", qa, 4'b0000);
        check_val("R2 after 2nd reset", qb, 4'b0000);

        // Summary report
        if (err_cnt == 0)
            $display(">> tb_register_file PASSED: %0d/%0d checks OK!\n", test_cnt, test_cnt);
        else
            $display(">> tb_register_file FAILED: %0d/%0d checks failed!\n", err_cnt, test_cnt);

        $finish;                  // Terminate simulation
    end
endmodule