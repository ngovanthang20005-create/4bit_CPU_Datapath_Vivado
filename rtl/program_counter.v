module program_counter (
    input            clk,
    input            rst,
    input            pc_load,
    input      [3:0] pc_in,
    output reg [3:0] pc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 4'b0000;
        else if (pc_load)
            pc_out <= pc_in;
        else
            pc_out <= pc_out + 1'b1;
    end
endmodule