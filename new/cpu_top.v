module cpu_top (
    input        clk,
    input        rst,
    output [3:0] pc_out,     
    output [3:0] wb_out,     
    output       z_out,      
    output       c_out      
);

    wire [3:0]  pc;
    wire [11:0] rom_inst;
    wire [11:0] ir_inst;


    wire [3:0] opcode = ir_inst[11:8];
    wire [1:0] rd     = ir_inst[7:6];
    wire [1:0] rs     = ir_inst[5:4];
    wire [3:0] imm4   = ir_inst[3:0];


    wire reg_write, mem_write, pc_load, flag_write;
    wire [1:0] reg_dst_src;
    wire [2:0] alu_op;


    wire alu_z, alu_c;
    wire reg_z, reg_c;


    wire [3:0] reg_rd_data, reg_rs_data;
    wire [3:0] alu_result;
    wire [3:0] mem_read_data;
    wire [3:0] wb_data;


    program_counter PC_UNIT (
        .clk(clk),
        .rst(rst),
        .pc_load(pc_load),
        .pc_in(imm4),
        .pc_out(pc)
    );

    // 2. Instruction Memory
    instruction_memory IM_UNIT (
        .addr(pc),
        .instruction(rom_inst)
    );

    // 3. Instruction Register (IR)
    instruction_register IR_UNIT (
        .clk(clk),
        .rst(rst),
        .instruction_in(rom_inst),
        .instruction_out(ir_inst)
    );

    // 4. Control Unit
    control_unit CU_UNIT (
        .opcode(opcode),
        .z_flag(reg_z),
        .c_flag(reg_c),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .pc_load(pc_load),
        .flag_write(flag_write),
        .reg_dst_src(reg_dst_src),
        .alu_op(alu_op)
    );

    // 5. Flag Register
    flag_register FR_UNIT (
        .clk(clk),
        .rst(rst),
        .flag_write(flag_write),
        .z_in(alu_z),
        .c_in(alu_c),
        .z_out(reg_z),
        .c_out(reg_c)
    );

    // 6. Register File
    register_file RF_UNIT (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg_A(rd),
        .read_reg_B(rs),
        .write_reg(rd),
        .write_data(wb_data),
        .read_data_A(reg_rd_data),
        .read_data_B(reg_rs_data)
    );

    // 7. ALU
    alu ALU_UNIT (
        .A(reg_rd_data),
        .B(reg_rs_data),
        .alu_op(alu_op),
        .result(alu_result),
        .z_flag(alu_z),
        .c_flag(alu_c)
    );

    // 8. Multiplexer (MUX Write-back)
    mux MUX_UNIT (
        .in0(alu_result),
        .in1(mem_read_data),
        .in2(imm4),
        .in3(reg_rs_data),
        .sel(reg_dst_src),
        .out(wb_data)
    );

    // 9. Data Memory
    data_memory DM_UNIT (
        .clk(clk),
        .mem_write(mem_write),
        .addr(imm4),
        .write_data(reg_rd_data),
        .read_data(mem_read_data)
    );

    // Cổng ra quan sát (để Vivado không xóa logic khi Implementation)
    assign pc_out = pc;
    assign wb_out = wb_data;
    assign z_out  = reg_z;
    assign c_out  = reg_c;

endmodule