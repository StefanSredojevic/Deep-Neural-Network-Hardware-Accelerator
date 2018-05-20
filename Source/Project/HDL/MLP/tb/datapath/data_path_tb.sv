`timescale 1ns/1ps
`include "../tb/data_path_tb_class.sv"

module data_path_tb ();

	// instantiate interface
	data_path_interface dp_if();
	
	// instantiate dut and connecting it with interface
	data_path data_path_dut(
		.pi_clk					(dp_if.pi_clk),				
		.pi_rst					(dp_if.pi_rst),	
		.pi_valid				(dp_if.pi_valid),			
		.pi_clc_accumulator		(dp_if.pi_clc_accumulator),	
		.pi_accumulation_done	(dp_if.pi_accumulation_done),
		.pi_ena_inp				(dp_if.pi_ena_inp),			
		.pi_enb_inp				(dp_if.pi_enb_inp),			
		.pi_wea_inp				(dp_if.pi_wea_inp),			
		.pi_web_inp				(dp_if.pi_web_inp),			
		.pi_addra_inp			(dp_if.pi_addra_inp),		
		.pi_addrb_inp			(dp_if.pi_addrb_inp),		
		.pi_dia_inp				(dp_if.pi_dia_inp),			
		.pi_dib_inp				(dp_if.pi_dib_inp),			
		.pi_ena_wei				(dp_if.pi_ena_wei),			
		.pi_enb_wei				(dp_if.pi_enb_wei),			
		.pi_wea_wei				(dp_if.pi_wea_wei),			
		.pi_web_wei				(dp_if.pi_web_wei),			
		.pi_addra_wei			(dp_if.pi_addra_wei),		
		.pi_addrb_wei			(dp_if.pi_addrb_wei),		
		.pi_dia_wei				(dp_if.pi_dia_wei),			
		.pi_dib_wei				(dp_if.pi_dib_wei),			
		.pi_ena_reg				(dp_if.pi_ena_reg),			
		.pi_enb_reg				(dp_if.pi_enb_reg),			
		.pi_wea_reg				(dp_if.pi_wea_reg),			
		.pi_web_reg				(dp_if.pi_web_reg),			
		.pi_addra_reg			(dp_if.pi_addra_reg),		
		.pi_addrb_reg			(dp_if.pi_addrb_reg),					
		.po_doa					(dp_if.po_doa),
		.po_dob					(dp_if.po_dob)
	);
	
    //Creating verification scenario
	initial begin
		dp_if.init();
		dp_if.set_number_of_used_neurons(2);
		dp_if.set_nodes_num(4,4,2,2);
		dp_if.set_inputs_rnd();
		dp_if.set_weights_rnd();
		dp_if.write_inputs_BRAM();
		dp_if.write_weights_BRAM();
		dp_if.start_nn();
	end
	
    //Deciding when to finish simulation
	initial
		#10000 $finish();
	
    //Clock stimulus
	always begin
		#20 dp_if.pi_clk <= ~dp_if.pi_clk;	
	end
	
endmodule : data_path_tb
