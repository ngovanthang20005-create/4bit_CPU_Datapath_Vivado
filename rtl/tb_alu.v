`timescale 1ns / 1ps

module tb_alu;
    reg  [3:0] A, B;
    reg  [2:0] alu_op;
    wire [3:0] result;
    wire       z_flag, c_flag;

    integer errors = 0;
    integer tests  = 0;

    alu DUT (.A(A), .B(B), .alu_op(alu_op),
             .result(result), .z_flag(z_flag), .c_flag(c_flag));

    task test;
        input [8*14:1] name;
        input [3:0] in_a, in_b;
        input [2:0] op;
        input [3:0] exp_result;
        input       exp_c;
        input       exp_z;
        begin
            A = in_a; B = in_b; alu_op = op;
            #10;
            tests = tests + 1;
            if (result === exp_result && c_flag === exp_c && z_flag === exp_z)
                $display("PASS  %0s A=%b B=%b -> result=%b C=%b Z=%b",
                         name, A, B, result, c_flag, z_flag);
            else begin
                $display("FAIL  %0s A=%b B=%b -> result=%b C=%b Z=%b",
                         name, A, B, result, c_flag, z_flag);
                $display("      expected result=%b C=%b Z=%b",
                         exp_result, exp_c, exp_z);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("\n===== tb_alu: kiem tra ALU =====");
        //   name            A       B       op    result  C  Z
        test("ADD 5+3      ", 4'b0101, 4'b0011, 3'b000, 4'b1000, 0, 0);
        test("ADD 15+1     ", 4'b1111, 4'b0001, 3'b000, 4'b0000, 1, 1);
        test("ADD 15+15    ", 4'b1111, 4'b1111, 3'b000, 4'b1110, 1, 0);
        test("SUB 5-3      ", 4'b0101, 4'b0011, 3'b001, 4'b0010, 0, 0);
        test("SUB 3-5 (bor)", 4'b0011, 4'b0101, 3'b001, 4'b1110, 1, 0);
        test("SUB 7-7      ", 4'b0111, 4'b0111, 3'b001, 4'b0000, 0, 1);
        test("AND          ", 4'b1100, 4'b1010, 3'b010, 4'b1000, 0, 0);
        test("OR           ", 4'b1100, 4'b1010, 3'b011, 4'b1110, 0, 0);
        test("XOR          ", 4'b1100, 4'b1010, 3'b100, 4'b0110, 0, 0);
        test("XOR to zero  ", 4'b0110, 4'b0110, 3'b100, 4'b0000, 0, 1);
        test("NOT 0101     ", 4'b0101, 4'b0000, 3'b101, 4'b1010, 0, 0);
        test("NOT 1111     ", 4'b1111, 4'b0000, 3'b101, 4'b0000, 0, 1);
        test("unused op    ", 4'b1010, 4'b0101, 3'b110, 4'b0000, 0, 1);

        $display("\n==================================================");
        if (errors == 0)
            $display("tb_alu PASSED: %0d of %0d tests OK", tests, tests);
        else
            $display("tb_alu FAILED: %0d of %0d tests failed", errors, tests);
        $display("==================================================\n");
        $finish;
    end
endmodule
