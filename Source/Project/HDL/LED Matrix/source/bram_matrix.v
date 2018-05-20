module bram_led #(parameter integer WADDR = 4, parameter integer WDATA = 64)
    (pi_clk,pi_en,pi_addr,po_data);
    input        pi_clk, pi_en;
    input [WADDR-1:0] pi_addr;
    output[WDATA-1:0] po_data;
        
logic[WDATA-1:0] data;

always @(posedge pi_clk) begin 
	if (pi_en) begin
	   case(pi_addr)
            4'h0:  data <= 64'h007e8181817e0000;
            4'h1:  data <= 64'h000082ff80000000;
            4'h2:  data <= 64'h0082c1a1918e0000;
            4'h3:  data <= 64'h0042818989760000;
            4'h4:  data <= 64'h0030282422ff2000;
            4'h5:  data <= 64'h004f898989710000;
            4'h6:  data <= 64'h007e898989720000;
            4'h7:  data <= 64'h0001e11109070000;
            4'h8:  data <= 64'h0076898989760000;
            4'h9:  data <= 64'h004e9191917e0000;
            default:data<= 64'h8142241818244281;
        endcase
     end
     else           data <= 64'h8142241818244281;
	
end

    assign po_data = data;

endmodule : bram_led