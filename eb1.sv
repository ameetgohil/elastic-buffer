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

`ifdef FORMAL
   reg f_past_valid = 0;
   initial assume(!rstf);
   always @(posedge clk) begin
      f_past_valid <= 1;
      //reset state
      if(f_past_valild && !rstf) begin
         assert(i_data == 0);
         assert(i_valid == 0);
      end

      if(f_past_valid && rstf && $past(rstf))
        if($past(i_ready) && $past(t_valid))
          assert(i_data == $past(t_data));
      
      if(f_past_valid && rstf && $past(rstf)) begin

         if($past(t_valid))
           assert(i_valid);
         // i_valid should hold ready was not high in the past cycle
         if($past(i_valid) && !$past(i_ready))
           assert(i_valid);

         // data value should not change
         if($past(i_valid) && !$past(i_ready))
           assert(i_data == $past(i_data));

         // t_ready should only low if there is already data in the buffer and i_ready is low
         if(i_ready)
           assert(t_ready);
         if(i_valid && !i_ready)
           assert(t_ready == 0);

         if(!i_valid)
           assert(t_ready);


      end
      
   end

`endif

   
endmodule // eb1
