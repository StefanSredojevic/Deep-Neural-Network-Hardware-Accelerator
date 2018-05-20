
/*
    This TB is useless, because neuron structure is changed
*/

`timescale 1ns/1ps
`include "../tb/neuron_tb_class.sv"

module neuron_tb ();
		
	// instantiate interface
    neuron_interface  neuron_if();
	
	// instantiate dut and connecting it with interface
	neuron neuron_dut (
		.pi_clk					(neuron_if.pi_clk),
		.pi_rst					(neuron_if.pi_rst),
		.pi_valid				(neuron_if.pi_valid),
		.pi_clc_accumulator		(neuron_if.pi_clc_accumulator),
		.pi_bias				(neuron_if.pi_bias),
		.pi_weights				(neuron_if.pi_weights),
		.pi_inputs				(neuron_if.pi_inputs),
		.pi_accumulation_done	(neuron_if.pi_accumulation_done),
		.po_multiply_test		(neuron_if.po_multiply_test),
		.po_accumulation_test 	(neuron_if.po_accumulation_test),
		.po_BRAM_add			(neuron_if.po_BRAM_add),
		.po_BRAM_en				(neuron_if.po_BRAM_en)
	);
	
	event e1;
	
	// Initialization
	initial 
		neuron_if.init();
		
	initial
		neuron_if.late_signals();
	
	// Clock
	always
		#50 neuron_if.pi_clk <= ~neuron_if.pi_clk;
	
	
	//Run neuron calculation in hardware
	initial begin
		neuron_if.open_files();
		neuron_if.calc_neuron();
		-> e1;
	end
	
	initial begin
		@(e1);
		neuron_if.close_files();
	end
	
endmodule : neuron_tb

