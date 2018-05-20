
`timescale 1 ns / 1 ps

	module sw_reset_ip_v1_0 #
	(
		// Users to add parameters here
        
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
		// User ports ends
		// Do not modify the ports beyond this line

        output wire [7:0] po_h_data,
        output wire [7:0] po_v_data,
		// Ports of Axi Slave Bus Interface S00_AXI
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
		input wire  s00_axi_rready
	);
	
	wire [4:0]     axil_data;
	wire [63:0]    h_data;
	reg  [2:0]     cnt;            
	
// Instantiation of Axi Bus Interface S00_AXI
	sw_reset_ip_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) sw_reset_ip_v1_0_S00_AXI_inst (
	    .po_matrix_value(axil_data),
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

    bram_led #(.WADDR(4),.WDATA(64))
    (
        .pi_clk     (s00_axi_aclk), 
        .pi_en      (axil_data[4]),
        .pi_addr    (axil_data[3:0]),
        .po_data    (h_data)
    );

	always @(posedge s00_axi_aclk) begin
	   if(!s00_axi_aresetn)
	       cnt <= 4'h0;
       else
        cnt <= cnt + 4'h1;
	end

assign po_h_data = (cnt == 4'h0) ? h_data[7:0]   :
                   (cnt == 4'h1) ? h_data[15:8]  :
                   (cnt == 4'h2) ? h_data[23:16] :
                   (cnt == 4'h3) ? h_data[31:24] :
                   (cnt == 4'h4) ? h_data[39:32] :
                   (cnt == 4'h5) ? h_data[47:40] :
                   (cnt == 4'h6) ? h_data[55:48] :
                   (cnt == 4'h7) ? h_data[63:56] : 8'h00;
                   
assign po_v_data = (cnt == 4'h0) ? (~8'h01) :
                   (cnt == 4'h1) ? (~8'h02) :
                   (cnt == 4'h2) ? (~8'h04) :
                   (cnt == 4'h3) ? (~8'h08) :
                   (cnt == 4'h4) ? (~8'h10) :
                   (cnt == 4'h5) ? (~8'h20) :
                   (cnt == 4'h6) ? (~8'h40) :
                   (cnt == 4'h7) ? (~8'h80) : 8'h00;

	endmodule
