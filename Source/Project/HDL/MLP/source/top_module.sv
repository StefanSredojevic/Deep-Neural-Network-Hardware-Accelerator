`timescale 1 ns / 1 ps

module top_module #
(
	parameter integer C_S00_AXI_DATA_WIDTH	    = 32,
	parameter integer C_S00_AXI_ADDR_WIDTH	    = 5 ,
	parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,
	parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
	parameter integer BRAM_WADDR				= 11,
	parameter integer BRAM_WDATA				= 16
)
(
    //TEST SIGNALS - BEGIN
    //output [15:0] po_reg_port_a,
    //output [15:0] po_reg_port_b,
    //output        po_ena,
    //output        po_enb,
    output[31:0]    po_fsm_state,         
    output[31:0]    po_mlp_data,         
    output          po_write_to_master,  
    output          po_wr_to_master_done,
	   //Test counter
	output wire [12:0]							po_test_cnt,
	//TEST SIGNALS _ END
	//Ports of Axi Slave Bus Interface S00_AXI
	input  wire                                 s00_axi_aclk,
	input  wire                                 s00_axi_aresetn,
	input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0]    s00_axi_awaddr,
	input  wire [2 : 0]                         s00_axi_awprot,
	input  wire                                 s00_axi_awvalid,
	output wire                                 s00_axi_awready,
	input  wire [C_S00_AXI_DATA_WIDTH-1 : 0]    s00_axi_wdata,
	input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]s00_axi_wstrb,
	input  wire                                 s00_axi_wvalid,
	output wire                                 s00_axi_wready,
	output wire [1 : 0]                         s00_axi_bresp,
	output wire                                 s00_axi_bvalid,
	input  wire                                 s00_axi_bready,
	input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0]    s00_axi_araddr,
	input  wire [2 : 0]                         s00_axi_arprot,
	input  wire                                 s00_axi_arvalid,
	output wire                                 s00_axi_arready,
	output wire [C_S00_AXI_DATA_WIDTH-1 : 0]    s00_axi_rdata,
	output wire [1 : 0]                         s00_axi_rresp,
	output wire                                 s00_axi_rvalid,
	input  wire                                 s00_axi_rready,

	//Ports of Axi Slave Bus Interface S00_AXIS
	input  wire                                 s00_axis_aclk,
	input  wire                                 s00_axis_aresetn,
	output wire                                 s00_axis_tready,
	input  wire [C_S00_AXIS_TDATA_WIDTH-1 : 0]  s00_axis_tdata,
	input  wire [(C_S00_AXIS_TDATA_WIDTH/8)-1:0]s00_axis_tstrb,
	input  wire                                 s00_axis_tlast,
	input  wire                                 s00_axis_tvalid,

	//Ports of Axi Master Bus Interface M00_AXIS
	input  wire                                 m00_axis_aclk,
	input  wire                                 m00_axis_aresetn,
	output wire                                 m00_axis_tvalid,
	output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0]  m00_axis_tdata,
	output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1:0]m00_axis_tstrb,
	output wire                                 m00_axis_tlast,
	input  wire                                 m00_axis_tready
);

//User signals
    wire [15:0] status_register;           
    wire        wren_status_reg;            
    wire [31:0] input_nodes;                
    wire [31:0] hidden_nodes;               
    wire [31:0] output_nodes;               
    wire [31:0] control_signals;               
    wire		data_read_axis_slave;       
    wire        mlp_data_valid_axis_slave;  
    wire [31:0] mlp_data_axis_slave;        
    wire [15:0] mlp_data_top_module;       
    wire        write_to_fifo_top_module;  
    wire        wr_fifo_done_top_module;   
    wire        dp_valid;        
    wire        dp_clc_accumulator;
    wire        dp_accumulation_done;
    wire        dp_ena_bia;      
    wire        dp_enb_bia;      
    wire        dp_wea_bia;      
    wire        dp_web_bia;      
    wire [BRAM_WADDR-1:0] dp_addra_bia;   
    wire [BRAM_WADDR-1:0] dp_addrb_bia;         
    wire        dp_ena_inp;      
    wire        dp_enb_inp;      
    wire        dp_wea_inp;      
    wire        dp_web_inp;      
    wire [BRAM_WADDR-1:0] dp_addra_inp;   
    wire [BRAM_WADDR-1:0] dp_addrb_inp;         
    wire        dp_ena_wei;      
    wire        dp_enb_wei;      
    wire        dp_wea_wei;      
    wire        dp_web_wei;      
    wire [BRAM_WADDR-1:0] dp_addra_wei;    
    wire [BRAM_WADDR-1:0] dp_addrb_wei;         
    wire        dp_ena_reg;      
    wire        dp_enb_reg;      
    wire        dp_wea_reg;      
    wire        dp_web_reg;      
    wire [BRAM_WADDR-1:0]  dp_addra_reg;    
    wire [BRAM_WADDR-1:0]  dp_addrb_reg;             
    wire [15:0] dp_dob;   
    wire [9:0]	current_layer_nodes;        

//Counter register
(* dont_touch = "true" *) reg[12:0] counter;

always @(posedge s00_axis_aclk) begin
	if(!s00_axis_aresetn)
		counter <= 13'h0000;
	else if(s00_axis_tready && s00_axis_tvalid)
		counter <= counter + 13'h0001;
	else if(counter == 13'h1C95)
		counter <= 13'h0000;
end

assign po_test_cnt = counter;

// Instantiation of Axi Bus Interface S00_AXI
	axil_slave # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axil_slave_inst (
		.S_AXI_ACLK     (s00_axi_aclk),
		.S_AXI_ARESETN  (s00_axi_aresetn),
		.S_AXI_AWADDR   (s00_axi_awaddr),
		.S_AXI_AWPROT   (s00_axi_awprot),
		.S_AXI_AWVALID  (s00_axi_awvalid),
		.S_AXI_AWREADY  (s00_axi_awready),
		.S_AXI_WDATA    (s00_axi_wdata),
		.S_AXI_WSTRB    (s00_axi_wstrb),
		.S_AXI_WVALID   (s00_axi_wvalid),
		.S_AXI_WREADY   (s00_axi_wready),
		.S_AXI_BRESP    (s00_axi_bresp),
		.S_AXI_BVALID   (s00_axi_bvalid),
		.S_AXI_BREADY   (s00_axi_bready),
		.S_AXI_ARADDR   (s00_axi_araddr),
		.S_AXI_ARPROT   (s00_axi_arprot),
		.S_AXI_ARVALID  (s00_axi_arvalid),
		.S_AXI_ARREADY  (s00_axi_arready),
		.S_AXI_RDATA    (s00_axi_rdata),
		.S_AXI_RRESP    (s00_axi_rresp),
		.S_AXI_RVALID   (s00_axi_rvalid),
		.S_AXI_RREADY   (s00_axi_rready),
        //user ports
        .pi_status_register ({16'h0000,status_register}),
        .pi_wren_status_reg (wren_status_reg),
        .po_input_nodes     (input_nodes),
        .po_hidden_nodes    (hidden_nodes),
        .po_output_nodes    (output_nodes),
        .po_control_signals (control_signals) 
	);

// Instantiation of Axi Bus Interface S00_AXIS
	axis_slave # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) axis_slave_inst (
		.S_AXIS_ACLK        (s00_axis_aclk),
		.S_AXIS_ARESETN     (s00_axis_aresetn),
		.S_AXIS_TREADY      (s00_axis_tready),
		.S_AXIS_TDATA       (s00_axis_tdata),
		.S_AXIS_TSTRB       (s00_axis_tstrb),
		.S_AXIS_TLAST       (s00_axis_tlast),
		.S_AXIS_TVALID      (s00_axis_tvalid),
        //user ports
        .pi_data_read       (data_read_axis_slave),
	    .po_mlp_data_valid  (mlp_data_valid_axis_slave),
        .po_mlp_data        (mlp_data_axis_slave)
    );
// Instantiation of Axi Bus Interface M00_AXIS
	axis_master # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) axis_master_inst (
		.M_AXIS_ACLK    	(m00_axis_aclk),
		.M_AXIS_ARESETN 	(m00_axis_aresetn),
		.M_AXIS_TVALID  	(m00_axis_tvalid),
		.M_AXIS_TDATA   	(m00_axis_tdata),
		.M_AXIS_TSTRB   	(m00_axis_tstrb),
		.M_AXIS_TLAST   	(m00_axis_tlast),
		.M_AXIS_TREADY  	(m00_axis_tready),
        //user ports
        .pi_current_layer_nodes(current_layer_nodes),
        .pi_mlp_data        ({mlp_data_top_module,mlp_data_top_module}),  
	    .pi_write_to_fifo   (write_to_fifo_top_module),
        .po_wr_fifo_done    (wr_fifo_done_top_module)
    ); 

assign po_mlp_data          = {mlp_data_top_module,mlp_data_top_module};
assign po_write_to_master   = write_to_fifo_top_module;
assign po_wr_to_master_done = wr_fifo_done_top_module;

// Instantiation of Data Path
    data_path # (
    	.BRAM_WADDR(BRAM_WADDR),
    	.BRAM_WDATA(BRAM_WDATA)
    )data_path_inst(
        //TEST SIGNALS - BEGIN
        //.po_reg_port_a      (po_reg_port_a),
        //.po_reg_port_b      (po_reg_port_b),
        //.po_ena             (po_ena),
        //.po_enb             (po_enb),
        //TEST SIGNALS - END
       .pi_clk              (s00_axis_aclk),              
       .pi_rst              (~s00_axis_aresetn),  
       //neuron            
       .pi_valid            (dp_valid),         
       .pi_clc_accumulator  (dp_clc_accumulator),
       .pi_accumulation_done(dp_accumulation_done), 
        //biases
       .pi_ena_bia			(dp_ena_bia),
	   .pi_enb_bia			(dp_enb_bia),
	   .pi_wea_bia			(dp_wea_bia),
	   .pi_web_bia			(dp_web_bia),
	   .pi_addra_bia		(dp_addra_bia),
	   .pi_addrb_bia		(dp_addrb_bia),
	   .pi_dia_bia			(mlp_data_axis_slave[15:0]),
	   .pi_dib_bia			(mlp_data_axis_slave[31:16]),
        //inputs
       .pi_ena_inp          (dp_ena_inp),          
       .pi_enb_inp          (dp_enb_inp),          
       .pi_wea_inp          (dp_wea_inp),          
       .pi_web_inp          (dp_web_inp),          
       .pi_addra_inp        (dp_addra_inp),        
       .pi_addrb_inp        (dp_addrb_inp),        
       .pi_dia_inp          (mlp_data_axis_slave[15:0]),         
       .pi_dib_inp          (mlp_data_axis_slave[31:16]),  
        //weights                     
       .pi_ena_wei          (dp_ena_wei),          
       .pi_enb_wei          (dp_enb_wei),          
       .pi_wea_wei          (dp_wea_wei),          
       .pi_web_wei          (dp_web_wei),          
       .pi_addra_wei        (dp_addra_wei),        
       .pi_addrb_wei        (dp_addrb_wei),        
       .pi_dia_wei          (mlp_data_axis_slave[15:0]),         
       .pi_dib_wei          (mlp_data_axis_slave[31:16]),
        //output reg                       
       .pi_ena_reg          (dp_ena_reg),          
       .pi_enb_reg          (dp_enb_reg),          
       .pi_wea_reg          (dp_wea_reg),          
       .pi_web_reg          (dp_web_reg),          
       .pi_addra_reg        (dp_addra_reg),        
       .pi_addrb_reg        (dp_addrb_reg),        
       .po_doa              (mlp_data_top_module),             
       .po_dob              (dp_dob)//NOT USED 
    );           

// Instantiation of Control Unit

	control_unit #(.num_of_used_neurons(2)) control_unit_inst
	(
	    .po_fsm_state               (po_fsm_state),
		//clock and reset
		.pi_clk						(s00_axis_aclk),                    
		.pi_rst						(~s00_axis_aresetn),                    
		//register map  					   
		.pi_num_of_input_nodes		(input_nodes),     
		.pi_num_of_hidden			(hidden_nodes),          
		.pi_num_of_output_nodes		(output_nodes),    
		.pi_ctrl_signals			(control_signals[15:0]),           
		.po_wren_stat_reg			(wren_status_reg), //nije jos realizovano         
		.po_stat_reg_data			(status_register),          
		//axi stream slave   					   
		.pi_axis_slave_valid_data	(mlp_data_valid_axis_slave),  
		.po_axis_slave_data_stored	(data_read_axis_slave), 
		//biases BRAM    					   
		.po_addra_bia				(dp_addra_bia),              
		.po_addrb_bia				(dp_addrb_bia),              
		.po_ena_bia					(dp_ena_bia),                
		.po_enb_bia					(dp_enb_bia),                
		.po_wea_bia					(dp_wea_bia),                
		.po_web_bia					(dp_web_bia),                
		//inputs BRAM   					   
		.po_addra_inp				(dp_addra_inp),              
		.po_addrb_inp				(dp_addrb_inp),              
		.po_ena_inp					(dp_ena_inp),                
		.po_enb_inp					(dp_enb_inp),                
		.po_wea_inp					(dp_wea_inp),                
		.po_web_inp					(dp_web_inp),                
		//weights BRAM   					   
		.po_addra_wei				(dp_addra_wei),              
		.po_addrb_wei				(dp_addrb_wei),              
		.po_ena_wei					(dp_ena_wei),                
		.po_enb_wei					(dp_enb_wei),                
		.po_wea_wei					(dp_wea_wei),                
		.po_web_wei					(dp_web_wei),                
		//neuron    					   
		.po_clc_accumulator			(dp_clc_accumulator),        
		.po_accumulation_done		(dp_accumulation_done),      
		.po_neuron_en				(dp_valid),              
		//output register BRAM  					   
		.po_addra_reg				(dp_addra_reg),              
		.po_addrb_reg				(dp_addrb_reg),              
		.po_ena_reg					(dp_ena_reg),                
		.po_enb_reg					(dp_enb_reg),                
		.po_wea_reg					(dp_wea_reg),                
		.po_web_reg					(dp_web_reg),                
		//axi stream master 	
		.po_current_layer_nodes		(current_layer_nodes),						
		.pi_axis_master_data_stored	(wr_fifo_done_top_module),
		.po_axis_master_write_data  (write_to_fifo_top_module)
	); 
endmodule : top_module
