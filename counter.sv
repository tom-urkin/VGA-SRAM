//Counter module - counts to N, M times. The counter's outputs are used by the internal control signal generator to correlate between the data generation modules (PRNGs) and the SRAM write/read control signals.
//Pixel data is stored in bytes, there are N bytes per row and M rows.
module counter(i_rst,i_clk,i_en,o_count_n,o_count_m);
//Parameters
parameter N = 640;                                     //Numer of pixels in the horizontal axis
parameter M=480;                                       //Number of pixels in the Vertical axis
parameter CNT_WIDTH=10;                                //Counter width, please modify for N or M larger than 2^10

//Input signals
input logic i_rst;                                     //Active high logic
input logic i_clk;                                     //Input clock
input logic i_en;                                      //
//Output signals
output logic [CNT_WIDTH-1:0] o_count_n;                //Horizontal counter (please see attached timing diagram)
output logic [CNT_WIDTH-1:0] o_count_m;                //Veritical counter (please see attached timing diagram)

//HDL code
always @(posedge i_clk or negedge i_rst)
  if (!i_rst) begin
    o_count_n<=$bits(o_count_n)'(0);
    o_count_m<=$bits(o_count_m)'(0);
  end
  else if (!i_en) begin
    if (o_count_m<$bits(o_count_m)'(M))
      if (o_count_n<$bits(o_count_n)'(N-1))
        o_count_n<=o_count_n+$bits(o_count_n)'(1);
      else begin
        o_count_n<=$bits(o_count_n)'(0);
        o_count_m<=o_count_m+$bits(o_count_m)'(1);
      end
  end

endmodule
