
`timescale 1ns/1ps
`include "../tb/axis_slave_tb_class.sv"

module axis_slave_tb ();

	// instantiate interface
	axis_slave_interface axi_if();
	
	// instantiate dut and connecting it with interface
	axis_slave #(.C_S_AXIS_TDATA_WIDTH(32))
		axis_slave_dut
		(
			.pi_data_read		(axi_if.pi_data_read),
			.po_mlp_data_valid	(axi_if.po_mlp_data_valid), 
			.po_mlp_data		(axi_if.po_mlp_data),
			.S_AXIS_ACLK		(axi_if.S_AXIS_ACLK),     
			.S_AXIS_ARESETN		(axi_if.S_AXIS_ARESETN),
			.S_AXIS_TREADY	    (axi_if.S_AXIS_TREADY),
			.S_AXIS_TDATA		(axi_if.S_AXIS_TDATA),    
			.S_AXIS_TSTRB		(axi_if.S_AXIS_TSTRB),       
			.S_AXIS_TLAST		(axi_if.S_AXIS_TLAST),       
			.S_AXIS_TVALID		(axi_if.S_AXIS_TVALID)   
		);

    initial
        axi_if.init();

    //Creating verification scenario
    always @(posedge axi_if.S_AXIS_ACLK)
       axi_if.send_rnd_data();
    
    always @(posedge axi_if.S_AXIS_ACLK)
    	axi_if.run_data_read();

    //Deciding when to finish simulation
	initial
		#5000 $finish();
	
    //Clock stimulus
	always begin
		#20 axi_if.S_AXIS_ACLK <= ~axi_if.S_AXIS_ACLK;	
	end
	
endmodule : axis_slave_tb
