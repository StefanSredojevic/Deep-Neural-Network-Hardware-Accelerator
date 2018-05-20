
`timescale 1 ns / 1 ps

	module UART_AXI_v1_0 #
	(
		// Users to add parameters here
        parameter DATA_WIDTH = 8,
        parameter FIFO_DEPTH_R = 4,
        parameter FIFO_DEPTH_T = 5,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire pi_RX,
		output wire po_TX,  
		output wire po_tlast,
		output wire po_tran_over,
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
	wire w_stop_bits;
	wire [14:0] w_baud_rate;
	wire [DATA_WIDTH-1:0] w_t_data;
	wire w_start_tran;
	wire w_fifo_write_en;
	wire w_read_data;
	wire [19:0] w_set_tlast;
	wire [(DATA_WIDTH*FIFO_DEPTH_R)-1:0] w_r_data;
	wire w_rec_error;
	wire w_tran_over;
	wire w_fifo_write_over;
	wire w_fifo_full;
    wire w_data_avaliable;
	wire w_tlast;

// Instantiation of Axi Bus Interface S00_AXI
	UART_AXI_v1_0_S00_AXI # ( 
	    .DATA_WIDTH(DATA_WIDTH),
	    .FIFO_DEPTH_R(FIFO_DEPTH_R),
	    .FIFO_DEPTH_T(FIFO_DEPTH_T),
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) UART_AXI_v1_0_S00_AXI_inst (
	    .po_baud_rate(w_baud_rate),
	    .po_stop_bits(w_stop_bits),
	    .po_t_data(w_t_data),
        .po_start_tran(w_start_tran),
        .po_fifo_write_en(w_fifo_write_en),
        .po_set_tlast(w_set_tlast),
        .pi_rec_error(w_rec_error),
        .pi_fifo_write_over(w_fifo_write_over),
        .pi_fifo_full(w_fifo_full),
        .pi_tlast(w_tlast),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

// Instantiation of Axi Bus Interface M00_AXIS
	axis_master # (
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) axis_master (
	    .po_read_data(w_read_data),
	    .pi_r_data(w_r_data),
	    .pi_data_avaliable(w_data_avaliable),
	    .pi_tlast(w_tlast),
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

	// Add user logic here
    uart_top #( .DATA_WIDTH(DATA_WIDTH),
                .FIFO_DEPTH_R(FIFO_DEPTH_R),
                .FIFO_DEPTH_T(FIFO_DEPTH_T))uart_top_inst(
                .pi_clk(m00_axis_aclk),
                .pi_rst(m00_axis_aresetn),
                .pi_stop_bits(w_stop_bits),
                .pi_baud_rate(w_baud_rate), //lite
                .pi_t_data(w_t_data), //lite
                .pi_start_tran(w_start_tran), //lite
                .pi_fifo_write_en(w_fifo_write_en), //lite
                .pi_ur_data(pi_RX), //extern
                .pi_read_data(w_read_data), //stream
                .pi_set_tlast(w_set_tlast), //lite
                .po_r_data(w_r_data), //stream
                .po_rec_error(w_rec_error),  //lite
                .po_ut_data(po_TX), //extern
                .po_tran_over(po_tran_over), //interrupt
                .po_fifo_write_over(w_fifo_write_over), //lite
                .po_fifo_full(w_fifo_full),//lite
                .po_data_avaliable(w_data_avaliable),//stream
                .po_tlast(w_tlast));//stream
	// User logic ends
    assign po_tlast = w_data_avaliable;
	endmodule
