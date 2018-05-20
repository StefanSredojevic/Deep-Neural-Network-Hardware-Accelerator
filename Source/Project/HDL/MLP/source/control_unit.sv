
module control_unit #(parameter integer num_of_used_neurons = 2)
(
    output [31:0]           po_fsm_state,
    //clock and reset
	input 					pi_clk,
	input 					pi_rst,
    //register map
	input [31 : 0]			pi_num_of_input_nodes,
	input [31 : 0]			pi_num_of_hidden,
	input [31 : 0]			pi_num_of_output_nodes,
	input [15 : 0]			pi_ctrl_signals,
	output					po_wren_stat_reg,
	output[15 : 0]			po_stat_reg_data,	
    //axi stream slave
	input 					pi_axis_slave_valid_data,
    output					po_axis_slave_data_stored,
    //biases BRAM
	output[10 : 0]			po_addra_bia,
	output[10 : 0]			po_addrb_bia,
	output					po_ena_bia,
	output					po_enb_bia,
    output                  po_wea_bia,
    output                  po_web_bia,
	//inputs BRAM
	output[10 : 0]			po_addra_inp,
	output[10 : 0]			po_addrb_inp,
	output					po_ena_inp,
	output					po_enb_inp,
    output                  po_wea_inp,
    output                  po_web_inp,
    //weights BRAM
	output[10 : 0]			po_addra_wei,
	output[10 : 0]			po_addrb_wei,
	output					po_ena_wei,
	output					po_enb_wei,
    output                  po_wea_wei,
    output                  po_web_wei,
    //neuron
	output					po_clc_accumulator,
	output					po_accumulation_done,
    output                  po_neuron_en,
    //output register BRAM
	output[10 : 0]			po_addra_reg,
	output[10 : 0]			po_addrb_reg,
	output					po_ena_reg,
	output					po_enb_reg,
    output                  po_wea_reg,
    output                  po_web_reg,
	//axi stream master  
	output[9:0]				po_current_layer_nodes, 
    input                   pi_axis_master_data_stored,
	output					po_axis_master_write_data
);

/**********************SIGNALS**********************/
    //states
(* dont_touch = "true" *) enum {OFF, IDLE, SET_LAYERS_INFO, LOAD_INPUTS, LOAD_BIASES, LOAD_WEIGHTS, NEURON_CALC, WAIT_SIG, WAIT_SIG2, STORE_RESULT, SEND_DATA_TO_CPU, PREPARE_INPUTS} state_reg, state_next;
    //register map
(* dont_touch = "true" *) logic    		wren_stat_reg;
(* dont_touch = "true" *) logic	        bsy;			//busy status signal, this signal will be concatenated to output of status register
//axi stream slave
(* dont_touch = "true" *) logic    		axis_slave_data_stored;
//biases BRAM
(* dont_touch = "true" *) logic[10 : 0]	addra_bia;
(* dont_touch = "true" *) logic[10 : 0]	addrb_bia;
(* dont_touch = "true" *) logic    		ena_bia;
(* dont_touch = "true" *) logic    		enb_bia;
(* dont_touch = "true" *) logic           wea_bia;
(* dont_touch = "true" *) logic           web_bia;
//inputs BRAM
(* dont_touch = "true" *) logic[10 : 0]	addra_inp;
(* dont_touch = "true" *) logic[10 : 0]	addrb_inp;
(* dont_touch = "true" *) logic    		ena_inp;
(* dont_touch = "true" *) logic    		enb_inp;
(* dont_touch = "true" *) logic           wea_inp;
(* dont_touch = "true" *) logic           web_inp;
//weights BRAM
(* dont_touch = "true" *) logic[10 : 0]	addra_wei;
(* dont_touch = "true" *) logic[10 : 0]	addrb_wei;
(* dont_touch = "true" *) logic    		ena_wei;
(* dont_touch = "true" *) logic    		enb_wei;
(* dont_touch = "true" *) logic           wea_wei;
(* dont_touch = "true" *) logic           web_wei;
//neuron
(* dont_touch = "true" *) logic    		clc_accumulator;
(* dont_touch = "true" *) logic    		accumulation_done;
(* dont_touch = "true" *) logic           neuron_en;
//output register BRAM
(* dont_touch = "true" *) logic[10 : 0]	addra_reg;
(* dont_touch = "true" *) logic[10 : 0]	addrb_reg;
(* dont_touch = "true" *) logic    		ena_reg;
(* dont_touch = "true" *) logic    		enb_reg;
(* dont_touch = "true" *) logic           wea_reg;
(* dont_touch = "true" *) logic           web_reg;
//axi stream master   
(* dont_touch = "true" *) logic    		axis_master_write_data;
//intern signals
//control signals
(* dont_touch = "true" *) logic           nn_enable;					//this signal enables whole neural network, nn is OFF until this signal goes to '1'
(* dont_touch = "true" *) logic           data_for_nn_rdy;			//this signal is set to '1' after cpu writes valid values inside control register
//intern register for storing values of nodes in each layer of neural network
(* dont_touch = "true" *) logic[9:0] current_layer  [0:4];
(* dont_touch = "true" *) logic[9:0] previous_layer [0:4];
//addreses used for  reading and writing information into BRAMs
(* dont_touch = "true" *) logic[9 :0]		inp_addr_cnt;				//should count up to 1024
(* dont_touch = "true" *) logic[7 :0]		bia_addr_cnt;				//should count up to 256
(* dont_touch = "true" *) logic[17:0]		wei_addr_cnt;				//should count up to 1024*2=2048 in our case
(* dont_touch = "true" *) logic[9 :0]		reg_addr_cnt;				//should count up to 1024
//counters for counting iterations and other things
(* dont_touch = "true" *) logic[9 :0]		inp_cnt;					//should count up to 1024
(* dont_touch = "true" *) logic[9 :0]		bia_cnt;					//max number of used neurons, in theory its 1024
(* dont_touch = "true" *) logic[10:0]		wei_cnt;					//should count up to 1024*2=2048
(* dont_touch = "true" *) logic[9 :0]		neu_cnt;					//should count up to 1024
(* dont_touch = "true" *) logic[9 :0]		reg_cnt;					//should count up to 1024
//parameters for neural newtork calculations and "loops"
(* dont_touch = "true" *) logic[7 :0]		bia_iterations_per_cycle;	//max 128 [We will say that max number of used neurons is 256]	
(* dont_touch = "true" *) logic[7 :0]		bia_iterations_per_layer;  	//max 128								
(* dont_touch = "true" *) logic[9 :0]	    inp_iterations_per_cycle;	//max 1024
(* dont_touch = "true" *) logic[7 :0]	    inp_iterations_per_layer;  	//max 128								
(* dont_touch = "true" *) logic[17:0]		wei_iterations_per_cycle;	//max 262144
(* dont_touch = "true" *) logic[7 :0]	    wei_iterations_per_layer; 	//max 128 
(* dont_touch = "true" *) logic[9 :0]		neu_iterations_per_cycle;	//max 1024
(* dont_touch = "true" *) logic[10:0]	    neu_iterations_per_layer;  	//max 128								
(* dont_touch = "true" *) logic[10:0]		reg_iterations_per_cycle;	//max 1024
(* dont_touch = "true" *) logic[7 :0]		reg_iterations_per_layer;	//max 128

(* dont_touch = "true" *) logic[7 :0]		iterations_per_layer_done;	//max 128
//parameters used for nn calculations
(* dont_touch = "true" *) logic[2 :0]		working_on_layer;			//this parameter tells us on which layer are we working ('0' for first(hidden1) layer)
(* dont_touch = "true" *) logic[9 :0]		inp_addr_cnt_rd;			//max 1024
(* dont_touch = "true" *) logic[7 :0]     bia_addr_cnt_rd;			//max 128
(* dont_touch = "true" *) logic[17:0]     wei_addr_cnt_rd;			//max 262144
(* dont_touch = "true" *) logic[9 :0]		reg_addr_cnt_rd;			//max 1024
//intern signals
(* dont_touch = "true" *) logic			set_layers_info_en;			//used to enable storing network informations inside registers

assign po_fsm_state = state_reg;

/**********************ASSIGNING INPUT VALUES**********************/
assign 			nn_enable       		 	= pi_ctrl_signals[0];
assign 			data_for_nn_rdy 		 	= pi_ctrl_signals[1];
/**********************ASSIGNING INTERN VALUES*********************/
assign 			inp_iterations_per_cycle	= previous_layer[working_on_layer]; 		//784-16-16 in our case
assign			inp_iterations_per_layer	= current_layer[working_on_layer] / num_of_used_neurons;
assign 			bia_iterations_per_cycle 	= num_of_used_neurons;													   
assign 			wei_iterations_per_cycle	= previous_layer[working_on_layer] * num_of_used_neurons;//784*2-16*2-16*2 in our case
assign 			neu_iterations_per_cycle	= inp_iterations_per_cycle;					//same as num of inputs, we are saving resources								   
assign 			reg_iterations_per_cycle	= num_of_used_neurons;

/***************************STATES LOGIC***************************/
always_ff @(posedge pi_clk) begin
    if(pi_rst)
        state_reg <= OFF;
    else
        state_reg <= state_next;//iz nekog razloga i state_next je nakon sinteze postao sekvencijalan. Ovo mozda bude problem kasnije
end

/**************************SEQUENTIAL LOGIC*************************/
always_ff @(posedge pi_clk) begin
	if(pi_rst)	begin
	    previous_layer[0] <= 0;//preparing number of nodes in each layer,
        previous_layer[1] <= 0;//it's separated in 2 segments just to make it easer
        previous_layer[2] <= 0;//to work with it
        previous_layer[3] <= 0;
        previous_layer[4] <= 0;
                           
        current_layer [0] <= 0;
        current_layer [1] <= 0;
        current_layer [2] <= 0;
        current_layer [3] <= 0;
        current_layer [4] <= 0;
	end	
	else if(set_layers_info_en) begin
		previous_layer[0] <= pi_num_of_input_nodes  [9  :0] ;//preparing number of nodes in each layer,
        previous_layer[1] <= {2'b00,pi_num_of_hidden[7 -:8]};//it's separated in 2 segments just to make it easer
        previous_layer[2] <= {2'b00,pi_num_of_hidden[15-:8]};//to work with it
        previous_layer[3] <= {2'b00,pi_num_of_hidden[23-:8]};
        previous_layer[4] <= {2'b00,pi_num_of_hidden[31-:8]};
                          
        current_layer [0] <= {2'b00,pi_num_of_hidden[7 -:8]};
        current_layer [1] <= {2'b00,pi_num_of_hidden[15-:8]};
        current_layer [2] <= {2'b00,pi_num_of_hidden[23-:8]};
        current_layer [3] <= {2'b00,pi_num_of_hidden[31-:8]};
        current_layer [4] <= pi_num_of_output_nodes [9  :0] ;
    end
end

always_ff @(posedge pi_clk) begin							//Counters logic
	if(pi_rst) begin
		reset_network_counters();
		iterations_per_layer_done  <= 1;  
	end
	else begin
		accumulation_done<= 1'b0;
		
		if(state_reg == SET_LAYERS_INFO) begin							/*----------------------SET_LAYERS_INFO*/
			inp_addr_cnt 		<= 0;
			inp_cnt				<= inp_iterations_per_cycle;//in our case 784 for 1st iteration
		end
	
		if(state_reg == LOAD_INPUTS) begin								/*--------------------LOAD_INPUTS STATE*/
			if(inp_cnt == 0) begin
				bia_cnt		   	<= bia_iterations_per_cycle;//number of used neurons
				reg_addr_cnt	<= 0; //DODATO
				inp_addr_cnt_rd	<= 0;
				bia_addr_cnt_rd	<= 0;
				wei_addr_cnt_rd	<= 0;
				reg_addr_cnt_rd	<= 0;
			end
			else if(pi_axis_slave_valid_data) begin
				inp_cnt 		<= inp_cnt   	- 1'b1;
				inp_addr_cnt	<= inp_addr_cnt + 1'b1;
			end
		end
		
		if(state_reg ==  LOAD_BIASES) begin								/*--------------------LOAD_BIASES STATE*/
			if(bia_cnt==0)
				wei_cnt			<= wei_iterations_per_cycle;//number of nodes in prev layer * number of used neurons
			else if(pi_axis_slave_valid_data) begin
				bia_cnt 		<= bia_cnt   	- 2'b10;	//-2 because we have dual-port BRAMs
				bia_addr_cnt	<= bia_addr_cnt + 2'b10;	//+2 because we have dual-port BRAMs
			end
		end
		
		if(state_reg == LOAD_WEIGHTS) begin								/*-------------------LOAD_WEIGHTS STATE*/
			if(wei_cnt == 0)
				neu_cnt			<= neu_iterations_per_cycle;//number of nodes in prev layer
			else if(pi_axis_slave_valid_data) begin
				wei_cnt 		<= wei_cnt   	- 2'b10;	//-2 because we have dual-port BRAMs
				wei_addr_cnt	<= wei_addr_cnt + 2'b10;	//+2 because we have dual-port BRAMs
			end
		end
		
		if(state_reg == NEURON_CALC) begin								/*--------------------NEURON_CALC STATE*/
			if(neu_cnt == 0) begin
				accumulation_done<= 1'b1;					//delayed signal, needed for synchronization
				inp_addr_cnt_rd	 <= 0;
				wei_addr_cnt_rd	 <= 0;
				//bia_addr_cnt_rd  <= bia_addr_cnt_rd + 2'b10;
				bia_addr_cnt_rd	 <= 0; //Nije uzeto u obzir ako se koristi vise od 2 neurona !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				reg_cnt			 <= reg_iterations_per_cycle;
				neuron_en 		 <= 1'b0;					//disables neuron
			end
			else begin
				neuron_en 		 <= 1'b1;					//enables neuron realized like D FF because we need 1 clock delay because of used BRAMS
				inp_addr_cnt_rd  <= inp_addr_cnt_rd + 1'b1;
				wei_addr_cnt_rd  <= wei_addr_cnt_rd + 1'b1;
				neu_cnt			 <= neu_cnt - 1'b1;			//we need same number of iteration as number of nodes in prev layer
			end
		end

		if(state_reg == STORE_RESULT) begin
			if(reg_cnt == 0) begin
				bia_addr_cnt	<= 0;
				inp_addr_cnt	<= 0;
				wei_addr_cnt	<= 0;
				if(iterations_per_layer_done == inp_iterations_per_layer)
					iterations_per_layer_done <= 1;
				else begin
					iterations_per_layer_done <= iterations_per_layer_done + 1'b1;
					bia_cnt		<= bia_iterations_per_cycle;//in our case again set to number of used neurons which is 2
				end
			end
			else begin
				reg_addr_cnt	<= reg_addr_cnt + 2'b10;
				reg_cnt			<= reg_cnt - 2'b10;			//because we have dual-port BRAMs
			end
		end	
																		/*---------------SEND_DATA_TO_CPU STATE*/
		if(state_reg == SEND_DATA_TO_CPU) begin
			axis_master_write_data 		<= 1'b0;				//we are reading only on one port - PORT A
			if(reg_addr_cnt_rd == current_layer[working_on_layer])
				working_on_layer		<= working_on_layer + 1'b1;
			else if(pi_axis_master_data_stored)
				reg_addr_cnt_rd			<= reg_addr_cnt_rd + 1'b1;
			else
				axis_master_write_data 	<= 1'b1;				//we are reading only on one port - PORT A
		end
		
		if(state_reg == PREPARE_INPUTS)
			inp_cnt						<= inp_iterations_per_cycle;
	end
end

/*********************COMBINATIONAL LOGIC (FSM)*********************/
always_comb begin
    
	f_BRAMS_rst();											//just in case
	set_layers_info_en 	<= 0;
	wren_stat_reg		<= 1'b0;
	
    case(state_reg)
        
        OFF: begin/*------------------------------------OFF STATE*/
            f_BRAMS_rst();
         
            wren_stat_reg			   <= 0;  //NIJE REALIZOVAN            
            bsy                        <= 0;  //NIJE REALIZOVAN     
            axis_slave_data_stored     <= 0;  //Moore   
            addra_bia                  <= 0;                  
            addrb_bia                  <= 0;                  
            ena_bia                    <= 0;                    
            enb_bia                    <= 0;                    
            wea_bia                    <= 0;                    
            web_bia                    <= 0;                    
            addra_inp                  <= 0;                  
            addrb_inp                  <= 0;                  
            ena_inp                    <= 0;                    
            enb_inp                    <= 0;                    
            wea_inp                    <= 0;                    
            web_inp                    <= 0;                    
            addra_wei                  <= 0;                  
            addrb_wei                  <= 0;                  
            ena_wei                    <= 0;                    
            enb_wei                    <= 0;                    
            wea_wei                    <= 0;                    
            web_wei                    <= 0;                    
            clc_accumulator            <= 0;                                    
            addra_reg                  <= 0;                  
            addrb_reg                  <= 0;                  
            ena_reg                    <= 0;                    
            enb_reg                    <= 0;                    
            wea_reg                    <= 0;                    
            web_reg                    <= 0;                                                                
            set_layers_info_en         <= 0;    
            
            if (nn_enable)
                state_next  		<= IDLE;
            else
                state_next  		<= OFF;    
        end

        IDLE: begin/*----------------------------------IDLE STATE*/
            f_BRAMS_rst();
            if(data_for_nn_rdy) begin
            	set_layers_info_en 	<= 1'b1;				//enable signal for collecting information in registers            
            	wren_stat_reg		<= 1'b1;            
       			bsy                 <= 1'b1;
                state_next  		<= SET_LAYERS_INFO;
            end
            else
                state_next  		<= IDLE;
        end

        SET_LAYERS_INFO: begin/*------------------SET_LAYERS_INFO*/
            state_next      		<= LOAD_INPUTS;
        end

        LOAD_INPUTS: begin/*--------------------LOAD_INPUTS STATE*/
			axis_slave_data_stored 				<= 1'b0;
			f_BRAM_inp(0,1);

            if(inp_cnt==0)								
				state_next     					<= LOAD_BIASES;
            else begin
				if(pi_axis_slave_valid_data) begin
					f_BRAM_inp(1,1);
					axis_slave_data_stored 		<= 1'b1;
					addra_inp					<= inp_addr_cnt;
					addrb_inp					<= previous_layer[working_on_layer] + inp_addr_cnt;
					state_next					<= LOAD_INPUTS;
				end
				else
					state_next					<= LOAD_INPUTS;
            end
        end

        LOAD_BIASES: begin/*--------------------LOAD_BIASES STATE*/
			axis_slave_data_stored 				<= 1'b0;
			clc_accumulator						<= 1'b0;
			f_BRAM_bia(0,1);

			if(bia_cnt==0)
				state_next  					<= LOAD_WEIGHTS;
            else begin
				if(pi_axis_slave_valid_data) begin
					f_BRAM_bia(1,1);
					axis_slave_data_stored 		<= 1'b1;
					addra_bia   				<= bia_addr_cnt;
					addrb_bia   				<= bia_addr_cnt	+ 1'b1;
					state_next					<= LOAD_BIASES;
				end
				else	
					state_next					<= LOAD_BIASES;
            end
        end

        LOAD_WEIGHTS: begin/*------------------LOAD_WEIGHTS STATE*/
			axis_slave_data_stored 				<= 1'b0;
			f_BRAM_wei(0,1);

			if(wei_cnt==0)
				state_next  					<= NEURON_CALC;
            else begin
				if(pi_axis_slave_valid_data) begin
					f_BRAM_wei(1,1);
					axis_slave_data_stored 		<= 1'b1;
					addra_wei   				<= wei_addr_cnt;
					addrb_wei   				<= wei_addr_cnt	+ 1'b1;
					state_next					<= LOAD_WEIGHTS;
				end
				else	
					state_next					<= LOAD_WEIGHTS;
            end
        end

        NEURON_CALC: begin/*--------------------NEURON_CALC STATE*/
			f_BRAM_inp(0,0);
			f_BRAM_bia(0,0);
			f_BRAM_wei(0,0);

			if(neu_cnt==0)
				state_next  	 <= WAIT_SIG;
            else begin
				f_BRAM_inp(1,0);		 					//enables BRAMs in reading mode
				f_BRAM_bia(1,0);
				f_BRAM_wei(1,0);
				addra_inp	 	 <= inp_addr_cnt_rd;		//increased by 1 every NEURON_CALC iteration
				addrb_inp	 	 <= previous_layer[working_on_layer] + inp_addr_cnt_rd;
				addra_bia   	 <= bia_addr_cnt_rd;		//increased by 2 after every cycle
				addrb_bia   	 <= bia_addr_cnt_rd + 1'b1;
				addra_wei   	 <= wei_addr_cnt_rd;		//increased by 1 every NEURON_CALC iteration
				addrb_wei   	 <= previous_layer[working_on_layer] + wei_addr_cnt_rd;//offset is same as number of nodes in prev layer

				state_next 		 <= NEURON_CALC;
            end
        end

		WAIT_SIG:
			state_next 			<= WAIT_SIG2;
			
		WAIT_SIG2:
			state_next 			<= STORE_RESULT;

        STORE_RESULT: begin/*------------------STORE_RESULT STATE*/
			f_BRAM_reg(0,1);
			clc_accumulator		  	<= 1'b0;

			if(reg_cnt==0) begin
				if(iterations_per_layer_done == inp_iterations_per_layer) begin	//Here we change layer
					state_next		<= SEND_DATA_TO_CPU;
					clc_accumulator	<= 1'b1;
					wren_stat_reg	<= 1'b1;            
           			bsy             <= 1'b0;
				end
				else begin
					clc_accumulator	<= 1'b1;
					state_next		<= LOAD_BIASES;
				end
			end
			else begin
				f_BRAM_reg(1,1);
				addra_reg 		<= reg_addr_cnt;
				addrb_reg 		<= reg_addr_cnt + 1'b1;
				state_next		<= STORE_RESULT;
			end
        end

        SEND_DATA_TO_CPU: begin/*----------SEND_DATA_TO_CPU STATE*/
			ena_reg 					<= 1'b0;				// we only need port A
			wea_reg 					<= 1'b0;    	
			clc_accumulator				<= 1'b0;		
			addra_reg					<= reg_addr_cnt_rd;

			if(reg_addr_cnt_rd==current_layer[working_on_layer]) begin
				wren_stat_reg		<= 1'b1;            
       			bsy                 <= 1'b1;
				state_next				<= PREPARE_INPUTS;
			end
			else if(pi_axis_master_data_stored)
				state_next				<= SEND_DATA_TO_CPU;
			else begin
				ena_reg 				<= 1'b1;				// we only need port A
				wea_reg 				<= 1'b0; 
				state_next				<= SEND_DATA_TO_CPU;
			end
		end
		
		PREPARE_INPUTS:
			state_next					<= LOAD_INPUTS;
			
    endcase
end

/*~~~~~~~~~~*/
assign po_current_layer_nodes = current_layer[working_on_layer];
/*~~~~~~~~~~*/

/*********************ASSIGNING OUTPUT VALUES*********************/
assign po_wren_stat_reg          = wren_stat_reg;         
assign po_stat_reg_data          = {15'h0000,bsy};                        
assign po_axis_slave_data_stored = axis_slave_data_stored;
assign po_addra_bia              = addra_bia;             
assign po_addrb_bia              = addrb_bia;             
assign po_ena_bia                = ena_bia;               
assign po_enb_bia                = enb_bia;               
assign po_wea_bia                = wea_bia;               
assign po_web_bia                = web_bia;               
assign po_addra_inp              = addra_inp;             
assign po_addrb_inp              = addrb_inp;             
assign po_ena_inp                = ena_inp;               
assign po_enb_inp                = enb_inp;               
assign po_wea_inp                = wea_inp;               
assign po_web_inp                = web_inp;               
assign po_addra_wei              = addra_wei;             
assign po_addrb_wei              = addrb_wei;             
assign po_ena_wei                = ena_wei;               
assign po_enb_wei                = enb_wei;               
assign po_wea_wei                = wea_wei;               
assign po_web_wei                = web_wei;                                   
assign po_clc_accumulator        = clc_accumulator;       
assign po_accumulation_done      = accumulation_done;     
assign po_neuron_en              = neuron_en;                         
assign po_addra_reg              = addra_reg;             
assign po_addrb_reg              = addrb_reg;             
assign po_ena_reg                = ena_reg;               
assign po_enb_reg                = enb_reg;               
assign po_wea_reg                = wea_reg;               
assign po_web_reg                = web_reg;               
assign po_axis_master_write_data = axis_master_write_data && ~pi_axis_master_data_stored;//Forcing signal to drop earlier
//assign po_axis_master_write_data = axis_master_write_data;//Forcing signal to drop earlier

/****************************FUNCTIONS****************************/
//BRAMS FUNCTIONS
function void f_BRAM_bia(input logic en,wren);
     if(en) begin
        ena_bia = 1'b1; 
        enb_bia = 1'b1;
        wea_bia = wren;
        web_bia = wren;
     end
     else begin
        ena_bia = 1'b0; 
        enb_bia = 1'b0;
     end
endfunction

function void f_BRAM_inp(input logic en,wren);
     if(en) begin
        ena_inp = 1'b1; 
        enb_inp = 1'b1;
        wea_inp = wren;
        web_inp = wren;
     end
     else begin
        ena_inp = 1'b0; 
        enb_inp = 1'b0;
     end
endfunction

function void f_BRAM_wei(input logic en,wren);
     if(en) begin
        ena_wei = 1'b1; 
        enb_wei = 1'b1;
        wea_wei = wren;
        web_wei = wren;
     end
     else begin
        ena_wei = 1'b0; 
        enb_wei = 1'b0;
     end
endfunction

function void f_BRAM_reg(input logic en,wren);
     if(en) begin
        ena_reg = 1'b1; 
        enb_reg = 1'b1;
        wea_reg = wren;
        web_reg = wren;
     end
     else begin
        ena_reg = 1'b0; 
        enb_reg = 1'b0;
     end
endfunction

function void f_BRAMS_rst();//disable all brams
    f_BRAM_bia(0,0);
    f_BRAM_inp(0,0);
    f_BRAM_wei(0,0);
    f_BRAM_reg(0,0);
endfunction

function void reset_network_counters();
	inp_addr_cnt				= 0;				
	bia_addr_cnt				= 0;				
	wei_addr_cnt				= 0;				
	reg_addr_cnt				= 0;				
	inp_cnt						= 0;					
	bia_cnt						= 0;					
	wei_cnt						= 0;					
	neu_cnt						= 0;					
	reg_cnt						= 0;
	inp_addr_cnt_rd				= 0;						
	bia_addr_cnt_rd				= 0;						
	wei_addr_cnt_rd				= 0;						
	reg_addr_cnt_rd				= 0;
	working_on_layer			= 0;	
	neuron_en					= 0;  
	accumulation_done			= 0;
	axis_master_write_data		= 0; 
endfunction

endmodule : control_unit

