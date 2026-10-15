module register_file (
    input        clk,
    input        rst,
    input        reg_write,
    input  [1:0] read_reg_A, // Rd
    input  [1:0] read_reg_B, // Rs
    input  [1:0] write_reg,  // Rd
    input  [3:0] write_data,
    output [3:0] read_data_A,
    output [3:0] read_data_B
);
    reg [3:0] reg_array [0:3];
    integer i;

    assign read_data_A = reg_array[read_reg_A];
    assign read_data_B = reg_array[read_reg_B];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4; i = i + 1)
                reg_array[i] <= 4'b0000;
        end else if (reg_write) begin
            reg_array[write_reg] <= write_data;
        end
    end
endmodule