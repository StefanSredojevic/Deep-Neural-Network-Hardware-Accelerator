
module axis_master
    #
    (parameter integer C_M_AXIS_TDATA_WIDTH	= 32)
    (
     input  wire [C_M_AXIS_TDATA_WIDTH-1 : 0]    pi_r_data,
     input  wire                                 pi_tlast,
     input  wire                                 pi_data_avaliable,
     output reg                                  po_read_data,
     input  wire                                 M_AXIS_ACLK,
     input  wire                                 M_AXIS_ARESETN,
     output wire                                 M_AXIS_TVALID,
     output wire [C_M_AXIS_TDATA_WIDTH-1:0]      M_AXIS_TDATA,
     output wire [(C_M_AXIS_TDATA_WIDTH/8)-1:0]  M_AXIS_TSTRB,
     output wire                                 M_AXIS_TLAST,
     input  wire                                 M_AXIS_TREADY
    );
    

    reg[1:0]                        mst_exec_state;
    reg								reg_empty;
    reg  	                        axis_tvalid;
    reg[C_M_AXIS_TDATA_WIDTH-1:0]   stream_data_out;
    wire  	                        tx_en;
    reg  	                        tx_done;
    reg[9:0] counter;
    reg                             tlast;

    // I/O Connections assignments
    assign M_AXIS_TVALID= axis_tvalid;
    assign M_AXIS_TDATA	= stream_data_out;
    assign M_AXIS_TLAST	= tlast;       
    assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH / 8){1'b1}};


    // Control state machine implementation
    always @(posedge M_AXIS_ACLK) begin
    	po_read_data <= 1'b0;
        if (!M_AXIS_ARESETN) begin
        	reg_empty <= 1'b1;
            po_read_data <= 1'b0;
            axis_tvalid <= 1'b0;
        end if(pi_data_avaliable && reg_empty) begin
            reg_empty 		<= 1'b0;
            stream_data_out <= pi_r_data;
            axis_tvalid 	<= 1'b1;
        end
        else if(!reg_empty && M_AXIS_TREADY) begin
        	reg_empty <= 1'b1;
            axis_tvalid <= 1'b0;
            po_read_data <= 1'b1;
        end
    end
    
    always @(posedge M_AXIS_ACLK) begin
        if (!M_AXIS_ARESETN) begin
            tlast <= 0;
        end
        else begin
            tlast <= pi_tlast;
        end
    end
endmodule : axis_master