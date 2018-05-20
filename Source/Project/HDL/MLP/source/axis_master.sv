
//`timescale 1 ns / 1 ps

module axis_master
    #
    (parameter integer C_M_AXIS_TDATA_WIDTH	= 32)
    (
     input  wire [9 : 0]						 pi_current_layer_nodes,
     input  wire [C_M_AXIS_TDATA_WIDTH-1 : 0]    pi_mlp_data,
     input  wire                                 pi_write_to_fifo,
     output reg                                  po_wr_fifo_done,
     input  wire                                 M_AXIS_ACLK,
     input  wire                                 M_AXIS_ARESETN,
     output wire                                 M_AXIS_TVALID,
     output wire [C_M_AXIS_TDATA_WIDTH-1:0]      M_AXIS_TDATA,
     output wire [(C_M_AXIS_TDATA_WIDTH/8)-1:0]  M_AXIS_TSTRB,
     output wire                                 M_AXIS_TLAST,
     input  wire                                 M_AXIS_TREADY
    );
    
    localparam		                IDLE 		= 1'b0,
                                    SEND_STREAM = 1'b1; 

    reg[1:0]                        mst_exec_state;
    reg								reg_empty;
    reg  	                        axis_tvalid;
    (* dont_touch = "true" *) reg  axis_tlast;
    reg[C_M_AXIS_TDATA_WIDTH-1:0]   stream_data_out;
    wire  	                        tx_en;
    reg  	                        tx_done;
    reg[9:0] counter;

    // I/O Connections assignments
    assign M_AXIS_TVALID= axis_tvalid;
    assign M_AXIS_TDATA	= stream_data_out;
    assign M_AXIS_TLAST	= axis_tlast;       //Not used
    assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH / 8){1'b1}};


    // Control state machine implementation
    always @(posedge M_AXIS_ACLK) begin
    	po_wr_fifo_done <= 1'b0;
        if (!M_AXIS_ARESETN) begin
        	reg_empty <= 1'b1;
            po_wr_fifo_done <= 1'b0;
            axis_tvalid <= 1'b0;
        end if(pi_write_to_fifo && reg_empty) begin
            reg_empty 		<= 1'b0;
            stream_data_out <= pi_mlp_data;
            axis_tvalid 	<= 1'b1;
        end
        else if(!reg_empty && M_AXIS_TREADY) begin
        	reg_empty <= 1'b1;
            axis_tvalid <= 1'b0;
            po_wr_fifo_done <= 1'b1;
        end
    end

	 // TLAST logic
    always @(posedge M_AXIS_ACLK) begin
        if (!M_AXIS_ARESETN)
        	counter <= 10'h000;
        else if(pi_write_to_fifo && reg_empty) begin
			counter <= counter + 10'h001;
        end
        else if (axis_tlast)
        	counter <= 10'h000;
    end

	assign axis_tlast = ( (counter == pi_current_layer_nodes) && (!reg_empty) && (M_AXIS_TREADY) ) ? 1'b1 : 1'b0;

endmodule : axis_master

