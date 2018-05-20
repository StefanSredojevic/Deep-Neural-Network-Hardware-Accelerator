//`timescale 1ns/1ps
`include "../tb/top_module_tb_class.sv"

module top_module_tb ();

    `include "../tb/mnist_inputs_weights_biases_bin.sv"

	// instantiate interface
	top_module_interface tm_if();
	
	// instantiate dut and connecting it with interface
	top_module #(.C_S00_AXI_DATA_WIDTH	(32),
		         .C_S00_AXI_ADDR_WIDTH	(5),
		         .C_S00_AXIS_TDATA_WIDTH(32),
		         .C_M00_AXIS_TDATA_WIDTH(32))
		top_module_dut
		(
            //Ports of Axi Slave Bus Interface S00_AXI
            .s00_axi_aclk    (tm_if.s00_axi_aclk   ),    
            .s00_axi_aresetn (tm_if.s00_axi_aresetn), 
            .s00_axi_awaddr  (tm_if.s00_axi_awaddr ),  
            .s00_axi_awprot  (tm_if.s00_axi_awprot ),  
            .s00_axi_awvalid (tm_if.s00_axi_awvalid), 
            .s00_axi_awready (tm_if.s00_axi_awready), 
            .s00_axi_wdata   (tm_if.s00_axi_wdata  ),   
            .s00_axi_wstrb   (tm_if.s00_axi_wstrb  ),   
            .s00_axi_wvalid  (tm_if.s00_axi_wvalid ),  
            .s00_axi_wready  (tm_if.s00_axi_wready ),  
            .s00_axi_bresp   (tm_if.s00_axi_bresp  ),   
            .s00_axi_bvalid  (tm_if.s00_axi_bvalid ),  
            .s00_axi_bready  (tm_if.s00_axi_bready ),  
            .s00_axi_araddr  (tm_if.s00_axi_araddr ),  
            .s00_axi_arprot  (tm_if.s00_axi_arprot ),  
            .s00_axi_arvalid (tm_if.s00_axi_arvalid), 
            .s00_axi_arready (tm_if.s00_axi_arready), 
            .s00_axi_rdata   (tm_if.s00_axi_rdata  ),   
            .s00_axi_rresp   (tm_if.s00_axi_rresp  ),   
            .s00_axi_rvalid  (tm_if.s00_axi_rvalid ),  
            .s00_axi_rready  (tm_if.s00_axi_rready ),  
            //Ports of Axi Slave Bus Interface S00_AXIS                 
            .s00_axis_aclk   (tm_if.s00_axis_aclk  ),   
            .s00_axis_aresetn(tm_if.s00_axis_aresetn),
            .s00_axis_tready (tm_if.s00_axis_tready), 
            .s00_axis_tdata  (tm_if.s00_axis_tdata ),  
            .s00_axis_tstrb  (tm_if.s00_axis_tstrb ),  
            .s00_axis_tlast  (tm_if.s00_axis_tlast ),  
            .s00_axis_tvalid (tm_if.s00_axis_tvalid), 
            //Ports of Axi Master Bus Interface M00_AXIS                 
            .m00_axis_aclk   (tm_if.m00_axis_aclk  ),   
            .m00_axis_aresetn(tm_if.m00_axis_aresetn),
            .m00_axis_tvalid (tm_if.m00_axis_tvalid), 
            .m00_axis_tdata  (tm_if.m00_axis_tdata ),  
            .m00_axis_tstrb  (tm_if.m00_axis_tstrb ),  
            .m00_axis_tlast  (tm_if.m00_axis_tlast ),  
            .m00_axis_tready (tm_if.m00_axis_tready)         
		);

	event e1;
	real percent;

    always
       #20 tm_if.clk();
    
	initial begin
		tm_if.nn_start_pictures(784,16,16,10,500.0,percent);
		$display("Accuracy = %f \n", percent);
		-> e1;
	end

    initial begin
		@(e1);
		repeat(100)@(posedge tm_if.s00_axi_aclk);
		$finish();
	end
	
	initial
		#3000ms $finish();
	
endmodule : top_module_tb
