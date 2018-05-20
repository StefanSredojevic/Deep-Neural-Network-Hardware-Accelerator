
/*
    This CLASS is useless, because neuron structure is changed
*/

//Interface
interface neuron_interface;
	logic 					pi_clk;
	logic 					pi_rst;
	logic					pi_valid;
	logic 					pi_clc_accumulator;
	logic signed [15:0]		pi_bias;
	logic signed [15:0]		pi_weights;
	logic signed [15:0]		pi_inputs;
	logic					pi_accumulation_done;
	logic signed [15:0]		po_multiply_test;
	logic [15:0]			po_accumulation_test;
	logic [15:0]			po_BRAM_add;
	logic					po_BRAM_en;
	
	//Data for reading CSV file
	int 	fd_bias,fd_input,fd_weight;	//file descriptor
	int 	status;
	real	f_bias,f_input,f_weight,f_multiply,f_accumulator = 6.462664,f_accumulator_plus_bias;
	
	//Signals
	real multiply2real 			= 0;
	real accumulator2real 		= 0;
	real f_multiply_l;
	real f_accumulator_l,f_accumulator_l2;
	
	//Including rnd_biases, rnd_inputs and rnd_weights
	`include "../tb/rnd_biases_weights_inputs_bin.sv"

	//TASK init
	task init();	
		fork
			$display("Starting simulation...");
			#100000 $finish();

			pi_clk 				<= 0;
			pi_rst 				<= 1;
			pi_clc_accumulator	<= 1;
			pi_accumulation_done<= 0;
			pi_valid			<= 0;
			
			#100 pi_rst 				<= 0;
			#100 pi_clc_accumulator		<= 0;
		join
	endtask : init
	
	task open_files();
		//open files
		fd_bias 	= $fopen("../tb/rnd_biases_int.dat" ,"r");
		fd_input 	= $fopen("../tb/rnd_inputs_int.dat" ,"r");
		fd_weight 	= $fopen("../tb/rnd_weights_int.dat","r");
	endtask
	
	task close_files();
		$fclose(fd_bias);
		$fclose(fd_input);
		$fclose(fd_weight);
	endtask
	
	//TASK calc_neuron_hw
	task calc_neuron();//Hardware
		for(int j=9;j>0;j--) begin
			for(int i=783;i>0;i--) begin
				@(posedge pi_clk);
				/*~~~~~HARDWARE~~~~~*/
				pi_bias	  <= rnd_biases [41];
				pi_inputs <= rnd_inputs [i];
				pi_weights<= rnd_weights[i];
				if(i>1) begin
					pi_accumulation_done<= 0;
					pi_valid			<= 1;
				end
				else begin
					pi_accumulation_done<= 1;
					pi_valid			<= 0;
					f_accumulator		 = 0;
				end
				/*~~~~~SOFTWARE~~~~~*/
				if($feof(fd_input) != 1) begin
					//read bias
						//status = $fscanf(fd_bias ,"%f,",f_bias);
					//f_bias = 6.462664;
					//read input
					status = $fscanf(fd_input ,"%f,",f_input);
					if(status != 1) $error;//you did not read one value
					//read weight
					status = $fscanf(fd_weight,"%f,",f_weight);
					if(status != 1) $error;//you did not read one value
				
					f_multiply	  				= f_input * f_weight;
					f_accumulator 				= f_accumulator + f_multiply;
					//if(i==1)
						//f_accumulator_plus_bias = f_accumulator + f_bias;
				end
				
				if(po_multiply_test[15]==1'b1)
					multiply2real	 = -(bin2real(~(po_multiply_test-1)));
				else
					multiply2real	 = bin2real(po_multiply_test);
					
				accumulator2real = bin2real(po_accumulation_test);
			end
		end
	endtask : calc_neuron
	
	task late_signals();
		while(1) begin
			@(posedge pi_clk);
			f_multiply_l 	<= f_multiply;
			f_accumulator_l	<= f_accumulator; 
			f_accumulator_l2<= f_accumulator_l;
		end
	endtask
		
	//FUNCTION bin2real
	function real bin2real(input logic[15:0] x);
		logic sign;
		
		if (x[15]==1'b0)
			sign = 1'b0;
		else
			sign = 1'b1;
			
		if(!sign)
		//bin2real = 1.0*x[11]+2.0*x[12]+4.0*x[13]+8.0*x[14]+0.5*x[10]+0.25*x[9]+0.125*x[8]+0.0625*x[7]+0.03125*x[6]+0.015625*x[5]+0.0078125*x[4]+0.00390625*x[3]+0.001953125*x[2]+0.0009765625*x[1]+0.00048828125*x[0];
		bin2real = 1.0*x[7]+2.0*x[8]+4.0*x[9]+8.0*x[10]+16.0*x[11]+32.0*x[12]+64.0*x[13]+128.0*x[14]+0.5*x[6]+0.25*x[5]+0.125*x[4]+0.0625*x[3]+0.03125*x[2]+0.015625*x[1]+0.0078125*x[0];
		else
		//bin2real = -(1.0*x[11]+2.0*x[12]+4.0*x[13]+8.0*x[14]+0.5*x[10]+0.25*x[9]+0.125*x[8]+0.0625*x[7]+0.03125*x[6]+0.015625*x[5]+0.0078125*x[4]+0.00390625*x[3]+0.001953125*x[2]+0.0009765625*x[1]+0.00048828125*x[0]);
		bin2real = -(1.0*x[7]+2.0*x[8]+4.0*x[9]+8.0*x[10]+16.0*x[11]+32.0*x[12]+64.0*x[13]+128.0*x[14]+0.5*x[6]+0.25*x[5]+0.125*x[4]+0.0625*x[3]+0.03125*x[2]+0.015625*x[1]+0.0078125*x[0]);
	endfunction
	
endinterface : neuron_interface
