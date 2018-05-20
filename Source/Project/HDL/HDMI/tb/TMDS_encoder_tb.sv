/**********************************************************/
/**********************************************************/
//File                  :TMDS ENCODER TB
//Project               :SmarTech
//Creation              :13.03.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module TMDS_encoder_tb;
    localparam CLOCK_INTERVAL = 40;
    localparam NUM_OF_DATA = 50;

    logic [7:0] data_for_encoding;
    logic [9:0] dut_encoded_data;
    logic [9:0] ref_encoded_data;

    TMDS_encoder_interface dut_in();
    TMDS_encoder_interface ref_in();

    TMDS_enc dut(   .pi_clk(dut_in.pi_clk),
                    .pi_rst(dut_in.pi_rst),
                    .pi_display_en(dut_in.pi_display_en),
                    .pi_control(dut_in.pi_control),
                    .pi_data(dut_in.pi_data),
                    .po_data(dut_in.po_data));
    tmds_encoder reff(  .clk(ref_in.pi_clk),
                        .reset(ref_in.pi_rst),
                        .disp_en(ref_in.pi_display_en),
                        .ctrl(ref_in.pi_control),
                        .data(ref_in.pi_data),
                        .tmds(ref_in.po_data));
    always begin
        #CLOCK_INTERVAL dut_in.pi_clk <= ~dut_in.pi_clk;
        ref_in.pi_clk <= ~ref_in.pi_clk;
    end

    initial begin
        fork
            dut_in.init();
            ref_in.init();
        join
    end

    always begin
        for (int i = 0; i < NUM_OF_DATA; i = i + 1) begin
            data_for_encoding = $random;
            if(($random) % 2) begin
                fork
                    dut_in.disp_enable();
                    ref_in.disp_enable();
                join
            end
            else begin
                fork
                    dut_in.disp_disable();
                    ref_in.disp_disable();
                join
            end
            #($urandom_range(0,1000));
            fork
            dut_in.encode_data(data_for_encoding, dut_encoded_data);
            ref_in.encode_data(data_for_encoding, ref_encoded_data);
            join
        end
        $finish;
    end

endmodule
