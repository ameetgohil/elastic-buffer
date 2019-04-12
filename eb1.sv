module eb1 #(DWIDTH=32)
  (input wire[DWIDTH-1:0] t_data,
   input wire                t_valid,
   output wire               t_ready,
   output logic [DWIDTH-1:0] i_data,
   output logic              i_valid,
   input wire                i_ready,
   input                     clk, rstf
   );

   assign i_ready = t_ready;

   assign dat_en = t_valid & t_ready;

   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         i_data <= 0;
         i_valid <= 0;
      end
      else begin
         if(dat_en)
           i_data <= t_data;
         i_valid = ~t_ready | t_valid;
      end
   end
   
endmodule // eb1

