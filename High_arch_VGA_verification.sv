//Verification of the VGA driver
module High_arch_VGA_verification(i_rst,i_rst_VGA,i_clk,o_red,o_green,o_blue,hsync,vsync,VGA_blank_N,VGA_sync_N,clk_VGA);

//Input signals
input logic i_clk;                                     //50MHz clock
input logic i_rst;                                     //Active high logic
input logic i_rst_VGA;                                 //Active high logic

//Output signals
//VGA output signals
output logic hsync;                                    //Horizontal synch signal
output logic vsync;                                    //Vertical sync signal
output logic [7:0]  o_red;                             //Red color data bits
output logic [7:0]  o_green;                           //Green color data bits
output logic [7:0]  o_blue;                            //Blue color data bits
output logic VGA_blank_N;                              //Tie to logic high (see ADV7123 video DAC datasheet)
output logic VGA_sync_N;                               //Tie to logic low (see ADV7123 video DAC datasheet)
output logic clk_VGA;                                  //25MHz clock


//Internal signals 
logic [9:0] next_x_cor;                                //Next pixel x-coordinates
logic [9:0] next_y_cor;                                //Next pixel y-coordinates

logic [7:0] i_color;                                   //Pixel data
logic [7:0] color_map [639:0];                         //Horizontal frame data for verification (constant vertical color strips patter)
integer k;                                             

//HDL code
//Generating the VGA driver 25MHz clock
always @(posedge i_clk) 
	if (!i_rst)
    clk_VGA<=1'b0;
	else
    clk_VGA<=~clk_VGA;

//Generating verification band pattern
always @(posedge i_clk)
	 for (k=0; k<640; k=k+1) begin
	   if (k<100)
		  color_map[k]=8'b10110000;
		else if (k<200)
		  color_map[k]=8'b00110100;
		else if (k<300)
		  color_map[k]=8'b00110011;
		else if (k<400)
		  color_map[k]=8'b00001100;
		else if (k<500)
		  color_map[k]=8'b10101100;
		else
		  color_map[k]=8'b00101111;		
	 end 
  
assign i_color=color_map[next_x_cor];

//Instantiating the VGA driver
VGA_Driver m0(.i_rst(i_rst_VGA),
              .i_clk(clk_VGA),
              .i_color(i_color),
              .hsync(hsync),
              .vsync(vsync),
              .o_red(o_red),
              .o_blue(o_blue),
              .o_green(o_green),
              .next_x_cor(next_x_cor),
              .next_y_cor(next_y_cor)
             );

assign VGA_blank_N=1'b1;                              //Tie to logic high (see ADV7123 video DAC datasheet)
assign VGA_sync_N=1'b0;                               //Tie to logic low (see ADV7123 video DAC datasheet)

endmodule
