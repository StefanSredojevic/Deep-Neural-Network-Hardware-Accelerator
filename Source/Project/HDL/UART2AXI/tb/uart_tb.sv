/**********************************************************/
/**********************************************************/
//File                  :UART MODULE
//Project               :SmarTech
//Creation              :11.02.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module uart_tb;
/**********************PAMAMETERS**************************/
parameter DATA_WIDTH = 8;
parameter IN_CLK = 10000000;
parameter BAUD_RATE = 115200;
parameter CLK_FREQ = 1000000000/IN_CLK; // (1/(CLK_FREQ*1n))
parameter RST_DURATION = 2000;
parameter NUM_OF_SAMPLES = 20;
/**********************************************************/
/*****************REGISTERS AND WIRES**********************/
logic ri_clk;
logic ri_rst;
logic ri_stop_bits;
logic [DATA_WIDTH-1:0] ri_t_data_dut1;
logic [DATA_WIDTH-1:0] ri_t_data_dut2;
logic ri_start_tran_dut1;
logic ri_start_tran_dut2;
wire w_ur_data;
wire [DATA_WIDTH-1:0] wo_r_data_dut1;
wire [DATA_WIDTH-1:0] wo_r_data_dut2;
wire wo_rec_over_dut1;
wire wo_rec_over_dut2;
wire wo_rec_error_dut1;
wire wo_rec_error_dut2;
wire w_ut_data;
wire wo_tran_over_dut1;
wire wo_tran_over_dut2;
integer sent_data_dut1;
integer sent_data_dut2;
integer received_data_dut1;
integer received_data_dut2;
integer send_dut1_finished;
integer send_dut2_finished;
integer receive_dut1_finished;
integer receive_dut2_finished;
logic stimuls_finished;
/*************************FILE VARIABLES*******************/
integer data_file_from_dut1;
integer data_file_from_dut2;
integer data_file_to_dut1;
integer data_file_to_dut2;
/**********************************************************/
/************INSTANCING DESIGNS UNDER TEST*****************/
uart #(
    .DATA_WIDTH(DATA_WIDTH),
    .IN_CLK(IN_CLK),
    .BAUD_RATE(BAUD_RATE))DUT1(
	.pi_clk (ri_clk),
	.pi_rst (ri_rst),
	.pi_stop_bits (ri_stop_bits), 
	.pi_t_data (ri_t_data_dut1),
	.pi_start_tran (ri_start_tran_dut1),
	.pi_ur_data (w_ur_data),
	.po_r_data (wo_r_data_dut1),
	.po_rec_over (wo_rec_over_dut1),
    .po_rec_error (wo_rec_error_dut1),
	.po_ut_data (w_ut_data),
	.po_tran_over (wo_tran_over_dut1)
);
uart #(
    .DATA_WIDTH(DATA_WIDTH),
    .IN_CLK(IN_CLK),
    .BAUD_RATE(BAUD_RATE))DUT2 (
	.pi_clk (ri_clk),
	.pi_rst (ri_rst),
	.pi_stop_bits (ri_stop_bits), 
	.pi_t_data (ri_t_data_dut2),
	.pi_start_tran (ri_start_tran_dut2),
	.pi_ur_data (w_ut_data),
	.po_r_data (wo_r_data_dut2),
	.po_rec_over (wo_rec_over_dut2),
    .po_rec_error (wo_rec_error_dut2),
	.po_ut_data (w_ur_data),
	.po_tran_over (wo_tran_over_dut2)
);
data_checker check1 (
    .pi_start_checking(stimuls_finished)
);
/**********************************************************/
/**********INITIALIZATION AND CLK GENERATOR****************/
initial begin
	ri_clk = 1'b1;
	ri_stop_bits = 1'b1;
    ri_t_data_dut1 = {DATA_WIDTH{1'b0}};
    ri_t_data_dut2 = {DATA_WIDTH{1'b0}};
    ri_start_tran_dut1 = 1'b0;
    ri_start_tran_dut2 = 1'b0;
    sent_data_dut1 = 0;
    sent_data_dut2 = 0;
    received_data_dut1 = 0;
    received_data_dut2 = 0;
    send_dut1_finished = 0;
    send_dut2_finished = 0;
    receive_dut1_finished = 0;
    receive_dut2_finished = 0;
	data_file_from_dut1 = $fopen("From_dut1.txt","w");
	data_file_from_dut2 = $fopen("From_dut2.txt","w");
	data_file_to_dut1 = $fopen("To_dut1.txt","w");
	data_file_to_dut2 = $fopen("To_dut2.txt","w");
	ri_rst = 1'b1;
    #1000 ri_rst = 1'b0;
	#RST_DURATION ri_rst = 1'b1;
end
always begin
	#CLK_FREQ ri_clk = !ri_clk;
end
/**********************************************************/
/****************DUT1 SET STIMULUS*************************/
always @(posedge ri_clk) begin
    if(ri_rst) begin
	    while(sent_data_dut1 < NUM_OF_SAMPLES) begin
            #($urandom_range(300000000,0));
		    ri_t_data_dut1 = $random;
            ri_start_tran_dut1 = 1'b1;
            wait(!wo_tran_over_dut1);
            wait(wo_tran_over_dut1);
            ri_start_tran_dut1 = 1'b0;
		    $fwrite(data_file_to_dut2,"%b\n",ri_t_data_dut1);
		    sent_data_dut1 = sent_data_dut1 + 1;
	    end
	    $fclose(data_file_to_dut2);
        send_dut1_finished = 1'b1;
	    wait(0);
    end
end
/**********************************************************/
/****************DUT1 READ STIMULUS************************/
always @(posedge wo_rec_over_dut1) begin
    if(ri_rst) begin
        if(received_data_dut1 < NUM_OF_SAMPLES) begin
            $fwrite(data_file_from_dut2,"%b\n",wo_r_data_dut1);
            received_data_dut1 = received_data_dut1 + 1;
        end
        if(received_data_dut1 == NUM_OF_SAMPLES) begin 
            $fclose(data_file_from_dut2);
            receive_dut1_finished = 1'b1;
            wait(0);
        end
    end
end
/**********************************************************/
/****************DUT2 SET STIMULUS*************************/
always @(posedge ri_clk) begin
    if(ri_rst) begin
	    while(sent_data_dut2 < NUM_OF_SAMPLES) begin
            #($urandom_range(200000000,0));
		    ri_t_data_dut2 = $random;
            ri_start_tran_dut2 = 1'b1;
            wait(!wo_tran_over_dut2);
            wait(wo_tran_over_dut2);
            ri_start_tran_dut2 = 1'b0;
		    $fwrite(data_file_to_dut1,"%b\n",ri_t_data_dut2);
		    sent_data_dut2 = sent_data_dut2 + 1;
	    end 
	    $fclose(data_file_to_dut1);
        send_dut2_finished = 1'b1;
	    wait(0);
    end
end
/**********************************************************/
/****************DUT2 READ STIMULUS************************/
always @(posedge wo_rec_over_dut2) begin
    if(ri_rst) begin
        if(received_data_dut2 < NUM_OF_SAMPLES) begin
            $fwrite(data_file_from_dut1,"%b\n",wo_r_data_dut2);
            received_data_dut2 = received_data_dut2 + 1;
        end
        if(received_data_dut2 == NUM_OF_SAMPLES) begin
            $fclose(data_file_from_dut1);
            receive_dut2_finished = 1'b1;
            wait(0);
        end
    end
end
/**********************************************************/
assign stimuls_finished = receive_dut1_finished && receive_dut2_finished && send_dut2_finished && send_dut1_finished ? 1 : 0;
endmodule
	
