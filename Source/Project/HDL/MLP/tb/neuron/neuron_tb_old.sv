/*
    This TB is useless, because neuron structure is changed
*/

`timescale 1ns/1ps
`include "../tb/neuron_tb_class.sv"

module neuron_tb
		
	// instantiate interface
    neuron_interface  neuron_if();
	
	// instantiate dut and connecting it with interface
	neuron #(w_num) neuron_dut (
		neuron_if.pi_clk,
		neuron_if.pi_rst,
		neuron_if.pi_valid,
		neuron_if.pi_clc_accumulator,
		neuron_if.pi_bias,
		neuron_if.pi_weights,
		neuron_if.pi_inputs,
		neuron_if.pi_accumulation_done,
		neuron_if.po_BRAM_en,
		neuron_if.po_BRAM_add,
		neuron_if.po_multiply_test,
		neuron_if.po_accumulation_test,
	);
	
	//Signals
	//Including [783:0]rnd_inputs and [783:0]rnd_weights
	`include "../tb/rnd_weights_inputs_bin.sv";
	real multiply2real;
	real accumulator2real;
	
	// Initialization
	initial
		neuron_if.init();
	
	// Clock
	always
		#50 neuron_if.pi_clk <= ~neuron_if.pi_clk;
	
	//Connecting inputs and weights to neuron
	//This logic is used to connect data in reverse order (casting from unpacked array to packed)
	always_comb begin
		for(int i=0;i<784;i++)
			neuron_if.pi_inputs[i]  <= rnd_inputs[783-i];
	end
	
	always_comb begin
		for(int i=0;i<784;i++)
			neuron_if.pi_weights[i]  <= rnd_weights[783-i];
	end
	
	//Run neuron calculation in hardware
	always @(posedge neuron_if.pi_clk) begin
		neuron_if.calc_neuron_hw();
		neuron_if.pi_valid <= 1'b1;
	end
	
	//always @(posedge neuron_if.pi_clk)
	initial begin
		@ (posedge neuron_if.pi_clk);
		@ (posedge neuron_if.pi_clk);
		neuron_if.calc_neuron_sw();
	end
	
	//Run test
	initial
		accumulator2real <= 0;
	
	always @(posedge neuron_if.pi_clk) begin
		multiply2real	 = neuron_if.bin2real(neuron_if.po_multiply_test);
		accumulator2real = neuron_if.bin2real(neuron_if.po_accumulation_test);
	end
	
endmodule : neuron_tb

