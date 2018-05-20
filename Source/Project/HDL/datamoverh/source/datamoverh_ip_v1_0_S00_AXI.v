

//`timescale 1 ns / 1 ps

	module datamoverh #
	(
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		//USER PORTS
		output          po_usr_rst,
		output [71:0] 	po_command,
		output			po_valid,
		input 			pi_ready,
		input [7:0]     pi_sts_tdata,
		input           pi_sts_tvalid,

		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  							axi_awready;
	reg  							axi_wready;
	reg [1 : 0] 					axi_bresp;
	reg  							axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  							axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 					axi_rresp;
	reg  							axi_rvalid;

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;

	//USER SIGNALS
	logic send_stream_data;
	logic slv_reg_wren_late; 
	logic slv_reg3_read;
	(* dont_touch = "true" *) logic put_slv_reg3_read_to_zero;
	logic slv_reg2_en_edge;
	logic slv_reg2_en_late;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 8
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;

	always @( posedge S_AXI_ACLK ) begin
	  if ( S_AXI_ARESETN == 1'b0 )
	      axi_awready <= 1'b0;
	  else begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	          axi_awready <= 1'b1;
	      else           
	          axi_awready <= 1'b0;
	   end 
	end        

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        //case(axi_awaddr) // Ovo je pre bilo i ne radi okej ovako, pogledaj axi lite u mlpu za razlog
	          3'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                    end
	        endcase
	      end
	  end
	end    

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       
 
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
	
	//Edge detection of enable signal
	always @(posedge S_AXI_ACLK) begin
		if(!S_AXI_ARESETN)
			slv_reg2_en_late <= 1'b0;
		else
			slv_reg2_en_late <= ~slv_reg2[10];
	end
	
	assign slv_reg2_en_edge = slv_reg2[10] && slv_reg2_en_late;
	
	always @(posedge S_AXI_ACLK) begin
		if(!S_AXI_ARESETN)
			send_stream_data <= 1'b0;
		else if(slv_reg2_en_edge==1'b1 && slv_reg_wren_late == 1'b1)
			send_stream_data <= 1'b1;
		else if(send_stream_data == 1'b1 && pi_ready == 1'b1)	//If command is valid and if data mover is ready to recieve command
			send_stream_data <= 1'b0;
	end
	
	always @(posedge S_AXI_ACLK) begin
		if(!S_AXI_ARESETN)
			slv_reg_wren_late <= 1'b0;
		else
			slv_reg_wren_late <= slv_reg_wren;
	end

	assign po_command 	= {slv_reg2[9:0],slv_reg1,slv_reg0};//72 Total
	assign po_valid		= send_stream_data;
	
	 //Writing into status register
    always @( posedge S_AXI_ACLK ) begin
        if(S_AXI_ARESETN == 1'b0) begin
             slv_reg3 <= 0;
             put_slv_reg3_read_to_zero <= 1'b0;
         end
        //else if (pi_ready && send_stream_data) begin
        else if ((pi_sts_tdata[7]==1'b1) && pi_sts_tvalid) begin//If sending is over and status is okay
            slv_reg3 <= 32'h00000001;
            put_slv_reg3_read_to_zero <= 1'b0;
        end
		else if (slv_reg3[0] == 1'b1 && slv_reg3_read == 1'b1) begin
			slv_reg3 <= 0;
			put_slv_reg3_read_to_zero <= 1'b1;
		end
    end
    
    // Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	      //case (axi_araddr)
	       	2'h3   	: begin
	       		reg_data_out  <= slv_reg3;
	       		if(slv_reg_rden)	
	       			slv_reg3_read <= 1'b1;
	       		else if(put_slv_reg3_read_to_zero)
	       			slv_reg3_read <= 1'b0;
                else
                    slv_reg3_read <= slv_reg3_read;
       		end
       		
	        default : begin
	        	reg_data_out <= 0;
	        	slv_reg3_read <= 1'b0;
        	end
	      endcase
	end

    assign po_usr_rst = slv_reg2[11];

	// User logic ends

	endmodule : datamoverh