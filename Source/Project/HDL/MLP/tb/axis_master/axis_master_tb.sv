
`timescale 1ns/1ps
`include "../tb/axis_master_tb_class.sv"

module axis_master_tb ();

	// instantiate interface
	axis_master_interface axi_if();
	
	// instantiate dut and connecting it with interface
	axis_master #(.C_M_AXIS_TDATA_WIDTH(32))
		axis_master_dut
		(
            .pi_mlp_data        (axi_if.pi_mlp_data),
			.pi_write_to_fifo	(axi_if.pi_write_to_fifo), 
			.po_wr_fifo_done	(axi_if.po_wr_fifo_done),
			.M_AXIS_ACLK		(axi_if.M_AXIS_ACLK),     
			.M_AXIS_ARESETN		(axi_if.M_AXIS_ARESETN),
			.M_AXIS_TREADY	    (axi_if.M_AXIS_TREADY),
			.M_AXIS_TDATA		(axi_if.M_AXIS_TDATA),    
			.M_AXIS_TSTRB		(axi_if.M_AXIS_TSTRB),       
			.M_AXIS_TLAST		(axi_if.M_AXIS_TLAST),       
			.M_AXIS_TVALID		(axi_if.M_AXIS_TVALID)   
		);
	
    logic [31:0] data;

    initial begin
   		data <= 0;
        axi_if.init();
    end

    //Creating verification scenario
    always @(posedge axi_if.M_AXIS_ACLK) begin
	       axi_if.send_data(data,1);
    	   data = data + 4'hC;
    end

	always @(posedge axi_if.M_AXIS_ACLK)
			axi_if.run_tready();

    //Deciding when to finish simulation
	initial
		#5000 $finish();
	
    //Clock stimulus
	always begin
		#20 axi_if.M_AXIS_ACLK <= ~axi_if.M_AXIS_ACLK;	
	end
	
endmodule : axis_master_tb
