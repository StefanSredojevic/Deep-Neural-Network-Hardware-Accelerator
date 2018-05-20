/**********************************************************/
/**********************************************************/
//File                  :UART MODULE DATA CHECKER
//Project               :SmarTech
//Creation              :12.02.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module data_checker(pi_start_checking);
/**********************CHECKER INTERFACE*******************/
input pi_start_checking;
/**********************************************************/
/**********************PARAMETERS**************************/
import parameters::*;
integer data_file_from_dut1;
integer data_file_from_dut2;
integer data_file_to_dut1;
integer data_file_to_dut2;
integer scan_file_from_dut1;
integer scan_file_from_dut2;
integer scan_file_to_dut1;
integer scan_file_to_dut2;
logic [DATA_WIDTH-1:0] captured_data_from_dut1;
logic [DATA_WIDTH-1:0] captured_data_from_dut2;
logic [DATA_WIDTH-1:0] captured_data_to_dut1;
logic [DATA_WIDTH-1:0] captured_data_to_dut2;
integer dut1_to_dut2;
integer dut2_to_dut1;
integer dut1_to_dut2_finished;
integer dut2_to_dut1_finished;
integer finish;
/*************************************************************/
/**********INITIALIZATION AND OPENINING FILES*****************/
initial begin
	data_file_from_dut1 = 0;
	data_file_from_dut2 = 0;
	data_file_to_dut1 = 0;
	data_file_to_dut2 = 0;
	dut1_to_dut2 = 0;
	dut2_to_dut1 = 0;
	scan_file_from_dut1 = 0;
	scan_file_from_dut2 = 0;
	scan_file_to_dut1 = 0;
	scan_file_to_dut2 = 0;
	dut2_to_dut1_finished = 0;
	dut1_to_dut2_finished = 0;
	captured_data_from_dut1 = {DATA_WIDTH{1'b0}};
	captured_data_from_dut2 = {DATA_WIDTH{1'b0}};
	captured_data_to_dut1 = {DATA_WIDTH{1'b0}};
	captured_data_to_dut2 = {DATA_WIDTH{1'b0}};
	data_file_from_dut1 = $fopen("From_dut1.txt","r");
	if(data_file_from_dut1 == 0) begin
		$display("Can not find From_dut1.txt");
		$finish;
	end
	data_file_from_dut2 = $fopen("From_dut2.txt","r");
	if(data_file_from_dut2 == 0) begin
		$display("Can not find From_dut2.txt");
		$finish;
	end
	data_file_to_dut1 = $fopen("To_dut1.txt","r");
	if(data_file_to_dut1 == 0) begin
		$display("Can not find To_dut1.txt");
		$finish;
	end
	data_file_to_dut2= $fopen("To_dut2.txt","r");
	if(data_file_to_dut2 == 0) begin
		$display("Can not find To_dut2.txt");
		$finish;
	end
	dut1_to_dut2 = $fopen("dut1_to_dut2.txt","w");
	dut2_to_dut1 = $fopen("dut2_to_dut1.txt","w");
 end
/***************************************************************/
/****************COMPARE FIRST DIRECTION DATA*******************/
 always @(posedge pi_start_checking) begin
	do begin
		scan_file_from_dut1 = $fscanf(data_file_from_dut1,"%b\n",captured_data_from_dut1);
		scan_file_to_dut2 = $fscanf(data_file_to_dut2,"%b\n",captured_data_to_dut2);
		if(captured_data_from_dut1 == captured_data_to_dut2) begin
			$fwrite(dut1_to_dut2,"%b",captured_data_from_dut1);
			$fwrite(dut1_to_dut2,"%s","==");
			$fwrite(dut1_to_dut2,"%b",captured_data_to_dut2);
			$fwrite(dut1_to_dut2,"%s","\t\t[MATCHED]\n");
		end
		else begin
			$fwrite(dut1_to_dut2,"%b",captured_data_from_dut1);
			$fwrite(dut1_to_dut2,"%s","!=");
			$fwrite(dut1_to_dut2,"%b",captured_data_to_dut2);
			$fwrite(dut1_to_dut2,"%s","\t\t[MISMATCHED]\n");
		end
	end while(!$feof(data_file_from_dut1));
	$fclose(data_file_from_dut1);
	$fclose(data_file_to_dut2);
	$fclose(dut1_to_dut2);
	dut1_to_dut2_finished = 1'b1;
	wait(0);
 end
/*****************************************************************/
/****************COMPARE SECOND DIRECTION DATA********************/
 always @(posedge pi_start_checking) begin
	do begin
		scan_file_from_dut2 = $fscanf(data_file_from_dut2,"%b\n",captured_data_from_dut2);
		scan_file_to_dut1 = $fscanf(data_file_to_dut1,"%b\n",captured_data_to_dut1);
		if(captured_data_from_dut2 == captured_data_to_dut1) begin
			$fwrite(dut2_to_dut1,"%b",captured_data_from_dut2);
			$fwrite(dut2_to_dut1,"%s","==");
			$fwrite(dut2_to_dut1,"%b",captured_data_to_dut1);
			$fwrite(dut2_to_dut1,"%s","\t\t[MATCHED]\n");
		end
		else begin
			$fwrite(dut2_to_dut1,"%b",captured_data_from_dut2);
			$fwrite(dut2_to_dut1,"%s","!=");
			$fwrite(dut2_to_dut1,"%b",captured_data_to_dut1);
			$fwrite(dut2_to_dut1,"%s","\t\t[MISMATCHED]\n");
		end
	end while(!$feof(data_file_from_dut2));
	$fclose(data_file_from_dut2);
	$fclose(data_file_to_dut1);
	$fclose(dut2_to_dut1);
	dut2_to_dut1_finished = 1'b1;
	wait(0);
 end
/*******************************************************************/
/******WAIT FOR BOTH PROCESS TO BE DONE AND BREAK SIMULATION********/
 assign finish = dut1_to_dut2_finished && dut2_to_dut1_finished ? 1 : 0;
 always @(posedge finish) begin
	$finish;
end
/*******************************************************************/
endmodule
