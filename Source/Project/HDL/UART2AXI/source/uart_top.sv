/**********************************************************/
/**********************************************************/
//File                  :UART TOP MODULE 
//Project               :SmarTech
//Creation              :12.02.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module uart_top #(parameter DATA_WIDTH = 8, parameter FIFO_DEPTH_T = 5, parameter FIFO_DEPTH_R = 4)
(pi_clk, pi_rst, pi_baud_rate, pi_stop_bits, pi_t_data, pi_start_tran, pi_fifo_write_en, pi_ur_data, pi_read_data, pi_set_tlast, po_r_data , po_rec_error, po_ut_data, po_tran_over, po_fifo_write_over, po_fifo_full, po_data_avaliable, po_tlast);

input pi_clk;
input pi_rst;
input [14:0] pi_baud_rate;
input pi_stop_bits;
input [DATA_WIDTH-1:0]pi_t_data;
input pi_start_tran;
input pi_fifo_write_en;
input pi_ur_data;
input pi_read_data;
input [19:0] pi_set_tlast;

output [(DATA_WIDTH*FIFO_DEPTH_R)-1:0]po_r_data;
output po_rec_error;
output po_ut_data;
output po_tran_over;
output po_fifo_write_over;
output po_fifo_full;
output po_data_avaliable;
output po_tlast;

logic [DATA_WIDTH-1:0] data_fifo_to_uart;
logic set_new_data;
logic start_tran;
logic read_over;
logic fifo_empty;
logic tran_over;
logic [DATA_WIDTH-1:0] uartTofifo;
logic rFifo_read_en;
logic rFifo_full;
logic rFifo_empty;
logic tlast_over;

uart #(	.DATA_WIDTH(DATA_WIDTH))uart_inst(
		.pi_clk(pi_clk),
		.pi_rst(pi_rst),
		.pi_baud_rate(pi_baud_rate),
		.pi_stop_bits(pi_stop_bits),
		.pi_t_data(data_fifo_to_uart),
		.pi_start_tran(start_tran),
        .pi_set_tlast(pi_set_tlast),
		.pi_ur_data(pi_ur_data),
		.po_r_data(uartTofifo),
		.po_rec_over(rFifo_read_en),
		.po_rec_error(po_rec_error),
		.po_ut_data(po_ut_data),
		.po_tran_over(tran_over),
		.po_load_over(set_new_data),
        .po_tlast_over(tlast_over));
				
fifo #(	.DATA_WIDTH(DATA_WIDTH),
		.FIFO_DEPTH(FIFO_DEPTH_T))fifo_transfer(
		.pi_clk(pi_clk),
		.pi_rst(pi_rst),
		.pi_data(pi_t_data),
		.pi_write_en(pi_fifo_write_en),
		.pi_read_en(set_new_data),
		.po_data(data_fifo_to_uart),
		.po_read_over(read_over),
		.po_write_over(po_fifo_write_over),
		.po_fifo_empty(fifo_empty),
        .po_fifo_full(po_fifo_full));
sipo #( .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_R))fifo_receive(
        .pi_clk(pi_clk),
        .pi_rst(pi_rst),
        .pi_data(uartTofifo),
        .pi_write_en(rFifo_read_en),
        .pi_read_en(pi_read_data),
        .pi_tlast_over(tlast_over),
        .po_data(po_r_data),
        .po_tlast(po_tlast),
        .po_data_valid(po_data_avaliable));
assign start_tran = pi_start_tran && read_over && !fifo_empty;
assign po_tran_over = fifo_empty && tran_over;
endmodule