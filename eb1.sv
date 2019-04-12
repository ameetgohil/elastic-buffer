module eb1 #(DWIDTH=32)
  (input wire[DWIDTH-1:0] t_data,
   input wire t_valid,
   output wire t_ready,
   output logic[DWIDTH-1:0] i_data,
   output logic i_valid,
   input wire i_ready
   );

   assign i_ready = t_ready;

   
   
endmodule // eb1

