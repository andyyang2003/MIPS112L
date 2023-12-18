`timescale 1ns / 1ps


module mux3#(parameter mux_width= 32)(
    input [mux_width-1:0] a,b,c,
    input [1:0] sel,
    output [mux_width-1:0] y
    );
    
    assign y = sel[1] ? c : (sel[0] ? b : a);
    
endmodule
