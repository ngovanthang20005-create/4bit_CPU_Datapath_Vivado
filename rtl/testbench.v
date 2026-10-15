`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg rst;

    integer errors = 0;
    integer checks = 0;

    cpu_top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock 100 MHz (chu kỳ 10 ns), cạnh lên tại 5, 15, 25, ...
    always #5 clk = ~clk;

    // So sánh một giá trị với giá trị mong đợi
    task check;
        input [8*28:1] name;
        input [3:0]    actual;
        input [3:0]    expected;
        begin
            checks = checks + 1;
            if (actual === expected)
                $display("PASS  %0s = %0d", name, actual);
            else begin
                $display("FAIL  %0s = %0d (expected %0d)", name, actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    // So sánh một bit (cờ Z, C)
    task check_bit;
        input [8*28:1] name;
        input          actual;
        input          expected;
        begin
            checks = checks + 1;
            if (actual === expected)
                $display("PASS  %0s = %b", name, actual);
            else begin
                $display("FAIL  %0s = %b (expected %b)", name, actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;

        $display("\n===== tb_cpu: kiem tra CPU 4-bit =====");

        // ---- Test 1: reset (rst van = 1 den 20 ns) ----
        @(posedge clk); @(posedge clk); #1;
        check("reset: PC",  uut.pc,                     4'd0);
        check("reset: R1",  uut.RF_UNIT.reg_array[1],   4'd0);
        check("reset: R2",  uut.RF_UNIT.reg_array[2],   4'd0);
        check("reset: R3",  uut.RF_UNIT.reg_array[3],   4'd0);

        #4 rst = 0;   // nha reset tai 20 ns

        // ---- Test 2: PC tang ----
        @(posedge clk); #1;                              // 25 ns
        check("PC tang 0 -> 1", uut.pc, 4'd1);

        // ---- Test 3: LDI ----
        @(posedge clk); #1;                              // 35 ns
        check("LDI R1,5 -> R1", uut.RF_UNIT.reg_array[1], 4'd5);
        @(posedge clk); #1;                              // 45 ns
        check("LDI R2,3 -> R2", uut.RF_UNIT.reg_array[2], 4'd3);

        // ---- Test 4: ADD (5 + 3) ----
        @(posedge clk); #1;                              // 55 ns
        check    ("ADD R1,R2 -> R1", uut.RF_UNIT.reg_array[1], 4'd8);
        check_bit("ADD: Zero",       uut.reg_z, 1'b0);
        check_bit("ADD: Carry",      uut.reg_c, 1'b0);

        // ---- Test 5: ST roi LD (ST chay o 65 ns, LD chay o 75 ns) ----
        @(posedge clk);                                  // 65 ns: ST R1,[1]
        @(posedge clk); #1;                              // 75 ns: LD R3,[1]
        check("ST/LD qua RAM -> R3", uut.RF_UNIT.reg_array[3], 4'd8);

        // ---- Test 6: SUB (8 - 8 = 0) ----
        @(posedge clk); #1;                              // 85 ns
        check    ("SUB R1,R3 -> R1", uut.RF_UNIT.reg_array[1], 4'd0);
        check_bit("SUB: Zero",       uut.reg_z, 1'b1);

        // ---- Test 7: JZ taken ----
        @(posedge clk); #1;                              // 95 ns
        check("JZ 8 taken: PC", uut.pc, 4'd8);

        // ---- Test 8: delay slot (lenh sau JZ van chay) ----
        @(posedge clk); #1;                              // 105 ns
        check("delay slot LDI R0,15", uut.RF_UNIT.reg_array[0], 4'd15);

        // ---- Test 9: NOT ----
        @(posedge clk); #1;                              // 115 ns
        check("NOT R2 (~0011) -> R2", uut.RF_UNIT.reg_array[2], 4'd12);

        // ---- Test 10: JMP 9 ----
        @(posedge clk); #1;                              // 125 ns
        check("JMP 9: PC", uut.pc, 4'd9);

        // ---- Tong ket ----
        $display("\n==================================================");
        if (errors == 0)
            $display("tb_cpu PASSED: %0d of %0d checks OK", checks, checks);
        else
            $display("tb_cpu FAILED: %0d of %0d checks failed", errors, checks);
        $display("==================================================\n");
        $finish;
    end

    // Giữ log theo dõi để đưa vào báo cáo
    initial begin
        $monitor("Time=%0t | PC=%0d | IR=%b | R1=%d | R2=%d | R3=%d | Z=%b C=%b",
                 $time, uut.pc, uut.ir_inst,
                 uut.RF_UNIT.reg_array[1],
                 uut.RF_UNIT.reg_array[2],
                 uut.RF_UNIT.reg_array[3],
                 uut.reg_z, uut.reg_c);
    end
endmodule