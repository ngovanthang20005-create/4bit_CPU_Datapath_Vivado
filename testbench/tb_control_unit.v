`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/08/2026 04:10:02 AM
// Design Name: NgoVanThang
// Module Name: tb_control_unit
// Roll Number: SS190566
//////////////////////////////////////////////////////////////////////////////////
module tb_control_unit;
    reg  [3:0] opcode = 4'b0000;    // Instruction opcode stimulus
    reg        ex_is_jmp = 0;       // EX stage jump stimulus
    reg        ex_is_jz = 0;        // EX stage jump-if-zero stimulus
    reg        zero_flag = 0;       // Zero flag stimulus
    wire [2:0] alu_ctrl;            // ALU control output
    wire       alu_src_sel;         // ALU source select output
    wire       wb_sel;              // Write-back select output
    wire       reg_we;              // Register write enable output
    wire       mem_we;              // Memory write enable output
    wire       zero_we;             // Zero flag write enable output
    wire       carry_we;            // Carry flag write enable output
    wire       is_jmp;              // Jump signal output
    wire       is_jz;               // Jump-if-zero signal output
    wire       pc_sel;              // PC select output
    wire       flush;               // Flush output

    integer checks = 0;             // Total checks counter
    integer errors = 0;             // Total errors counter

    // Instantiate Device Under Test (DUT)
    control_unit DUT (
        .opcode     (opcode),       // Opcode input connection
        .alu_ctrl   (alu_ctrl),     // ALU control connection
        .alu_src_sel(alu_src_sel),  // ALU src select connection
        .wb_sel     (wb_sel),       // WB select connection
        .reg_we     (reg_we),       // Reg write enable connection
        .mem_we     (mem_we),       // Mem write enable connection
        .zero_we    (zero_we),      // Zero write enable connection
        .carry_we   (carry_we),     // Carry write enable connection
        .is_jmp     (is_jmp),       // Jump connection
        .is_jz      (is_jz),        // Jump-if-zero connection
        .ex_is_jmp  (ex_is_jmp),    // EX jump connection
        .ex_is_jz   (ex_is_jz),     // EX jump-if-zero connection
        .zero_flag  (zero_flag),    // Zero flag connection
        .pc_sel     (pc_sel),       // PC select connection
        .flush      (flush)         // Flush connection
    );

    // Concatenate all decoder control signals into an 11-bit vector for comparison
    wire [10:0] packed_signals = {alu_ctrl, alu_src_sel, wb_sel, reg_we, mem_we, zero_we, carry_we, is_jmp, is_jz};

    // Verification task to check decoder outputs
    task test_opcode;
        input [48:1] op_name;       // Instruction mnemonic
        input [3:0]  op_code_in;    // Target opcode
        input [10:0] exp_signals;   // Expected control bus
    begin
        opcode = op_code_in; #1;    // Apply opcode and wait for evaluation
        checks = checks + 1;        // Increment check counter
        if (packed_signals === exp_signals)
            $display("[PASS] Decoder: %0s -> signals=%b", op_name, packed_signals);
        else begin
            $display("[FAIL] Decoder: %0s -> got %b, exp %b", op_name, packed_signals, exp_signals);
            errors = errors + 1;    // Increment error counter
        end
    end
    endtask

    // Verification task to check branch and flush logic
    task test_branch;
        input [120:1] br_name;      // Branch test label
        input         jmp_in;       // Jump stimulus
        input         jz_in;        // Jump-if-zero stimulus
        input         zf_in;        // Zero flag stimulus
        input         exp_pc_sel;   // Expected PC select / flush
    begin
        ex_is_jmp = jmp_in; ex_is_jz = jz_in; zero_flag = zf_in; #1; // Apply inputs
        checks = checks + 1;        // Increment check counter
        if (pc_sel === exp_pc_sel && flush === exp_pc_sel)
            $display("[PASS] Branch: %0s -> pc_sel=%b flush=%b", br_name, pc_sel, flush);
        else begin
            $display("[FAIL] Branch: %0s -> got pc_sel=%b (exp %b)", br_name, pc_sel, exp_pc_sel);
            errors = errors + 1;    // Increment error counter
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
        
        $display("===== START: tb_control_unit Simulation =====");

        // Part A: Verify Decoder stage output
        test_opcode("ADD",   4'h0, 11'b000_0_0_1_0_1_1_0_0); // Arithmetic ADD
        test_opcode("SUB",   4'h1, 11'b001_0_0_1_0_1_1_0_0); // Arithmetic SUB
        test_opcode("AND",   4'h2, 11'b010_0_0_1_0_1_0_0_0); // Logical AND
        test_opcode("OR",    4'h3, 11'b011_0_0_1_0_1_0_0_0); // Logical OR
        test_opcode("XOR",   4'h4, 11'b100_0_0_1_0_1_0_0_0); // Logical XOR
        test_opcode("NOT",   4'h5, 11'b101_0_0_1_0_1_0_0_0); // Logical NOT
        test_opcode("LDI",   4'h6, 11'b110_1_0_1_0_0_0_0_0); // Load Immediate
        test_opcode("MOV",   4'h7, 11'b110_0_0_1_0_0_0_0_0); // Register Move
        test_opcode("LOAD",  4'h8, 11'b110_1_1_1_0_0_0_0_0); // Memory Load
        test_opcode("STORE", 4'h9, 11'b110_1_0_0_1_0_0_0_0); // Memory Store
        test_opcode("JMP",   4'hA, 11'b000_0_0_0_0_0_0_1_0); // Unconditional Jump
        test_opcode("JZ",    4'hB, 11'b000_0_0_0_0_0_0_0_1); // Conditional Jump-if-Zero
        test_opcode("RES-C", 4'hC, 11'b000_0_0_0_0_0_0_0_0); // Reserved C (NOP)
        test_opcode("RES-D", 4'hD, 11'b000_0_0_0_0_0_0_0_0); // Reserved D (NOP)
        test_opcode("RES-E", 4'hE, 11'b000_0_0_0_0_0_0_0_0); // Reserved E (NOP)
        test_opcode("RES-F", 4'hF, 11'b000_0_0_0_0_0_0_0_0); // Reserved F (NOP)

        // Part B: Verify Branch logic
        test_branch("No jump, Z=0", 0, 0, 0, 1'b0); // No branch
        test_branch("No jump, Z=1", 0, 0, 1, 1'b0); // No branch with zero flag
        test_branch("JMP, Z=0",     1, 0, 0, 1'b1); // JMP taken (Z=0)
        test_branch("JMP, Z=1",     1, 0, 1, 1'b1); // JMP taken (Z=1)
        test_branch("JZ with Z=0",  0, 1, 0, 1'b0); // JZ not taken
        test_branch("JZ with Z=1",  0, 1, 1, 1'b1); // JZ taken

        // Summary report
        if (errors == 0)
            $display(">> tb_control_unit PASSED: %0d/%0d checks OK!\n", checks, checks);
        else
            $display(">> tb_control_unit FAILED: %0d/%0d checks failed!\n", errors, checks);

        $finish;                    // Terminate simulation
    end
endmodule