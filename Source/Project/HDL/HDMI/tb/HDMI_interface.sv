/**********************************************************/
/**********************************************************/
//File                  :HDMI_INTERFACE
//Project               :SmarTech
//Creation              :13.03.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
interface HDMI_interface #();
/******************INPUT PORTS*****************************/
    logic pi_clk;
    logic pi_s_clk;
    logic pi_rst;
    logic [7:0] pi_red;
    logic [7:0] pi_blue;
    logic [7:0] pi_green;
/******************OUTPUT PORTS****************************/
    logic [2:0] po_TMDSp;
    logic [2:0] po_TMDSn;
    logic po_TMDSp_clk;
    logic po_TMDSn_clk;
/******************TASKS***********************************/ 
    //Init interface with reset sequence for module
    task init();
        fork
            pi_clk <= 1'b0;
            pi_s_clk <= 1'b0;
            pi_rst <= 1'b1;
            pi_red <= 7'd0;
            pi_blue <= 7'd0;
            pi_green <= 7'd0;
            #800 pi_rst <= 1'b0;
            #1600 pi_rst <= 1'b1;
        join
    endtask:init
    //Set pixel bits for red color
    task set_red(input logic [7:0]red_bits);
        pi_red <= red_bits;
    endtask:set_red
    //Set pixel bits for blue color
    task set_blue(input logic [7:0]blue_bits);
        pi_blue <= blue_bits;
    endtask:set_blue
    //Set pixel bits for green color
    task set_green(input logic [7:0]green_bits);
        pi_green <= green_bits;
    endtask:set_green

endinterface
