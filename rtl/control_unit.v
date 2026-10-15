module control_unit (
    input  [3:0] opcode,
    input        z_flag,
    input        c_flag,
    output reg   reg_write,
    output reg   mem_write,
    output reg   pc_load,
    output reg   flag_write,
    output reg [1:0] reg_dst_src, // MUX select
    output reg [2:0] alu_op
);
    always @(*) begin
        reg_write   = 1'b0;
        mem_write   = 1'b0;
        pc_load     = 1'b0;
        flag_write  = 1'b0;
        reg_dst_src = 2'b00;
        alu_op      = 3'b000;

        case (opcode)
            4'b0000: begin // ADD
                reg_write  = 1'b1;
                flag_write = 1'b1;
                alu_op     = 3'b000;
                reg_dst_src= 2'b00;
            end
            4'b0001: begin // SUB
                reg_write  = 1'b1;
                flag_write = 1'b1;
                alu_op     = 3'b001;
                reg_dst_src= 2'b00;
            end
            4'b0010: begin // AND
                reg_write  = 1'b1;
                flag_write = 1'b1;
                alu_op     = 3'b010;
                reg_dst_src= 2'b00;
            end
            4'b0011: begin // OR
                reg_write  = 1'b1;
                flag_write = 1'b1;
                alu_op     = 3'b011;
                reg_dst_src= 2'b00;
            end
            4'b0100: begin // XOR
                reg_write  = 1'b1;
                flag_write = 1'b1;
                alu_op     = 3'b100;
                reg_dst_src= 2'b00;
            end
            4'b0101: begin // NOT
                reg_write  = 1'b1;
                flag_write = 1'b1;
                alu_op     = 3'b101;
                reg_dst_src= 2'b00;
            end
            4'b0110: begin // LOAD Imm
                reg_write  = 1'b1;
                reg_dst_src= 2'b10;
            end
            4'b0111: begin // MOV Rd, Rs
                reg_write  = 1'b1;
                reg_dst_src= 2'b11;
            end
            4'b1000: begin // LD Rd, [Addr]
                reg_write  = 1'b1;
                reg_dst_src= 2'b01;
            end
            4'b1001: begin // ST Rd, [Addr]
                mem_write  = 1'b1;
            end
            4'b1010: begin // JMP
                pc_load    = 1'b1;
            end
            4'b1111: begin // JZ
                if (z_flag) pc_load = 1'b1;
            end
            4'b1100: begin // JC
                if (c_flag) pc_load = 1'b1;
            end
            default: ;
        endcase
    end
endmodule