//=============================================================
// reg_file.v
// 8 registers x 8 bits (8x8 Register File)
// Two asynchronous (combinational) read ports, one synchronous
// write port (write on rising clock edge when we=1)
//=============================================================
`timescale 1ns/1ps

module reg_file (
    input  wire        clk,
    input  wire        we,
    input  wire [2:0]  waddr,
    input  wire [7:0]  wdata,
    input  wire [2:0]  raddr1,
    input  wire [2:0]  raddr2,
    output wire [7:0]  rdata1,
    output wire [7:0]  rdata2
);

    reg [7:0] regs [0:7];
    integer i;

    // synchronous write
    always @(posedge clk) begin
        if (we)
            regs[waddr] <= wdata;
    end

    // asynchronous (combinational) read - REGOUT1 / REGOUT2
    assign rdata1 = regs[raddr1];
    assign rdata2 = regs[raddr2];

    // optional: init registers to 0 for simulation clarity
    initial begin
        for (i = 0; i < 8; i = i + 1)
            regs[i] = 8'd0;
    end

endmodule
