`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    reg [9:0] pc;
    wire [9:0] branchaddy;
    wire [9:0] jumpaddy;
    always @(posedge clk or posedge reset)  
    begin   
        if(reset == 1'b1)   
           pc <= 10'b0000000000;  
        else 
        begin
        if (en == 1'b1)  
           pc <= jumpaddy;   
        end
    end  
 
    assign pc_plus4 = pc + 10'b0000000100;
    
    mux2 #(.mux_width(10)) mux2a (
    .a(pc_plus4),
    .b(branch_address),
    .sel(branch_taken),
    .y(branchaddy)
    );
    mux2 #(.mux_width(10)) mux2b (
    .a(branchaddy),
    .b(jump_address),
    .sel(jump),
    .y(jumpaddy)
    );
    
    instruction_mem instruction_mem (
    .read_addr(pc),
    .data(instr)
    );
    
endmodule
