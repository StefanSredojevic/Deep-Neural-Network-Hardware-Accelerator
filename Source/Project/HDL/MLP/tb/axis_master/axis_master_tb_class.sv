interface axis_master_interface #(parameter integer C_M_AXIS_TDATA_WIDTH = 32); 
    logic [C_M_AXIS_TDATA_WIDTH-1 : 0]   pi_mlp_data;
    logic                                pi_write_to_fifo;
    logic                                po_wr_fifo_done;
    logic                                M_AXIS_ACLK;
    logic                                M_AXIS_ARESETN;
    logic                                M_AXIS_TVALID;
    logic[C_M_AXIS_TDATA_WIDTH-1:0]      M_AXIS_TDATA;
    logic[(C_M_AXIS_TDATA_WIDTH/8)-1:0]  M_AXIS_TSTRB;
    logic                                M_AXIS_TLAST;
    logic                                M_AXIS_TREADY;

    int n;

    task init();
        pi_mlp_data         <= 0;
        pi_write_to_fifo    <= 0;
        M_AXIS_ACLK         <= 0;
        M_AXIS_ARESETN      <= 0;
        M_AXIS_TREADY       <= 0;
        #50 M_AXIS_ARESETN  <= 1;
    endtask

    task send_data(input logic [C_M_AXIS_TDATA_WIDTH-1:0] data, logic set_valid);
        @(posedge M_AXIS_ACLK);
        pi_mlp_data      <= data;
        pi_write_to_fifo <= 1'b1;
        wait(po_wr_fifo_done);
        pi_write_to_fifo <= 1'b0;
    endtask

    task run_tready();
        n = $urandom_range(1,10); 
        M_AXIS_TREADY <= repeat(n)@(posedge M_AXIS_ACLK) 1'b1;
        @(posedge M_AXIS_ACLK);
        M_AXIS_TREADY <= 1'b0;
    endtask

endinterface : axis_master_interface
