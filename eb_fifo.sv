module eb_fifo
  #(parameter DWIDTH = 32,
    parameter DEPTH = 16)
   (input wire [DWIDTH-1:0]   t_data,
    input wire                t_valid,
    output wire               t_ready,
    output logic [DWIDTH-1:0] i_data,
    output logic              i_valid,
    input wire                i_ready,
    input wire                clk, rstf
    );

   reg [DEPTHLOG2MO : 0]      status_cnt;
   reg [DEPTHLOG2MO : 0]      q_rd_ptr;

   assign t_0_ack = !(status_cnt == DEPTHMO);
   assign ren = 1;
   assign wen = t_0_req && t_0_ack;

   always @(posedge clk or negedge reset_n)
     if (~reset_n) i_0_req <= 1'b0;
     else if (status_cnt == 0 && !(t_0_req && t_0_ack)) i_0_req <= 0;
     else if ((i_0_req && i_0_ack)  && !(t_0_req && t_0_ack) && (status_cnt == 1)) i_0_req <= 0;
     else i_0_req <= 1;

   always @(posedge clk or negedge reset_n)
     if (~reset_n) wr_ptr <= 0;
     else if (t_0_req && t_0_ack) wr_ptr <= (wr_ptr == DEPTHMO) ? 0 : (wr_ptr + 1);

   assign rd_ptr=(i_0_req & i_0_ack)?(((q_rd_ptr == DEPTHMO) && (status_cnt != 0)) ? 0 : q_rd_ptr + 1):q_rd_ptr;
   
   always @(posedge clk or negedge reset_n)
     if (~reset_n) begin
        q_rd_ptr <= 0;
     end else begin
        if (i_0_req && i_0_ack) q_rd_ptr <= (((q_rd_ptr == DEPTHMO) && (status_cnt != 0)) ? 0 : (q_rd_ptr + 1));
     end

   always @(posedge clk or negedge reset_n)
     if (~reset_n) status_cnt <= 0;
     else if ((i_0_req && i_0_ack) && (t_0_req && t_0_ack)) status_cnt <= status_cnt;
     else if (i_0_req && i_0_ack && (status_cnt != 0)) status_cnt <= status_cnt - 1;
     else if (t_0_req && t_0_ack) status_cnt <= status_cnt + 1;

endmodule

endmodule // eb_fifo_ctrl



