module instruction_register (
    input clk,
    input rst,
    input [11:0] instruction_in,
    output reg [11:0] instruction_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            instruction_out <= 12'b0;
        else
            instruction_out <= instruction_in;
    end
endmodule