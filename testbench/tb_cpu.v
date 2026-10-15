`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/08/2026 04:56:00 AM
// Design Name: NgoVanThang
// Module Name: tb_cpu
// Roll Number: SS190566
//////////////////////////////////////////////////////////////////////////////////
module tb_cpu;
    reg clk = 0;                  // Clock generator
    reg rst = 1;                  // Reset signal (Active-high)
    integer errors = 0;           // Total error counter
    integer checks = 0;           // Total checks counter
    integer cycle  = 0;           // Clock cycle counter
    integer i;                    // Loop index variable
    reg show_pipeline = 0;        // Debug flag to print pipeline stages

    // Clock generator: 100MHz (period = 10ns)
    always #5 clk = ~clk;

    // Output monitor wires from CPU
    wire [3:0]  pc_out;           // Current PC value
    wire [3:0]  alu_out;          // ALU computation output
    wire [3:0]  wb_data_out;      // Write-back data bus
    wire [11:0] instr_out;        // Executing instruction
    wire        zero_out;         // Zero flag output
    wire        carry_out;        // Carry flag output

    // Instantiate Device Under Test (DUT)
    cpu_top #(.PROGRAM_FILE("program.mem")) CPU (
        .clk        (clk),        // Clock connection
        .rst        (rst),        // Reset connection
        .pc_out     (pc_out),     // PC debug connection
        .instr_out  (instr_out),  // Instruction debug connection
        .alu_out    (alu_out),    // ALU result connection
        .wb_data_out(wb_data_out),// Write-back data connection
        .zero_out   (zero_out),   // Zero flag connection
        .carry_out  (carry_out)   // Carry flag connection
    );

    // Track clock cycles
    always @(posedge clk) begin
        if (rst) cycle <= 0;      // Reset cycle count
        else     cycle <= cycle + 1; // Increment cycle count
    end

    // Real-time pipeline status monitoring on falling edge
    always @(negedge clk) begin
        if (!rst && show_pipeline) begin
            $write(" cycle %2d | IF: addr %2d | ID: ", cycle + 1, CPU.pc_curr);
            if (CPU.id_valid) $write("%h (addr %2d)", CPU.id_instr, CPU.id_pc);
            else              $write("bubble      ");
            $write(" | EX: ");
            if (CPU.ex_valid) $write("%h (addr %2d)", CPU.ex_instr, CPU.ex_pc);
            else              $write("bubble      ");
            $display(" | R1=%b R2=%b R3=%b", CPU.RF.r1, CPU.RF.r2, CPU.RF.r3);
        end else if (!rst && CPU.ex_valid) begin
            $display(" EX addr %2d: %h | R0=%b R1=%b R2=%b R3=%b | Z=%b C=%b",
                     CPU.ex_pc, CPU.ex_instr, CPU.RF.r0, CPU.RF.r1, CPU.RF.r2, CPU.RF.r3,
                     zero_out, carry_out);
        end
    end

    // Helper task to perform a synchronous CPU reset
    task reset_cpu;
    begin
        rst = 1;
        @(posedge clk); @(posedge clk); #1;
        rst = 0;                  // Deassert reset
    end
    endtask

    // Helper task to clear and reload instruction/data memory from hex file
    task load_program;
        input [160:1] f_name;     // Memory hex file path
    begin
        rst = 1;                  // Hold reset while loading
        for (i = 0; i < 16; i = i + 1) begin
            CPU.IMEM.mem[i] = 12'hC00; // Clear IMEM to NOP
            CPU.DMEM.ram[i] = 4'b0000; // Clear DMEM to 0
        end
        $readmemh(f_name, CPU.IMEM.mem); // Load new program
    end
    endtask

    // Helper task to wait until instruction at given address completes execution
    task finish;
        input [3:0] addr;         // Target PC address
    begin
        @(negedge clk);
        while (!(CPU.ex_valid && CPU.ex_pc == addr))
            @(negedge clk);
        @(posedge clk);           // Wait for write-back edge
        #1;
    end
    endtask

    // Verification task to check 4-bit bus values
    task check;
        input [352:1] name;       // Test description label
        input [3:0]   actual;     // Actual signal value
        input [3:0]   expected;   // Expected signal value
    begin
        checks = checks + 1;      // Increment check counter
        if (actual === expected)
            $display("PASS %0s = %b", name, actual);
        else begin
            $display("FAIL %0s = %b (expected %b)", name, actual, expected);
            errors = errors + 1;  // Increment error counter
        end
    end
    endtask

    // Verification task to check 1-bit control/flag signals
    task check_bit;
        input [352:1] name;       // Test description label
        input         actual;     // Actual bit value
        input         expected;   // Expected bit value
    begin
        checks = checks + 1;      // Increment check counter
        if (actual === expected)
            $display("PASS %0s = %b", name, actual);
        else begin
            $display("FAIL %0s = %b (expected %b)", name, actual, expected);
            errors = errors + 1;  // Increment error counter
        end
    end
    endtask

    // Main testbench flow
    initial begin
        $display("\n============================================================");
        $display("   DIGITAL DESIGN PROJECT: 4-BIT CPU_DATAPATCH    ");
        $display("   Student Name : TRAN QUAN BAO");
        $display("   Roll Number  : SE190570");
        $display("   Date         : 2026-10-08");
        $display("============================================================\n");
        
        // TEST 1: Demonstration program
        $display("\n===== TEST 1: demonstration program (program.mem) =====");
        show_pipeline = 1;        // Enable pipeline tracing
        reset_cpu;
        finish(2);
        check("ADD R1,R2 -> R1 (5+3)", CPU.RF.r1, 4'b1000);
        finish(4);
        check("LDI R3,1010 -> R3", CPU.RF.r3, 4'b1010);
        check("XOR R1,R3 -> R1", CPU.RF.r1, 4'b0010);
        check("R2 still 0011", CPU.RF.r2, 4'b0011);
        $display(" 5 instructions finished after %0d clock cycles", cycle);
        finish(5);
        check("JMP 0101: PC (fetch address) = 5", pc_out, 4'd5);
        finish(5);
        show_pipeline = 0;        // Disable pipeline tracing
        check("JMP runs again: program loops at 5", pc_out, 4'd5);

        // TEST 2: Arithmetic and memory operations
        $display("\n===== TEST 2: arithmetic and memory (prog_arith.mem) =====");
        load_program("prog_arith.mem");
        reset_cpu;
        finish(2);
        check("ADD R1,R2 (0101+0011) -> R1", CPU.RF.r1, 4'b1000);
        check_bit("ADD: Carry", carry_out, 1'b0);
        check_bit("ADD: Zero", zero_out, 1'b0);
        finish(3);
        check("STORE R1,0 -> data_memory[0]", CPU.DMEM.ram[0], 4'b1000);
        finish(5);
        check("SUB R1,R2 (0101-0011) -> R1", CPU.RF.r1, 4'b0010);
        check_bit("SUB: Zero", zero_out, 1'b0);
        check_bit("SUB: Carry (1 = no borrow)", carry_out, 1'b1);
        finish(6);
        check("STORE R1,1 -> data_memory[1]", CPU.DMEM.ram[1], 4'b0010);
        finish(7);
        check("LOAD R0,0 -> R0", CPU.RF.r0, 4'b1000);
        finish(8);
        check("SUB R2,R2 -> R2", CPU.RF.r2, 4'b0000);
        check_bit("Zero flag after 0000 result", zero_out, 1'b1);
        $display(" 9 instructions finished after %0d clock cycles", cycle);

        // TEST 3: Logic operations
        $display("\n===== TEST 3: logic operations (prog_logic.mem) =====");
        load_program("prog_logic.mem");
        reset_cpu;
        finish(3);
        check("AND 1100, 1010 -> R3", CPU.RF.r3, 4'b1000);
        finish(5);
        check("OR 1100, 1010 -> R3", CPU.RF.r3, 4'b1110);
        finish(6);
        check("XOR 1100, 1010 -> R1", CPU.RF.r1, 4'b0110);
        finish(7);
        check("MOV R2, R1 (R1=0110) -> R2", CPU.RF.r2, 4'b0110);
        finish(9);
        check("NOT 0101 -> R0", CPU.RF.r0, 4'b1010);
        finish(10);
        check("LDI R3,1010 -> R3", CPU.RF.r3, 4'b1010);
        finish(11);
        check("XOR R3,R3 -> R3", CPU.RF.r3, 4'b0000);
        check_bit("Zero flag after 0000 result", zero_out, 1'b1);
        $display(" 12 instructions finished after %0d clock cycles", cycle);

        // TEST 4: Program counter and branch instructions
        $display("\n===== TEST 4: PC and jumps (prog_jump.mem) =====");
        load_program("prog_jump.mem");
        rst = 1;
        @(posedge clk); @(posedge clk); #1;
        rst = 0;
        check("PC after reset", pc_out, 4'd0);
        @(posedge clk); #1;
        check("PC increment (0->1)", pc_out, 4'd1);
        finish(1);
        check("JMP 4: PC becomes 0100", pc_out, 4'b0100);
        check_bit("JMP flushed the ID/EX register", CPU.ex_valid, 1'b0);
        finish(5);
        check_bit("SUB R1, R1 sets Zero", zero_out, 1'b1);
        finish(6);
        check("JZ 9 taken: PC = 9", pc_out, 4'd9);
        finish(10);
        check_bit("ADD R3, R3 clears Zero", zero_out, 1'b0);
        finish(11);
        check("JZ 14 not taken: next in EX is addr 12", CPU.ex_pc, 4'd12);
        finish(13);
        check("R0 = 1 (JMP skipped addresses 2, 3)", CPU.RF.r0, 4'd1);
        check("R2 = 6 (JZ skipped 7, 8; 14 never ran)", CPU.RF.r2, 4'd6);
        check("Program stops at PC = 13", pc_out, 4'd13);

        // TEST 5: Reset behavior and check for unknown (X) states
        $display("\n===== TEST 5: reset =====");
        rst = 1;
        @(posedge clk); #1;
        check("PC after reset", pc_out, 4'd0);
        check("R0 after reset", CPU.RF.r0, 4'd0);
        check("R2 after reset", CPU.RF.r2, 4'd0);
        check_bit("Zero after reset", zero_out, 1'b0);
        check_bit("Carry after reset", carry_out, 1'b0);
        check_bit("IF/ID empty after reset", CPU.id_valid, 1'b0);
        check_bit("ID/EX empty after reset", CPU.ex_valid, 1'b0);
        rst = 0;
        repeat (6) @(posedge clk); #1;

        checks = checks + 1;
        if ((^{pc_out, instr_out, alu_out, wb_data_out, zero_out, carry_out,
              CPU.RF.r0, CPU.RF.r1, CPU.RF.r2, CPU.RF.r3}) === 1'bx) begin
            $display("FAIL unknown (X) value found on key outputs");
            errors = errors + 1;
        end else begin
            $display("PASS no unknown (X) values on key outputs or registers");
        end

        // SUMMARY
        $display("\n==========================================");
        if (errors == 0)
            $display("tb_cpu PASSED: %0d of %0d checks OK", checks, checks);
        else
            $display("tb_cpu FAILED: %0d of %0d checks failed", errors, checks);
        $display("==========================================\n");

        $finish;                  // Terminate simulation
    end
endmodule