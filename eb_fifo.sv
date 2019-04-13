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

   localparam AWIDTH = $clog(DEPTH);

   reg [DWIDTH-1:0]           mem[DEPTH-1:0];
   reg [AWIDTH-1:0]           wr_ptr, rd_ptr;
   reg                        ren, wen;
   reg [AWIDTH-1:0]           status_cnt;
   reg [AWIDTH-1:0]           q_rd_ptr;

   always @(posedge clk)
     if(ren && wen && (wr_ptr == rd_ptr))
       data_r0 <= t_data;
     else if(ren)
       data_r0 <= mem[rd_ptr];

   always @(posedge clk)
     if(wen)
       mem[wr_ptr] <= t_data;

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



