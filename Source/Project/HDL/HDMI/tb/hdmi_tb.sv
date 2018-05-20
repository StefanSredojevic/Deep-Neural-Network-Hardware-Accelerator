/**********************************************************/
/**********************************************************/
//File                  :HDMI TB
//Project               :SmarTech
//Creation              :13.03.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module hdmi_tb;
    localparam CLOCK_INTERVAL = 400;
    localparam CLOCK_INTERVAL_FAST = 40;

    HDMI_interface dut_in();
    HDMI_interface ref_in();

    HDMI dut(   .pi_clk(dut_in.pi_clk),
                .pi_s_clk(dut_in.pi_s_clk),
                .pi_rst(dut_in.pi_rst),
                .pi_red(dut_in.pi_red),
                .pi_blue(dut_in.pi_blue),
                .pi_green(dut_in.pi_green),
                .po_TMDSp(dut_in.po_TMDSp),
                .po_TMDSn(dut_in.po_TMDSn),
                .po_TMDSp_clk(dut_in.po_TMDSp_clk),
                .po_TMDSn_clk(dut_in.po_TMDSn_clk));
                
    HDMI_test reff(  .pixclk(ref_in.pi_clk),
                    .pi_s_clk(ref_in.pi_s_clk),
                    .reset(ref_in.pi_rst),
                    .pi_red(ref_in.pi_red),
                    .pi_green(ref_in.pi_green),
                    .pi_blue(ref_in.pi_blue),
                    .TMDSp(ref_in.po_TMDSp),
                    .TMDSn(ref_in.po_TMDSn),
                    .TMDSp_clock(ref_in.po_TMDSp_clk),
                    .TMDSn_clock(ref_in.po_TMDSn_clk));
    initial begin
        fork
            dut_in.init();
            ref_in.init();
        join
    end

    always begin
        #CLOCK_INTERVAL  dut_in.pi_clk <= ~dut_in.pi_clk;
        ref_in.pi_clk <= ~ref_in.pi_clk;
    end

    always begin
        #CLOCK_INTERVAL_FAST  dut_in.pi_s_clk <= ~dut_in.pi_s_clk;
        ref_in.pi_s_clk <= ~ref_in.pi_s_clk;
    end
    always begin
        for(longint i = 0;i<10000000;i=i+1) begin
            #(($urandom_range(0,10000)));
            fork
                dut_in.set_red($random);
                dut_in.set_green($random);
                dut_in.set_blue($random);
                ref_in.set_red($random);
                ref_in.set_green($random);
                ref_in.set_blue($random); 
            join
        end
        $finish;
    end
endmodule
