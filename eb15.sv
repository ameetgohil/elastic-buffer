module eb15 #(DWIDTH=32)
   (input wire[DWIDTH-1:0] t_data,
    input wire                t_valid,
    output wire               t_ready,
    output logic [DWIDTH-1:0] i_data,
    output logic              i_valid,
    input wire                i_ready,
    input                     clk, rstf
    );

   localparam S0 = 5'b1_0_10_0;
   localparam S1 = 5'b1_1_01_0;
   localparam S2 = 5'b0_1_00_0;
   localparam S3 = 5'b1_1_10_1;
   localparam S4 = 5'b0_1_00_1;

   
   
   logic                      en0, en1, sel;
   logic [4:0]                q_state, n_state;

   //  state   d0  d1  t.ready   i.valid   en0     en1     sel
   //  0       x   x   1         0         t.valid 0       0       1_0_10_0
   //  1       0   x   1         1         0       t.valid 0       1_1_01_0
   //  2       0   1   0         1         0       0       0       0_1_00_0
   //  3       x   0   1         1         t.valid 0       1       1_1_10_1
   //  4       1   0   0         1         0       0       1       0_1_00_1

   always_comb begin
      casez({state, t_valid, i_ready})
        {S0, 2'b1?} : n_state = S1;

        {S1, 2'b01} : n_state = S0;
        {S1, 2'b10} : n_state = S2;
        {S1, 2'b11} : n_state = S3;

        {S2, 2'b?1} : n_state = S3;

        {S3, 2'b01} : n_state = S0;
        {S3, 2'b10} : n_state = S4;
        {S3, 2'b11} : n_state = S1;

        {S4, 2'b?1} : n_state = S1;
        default: n_state = state;
      endcase // casez ({state, t_valid, i_ready})
   end // always_comb

   assign t_ready = state[4];
   assign i_valid = state[3];
   assign en0 = state[2] & t_valid;
   assign en1 = state[1] & t_valid;
   assign sel = state[0];

   logic[DWIDTH-1:0] data_r0, data_r1;

   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         data_r0 <= S0;
         data_r1 <= 0;
         q_state <= 0;
      end
      else begin
         q_state <= n_state;
         if(en0)
           data_r0 <= t_data;
         if(en1)
           data_r1 <= t_data;
      end // else: !if(~rstf)
   end
   
endmodule
