interface top_module_interface #(
    parameter integer C_S00_AXI_DATA_WIDTH	    = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH	    = 5 ,
    parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,
    parameter integer C_M00_AXIS_TDATA_WIDTH	= 32); 

    logic                                 s00_axi_aclk;
    logic                                 s00_axi_aresetn;
    logic [C_S00_AXI_ADDR_WIDTH-1 : 0]    s00_axi_awaddr;
    logic [2 : 0]                         s00_axi_awprot;
    logic                                 s00_axi_awvalid;
    logic                                 s00_axi_awready;
    logic [C_S00_AXI_DATA_WIDTH-1 : 0]    s00_axi_wdata;
    logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]s00_axi_wstrb;
    logic                                 s00_axi_wvalid;
    logic                                 s00_axi_wready;
    logic [1 : 0]                         s00_axi_bresp;
    logic                                 s00_axi_bvalid;
    logic                                 s00_axi_bready;
    logic [C_S00_AXI_ADDR_WIDTH-1 : 0]    s00_axi_araddr;
    logic [2 : 0]                         s00_axi_arprot;
    logic                                 s00_axi_arvalid;
    logic                                 s00_axi_arready;
    logic [C_S00_AXI_DATA_WIDTH-1 : 0]    s00_axi_rdata;
    logic [1 : 0]                         s00_axi_rresp;
    logic                                 s00_axi_rvalid;
    logic                                 s00_axi_rready;
    //Ports of Axi Slave Bus Interface S00_AXIS
    logic                                 s00_axis_aclk;
    logic                                 s00_axis_aresetn;
    logic                                 s00_axis_tready;
    logic [C_S00_AXIS_TDATA_WIDTH-1 : 0]  s00_axis_tdata;
    logic [(C_S00_AXIS_TDATA_WIDTH/8)-1:0]s00_axis_tstrb;
    logic                                 s00_axis_tlast;
    logic                                 s00_axis_tvalid;
    //Ports of Axi Master Bus Interface M00_AXIS
    logic                                 m00_axis_aclk;
    logic                                 m00_axis_aresetn;
    logic                                 m00_axis_tvalid;
    logic [C_M00_AXIS_TDATA_WIDTH-1 : 0]  m00_axis_tdata;
    logic [(C_M00_AXIS_TDATA_WIDTH/8)-1:0]m00_axis_tstrb;
    logic                                 m00_axis_tlast;
    logic                                 m00_axis_tready;

    `include "../tb/mnist_inputs_weights_biases_bin.sv"

    bit EN;
    bit DAT_RDY;

    logic [31:0]  input_num;
    logic [31:0]  hidden1_num;
    logic [31:0]  hidden2_num;
    logic [31:0]  hidden3_num;
    logic [31:0]  hidden4_num;
    logic [31:0]  hidden_num;//all in one register
    logic [31:0]  output_num;
    logic [31:0]  control_reg;
    
    logic[15:0] a,b;
	logic[31:0] c;
	int inputs_cnt,inputs_ptr;
    int biases_cnt,biases_ptr;
    int weights_cnt,weights_ptr;
    logic[15:0] next_layer_inputs[];
    int cnt_output_reg;
    bit first_layer;
    int fd_output_test;
    real output_test;
    int correct_output;
	int inp_ptr_val_temp;

    assign hidden_num[7-:8]  = hidden1_num;
    assign hidden_num[15-:8] = hidden2_num;
    assign hidden_num[23-:8] = hidden3_num;
    assign hidden_num[31-:8] = hidden4_num;

    assign control_reg = {30'b0,DAT_RDY,EN};


    task init();
        //axi lite slave
        s00_axi_aclk        <= 0;
	    s00_axi_aresetn     <= 0;
	    s00_axi_awaddr      <= 0;//need to drive
	    s00_axi_awprot      <= 0;
	    s00_axi_awvalid     <= 0;//need to drive
	    s00_axi_wdata       <= 0;//need to drive
	    s00_axi_wstrb       <= 0;//need to drive
	    s00_axi_wvalid      <= 0;
	    s00_axi_bready      <= 0;
	    s00_axi_araddr      <= 0;
	    s00_axi_arprot      <= 0;
	    s00_axi_arvalid     <= 0;
	    s00_axi_rready      <= 0;
        //axi stream slave
	    s00_axis_aclk       <= 0;
	    s00_axis_aresetn    <= 0;
	    s00_axis_tdata      <= 0;
	    s00_axis_tstrb      <= 0;
	    s00_axis_tlast      <= 0;
	    s00_axis_tvalid     <= 0;
        //axi stream master
	    m00_axis_aclk       <= 0;
	    m00_axis_aresetn    <= 0;
	    m00_axis_tready     <= 0;
        first_layer         <= 1;

    #50 s00_axi_aresetn     <= 1;
    #50 s00_axis_aresetn    <= 1;
    #50 m00_axis_aresetn    <= 1;
    endtask
        
    task clk();
        s00_axi_aclk        <= ~s00_axi_aclk;
        s00_axis_aclk       <= ~s00_axis_aclk;
        m00_axis_aclk       <= ~m00_axis_aclk;
    endtask

    task nn_layers_nodes_num(input logic [31:0] q,w,e,r,t,y);
        input_num   = q;  
        hidden1_num = w;
        hidden2_num = e;
        hidden3_num = r;
        hidden4_num = t;
        output_num  = y;
    endtask

    task nn_en(input bit switch);
        EN = switch;
    endtask

    task nn_dat_rdy(input bit switch);
        DAT_RDY = switch;
    endtask
    
    task axil_slave();
        axil_slave_send(0,input_num);
        axil_slave_send(1,hidden_num);
        axil_slave_send(2,output_num);
        axil_slave_send(3,control_reg); 
    endtask

    task axil_slave_send(input logic [31:0] addr,logic [31:0] data);
        @(posedge s00_axi_aclk);
        s00_axi_awaddr  <= addr;
        s00_axi_awvalid <= 1;
        s00_axi_wdata   <= data;
        s00_axi_wvalid  <= 1; 
        s00_axi_bready  <= 1;
        s00_axi_wstrb   <= ~0;//proveri ideja je da svi biti budu 1
        wait(s00_axi_awready); 
        @( posedge s00_axi_aclk);
        s00_axi_awvalid <= 0;
        s00_axi_awaddr  <= 0;
        wait(s00_axi_wready); 
        @(posedge s00_axi_aclk);
        s00_axi_wdata   <= 0;
        s00_axi_wstrb   <= 0;
        s00_axi_wvalid  <= 0; 
        wait(s00_axi_bvalid); 
        @(posedge s00_axi_aclk);
        s00_axi_bready  <= 0;
        @(posedge s00_axi_aclk);
    endtask

    task axis_slave(input logic [31:0] data);
        @(posedge s00_axis_aclk);
        if(s00_axis_tready) begin
        	s00_axis_tdata  <= data;
			s00_axis_tvalid <= 1;
        end
        @(posedge s00_axis_aclk);
        s00_axis_tvalid <= 0;    
    endtask

    task axis_master();
        m00_axis_tready <= 1;
    endtask

    task load_inputs(input integer n);// n = number of inputs
        inputs_cnt = 0;
        while(inputs_cnt!=n) begin//inputs
            @(posedge tm_if.s00_axi_aclk);
            if(tm_if.s00_axis_tready) begin
                if(first_layer) begin
                	a = inputs[inputs_ptr];
                	b = inputs[inputs_ptr];
                	c = {b,a};
                	tm_if.axis_slave(c);
                	inputs_cnt += 1;
                    inputs_ptr += 1;
                end
                else begin
                    a = next_layer_inputs[inputs_ptr];
                	b = next_layer_inputs[inputs_ptr];
                	c = {b,a};
                	tm_if.axis_slave(c);
                	inputs_cnt += 1;
                    inputs_ptr += 1;
                end
           	end  
        end     
    endtask

    task reset_inputs_ptr(input int value);
        inputs_ptr <= value;
    endtask

    task load_biases(input integer n);
        biases_cnt=0;
        while(biases_cnt!=n) begin//biases
            @(posedge tm_if.s00_axi_aclk);
            if(tm_if.s00_axis_tready) begin
                a = biases[biases_ptr];
                b = biases[biases_ptr+1];
                c = {b,a};
                axis_slave(c);
                biases_cnt += 2;
                biases_ptr += 2;
            end
        end
    endtask

    task reset_biases_ptr();
        biases_ptr <= 0;
    endtask

    task load_weights(input integer n);
        weights_cnt = 0;
        while(weights_cnt!=n) begin//inputs
            @(posedge tm_if.s00_axi_aclk);
            if(tm_if.s00_axis_tready) begin
            	a = weights[weights_ptr];
            	b = weights[weights_ptr+1];
            	c = {b,a};
            	tm_if.axis_slave(c);
            	weights_cnt += 2;
                weights_ptr += 2;
           	end  
        end     
    endtask

    task reset_weights_ptr();
        weights_ptr <= 0;
    endtask

    task reset_ptrs(input int inputs_ptr_val);
        reset_inputs_ptr(inputs_ptr_val);
        reset_biases_ptr();
        reset_weights_ptr();
    endtask

    task nn_start_layer(input integer prev_layer, curr_lay,num_used_neurons);

        load_inputs(prev_layer);

        repeat(curr_lay/num_used_neurons) begin
            load_biases(num_used_neurons);
            load_weights(prev_layer*num_used_neurons);
        end
    endtask

    task read_output_reg(input integer num_curr_layer);
        next_layer_inputs = new[num_curr_layer];
        cnt_output_reg = 0;
        @(posedge tm_if.s00_axi_aclk);
        m00_axis_tready <= 1;
        while(cnt_output_reg!=num_curr_layer) begin
            @(posedge tm_if.s00_axi_aclk);
            if(m00_axis_tvalid) begin
                next_layer_inputs[cnt_output_reg] = m00_axis_tdata;
                cnt_output_reg++;
            end
        end
        m00_axis_tready <= 0;
        first_layer     <= 0;
	endtask

    task test_outputs();//File should be opened and closed separately
        int status;
        real number;
        logic[15:0] error_tolerance;
        real error_tolerance_f;
        int i;

        correct_output    = 0;
        error_tolerance   = 16'b0000001100000000; //1.4.11 = 0.375
        error_tolerance_f = bin2real(error_tolerance);
        
        for(i=0;i<$size(next_layer_inputs);i++) begin
            status = $fscanf(fd_output_test,"%f\n",output_test);
            if(status != 1) $error;//you did not read one value

            number = bin2real(next_layer_inputs[i]);
            if((number >= (next_layer_inputs[i]-error_tolerance_f))&&(number <= (next_layer_inputs[i]+error_tolerance_f))) begin
                correct_output ++;
                $display("Output vrednosti su se poklopile za neuron %d \n",i);
            end
            else begin
                $warning("Vrednosti za neuron %d se nisu poklopile. \n",i);
                $warning("Ocekivana vrednost je %f a dobijena je %f \n",output_test,number);
            end
        end
    endtask

	task nn_start_picture(input int inp,hid1,hid2,out,inp_ptr_val);
		nn_layers_nodes_num(inp,hid1,hid2,out,0,0);
		nn_en(1);                             
		nn_dat_rdy(1);                        
		init();
		
		axil_slave();
		
		inp_ptr_val_temp = inp_ptr_val;  
		
		reset_ptrs(inp_ptr_val_temp);            
		nn_start_layer(inp,hid1,2);
		read_output_reg(hid1);  
		
	 	
        /*~~~~~testing outputs~~~~~*/
        //test_outputs();
        inp_ptr_val_temp = 0;					 
		reset_inputs_ptr(inp_ptr_val_temp);      
		nn_start_layer(hid1,hid2,2);
		read_output_reg(hid2);     
			
		 
        /*~~~~~testing outputs~~~~~*/
        //test_outputs();
        
    	inp_ptr_val_temp = 0;				 
		reset_inputs_ptr(inp_ptr_val_temp);      
		nn_start_layer(hid2,out,2);
								 
		read_output_reg(out);  
		
        /*~~~~~testing outputs~~~~~*/
        //test_outputs();

		nn_en(0);        
		nn_dat_rdy(0);   
		
		axil_slave();                            
	endtask

	task nn_start_pictures(input int inp,hid1,hid2,out,real pic_num, output real correct_answer);
		int pic_cnt;
		int inputs_ptr_val;
		int fd_labels,label;
		int detected_num;
		logic[15:0] percent;
		real correct;
		int status;
		
		inputs_ptr_val 	= 0;
		pic_cnt 		= 0;
		correct 		= 0;
	
		fd_labels       = $fopen("../tb/labels.txt","r");
        fd_output_test  = $fopen("../tb/output_test.txt","r");
        
        if(fd_output_test==0)
        	$error();

		for(pic_cnt=0;pic_cnt<pic_num;pic_cnt++) begin

			status = $fscanf(fd_labels,"%d",label);
			if(status != 1) $error;//you did not read one value
					
			inputs_ptr_val = 784 * pic_cnt;
			nn_start_picture(inp,hid1,hid2,out,inputs_ptr_val);

			detected_num = 0;
			percent		 = 0;

			for(int y=0;y<10;y++) begin
				if(next_layer_inputs[y] > percent) begin
					percent 	= next_layer_inputs[y];
					detected_num= y;
				end
			end

			if(detected_num == label)begin
				//$display("GOOD! \n");
				correct++;
			end
			//else
				//$display("BAD! \n");
            

            if(pic_cnt==1)
                $fclose(fd_output_test); 
		end

		correct_answer = real'((correct/pic_num)*100.0);

		$fclose(fd_labels);
	endtask

    function real bin2real(input logic[15:0] x);
		logic sign;
		
		if (x[15]==1'b0)
			sign = 1'b0;
		else
			sign = 1'b1;
			
		if(!sign)
		bin2real = 1.0*x[11]+2.0*x[12]+4.0*x[13]+8.0*x[14]+0.5*x[10]+0.25*x[9]+0.125*x[8]+0.0625*x[7]+0.03125*x[6]+0.015625*x[5]+0.0078125*x[4]+0.00390625*x[3]+0.001953125*x[2]+0.0009765625*x[1]+0.00048828125*x[0];
		else
		bin2real = -(1.0*x[11]+2.0*x[12]+4.0*x[13]+8.0*x[14]+0.5*x[10]+0.25*x[9]+0.125*x[8]+0.0625*x[7]+0.03125*x[6]+0.015625*x[5]+0.0078125*x[4]+0.00390625*x[3]+0.001953125*x[2]+0.0009765625*x[1]+0.00048828125*x[0]);
	endfunction

endinterface
