`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage. 
    sign_extend imm (
    .sign_ex_in(instr[15:0]),
    .sign_ex_out(imm_value)
    );
    assign jump_address = instr[25:0] * 4;
    assign branch_address = pc_plus4 + imm_value*4;
    wire reg_dst;
    wire branch;
    wire imem_to_reg, imem_read, imem_write, ialu_src, ireg_write;
    wire [1:0]ialu_op;
    
    
    wire controlmuxsel;
    assign controlmuxsel = !Data_Hazard || Control_Hazard;
    
    control controlUnit(
    .reset(reset),
    .opcode(instr[31:26]),
    .reg_dst(reg_dst),
    .mem_to_reg(imem_to_reg),
    .alu_op(ialu_op),
    .mem_read(imem_read), .mem_write(imem_write), .alu_src(ialu_src), .reg_write(ireg_write),
    .branch(branch), .jump(jump)
    );
    mux2 #(.mux_width(1)) memtoregmux(
    .a(imem_to_reg),
    .b(1'b0),
    .sel(controlmuxsel),
    .y(mem_to_reg)
    );
    mux2 #(.mux_width(2)) aluopmux(
    .a(ialu_op),
    .b(1'b0),
    .sel(controlmuxsel),
    .y(alu_op)
    );
    mux2 #(.mux_width(1)) memreadmux(
    .a(imem_read),
    .b(1'b0),
    .sel(controlmuxsel),
    .y(mem_read)
    );
    mux2 #(.mux_width(1)) memwritemux(
    .a(imem_write),
    .b(1'b0),
    .sel(controlmuxsel),
    .y(mem_write)
    );
    mux2 #(.mux_width(1)) alusrcmux(
    .a(ialu_src),
    .b(1'b0),
    .sel(controlmuxsel),
    .y(alu_src)
    );
    mux2 #(.mux_width(1)) regwritemux(
    .a(ireg_write),
    .b(1'b0),
    .sel(controlmuxsel),
    .y(reg_write)
    );
    
    register_file file (
    .clk(clk),
    .reset(reset),  
    .reg_write_en(mem_wb_reg_write),  
    .reg_write_dest(mem_wb_write_reg_addr),  
    .reg_write_data(mem_wb_write_back_data),
    .reg_read_addr_1(instr[25:21]), 
    .reg_read_addr_2(instr[20:16]),  
    .reg_read_data_1(reg1),  
    .reg_read_data_2 (reg2)
    ) ;
    mux2 #(.mux_width(5)) desReg (
    .a(instr[20:16]),
    .b(instr[15:11]),
    .sel(reg_dst),
    .y(destination_reg)
    );
    
    assign eq_test_signal = ((reg1^reg2 )==32'd0) ? 1'b1 : 1'b0 ;
    assign branch_taken = eq_test_signal && (branch);
    

    
    
       
endmodule
