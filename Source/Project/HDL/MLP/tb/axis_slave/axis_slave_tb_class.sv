interface axis_slave_interface #(parameter integer C_S_AXIS_TDATA_WIDTH	= 32); 
	logic								pi_data_read;
    logic       						po_mlp_data_valid;
    logic [C_S_AXIS_TDATA_WIDTH-1:0]  	po_mlp_data;
    logic                               S_AXIS_ACLK;
    logic                               S_AXIS_ARESETN;
    logic                               S_AXIS_TREADY;
    logic [C_S_AXIS_TDATA_WIDTH-1:0]    S_AXIS_TDATA;
    logic [(C_S_AXIS_TDATA_WIDTH/8)-1:0]S_AXIS_TSTRB;
    logic                               S_AXIS_TLAST;
    logic                               S_AXIS_TVALID;

	int n;
	logic[31:0] data;

    task init();
    	pi_data_read		<= 0;
        S_AXIS_ACLK         <= 0;
        S_AXIS_ARESETN      <= 0;
        S_AXIS_TDATA        <= 0;
        S_AXIS_TSTRB        <= 0;
        S_AXIS_TLAST        <= 0;
        S_AXIS_TVALID       <= 0;
        data				<= 3;
        #50 S_AXIS_ARESETN  <= 1;
    endtask

    task send_rnd_data();
        @(posedge S_AXIS_ACLK);
        if(axi_if.S_AXIS_TREADY) begin
        	S_AXIS_TDATA  <= data;
			S_AXIS_TVALID <= 1;
		end
		
		@(posedge S_AXIS_ACLK);
		S_AXIS_TVALID <= 0;
		data += 4'hB;
    endtask
    
    task run_data_read();
    	n = $urandom_range(1,100);
    	if(S_AXIS_TREADY)
    		pi_data_read <= repeat(n)@(posedge S_AXIS_ACLK) 1'b1;
    	@(posedge S_AXIS_ACLK);
    	pi_data_read <= 1'b0;
    endtask

endinterface : axis_slave_interface
