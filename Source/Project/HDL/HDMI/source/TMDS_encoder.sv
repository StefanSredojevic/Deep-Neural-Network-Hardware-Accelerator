/**********************************************************/
/**********************************************************/
//File                  :TMDS ENCODER MODULE 
//Project               :SmarTech
//Creation              :11.03.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module TMDS_enc (pi_clk,pi_rst,pi_display_en,pi_control,pi_data,po_data);
/**************PORT DEFINITION*****************************/
    input wire pi_clk;
    input wire pi_rst;
    input wire pi_display_en;
    input wire [1:0]pi_control; //control bit order C1,C2
    input wire [7:0]pi_data;
    output reg [9:0]po_data;
/***************DEFINITION OF INTERNALS******************/
    reg [9:0]data;
    reg [3:0]i;
    reg [3:0]j;
    reg [3:0]k;
    reg [3:0]ones_i;
    reg [3:0]ones_s;
    reg [3:0]ones_in_data;
    reg [3:0]ones_st_data;
    reg [3:0]bit_diff;
    (* dont_touch = "true" *) reg signed [4:0]disparity;
/**********CALCULATE A NUM OF ONES IN INPUT VECTOR******/
    always_comb begin 
        ones_i = 0;
        for (i=0 ; i<8 ; i=i+1) begin
            if(pi_data[i]) begin
                ones_i = ones_i + 1;      
            end
        end
        ones_in_data = ones_i;
    end
/**********PROCCESS INTERNAL DATA***********************/
    always_comb begin
        if((ones_in_data > 4) || ((ones_in_data == 4) && (!pi_data[0]))) begin
            data[0] = pi_data[0];
            for(j=1 ; j<8 ; j=j+1) begin
                data[j] = data[j-1] ~^ pi_data[j];
            end
            data[8] = 0;
        end
        else begin
            data[0] = pi_data[0];
            for(j=1 ; j<8 ; j=j+1) begin
                data[j] = data[j-1] ^ pi_data[j];
            end
            data[8] = 1;
        end
    end
/**********CALCULATE A NUM OF ONES IN INTERNAL VEC***/
    always_comb begin
        ones_s = 0;
        for(k=0 ; k<8 ; k=k+1) begin
            if(data[k]) begin
                ones_s = ones_s + 1;
            end
        end
        ones_st_data = ones_s;
        bit_diff = ones_s + ones_s - 8;
    end
/***DETERMIN OUTPUT VALUE AND CALCULATE DISPARITY*******/
    always_ff @(posedge pi_clk) begin
        if(!pi_rst) begin
            disparity <= 0;
            po_data <= 0;
        end
        else begin
            if(pi_display_en) begin
                if((!disparity)|| (ones_st_data==4)) begin
                    if(!data[8]) begin
                        po_data <= {2'b10,~(data[7:0])};
                        disparity <= disparity - bit_diff;
                    end
                    else begin
                        po_data <= {2'b01,(data[7:0])};
                        disparity <= disparity + bit_diff;
                    end
                end
                else begin
                    if((disparity > 0 && ones_st_data > 4) || (disparity < 0 && ones_st_data < 4)) begin
                        if(!data[8]) begin
                            po_data <= {2'b10,~(data[7:0])};
                            disparity <= disparity - bit_diff;
                        end
                        else begin
                            po_data <= {2'b11,~(data[7:0])};
                            disparity <= disparity - bit_diff + 2;
                        end
                    end
                    else begin
                        if(!data[8]) begin
                            po_data <= {2'b00,(data[7:0])};
                            disparity <= disparity + bit_diff - 2;
                        end
                        else begin
                            po_data <= {2'b01,(data[7:0])};
                            disparity <= disparity + bit_diff;
                        end
                    end
                 end
            end
            else begin
                case(pi_control) //control bit order C1,C2
                    2'b00:
                        po_data <= 10'b1101010100;
                    2'b01:
                        po_data <= 10'b0010101011;
                    2'b10:
                        po_data <= 10'b0101010100;
                    2'b11:
                        po_data <= 10'b1010101011;
                    default:
                        po_data <= 10'b1010101011;
                endcase
                disparity <= 0;
            end
        end
    end
endmodule
