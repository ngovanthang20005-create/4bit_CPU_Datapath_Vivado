module data_memory (
    input        clk,
    input        mem_write,
    input  [3:0] addr,
    input  [3:0] write_data,
    output [3:0] read_data
);
    reg [3:0] ram [0:15];
    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1)
            ram[i] = 4'b0000;
    end

    always @(posedge clk) begin
        if (mem_write)
            ram[addr] <= write_data;
    end

    assign read_data = ram[addr];
endmodule