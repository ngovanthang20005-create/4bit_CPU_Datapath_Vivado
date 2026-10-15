`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/08/2026 02:50:35 AM
// Design Name: NgoVanThang
// Module Name: tb_alu
// Roll Number: SS190566
//////////////////////////////////////////////////////////////////////////////////
module tb_alu;
    reg  [3:0] a, b;              // Stimulus input operands A and B
    reg  [2:0] alu_ctrl;          // ALU control code stimulus
    wire [3:0] result;            // ALU result output
    wire       carry, zero;       // ALU flag outputs

    integer total_tests = 0;      // Total test counter
    integer failed_tests = 0;     // Failed test counter

    // Instantiate Device Under Test (DUT)
    alu DUT (
        .a       (a),             // Operand A connection
        .b       (b),             // Operand B connection
        .alu_ctrl(alu_ctrl),      // ALU control connection
        .result  (result),        // Result output connection
        .carry   (carry),         // Carry flag connection
        .zero    (zero)           // Zero flag connection
    );

    // Verification task to apply stimulus and check response
    task check_alu;
        input [96:1] test_label;  // Test description string
        input [3:0]  val_a, val_b;// Input operands
        input [2:0]  op;          // Operation opcode
        input [3:0]  exp_res;     // Expected result
        input        exp_c;       // Expected carry flag
        input        exp_z;       // Expected zero flag
    begin
        total_tests = total_tests + 1; // Increment total count
        a = val_a; b = val_b; alu_ctrl = op; // Apply inputs
        #10;                      // Wait for combinational logic propagation

        // Compare actual outputs against expected values
        if (result === exp_res && carry === exp_c && zero === exp_z) begin
            $display("[PASS] %0s | a=%b b=%b -> res=%b c=%b z=%b", test_label, a, b, result, carry, zero);
        end else begin
            $display("[FAIL] %0s | a=%b b=%b -> res=%b c=%b z=%b (Expected res=%b c=%b z=%b)",
                     test_label, a, b, result, carry, zero, exp_res, exp_c, exp_z);
            failed_tests = failed_tests + 1; // Increment error count
        end
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
        
        $display("===== START: tb_alu Simulation =====");

        // Arithmetic test cases
        check_alu("ADD 5+3",     4'b0101, 4'b0011, 3'd0, 4'b1000, 1'b0, 1'b0); // 5 + 3 = 8
        check_alu("ADD 15+1",    4'b1111, 4'b0001, 3'd0, 4'b0000, 1'b1, 1'b1); // 15 + 1 = 16 (overflow/zero)
        check_alu("SUB 5-3",     4'b0101, 4'b0011, 3'd1, 4'b0010, 1'b1, 1'b0); // 5 - 3 = 2 (no-borrow)
        check_alu("SUB 3-5",     4'b0011, 4'b0101, 3'd1, 4'b1110, 1'b0, 1'b0); // 3 - 5 = -2 (borrow)
        check_alu("SUB 7-7",     4'b0111, 4'b0111, 3'd1, 4'b0000, 1'b1, 1'b1); // 7 - 7 = 0 (zero result)

        // Logical test cases
        check_alu("AND",         4'b1100, 4'b1010, 3'd2, 4'b1000, 1'b0, 1'b0); // Bitwise AND
        check_alu("OR",          4'b1100, 4'b1010, 3'd3, 4'b1110, 1'b0, 1'b0); // Bitwise OR
        check_alu("XOR",         4'b1100, 4'b1010, 3'd4, 4'b0110, 1'b0, 1'b0); // Bitwise XOR
        check_alu("XOR to zero", 4'b0110, 4'b0110, 3'd4, 4'b0000, 1'b0, 1'b1); // Bitwise XOR zero check
        check_alu("NOT 0101",    4'b0101, 4'b0000, 3'd5, 4'b1010, 1'b0, 1'b0); // Bitwise NOT A
        check_alu("PASS b",      4'b0000, 4'b1001, 3'd6, 4'b1001, 1'b0, 1'b0); // Pass operand B

        // Summary report
        if (failed_tests == 0)
            $display(">> tb_alu PASSED: %0d/%0d checks OK!\n", total_tests, total_tests);
        else
            $display(">> tb_alu FAILED: %0d/%0d checks failed!\n", failed_tests, total_tests);

        $finish;                  // Terminate simulation
    end
endmodule