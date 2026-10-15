module alu (
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] alu_op, // 000: ADD, 001: SUB, 010: AND, 011: OR, 100: XOR, 101: NOT
    output reg [3:0] result,
    output reg z_flag,
    output reg c_flag
);
    reg [4:0] temp_res;

    always @(*) begin
        c_flag = 1'b0;
        case (alu_op)
            3'b000: begin // ADD
                temp_res = {1'b0, A} + {1'b0, B};
                result = temp_res[3:0];
                c_flag = temp_res[4];
            end
            3'b001: begin // SUB
                temp_res = {1'b0, A} - {1'b0, B};
                result = temp_res[3:0];
                c_flag = temp_res[4];
            end
            3'b010: result = A & B;   // AND
            3'b011: result = A | B;   // OR
            3'b100: result = A ^ B;   // XOR
            3'b101: result = ~A;      // NOT
            default: result = 4'b0000;
        endcase
        z_flag = (result == 4'b0000) ? 1'b1 : 1'b0;
    end
endmodule