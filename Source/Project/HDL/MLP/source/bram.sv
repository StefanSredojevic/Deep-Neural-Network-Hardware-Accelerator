//Dual-Port Block RAM with Two Write Ports

module bram #(parameter integer WADDR = 11, parameter integer WDATA = 16)
    (pi_clka,pi_clkb,pi_ena,pi_enb,pi_wea,pi_web,pi_addra,pi_addrb,pi_dia,pi_dib,po_doa,po_dob);
    input        pi_clka,pi_clkb,pi_ena,pi_enb,pi_wea,pi_web;
    input [WADDR-1:0] pi_addra,pi_addrb;
    input [WDATA-1:0] pi_dia,pi_dib;
    output[WDATA-1:0] po_doa,po_dob;

localparam RAM_DEPTH = 2**WADDR;
        
reg[WDATA-1:0] ram [0:RAM_DEPTH-1];
reg[WDATA-1:0] po_doa,po_dob;

//Dual-Port logic port A
always @(posedge pi_clka) begin 
	if (pi_ena) begin
     	if (pi_wea) begin
        	ram[pi_addra] 	<= pi_dia;
                //This is under comment because output is set to 'X' if this is uncommented
                //Network still works okay, but uncomment only if needed
        	//po_doa 			<= ram[pi_addra];
     	end
     	else
        	 po_doa 		<= ram[pi_addra];
	end
end

//Dual-Port logic port B
always @(posedge pi_clkb) begin 
	if (pi_enb) begin
     	if (pi_web) begin
        	ram[pi_addrb] 	<= pi_dib;
                //This is under comment because output is set to 'X' if this is uncommented
                //Network still works okay, but uncomment only if needed
        	//po_dob 			<= ram[pi_addrb];
     	end
     	else
     		po_dob 			<= ram[pi_addrb];
	end
end

endmodule : bram
