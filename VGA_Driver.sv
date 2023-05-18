//VGA Driver
module VGA_Driver(i_rst,i_clk,i_color,hsync,vsync,o_red,o_blue,o_green,next_x_cor,next_y_cor);
//Parameters
parameter ACTIVE_HORIZONTAL = 640;                    //Numer of pixels in the horizontal axis
parameter ACTIVE_VERTICAL = 480;                      //Number of pixels in the Vertical axis

parameter H_LEN_FRONT_PORCH=16;                       //Length of the 'Horizontal front porch' section (see attached figure)
parameter H_LEN_SYNC_PULSE=96;                        //Length of the 'Horizontal Sync' section (see attached figure)
parameter H_LEN_BACK_PORCH=48;                        //Length of the 'Horizontal back porch' section (see attached figure)

parameter V_LEN_FRONT_PORCH=10;                       //Length of the 'Vertical front porch' section (see attached figure)
parameter V_LEN_SYNC_PULSE=2;                         //Length of the 'Vertical synch' section (see attached figure) 
parameter V_LEN_BACK_PORCH=33;                        //Length of the 'Vertical back porch' section (see attached figure)

parameter W_COLOR=8;                                  //Each pixel is described as an 8-bit word

//Local parameters
localparam TOTAL_HORIZONTAL = ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH+H_LEN_SYNC_PULSE+H_LEN_BACK_PORCH;           //Default : 800
localparam TOTAL_VERTICAL = ACTIVE_VERTICAL+V_LEN_FRONT_PORCH+V_LEN_SYNC_PULSE+V_LEN_BACK_PORCH;               //Default : 525

//Input signals
input logic i_rst;                                     //Active low logic
input logic i_clk;                                     //VGA driver clock, ~25MHz
input logic [W_COLOR-1:0] i_color;                     //Instantanious pixel color

//Output signals
output logic hsync;                                    //Horizontal sync signal
output logic vsync;                                    //Vertical sync signal
output logic [W_COLOR-1:0] o_red;                      //Input of the DAC in the VGA connector (converts into an analog signal between 0V-0.7V)
output logic [W_COLOR-1:0] o_green;                    //Input of the DAC in the VGA connector (converts into an analog signal between 0V-0.7V)
output logic [W_COLOR-1:0] o_blue;                     //Input of the DAC in the VGA connector (converts into an analog signal between 0V-0.7V)

output logic [9:0] next_x_cor;                         //X Coordinates of the next pixel. If ACTIVE_HORIZONTAL exceeds 1023, this width should be properly modified
output logic [9:0] next_y_cor;                         //Y Coordinates of the next pixel. If ACTIVE_VERTICAL exceeds 1023, this width should be properly modified

//Internal signals
logic [9:0] count_h;                                   //Resets at 800. If TOTAL_HORIZONTAL exceeds 1023, this width should be modified accordingly
logic [9:0] count_v;                                   //Resets at 525. If TOTAL_VERTICAL exceeds 1023, this width should be modified accordingly

//HDL code
always @(posedge i_clk or negedge i_rst)
  if (!i_rst) begin
    count_h<=$bits(count_h)'(0);
	 count_v<=$bits(count_v)'(0);
    o_red<=$bits(o_red)'(0);
    o_green<=$bits(o_green)'(0);
    o_blue<=$bits(o_blue)'(0);			
  end
  else begin
    if (count_h<TOTAL_HORIZONTAL-1)
	   count_h<=count_h+$bits(count_h)'(1);
	 else if (count_v<TOTAL_VERTICAL-1) begin                                 //End of row
	   count_h<=$bits(count_h)'(0);
		count_v<=count_v+$bits(count_v)'(1);
		end
	 else begin                                                               //End of frame
	   count_h<=$bits(count_h)'(0);
		count_v<=$bits(count_v)'(0);
    end	
	 
	 //hsync generation
	 if (count_h<ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH)                         //Horizontal active region and front porch
	   hsync<=1'b1;                                        
	 else if (count_h<ACTIVE_HORIZONTAL+H_LEN_FRONT_PORCH+H_LEN_SYNC_PULSE)   //Horizontal sync
	   hsync<=1'b0;                                        
	 else                                                                     //Horizontal back porch
	   hsync<=1'b1;  
	 
	 //vsync generation
	 if (count_v<ACTIVE_VERTICAL+V_LEN_FRONT_PORCH)                           //Vertical active region and front porch
	   vsync<=1'b1;
	 else if (count_v<ACTIVE_VERTICAL+V_LEN_FRONT_PORCH+V_LEN_SYNC_PULSE)     //Vertical sync
	   vsync<=1'b0;
	 else                                                                     //Vertical back porch
	   vsync<=1'b1;
		
	 //Output pixel data generation
	 if ((count_h<ACTIVE_HORIZONTAL)&&(count_v<ACTIVE_VERTICAL)) begin
      o_red<={i_color[7:5],5'd0};                                           //Red section (RRRGGGBB color format)
      o_blue<={i_color[1:0],6'd0};                                          //Blue section (RRRGGGBB color format)
      o_green<={i_color[4:2],5'd0};                                         //Green section (RRRGGGBB color format)	   
	 end 
	else begin
     o_red<=$bits(o_red)'(0);
     o_green<=$bits(o_green)'(0);
     o_blue<=$bits(o_blue)'(0);	
	end	
  end
  

//Next cycle pixel coordinates. Frame indexing: [0:639]x[0:479]
assign next_x_cor = count_h;
assign next_y_cor = count_v;
endmodule
