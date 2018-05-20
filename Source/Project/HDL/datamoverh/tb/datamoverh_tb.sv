`timescale 1ns/1ps

module datamoverh_tb ();

//TB SIGNALS
logic[71:0]    	po_command_t;   
logic        	po_valid_t;     	
logic        	pi_ready_t;     
logic        	S_AXI_ACLK_t;   
logic        	S_AXI_ARESETN_t;
logic[4:0]     	S_AXI_AWADDR_t; 
logic[2:0]     	S_AXI_AWPROT_t;
logic        	S_AXI_AWVALID_t;
logic        	S_AXI_AWREADY_t;
logic[31:0]    	S_AXI_WDATA_t;
logic[3:0]     	S_AXI_WSTRB_t;
logic        	S_AXI_WVALID_t;
logic        	S_AXI_WREADY_t;
logic[1:0]    	S_AXI_BRESP_t;
logic        	S_AXI_BVALID_t;
logic        	S_AXI_BREADY_t;
logic[4:0]     	S_AXI_ARADDR_t;
logic[2:0]     	S_AXI_ARPROT_t;
logic        	S_AXI_ARVALID_t;
logic        	S_AXI_ARREADY_t;
logic[31:0]   	S_AXI_RDATA_t;
logic[1:0]    	S_AXI_RRESP_t;
logic        	S_AXI_RVALID_t;
logic        	S_AXI_RREADY_t;
	
logic[31:0]		slave_data;

event e1,e2;
		
datamoverh #(.C_S_AXI_DATA_WIDTH(32),
			 .C_S_AXI_ADDR_WIDTH(5))
	datamoverh_dut(
	.po_command		(po_command_t),
	.po_valid		(po_valid_t),
	.pi_ready		(pi_ready_t),
	.S_AXI_ACLK		(S_AXI_ACLK_t),
	.S_AXI_ARESETN	(S_AXI_ARESETN_t),
	.S_AXI_AWADDR	(S_AXI_AWADDR_t),
	.S_AXI_AWPROT	(S_AXI_AWPROT_t),
	.S_AXI_AWVALID	(S_AXI_AWVALID_t),
	.S_AXI_AWREADY	(S_AXI_AWREADY_t),
	.S_AXI_WDATA	(S_AXI_WDATA_t),  
	.S_AXI_WSTRB	(S_AXI_WSTRB_t),
	.S_AXI_WVALID	(S_AXI_WVALID_t),
	.S_AXI_WREADY	(S_AXI_WREADY_t),
	.S_AXI_BRESP	(S_AXI_BRESP_t),
	.S_AXI_BVALID	(S_AXI_BVALID_t),
	.S_AXI_BREADY	(S_AXI_BREADY_t),
	.S_AXI_ARADDR	(S_AXI_ARADDR_t),
	.S_AXI_ARPROT	(S_AXI_ARPROT_t),
	.S_AXI_ARVALID	(S_AXI_ARVALID_t),
	.S_AXI_ARREADY	(S_AXI_ARREADY_t),
	.S_AXI_RDATA	(S_AXI_RDATA_t),
	.S_AXI_RRESP	(S_AXI_RRESP_t),
	.S_AXI_RVALID	(S_AXI_RVALID_t),
	.S_AXI_RREADY	(S_AXI_RREADY_t)
	);

initial begin   
	pi_ready_t		<= 0;     
	S_AXI_ACLK_t	<= 0;   
	S_AXI_ARESETN_t	<= 0;
	S_AXI_AWADDR_t	<= 0; 
	S_AXI_AWPROT_t	<= 0; 
	S_AXI_AWVALID_t	<= 0;
	S_AXI_WDATA_t	<= 0;  
	S_AXI_WSTRB_t	<= 0;  
	S_AXI_WVALID_t	<= 0;  
	S_AXI_BREADY_t	<= 0; 
	S_AXI_ARADDR_t	<= 0; 
	S_AXI_ARPROT_t	<= 0; 
	S_AXI_ARVALID_t	<= 0;
	S_AXI_RREADY_t	<= 0; 
	#50 S_AXI_ARESETN_t	<= 1;
end

always
	#20 S_AXI_ACLK_t <= ~S_AXI_ACLK_t;

initial begin
	axil_slave_write(0,32'hFFFFFFFF);
	axil_slave_write(1,32'hFFFFFFFF);
	axil_slave_write(2,32'h000003FF);
	axil_slave_write(2,32'h000007FF);
	-> e1;
	@(e2);
	axil_slave_write(0,32'hAAAAAAAA);
	axil_slave_write(1,32'hAAAAAAAA);
	axil_slave_write(2,32'h000003AA);
	axil_slave_write(2,32'h000007AA);
	$finish();
end

always begin
	@(e1);
	@(posedge S_AXI_ACLK_t);
	slave_data = 0;
	while(slave_data == 0)
		axil_slave_read(3,slave_data);	
	-> e2;
end

always begin
	@(posedge S_AXI_ACLK_t);
	if(po_valid_t)
		pi_ready_t <= 1'b1;
	else
		pi_ready_t <= 1'b0;
end

task axil_slave_write(input logic [31:0] addr,logic [31:0] data);
	@(posedge S_AXI_ACLK_t);
	S_AXI_AWADDR_t  <= addr;
	S_AXI_AWVALID_t <= 1;
	S_AXI_WDATA_t   <= data;
	S_AXI_WVALID_t  <= 1; 
	S_AXI_BREADY_t  <= 1;
	S_AXI_WSTRB_t   <= ~0;//proveri ideja je da svi biti budu 1
	wait(S_AXI_AWREADY_t); 
	@( posedge S_AXI_ACLK_t);
	S_AXI_AWVALID_t <= 0;
	S_AXI_AWADDR_t  <= 0;
	wait(S_AXI_WREADY_t); 
	@(posedge S_AXI_ACLK_t);
	S_AXI_WDATA_t   <= 0;
	S_AXI_WSTRB_t   <= 0;
	S_AXI_WVALID_t  <= 0; 
	wait(S_AXI_BVALID_t); 
	@(posedge S_AXI_ACLK_t);
	S_AXI_BREADY_t  <= 0;
	@(posedge S_AXI_ACLK_t);
endtask

task axil_slave_read(input logic [31:0] addr,output logic [31:0] data);
	@(posedge S_AXI_ACLK_t);
	S_AXI_ARADDR_t  <= addr;
	S_AXI_ARVALID_t <= 1;
	S_AXI_RREADY_t	<= 1;
	wait(S_AXI_ARREADY_t); 
	@( posedge S_AXI_ACLK_t);
	S_AXI_ARVALID_t <= 0;
	S_AXI_ARADDR_t  <= 0;
	wait(S_AXI_RVALID_t); 
	@(posedge S_AXI_ACLK_t);
	data  			<= S_AXI_RDATA_t;
	S_AXI_RREADY_t	<= 0;
	@(posedge S_AXI_ACLK_t);
endtask

endmodule : datamoverh_tb
