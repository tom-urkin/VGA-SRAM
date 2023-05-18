//control_signal_generator module
//o_WE_n : logic low upon trigger detection (key of the FPGa board in this example but can be an internal control signal as well). Rises to logic high When write operation is finished.
//o_PRNG_en : Rises to logic high when write operation of N bytes is finished, trigerrs the PRNG module to generate a now row data, i.e. new N pixels (please see timing diagram for detailed view)
module control_signal_generator(i_rst,i_clk,i_count_n,i_count_m,i_wr_trigger,i_rd_trigger,i_next_x_cor,i_next_y_cor,o_WE_n,o_OE_n,o_PRNG_en,o_addr_inc);
//Parameters
parameter N=640;                                              //Numer of pixels in the horizontal axis
parameter M=480;                                              //Number of pixels in the Vertical axis
parameter CNT_WIDTH=10;                                       //Counter width, please modify for N or M larger than 2^10

//Input signals
input logic i_rst;                                            //Active high logic
input logic i_clk;                                            //Input clock
input logic i_wr_trigger;                                     //Key trigger in this case, can also be any internal control signal 
input logic i_rd_trigger;                                     //Key trigger in this case, can also be any internal control signal
input logic [CNT_WIDTH-1:0] i_count_n;                        //Horizontal counter
input logic [CNT_WIDTH-1:0] i_count_m;                        //Vertical counter
input logic [9:0] i_next_x_cor;                               //X Coordinates of the next pixel
input logic [9:0] i_next_y_cor;                               //y Coordinates of the next pixel

//Output signals
output logic o_WE_n;                                          //Write enable signal to the SRAM chip
output logic o_OE_n;                                          //Read enable signal to the SRAM chip
output logic o_PRNG_en;                                       //Enables generation of N new pixels
output logic o_addr_inc;                                      //Rises to logic high when the VGA controller is at the 'active region'

//Internal signals
logic i_wr_trigger_delay;                                     //Creating a single-cycle pulse of i_wr_trigger
logic i_wr_trigger_int;                                       //Creating a single-cycle pulse of i_wr_trigger
logic i_rd_trigger_delay;                                     //Creating a single-cycle pulse of i_rd_trigger
logic i_rd_trigger_int;                                       //Creating a single-cycle pulse of i_rd_trigger

//HDL code

//Creating a single-cycle pulse of i_wr_trigger. It is required due to the large debouncing period of the DE-115 keys.
always @(posedge i_clk or negedge i_rst)
  if (!i_rst) begin
    i_wr_trigger_delay<=1'b1;
    i_wr_trigger_int<=1'b1;
  end
  else begin
    i_wr_trigger_delay<=i_wr_trigger;
	 i_wr_trigger_int<=~(i_wr_trigger_delay&&~i_wr_trigger);
  end

always @(posedge i_clk or negedge i_rst)
  if (!i_rst) begin
    i_rd_trigger_delay<=1'b1;
    i_rd_trigger_int<=1'b1;
  end
  else begin
    i_rd_trigger_delay<=i_rd_trigger;
	 i_rd_trigger_int<=~(i_rd_trigger_delay&&~i_rd_trigger);
  end  


//o_WE_n generation
always @(posedge i_clk or negedge i_rst)
  if (!i_rst)
    o_WE_n<=1'b1;
  else if (i_wr_trigger_int==1'b0)
    o_WE_n<=1'b0;
  else if ((i_count_n==$bits(i_count_n)'(N-1))&&(i_count_m==$bits(i_count_m)'(M-1)))
    o_WE_n<=1'b1;


//o_OE_n generation
always @(posedge i_clk or negedge i_rst)
  if (!i_rst)
    o_OE_n<=1'b1;
  else if (i_rd_trigger_int==1'b0)
    o_OE_n<=~o_OE_n;

	 
assign o_addr_inc = (i_next_x_cor<$bits(i_next_x_cor)'(640))&&(i_next_y_cor<$bits(i_next_y_cor)'(480));
	
//o_PRNG_en generation
always @(posedge i_clk or negedge i_rst)
  if (!i_rst)
    o_PRNG_en<=1'b0;
  else if (i_count_n==$bits(i_count_n)'(N-2))   //Ensures the synchronous 'N-bit to N-byte converter' produces pixel data at the following clock. Please see timing diagram for further details.
    o_PRNG_en<=1'b1;
  else 
    o_PRNG_en<=1'b0;

endmodule
