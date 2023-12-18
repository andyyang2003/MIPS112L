`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    wire [3:0] ALU_Control;
    wire [31:0] reg1out;
    wire [31:0] reg2out;
    wire [31:0] mux3out;
    ALUControl ALUctrl (
    .ALUOp(id_ex_alu_op),
    .Function(id_ex_instr[5:0]),
    .ALU_Control(ALU_Control)
    );
    mux4 #(.mux_width(32)) mux1(
    .a(reg1),
    .b(mem_wb_write_back_result),
    .c(ex_mem_alu_result),
    .d(0),
    .sel(Forward_A),
    .y(reg1out)
    );
    mux4 #(.mux_width(32)) mux2(
    .a(reg2),
    .b(mem_wb_write_back_result),
    .c(ex_mem_alu_result),
    .d(0),
    .sel(Forward_B),
    .y(reg2out)
    );
    assign alu_in2_out = reg2out;
    mux2 #(.mux_width(32)) mux3(
    .a(reg2out),
    .b(id_ex_imm_value),
    .sel(id_ex_alu_src),
    .y(mux3out)
    );
    ALU ALUunit(
    .a(reg1out),
    .b(mux3out),
    .alu_control(ALU_Control),
    .alu_result(alu_result)
    );
    
    
    // Write your code here
        
       
endmodule
