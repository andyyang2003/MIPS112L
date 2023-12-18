module top;

	wire [15:0] z80_wb_addr_o;

	z80_core_top u_z80(
		.wb_clk_i (wb_clk_i),
		.wb_rst_i (wb_rst_i),

		.wb_dat_o (z80_wb_data_o),
		.wb_stb_o (z80_wb_stb_o),
		.wb_cyc_o (z80_wb_cyc_o),
		.wb_we_o  (z80_wb_we_o),
		.wb_adr_o (z80_wb_addr_o),
		.wb_tga_o (),
		.wb_ack_i (z80_wb_ack_i),
		.wb_dat_i (z80_wb_data_i),

		.int_req_i(1'b0)
	);
	// u_wb_i2c_slave_1
	assign u_wb_i2c_slave_1_wb_addr_i = {1'b0,z80_wb_addr_o[14:0]};
	assign u_wb_i2c_slave_1_wb_stb_i  = z80_wb_addr_o[15] ? z80_wb_stb_o : 0;
	assign u_wb_i2c_slave_1_wb_cyc_i  = z80_wb_addr_o[15] ? z80_wb_cyc_o : 0;
	assign u_wb_i2c_slave_1_wb_we_i   = z80_wb_addr_o[15] ? z80_wb_we_o : 0;
	assign u_wb_i2c_slave_1_wb_data_i = z80_wb_data_o;
	
	// u_wb_i2c_slave_2
	assign u_wb_i2c_slave_2_wb_addr_i = {1'b1,z80_wb_addr_o[14:0]};
	assign u_wb_i2c_slave_2_wb_stb_i  = z80_wb_addr_o[15] ? 0 : z80_wb_stb_o;
	assign u_wb_i2c_slave_2_wb_cyc_i  = z80_wb_addr_o[15] ? 0 : z80_wb_cyc_o;
	assign u_wb_i2c_slave_2_wb_we_i   = z80_wb_addr_o[15] ? 0 : z80_wb_we_o;
	assign u_wb_i2c_slave_2_wb_data_i = z80_wb_data_o;
    
    wire u_wb_i2c_slave_1_wb_data_o, u_wb_i2c_slave_2_wb_data_o, u_wb_i2c_slave_1_wb_ack_o, u_wb_i2c_slave_2_wb_ack_o;
	assign z80_wb_data_i = z80_wb_addr_o[15] ? u_wb_i2c_slave_1_wb_data_o : u_wb_i2c_slave_2_wb_data_o;	
	assign z80_wb_ack_i = z80_wb_addr_o[15] ? u_wb_i2c_slave_1_wb_ack_o : u_wb_i2c_slave_2_wb_ack_o;

	I2C16bits_wrapper u_wb_i2c_slave_1(
		.wb_clk_i(wb_clk_i), //master clock input
		.wb_rst_i(wb_rst_i), //synchronous active high reset
		.i2c16_wb_adr_i(u_wb_i2c_slave_1_wb_addr_i), //WB slave; I2C reg number
		.i2c16_wb_dat_i(u_wb_i2c_slave_1_wb_data_i), //I2C data to write
		.i2c16_wb_dat_o(u_wb_i2c_slave_1_wb_data_o), //I2C data read
		.i2c16_wb_we_i(u_wb_i2c_slave_1_wb_we_i), //Write enable input
		.i2c16_wb_stb_i(u_wb_i2c_slave_1_wb_stb_i), //Strobe signals / core select signal
		.i2c16_wb_cyc_i(u_wb_i2c_slave_1_wb_cyc_i), //Valid bus cycle input
		.i2c16_wb_ack_o(u_wb_i2c_slave_1_wb_ack_o), //Bus cycle acknowledge output
		.i2c16_wb_err_o(), //Bus cycle error output

		.scl_pad_i(u_jop1_scl_line), //i2c lines; i2c clock line input
		.scl_pad_o(u_wb_i2c_slave_1_scl_o), //i2c clock line output
		.scl_padoen_o(u_wb_i2c_slave_1_scl_oe), //i2c clock line output enable, active low
		.sda_pad_i(u_jop1_sda_line), //i2c data line input
		.sda_pad_o(u_wb_i2c_slave_1_sda_o), //i2c data line output
		.sda_padoen_o(u_wb_i2c_slave_1_sda_oe) //i2c data line output enable, active low
	);

	blocku u_wb_i2c_slave_2(
		.wb_clk_i(wb_clk_i),
		.wb_rst_i(wb_rst_i),
		.wb_add_i(u_wb_i2c_slave_2_wb_addr_i),
		.wb_data_i(u_wb_i2c_slave_2_wb_data_i),
		.wb_data_o(u_wb_i2c_slave_2_wb_data_o),
		.wb_we_i(u_wb_i2c_slave_2_wb_we_i),
		.wb_stb_i(u_wb_i2c_slave_2_wb_stb_i),
		.wb_cyc_i(u_wb_i2c_slave_2_wb_cyc_i),
		.wb_ack_o(u_wb_i2c_slave_2_wb_ack_o),

		.irq(),
		.trans_comp(),

		.scl_oe(u_wb_i2c_slave_2_scl_oe),
		.scl_in(u_jop2_scl_line),
		.scl_o(u_wb_i2c_slave_2_scl_o),
		.sda_oe(u_wb_i2c_slave_2_sda_oe),
		.sda_in(u_jop2_sda_line),
		.sda_o(u_wb_i2c_slave_2_sda_o)
	);


	pullup u_jop1_sda_pullup(u_jop1_sda_line);
	assign u_jop1_sda_line = u_wb_i2c_slave_1_sda_oe ? u_wb_i2c_slave_1_sda_o : 1'bz;

	pullup u_jop1_scl_pullup(u_jop1_scl_line);
	assign u_jop1_scl_line = u_wb_i2c_slave_1_scl_oe ? u_wb_i2c_slave_1_scl_o : 1'bz;
    wire [31:0] ram_data ;
    wire [31:0] ram_data_2;   
    
	jop_iic u_jop1(
		.clk     (jop_clk),
		.ser_txd (), //serial interface
		.ser_rxd (0),
		.ser_ncts(0),
		.ser_nrts(),
		.wd      (), //watchdog
		.freeio  (),
		.rama_a  (), //two ram banks
		.rama_d  (ram_data[15:0]),
		.rama_ncs(ram_ncs),
		.rama_noe(ram_noe),
		.rama_nlb(),
		.rama_nub(),
		.rama_nwe(ram_nwr),
		.ramb_a  (ram_addr),
		.ramb_d  (ram_data[31:16]),
		.ramb_ncs(),
		.ramb_noe(),
		.ramb_nlb(),
		.ramb_nub(),
		.ramb_nwe(),
		.fl_a    (fl_a), //config/program flash and big nand flash
		.fl_d    (fl_d),
		.fl_ncs  (fl_ncs),
		.fl_ncsb (fl_ncsb),
		.fl_noe  (fl_noe),
		.fl_nwe  (fl_nwe),
		.fl_rdy  (1),
		.io_b    (io_b), //I/O pins of board
		.io_l    (io_l),
		.io_r    (io_r),
		.io_t    (io_t),
		.oLEDR   (),
		.iSW     (iSW), //Switches
		.sda     (u_jop1_sda_line), //i2c
		.scl     (u_jop1_sda_line)
	);

	pullup u_jop2_sda_pullup(u_jop2_sda_line);
	assign u_jop2_sda_line = u_wb_i2c_slave_2_sda_oe ? u_wb_i2c_slave_2_sda_o : 1'bz;

	pullup u_jop2_scl_pullup(u_jop2_scl_line);
	assign u_jop2_scl_line = u_wb_i2c_slave_2_scl_oe ? u_wb_i2c_slave_2_scl_o : 1'bz;

	jop_iic u_jop2(
		.clk     (jop_clk),
		.ser_txd (), //serial interface
		.ser_rxd (0),
		.ser_ncts(0),
		.ser_nrts(),
		.wd      (), //watchdog
		.freeio  (),
		.rama_a  (), //two ram banks
		.rama_d  (ram_data_2[15:0]),
		.rama_ncs(ram_ncs_2),
		.rama_noe(ram_noe_2),
		.rama_nlb(),
		.rama_nub(),
		.rama_nwe(ram_nwr_2),
		.ramb_a  (ram_addr_2),
		.ramb_d  (ram_data_2[31:16]),
		.ramb_ncs(),
		.ramb_noe(),
		.ramb_nlb(),
		.ramb_nub(),
		.ramb_nwe(),
		.fl_a    (fl_a_2), //config/program flash and big nand flash
		.fl_d    (fl_d_2),
		.fl_ncs  (fl_ncs_2),
		.fl_ncsb (fl_ncsb_2),
		.fl_noe  (fl_noe_2),
		.fl_nwe  (fl_nwe_2),
		.fl_rdy  (1),
		.io_b    (io_b_2), //I/O pins of board
		.io_l    (io_l_2),
		.io_r    (io_r_2),
		.io_t    (io_t_2),
		.oLEDR   (),
		.iSW     (iSW_2), //Switches
		.sda     (u_jop2_sda_line), //i2c
		.scl     (u_jop2_sda_line)
	);

	memory #(.data_bits(32)) u_memory_1  (
		.addr(ram_addr),
		.data(ram_data),
		.ncs (ram_ncs),
		.noe (ram_noe),
		.nwr (ram_nwr)
	);
	
	memory #(.data_bits(32)) u_memory_2  (
		.addr(ram_addr_2),
		.data(ram_data_2),
		.ncs (ram_ncs_2),
		.noe (ram_noe_2),
		.nwr (ram_nwr_2)
	);  

endmodule
