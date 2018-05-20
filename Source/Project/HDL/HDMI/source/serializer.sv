/**********************************************************/
/**********************************************************/
//File                  :Serializer 
//Project               :SmarTech
//Creation              :11.03.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module serializer (pi_clk,pi_rst,pi_red,pi_blue,pi_green,po_TMDSp,po_TMDSn,r_test,g_test,b_test);
/**************PORT DEFINITION*****************************/               
    input wire pi_clk;                                                     
    input wire pi_rst;
    input wire [9:0] pi_red;
    input wire [9:0] pi_blue;
    input wire [9:0] pi_green;

    output [2:0] po_TMDSp;
    output [2:0] po_TMDSn;
    
    //Test signals
    output wire r_test;
    output wire g_test;
    output wire b_test;
/***************DEFINITION OF INTERNALS******************/
    (* dont_touch = "true" *) reg [3:0] counter_mod10;
    reg [9:0] TMDS_shift_red;
    reg [9:0] TMDS_shift_green;
    reg [9:0] TMDS_shift_blue;
    reg TMDS_shift_load;
/****************GENERATE LOAD DATA SIGNAL***************/
    always_ff @(posedge pi_clk) begin
        if(!pi_rst) begin
            TMDS_shift_load <= 1'b0;
        end
        else begin
            if(counter_mod10 == 4'd9) begin
                TMDS_shift_load <= 1'b1;
            end
            else begin 
                TMDS_shift_load <= 1'b0;
            end
        end
    end
/**********LOAD DATA AND SHIFT DATA OUT****************/
    always_ff @(posedge pi_clk) begin
        if(!pi_rst) begin
            counter_mod10 <= 4'd0;
            TMDS_shift_blue <= 10'd0;
            TMDS_shift_green <= 10'd0;
            TMDS_shift_red <= 10'd0;
        end
        else begin
            if(TMDS_shift_load) begin
                TMDS_shift_blue <= pi_blue;
                TMDS_shift_green <= pi_green;
                TMDS_shift_red <= pi_red;
                counter_mod10 <= 4'd0;
            end
            else begin
                TMDS_shift_blue <= {1'b0,TMDS_shift_blue[9:1]};
                TMDS_shift_green <= {1'b0,TMDS_shift_green[9:1]};
                TMDS_shift_red <= {1'b0,TMDS_shift_red[9:1]};
                counter_mod10 <= counter_mod10 + 4'd1;
            end
        end
    end
/***************BUFFER WITH DIFFERENCIAL OUTS***********/
    OBUFDS OBUFDS_red(  .I(TMDS_shift_red[0]),   
                        .O(po_TMDSp[2]),
                        .OB(po_TMDSn[2]));
    OBUFDS OBUFDS_green(    .I(TMDS_shift_green[0]),   
                            .O(po_TMDSp[1]),
                            .OB(po_TMDSn[1]));
    OBUFDS OBUFDS_blue( .I(TMDS_shift_blue[0]),   
                        .O(po_TMDSp[0]),
                        .OB(po_TMDSn[0]));
                        
    assign r_test = TMDS_shift_red[0];
    assign g_test = TMDS_shift_green[0];
    assign b_test = TMDS_shift_blue[0];
    
endmodule
