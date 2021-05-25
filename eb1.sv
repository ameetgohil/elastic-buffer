module eb1 #(DWIDTH=32)
   (input wire[DWIDTH-1:0] t_data,
    input wire                t_valid,
    output wire               t_ready,
    output logic [DWIDTH-1:0] i_data,
    output logic              i_valid,
    input wire                i_ready,
    input wire                clk, rstf
    );

   wire                       dat_en;

   assign t_ready = i_ready | ~i_valid;

   assign dat_en = t_valid & t_ready;
  
   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         i_data <= 0;
         i_valid <= 0;
      end
      else begin
         if(dat_en)
           i_data <= t_data;

         i_valid <= ~t_ready | t_valid;

      end // else: !if(~rstf)
   end // always @ (posedge clk or negedge rstf)

endmodule // eb1
