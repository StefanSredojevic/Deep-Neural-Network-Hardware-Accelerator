
//Interface
interface data_path_interface #();
    //Neuron signals
    logic 		pi_clk;
    logic 		pi_rst;
    logic		pi_valid;
    logic 		pi_clc_accumulator;
    logic 		pi_accumulation_done;
    //Sigmoid LUT BRAM signals
    /*  NO PORTS  */
    //Input BRAM
    logic 		pi_ena_inp;
    logic 		pi_enb_inp;
    logic 		pi_wea_inp;
    logic 		pi_web_inp;
    logic[13:0] pi_addra_inp;
    logic[13:0] pi_addrb_inp;
    logic[15:0] pi_dia_inp;
    logic[15:0] pi_dib_inp;
    //Weights BRAM
    logic 		pi_ena_wei;
    logic 		pi_enb_wei;
    logic 		pi_wea_wei;
    logic 		pi_web_wei;
    logic[13:0] pi_addra_wei;
    logic[13:0] pi_addrb_wei;
    logic[15:0] pi_dia_wei;
    logic[15:0] pi_dib_wei;
    //Output Register BRAM
    logic 		pi_ena_reg;
    logic 		pi_enb_reg;
    logic 		pi_wea_reg;
    logic 		pi_web_reg;
    logic[9:0]  pi_addra_reg;
    logic[9:0]  pi_addrb_reg;
    logic[15:0] po_doa;
    logic[15:0] po_dob;

    //VARIABLES
    int inputl,
        hidden1,
        hidden2,
        outputl; //input,hidden 1, hidden 2 and output layers
    bit[15:0] input_nodes_val[];       //Input values
    bit[15:0] weights_val[];           //Input values
    int number_of_weights;
    int number_of_nodes_previous_layer[3];
    int number_of_nodes_current_layer[3];
    int temp_previous_layer_num;
    int temp_current_layer_num;
    int number_of_used_neurons;
    int M,
        N,
        P;
    int i,
        j,
        k;
    int initS,
        snounS,
        snnS,
        sirS,
        swrS,
        wiBS,
        wwBS,
        snS = 0; //Signals for signaling when certain task start

    bit[13:0] addr_inp;
    bit[13:0] addr_inp_offset;
    bit[15:0] dia_inp;
    bit[15:0] dib_inp;

    bit[13:0] addr_wei;
    bit[13:0] addr_wei_offset;
    bit[15:0] dia_wei;
    bit[15:0] dib_wei;

    bit[15:0] temp_input_val;
    bit[15:0] temp_data;

    //Including [783:0]rnd_inputs and [783:0]rnd_weights
    `include "../tb/rnd_weights_inputs_bin.sv"

    //TASK init
    task init();
        initS = 1;
        fork
            pi_clk 				<= 0;
            pi_rst 				<= 0;
            pi_valid			<= 0;
            pi_clc_accumulator 	<= 0;
            pi_accumulation_done <= 0;
            pi_ena_inp 			<= 0;
            pi_enb_inp 			<= 0;
            pi_wea_inp 			<= 0;
            pi_web_inp 			<= 0;
            pi_addra_inp 		<= 0;
            pi_addrb_inp 		<= 0;
            pi_dia_inp 			<= 0;
            pi_dib_inp 			<= 0;
            pi_ena_wei 			<= 0;
            pi_enb_wei 			<= 0;
            pi_wea_wei 			<= 0;
            pi_web_wei 			<= 0;
            pi_addra_wei 		<= 0;
            pi_addrb_wei 		<= 0;
            pi_dia_wei 			<= 0;
            pi_dib_wei 			<= 0;
            pi_ena_reg 			<= 0;
            pi_enb_reg 			<= 0;
            pi_wea_reg 			<= 0;
            pi_web_reg 			<= 0;
            pi_addra_reg 		<= 0;
            pi_addrb_reg 		<= 0;
            #50  pi_rst			<= 1;
            #100 pi_rst			<= 0;

            $display("Starting simulation...");
        join
    endtask : init

    task w_input(input logic[13:0] add, input logic[15:0] dat, input string port); //writing inputs manually (not used in this TB)
        if (port == "a") begin
            fork
                pi_ena_inp 	<= 1;
                pi_wea_inp 	<= 1;
                pi_addra_inp <= add;
                pi_dia_inp	<= dat;
            join

            repeat (3)
                @(posedge pi_clk);

            fork
                pi_ena_inp 	<= 0;
                pi_wea_inp 	<= 0;
            join
        end else if (port == "b") begin
            fork
                pi_enb_inp 	<= 1;
                pi_web_inp 	<= 1;
                pi_addrb_inp <= add;
                pi_dib_inp	<= dat;
            join

            repeat (3)
                @(posedge pi_clk);

            fork
                pi_enb_inp 	<= 0;
                pi_web_inp 	<= 0;
            join
        end
    endtask : w_input

    task w_weight(input logic[13:0] add, input logic[15:0] dat, input string port); //writing weights manually (not used in this TB)
        if (port == "a") begin
            fork
                pi_ena_wei 	<= 1;
                pi_wea_wei 	<= 1;
                pi_addra_wei <= add;
                pi_dia_wei	<= dat;
            join

            repeat (3)
                @(posedge pi_clk);

            fork
                pi_ena_wei 	<= 0;
                pi_wea_wei 	<= 0;
            join
        end else if (port == "b") begin
            fork
                pi_enb_wei 	<= 1;
                pi_web_wei 	<= 1;
                pi_addrb_wei <= add;
                pi_dib_wei	<= dat;
            join

            repeat (3)
                @(posedge pi_clk);

            fork
                pi_enb_wei 	<= 0;
                pi_web_wei 	<= 0;
            join
        end
    endtask : w_weight

    task clc_neuron(); //Task for clearing score from neuron's accumulator
        @(posedge pi_clk);
        pi_clc_accumulator <= 1;
        pi_valid 		   <= 0;
        @(posedge pi_clk);
        pi_clc_accumulator <= 0;
    endtask

    task accumulation_done(); //Task for signaling finished accumulation cycle
        @(posedge pi_clk);
        pi_accumulation_done <= 1;
        @(posedge pi_clk); @(posedge pi_clk);
        pi_accumulation_done <= 0;
    endtask

    function void set_nodes_num(input int inputl_num, hidden1_num, hidden2_num, outputl_num); //Number of nodes in any layer must be even number
        snnS 	= 1;
        inputl  = inputl_num;
        hidden1 = hidden1_num;
        hidden2 = hidden2_num;
        outputl = outputl_num;

        number_of_nodes_previous_layer[0] = inputl_num;
        number_of_nodes_previous_layer[1] = hidden1_num;
        number_of_nodes_previous_layer[2] = hidden2_num;

        number_of_nodes_current_layer[0] = hidden1_num;
        number_of_nodes_current_layer[1] = hidden2_num;
        number_of_nodes_current_layer[2] = outputl_num;
    endfunction

    function void set_number_of_used_neurons(input int num); //This function is not implemented well in fallowing algotithms
        snounS = 1;                                          //just to be sure always use 2 neurons
        number_of_used_neurons = num;
    endfunction

    function void set_inputs_rnd(); //Setting inputs random, number of inputs is limited to 784
        sirS = 1;
        if (inputl <= 0 || inputl >= 785)
            $error("Something is wrong with number of input nodes, number of nodes should not be larger than 784 and you number is %d \n", inputl);

        input_nodes_val	= new[inputl+hidden1+hidden2+outputl];

        for (int i = 0; i < inputl; i++)
            input_nodes_val[i] = rnd_inputs[i];
    endfunction

    function void set_weights_rnd(); //Setting weights random, number of inputs is limited to 784*16
        swrS = 1;
        number_of_weights = inputl * hidden1 + hidden1 * hidden2 + hidden2 * outputl;

        weights_val	= new[number_of_weights];

        for (int i = 0; i < number_of_weights; i++)
            weights_val[i] = rnd_weights[i];
    endfunction

    task write_inputs_BRAM(); //Write inputs to BRAM
        wiBS 			 = 1;
        addr_inp 		<= 0;
        addr_inp_offset <= inputl + hidden1 + hidden2 + outputl;
        dia_inp  		<= 0;
        dib_inp  		<= 0;

        for (int i = 0; i < inputl; i++) begin

            @(posedge pi_clk) ;

            fork
                pi_addra_inp <= addr_inp;
                pi_addrb_inp <= addr_inp + addr_inp_offset;

                pi_dia_inp   <= input_nodes_val[i];
                pi_dib_inp   <= input_nodes_val[i];

                pi_wea_inp <= 1;
                pi_web_inp <= 1;

                pi_ena_inp <= 1;
                pi_enb_inp <= 1;
            join

            addr_inp++;
        end
        
        @(posedge pi_clk) ;

        pi_wea_inp <= 0;
        pi_web_inp <= 0;

        pi_ena_inp <= 0;
        pi_enb_inp <= 0;
    endtask

    task write_weights_BRAM(); //Write weights to BRAM
        wwBS     = 1;
        addr_wei <= 0;
        dia_wei <= 0;
        dib_wei <= 0;

        for (int i = 0; i < number_of_weights; i++) begin

            @(posedge pi_clk) ;

            fork
                pi_addra_wei <= addr_wei;
                pi_dia_wei   <= weights_val[i];
                pi_wea_wei   <= 1;
                pi_ena_wei   <= 1;
            join

            addr_wei++;
        end

        @(posedge pi_clk) ;

        pi_wea_wei <= 0;
        pi_web_wei <= 0;

        pi_ena_wei <= 0;
        pi_enb_wei <= 0;
    endtask

    task start_nn(); //Start neural network
        snS = 1;
        M 	= 0;
        N 	= 0;
        P 	= number_of_nodes_previous_layer[0];

        clc_neuron();

        for (i = 0; i < 3; i++) begin // i = number of all layers - 1
            temp_previous_layer_num = number_of_nodes_previous_layer[i];
            temp_current_layer_num  = number_of_nodes_current_layer[i];

            for (j = 0; j < temp_current_layer_num / 2; j++) begin // j = numer off all iterations nedded for 1 layer, we have 2 neurons so it will be temp_current_layer_num/2

                clc_neuron();

                for (k = 0; k < temp_previous_layer_num; k++) begin // k = number of previous layer nodes, on this way we will accumulate all values

                    @(posedge pi_clk) ;

                    fork
                        pi_wea_inp   <= 0; //Read
                        pi_web_inp   <= 0; //Read
                        pi_wea_wei   <= 0; //Read
                        pi_web_wei   <= 0; //Read

                        pi_wea_reg   <= 1; //Writing to output register, but enable signal will be set to 1 at the end of the loop
                        pi_web_reg   <= 1;

                        pi_addra_inp <= k + N;
                        pi_addrb_inp <= k + N;
                        pi_addra_wei <= k + 2 * number_of_nodes_previous_layer[i] * j + M; //Number of used neurons is not taken in consideration, formula only works for 2 neurons
                        pi_addrb_wei <= k + 2 * number_of_nodes_previous_layer[i] * j + M + number_of_nodes_previous_layer[i];

                        pi_addra_reg <= P;
                        pi_addrb_reg <= P + 1;

                        pi_ena_inp <= 1;
                        pi_enb_inp <= 1;
                        pi_ena_wei <= 1;
                        pi_enb_wei <= 1;

                    join

                    @(posedge pi_clk) ;
                    pi_valid   <= 1;
                    @(posedge pi_clk) ;
                    pi_valid   <= 0;

                end

                pi_valid   <= 0;
                accumulation_done();

                @(posedge pi_clk) ;
                fork
                    pi_ena_reg <= 1;
                    pi_enb_reg <= 1;
                join
                @(posedge pi_clk) ;
                fork
                    pi_ena_reg <= 0;
                    pi_enb_reg <= 0;
                join
                P = P + number_of_used_neurons;
            end
            M = M + number_of_nodes_previous_layer[i] * number_of_nodes_current_layer[i];
            N = N + number_of_nodes_previous_layer[i];

            read_from_output_register(i, N);

        end
    endtask

    task read_from_output_register(input int i, N); // Only one port for is used for reading data to make it easier for understanding

        for (int cnt = N; cnt < (N + number_of_nodes_current_layer[i]); cnt++) begin

            @(posedge pi_clk) ;

            fork
                pi_wea_reg   <= 0; //Reading output register
                pi_web_reg   <= 0;

                pi_addra_reg <= cnt;
                pi_addrb_reg <= cnt;

                pi_ena_reg <= 1;
                pi_enb_reg <= 1;
            join

            @(posedge pi_clk) ;
            @(posedge pi_clk) ;
            temp_data  <= po_doa;
            @(posedge pi_clk) ;
            pi_dia_inp <= temp_data;
            pi_dib_inp <= temp_data;

            fork
                pi_wea_inp <= 1; //Writing into input register
                pi_web_inp <= 1;

                pi_addra_inp <= cnt;
                pi_addrb_inp <= cnt + addr_inp_offset;

                pi_ena_inp <= 1;
                pi_enb_inp <= 1;
            join
        end

        @(posedge pi_clk) ;
        fork
            pi_ena_reg <= 0;
            pi_enb_reg <= 0;
        join

    endtask

endinterface : data_path_interface

/*
//Only used to get real number randomization, not used in this TB
class rand_class;
  rand int unsigned multiplier;
  real result, A, B;
 
  function post_tandomize();
     result = A + (B-A)*(real'(multiplier)/32'hffffffff);
  endfunction
  
  function void set_inputs_rnd();
        if(inputl<=0 || inputl>=785)
            $error("Something is wrong with number of input nodes, number of nodes should not be larger than 784 and you number is %d \n",inputl);
        
        inputV	= new[inputl];
        
        for(int i=0;i<inputl;i++)
            inputV[i] = rand_class.post_tandomize();
            
    endfunction
    
endclass
*/
