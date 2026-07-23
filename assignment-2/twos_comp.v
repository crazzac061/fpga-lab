//=============================================================
// twos_comp.v
// Combinational 8-bit 2's complement (negation) unit
//=============================================================
`timescale 1ns/1ps

module twos_comp (
    input  wire [7:0] in,
    output wire [7:0] out
);

    assign out = (~in) + 8'd1;

endmodule
