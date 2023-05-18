//N-bit to N-byte serial converter
//This module converts an N-bit word to N bytes. Pixel color can be changed in the instantiation stage.
module N_bit_to_N_Byte_converter(i_rst,i_clk,i_data,o_word);

//Parameters
parameter N=640;                                         //Width of the PRNG output + ZP to hotizontal frame width
parameter CNT_WIDTH=10;                                  //Counter width. Modify accordingly if N>2^10
parameter COLOR_FORMAT = 8'b11010011;

//Input signals
input logic i_rst;                                       //Active low logic (WE_n signal)
input logic i_clk;                                       //Input clock
input logic [N-1:0] i_data;                              //N-bit word, output of the PRNG module

//Output signals
output logic [7:0] o_word;                               //8-bit word to be written to the SRAM 

//Internal signals
logic tmp_bit;                                           //Single bit to be trasnformed into pixel data, i.e. 8-bit
logic [CNT_WIDTH-1:0] count_tmp;                         //Temporary internal counter

//HDL code
always @(posedge i_clk or negedge i_rst)
  if (!i_rst) begin
    count_tmp<=$bits(count_tmp)'(N-1);
    tmp_bit<=i_data[N-1];
  end
  else if (count_tmp>$bits(count_tmp)'(0)) begin
    count_tmp<=count_tmp-$bits(count_tmp)'(1);
    tmp_bit<=i_data[count_tmp];
  end
  else begin
    count_tmp<=$bits(count_tmp)'(N-1);
	 tmp_bit<=i_data[N-1];
  end

assign o_word= (tmp_bit) ?  COLOR_FORMAT : 8'd0;         //8-bit word to be written into the SRAM
  
endmodule
