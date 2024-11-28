`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/25 17:15:41
// Design Name: 
// Module Name: test_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rxtx_fifo_tb;
reg clk_200;
reg user_clk_out;
reg rst;

//wire clk_d1,clk_d2;

reg [63:0]  RX_D  ;
reg        RX_SRC_RDY_N  ;  
wire        EMPTY    ;
wire        ALEMPTY    ;
reg         RD_DATA_EN    ;
wire [63:0] O_CAP_DATA     ;

reg    CHANNEL_UP;

reg CAP_EN;
reg [63:0] IN_CAP_DATA;
wire [63:0] TX_D;
wire TX_SRC_RDY_N;
reg TX_DST_RDY_N;

parameter CLK_200M_CYCLE = 5;
parameter USER_CLK_CYCLE = 20;
parameter RST_TIME = 5;

aurora_64b66b_RX_Fifo_64in_64out U_FIFO_rx(
    .RESET          (rst) ,
    .CLK            (clk_200) ,
                     
    .EMPTY          (EMPTY) ,  //to user interface
    .ALEMPTY        (ALEMPTY) ,
    .RD_DATA_EN     (RD_DATA_EN) ,
    .O_CAP_DATA     (O_CAP_DATA) ,
                     
    .RX_D           (RX_D) , //LL
    .RX_SRC_RDY_N   (RX_SRC_RDY_N) ,
                     
    .USER_CLK       (user_clk_out) ,
    .CHANNEL_UP     (CHANNEL_UP) 
);
aurora_64b66b_TX_Fifo_64in_64out U_FIFO_tx(
    .RESET        (rst),     
    .CLK          (clk_200), 
                 
    .CAP_EN       (CAP_EN),     
    .IN_CAP_DATA  (IN_CAP_DATA),     
                    
    .TX_D         (TX_D),     
    .TX_SRC_RDY_N (TX_SRC_RDY_N),     
    .TX_DST_RDY_N (TX_DST_RDY_N),     
                     
    .USER_CLK     (user_clk_out),     
    .CHANNEL_UP   (CHANNEL_UP)
);

           

always #(2.5) clk_200 = ~clk_200;
always #(USER_CLK_CYCLE/2)user_clk_out = ~user_clk_out;

integer i,ii,iii,iiii;
// 产生复位信号
initial begin
    clk_200 = 1'b1;
    user_clk_out = 1'b1;
    CHANNEL_UP = 1'b0;
    rst = 1'b1;
    #(USER_CLK_CYCLE*RST_TIME);
    rst = 1'b0;
    #(USER_CLK_CYCLE*10);
    CHANNEL_UP = 1'b1;
end
//RX输入信号赋值,TX
initial begin
    #1;
    //赋初值
    RX_D = 0;
    RX_SRC_RDY_N = 1;    
    //TX_DST_RDY_N = 0;
    #(75*USER_CLK_CYCLE);
    //开始赋值
   for(i=0;i<80;i=i+1)begin
      RX_D = i;
      //IN_CAP_DATA = i;
      RX_SRC_RDY_N = ~RX_SRC_RDY_N;
      //TX_DST_RDY_N = ~TX_DST_RDY_N;
      #(USER_CLK_CYCLE);
      RX_SRC_RDY_N = ~RX_SRC_RDY_N;
      //TX_DST_RDY_N = ~TX_DST_RDY_N;
      //CAP_EN = ~CAP_EN;
      #(USER_CLK_CYCLE);
   end
    #(50*USER_CLK_CYCLE);
end

//RX用200m取数据，TX用200m传数据给aurora
initial begin
    #1;
    RD_DATA_EN = 1'b0;
    #(USER_CLK_CYCLE*200);
    for(ii = 0;ii<200;ii=ii+1)begin
        RD_DATA_EN = ~RD_DATA_EN;
        
        #(CLK_200M_CYCLE);
    end
     
    
end
initial begin
    #1;
    CAP_EN = 0;
    IN_CAP_DATA = 0;
    #(75*USER_CLK_CYCLE);
    for(iii=0;iii<80;iii=iii+1)begin
        IN_CAP_DATA = iii;
        CAP_EN = ~CAP_EN;
        #(CLK_200M_CYCLE);
         CAP_EN = ~CAP_EN;
        #(CLK_200M_CYCLE);
    end
end

initial begin
    #1;
    TX_DST_RDY_N = 1;
    #(USER_CLK_CYCLE*100);
    for(iiii=0;iiii<200;iiii=iiii+1)begin
        TX_DST_RDY_N = ~TX_DST_RDY_N;
        #(USER_CLK_CYCLE);
    end
    #(200*CLK_200M_CYCLE);
    $stop;                
end                
endmodule
