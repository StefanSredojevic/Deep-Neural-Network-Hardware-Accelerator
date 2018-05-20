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
module fifo #(parameter DATA_WIDTH = 8, parameter FIFO_DEPTH = 5)
(pi_clk, pi_rst, pi_data, pi_write_en, pi_read_en, po_data, po_read_over, po_write_over, po_fifo_empty, po_fifo_full);

localparam DATA_BUS_WIDTH = $clog2(DATA_WIDTH);
localparam FIFO_DEPTH_COUNTER_WIDTH = $clog2(FIFO_DEPTH);

input pi_clk;
input pi_rst;
input [DATA_WIDTH-1:0] pi_data;
input pi_write_en;
input pi_read_en;

output [DATA_WIDTH-1:0] po_data;
output po_read_over;
output po_write_over;
output po_fifo_empty;
output po_fifo_full;
/**********************************************************/
logic [FIFO_DEPTH_COUNTER_WIDTH-1:0] read_ptr;
logic [FIFO_DEPTH_COUNTER_WIDTH-1:0] read_ptr_next;
logic [FIFO_DEPTH_COUNTER_WIDTH-1:0] write_ptr;
logic [FIFO_DEPTH_COUNTER_WIDTH-1:0] write_ptr_next;
logic [DATA_WIDTH-1:0] fifo_buff [FIFO_DEPTH-1:0];
logic fifo_full;
logic fifo_empty;
logic read_over_next;
logic read_over;
logic write_over;
logic read_enable_sync;
logic read_enable_delayed;
logic read_enable_edge;
logic [FIFO_DEPTH_COUNTER_WIDTH-1:0] k;
logic last_activity_next;
logic last_activity;
logic write_enable_sync;
logic write_enable_delayed;
logic write_enable_edge;
logic write_enable_falling_edge;

assign fifo_full = read_ptr == write_ptr ? 1 : 0;
assign fifo_empty = read_ptr == write_ptr ? 1 : 0;
assign po_fifo_empty = fifo_empty && !last_activity;
assign po_fifo_full = fifo_full && last_activity;
assign read_enable_edge = !read_enable_delayed && read_enable_sync;
assign write_enable_edge = !write_enable_delayed && write_enable_sync;
assign write_enable_falling_edge = write_enable_delayed && !write_enable_sync;

always_ff @(posedge pi_clk) begin
	if(!pi_rst) begin
		read_ptr <= 0;
		write_ptr <= 0;
        read_over <= 1;
        write_over <= 0;
        read_enable_sync <= 0;
        last_activity <= 0;
        read_enable_delayed <= 0;
        write_enable_sync <= 0;
        write_enable_delayed <= 0;
        for(k = 0; k < FIFO_DEPTH; k = k+ 1) begin
            fifo_buff[k] = {DATA_WIDTH{1'b0}};
        end 
	end
	else begin
        last_activity <= last_activity_next;
		read_ptr <= read_ptr_next;
		write_ptr <= write_ptr_next;
        read_over <= read_over_next;
        read_enable_sync <= pi_read_en;
        read_enable_delayed <= read_enable_sync;
        write_enable_sync <= pi_write_en;
        write_enable_delayed <= write_enable_sync;
		if(write_enable_edge && !po_fifo_full) begin
			fifo_buff[write_ptr] <= pi_data;
            write_over <= 1;
		end
        else if(write_enable_falling_edge) begin
             write_over <= 0;
        end
	end
end

always_comb begin
	read_ptr_next = read_ptr;
	write_ptr_next = write_ptr;
	read_over_next = read_over;
    last_activity_next = last_activity;
	if(write_enable_edge && !write_enable_delayed) begin
		if(!po_fifo_full) begin
			if(write_ptr == FIFO_DEPTH-1) begin
				write_ptr_next = 1'b0;
			end
			else begin
				write_ptr_next = write_ptr + 1;
			end
            read_over_next = 1;
            last_activity_next = 1;
		end
		else begin
			write_ptr_next = write_ptr;
		end
	end
	else if(read_enable_edge && !read_enable_delayed) begin
		if(!po_fifo_empty) begin
			if(read_ptr == FIFO_DEPTH-1) begin
				read_ptr_next = 1'b0;
				read_over_next = 1'b1;
			end
			else begin
				read_ptr_next <= read_ptr + 1'b1;
				read_over_next = 1'b1;
			end
            last_activity_next = 0;
		end
		else begin
			read_over_next = 1'b0;
		end
	end
	else begin
		read_ptr_next = read_ptr;
		write_ptr_next = write_ptr;
	end
end
assign po_data = fifo_buff[read_ptr];
assign po_write_over = write_over;
assign po_read_over = read_over;
endmodule