/**********************************************************/
/**********************************************************/
//File                  :UART MODULE 
//Project               :SmarTech
//Creation              :12.02.2018
/**********************************************************/
// Autor                :Marko Kozomora
// Email                :marko.kozomora@lsys-eastern.com
/**********************************************************/
/**********************************************************/
/**********************************************************/
/**********************************************************/
module uart #(parameter DATA_WIDTH = 8)
(pi_clk, pi_rst, pi_baud_rate, pi_stop_bits, pi_t_data, pi_start_tran, pi_ur_data, pi_set_tlast,po_r_data, po_rec_over, po_rec_error, po_ut_data, po_tran_over, po_load_over, po_tlast_over);
/**********************PARAMETERS***************************/
/*WARNING SET ACCURATE VALUE FOR IN_CLK AND BAUD_RATE*/
localparam DATA_BUS_NUM_OF_BITS = $clog2(DATA_WIDTH);
localparam BAUD_RATE_BUS = 15;

localparam IDLE 	 = 3'b000;
localparam START_BIT = 3'b001;
localparam DATA_BITS = 3'b010;
localparam STOP_BITS = 3'b100;

localparam NUM_OF_CLKS_ONE_STOP_BIT_R = (DATA_WIDTH + 2);
localparam NUM_OF_CLKS_TWO_STOP_BITS_R = (DATA_WIDTH + 3);
localparam NUM_OF_CLKS_ONE_STOP_BIT_T = (DATA_WIDTH + 2);
localparam NUM_OF_CLKS_TWO_STOP_BITS_T = (DATA_WIDTH + 3);
localparam CLK_COUNTER_WIDTH = $clog2(NUM_OF_CLKS_TWO_STOP_BITS_T);
/***********************************************************/
/**********************CPU INTERFACE************************/
input pi_clk;
input pi_rst;
input [BAUD_RATE_BUS-1:0] pi_baud_rate;
input pi_stop_bits;
input pi_start_tran;
input [DATA_WIDTH-1:0] pi_t_data;
input [19:0] pi_set_tlast;

output reg [DATA_WIDTH-1:0] po_r_data;
output reg po_rec_over;
output reg po_tran_over;
output reg po_rec_error;
output reg po_load_over;
output po_tlast_over;
/***********************************************************/
/************************UART INTERFACE*********************/
input pi_ur_data;

output reg po_ut_data;
/***********************************************************/
/************************INTERNAL REGISTERS*****************/
reg [2:0] uart_state_t;
reg [2:0] uart_next_state_t;
reg [2:0] uart_state_r;
reg [2:0] uart_next_state_r;
reg [BAUD_RATE_BUS-1:0] t_counter;
reg [BAUD_RATE_BUS-1:0] r_counter;
(* dont_touch = "true" *) reg [CLK_COUNTER_WIDTH-1:0] tran_clk_counter;
(* dont_touch = "true" *) reg [CLK_COUNTER_WIDTH-1:0] rec_clk_counter;
reg t_clk_en;
reg r_clk_en;
reg hold_start_tran;
reg hold_start_rec;
reg start_rec_edge_det;
reg [DATA_BUS_NUM_OF_BITS-1:0] r_bit_counter;
reg [DATA_BUS_NUM_OF_BITS-1:0] r_bit_counter_next;
reg [DATA_WIDTH-1:0] r_data;
reg r_data_ready;
reg r_error_detected;
reg r_data_ready_next;
reg r_error_detected_next;
reg [DATA_BUS_NUM_OF_BITS-1:0] t_bit_counter;
reg [DATA_BUS_NUM_OF_BITS-1:0] t_bit_counter_next;
reg tran_over;
reg tran_over_next;
reg [DATA_WIDTH-1:0] data_to_send;
(* dont_touch = "true" *) reg [DATA_WIDTH-1:0] data_to_send_next;
reg load_over;
reg load_over_next;
reg [19:0] tlast_counter;
(* dont_touch = "true" *) reg start_tran_sync;
(* dont_touch = "true" *) reg start_tran_delayed;
reg start_tran_r_edge;
reg rec_over_delayed;
reg rec_over;
reg rec_over_r_edge;
reg tlast;
reg r_data_ready_delayed;
/*************************************************************/
/*************************PRESCALER LOGIC*********************
Wait for edge of start bit, send signal to fsm that start bit happend
and start with generating clock, which will help us to sample data
in the middle of bits
**************************************************************/
/****************************************************************/
//RECEIVE PRESALER
/****************************************************************/
assign start_rec_edge_det = uart_state_r == IDLE ? !pi_ur_data : 0;
always_ff @(posedge pi_clk) begin
	if(!pi_rst) begin
		r_counter <= (pi_baud_rate >> 1);
		r_clk_en <= 1'b0;
		hold_start_rec <= 1'b0;
	end
	else begin
		if(start_rec_edge_det || hold_start_rec) begin
			hold_start_rec <= 1'b1;
			if(r_counter < pi_baud_rate) begin
				r_counter <= r_counter + 1;
				r_clk_en <= 1'b0;
			end
			else begin
				r_counter <= {BAUD_RATE_BUS{1'b0}};
				if(!pi_stop_bits) begin
					if(rec_clk_counter < NUM_OF_CLKS_ONE_STOP_BIT_R) begin
						if(rec_clk_counter == (NUM_OF_CLKS_ONE_STOP_BIT_R-1)) begin
						    r_counter <= pi_baud_rate;
						end
						else begin
							r_counter <= {BAUD_RATE_BUS{1'b0}};
						end
						rec_clk_counter <= rec_clk_counter + 1;
						r_clk_en <= 1'b1;
					end
					else begin
						r_counter <= pi_baud_rate;
						rec_clk_counter <= {CLK_COUNTER_WIDTH{1'b0}};
						hold_start_rec <= 1'b0;
						r_clk_en <= 1'b1;
					end
				end
				else begin
					if(rec_clk_counter < NUM_OF_CLKS_TWO_STOP_BITS_R) begin
						if(rec_clk_counter == (NUM_OF_CLKS_ONE_STOP_BIT_R-1)) begin
							r_counter <= pi_baud_rate;
						end
						else begin
							r_counter <= {BAUD_RATE_BUS{1'b0}};
						end
						rec_clk_counter <= rec_clk_counter + 1;
						r_clk_en <= 1'b1;
					end
					else begin
						r_counter <= pi_baud_rate;
						rec_clk_counter <= {CLK_COUNTER_WIDTH{1'b0}};
						hold_start_rec <= 1'b0;
						r_clk_en <= 1'b1;
					end
				end
			end
		end
		else begin
			r_counter <= (pi_baud_rate >> 1);
			hold_start_rec <= 1'b0;
			rec_clk_counter <= {CLK_COUNTER_WIDTH{1'b0}};
			r_clk_en <= 1'b0;
		end
	end
end
/****************************************************************/
//TRANSMIT PRESALER
/****************************************************************/
always_ff @(posedge pi_clk) begin
	if(!pi_rst) begin
		t_counter <= pi_baud_rate;
		tran_clk_counter <= {CLK_COUNTER_WIDTH{1'b0}};
		hold_start_tran <= 1'b0;
		t_clk_en <= 1'b0;
	end
	else begin
		if(hold_start_tran || pi_start_tran) begin
			hold_start_tran <= 1'b1;
			if(t_counter < pi_baud_rate) begin
				t_counter <= t_counter + 1;
				t_clk_en <= 1'b0;
			end
			else begin
				t_counter <= {BAUD_RATE_BUS{1'b0}};
				if(!pi_stop_bits) begin
					if(tran_clk_counter < NUM_OF_CLKS_ONE_STOP_BIT_T) begin
						tran_clk_counter <= tran_clk_counter + 1;
						t_clk_en <= 1'b1;
					end
					else begin
						tran_clk_counter <= {CLK_COUNTER_WIDTH{1'b0}};
						hold_start_tran <= 1'b0;
						t_counter <= pi_baud_rate;
						t_clk_en <= 1'b1;
					end
				end
				else begin
					if(tran_clk_counter < NUM_OF_CLKS_TWO_STOP_BITS_T) begin
						tran_clk_counter <= tran_clk_counter + 1;
						t_clk_en <= 1'b1;
					end
					else begin
						tran_clk_counter <= {CLK_COUNTER_WIDTH{1'b0}};
						hold_start_tran <= 1'b0;
						t_counter <= pi_baud_rate;
						t_clk_en <= 1'b1;
					end
				end
			end
		end
		else begin
			hold_start_tran <= 1'b0;
			tran_clk_counter <= {CLK_COUNTER_WIDTH{1'b0}};
			t_counter <= pi_baud_rate;
			t_clk_en <= 1'b0;
		end
	end
end
/****************************************************************/
/************************RECIEVE DATA FSM************************/
/****************************************************************/
//STATE REGISTER
always_ff @(posedge pi_clk) begin
	if(!pi_rst) begin
		uart_state_r <= IDLE;
		r_bit_counter <= {DATA_BUS_NUM_OF_BITS{1'b0}};
		r_data <= {DATA_WIDTH{1'b0}};
		r_data_ready <= 1'b0;
		r_error_detected <= 1'b0;
        rec_over_delayed <= 1'b0;
        rec_over <= 1'b0;
	end
	else if(r_clk_en) begin
		uart_state_r <= uart_next_state_r;
		r_bit_counter <= r_bit_counter_next;
		r_data_ready <= r_data_ready_next;
		r_error_detected <= r_error_detected_next;
        rec_over <= r_data_ready_next;
        rec_over_delayed <= rec_over;
		if(uart_next_state_r == DATA_BITS) begin
			r_data[r_bit_counter_next] = pi_ur_data;
		end
    end
    else begin
        rec_over <= r_data_ready_next;
        rec_over_delayed <= rec_over;
	end
end
//NEXT STATE LOGIC
always_comb begin
	uart_next_state_r = IDLE;
	r_bit_counter_next = {DATA_BUS_NUM_OF_BITS{1'b0}};
	case(uart_state_r)
        IDLE:begin
            uart_next_state_r = START_BIT;
        end
		START_BIT:begin
			uart_next_state_r = DATA_BITS;
		end
		DATA_BITS:begin
			if(r_bit_counter == DATA_WIDTH-1) begin
				uart_next_state_r = STOP_BITS;
				r_bit_counter_next = {DATA_BUS_NUM_OF_BITS{1'b0}};
			end
			else begin
				uart_next_state_r = DATA_BITS;
				r_bit_counter_next = r_bit_counter + 1;
			end
		end
		STOP_BITS:begin
			r_bit_counter_next = r_bit_counter + 1;
			if(!pi_stop_bits) begin
				uart_next_state_r = IDLE;
			end
			else begin
				if(r_bit_counter == 1) begin
					uart_next_state_r = IDLE;
				end
				else begin
					uart_next_state_r = STOP_BITS;
				end
			end
		end
		default:begin
			uart_next_state_r = IDLE;
		end
	endcase
end
//OUTPUT LOGIC
always_comb begin
	r_data_ready_next = r_data_ready;
	r_error_detected_next = r_error_detected;
	case(uart_state_r)
        IDLE:begin
			r_data_ready_next = r_data_ready;
			r_error_detected_next = r_error_detected;
        end
		START_BIT:begin
			r_data_ready_next = r_data_ready;
			r_error_detected_next = r_error_detected;
		end
		DATA_BITS:begin
			r_data_ready_next = 1'b0;
			r_error_detected_next = 1'b0;
		end
		STOP_BITS:begin
			if(pi_ur_data) begin
				r_error_detected_next = 1'b0;
				if(!pi_stop_bits) begin
					r_data_ready_next = 1'b1;
				end
				else begin
					if(r_bit_counter == 1) begin
						r_data_ready_next = 1'b1;
					end
					else begin
						r_data_ready_next = r_data_ready;
					end
				end
			end
			else begin
				r_data_ready_next = 1'b1;
				r_error_detected_next = 1'b1;
			end
		end
		default:begin
			r_data_ready_next = r_data_ready;
			r_error_detected_next = r_error_detected;
		end
	endcase
end
assign po_rec_error = r_error_detected_next;
assign po_rec_over = r_data_ready_delayed;
assign rec_over_r_edge = rec_over && !rec_over_delayed;
assign po_r_data = r_data_ready_next ? r_data : {DATA_WIDTH{1'bz}};
/******************************************************************/
/************************TRANSMIT DATA FSM*************************/
/******************************************************************/
//STATE REGISTER
always_ff @(posedge pi_clk) begin
	if(!pi_rst) begin
		uart_state_t = IDLE;
		t_bit_counter <= {DATA_BUS_NUM_OF_BITS{1'b0}};
		tran_over <= 1'b0;
		data_to_send <= {DATA_WIDTH{1'b0}};
		load_over <= 1'b0;
        start_tran_sync <= 1'b0;
        start_tran_delayed <= 1'b0;
	end
	else if(t_clk_en) begin
		uart_state_t <= uart_next_state_t;
		tran_over <= tran_over_next;
		t_bit_counter <= t_bit_counter_next;
		load_over <= load_over_next;
		data_to_send <= data_to_send_next;
        start_tran_sync <= pi_start_tran;
        start_tran_delayed <= start_tran_sync;
	end
    else begin
        start_tran_sync <= pi_start_tran;
        start_tran_delayed <= start_tran_sync;
    end
end
//NEXT STATE LOGIC
always_comb begin
	uart_next_state_t = IDLE;
	t_bit_counter_next = {DATA_BUS_NUM_OF_BITS{1'b0}};
	case(uart_state_t) 
        IDLE:begin
            uart_next_state_t = START_BIT;
        end
		START_BIT:begin
	        uart_next_state_t = DATA_BITS;
		end
		DATA_BITS:begin
			if(t_bit_counter == DATA_WIDTH-1) begin
				uart_next_state_t = STOP_BITS;
				t_bit_counter_next = {DATA_BUS_NUM_OF_BITS{1'b0}};
			end
			else begin
				uart_next_state_t = DATA_BITS;
				t_bit_counter_next = t_bit_counter + 1;
			end
		end	
		STOP_BITS:begin
			t_bit_counter_next = t_bit_counter + 1;
			if(!pi_stop_bits) begin	
				uart_next_state_t = IDLE;
			end
			else begin
				if(t_bit_counter == 1) begin
					uart_next_state_t = IDLE;
				end
				else begin
					uart_next_state_t = STOP_BITS;
				end
			end
		end
		default:begin
			uart_next_state_t = IDLE;
		end
	endcase
end
//OUTPUT LOGIC
always_comb begin
	tran_over_next = tran_over;
	load_over_next = load_over;
	po_ut_data = 1'b1;
    data_to_send_next = data_to_send;
	case(uart_state_t)
		IDLE:begin
            if(pi_start_tran) begin
			    po_ut_data = 1'b0;
			    tran_over_next = 1'b0;
			    data_to_send_next = pi_t_data;
			    load_over_next = 1'b1;
            end
            else begin
			    po_ut_data = 1'b1;
			    tran_over_next = tran_over;
			    data_to_send_next = pi_t_data;
			    load_over_next = load_over;
            end
		end
		START_BIT:begin
		    po_ut_data = 1'b0;
			tran_over_next = tran_over;
			load_over_next = load_over;
		end
		DATA_BITS:begin
			po_ut_data = data_to_send[t_bit_counter];
			tran_over_next = tran_over;
			load_over_next = 1'b0;
			data_to_send_next = data_to_send;
		end
		STOP_BITS:begin
			data_to_send_next = data_to_send;
			po_ut_data = 1'b1;
			load_over_next = load_over;
			if(!pi_stop_bits) begin
				tran_over_next = 1'b1;
			end
			else begin
				if(t_bit_counter == 1) begin
					tran_over_next = 1'b1;
				end
				else begin
					tran_over_next = tran_over;
				end
			end
		end
	endcase
end

assign po_tran_over = tran_over_next;
assign po_load_over = load_over_next;
assign start_tran_r_edge = start_tran_delayed && !start_tran_sync;
/******************************************************************/
/************************TLAST GENERATOR***************************/
/******************************************************************/
always_ff @(posedge pi_clk) begin
	if(!pi_rst) begin
        tlast_counter <= {10{1'b0}};
        r_data_ready_delayed <= 0;
    end
    else begin
        r_data_ready_delayed <= r_data_ready;
        if(rec_over_r_edge) begin
            if(tlast_counter == pi_set_tlast) begin
                tlast_counter <= 10'd1;
            end
            else begin
                tlast_counter <= tlast_counter + 1'b1;
            end
        end
        else begin
            tlast_counter <= tlast_counter;
        end
    end
end
assign tlast = (tlast_counter == pi_set_tlast) ? 1 : 0;
assign po_tlast_over = tlast;
endmodule
/******************************************************************/