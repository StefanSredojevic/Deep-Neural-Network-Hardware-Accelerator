`timescale 1ns / 1ps

module inverter # (parameter integer DELAYED_SIGNAL = 1)
    (
        input clk,
        input i,
        output o
     );

    generate
        if(DELAYED_SIGNAL == 1) begin
           
           reg in_temp;
        
            always @(posedge clk)
                in_temp <= ~i;
                
            assign o = in_temp;
        end
    endgenerate
    
    generate
        if(DELAYED_SIGNAL == 0)
            assign o = ~i;
    endgenerate

endmodule
