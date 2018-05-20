/*
        System for multiplacion is 1.4.11
        1 for sign
        4 for whole number
        11 for fraction
*/
module neuron
		//Neuron signals
	(	input 				pi_clk,				 //Clock
		input 				pi_rst,				 //Reset
		input				pi_valid,			 //Signal is set to 1 when we have valid input and weight value
		input 				pi_clc_accumulator,	 //Clear accumulator
        input signed [15:0] pi_bias,
		input signed [15:0] pi_weights,			 //Weights
		input signed [15:0] pi_inputs,			 //Input Values
		input				pi_accumulation_done,//Signal is '1' after collecting all walues inside accumulator - signal from Control Unit
			//uncomment if neuron is tested separately
		//output signed[15:0]	po_accumulation_test,//FOR TESTING
		//output signed[15:0]	po_multiply_test,	 //FOR TESTING
		output				po_BRAM_en,          //Sigmoid LUT enable signal
		output		 [15:0]	po_BRAM_add			 //Output value of neuron which is acctuali address in LUT
	);

// SIGNALS
logic signed [31:0] mul_res;					//Multiply result in system 2.8.22
logic signed [15:0] mul_res_red;				//Multiply result reduced to system 1.4.11
		
logic signed [31:0] acc_res;					//Accumulation result
logic signed [15:0] acc_res_red;
logic 				overflow;					//Used for debugging
logic signed [15:0] acc_res_bias;				//Accumulation result and added bias value
logic signed [15:0] acc_res_bias_red;			//Accumulation result and added bias value reduced

logic [15:0] acc_res_bias_red_sig_mag1;
logic [14:0] acc_res_bias_red_sig_mag2;
logic [15:0] acc_res_bias_red_sig_mag3;

logic [15:0] acc_res_bias_red_sat;				//Accumulation result plus bias reduced and saturated

localparam      s1 = 1'b0;						// One-Hot State Encoding
localparam      s2 = 1'b1;
logic           state;

 //Taking care of signals, keeping it away from being removed by Vivado synthesize tool
(* dont_touch = "true" *) logic       BRAM_en;
(* dont_touch = "true" *) logic[15:0] BRAM_addr;
                
/////////////////////////////////////////
//					NEURON			   //
/////////////////////////////////////////
assign mul_res 		= pi_inputs * pi_weights;			//Multiply result 2.8.22
//assign mul_res_red	= {mul_res[31],mul_res[29-:15]};	//Multiply result 1.8.7

//ACUMULATOR 							
always_ff @ (posedge pi_clk) begin						// Clear or update accumulator data, as appropriate  
	if(pi_rst)
		acc_res <= 0;
	else if(pi_clc_accumulator) 
		acc_res <= 0;	
	else if(pi_valid==1'b1) begin
		{overflow,acc_res} <= acc_res + mul_res;	
	end
end 

assign acc_res_red = {acc_res[31],acc_res[29-:15]};

//Now system is 1.8.7 but bias is 1.4.11 so we need to adjust bias system to 1.8.11
assign acc_res_bias = (pi_bias[15]==1'b1) ? acc_res_red + {pi_bias[15],4'hF,pi_bias[14-:11]} : acc_res_red + {pi_bias[15],4'h0,pi_bias[14-:11]}; 
//Now we will convert value from complement of 2's to sign and magnitude because that's how we sampled sigmoind function
assign acc_res_bias_red_sig_mag1= acc_res_bias - 1; 
assign acc_res_bias_red_sig_mag2= ~(acc_res_bias_red_sig_mag1[14:0]); 
assign acc_res_bias_red_sig_mag3= {acc_res_bias[15],acc_res_bias_red_sig_mag2};
//Now we need to convert basic system to system with saturation which means if overflow occured 4 bits from whole number will be 1111
//in other words system will be saturated to value of 15
assign acc_res_bias_red 		= (acc_res_bias[15] == 1'b1) ? acc_res_bias_red_sig_mag3 : acc_res_bias[15:0];
assign acc_res_bias_red_sat		= (acc_res_bias_red[14-:4] != 4'h0) ? {acc_res_bias_red[15],8'h0F,acc_res_bias_red[6:0]} : acc_res_bias_red; //Saturation

//FOR TESTING
assign po_multiply_test		= {mul_res[31],mul_res[29-:15]};//nije konvertovan u sistem znak i amplituda
assign po_accumulation_test = acc_res_bias_red;

//FSM
always @ (posedge pi_clk) begin
	if(pi_rst) begin
		state 		<= s1;
		BRAM_en 	<= 0;
		BRAM_addr	<= 0;
	end
	else begin
		case(state)
                s1: if (pi_accumulation_done) begin //If accumulaton is done for all inputs we need to signalize it to Sigmoid LUT with BRAM_en signal
					BRAM_addr	<= acc_res_bias_red_sat;
					BRAM_en		<= 1'b1;
					state 		<= s2;
				end
				else begin
					BRAM_addr	<= 0;
					BRAM_en 	<= 1'b0;
					state 		<= s1;
				end
			s2: begin
					BRAM_en 	<= 1'b0;
					state 		<= s1;
				end
		endcase
	end
end

assign po_BRAM_add  = BRAM_addr;	//Output system is 1.8.7
assign po_BRAM_en 	= BRAM_en; 						  

endmodule : neuron
