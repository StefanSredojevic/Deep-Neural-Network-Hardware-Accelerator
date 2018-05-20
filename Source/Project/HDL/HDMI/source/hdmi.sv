/**********************************************************/
/**********************************************************/
//File                  :HDMI_TOP
//Project               :SmarTech
//Creation              :11.03.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module HDMI #(parameter VPIX = 480, parameter HPIX = 640, parameter MVPIX = 524, parameter MHPIX = 800)
            (pi_clk,pi_s_clk,pi_rst,pi_red,pi_blue,pi_green,po_TMDSp,po_TMDSn,po_TMDSp_clk,po_TMDSn_clk, po_stream_ready,
            r_test,g_test,b_test,counterX_test,counterY_test);
/**********LOCAL PARAMETERS********************************/
    localparam COUNTER_Y_BITS = $clog2(MVPIX);
    localparam COUNTER_X_BITS = $clog2(MHPIX);
/**************PORT DEFINITION*****************************/
    input wire pi_clk;
    input wire pi_s_clk;
    input wire pi_rst;
    input wire [7:0] pi_red;
    input wire [7:0] pi_blue;
    input wire [7:0] pi_green;

    output [2:0] po_TMDSp;
    output [2:0] po_TMDSn;
    output po_TMDSp_clk;
    output po_TMDSn_clk;
    output po_stream_ready;
    
    //Test signals
    output wire r_test;
    output wire g_test;
    output wire b_test;
    output wire [COUNTER_X_BITS-1:0] counterX_test;
    output wire [COUNTER_Y_BITS-1:0] counterY_test;
/***************DEFINITION OF INTERNALS******************/
    reg [COUNTER_Y_BITS-1:0] counterY;
    reg [COUNTER_X_BITS-1:0] counterX;
    wire [9:0] TMDS_red;
    wire [9:0] TMDS_blue;
    wire [9:0] TMDS_green;
    wire hSync;
    wire vSync;
    wire drawArea;
/***************PIXEL POSITION COUNTER*******************/
    always_ff @(posedge pi_clk) begin
        if(!pi_rst) begin
            counterX <= {COUNTER_X_BITS{1'b0}};
            counterY <= {COUNTER_Y_BITS{1'b0}}; 
        end
        else begin
            if(counterX == MHPIX-1) begin
                counterX <= {COUNTER_X_BITS{1'b0}};
                if(counterY == MVPIX-1) begin
                    counterY <= {COUNTER_Y_BITS{1'b0}};
                end
                else begin
                    counterY <= counterY + 1;
                end
            end
            else begin
                counterX <= counterX + 1;
            end
        end
    end
    
    //TEST SIGNALS
    assign counterX_test = counterX;
    assign counterY_test = counterY;
    
/***************SYNC SIGNALS GENERATOR*******************/
    assign hSync = (counterX >= 656) && (counterX < 752);
    assign vSync = (counterY >= 490) && (counterY < 492);
    assign drawArea = (counterX < 640) && (counterY < 480);
    assign po_stream_ready = drawArea;
/*******INSTANCING TMDS ENCODER FOR EACH COLOR***********/
    TMDS_enc encode_R(  .pi_clk(pi_clk),
                        .pi_rst(pi_rst),
                        .pi_display_en(drawArea),
                        .pi_control(2'b00),
                        .pi_data(pi_red),
                        .po_data(TMDS_red));
    TMDS_enc encode_G(  .pi_clk(pi_clk),
                        .pi_rst(pi_rst),
                        .pi_display_en(drawArea),
                        .pi_control(2'b00),
                        .pi_data(pi_green),
                        .po_data(TMDS_green));
    TMDS_enc encode_B(  .pi_clk(pi_clk),
                        .pi_rst(pi_rst),
                        .pi_display_en(drawArea),
                        .pi_control({vSync,hSync}),
                        .pi_data(pi_blue),
                        .po_data(TMDS_blue));
/***************INSTANCING SERIALIZER********************/
    serializer serializer_A(    .pi_clk(pi_s_clk),
                                .pi_rst(pi_rst),
                                .pi_red(TMDS_red),
                                .pi_blue(TMDS_blue),
                                .pi_green(TMDS_green),
                                .po_TMDSp(po_TMDSp),
                                .po_TMDSn(po_TMDSn),
                                .r_test(r_test),
                                .g_test(g_test),
                                .b_test(b_test));
/***************DIFFERENCIAL BUFFER FOR TMDS CLOCK*******/
   OBUFDS OBUFDS_clock(    .I(pi_clk),
                            .O(po_TMDSp_clk),
                            .OB(po_TMDSn_clk));
    
endmodule
