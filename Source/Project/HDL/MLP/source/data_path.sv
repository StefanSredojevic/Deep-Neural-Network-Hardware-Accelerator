module data_path # (parameter integer BRAM_WADDR = 11, parameter integer BRAM_WDATA = 16)
	(
	   //TEST SIGNALS - BEGIN
	   //output [15:0] po_reg_port_a,
	   //output [15:0] po_reg_port_b,
	   //output        po_ena,
	   //output        po_enb,
	   //TEST SIGNALS _ END
	   
		//Neuron signals
		input 		pi_clk,					//Common clock
		input 		pi_rst,					//Common reset
		input 		pi_valid,				//Signal is set to 1 when we have valid input and weight value
		input 		pi_clc_accumulator,		//Clears neurons accumulator result
		input 		pi_accumulation_done,	//Signalising one over accumulation cycle
		//Sigmoid LUT BRAM signals
		/*  NO PORTS  */                    //This block does not have external ports, all connections are internal
        //Biases BRAM
        input 		pi_ena_bia,				//Enable BRAM port A
		input 		pi_enb_bia,				//Enable BRAM port B
		input 		pi_wea_bia,				//Write Enable BRAM port A [write - '1'   read - '0']
		input 		pi_web_bia,				//Write Enable BRAM port B [write - '1'   read - '0']
		input[BRAM_WADDR-1:0] pi_addra_bia,			//BRAM address port A
		input[BRAM_WADDR-1:0] pi_addrb_bia,			//BRAM address port B
		input[BRAM_WDATA-1:0] pi_dia_bia,				//Biase Data BRAM port A
		input[BRAM_WDATA-1:0] pi_dib_bia,				//Biase Data BRAM port B
		//Inputs BRAM
		input 		pi_ena_inp,				//Enable BRAM port A
		input 		pi_enb_inp,				//Enable BRAM port B
		input 		pi_wea_inp,				//Write Enable BRAM port A [write - '1'   read - '0']
		input 		pi_web_inp,				//Write Enable BRAM port B [write - '1'   read - '0']
		input[BRAM_WADDR-1:0] pi_addra_inp,			//BRAM address port A
		input[BRAM_WADDR-1:0] pi_addrb_inp,			//BRAM address port B
		input[BRAM_WDATA-1:0] pi_dia_inp,				//Input Data BRAM port A
		input[BRAM_WDATA-1:0] pi_dib_inp,				//Input Data BRAM port B
		//Weights BRAM
		input 		pi_ena_wei,				//Enable BRAM port A
		input 		pi_enb_wei,				//Enable BRAM port B
		input 		pi_wea_wei,				//Write Enable BRAM port A [write - '1'   read - '0']
		input 		pi_web_wei,				//Write Enable BRAM port B [write - '1'   read - '0']
		input[BRAM_WADDR-1:0] pi_addra_wei,			//BRAM address port A
		input[BRAM_WADDR-1:0] pi_addrb_wei,			//BRAM address port B
		input[BRAM_WDATA-1:0] pi_dia_wei,				//Input Data BRAM port A
		input[BRAM_WDATA-1:0] pi_dib_wei,				//Input Data BRAM port B
		//Output Register BRAM
		input 		pi_ena_reg,				//Enable BRAM port A
		input 		pi_enb_reg,				//Enable BRAM port B
		input 		pi_wea_reg,				//Write Enable BRAM port A [write - '1'   read - '0']
		input 		pi_web_reg,				//Write Enable BRAM port B [write - '1'   read - '0']
		input [BRAM_WADDR-1:0] pi_addra_reg,			//BRAM address port A
		input [BRAM_WADDR-1:0] pi_addrb_reg,			//BRAM address port B
		output[BRAM_WDATA-1:0]po_doa,                 //Output from eural Network, this result is sent backt to DDR memory, prot A
		output[BRAM_WDATA-1:0]po_dob                  //Output from eural Network, this result is sent backt to DDR memory, prot B
	);

//SIGNALS
    //Biases intern signals
logic[BRAM_WDATA-1:0] doa_bia;
logic[BRAM_WDATA-1:0] dob_bia;

    //Inputs intern signals
logic[BRAM_WDATA-1:0] doa_inp;
logic[BRAM_WDATA-1:0] dob_inp;

    //Weights intern signals
logic[BRAM_WDATA-1:0] doa_wei;
logic[BRAM_WDATA-1:0] dob_wei;

    //Sigmoid LUT intern signals
logic[15:0]  addra_sig;
logic[15:0]  addrb_sig;
logic		 ena_sig;
logic		 enb_sig;
logic[9:0]   doa_sig;
logic[9:0]   dob_sig;

//Inputs BRAM	
bram #(.WADDR(BRAM_WADDR), .WDATA(BRAM_WDATA)) BRAM_bia(
	.pi_clka 	(pi_clk),
	.pi_clkb 	(pi_clk),
	.pi_ena 	(pi_ena_bia),	
	.pi_enb 	(pi_enb_bia),	
	.pi_wea 	(pi_wea_bia),	
	.pi_web 	(pi_web_bia),	
	.pi_addra	(pi_addra_bia),
	.pi_addrb	(pi_addrb_bia),
	.pi_dia		(pi_dia_bia),	
	.pi_dib		(pi_dib_bia),	
	.po_doa		(doa_bia),
	.po_dob		(dob_bia)
);

//Inputs BRAM	
bram #(.WADDR(BRAM_WADDR), .WDATA(BRAM_WDATA)) BRAM_inp(
	.pi_clka 	(pi_clk),
	.pi_clkb 	(pi_clk),
	.pi_ena 	(pi_ena_inp),	
	.pi_enb 	(pi_enb_inp),	
	.pi_wea 	(pi_wea_inp),	
	.pi_web 	(pi_web_inp),	
	.pi_addra	(pi_addra_inp),
	.pi_addrb	(pi_addrb_inp),
	.pi_dia		(pi_dia_inp),	
	.pi_dib		(pi_dib_inp),	
	.po_doa		(doa_inp),
	.po_dob		(dob_inp)
);

//Weights BRAM
bram #(.WADDR(BRAM_WADDR), .WDATA(BRAM_WDATA)) BRAM_wei(
	.pi_clka 	(pi_clk),
	.pi_clkb 	(pi_clk),
	.pi_ena 	(pi_ena_wei),	
	.pi_enb 	(pi_enb_wei),	
	.pi_wea 	(pi_wea_wei),	
	.pi_web 	(pi_web_wei),	
	.pi_addra	(pi_addra_wei),
	.pi_addrb	(pi_addrb_wei),
	.pi_dia		(pi_dia_wei),	
	.pi_dib		(pi_dib_wei),	
	.po_doa		(doa_wei),
	.po_dob		(dob_wei)
);

//Sigmoid LUT BRAM
sigmoid_lookup BRAM_sig(
	.pi_clka 	(pi_clk),
	.pi_clkb 	(pi_clk),
	.pi_ena 	(ena_sig),	
	.pi_enb 	(enb_sig),	
    //System was 1.8.7 now is 1.4.5, this is due need to have 2^10 combinations of sempled sigmoid function	
	.pi_addra	({addra_sig[15],addra_sig[10:2]}),
	.pi_addrb	({addrb_sig[15],addrb_sig[10:2]}),	
	.po_doa		(doa_sig),
	.po_dob		(dob_sig)
);

//Neuron A
neuron neuron_A(
	.pi_clk					(pi_clk),			
	.pi_rst					(pi_rst),	
	.pi_valid				(pi_valid),		
	.pi_clc_accumulator		(pi_clc_accumulator),
	.pi_weights				(doa_wei),
    .pi_bias				(doa_bia),
	.pi_inputs				(doa_inp),
	.pi_accumulation_done	(pi_accumulation_done),
	.po_BRAM_en				(ena_sig),
	.po_BRAM_add			(addra_sig)
);

//Neuron B
neuron neuron_B(
	.pi_clk					(pi_clk),			
	.pi_rst					(pi_rst),
	.pi_valid				(pi_valid),			
	.pi_clc_accumulator		(pi_clc_accumulator),
	.pi_weights				(dob_wei),
	.pi_bias				(dob_bia),
	.pi_inputs				(dob_inp),
	.pi_accumulation_done	(pi_accumulation_done),
	.po_BRAM_en				(enb_sig),
	.po_BRAM_add			(addrb_sig)
);

//Output Register BRAM
bram #(.WADDR(BRAM_WADDR), .WDATA(BRAM_WDATA)) BRAM_reg(
	.pi_clka 	(pi_clk),
	.pi_clkb 	(pi_clk),
	.pi_ena 	(pi_ena_reg),	
	.pi_enb 	(pi_enb_reg),
	.pi_wea		(pi_wea_reg),
	.pi_web		(pi_web_reg),
	.pi_addra	(pi_addra_reg),
	.pi_addrb	(pi_addrb_reg),	
    //System was 1.9 (output from sigmoid function) now its converted back to 1.4.11
	.pi_dia		({4'b0000,doa_sig,2'b00}),
	.pi_dib		({4'b0000,dob_sig,2'b00}),
	.po_doa		(po_doa),
	.po_dob		(po_dob)
);

//assign po_reg_port_a = {4'b0000,doa_sig,2'b00};
//assign po_reg_port_b = {4'b0000,dob_sig,2'b00};
//assign po_ena = pi_ena_reg;
//assign po_enb = pi_enb_reg;

endmodule : data_path
