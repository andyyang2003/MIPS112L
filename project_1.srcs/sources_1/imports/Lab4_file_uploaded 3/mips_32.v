`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2
    wire [9:0] branch_address; 
    wire [9:0] jump_address;
    wire branch_taken;
    wire jump;
    wire en; 
    wire [9:0] pc_plus4;
    wire [31:0] instr;
    wire [9:0] if_id_pc_plus4;
    wire [31:0] if_id_instr;
    
    

    wire [31:0] write_back_data;
    wire [4:0] mem_wb_destination_reg;
    
    wire [31:0] reg1, reg2;
    wire [31:0] imm_value;
    wire [31:0] alu_in2;
    wire [1:0] alu_op;
    wire mem_read, mem_write, alu_src, reg_write, mem_to_reg;
    wire [4:0] destination_reg;
    wire Data_Hazard;
    wire IF_Flush;
    
    wire [31:0] mem_read_data;
    wire [31:0] id_ex_instr;
    wire [31:0] id_ex_reg1, id_ex_reg2;
    wire [31:0] id_ex_imm_value;
    wire [4:0] id_ex_destination_reg;
    wire [1:0] id_ex_alu_op;
    wire id_ex_mem_read, id_ex_mem_write, id_ex_alu_src, id_ex_reg_write;
    wire id_ex_mem_to_reg;
    wire [31:0] alu_in2_out;
    wire [31:0] alu_result;

    wire [31:0] ex_mem_alu_result;
    wire ex_mem_reg_write;
    wire [4:0] ex_mem_write_reg_addr;
    wire [31:0] ex_mem_instr;
    wire [4:0] ex_mem_destination_reg;
    wire [31:0] ex_mem_alu_in2_out;
    wire ex_mem_mem_to_reg, ex_mem_mem_read, ex_mem_mem_write, ex_mem_reg_write;
   
    wire [4:0] id_ex_instr_rs, id_ex_instr_rt;
    
    wire [1:0] Forward_A, Forward_B;
    
    wire mem_wb_reg_write, mem_wb_mem_to_reg;
    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_mem_read_data;
   
     
    
    
// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    // Complete your code here      
    IF_pipe_stage IF (
    .clk(clk),
    .reset(reset),
    .en(Data_Hazard),
    .branch_address(branch_address),
    .branch_taken(branch_taken),
    .jump(jump),
    .jump_address(jump_address),
    .instr(instr),
    .pc_plus4(pc_plus4)
    );
    
///////////////////////////// IF/ID registers
    // Complete your code here
    
    pipe_reg_en #(.WIDTH(10)) regpcplus4(
    .clk(clk), .reset(reset),
    .en(Data_Hazard), .flush(IF_Flush),
    .d(pc_plus4),
    .q(if_id_pc_plus4)
    );
    pipe_reg_en #(.WIDTH(32)) reginstr(
    .clk(clk), .reset(reset),
    .en(Data_Hazard), .flush(IF_Flush),
    .d(instr),
    .q(if_id_instr)
    );

///////////////////////////// Instruction Decode 
	// Complete your code here
	
    ID_pipe_stage ID (
    .clk(clk), .reset(reset),
    .pc_plus4(if_id_pc_plus4), .instr(if_id_instr), .mem_wb_reg_write(mem_wb_reg_write),
    .mem_wb_write_back_data(write_back_data),.mem_wb_write_reg_addr(mem_wb_destination_reg),
    .Data_Hazard(Data_Hazard), .Control_Hazard(IF_Flush),
    .reg1(reg1), .reg2(reg2), .imm_value(imm_value), .branch_address(branch_address), .jump_address(jump_address),
    .branch_taken(branch_taken), .destination_reg(destination_reg), .alu_op(alu_op), .mem_to_reg(mem_to_reg),
    .mem_read(mem_read), .mem_write(mem_write), .alu_src(alu_src), .reg_write(reg_write)
    );
             
///////////////////////////// ID/EX registers 
	// Complete your code here
	pipe_reg #(.WIDTH(32)) r1(
    .clk(clk), .reset(reset),
    .d(if_id_instr),
    .q(id_ex_instr)
    );
    pipe_reg #(.WIDTH(32)) r2(
    .clk(clk), .reset(reset),
    .d(reg1),
    .q(id_ex_reg1)
    );
    pipe_reg #(.WIDTH(32)) r3(
    .clk(clk), .reset(reset),
    .d(reg2),
    .q(id_ex_reg2)
    );
    pipe_reg #(.WIDTH(32)) r4(
    .clk(clk), .reset(reset),
    .d(imm_value),
    .q(id_ex_imm_value)
    );
    pipe_reg #(.WIDTH(5)) r5(
    .clk(clk), .reset(reset),
    .d(destination_reg),
    .q(id_ex_destination_reg)
    );
    pipe_reg #(.WIDTH(1)) r6(
    .clk(clk), .reset(reset),
    .d(mem_to_reg),
    .q(id_ex_mem_to_reg)
    );
    pipe_reg #(.WIDTH(1)) r7(
    .clk(clk), .reset(reset),
    .d(mem_read),
    .q(id_ex_mem_read)
    );
    pipe_reg #(.WIDTH(1)) r8(
    .clk(clk), .reset(reset),
    .d(mem_write),
    .q(id_ex_mem_write)
    );
    pipe_reg #(.WIDTH(1)) r9(
    .clk(clk), .reset(reset),
    .d(alu_src),
    .q(id_ex_alu_src)
    );
    pipe_reg #(.WIDTH(1)) r10(
    .clk(clk), .reset(reset),
    .d(reg_write),
    .q(id_ex_reg_write)
    );    
    pipe_reg #(.WIDTH(2)) r11(
    .clk(clk), .reset(reset),
    .d(alu_op),
    .q(id_ex_alu_op)
    );

///////////////////////////// Hazard_detection unit
	// Complete your code here    
    Hazard_detection HUnit (
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_destination_reg(id_ex_destination_reg),
    .if_id_rs(if_id_instr[25:21]), .if_id_rt(if_id_instr[20:16]),
    .branch_taken(branch_taken), .jump(jump),
    .Data_Hazard(Data_Hazard),
    .IF_Flush(IF_Flush)
    );
           
///////////////////////////// Execution    
	// Complete your code here
	EX_pipe_stage EX(
	.id_ex_instr(id_ex_instr), .reg1(id_ex_reg1), .reg2(id_ex_reg2), .id_ex_imm_value(id_ex_imm_value),
	.ex_mem_alu_result(ex_mem_alu_result), .mem_wb_write_back_result(write_back_data), .id_ex_alu_src(id_ex_alu_src),
	.id_ex_alu_op(id_ex_alu_op), .Forward_A(Forward_A), .Forward_B(Forward_B), .alu_in2_out(alu_in2_out), .alu_result(alu_result)
	);
        
///////////////////////////// Forwarding unit
	// Complete your code here 
    EX_Forwarding_unit FW(
    .ex_mem_reg_write(ex_mem_reg_write),
    .ex_mem_write_reg_addr(ex_mem_destination_reg),
    .id_ex_instr_rs(id_ex_instr_rs),
    .id_ex_instr_rt(id_ex_instr_rt),
    .mem_wb_reg_write(mem_wb_write),
    .mem_wb_write_reg_addr(mem_wb_destination_reg),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B)
    );
     
///////////////////////////// EX/MEM registers
	// Complete your code here 
    pipe_reg #(.WIDTH(32)) idexinstr(
    .clk(clk), .reset(reset),
    .d(id_ex_instr),
    .q(ex_mem_instr)
    );
    pipe_reg #(.WIDTH(5)) idexdesreg(
    .clk(clk), .reset(reset),
    .d(id_ex_destination_reg),
    .q(ex_mem_destination_reg)
    );
    pipe_reg #(.WIDTH(32)) alures(
    .clk(clk), .reset(reset),
    .d(alu_result),
    .q(ex_mem_alu_result)
    );
    pipe_reg #(.WIDTH(32)) aluin2(
    .clk(clk), .reset(reset),
    .d(alu_in2_out),
    .q(ex_mem_alu_in2_out)
    );
    pipe_reg #(.WIDTH(1)) regmemreg(
    .clk(clk), .reset(reset),
    .d(id_ex_mem_to_reg),
    .q(ex_mem_mem_to_reg)
    );
    pipe_reg #(.WIDTH(1)) regmemread(
    .clk(clk), .reset(reset),
    .d(id_ex_mem_read),
    .q(ex_mem_mem_read)
    );
    pipe_reg #(.WIDTH(1)) regmemwrite(
    .clk(clk), .reset(reset),
    .d(id_ex_mem_write),
    .q(ex_mem_mem_write)
    );
    pipe_reg #(.WIDTH(1)) regwrite(
    .clk(clk), .reset(reset),
    .d(id_ex_reg_write),
    .q(ex_mem_reg_write)
    );
    
///////////////////////////// memory    
	// Complete your code here
	data_memory data_mem(
	.clk(clk), .mem_access_addr(ex_mem_alu_result),
	.mem_write_data(ex_mem_alu_in2_out),
	.mem_write_en(ex_mem_mem_write),
	.mem_read_en(ex_mem_mem_read),
	.mem_read_data(mem_read_data)
	);
     

///////////////////////////// MEM/WB registers  
	// Complete your code here
    pipe_reg #(.WIDTH(32)) mwb1(
    .clk(clk), .reset(reset),
    .d(ex_mem_alu_result),
    .q(mem_wb_alu_result)
    );

    pipe_reg #(.WIDTH(32)) mwb2(
    .clk(clk), .reset(reset),
    .d(mem_read_data),
    .q(mem_wb_mem_read_data)
    );
    
    pipe_reg #(.WIDTH(1)) mwb3(
    .clk(clk), .reset(reset),
    .d(ex_mem_mem_to_reg),
    .q(mem_wb_mem_to_reg)
    );
    pipe_reg #(.WIDTH(1)) mwb4(
    .clk(clk), .reset(reset),
    .d(ex_mem_reg_write),
    .q(mem_wb_reg_write)
    );
    pipe_reg #(.WIDTH(5)) mwb5(
    .clk(clk), .reset(reset),
    .d(ex_mem_destination_reg),
    .q(mem_wb_destination_reg)
    );
    
///////////////////////////// writeback    
	// Complete your code here
    mux2 #(.mux_width(32))wbmux (
    .a(mem_wb_alu_result),
    .b(mem_wb_mem_read_data),
    .sel(mem_wb_mem_to_reg),
    .y(write_back_data)
    );
    assign result = write_back_data;
    
endmodule
