`timescale 1ns/1ps

module alu_8bit (
    input  [7:0] a, b,
    input  [2:0] sel,
    output reg [7:0] result,
    output reg       carry,
    output           zero,
    output           negative
);

    assign zero     = (result == 8'b0);

    assign negative = result[7];

    always @(*) begin
        carry = 0;
        case (sel)
            3'b000: {carry, result} = a + b;         // Addition
            3'b001: {carry, result} = a - b;         // Subtraction
            3'b010:  result        = a & b;          // AND
            3'b011:  result        = a | b;          // OR
            3'b100:  result        = a ^ b;          // XOR
            3'b101:  result        = ~a;             // NOT
            3'b110:  result        = a << 1;         // Left Shift
            3'b111:  result        = a >> 1;         // Right Shift
            default: result        = 8'b0;
        endcase
    end

endmodule

// ─── Testbench ────────────────────────────────────────
module alu_8bit_tb;

    reg  [7:0] a, b;
    reg  [2:0] sel;
    wire [7:0] result;
    wire       carry, zero, negative;

    alu_8bit uut (
        .a(a), .b(b), .sel(sel),
        .result(result),
        .carry(carry),
        .zero(zero),
        .negative(negative)
    );

    initial begin
        $dumpfile("alu_8bit.vcd");
        $dumpvars(0, uut);

        $display("============================================");
        $display(" SEL |    A    |    B    | Result  | C Z N");
        $display("============================================");
        $monitor(" %3b | %8b| %8b| %8b| %b %b %b",
                  sel, a, b, result, carry, zero, negative);

        // Addition
        sel=3'b000; a=8'd15;  b=8'd10;  #100;   // 15+10=25
        sel=3'b000; a=8'd200; b=8'd100; #100;   // 200+100=300 (overflow)

        // Subtraction
        sel=3'b001; a=8'd50;  b=8'd20;  #100;   // 50-20=30
        sel=3'b001; a=8'd10;  b=8'd20;  #100;   // 10-20 (underflow)

        // AND
        sel=3'b010; a=8'b11001100; b=8'b10101010; #100;

        // OR
        sel=3'b011; a=8'b11001100; b=8'b10101010; #100;

        // XOR
        sel=3'b100; a=8'b11001100; b=8'b10101010; #100;

        // NOT
        sel=3'b101; a=8'b11001100; b=8'b00000000; #100;

        // Left Shift
        sel=3'b110; a=8'b00001111; b=8'b00000000; #100;

        // Right Shift
        sel=3'b111; a=8'b11110000; b=8'b00000000; #100;

        // Zero Flag Test
        sel=3'b010; a=8'b00000000; b=8'b00000000; #100;

        $finish;
    end

endmodule
