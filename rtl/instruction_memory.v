module instruction_memory (
    input  [3:0]  addr,
    output [11:0] instruction
);
    reg [11:0] rom [0:15];

    initial begin
        rom[0]  = 12'b0110_01_00_0101; // LOAD R1, 5
        rom[1]  = 12'b0110_10_00_0011; // LOAD R2, 3
        rom[2]  = 12'b0000_01_10_0000; // ADD  R1, R2   (R1 = 5 + 3 = 8)
        rom[3]  = 12'b1001_01_00_0001; // ST   R1, [1]  (MEM[1] = 8)
        rom[4]  = 12'b1000_11_00_0001; // LD   R3, [1]  (R3 = 8)
        rom[5]  = 12'b0001_01_11_0000; // SUB  R1, R3   (R1 = 8 - 8 = 0, Z=1)
        rom[6]  = 12'b1111_00_00_1000; // JZ   8        (Nhảy đến PC=8 nếu Z=1)
        rom[7]  = 12'b0110_00_00_1111; // (Lệnh bị bỏ qua do nhảy)
        rom[8]  = 12'b0101_10_00_0000; // NOT  R2       (R2 = ~3 = 12)
        rom[9]  = 12'b1010_00_00_1001; // JMP  9        (Vòng lặp dừng)
        rom[10] = 12'h000;
        rom[11] = 12'h000;
        rom[12] = 12'h000;
        rom[13] = 12'h000;
        rom[14] = 12'h000;
        rom[15] = 12'h000;
    end

    assign instruction = rom[addr];
endmodule