`timescale 1ns / 1ps

module led_frequency_tester #(parameter logic[31:0] VALUE = 25000000)
    (input pi_clk,
     input pi_rstn,
     output po_output);
    
    localparam LOCAL_VAL = VALUE - 1;
    reg [31:0] counter;
    reg peak;
    
    always @(posedge pi_clk) begin
        if(!pi_rstn) begin
            counter <= LOCAL_VAL;
            peak    <= 1'b0;
        end
        else begin
            if(counter == 0) begin
                counter <= LOCAL_VAL;
                peak    <= ~peak;
            end
            else begin
                counter <= counter - 1;
                peak    <= peak;
            end
        end 
    end
    
    assign po_output = peak;
    
endmodule
