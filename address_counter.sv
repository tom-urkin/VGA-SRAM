//Address counter
module address_counter(i_rst,i_clk,i_wr_n,i_rd_n,i_addr_inc,A);
//Parameters
parameter CNT_WIDTH=20;                        
parameter N=640;                               
parameter M=480;                               

//Input signals
input logic i_rst;                             //Active low logic
input logic i_clk;                             //Input clock
input logic i_wr_n;                            //SRAM write enable signal
input logic i_rd_n;                            //SRAM READ enable signal
input logic i_addr_inc;                        //Rises to logic high when the VGA controller is at the 'active region'

//Output signals
output logic [CNT_WIDTH-1:0] A;                //Veritical counter (please see attached timing diagram)

//Internal signals
logic [CNT_WIDTH-1:0] count_tmp;

//HDL code
always @(posedge i_clk or negedge i_rst)
  if (!i_rst) 
    A<=$bits(A)'(0);
  else if (i_wr_n==1'b0)                       //Write mode
    A<=A+$bits(A)'(1);	 
  else if (i_rd_n==1'b0) begin                 //Read mode
    if (i_addr_inc==1'b1)
      if (A==$bits(A)'(N*M-1))
		  A<=$bits(A)'(0);
	   else
	     A<=A+$bits(A)'(1);
  end 
  else 
    A<=$bits(A)'(0);


endmodule
