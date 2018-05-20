/**********************************************************/
/**********************************************************/
//File                  :TMDS INTERFACE 
//Project               :SmarTech
//Creation              :13.03.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
interface TMDS_encoder_interface #();
/******************INPUT PORTS*****************************/
    logic pi_clk;
    logic pi_rst;
    logic pi_display_en;
    logic [1:0] pi_control;
    logic [7:0] pi_data;
/******************OUTPUT PORTS****************************/ 
    logic [9:0] po_data;
/******************TASKS***********************************/ 
    //Init interface with reset sequence for module
    task init();
        fork
            pi_clk <= 1'b0;
            pi_rst <= 1'b1;
            pi_display_en <= 1'b0;
            pi_control <= 2'b00;
            pi_data <= 7'd0;
            #50 pi_rst <= 1'b0;
            #150 pi_rst <= 1'b1;
            $display("Init over!");
        join
    endtask:init
    //Set display enable
    task disp_enable();
        pi_display_en <= 1'b1;
    endtask:disp_enable
    //Deactivate display enable
    task disp_disable();
        pi_display_en <= 1'b0;
    endtask:disp_disable
    //Set control bits to "command" value
    task set_control(input logic [1:0] command);
        pi_control <= command;
    endtask:set_control
    //Send data to be encoded and read ecoded data
    task encode_data(input logic [7:0]data, output logic [9:0]en_data);
        fork
            pi_data <= data;
            @(posedge pi_clk);
            en_data <= po_data;
        join
    endtask:encode_data
endinterface
