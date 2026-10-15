module flag_register (
    input clk,
    input rst,
    input flag_write,
    input z_in,
    input c_in,
    output reg z_out,
    output reg c_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            z_out <= 1'b0;
            c_out <= 1'b0;
        end else if (flag_write) begin
            z_out <= z_in;
            c_out <= c_in;
        end
    end
endmodule