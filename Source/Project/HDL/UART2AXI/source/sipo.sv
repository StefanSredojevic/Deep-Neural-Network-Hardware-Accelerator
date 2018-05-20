/**********************************************************/
/**********************************************************/
//File                  :FIFO BUFFER 
//Project               :SmarTech
//Creation              :12.02.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module sipo #(parameter DATA_WIDTH = 8, parameter FIFO_DEPTH = 4)
(pi_clk, pi_rst, pi_data, pi_write_en, pi_read_en, pi_tlast_over, po_data, po_tlast, po_data_valid);

localparam DATA_BUS_WIDTH = $clog2(DATA_WIDTH);
localparam FIFO_DEPTH_COUNTER_WIDTH = $clog2(FIFO_DEPTH);

input pi_clk;
input pi_rst;
input [DATA_WIDTH-1:0] pi_data;
input pi_write_en;
input pi_read_en;
input pi_tlast_over;

output [(DATA_WIDTH*FIFO_DEPTH)-1:0] po_data;
output po_tlast;
output po_data_valid;
/**********************************************************/
logic [FIFO_DEPTH_COUNTER_WIDTH:0] write_ptr;
logic [FIFO_DEPTH_COUNTER_WIDTH:0] write_ptr_next;
logic [DATA_WIDTH-1:0] fifo_buff [FIFO_DEPTH-1:0];
logic [DATA_WIDTH-1:0] fifo_buff_c [FIFO_DEPTH-1:0];
logic [DATA_WIDTH-1:0] fifo_buff_c_next [FIFO_DEPTH-1:0];
logic write_enable_sync;
logic write_enable_delayed;
logic write_enable_edge;
logic write_enable_falling_edge;
(* dont_touch = "true" *) logic fifo_full;
logic fifo_full_next;
logic tlast_over_sync;
logic tlast_over_delayed;
logic tlast_over_r_edge;
logic new_data_ready;
logic new_data_ready_next;
(* dont_touch = "true" *)logic fifo_full_delayed;
logic fifo_full_r_edge;


assign write_enable_edge = !write_enable_delayed && write_enable_sync;
assign write_enable_falling_edge = write_enable_delayed && !write_enable_sync;
assign tlast_over_r_edge = tlast_over_sync && !tlast_over_delayed;
assign fifo_full_r_edge = fifo_full && !fifo_full_delayed;

always_ff @(posedge pi_clk) begin
    if(!pi_rst) begin
        fifo_buff[FIFO_DEPTH-1:0] <= '{FIFO_DEPTH{0}};
        fifo_buff_c[FIFO_DEPTH-1:0] <= '{FIFO_DEPTH{0}}; 
        write_enable_sync <= 0;
        write_enable_delayed <= 0;
        fifo_full <= 0;
        write_ptr <= 0;
        tlast_over_sync <= 0;
        tlast_over_delayed <= 0;
        new_data_ready <= 0;
        fifo_full_delayed <= 0;
    end
    else begin
        write_enable_sync <= pi_write_en;
        write_enable_delayed <= write_enable_sync;
        fifo_full <= fifo_full_next;
        write_ptr <= write_ptr_next;
        tlast_over_sync <= pi_tlast_over;
        tlast_over_delayed <= tlast_over_sync;
        fifo_full_delayed <= fifo_full;
        new_data_ready <= new_data_ready_next;
        if(write_enable_edge) begin
            fifo_buff[write_ptr] <= pi_data;
        end
        if(fifo_full_next) begin
            fifo_buff[FIFO_DEPTH-1:0] <= '{FIFO_DEPTH{0}};
            fifo_buff_c <= fifo_buff_c_next;
        end          
    end
end

always_comb begin
    write_ptr_next = write_ptr;
    fifo_full_next = fifo_full;
    new_data_ready_next = new_data_ready;
    if(write_enable_edge) begin
        if(write_ptr == FIFO_DEPTH-1) begin
            write_ptr_next = 0;
            fifo_full_next = 1;
            fifo_buff_c_next = {pi_data,fifo_buff[FIFO_DEPTH-2:0]};
            new_data_ready_next = 1;
        end
        else begin
            fifo_full_next = 0;
            write_ptr_next = write_ptr + 1;
            fifo_buff_c_next = fifo_buff_c;
            new_data_ready_next = 0;
        end
    end 
    else if(tlast_over_r_edge) begin
        write_ptr_next = 0;
        fifo_full_next = 1;
        fifo_buff_c_next = fifo_buff;
        //new_data_ready_next = 1;
    end
    else begin
        write_ptr_next = write_ptr;
        fifo_full_next = 0;
        fifo_buff_c_next = fifo_buff_c;
        new_data_ready_next = 0;
    end
end

assign po_data_valid = new_data_ready;
assign po_tlast = pi_tlast_over && new_data_ready;
assign po_data = {fifo_buff_c[0], fifo_buff_c[1], fifo_buff_c[2], fifo_buff_c[3]};
endmodule