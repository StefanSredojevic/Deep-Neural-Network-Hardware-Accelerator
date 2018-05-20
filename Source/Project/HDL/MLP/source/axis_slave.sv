
//`timescale 1 ns / 1 ps

module axis_slave 
	#
	(parameter integer C_S_AXIS_TDATA_WIDTH	= 32)
    (
    input wire								pi_data_read,
    output reg       						po_mlp_data_valid,
    output wire[C_S_AXIS_TDATA_WIDTH-1:0]   po_mlp_data,
    input wire  S_AXIS_ACLK,                                    // AXI4Stream sink: Clock
    input wire  S_AXIS_ARESETN,                                 // AXI4Stream sink: Reset
    output wire  S_AXIS_TREADY,                                 // Ready to accept data in
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,       // Data in
    input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,   // Byte qualifier
    input wire  S_AXIS_TLAST,                                   // Indicates boundary of last packet
    input wire  S_AXIS_TVALID                                   // Data is in valid
    );

    localparam [1:0] IDLE = 2'b00,
                     WRITE_FIFO  = 2'b01,
                     READ_FIFO   = 2'b10; 

    logic  	     axis_tready;
    logic[1:0]   mst_exec_state;        
    logic        fifo_wren;
    logic        fifo_rden;
    logic[31:0]  stream_data_fifo;
    logic[31:0]  fifo_data_out;

    assign S_AXIS_TREADY	= axis_tready;
    assign fifo_wren 		= S_AXIS_TVALID && axis_tready;
 
    always @( posedge S_AXIS_ACLK )
    	if (!S_AXIS_ARESETN) begin
    		axis_tready		  <= 1'b1;
          	po_mlp_data_valid <= 1'b0;
    	end
        else if (fifo_wren && axis_tready) begin
          	fifo_data_out  	  <= S_AXIS_TDATA;
          	po_mlp_data_valid <= 1'b1;
          	axis_tready		  <= 1'b0;
        end
        else if (pi_data_read) begin
        	axis_tready		  <= 1'b1;
        	po_mlp_data_valid <= 1'b0;
        end
        	
    assign po_mlp_data = fifo_data_out;
    
endmodule : axis_slave
